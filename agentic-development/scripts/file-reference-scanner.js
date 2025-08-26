#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

const REFERENCE_PATTERNS = [
  // Markdown links: [text](./path/to/file.md) - most reliable
  /\[([^\]]*)\]\(([^)]+)\)/g,
  
  // Load statements: Load: path/to/file.md - capture full path
  /Load:\s*([^\s\n,]+)/gi,
  
  // Import statements: import './file.js' 
  /import\s+[^'"]*['"]([^'"]+)['"]/g,
  
  // Require statements: require('./file.js')
  /require\(['"]([^'"]+)['"]\)/g,
  
  // GitHub Actions workflow references
  /uses:\s*['"]([^'"]+)['"]/g,
  
  // Pre-commit hook file references
  /entry:\s*([^\s\n]+\.(sh|py|js))/g
];

const EXCLUDED_EXTENSIONS = [
  '.png', '.jpg', '.jpeg', '.gif', '.svg', '.ico',
  '.pdf', '.zip', '.tar', '.gz', '.exe', '.dll',
  '.mp4', '.mp3', '.wav', '.avi'
];

const EXCLUDED_DIRECTORIES = [
  'node_modules',
  '.git',
  '.npm',
  'coverage',
  'dist',
  'build',
  '.next',
  '.cache'
];

// Template variable patterns that should be ignored
const TEMPLATE_PATTERNS = [
  // Template variables like {agent-name}, {variable-name}
  /\{[^}]+\}/g,
  
  // Bash variables like $REPO, $VAR, ${VAR}
  /\$\{?[A-Za-z_][A-Za-z0-9_]*\}?/g,
  
  // Environment variables in documentation
  /\$\([A-Za-z_][A-Za-z0-9_]*\)/g,
  
  // Generic placeholders
  /\b(NAME|REPO|PATH|FILE|DIR|VAR)\b/g,
  
  // Workflow variables
  /\$\{\{\s*[^}]+\s*\}\}/g
];

class FileReferenceScanner {
  constructor(rootPath = process.cwd()) {
    this.rootPath = path.resolve(rootPath);
    this.results = {
      totalReferences: 0,
      validReferences: 0,
      invalidReferences: 0,
      files: {},
      brokenReferences: [],
      templateReferences: [],
      statistics: {
        byFileType: {},
        byReferenceType: {},
        coveragePercentage: 0
      }
    };
    // Test coverage tracking
    this.testCoverage = {
      scriptsRequiringTests: [],
      scriptsWithTests: [],
      untestedScripts: [],
      testCoveragePercentage: 0
    };
    // Issue tracking
    this.issueTracking = {
      enabled: false,
      createdIssues: [],
      updatedIssues: [],
      closedIssues: [],
      existingIssues: new Map()
    };
  }

  shouldSkipFile(filePath) {
    const relativePath = path.relative(this.rootPath, filePath);
    
    // Skip excluded directories
    for (const excludedDir of EXCLUDED_DIRECTORIES) {
      if (relativePath.includes(excludedDir)) {
        return true;
      }
    }
    
    // Skip excluded extensions
    const ext = path.extname(filePath).toLowerCase();
    return EXCLUDED_EXTENSIONS.includes(ext);
  }

  getAllFiles() {
    const files = [];
    
    const walk = (dir) => {
      const items = fs.readdirSync(dir);
      
      for (const item of items) {
        const fullPath = path.join(dir, item);
        const stat = fs.statSync(fullPath);
        
        if (stat.isDirectory()) {
          if (!this.shouldSkipFile(fullPath)) {
            walk(fullPath);
          }
        } else if (stat.isFile() && !this.shouldSkipFile(fullPath)) {
          files.push(fullPath);
        }
      }
    };
    
    walk(this.rootPath);
    return files;
  }

  isTemplateReference(referencePath) {
    // Check if the reference contains template variables
    for (const pattern of TEMPLATE_PATTERNS) {
      pattern.lastIndex = 0; // Reset regex state
      if (pattern.test(referencePath)) {
        return true;
      }
    }
    return false;
  }

  extractReferences(content, filePath) {
    const references = new Set();
    const fileDir = path.dirname(filePath);
    
    for (const pattern of REFERENCE_PATTERNS) {
      let match;
      
      // Reset regex state
      pattern.lastIndex = 0;
      
      // DoS protection: Limit regex iterations and execution time
      const maxIterations = 10000;
      const startTime = Date.now();
      const maxExecutionTime = 5000; // 5 seconds
      let iterations = 0;
      
      while ((match = pattern.exec(content)) !== null) {
        // Prevent excessive iterations (ReDoS protection)
        if (++iterations > maxIterations) {
          console.warn(`[SECURITY] Regex iteration limit exceeded for file: ${filePath}`);
          break;
        }
        
        // Prevent excessive execution time (ReDoS protection)
        if (Date.now() - startTime > maxExecutionTime) {
          console.warn(`[SECURITY] Regex execution time limit exceeded for file: ${filePath}`);
          break;
        }
        let referencePath;
        
        // Handle different pattern types
        if (match[2]) {
          // Markdown links [text](path)
          referencePath = match[2];
        } else if (match[1]) {
          // Other patterns with single capture group
          referencePath = match[1];
        } else {
          // Full match for patterns without capture groups
          referencePath = match[0];
        }
        
        // Skip URLs and anchors
        if (referencePath.startsWith('http') || referencePath.startsWith('#') || referencePath.startsWith('mailto:')) {
          continue;
        }
        
        // Skip empty or whitespace-only references
        if (!referencePath.trim()) {
          continue;
        }
        
        // Check if this is a template reference
        const isTemplate = this.isTemplateReference(referencePath);
        
        // Resolve relative paths with security validation
        let resolvedPath;
        
        // Sanitize path - remove null bytes and excessive dot sequences
        const sanitizedPath = referencePath.replace(/\0/g, '').replace(/\.{3,}/g, '..');
        
        if (sanitizedPath.startsWith('./') || sanitizedPath.startsWith('../')) {
          resolvedPath = path.resolve(fileDir, sanitizedPath);
        } else if (sanitizedPath.startsWith('/')) {
          resolvedPath = path.resolve(this.rootPath, sanitizedPath.substring(1));
        } else if (sanitizedPath.includes('agentic-development') || sanitizedPath.includes('.claude')) {
          resolvedPath = path.resolve(this.rootPath, sanitizedPath);
        } else {
          resolvedPath = path.resolve(fileDir, sanitizedPath);
        }
        
        // Security check: Ensure resolved path is within allowed boundaries
        const normalizedRoot = path.normalize(this.rootPath);
        const normalizedResolved = path.normalize(resolvedPath);
        
        if (!normalizedResolved.startsWith(normalizedRoot)) {
          console.warn(`[SECURITY] Path traversal attempt detected: ${referencePath} -> ${resolvedPath}`);
          continue; // Skip this reference
        }
        
        references.add({
          original: referencePath,
          resolved: resolvedPath,
          type: this.getReferenceType(referencePath, pattern),
          line: this.getLineNumber(content, match.index),
          isTemplate: isTemplate
        });
      }
    }
    
    return Array.from(references);
  }

  getReferenceType(referencePath, pattern) {
    if (pattern.source.includes('\\[.*\\]\\(')) return 'markdown-link';
    if (pattern.source.includes('Load:')) return 'load-statement';
    if (pattern.source.includes('import')) return 'import-statement';
    if (pattern.source.includes('require')) return 'require-statement';
    if (pattern.source.includes('uses:')) return 'github-action';
    if (pattern.source.includes('entry:')) return 'pre-commit-hook';
    
    // Determine type based on path content
    if (referencePath.includes('.claude/agents/')) return 'agent-file';
    if (referencePath.includes('agentic-development')) return 'documentation';
    if (referencePath.startsWith('./') || referencePath.startsWith('../')) return 'relative-path';
    
    return 'other';
  }

  getLineNumber(content, index) {
    return content.substring(0, index).split('\n').length;
  }

  validateReference(reference) {
    try {
      // Template references are considered valid by default
      if (reference.isTemplate) {
        return true;
      }
      
      // Check if file exists
      if (fs.existsSync(reference.resolved)) {
        return true;
      }
      
      // Check for common variations
      const alternatives = [
        reference.resolved + '.md',
        reference.resolved + '/README.md',
        reference.resolved.replace(/\.(md|js|sh)$/, ''),
        reference.resolved.replace(/\/index\.(md|js)$/, '')
      ];
      
      for (const alt of alternatives) {
        if (fs.existsSync(alt)) {
          return true;
        }
      }
      
      return false;
    } catch (error) {
      console.error(`Error validating reference: ${reference.resolved}`, error);
      return false;
    }
  }

  scanFile(filePath) {
    try {
      const content = fs.readFileSync(filePath, 'utf-8');
      const references = this.extractReferences(content, filePath);
      const fileExt = path.extname(filePath);
      
      // Update statistics
      this.results.statistics.byFileType[fileExt] = (this.results.statistics.byFileType[fileExt] || 0) + references.length;
      
      const fileResults = {
        references: references.length,
        valid: 0,
        invalid: 0,
        template: 0,
        details: []
      };
      
      for (const reference of references) {
        this.results.totalReferences++;
        
        // Update reference type statistics
        this.results.statistics.byReferenceType[reference.type] = 
          (this.results.statistics.byReferenceType[reference.type] || 0) + 1;
        
        if (reference.isTemplate) {
          this.results.templateReferences.push({
            file: path.relative(this.rootPath, filePath),
            reference: reference.original,
            line: reference.line,
            type: reference.type
          });
          fileResults.template++;
          // Count templates as valid for coverage calculation
          this.results.validReferences++;
          fileResults.valid++;
        } else if (this.validateReference(reference)) {
          this.results.validReferences++;
          fileResults.valid++;
        } else {
          this.results.invalidReferences++;
          fileResults.invalid++;
          
          this.results.brokenReferences.push({
            file: path.relative(this.rootPath, filePath),
            reference: reference.original,
            resolved: reference.resolved,
            line: reference.line,
            type: reference.type
          });
        }
        
        fileResults.details.push({
          original: reference.original,
          resolved: reference.resolved,
          type: reference.type,
          line: reference.line,
          valid: reference.isTemplate || this.validateReference(reference),
          isTemplate: reference.isTemplate
        });
      }
      
      this.results.files[path.relative(this.rootPath, filePath)] = fileResults;
      
    } catch (error) {
      console.error(`Error scanning file ${filePath}:`, error.message);
    }
  }

  scanTestCoverage() {
    console.log('🧪 Scanning test coverage...');
    
    const scriptFiles = this.getAllFiles().filter(file => {
      const ext = path.extname(file);
      return ext === '.sh' || ext === '.js';
    });
    
    this.testCoverage.scriptsRequiringTests = scriptFiles.map(file => 
      path.relative(this.rootPath, file)
    );
    
    for (const scriptFile of scriptFiles) {
      const relativePath = path.relative(this.rootPath, scriptFile);
      const hasTest = this.hasTestFile(scriptFile);
      
      if (hasTest) {
        this.testCoverage.scriptsWithTests.push(relativePath);
      } else {
        this.testCoverage.untestedScripts.push(relativePath);
      }
    }
    
    const totalScripts = this.testCoverage.scriptsRequiringTests.length;
    const testedScripts = this.testCoverage.scriptsWithTests.length;
    
    this.testCoverage.testCoveragePercentage = totalScripts > 0 
      ? Math.round((testedScripts / totalScripts) * 100) 
      : 100;
    
    console.log(`📊 Test Coverage: ${this.testCoverage.testCoveragePercentage}% (${testedScripts}/${totalScripts})`);
  }

  hasTestFile(scriptFile) {
    const ext = path.extname(scriptFile);
    const baseName = path.basename(scriptFile, ext);
    const dirName = path.dirname(scriptFile);
    
    const testPatterns = [];
    
    if (ext === '.sh') {
      // BATS test patterns
      testPatterns.push(
        path.join(this.rootPath, 'tests', 'unit', `${baseName}.bats`),
        path.join(dirName, 'tests', `${baseName}.bats`),
        path.join(dirName, `${baseName}.bats`)
      );
    } else if (ext === '.js') {
      // Jest test patterns
      testPatterns.push(
        path.join(this.rootPath, 'tests', 'unit', `${baseName}.test.js`),
        path.join(dirName, '__tests__', `${baseName}.test.js`),
        path.join(dirName, `${baseName}.test.js`)
      );
    }
    
    return testPatterns.some(pattern => fs.existsSync(pattern));
  }

  async createGitHubIssues() {
    if (!this.issueTracking.enabled) return;
    
    console.log('📝 Creating GitHub issues for broken references...');
    
    try {
      // Group broken references by file
      const brokenByFile = {};
      for (const broken of this.results.brokenReferences) {
        if (!brokenByFile[broken.file]) {
          brokenByFile[broken.file] = [];
        }
        brokenByFile[broken.file].push(broken);
      }
      
      for (const [file, brokenRefs] of Object.entries(brokenByFile)) {
        const issueTitle = `Fix broken file references in ${file}`;
        
        // Check if issue already exists
        const existingIssue = await this.findExistingIssue(issueTitle);
        if (existingIssue) {
          console.log(`📄 Issue already exists for ${file}: #${existingIssue.number}`);
          this.issueTracking.existingIssues.set(file, existingIssue);
          continue;
        }
        
        const issueBody = this.createIssueBody(file, brokenRefs);
        
        try {
          const result = execSync(`gh issue create --title "${issueTitle}" --body "${issueBody}" --label "documentation,broken-reference" --assignee @me`, {
            encoding: 'utf-8',
            cwd: this.rootPath
          });
          
          const issueUrl = result.trim();
          const issueNumber = issueUrl.split('/').pop();
          
          console.log(`✅ Created issue #${issueNumber} for ${file}`);
          this.issueTracking.createdIssues.push({
            file,
            issueNumber,
            issueUrl,
            brokenCount: brokenRefs.length
          });
          
        } catch (error) {
          console.error(`❌ Failed to create issue for ${file}:`, error.message);
        }
      }
      
    } catch (error) {
      console.error('❌ Error creating GitHub issues:', error.message);
    }
  }

  async findExistingIssue(title) {
    try {
      const result = execSync(`gh issue list --state open --search "${title}" --json number,title`, {
        encoding: 'utf-8',
        cwd: this.rootPath
      });
      
      const issues = JSON.parse(result);
      return issues.find(issue => issue.title === title) || null;
      
    } catch (error) {
      console.error('Error searching for existing issues:', error.message);
      return null;
    }
  }

  createIssueBody(file, brokenRefs) {
    const lines = [
      `## Broken File References in \`${file}\``,
      '',
      `Found ${brokenRefs.length} broken file reference(s) that need to be fixed.`,
      '',
      '### Broken References:',
      ''
    ];
    
    for (const ref of brokenRefs) {
      lines.push(`- Line ${ref.line}: \`${ref.reference}\``);
      lines.push(`  - Type: ${ref.type}`);
      lines.push(`  - Resolved to: \`${ref.resolved}\``);
      lines.push('');
    }
    
    lines.push('### Resolution Options:');
    lines.push('1. **Fix the path**: Update the reference to point to the correct file location');
    lines.push('2. **Create missing file**: If the referenced file should exist, create it');
    lines.push('3. **Remove reference**: If the reference is no longer needed, remove it');
    lines.push('');
    lines.push('---');
    lines.push('*This issue was automatically generated by the file reference scanner.*');
    
    return lines.join('\\n').replace(/"/g, '\\"');
  }

  scan(options = {}) {
    const {
      verbose = false,
      createIssues = false,
      scanTests = true
    } = options;
    
    if (verbose) {
      console.log(`🔍 Starting file reference scan in: ${this.rootPath}`);
    }
    
    this.issueTracking.enabled = createIssues;
    
    const files = this.getAllFiles();
    if (verbose) {
      console.log(`📁 Found ${files.length} files to scan`);
    }
    
    for (const file of files) {
      this.scanFile(file);
    }
    
    // Calculate coverage percentage
    this.results.statistics.coveragePercentage = this.results.totalReferences > 0
      ? Math.round((this.results.validReferences / this.results.totalReferences) * 100)
      : 100;
    
    // Scan test coverage if enabled
    if (scanTests) {
      this.scanTestCoverage();
    }
    
    if (verbose) {
      this.printResults();
    }
    
    return this.results;
  }

  printResults() {
    console.log('\n📊 Scan Results Summary:');
    console.log('========================');
    console.log(`Total References: ${this.results.totalReferences}`);
    console.log(`Valid References: ${this.results.validReferences}`);
    console.log(`Template References: ${this.results.templateReferences.length}`);
    console.log(`Invalid References: ${this.results.invalidReferences}`);
    console.log(`Coverage Percentage: ${this.results.statistics.coveragePercentage}%`);
    
    if (this.results.brokenReferences.length > 0) {
      console.log(`\n❌ Broken References (${this.results.brokenReferences.length}):`);
      for (const broken of this.results.brokenReferences.slice(0, 10)) {
        console.log(`  ${broken.file}:${broken.line} → ${broken.reference}`);
      }
      if (this.results.brokenReferences.length > 10) {
        console.log(`  ... and ${this.results.brokenReferences.length - 10} more`);
      }
    }
    
    if (this.results.templateReferences.length > 0) {
      console.log(`\n📝 Template References (${this.results.templateReferences.length}):`);
      for (const template of this.results.templateReferences.slice(0, 5)) {
        console.log(`  ${template.file}:${template.line} → ${template.reference} (${template.type})`);
      }
      if (this.results.templateReferences.length > 5) {
        console.log(`  ... and ${this.results.templateReferences.length - 5} more`);
      }
    }
    
    console.log('\n🧪 Test Coverage:');
    console.log(`Scripts Requiring Tests: ${this.testCoverage.scriptsRequiringTests.length}`);
    console.log(`Scripts With Tests: ${this.testCoverage.scriptsWithTests.length}`);
    console.log(`Untested Scripts: ${this.testCoverage.untestedScripts.length}`);
    console.log(`Test Coverage: ${this.testCoverage.testCoveragePercentage}%`);
  }

  getGitCommit() {
    try {
      return execSync('git rev-parse HEAD', { 
        encoding: 'utf-8', 
        cwd: this.rootPath 
      }).trim();
    } catch (error) {
      return 'unknown';
    }
  }

  generateReport(outputFile = null) {
    const report = {
      timestamp: new Date().toISOString(),
      totalFiles: Object.keys(this.results.files).length,
      totalReferences: this.results.totalReferences,
      validReferences: this.results.validReferences,
      invalidReferences: this.results.invalidReferences,
      templateReferences: this.results.templateReferences.length,
      coveragePercentage: this.results.statistics.coveragePercentage,
      brokenReferenceCount: this.results.brokenReferences.length,
      statistics: this.results.statistics,
      gitCommit: this.getGitCommit(),
      testCoverage: this.testCoverage,
      issueTracking: {
        enabled: this.issueTracking.enabled,
        createdIssues: this.issueTracking.createdIssues,
        updatedIssues: this.issueTracking.updatedIssues,
        closedIssues: this.issueTracking.closedIssues,
        existingIssuesCount: this.issueTracking.existingIssues.size
      }
    };
    
    if (outputFile) {
      fs.writeFileSync(outputFile, JSON.stringify(report, null, 2));
      console.log(`📄 Report saved to: ${outputFile}`);
    }
    
    return report;
  }
}

// CLI Interface
async function main() {
  const args = process.argv.slice(2);
  const options = {};
  let outputFile = null;
  
  for (let i = 0; i < args.length; i++) {
    const arg = args[i];
    
    if (arg === '--verbose' || arg === '-v') {
      options.verbose = true;
    } else if (arg === '--create-issues') {
      options.createIssues = true;
    } else if (arg === '--no-tests') {
      options.scanTests = false;
    } else if (arg.startsWith('--output=')) {
      outputFile = arg.split('=')[1];
    } else if (arg === '--help' || arg === '-h') {
      console.log(`
File Reference Scanner
=====================

Usage: node file-reference-scanner.js [options]

Options:
  --verbose, -v      Show detailed output during scanning
  --create-issues    Create GitHub issues for broken references
  --no-tests        Skip test coverage scanning
  --output=FILE     Save results to JSON file
  --help, -h        Show this help message

Examples:
  node file-reference-scanner.js --verbose
  node file-reference-scanner.js --create-issues --output=results.json
  node file-reference-scanner.js --verbose --no-tests
      `);
      process.exit(0);
    }
  }
  
  const scanner = new FileReferenceScanner();
  
  try {
    const results = scanner.scan(options);
    const report = scanner.generateReport(outputFile);
    
    // Create GitHub issues if requested
    if (options.createIssues) {
      await scanner.createGitHubIssues();
    }
    
    // Exit with appropriate code
    if (results.invalidReferences > 0) {
      console.log(`\n❌ Scan completed with ${results.invalidReferences} broken references`);
      process.exit(1);
    } else {
      console.log(`\n✅ Scan completed successfully - all references valid`);
      process.exit(0);
    }
    
  } catch (error) {
    console.error('❌ Scanner failed:', error.message);
    if (options.verbose) {
      console.error(error.stack);
    }
    process.exit(1);
  }
}

if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export default FileReferenceScanner;