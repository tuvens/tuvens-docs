#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Parse command line arguments
const args = process.argv.slice(2);
const eventType = args.find(arg => arg.startsWith('--event-type='))?.split('=')[1];
const payloadArg = args.find(arg => arg.startsWith('--payload='))?.split('=')[1];

if (!eventType || !payloadArg) {
    console.error('Usage: node update-branch-tracking.js --event-type=<type> --payload=<json>');
    process.exit(1);
}

let payload;
try {
    payload = JSON.parse(payloadArg);
} catch (error) {
    console.error('Error parsing payload JSON:', error.message);
    process.exit(1);
}

const TRACKING_DIR = path.join(__dirname, '../branch-tracking');
const ACTIVE_BRANCHES_FILE = path.join(TRACKING_DIR, 'active-branches.json');
const TASK_GROUPS_FILE = path.join(TRACKING_DIR, 'task-groups.json');
const MERGE_LOG_FILE = path.join(TRACKING_DIR, 'merge-log.json');
const CLEANUP_QUEUE_FILE = path.join(TRACKING_DIR, 'cleanup-queue.json');

// Load JSON file with error handling
function loadJson(filePath, defaultValue = {}) {
    try {
        if (fs.existsSync(filePath)) {
            return JSON.parse(fs.readFileSync(filePath, 'utf8'));
        }
        return defaultValue;
    } catch (error) {
        console.warn(`Error loading ${filePath}:`, error.message);
        return defaultValue;
    }
}

// Save JSON file with error handling
function saveJson(filePath, data) {
    try {
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2) + '\n');
        console.log(`Updated: ${path.basename(filePath)}`);
    } catch (error) {
        console.error(`Error saving ${filePath}:`, error.message);
    }
}

// Extract agent from branch name
function extractAgent(branchName) {
    const parts = branchName.split('/');
    if (parts.length >= 2) {
        const possibleAgent = parts[0];
        // Check if it matches known agent pattern
        const knownAgents = ['vibe-coder', 'devops', 'mobile-dev', 'node-dev', 'react-dev', 'svelte-dev', 'laravel-dev', 'codehooks-dev'];
        if (knownAgents.includes(possibleAgent)) {
            return possibleAgent;
        }
    }
    return 'unknown';
}

// Generate task group ID from branch name
function generateTaskGroup(branchName) {
    return branchName.replace(/[^a-zA-Z0-9-]/g, '-').toLowerCase();
}

// Main processing function
function processEvent(eventType, payload) {
    console.log(`Processing event: ${eventType}`);
    console.log('Payload:', JSON.stringify(payload, null, 2));

    const activeBranches = loadJson(ACTIVE_BRANCHES_FILE, { 
        lastUpdated: new Date().toISOString(),
        generatedBy: "GitHub Actions",
        tuvensStrategy: "develop->staging->main with change-type prefixes",
        branches: {} 
    });
    
    const taskGroups = loadJson(TASK_GROUPS_FILE, {});
    const mergeLog = loadJson(MERGE_LOG_FILE, { recentMerges: [] });
    const cleanupQueue = loadJson(CLEANUP_QUEUE_FILE, []);

    switch (eventType) {
        case 'branch-created':
            handleBranchCreated(payload, activeBranches, taskGroups);
            break;
        case 'branch-merged':
            handleBranchMerged(payload, activeBranches, taskGroups, mergeLog, cleanupQueue);
            break;
        case 'branch-deleted':
            handleBranchDeleted(payload, activeBranches, taskGroups);
            break;
        default:
            console.warn(`Unknown event type: ${eventType}`);
            return;
    }

    // Update timestamps
    activeBranches.lastUpdated = new Date().toISOString();

    // Save all files
    saveJson(ACTIVE_BRANCHES_FILE, activeBranches);
    saveJson(TASK_GROUPS_FILE, taskGroups);
    saveJson(MERGE_LOG_FILE, mergeLog);
    saveJson(CLEANUP_QUEUE_FILE, cleanupQueue);
}

function handleBranchCreated(payload, activeBranches, taskGroups) {
    const { repository, branch, author, created, githubUrl } = payload;
    
    if (!activeBranches.branches[repository]) {
        activeBranches.branches[repository] = [];
    }

    const agent = extractAgent(branch);
    const taskGroup = generateTaskGroup(branch);
    
    const branchInfo = {
        name: branch,
        author: author,
        created: created || new Date().toISOString(),
        lastActivity: new Date().toISOString(),
        taskGroup: taskGroup,
        status: 'active',
        worktree: `~/Code/Tuvens/${repository}/${agent}/${branch.replace(/[^a-zA-Z0-9-]/g, '-')}`,
        agent: agent,
        relatedBranches: [],
        githubUrl: githubUrl || `https://github.com/tuvens/${repository}/tree/${branch}`,
        issues: []
    };

    activeBranches.branches[repository].push(branchInfo);

    // Create or update task group
    if (!taskGroups[taskGroup]) {
        taskGroups[taskGroup] = {
            title: branch.replace(/[_-]/g, ' ').replace(/\b\w/g, l => l.toUpperCase()),
            description: `Automated task group for ${branch}`,
            coordinator: author,
            created: created || new Date().toISOString(),
            status: 'in-progress',
            branches: {},
            agents: {},
            dependencies: [],
            issues: [],
            documentation: []
        };
    }

    taskGroups[taskGroup].branches[repository] = branch;
    taskGroups[taskGroup].agents[agent] = `Working on ${repository}`;

    console.log(`✅ Added branch: ${repository}/${branch} (${agent})`);
}

function handleBranchMerged(payload, activeBranches, taskGroups, mergeLog, cleanupQueue) {
    const { repository, branch, targetBranch, mergedBy, mergedAt, pullRequestUrl } = payload;
    
    if (!activeBranches.branches[repository]) {
        return;
    }

    // Find and remove the branch from active branches
    const branchIndex = activeBranches.branches[repository].findIndex(b => b.name === branch);
    if (branchIndex === -1) {
        console.warn(`Branch not found in active branches: ${repository}/${branch}`);
        return;
    }

    const branchInfo = activeBranches.branches[repository][branchIndex];
    activeBranches.branches[repository].splice(branchIndex, 1);

    // Add to merge log
    const mergeEntry = {
        repository: repository,
        branch: branch,
        mergedAt: mergedAt || new Date().toISOString(),
        mergedBy: mergedBy,
        targetBranch: targetBranch,
        taskGroup: branchInfo.taskGroup,
        cleanupEligible: true,
        worktreePath: branchInfo.worktree,
        pullRequestUrl: pullRequestUrl
    };

    mergeLog.recentMerges.unshift(mergeEntry);
    
    // Keep only last 50 merges
    if (mergeLog.recentMerges.length > 50) {
        mergeLog.recentMerges = mergeLog.recentMerges.slice(0, 50);
    }

    // Add to cleanup queue
    cleanupQueue.push(mergeEntry);

    // Update task group status if all branches are merged
    const taskGroup = taskGroups[branchInfo.taskGroup];
    if (taskGroup) {
        delete taskGroup.branches[repository];
        delete taskGroup.agents[branchInfo.agent];
        
        if (Object.keys(taskGroup.branches).length === 0) {
            taskGroup.status = 'completed';
        }
    }

    console.log(`✅ Merged branch: ${repository}/${branch} → ${targetBranch}`);
}

function handleBranchDeleted(payload, activeBranches, taskGroups) {
    const { repository, branch } = payload;
    
    if (!activeBranches.branches[repository]) {
        return;
    }

    // Remove from active branches
    const branchIndex = activeBranches.branches[repository].findIndex(b => b.name === branch);
    if (branchIndex !== -1) {
        const branchInfo = activeBranches.branches[repository][branchIndex];
        activeBranches.branches[repository].splice(branchIndex, 1);

        // Update task group
        const taskGroup = taskGroups[branchInfo.taskGroup];
        if (taskGroup) {
            delete taskGroup.branches[repository];
            delete taskGroup.agents[branchInfo.agent];
        }

        console.log(`✅ Deleted branch: ${repository}/${branch}`);
    }
}

// Run the script
processEvent(eventType, payload);