#!/usr/bin/env node

/**
 * Test script for Gemini Integration Workflow
 * 
 * Tests all components of the Gemini feedback processing system
 * including categorization, prioritization, and agent assignment.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Test data for different scenarios
const TEST_SCENARIOS = {
  security_critical: {
    repository: "tuvens/test-repo",
    branch: "feature/security-fix",
    title: "SQL Injection Vulnerability in Auth Controller",
    description: "The login endpoint is vulnerable to SQL injection attacks. User input is directly concatenated into SQL queries without proper sanitization or parameterized queries.",
    file_path: "src/controllers/AuthController.php",
    line_numbers: "45-52",
    suggestions: [
      "Use parameterized queries",
      "Implement input sanitization", 
      "Add rate limiting to prevent brute force attacks"
    ]
  },
  performance_high: {
    repository: "tuvens/test-repo",
    branch: "feature/performance-optimization",
    title: "Memory Leak in React Component",
    description: "The UserProfile component has a memory leak due to missing cleanup in useEffect. This causes performance degradation over time.",
    file_path: "src/components/UserProfile.tsx",
    line_numbers: "23-45",
    suggestions: [
      "Add cleanup function to useEffect",
      "Implement component unmounting logic",
      "Use React.memo for optimization"
    ]
  },
  architecture_high: {
    repository: "tuvens/test-repo",
    branch: "feature/architecture-review",
    title: "Tight Coupling Between Services",
    description: "The UserService and PaymentService are tightly coupled, making the code difficult to test and maintain. Consider implementing dependency injection.",
    file_path: "src/services/UserService.js",
    line_numbers: "78-120",
    suggestions: [
      "Implement dependency injection pattern",
      "Create service interfaces",
      "Add unit tests for isolated testing"
    ]
  },
  code_quality_medium: {
    repository: "tuvens/test-repo", 
    branch: "feature/code-quality",
    title: "Code Duplication in Validation Logic",
    description: "The same validation logic is repeated across multiple controllers. This should be extracted into a reusable utility function.",
    file_path: "src/controllers/UserController.php",
    line_numbers: "15-30",
    suggestions: [
      "Extract validation logic to utility class",
      "Create reusable validation middleware",
      "Add validation tests"
    ]
  },
  documentation_low: {
    repository: "tuvens/test-repo",
    branch: "feature/documentation-update",
    title: "Missing API Documentation",
    description: "The /api/users endpoint lacks proper documentation. API endpoints should include parameter descriptions and example responses.",
    file_path: "docs/api/users.md",
    line_numbers: null,
    suggestions: [
      "Add parameter documentation",
      "Include example requests and responses",
      "Update OpenAPI specification"
    ]
  }
};

class GeminiIntegrationTester {
  constructor() {
    this.scriptsDir = path.join(__dirname, 'agentic-development', 'scripts');
    this.trackingDir = path.join(__dirname, 'agentic-development', 'branch-tracking');
    this.testResults = [];
  }

  log(message, level = 'INFO') {
    const timestamp = new Date().toISOString();
    const logMessage = `[${timestamp}] ${level}: ${message}`;
    console.log(logMessage);
    
    // Also log to file for persistent testing records
    const logFile = path.join(__dirname, 'gemini-integration-test.log');
    fs.appendFileSync(logFile, logMessage + '\n');
  }

  async runTest(testName, payload, expectedCategory, expectedPriority) {
    this.log(`\n🧪 Running test: ${testName}`);
    
    try {
      // Test feedback processing
      const processScript = path.join(this.scriptsDir, 'process-gemini-feedback.js');
      const payloadJson = JSON.stringify(payload);
      
      this.log(`Processing payload: ${payloadJson.substring(0, 100)}...`);
      
      // Run the processing script
      const result = execSync(
        `node "${processScript}" --payload='${payloadJson}'`,
        { encoding: 'utf8', cwd: __dirname }
      );
      
      this.log(`Processing result: ${result}`);
      
      // Verify the feedback was logged
      const feedbackLogFile = path.join(this.trackingDir, 'gemini-feedback.json');
      if (fs.existsSync(feedbackLogFile)) {
        const feedbackLog = JSON.parse(fs.readFileSync(feedbackLogFile, 'utf8'));
        const latestFeedback = feedbackLog.feedback_history?.[0];
        
        if (latestFeedback) {
          this.log(`✅ Feedback logged with ID: ${latestFeedback.feedback_id}`);
          this.log(`   Category: ${latestFeedback.category} (expected: ${expectedCategory})`);
          this.log(`   Priority: ${latestFeedback.priority} (expected: ${expectedPriority})`);
          this.log(`   Agent: ${latestFeedback.suggested_agent}`);
          
          // Validate expectations
          const categoryMatch = latestFeedback.category === expectedCategory;
          const priorityMatch = latestFeedback.priority === expectedPriority;
          
          if (categoryMatch && priorityMatch) {
            this.log(`✅ Test ${testName} PASSED`);
            this.testResults.push({ test: testName, status: 'PASSED', feedback_id: latestFeedback.feedback_id });
          } else {
            this.log(`❌ Test ${testName} FAILED - Category/Priority mismatch`);
            this.testResults.push({ test: testName, status: 'FAILED', reason: 'Category/Priority mismatch' });
          }
        } else {
          this.log(`❌ Test ${testName} FAILED - No feedback found in log`);
          this.testResults.push({ test: testName, status: 'FAILED', reason: 'No feedback logged' });
        }
      } else {
        this.log(`❌ Test ${testName} FAILED - Feedback log file not created`);
        this.testResults.push({ test: testName, status: 'FAILED', reason: 'Log file not created' });
      }
      
    } catch (error) {
      this.log(`❌ Test ${testName} FAILED - Error: ${error.message}`);
      this.testResults.push({ test: testName, status: 'FAILED', reason: error.message });
    }
  }

  async testAgentSessionTrigger(feedbackId) {
    this.log(`\n🤖 Testing agent session trigger for feedback: ${feedbackId}`);
    
    try {
      const triggerScript = path.join(this.scriptsDir, 'trigger-agent-session.js');
      
      const result = execSync(
        `node "${triggerScript}" --repository="tuvens/test-repo" --branch="feature/test" --agent="vibe-coder" --issue="123" --feedback-id="${feedbackId}" --priority="critical"`,
        { encoding: 'utf8', cwd: __dirname }
      );
      
      this.log(`Agent trigger result: ${result}`);
      
      // Verify session was logged
      const sessionsLogFile = path.join(this.trackingDir, 'agent-sessions.json');
      if (fs.existsSync(sessionsLogFile)) {
        const sessionsLog = JSON.parse(fs.readFileSync(sessionsLogFile, 'utf8'));
        const latestSession = sessionsLog.active_sessions?.[sessionsLog.active_sessions.length - 1];
        
        if (latestSession && latestSession.feedback_id === feedbackId) {
          this.log(`✅ Agent session created: ${latestSession.session_id}`);
          this.testResults.push({ test: 'agent_session_trigger', status: 'PASSED', session_id: latestSession.session_id });
        } else {
          this.log(`❌ Agent session not found or mismatch`);
          this.testResults.push({ test: 'agent_session_trigger', status: 'FAILED', reason: 'Session not found' });
        }
      } else {
        this.log(`❌ Agent sessions log file not created`);
        this.testResults.push({ test: 'agent_session_trigger', status: 'FAILED', reason: 'Sessions log not created' });
      }
      
    } catch (error) {
      this.log(`❌ Agent session trigger FAILED - Error: ${error.message}`);
      this.testResults.push({ test: 'agent_session_trigger', status: 'FAILED', reason: error.message });
    }
  }

  async testBranchTracking(payload) {
    this.log(`\n📊 Testing branch tracking integration`);
    
    try {
      const updateScript = path.join(this.scriptsDir, 'update-branch-tracking.js');
      const trackingPayload = {
        repository: payload.repository.split('/')[1],
        branch: payload.branch,
        feedback_id: 'test-feedback-123',
        category: 'security-vulnerability',
        priority: 'critical',
        agent: 'vibe-coder'
      };
      
      const result = execSync(
        `node "${updateScript}" --event-type="gemini-feedback" --payload='${JSON.stringify(trackingPayload)}'`,
        { encoding: 'utf8', cwd: __dirname }
      );
      
      this.log(`Branch tracking result: ${result}`);
      
      // Verify branch was updated
      const activeBranchesFile = path.join(this.trackingDir, 'active-branches.json');
      if (fs.existsSync(activeBranchesFile)) {
        const activeBranches = JSON.parse(fs.readFileSync(activeBranchesFile, 'utf8'));
        const repoName = payload.repository.split('/')[1];
        const branch = activeBranches.branches?.[repoName]?.find(b => b.name === payload.branch);
        
        if (branch && branch.gemini_feedback_history) {
          this.log(`✅ Branch tracking updated for ${payload.branch}`);
          this.log(`   Status: ${branch.status}`);
          this.log(`   Feedback history entries: ${branch.gemini_feedback_history.length}`);
          this.testResults.push({ test: 'branch_tracking', status: 'PASSED', branch: payload.branch });
        } else {
          this.log(`❌ Branch not found or feedback history missing`);
          this.testResults.push({ test: 'branch_tracking', status: 'FAILED', reason: 'Branch not updated' });
        }
      } else {
        this.log(`❌ Active branches file not found`);
        this.testResults.push({ test: 'branch_tracking', status: 'FAILED', reason: 'Active branches file not found' });
      }
      
    } catch (error) {
      this.log(`❌ Branch tracking test FAILED - Error: ${error.message}`);
      this.testResults.push({ test: 'branch_tracking', status: 'FAILED', reason: error.message });
    }
  }

  ensureDirectoriesExist() {
    const dirs = [
      this.trackingDir,
      this.scriptsDir
    ];
    
    dirs.forEach(dir => {
      if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
        this.log(`Created directory: ${dir}`);
      }
    });
  }

  async runAllTests() {
    this.log('🚀 Starting Gemini Integration Workflow Tests');
    this.ensureDirectoriesExist();
    
    // Run categorization and prioritization tests
    await this.runTest('security_critical', TEST_SCENARIOS.security_critical, 'security-vulnerability', 'critical');
    await this.runTest('performance_high', TEST_SCENARIOS.performance_high, 'performance-critical', 'high');
    await this.runTest('architecture_high', TEST_SCENARIOS.architecture_high, 'architecture-concern', 'high');
    await this.runTest('code_quality_medium', TEST_SCENARIOS.code_quality_medium, 'code-quality', 'medium');
    await this.runTest('documentation_low', TEST_SCENARIOS.documentation_low, 'documentation', 'low');
    
    // Test agent session triggering (use first successful test)
    const firstSuccess = this.testResults.find(r => r.status === 'PASSED' && r.feedback_id);
    if (firstSuccess) {
      await this.testAgentSessionTrigger(firstSuccess.feedback_id);
    }
    
    // Test branch tracking
    await this.testBranchTracking(TEST_SCENARIOS.security_critical);
    
    this.printSummary();
  }

  printSummary() {
    this.log(`\n📋 TEST SUMMARY`);
    this.log(`================`);
    
    const passed = this.testResults.filter(r => r.status === 'PASSED').length;
    const failed = this.testResults.filter(r => r.status === 'FAILED').length;
    
    this.log(`Total Tests: ${this.testResults.length}`);
    this.log(`Passed: ${passed}`);
    this.log(`Failed: ${failed}`);
    
    if (failed > 0) {
      this.log(`\nFailed Tests:`);
      this.testResults.filter(r => r.status === 'FAILED').forEach(test => {
        this.log(`❌ ${test.test}: ${test.reason}`);
      });
    }
    
    if (passed === this.testResults.length) {
      this.log(`\n🎉 All tests PASSED! Gemini Integration Workflow is working correctly.`);
    } else {
      this.log(`\n⚠️ Some tests FAILED. Please review the issues above.`);
    }
    
    this.log(`\nTest log saved to: gemini-integration-test.log`);
  }
}

// Run tests if script is called directly
if (require.main === module) {
  const tester = new GeminiIntegrationTester();
  tester.runAllTests().catch(error => {
    console.error('Test execution failed:', error);
    process.exit(1);
  });
}

module.exports = GeminiIntegrationTester;