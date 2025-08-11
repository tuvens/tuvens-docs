#!/usr/bin/env node

/**
 * Gemini Feedback Processing Script
 * 
 * Processes Gemini Code Review comments and categorizes them for automatic
 * GitHub issue creation and agent session triggering.
 */

const fs = require('fs');
const path = require('path');
const { 
    loadJSON, 
    saveJSON, 
    generateUniqueId, 
    getCurrentTimestamp,
    parseArguments,
    validateRequiredArguments,
    getTrackingDirectory 
} = require('./utils');

// Configuration - allow override for testing
const TRACKING_DIR = process.env.TRACKING_DIR || getTrackingDirectory();
const GEMINI_FEEDBACK_LOG = path.join(TRACKING_DIR, 'gemini-feedback.json');

/**
 * Feedback categories and their handling rules
 */
const FEEDBACK_CATEGORIES = {
  'security-vulnerability': {
    priority: 'critical',
    auto_create_issue: true,
    auto_trigger_agent: true,
    suggested_agents: ['devops', 'vibe-coder']
  },
  'performance-critical': {
    priority: 'high',
    auto_create_issue: true,
    auto_trigger_agent: true,
    suggested_agents: ['vibe-coder', 'react-dev']
  },
  'architecture-concern': {
    priority: 'high',
    auto_create_issue: true,
    auto_trigger_agent: false,
    suggested_agents: ['vibe-coder', 'devops']
  },
  'code-quality': {
    priority: 'medium',
    auto_create_issue: true,
    auto_trigger_agent: false,
    suggested_agents: ['vibe-coder']
  },
  'documentation': {
    priority: 'low',
    auto_create_issue: true,
    auto_trigger_agent: false,
    suggested_agents: ['docs-orchestrator']
  },
  'testing': {
    priority: 'medium',
    auto_create_issue: true,
    auto_trigger_agent: false,
    suggested_agents: ['vibe-coder']
  },
  'best-practices': {
    priority: 'low',
    auto_create_issue: false,
    auto_trigger_agent: false,
    suggested_agents: ['vibe-coder']
  }
};

/**
 * Priority levels and their thresholds
 */
const PRIORITY_RULES = {
  critical: {
    keywords: ['security', 'vulnerability', 'exploit', 'injection', 'xss', 'csrf'],
    auto_create_issue: true,
    auto_trigger_agent: true,
    escalate_immediately: true
  },
  high: {
    keywords: ['performance', 'memory leak', 'deadlock', 'architecture', 'breaking'],
    auto_create_issue: true,
    auto_trigger_agent: true,
    escalate_immediately: false
  },
  medium: {
    keywords: ['refactor', 'improve', 'optimize', 'test', 'coverage'],
    auto_create_issue: true,
    auto_trigger_agent: false,
    escalate_immediately: false
  },
  low: {
    keywords: ['style', 'format', 'comment', 'documentation', 'typo'],
    auto_create_issue: false,
    auto_trigger_agent: false,
    escalate_immediately: false
  }
};

/**
 * Agent assignment based on file patterns and feedback context
 */
const AGENT_ASSIGNMENT_RULES = {
  'frontend': {
    patterns: [/\.tsx?$/, /\.jsx?$/, /\.vue$/, /\.svelte$/, /components\//, /pages\//, /views\//],
    agents: ['react-dev', 'svelte-dev', 'node-dev']
  },
  'backend': {
    patterns: [/\.php$/, /controllers\//, /models\//, /services\//, /api\//],
    agents: ['laravel-dev', 'node-dev']
  },
  'infrastructure': {
    patterns: [/docker/i, /\.yml$/, /\.yaml$/, /terraform/, /kubernetes/, /deployment/],
    agents: ['devops']
  },
  'documentation': {
    patterns: [/\.md$/, /readme/i, /docs\//, /documentation\//],
    agents: ['docs-orchestrator', 'vibe-coder']
  },
  'general': {
    patterns: [],
    agents: ['vibe-coder']
  }
};

// Use shared utilities - utility functions moved to utils.js

/**
 * Categorize feedback based on content analysis
 */
function categorizeFeedback(feedback) {
  const content = `${feedback.title || ''} ${feedback.description || ''}`.toLowerCase();
  
  // Check for security vulnerabilities first
  if (PRIORITY_RULES.critical.keywords.some(keyword => content.includes(keyword))) {
    return 'security-vulnerability';
  }
  
  // Check for performance issues
  if (content.includes('performance') || content.includes('slow') || content.includes('memory')) {
    return 'performance-critical';
  }
  
  // Check for architecture concerns
  if (content.includes('architecture') || content.includes('design pattern') || content.includes('coupling')) {
    return 'architecture-concern';
  }
  
  // Check for testing
  if (content.includes('test') || content.includes('coverage') || content.includes('mock')) {
    return 'testing';
  }
  
  // Check for documentation
  if (content.includes('document') || content.includes('comment') || content.includes('readme')) {
    return 'documentation';
  }
  
  // Default to code quality
  return 'code-quality';
}

/**
 * Determine priority based on content and context
 */
function determinePriority(feedback, category) {
  const content = `${feedback.title || ''} ${feedback.description || ''}`.toLowerCase();
  
  // Check critical keywords first
  if (PRIORITY_RULES.critical.keywords.some(keyword => content.includes(keyword))) {
    return 'critical';
  }
  
  // Check high priority keywords
  if (PRIORITY_RULES.high.keywords.some(keyword => content.includes(keyword))) {
    return 'high';
  }
  
  // Use category default or analyze further
  if (FEEDBACK_CATEGORIES[category]) {
    return FEEDBACK_CATEGORIES[category].priority;
  }
  
  return 'medium';
}

/**
 * Suggest appropriate agent based on file patterns and feedback context
 */
function suggestAgent(feedback) {
  const filePath = feedback.file_path || '';
  
  // Check file patterns
  for (const [type, config] of Object.entries(AGENT_ASSIGNMENT_RULES)) {
    if (config.patterns.some(pattern => pattern.test(filePath))) {
      return config.agents[0]; // Return primary agent for the type
    }
  }
  
  // Default to vibe-coder for general tasks
  return 'vibe-coder';
}

/**
 * Extract recommendations from Gemini feedback
 */
function extractRecommendations(feedback) {
  const recommendations = [];
  
  if (feedback.suggestions && Array.isArray(feedback.suggestions)) {
    recommendations.push(...feedback.suggestions);
  }
  
  if (feedback.fix_suggestions) {
    recommendations.push(...feedback.fix_suggestions);
  }
  
  if (feedback.description) {
    // Extract action items from description
    const actionItems = feedback.description.match(/- (.*)/g);
    if (actionItems) {
      recommendations.push(...actionItems.map(item => item.replace(/^- /, '')));
    }
  }
  
  return recommendations.length > 0 ? recommendations : ['Review and address the identified issue'];
}

/**
 * Process raw Gemini feedback into structured format
 */
function processGeminiFeedback(rawPayload) {
  const feedback = typeof rawPayload === 'string' ? JSON.parse(rawPayload) : rawPayload;
  
  // Generate unique ID
  const feedbackId = generateUniqueId();
  const timestamp = getCurrentTimestamp();
  
  // Extract and normalize feedback data
  const processedFeedback = {
    feedback_id: feedbackId,
    timestamp: timestamp,
    
    // Source information
    repository: feedback.repository || 'tuvens/unknown',
    branch: feedback.branch || 'main',
    pull_request: feedback.pull_request || null,
    commit_sha: feedback.commit_sha || null,
    
    // Feedback content
    title: feedback.title || 'Gemini Code Review Feedback',
    summary: feedback.summary || feedback.description?.substring(0, 200) || 'No summary provided',
    details: feedback.description || feedback.details || 'No details provided',
    
    // Location information
    file_path: feedback.file_path || feedback.file || null,
    line_numbers: feedback.line_numbers || feedback.lines || null,
    
    // Processing results
    category: null,
    priority: null,
    suggested_agent: null,
    recommendations: []
  };
  
  // Categorize and prioritize
  processedFeedback.category = categorizeFeedback(processedFeedback);
  processedFeedback.priority = determinePriority(processedFeedback, processedFeedback.category);
  processedFeedback.suggested_agent = suggestAgent(processedFeedback);
  processedFeedback.recommendations = extractRecommendations(feedback);
  
  return processedFeedback;
}

/**
 * Determine actions based on processed feedback
 */
function determineActions(processedFeedback) {
  const category = FEEDBACK_CATEGORIES[processedFeedback.category];
  const priority = PRIORITY_RULES[processedFeedback.priority];
  
  return {
    create_issue: category?.auto_create_issue || priority?.auto_create_issue || false,
    trigger_agent: category?.auto_trigger_agent || priority?.auto_trigger_agent || false,
    escalate_immediately: priority?.escalate_immediately || false
  };
}

/**
 * Log feedback for tracking and analysis
 */
function logFeedback(processedFeedback, actions) {
  const feedbackLog = loadJSON(GEMINI_FEEDBACK_LOG);
  
  if (!feedbackLog.feedback_history) {
    feedbackLog.feedback_history = [];
  }
  
  const logEntry = {
    ...processedFeedback,
    actions_taken: actions,
    logged_at: new Date().toISOString()
  };
  
  feedbackLog.feedback_history.unshift(logEntry);
  
  // Keep only last 100 feedback entries
  if (feedbackLog.feedback_history.length > 100) {
    feedbackLog.feedback_history = feedbackLog.feedback_history.slice(0, 100);
  }
  
  feedbackLog.last_updated = getCurrentTimestamp();
  feedbackLog.total_processed = (feedbackLog.total_processed || 0) + 1;
  
  saveJSON(GEMINI_FEEDBACK_LOG, feedbackLog);
}

/**
 * Main processing function
 */
function main() {
  const args = process.argv.slice(2);
  
  if (args.length === 0) {
    console.log('Usage: node process-gemini-feedback.js --payload=<json>');
    process.exit(1);
  }
  
  // Parse arguments using shared utility
  const options = parseArguments(args);
  
  try {
    validateRequiredArguments(options, ['payload']);
  } catch (error) {
    console.error(error.message);
    process.exit(1);
  }
  
  try {
    // Process the feedback
    const processedFeedback = processGeminiFeedback(options.payload);
    const actions = determineActions(processedFeedback);
    
    // Log the feedback
    logFeedback(processedFeedback, actions);
    
    // Output results for GitHub Actions
    console.log(`Processing Gemini feedback: ${processedFeedback.feedback_id}`);
    console.log(`Category: ${processedFeedback.category}, Priority: ${processedFeedback.priority}`);
    console.log(`Actions: Issue=${actions.create_issue}, Agent=${actions.trigger_agent}`);
    
    // Set GitHub Actions outputs
    if (process.env.GITHUB_OUTPUT) {
      const outputs = [
        `feedback_id=${processedFeedback.feedback_id}`,
        `category=${processedFeedback.category}`,
        `priority=${processedFeedback.priority}`,
        `create_issue=${actions.create_issue}`,
        `trigger_agent=${actions.trigger_agent}`,
        `suggested_agent=${processedFeedback.suggested_agent}`,
        `target_repository=${processedFeedback.repository}`,
        `target_branch=${processedFeedback.branch}`,
        `issue_number=${processedFeedback.pull_request || ''}`,
        `feedback_data=${JSON.stringify(processedFeedback)}`,
        `tracking_payload=${JSON.stringify({
          repository: processedFeedback.repository.split('/')[1],
          branch: processedFeedback.branch,
          feedback_id: processedFeedback.feedback_id,
          category: processedFeedback.category,
          priority: processedFeedback.priority,
          agent: processedFeedback.suggested_agent
        })}`
      ];
      
      fs.appendFileSync(process.env.GITHUB_OUTPUT, outputs.join('\n') + '\n');
    }
    
  } catch (error) {
    console.error('Error processing Gemini feedback:', error.message);
    process.exit(1);
  }
}

// Run if called directly
if (require.main === module) {
  main();
}

module.exports = {
  processGeminiFeedback,
  categorizeFeedback,
  determinePriority,
  suggestAgent,
  determineActions
};