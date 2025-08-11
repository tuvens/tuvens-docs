#!/usr/bin/env node

/**
 * Agent Session Triggering Script
 * 
 * Triggers agent sessions for critical Gemini feedback by integrating with
 * the branch tracking system and agent coordination workflows.
 */

import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';
import { 
    loadJSON, 
    saveJSON, 
    generateUniqueId, 
    getCurrentTimestamp,
    parseArguments,
    validateRequiredArguments,
    getTrackingDirectory,
    ensureDirectoryExists 
} from './utils.js';

// ES modules don't have __dirname, so we need to create it
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration - allow override for testing
const TRACKING_DIR = process.env.TRACKING_DIR || getTrackingDirectory();
const AGENT_SESSIONS_LOG = path.join(TRACKING_DIR, 'agent-sessions.json');
const ACTIVE_BRANCHES_FILE = path.join(TRACKING_DIR, 'active-branches.json');

// Agent configuration mapping
const AGENT_CONFIG = {
  'vibe-coder': {
    description: 'General code improvements and system coordination',
    capabilities: ['code-review', 'refactoring', 'documentation', 'workflow-automation']
  },
  'react-dev': {
    description: 'Frontend React/TypeScript development',
    capabilities: ['react', 'typescript', 'frontend', 'ui-components']
  },
  'svelte-dev': {
    description: 'Frontend Svelte development',
    capabilities: ['svelte', 'frontend', 'ui-components']
  },
  'laravel-dev': {
    description: 'Backend Laravel/PHP development', 
    capabilities: ['laravel', 'php', 'backend', 'api']
  },
  'node-dev': {
    description: 'Node.js development',
    capabilities: ['nodejs', 'javascript', 'backend', 'api']
  },
  'devops': {
    description: 'Infrastructure and deployment automation',
    capabilities: ['docker', 'ci-cd', 'infrastructure', 'security']
  },
  'docs-orchestrator': {
    description: 'Documentation coordination and management',
    capabilities: ['documentation', 'markdown', 'api-docs']
  }
};

// Utility functions moved to utils.js
function generateSessionId() {
  return `gemini-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
}

/**
 * Create agent session context based on Gemini feedback
 */
function createSessionContext(options) {
  const context = {
    session_id: generateSessionId(),
    created_at: getCurrentTimestamp(),
    
    // Source information
    repository: options.repository,
    branch: options.branch,
    issue_number: options.issue,
    feedback_id: options['feedback-id'],
    priority: options.priority,
    
    // Agent assignment
    assigned_agent: options.agent,
    agent_capabilities: AGENT_CONFIG[options.agent]?.capabilities || [],
    
    // Session configuration
    session_type: 'gemini-triggered',
    auto_started: true,
    expected_duration: options.priority === 'critical' ? '2-4 hours' : '1-2 hours',
    
    // Context for agent
    task_description: `Address Gemini Code Review feedback in ${options.repository}/${options.branch}`,
    related_issue: options.issue ? `${options.repository}#${options.issue}` : null,
    feedback_context: {
      feedback_id: options['feedback-id'],
      priority: options.priority,
      source: 'gemini-code-review'
    }
  };
  
  return context;
}

/**
 * Update branch tracking with agent session information
 */
function updateBranchTracking(sessionContext) {
  const activeBranches = loadJSON(ACTIVE_BRANCHES_FILE);
  
  if (!activeBranches.branches) {
    activeBranches.branches = {};
  }
  
  const repoName = sessionContext.repository.split('/')[1];
  
  if (!activeBranches.branches[repoName]) {
    activeBranches.branches[repoName] = [];
  }
  
  // Find the branch or create new entry
  let branch = activeBranches.branches[repoName].find(b => b.name === sessionContext.branch);
  
  if (!branch) {
    // Create new branch entry
    branch = {
      name: sessionContext.branch,
      author: 'gemini-integration',
      created: getCurrentTimestamp(),
      lastActivity: getCurrentTimestamp(),
      taskGroup: null,
      status: 'agent-assigned',
      worktree: null,
      agent: sessionContext.assigned_agent,
      relatedBranches: [],
      githubUrl: `https://github.com/${sessionContext.repository}/tree/${sessionContext.branch}`,
      issues: sessionContext.related_issue ? [sessionContext.related_issue] : []
    };
    activeBranches.branches[repoName].push(branch);
  }
  
  // Update branch with session information
  branch.lastActivity = getCurrentTimestamp();
  branch.agent = sessionContext.assigned_agent;
  branch.status = 'agent-session-active';
  branch.gemini_feedback = {
    feedback_id: sessionContext.feedback_id,
    priority: sessionContext.priority,
    session_id: sessionContext.session_id,
    triggered_at: sessionContext.created_at
  };
  
  if (sessionContext.related_issue && !branch.issues.includes(sessionContext.related_issue)) {
    branch.issues.push(sessionContext.related_issue);
  }
  
  // Update metadata
  activeBranches.lastUpdated = getCurrentTimestamp();
  activeBranches.generatedBy = 'Gemini Integration - Agent Session Trigger';
  
  saveJSON(ACTIVE_BRANCHES_FILE, activeBranches);
}

/**
 * Log agent session for tracking and coordination
 */
function logAgentSession(sessionContext) {
  const sessionsLog = loadJSON(AGENT_SESSIONS_LOG);
  
  if (!sessionsLog.active_sessions) {
    sessionsLog.active_sessions = [];
  }
  
  if (!sessionsLog.session_history) {
    sessionsLog.session_history = [];
  }
  
  // Add to active sessions
  sessionsLog.active_sessions.push(sessionContext);
  
  // Add to history
  sessionsLog.session_history.unshift({
    ...sessionContext,
    status: 'triggered'
  });
  
  // Keep only last 50 sessions in history
  if (sessionsLog.session_history.length > 50) {
    sessionsLog.session_history = sessionsLog.session_history.slice(0, 50);
  }
  
  // Update metadata
  sessionsLog.last_updated = getCurrentTimestamp();
  sessionsLog.total_sessions = (sessionsLog.total_sessions || 0) + 1;
  
  saveJSON(AGENT_SESSIONS_LOG, sessionsLog);
}

/**
 * Generate agent task instructions
 */
function generateAgentInstructions(sessionContext) {
  const instructions = `# 🤖 Gemini Code Review - Agent Task Assignment

## Session Information
- **Session ID**: ${sessionContext.session_id}
- **Priority**: ${sessionContext.priority.toUpperCase()}
- **Repository**: ${sessionContext.repository}
- **Branch**: ${sessionContext.branch}
- **Assigned Agent**: ${sessionContext.assigned_agent}

## Task Context
${sessionContext.task_description}

## Related Resources
${sessionContext.related_issue ? `- **GitHub Issue**: ${sessionContext.related_issue}` : ''}
- **Feedback ID**: ${sessionContext.feedback_id}
- **Priority Level**: ${sessionContext.priority}

## Agent Instructions
1. **Review the GitHub issue** linked to this feedback for detailed context
2. **Examine the branch** for the specific code that triggered the feedback
3. **Address the feedback** according to the priority and category guidelines
4. **Update the GitHub issue** with your progress and findings
5. **Create appropriate tests** if the feedback involves code changes
6. **Update documentation** if architectural or API changes are made

## Success Criteria
- [ ] Gemini feedback has been addressed according to priority guidelines
- [ ] Code changes have been tested and validated
- [ ] GitHub issue has been updated with resolution details
- [ ] Related documentation has been updated (if applicable)
- [ ] Agent session has been marked as complete

## Priority Guidelines
${sessionContext.priority === 'critical' ? `
**🚨 CRITICAL PRIORITY**
- Address immediately
- Security vulnerabilities require immediate patching
- Notify team leads of progress
- Consider hotfix deployment if production is affected
` : sessionContext.priority === 'high' ? `
**⚠️ HIGH PRIORITY** 
- Address within 24 hours
- Performance or architecture issues need careful consideration
- Coordinate with other agents if cross-functional changes are needed
` : `
**📋 STANDARD PRIORITY**
- Address within normal development cycle
- Focus on code quality and maintainability improvements
- Can be batched with other similar improvements
`}

---
*Auto-generated by Gemini Integration System*
*Session created: ${sessionContext.created_at}*`;

  return instructions;
}

/**
 * Create agent-specific task file
 */
function createAgentTaskFile(sessionContext) {
  const agentDir = path.join(__dirname, '..', '..', sessionContext.assigned_agent);
  const taskFile = path.join(agentDir, `gemini-task-${sessionContext.session_id}.md`);
  
  try {
    // Ensure agent directory exists
    ensureDirectoryExists(agentDir);
    
    const instructions = generateAgentInstructions(sessionContext);
    fs.writeFileSync(taskFile, instructions);
    
    console.log(`📄 Created agent task file: ${taskFile}`);
    return taskFile;
  } catch (error) {
    console.error(`Error creating agent task file:`, error.message);
    return null;
  }
}

/**
 * Send notification to agent (if notification system exists)
 */
function notifyAgent(sessionContext) {
  // This would integrate with any existing notification systems
  // For now, just log the notification
  console.log(`📬 Notification sent to ${sessionContext.assigned_agent} agent`);
  console.log(`   Task: ${sessionContext.task_description}`);
  console.log(`   Priority: ${sessionContext.priority}`);
  console.log(`   Repository: ${sessionContext.repository}/${sessionContext.branch}`);
}

/**
 * Main function to trigger agent session
 */
function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log('Usage: node trigger-agent-session.js --repository=<repo> --branch=<branch> --agent=<agent> --issue=<issue> --feedback-id=<id> --priority=<priority>');
    process.exit(1);
  }
  
  // Parse arguments using shared utility
  const options = parseArguments(args);
  
  // Validate required arguments using shared utility
  try {
    validateRequiredArguments(options, ['repository', 'branch', 'agent', 'feedback-id', 'priority']);
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
  
  try {
    // Create session context
    const sessionContext = createSessionContext(options);
    
    // Update branch tracking
    updateBranchTracking(sessionContext);
    
    // Log agent session
    logAgentSession(sessionContext);
    
    // Create agent task file
    const taskFile = createAgentTaskFile(sessionContext);
    
    // Send notification
    notifyAgent(sessionContext);
    
    console.log(`✅ Agent session triggered successfully`);
    console.log(`   Session ID: ${sessionContext.session_id}`);
    console.log(`   Agent: ${sessionContext.assigned_agent}`);
    console.log(`   Priority: ${sessionContext.priority}`);
    console.log(`   Repository: ${sessionContext.repository}/${sessionContext.branch}`);
    
    if (taskFile) {
      console.log(`   Task File: ${taskFile}`);
    }
    
  } catch (error) {
    console.error('Error triggering agent session:', error.message);
    process.exit(1);
  }
}

// Run if called directly (ES modules equivalent)
if (import.meta.url === `file://${process.argv[1]}`) {
  main();
}

export {
  createSessionContext,
  updateBranchTracking,
  logAgentSession,
  generateAgentInstructions
};