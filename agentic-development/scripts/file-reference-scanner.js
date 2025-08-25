#!/usr/bin/env node

import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';

const REFERENCE_PATTERNS = [
  // Markdown links: [text](./path/to/file.md)
  /\[([^\]]*)\]\(([^)]+)\)/g,
  
  // Load statements: Load: path/to/file.md
  /Load:\s*([^\s\n,]+)/gi,
  
  // Agent file references: .claude/agents/name.md
  /\.claude\/agents\/[^\s\n,)]+\.md/g,
  
  // Documentation paths: agentic-development/path/to/file
  /agentic-development\/[^\s\n,)]+/g,
  
  // Relative script paths: ./scripts/file.sh
  /\.\/[^\s\n,)'"]+\.(sh|js|md|json|yml|yaml)/g,
  
  // Import statements: import './file.js'
  /import\s+[^'"]*['"]([^'"]+)['"]/g,
  
  // Require statements: require('./file.js')
  /require\(['"]([^'"]+)['"]\)/g,
  
  // GitHub Actions workflow references
  /uses:\s*['".]([^'"]+)['"]/g,
  
  // Pre-commit hook file references
  /entry:\s*([^\s\n]+)/g
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

class FileReferenceScanner {
  constructor(rootPath = process.cwd()) {
    this.rootPath = path.resolve(rootPath);
    this.results = {
      totalReferences: 0,
      validReferences: 0,
      invalidReferences: 0,
      files: {},
      brokenReferences: [],
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

  extractReferences(content, filePath) {
    const references = new Set();
    const fileDir = path.dirname(filePath);
    
    for (const pattern of REFERENCE_PATTERNS) {
      let match;
      
      // Reset regex state
      pattern.lastIndex = 0;
      
      while ((match = pattern.exec(content)) !== null) {
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
        
        // Resolve relative paths
        let resolvedPath;
        if (referencePath.startsWith('./') || referencePath.startsWith('../')) {
          resolvedPath = path.resolve(fileDir, referencePath);
        } else if (referencePath.startsWith('/')) {
          resolvedPath = path.resolve(this.rootPath, referencePath.substring(1));
        } else if (referencePath.includes('agentic-development') || referencePath.includes('.claude')) {
          resolvedPath = path.resolve(this.rootPath, referencePath);
        } else {
          resolvedPath = path.resolve(fileDir, referencePath);
        }
        
        references.add({
          original: referencePath,
          resolved: resolvedPath,
          type: this.getReferenceType(referencePath, pattern),
          line: this.getLineNumber(content, match.index)
        });
      }
    }
    
    return Array.from(references);
  }

  getReferenceType(referencePath, pattern) {
    if (pattern.source.includes('\\[.*\\]\\(')) return 'markdown-link';
    if (pattern.source.includes('Load:')) return 'load-statement';
    if (pattern.source.includes('\\.claude\\/agents')) return 'agent-file';
    if (pattern.source.includes('agentic-development')) return 'documentation';
    if (pattern.source.includes('\\.\\/')); return 'relative-path';
    if (pattern.source.includes('import')) return 'import-statement';
    if (pattern.source.includes('require')) return 'require-statement';
    if (pattern.source.includes('uses:')) return 'github-action';
    if (pattern.source.includes('entry:')) return 'pre-commit-hook';
    return 'other';
  }

  getLineNumber(content, index) {
    return content.substring(0, index).split('\n').length;
  }

  validateReference(reference) {
    try {
      // Check if file exists
      if (fs.existsSync(reference.resolved)) {
        return true;
      }
      
      // Check for common extensions if none provided
      if (!path.extname(reference.resolved)) {
        const commonExtensions = ['.md', '.js', '.json', '.sh', '.yml', '.yaml'];
        for (const ext of commonExtensions) {
          if (fs.existsSync(reference.resolved + ext)) {
            return true;
          }
        }
      }
      
      return false;
    } catch (error) {
      return false;
    }
  }

  scanFile(filePath) {
    try {
      const content = fs.readFileSync(filePath, 'utf8');
      const references = this.extractReferences(content, filePath);
      const relativePath = path.relative(this.rootPath, filePath);
      
      const fileResult = {
        path: relativePath,
        totalReferences: references.length,
        validReferences: 0,
        invalidReferences: 0,
        references: []
      };
      
      for (const reference of references) {
        const isValid = this.validateReference(reference);
        
        const referenceResult = {
          ...reference,
          valid: isValid,
          relativeTo: relativePath
        };
        
        fileResult.references.push(referenceResult);
        
        if (isValid) {
          fileResult.validReferences++;
          this.results.validReferences++;
        } else {
          fileResult.invalidReferences++;
          this.results.invalidReferences++;
          this.results.brokenReferences.push(referenceResult);
        }
        
        this.results.totalReferences++;
        
        // Update statistics
        const ext = path.extname(relativePath) || 'no-extension';
        this.results.statistics.byFileType[ext] = (this.results.statistics.byFileType[ext] || 0) + 1;
        this.results.statistics.byReferenceType[reference.type] = (this.results.statistics.byReferenceType[reference.type] || 0) + 1;
      }
      
      this.results.files[relativePath] = fileResult;
      
    } catch (error) {
      console.warn(`Warning: Could not scan file ${filePath}: ${error.message}`);
    }
  }

  generateCoverageBaseline() {
    const baseline = {
      timestamp: new Date().toISOString(),
      totalFiles: Object.keys(this.results.files).length,
      totalReferences: this.results.totalReferences,
      validReferences: this.results.validReferences,
      invalidReferences: this.results.invalidReferences,
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
    
    return baseline;
  }

  getGitCommit() {
    try {
      return execSync('git rev-parse HEAD', { encoding: 'utf8', cwd: this.rootPath }).trim();
    } catch (error) {
      return 'unknown';
    }
  }

  // Test Coverage Detection Methods
  isScriptFile(filePath) {
    const ext = path.extname(filePath).toLowerCase();
    const relativePath = path.relative(this.rootPath, filePath);
    
    // Skip test files themselves and exclude certain directories
    if (relativePath.includes('test') || relativePath.includes('spec')) {
      return false;
    }
    
    if (relativePath.includes('node_modules') || relativePath.includes('.git')) {
      return false;
    }
    
    return ext === '.js' || ext === '.sh';
  }

  getExpectedTestPath(scriptPath) {
    const relativePath = path.relative(this.rootPath, scriptPath);
    const ext = path.extname(scriptPath);
    const basename = path.basename(scriptPath, ext);
    
    // Different test patterns for different file types
    const testPatterns = [];
    
    if (ext === '.sh') {
      // BATS test patterns for shell scripts
      testPatterns.push(`tests/unit/${basename}.bats`);
      testPatterns.push(`tests/${basename}.bats`);
      testPatterns.push(`test/${basename}.bats`);
      testPatterns.push(`${path.dirname(relativePath)}/tests/${basename}.bats`);
    } else if (ext === '.js') {
      // Jest/Node test patterns for JavaScript files
      testPatterns.push(`tests/unit/${basename}.test.js`);
      testPatterns.push(`tests/${basename}.test.js`);
      testPatterns.push(`test/${basename}.test.js`);
      testPatterns.push(`${path.dirname(relativePath)}/tests/${basename}.test.js`);
      testPatterns.push(`${path.dirname(relativePath)}/__tests__/${basename}.test.js`);
    }
    
    return testPatterns;
  }

  hasTestFile(scriptPath) {
    const testPatterns = this.getExpectedTestPath(scriptPath);
    
    for (const testPattern of testPatterns) {
      const testPath = path.resolve(this.rootPath, testPattern);
      if (fs.existsSync(testPath)) {
        return { hasTest: true, testPath: testPattern };
      }
    }
    
    return { hasTest: false, expectedPaths: testPatterns };
  }

  scanTestCoverage() {
    console.log('🧪 Scanning test coverage for scripts...');
    
    const allFiles = this.getAllFiles();
    const scriptFiles = allFiles.filter(file => this.isScriptFile(file));
    
    console.log(`📝 Found ${scriptFiles.length} script files to check for tests`);
    
    for (const scriptFile of scriptFiles) {
      const relativePath = path.relative(this.rootPath, scriptFile);
      const testResult = this.hasTestFile(scriptFile);
      
      if (testResult.hasTest) {
        this.testCoverage.scriptsWithTests.push({
          script: relativePath,
          testFile: testResult.testPath
        });
      } else {
        this.testCoverage.untestedScripts.push({
          script: relativePath,
          expectedTestPaths: testResult.expectedPaths
        });
      }
      
      this.testCoverage.scriptsRequiringTests.push(relativePath);
    }
    
    // Calculate test coverage percentage
    const totalScripts = this.testCoverage.scriptsRequiringTests.length;
    const testedScripts = this.testCoverage.scriptsWithTests.length;
    
    this.testCoverage.testCoveragePercentage = totalScripts > 0 
      ? Math.round((testedScripts / totalScripts) * 100 * 100) / 100
      : 100;
    
    console.log(`📈 Test Coverage: ${this.testCoverage.testCoveragePercentage}% (${testedScripts}/${totalScripts} scripts tested)`);
  }

  // GitHub Issue Management Methods
  async enableIssueTracking() {
    this.issueTracking.enabled = true;
    await this.loadExistingIssues();
  }

  async loadExistingIssues() {
    try {
      // Load existing issues from GitHub with broken-reference label
      const result = execSync('gh issue list --label "broken-reference" --state all --json number,title,state,body --limit 100', 
        { encoding: 'utf8', cwd: this.rootPath });
      
      const issues = JSON.parse(result);
      
      for (const issue of issues) {
        // Extract reference path from issue title or body
        const referenceMatch = issue.title.match(/Fix broken reference: (.+)/) || 
                             issue.body.match(/Reference: `([^`]+)`/);
        
        if (referenceMatch) {
          const reference = referenceMatch[1];
          this.issueTracking.existingIssues.set(reference, {
            number: issue.number,
            title: issue.title,
            state: issue.state,
            reference: reference
          });
        }
      }
      
      console.log(`📋 Loaded ${this.issueTracking.existingIssues.size} existing broken reference issues`);
    } catch (error) {
      console.warn(`⚠️ Could not load existing issues: ${error.message}`);
    }
  }

  generateIssueTitle(brokenRef) {
    const reference = brokenRef.original;
    const file = brokenRef.relativeTo;
    
    // Truncate long references for readable titles
    const shortRef = reference.length > 50 ? reference.substring(0, 47) + '...' : reference;
    return `Fix broken reference: ${shortRef} in ${file}`;
  }

  generateIssueBody(brokenRefs, groupedByFile = false) {
    if (groupedByFile && brokenRefs.length > 1) {
      // Multiple broken references in same file
      const file = brokenRefs[0].relativeTo;
      const references = brokenRefs.map(ref => ref.original);
      
      return `# Broken File References in ${file}

**File**: \`${file}\`
**Found**: ${brokenRefs.length} broken references

## Broken References

${brokenRefs.map(ref => `
### ❌ \`${ref.original}\`
- **Line**: ${ref.line}
- **Type**: ${ref.type}
- **Resolved Path**: \`${path.relative(this.rootPath, ref.resolved)}\`
`).join('\n')}

## Resolution Options

For each broken reference, choose one of the following actions:

- [ ] **Fix Path**: Update the reference to point to the correct file location
- [ ] **Create Missing File**: Create the referenced file if it should exist
- [ ] **Remove Reference**: Remove the reference if it's no longer needed
- [ ] **Update Documentation**: Replace with correct reference or alternative

## Verification

After fixing the references:
1. Run \`npm run validate-references\` locally to verify fixes
2. Commit changes and push to trigger validation workflow
3. This issue will be automatically updated when references are fixed

---
*Auto-generated by File Reference Scanner*  
*Run ID: ${process.env.GITHUB_RUN_ID || 'local'}*`;
    } else {
      // Single broken reference
      const ref = brokenRefs[0];
      
      return `# Broken File Reference

**File**: \`${ref.relativeTo}\`  
**Line**: ${ref.line}  
**Reference**: \`${ref.original}\`  
**Type**: ${ref.type}  
**Resolved Path**: \`${path.relative(this.rootPath, ref.resolved)}\`

## Problem

The file reference \`${ref.original}\` on line ${ref.line} of \`${ref.relativeTo}\` points to a file that does not exist.

## Resolution Options

Choose one of the following actions:

- [ ] **Fix Path**: Update the reference to point to the correct file location
- [ ] **Create Missing File**: Create the file \`${path.relative(this.rootPath, ref.resolved)}\` if it should exist
- [ ] **Remove Reference**: Remove the reference if it's no longer needed
- [ ] **Update Documentation**: Replace with correct reference or alternative

## Context

\`\`\`
File: ${ref.relativeTo}
Line: ${ref.line}
Reference: ${ref.original}
Type: ${ref.type}
\`\`\`

## Verification

After fixing the reference:
1. Run \`npm run validate-references\` locally to verify the fix
2. Commit changes and push to trigger validation workflow
3. This issue will be automatically closed when the reference is fixed

---
*Auto-generated by File Reference Scanner*  
*Run ID: ${process.env.GITHUB_RUN_ID || 'local'}*`;
    }
  }

  async createIssue(brokenRefs, groupedByFile = false) {
    if (!this.issueTracking.enabled) return null;

    try {
      const title = groupedByFile ? 
        `Fix ${brokenRefs.length} broken references in ${brokenRefs[0].relativeTo}` :
        this.generateIssueTitle(brokenRefs[0]);
      
      const body = this.generateIssueBody(brokenRefs, groupedByFile);
      
      // Create issue using GitHub CLI with proper escaping
      const escapedTitle = title.replace(/"/g, '\\"').replace(/`/g, '\\`').replace(/\$/g, '\\$');
      const escapedBody = body.replace(/"/g, '\\"').replace(/`/g, '\\`').replace(/\$/g, '\\$');
      
      // Use file-based approach for complex content
      const tempBodyFile = path.join(this.rootPath, '.temp-issue-body.txt');
      fs.writeFileSync(tempBodyFile, body);
      
      const command = `gh issue create --title "${escapedTitle}" --body-file "${tempBodyFile}" --label "broken-reference,documentation,automated"`;
      
      const result = execSync(command, { encoding: 'utf8', cwd: this.rootPath });
      
      // Clean up temp file
      try {
        fs.unlinkSync(tempBodyFile);
      } catch (error) {
        console.warn(`Warning: Could not remove temp file: ${error.message}`);
      }
      
      const issueUrl = result.trim();
      const issueNumber = issueUrl.split('/').pop();
      
      console.log(`🔧 Created issue #${issueNumber}: ${title}`);
      
      this.issueTracking.createdIssues.push({
        number: issueNumber,
        title: title,
        url: issueUrl,
        references: brokenRefs.map(ref => ref.original)
      });
      
      return issueNumber;
    } catch (error) {
      console.error(`❌ Failed to create issue: ${error.message}`);
      return null;
    }
  }

  async updateIssue(issueNumber, brokenRefs) {
    if (!this.issueTracking.enabled) return false;

    try {
      const comment = `## Updated Broken References

**Scan Date**: ${new Date().toISOString()}  
**Run ID**: ${process.env.GITHUB_RUN_ID || 'local'}

Still finding ${brokenRefs.length} broken reference${brokenRefs.length > 1 ? 's' : ''} in this file:

${brokenRefs.map(ref => `- ❌ \`${ref.original}\` (line ${ref.line})`).join('\n')}

Please fix the remaining broken references listed above.`;

      // Use file-based approach for complex content
      const tempCommentFile = path.join(this.rootPath, '.temp-comment-body.txt');
      fs.writeFileSync(tempCommentFile, comment);
      
      const command = `gh issue comment ${issueNumber} --body-file "${tempCommentFile}"`;
      execSync(command, { encoding: 'utf8', cwd: this.rootPath });
      
      // Clean up temp file
      try {
        fs.unlinkSync(tempCommentFile);
      } catch (error) {
        console.warn(`Warning: Could not remove temp file: ${error.message}`);
      }
      
      console.log(`📝 Updated issue #${issueNumber} with current broken references`);
      
      this.issueTracking.updatedIssues.push(issueNumber);
      return true;
    } catch (error) {
      console.error(`❌ Failed to update issue #${issueNumber}: ${error.message}`);
      return false;
    }
  }

  async closeFixedIssues(fixedReferences) {
    if (!this.issueTracking.enabled || fixedReferences.length === 0) return;

    for (const [reference, issueInfo] of this.issueTracking.existingIssues.entries()) {
      if (fixedReferences.includes(reference) && issueInfo.state === 'open') {
        try {
          const comment = `## ✅ Reference Fixed

The broken reference \`${reference}\` has been fixed and is now valid.

**Verification**: File reference scanner confirms this reference is working correctly.

Automatically closing this issue.`;

          // Use file-based approach for complex content
          const tempCloseFile = path.join(this.rootPath, '.temp-close-comment.txt');
          fs.writeFileSync(tempCloseFile, comment);
          
          const closeCommand = `gh issue close ${issueInfo.number} --comment-file "${tempCloseFile}"`;
          execSync(closeCommand, { encoding: 'utf8', cwd: this.rootPath });
          
          // Clean up temp file
          try {
            fs.unlinkSync(tempCloseFile);
          } catch (error) {
            console.warn(`Warning: Could not remove temp file: ${error.message}`);
          }
          
          console.log(`✅ Closed issue #${issueInfo.number} - reference fixed: ${reference}`);
          
          this.issueTracking.closedIssues.push(issueInfo.number);
        } catch (error) {
          console.error(`❌ Failed to close issue #${issueInfo.number}: ${error.message}`);
        }
      }
    }
  }

  async processIssueCreation() {
    if (!this.issueTracking.enabled || this.results.brokenReferences.length === 0) {
      return;
    }

    console.log('🔧 Processing automatic issue creation for broken references...');

    // Group broken references by file for batch processing
    const brokenByFile = new Map();
    
    for (const brokenRef of this.results.brokenReferences) {
      const file = brokenRef.relativeTo;
      if (!brokenByFile.has(file)) {
        brokenByFile.set(file, []);
      }
      brokenByFile.get(file).push(brokenRef);
    }

    // Process each file's broken references
    for (const [file, refs] of brokenByFile.entries()) {
      // Check if we already have an issue for this file
      const existingIssue = Array.from(this.issueTracking.existingIssues.entries())
        .find(([ref, issue]) => issue.title.includes(file) && issue.state === 'open');

      if (existingIssue) {
        // Update existing issue
        await this.updateIssue(existingIssue[1].number, refs);
      } else {
        // Create new issue (grouped if multiple references in same file)
        const groupedIssue = refs.length > 1;
        await this.createIssue(refs, groupedIssue);
      }
    }

    console.log(`🎯 Issue processing complete: ${this.issueTracking.createdIssues.length} created, ${this.issueTracking.updatedIssues.length} updated`);
  }

  async scan(includeTestCoverage = false) {
    console.log('🔍 Starting file reference scan...');
    
    const files = this.getAllFiles();
    console.log(`📁 Found ${files.length} files to scan`);
    
    let scannedCount = 0;
    for (const file of files) {
      this.scanFile(file);
      scannedCount++;
      
      if (scannedCount % 50 === 0) {
        console.log(`📊 Progress: ${scannedCount}/${files.length} files scanned`);
      }
    }
    
    // Calculate coverage percentage
    this.results.statistics.coveragePercentage = this.results.totalReferences > 0 
      ? Math.round((this.results.validReferences / this.results.totalReferences) * 100 * 100) / 100
      : 100;
    
    console.log(`✅ Scan complete: ${this.results.totalReferences} references found`);
    console.log(`📈 Coverage: ${this.results.statistics.coveragePercentage}%`);
    
    // Run test coverage scan if requested
    if (includeTestCoverage) {
      this.scanTestCoverage();
    }

    // Process automatic issue creation if enabled
    if (this.issueTracking.enabled) {
      await this.processIssueCreation();
    }
    
    return this.results;
  }

  saveResults(outputPath = '.file-reference-coverage.json') {
    const baseline = this.generateCoverageBaseline();
    fs.writeFileSync(outputPath, JSON.stringify(baseline, null, 2));
    console.log(`💾 Results saved to ${outputPath}`);
    return baseline;
  }

  generateReport() {
    const report = {
      summary: {
        totalFiles: Object.keys(this.results.files).length,
        totalReferences: this.results.totalReferences,
        validReferences: this.results.validReferences,
        invalidReferences: this.results.invalidReferences,
        coveragePercentage: this.results.statistics.coveragePercentage
      },
      brokenReferences: this.results.brokenReferences.map(ref => ({
        file: ref.relativeTo,
        line: ref.line,
        reference: ref.original,
        resolved: path.relative(this.rootPath, ref.resolved),
        type: ref.type
      })),
      statistics: this.results.statistics,
      testCoverage: this.testCoverage
    };
    
    return report;
  }

  printReport() {
    const report = this.generateReport();
    
    console.log('\n📊 FILE REFERENCE SCAN REPORT');
    console.log('═══════════════════════════════');
    console.log(`📁 Files scanned: ${report.summary.totalFiles}`);
    console.log(`🔗 Total references: ${report.summary.totalReferences}`);
    console.log(`✅ Valid references: ${report.summary.validReferences}`);
    console.log(`❌ Invalid references: ${report.summary.invalidReferences}`);
    console.log(`📈 Coverage: ${report.summary.coveragePercentage}%`);
    
    if (report.brokenReferences.length > 0) {
      console.log('\n🚨 BROKEN REFERENCES:');
      console.log('─────────────────────');
      report.brokenReferences.forEach(ref => {
        console.log(`❌ ${ref.file}:${ref.line} -> ${ref.reference} (${ref.type})`);
      });
    }
    
    // Test coverage reporting
    if (report.testCoverage.scriptsRequiringTests.length > 0) {
      console.log('\n🧪 TEST COVERAGE REPORT');
      console.log('═══════════════════════');
      console.log(`📝 Scripts requiring tests: ${report.testCoverage.scriptsRequiringTests.length}`);
      console.log(`✅ Scripts with tests: ${report.testCoverage.scriptsWithTests.length}`);
      console.log(`❌ Untested scripts: ${report.testCoverage.untestedScripts.length}`);
      console.log(`📈 Test coverage: ${report.testCoverage.testCoveragePercentage}%`);
      
      if (report.testCoverage.untestedScripts.length > 0) {
        console.log('\n🚨 UNTESTED SCRIPTS:');
        console.log('────────────────────');
        report.testCoverage.untestedScripts.forEach(script => {
          console.log(`❌ ${script.script}`);
          console.log(`   Expected test files: ${script.expectedTestPaths.slice(0, 2).join(', ')}`);
        });
      }
      
      if (report.testCoverage.scriptsWithTests.length > 0) {
        console.log('\n✅ TESTED SCRIPTS:');
        console.log('──────────────────');
        report.testCoverage.scriptsWithTests.forEach(script => {
          console.log(`✅ ${script.script} → ${script.testFile}`);
        });
      }
    }
    
    console.log('\n📊 STATISTICS:');
    console.log('─────────────');
    console.log('By file type:');
    Object.entries(report.statistics.byFileType).forEach(([ext, count]) => {
      console.log(`  ${ext}: ${count}`);
    });
    
    console.log('By reference type:');
    Object.entries(report.statistics.byReferenceType).forEach(([type, count]) => {
      console.log(`  ${type}: ${count}`);
    });
  }
}

// CLI interface
if (import.meta.url === `file://${process.argv[1]}`) {
  const args = process.argv.slice(2);
  const isVerbose = args.includes('--verbose');
  const includeTestCoverage = args.includes('--test-coverage') || args.includes('--tests');
  const testCoverageOnly = args.includes('--test-coverage-only');
  const createIssues = args.includes('--create-issues');
  const outputPath = args.find(arg => arg.startsWith('--output='))?.split('=')[1] || '.file-reference-coverage.json';
  
  async function main() {
    try {
      const scanner = new FileReferenceScanner();
      
      // Enable issue tracking if requested
      if (createIssues) {
        await scanner.enableIssueTracking();
      }
      
      if (testCoverageOnly) {
        // Run only test coverage scan
        scanner.scanTestCoverage();
        const report = scanner.generateReport();
        
        console.log('\n🧪 TEST COVERAGE ONLY SCAN');
        console.log('═══════════════════════════');
        console.log(`📝 Scripts requiring tests: ${report.testCoverage.scriptsRequiringTests.length}`);
        console.log(`✅ Scripts with tests: ${report.testCoverage.scriptsWithTests.length}`);
        console.log(`❌ Untested scripts: ${report.testCoverage.untestedScripts.length}`);
        console.log(`📈 Test coverage: ${report.testCoverage.testCoveragePercentage}%`);
        
        // Exit with error if untested scripts found
        if (report.testCoverage.untestedScripts.length > 0) {
          console.log(`\n❌ Found ${report.testCoverage.untestedScripts.length} untested scripts`);
          if (isVerbose) {
            report.testCoverage.untestedScripts.forEach(script => {
              console.log(`❌ ${script.script}`);
            });
          }
          process.exit(1);
        } else {
          console.log(`\n✅ All ${report.testCoverage.scriptsRequiringTests.length} scripts have tests`);
          process.exit(0);
        }
      } else {
        // Run file reference scan (with optional test coverage)
        const results = await scanner.scan(includeTestCoverage);
        
        if (isVerbose) {
          scanner.printReport();
        }
        
        // Show issue tracking results if enabled
        if (createIssues && (scanner.issueTracking.createdIssues.length > 0 || scanner.issueTracking.updatedIssues.length > 0)) {
          console.log('\n🔧 ISSUE TRACKING RESULTS');
          console.log('═════════════════════════');
          
          if (scanner.issueTracking.createdIssues.length > 0) {
            console.log(`✅ Created ${scanner.issueTracking.createdIssues.length} new issues:`);
            scanner.issueTracking.createdIssues.forEach(issue => {
              console.log(`   🔧 Issue #${issue.number}: ${issue.title}`);
            });
          }
          
          if (scanner.issueTracking.updatedIssues.length > 0) {
            console.log(`📝 Updated ${scanner.issueTracking.updatedIssues.length} existing issues`);
          }
          
          if (scanner.issueTracking.closedIssues.length > 0) {
            console.log(`✅ Closed ${scanner.issueTracking.closedIssues.length} fixed issues`);
          }
        }
        
        const baseline = scanner.saveResults(outputPath);
        
        // Check for failures
        let hasFailures = false;
        let failureMessage = '';
        
        if (results.invalidReferences > 0) {
          hasFailures = true;
          failureMessage += `${results.invalidReferences} broken references`;
        }
        
        if (includeTestCoverage && scanner.testCoverage.untestedScripts.length > 0) {
          hasFailures = true;
          if (failureMessage) failureMessage += ' and ';
          failureMessage += `${scanner.testCoverage.untestedScripts.length} untested scripts`;
        }
        
        if (hasFailures) {
          console.log(`\n❌ Found ${failureMessage}`);
          if (createIssues) {
            console.log(`🔧 Issues created/updated to track these problems`);
          }
          process.exit(1);
        } else {
          console.log(`\n✅ All ${results.totalReferences} references are valid`);
          if (includeTestCoverage) {
            console.log(`✅ All ${scanner.testCoverage.scriptsRequiringTests.length} scripts have tests`);
          }
          process.exit(0);
        }
      }
      
    } catch (error) {
      console.error('❌ Scanner failed:', error.message);
      process.exit(1);
    }
  }
  
  main();
}

export default FileReferenceScanner;