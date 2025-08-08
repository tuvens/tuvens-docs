#!/usr/bin/env node

/**
 * Central Branch Tracking Update Script
 * 
 * Updates the central branch tracking system based on GitHub webhooks
 * and local branch operations.
 */

const fs = require('fs');
const path = require('path');

// Configuration
const TRACKING_DIR = path.join(__dirname, '..', 'branch-tracking');
const ACTIVE_BRANCHES_FILE = path.join(TRACKING_DIR, 'active-branches.json');
const TASK_GROUPS_FILE = path.join(TRACKING_DIR, 'task-groups.json');
const MERGE_LOG_FILE = path.join(TRACKING_DIR, 'merge-log.json');
const CLEANUP_QUEUE_FILE = path.join(TRACKING_DIR, 'cleanup-queue.json');

// Utility functions
function loadJSON(filePath) {
    try {
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (error) {
        console.error(`Error loading ${filePath}:`, error.message);
        return {};
    }
}

function saveJSON(filePath, data) {
    try {
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
        console.log(`✅ Updated: ${path.basename(filePath)}`);
    } catch (error) {
        console.error(`Error saving ${filePath}:`, error.message);
    }
}

function generateBranchId(repository, branchName) {
    return `${repository}:${branchName}`;
}

// Main handlers
function handleBranchCreated(payload) {
    console.log(`📝 Handling branch creation: ${payload.repository}/${payload.branch}`);
    
    const activeBranches = loadJSON(ACTIVE_BRANCHES_FILE);
    const taskGroups = loadJSON(TASK_GROUPS_FILE);
    
    // Ensure repository exists in active branches
    if (!activeBranches.branches) {
        activeBranches.branches = {};
    }
    if (!activeBranches.branches[payload.repository]) {
        activeBranches.branches[payload.repository] = [];
    }
    
    // Extract agent from branch name
    const agentMatch = payload.branch.match(/^([^/]+)\//);
    const agent = agentMatch ? agentMatch[1] : 'unknown';
    
    // Create new branch entry
    const newBranch = {
        name: payload.branch,
        author: payload.author,
        created: payload.created || new Date().toISOString(),
        lastActivity: new Date().toISOString(),
        taskGroup: null, // Will be set if part of a task group
        status: 'active',
        worktree: payload.worktree || null,
        agent: agent,
        relatedBranches: [],
        githubUrl: payload.githubUrl || `https://github.com/tuvens/${payload.repository}/tree/${payload.branch}`,
        issues: payload.issues || []
    };
    
    // Check if this branch should be part of an existing task group
    const branchTitle = payload.branch.replace(/^[^/]+\//, '').replace(/-/g, ' ');
    for (const [groupId, group] of Object.entries(taskGroups)) {
        if (group.title.toLowerCase().includes(branchTitle.toLowerCase()) || 
            branchTitle.toLowerCase().includes(group.title.toLowerCase())) {
            newBranch.taskGroup = groupId;
            // Update task group with new branch
            if (!group.branches[payload.repository]) {
                group.branches[payload.repository] = payload.branch;
            }
            break;
        }
    }
    
    // Add to active branches
    activeBranches.branches[payload.repository].push(newBranch);
    activeBranches.lastUpdated = new Date().toISOString();
    activeBranches.generatedBy = 'GitHub Actions';
    
    // Save updates
    saveJSON(ACTIVE_BRANCHES_FILE, activeBranches);
    if (newBranch.taskGroup) {
        saveJSON(TASK_GROUPS_FILE, taskGroups);
    }
}

function handleBranchMerged(payload) {
    console.log(`🔀 Handling branch merge: ${payload.repository}/${payload.branch}`);
    
    const activeBranches = loadJSON(ACTIVE_BRANCHES_FILE);
    const mergeLog = loadJSON(MERGE_LOG_FILE);
    const cleanupQueue = loadJSON(CLEANUP_QUEUE_FILE);
    
    if (!activeBranches.branches || !activeBranches.branches[payload.repository]) {
        console.log(`No active branches found for ${payload.repository}`);
        return;
    }
    
    // Find and remove the merged branch
    const branches = activeBranches.branches[payload.repository];
    const branchIndex = branches.findIndex(b => b.name === payload.branch);
    
    if (branchIndex === -1) {
        console.log(`Branch ${payload.branch} not found in active branches`);
        return;
    }
    
    const mergedBranch = branches.splice(branchIndex, 1)[0];
    
    // Add to merge log
    if (!mergeLog.recentMerges) {
        mergeLog.recentMerges = [];
    }
    
    const mergeEntry = {
        repository: payload.repository,
        branch: payload.branch,
        mergedAt: payload.mergedAt || new Date().toISOString(),
        mergedBy: payload.mergedBy,
        targetBranch: payload.targetBranch,
        taskGroup: mergedBranch.taskGroup,
        cleanupEligible: true,
        worktreePath: mergedBranch.worktree
    };
    
    mergeLog.recentMerges.unshift(mergeEntry);
    
    // Keep only last 50 merges
    if (mergeLog.recentMerges.length > 50) {
        mergeLog.recentMerges = mergeLog.recentMerges.slice(0, 50);
    }
    
    // Add to cleanup queue if worktree exists
    if (mergedBranch.worktree) {
        if (!cleanupQueue.eligibleForCleanup) {
            cleanupQueue.eligibleForCleanup = [];
        }
        cleanupQueue.eligibleForCleanup.push(mergeEntry);
    }
    
    // Update timestamps
    activeBranches.lastUpdated = new Date().toISOString();
    
    // Save updates
    saveJSON(ACTIVE_BRANCHES_FILE, activeBranches);
    saveJSON(MERGE_LOG_FILE, mergeLog);
    saveJSON(CLEANUP_QUEUE_FILE, cleanupQueue);
}

function handleBranchDeleted(payload) {
    console.log(`🗑️ Handling branch deletion: ${payload.repository}/${payload.branch}`);
    
    const activeBranches = loadJSON(ACTIVE_BRANCHES_FILE);
    
    if (!activeBranches.branches || !activeBranches.branches[payload.repository]) {
        return;
    }
    
    // Remove from active branches if still there
    const branches = activeBranches.branches[payload.repository];
    const branchIndex = branches.findIndex(b => b.name === payload.branch);
    
    if (branchIndex !== -1) {
        branches.splice(branchIndex, 1);
        activeBranches.lastUpdated = new Date().toISOString();
        saveJSON(ACTIVE_BRANCHES_FILE, activeBranches);
    }
}

function handleLocalUpdate(payload) {
    console.log(`🏠 Handling local update: ${payload.action} for ${payload.repository}/${payload.branch}`);
    
    switch (payload.action) {
        case 'create':
            handleBranchCreated({
                repository: payload.repository,
                branch: payload.branch,
                author: payload.author || 'local-user',
                created: new Date().toISOString(),
                worktree: payload.worktree,
                agent: payload.agent,
                taskGroup: payload.taskGroup,
                issues: payload.issues || []
            });
            break;
        case 'merge':
            handleBranchMerged(payload);
            break;
        case 'delete':
            handleBranchDeleted(payload);
            break;
        default:
            console.log(`Unknown action: ${payload.action}`);
    }
}

// Main execution
function main() {
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
        console.log('Usage: node update-branch-tracking.js --event-type=<type> --payload=<json>');
        console.log('   or: node update-branch-tracking.js --action=<action> --repo=<repo> --branch=<branch> [other options]');
        process.exit(1);
    }
    
    let eventType, payload;
    
    // Parse arguments
    const options = {};
    args.forEach(arg => {
        const [key, value] = arg.split('=');
        const cleanKey = key.replace('--', '');
        options[cleanKey] = value;
    });
    
    if (options['event-type'] && options['payload']) {
        // GitHub webhook format
        eventType = options['event-type'];
        try {
            payload = JSON.parse(options['payload']);
        } catch (error) {
            console.error('Error parsing payload JSON:', error.message);
            process.exit(1);
        }
    } else if (options['action']) {
        // Local command format
        eventType = 'local-update';
        payload = options;
    } else {
        console.error('Missing required arguments');
        process.exit(1);
    }
    
    console.log(`🔄 Processing ${eventType}...`);
    
    // Route to appropriate handler
    switch (eventType) {
        case 'branch-created':
            handleBranchCreated(payload);
            break;
        case 'branch-merged':
            handleBranchMerged(payload);
            break;
        case 'branch-deleted':
            handleBranchDeleted(payload);
            break;
        case 'local-update':
            handleLocalUpdate(payload);
            break;
        default:
            console.error(`Unknown event type: ${eventType}`);
            process.exit(1);
    }
    
    console.log('✅ Branch tracking update complete');
}

// Run if called directly
if (require.main === module) {
    main();
}

module.exports = {
    handleBranchCreated,
    handleBranchMerged,
    handleBranchDeleted,
    handleLocalUpdate
};