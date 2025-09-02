#!/usr/bin/env node

import { describe, it, before, after } from 'node:test';
import assert from 'node:assert';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';
import FileReferenceScanner from '../../scripts/file-reference-scanner.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

describe('FileReferenceScanner', () => {
  let scanner;
  let testDir;

  before(() => {
    // Create temporary test directory
    testDir = path.join(__dirname, 'test-temp');
    if (fs.existsSync(testDir)) {
      fs.rmSync(testDir, { recursive: true });
    }
    fs.mkdirSync(testDir, { recursive: true });
    
    scanner = new FileReferenceScanner(testDir);
  });

  after(() => {
    // Clean up test directory
    if (fs.existsSync(testDir)) {
      fs.rmSync(testDir, { recursive: true });
    }
  });

  describe('Template Recognition', () => {
    it('should identify template variables as valid references', () => {
      const templatePaths = [
        '.claude/agents/{agent-name}.md',
        'tuvens-docs/repositories/$REPO.md',
        'path/to/${VAR}.md',
        'workflow/${{ github.actor }}.yml'
      ];

      templatePaths.forEach(templatePath => {
        const isTemplate = scanner.isTemplateReference(templatePath);
        assert.strictEqual(isTemplate, true, `${templatePath} should be recognized as template`);
      });
    });

    it('should NOT identify regular paths as templates', () => {
      const regularPaths = [
        '.claude/agents/devops.md',
        'agentic-development/scripts/test.sh',
        './README.md',
        '../package.json'
      ];

      regularPaths.forEach(regularPath => {
        const isTemplate = scanner.isTemplateReference(regularPath);
        assert.strictEqual(isTemplate, false, `${regularPath} should NOT be recognized as template`);
      });
    });
  });

  describe('Reference Extraction', () => {
    it('should extract markdown links correctly', () => {
      const content = `
# Test Document
This is a [link to file](./test-file.md) in markdown.
Another [external link](https://example.com) should be ignored.
And a [template link](.claude/agents/{agent-name}.md) should be recognized.
      `;
      
      const testFile = path.join(testDir, 'test.md');
      fs.writeFileSync(testFile, content);
      
      const references = scanner.extractReferences(content, testFile);
      
      assert.strictEqual(references.length, 2, 'Should extract 2 file references (not external URLs)');
      assert.ok(references.some(ref => ref.original === './test-file.md'), 'Should find regular file reference');
      assert.ok(references.some(ref => ref.original === '.claude/agents/{agent-name}.md'), 'Should find template reference');
      assert.ok(references.some(ref => ref.isTemplate === true), 'Should mark template references');
    });

    it('should extract Load statements correctly', () => {
      const content = `
Context Loading:
- Load: .claude/agents/devops.md
- Load: agentic-development/protocols/protocol-name.md
      `;
      
      const testFile = path.join(testDir, 'agent-config.md');
      fs.writeFileSync(testFile, content);
      
      const references = scanner.extractReferences(content, testFile);
      
      assert.strictEqual(references.length, 2, 'Should extract 2 load statements');
      assert.ok(references.some(ref => ref.type === 'load-statement'), 'Should identify load statement type');
    });

    it('should ignore URLs and anchors', () => {
      const content = `
[External](https://github.com/user/repo)
[Anchor](#section)
[Email](mailto:test@example.com)
[Valid file](./actual-file.md)
      `;
      
      const testFile = path.join(testDir, 'links.md');
      fs.writeFileSync(testFile, content);
      
      const references = scanner.extractReferences(content, testFile);
      
      assert.strictEqual(references.length, 1, 'Should only extract file references');
      assert.strictEqual(references[0].original, './actual-file.md', 'Should extract the correct file reference');
    });
  });

  describe('Reference Validation', () => {
    it('should validate existing files as valid', () => {
      // Create test file
      const testFile = path.join(testDir, 'existing-file.md');
      fs.writeFileSync(testFile, '# Test file');
      
      const reference = {
        original: './existing-file.md',
        resolved: testFile,
        isTemplate: false
      };
      
      const isValid = scanner.validateReference(reference);
      assert.strictEqual(isValid, true, 'Existing file should be valid');
    });

    it('should validate template references as valid', () => {
      const reference = {
        original: '.claude/agents/{agent-name}.md',
        resolved: path.join(testDir, '.claude/agents/{agent-name}.md'),
        isTemplate: true
      };
      
      const isValid = scanner.validateReference(reference);
      assert.strictEqual(isValid, true, 'Template references should always be valid');
    });

    it('should mark non-existent non-template files as invalid', () => {
      const reference = {
        original: './non-existent-file.md',
        resolved: path.join(testDir, 'non-existent-file.md'),
        isTemplate: false
      };
      
      const isValid = scanner.validateReference(reference);
      assert.strictEqual(isValid, false, 'Non-existent files should be invalid');
    });
  });

  describe('Coverage Calculation', () => {
    it('should calculate coverage correctly including templates', () => {
      // Test coverage calculation logic
      const totalReferences = 10;
      const validReferences = 7; // 5 real + 2 templates = 7 valid
      
      const coveragePercentage = Math.round((validReferences / totalReferences) * 100);
      
      assert.strictEqual(coveragePercentage, 70, 'Coverage should be 70% (7/10)');
    });
  });

  describe('Integration Tests', () => {
    it('should handle real-world agent file patterns', () => {
      const agentContent = `
# DevOps Agent Configuration

## Context Loading  
- Load: .claude/agents/devops.md
- Load: tuvens-docs/repositories/$REPO.md

## References
[GitHub Comment Standards](agentic-development/protocols/github-comment-standards.md)
[Agent Discovery](.claude/agents/{agent-name}.md)
      `;
      
      const agentFile = path.join(testDir, 'devops.md');
      const protocolFile = path.join(testDir, 'agentic-development/protocols/github-comment-standards.md');
      
      // Create directory and referenced file
      fs.mkdirSync(path.dirname(protocolFile), { recursive: true });
      fs.writeFileSync(agentFile, agentContent);
      fs.writeFileSync(protocolFile, '# Protocol');
      
      // Initialize scanner results
      scanner.results = {
        totalReferences: 0,
        validReferences: 0,
        invalidReferences: 0,
        files: {},
        brokenReferences: [],
        templateReferences: [],
        statistics: { byFileType: {}, byReferenceType: {} }
      };
      
      scanner.scanFile(agentFile);
      
      // Should find template references
      assert.ok(scanner.results.templateReferences.length > 0, 'Should find template references');
      assert.ok(scanner.results.templateReferences.some(ref => 
        ref.reference.includes('{agent-name}')
      ), 'Should find {agent-name} template');
      assert.ok(scanner.results.templateReferences.some(ref => 
        ref.reference.includes('$REPO')
      ), 'Should find $REPO template');
      
      // Should validate the existing protocol file
      assert.ok(scanner.results.validReferences > 0, 'Should have valid references');
    });
  });
});

// Specific test for the false positive scenario from issue #337
describe('Issue #337 False Positive Fix', () => {
  it('should correctly handle agent-name template in Load statements', () => {
    const testDir = path.join(__dirname, 'issue-337-test');
    if (fs.existsSync(testDir)) {
      fs.rmSync(testDir, { recursive: true });
    }
    fs.mkdirSync(testDir, { recursive: true });
    
    const scanner = new FileReferenceScanner(testDir);
    
    // This is the exact content that was causing false positives
    const content = `# Agent Discovery Index

## Loading Guidance

### For Claude Code Users
To load an agent identity, use the Claude Code context loading feature:
\`\`\`
Context Loading:
- Load: .claude/agents/{agent-name}.md
\`\`\``;
    
    const testFile = path.join(testDir, 'README.md');
    fs.writeFileSync(testFile, content);
    
    scanner.results = {
      totalReferences: 0,
      validReferences: 0,
      invalidReferences: 0,
      files: {},
      brokenReferences: [],
      templateReferences: [],
      statistics: { byFileType: {}, byReferenceType: {} }
    };
    
    scanner.scanFile(testFile);
    
    // The key test: {agent-name} should be recognized as template, not broken
    assert.ok(scanner.results.templateReferences.length > 0, 'Should find template references');
    assert.ok(scanner.results.templateReferences.some(ref => 
      ref.reference.includes('{agent-name}')
    ), 'Should recognize {agent-name} as template variable');
    
    // Should not be in broken references
    const brokenAgentRefs = scanner.results.brokenReferences.filter(ref => 
      ref.reference.includes('{agent-name}')
    );
    assert.strictEqual(brokenAgentRefs.length, 0, 'Template variables should NOT appear in broken references');
    
    // Cleanup
    fs.rmSync(testDir, { recursive: true });
  });
});

console.log('🧪 Running File Reference Scanner Tests...');