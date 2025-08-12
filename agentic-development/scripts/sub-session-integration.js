#!/usr/bin/env node

/**
 * Sub-Session Integration
 * 
 * Central integration point for the sub-session file access control system.
 * Provides a unified interface for all sub-session operations and coordinates
 * with the existing branch tracking and agent management systems.
 */

import fs from 'fs';
import path from 'path';
import { execSync } from 'child_process';
import { fileURLToPath } from 'url';

// ES modules don't have __dirname, so we need to create it
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Import all our sub-session modules
import { 
    createSubSession, 
    endSubSession, 
    getSystemStatus as getSubSessionStatus,
    ACCESS_MODES 
} from './sub-session-manager.js';

import { 
    detectSubSession, 
    createClaudeValidationWrapper,
    generateClaudePromptAdditions 
} from './claude-access-validator.js';

import { 
    generateCoordinationReport,
    detectConflicts,
    getCoordinationStatus 
} from './coordination-manager.js';

// Configuration
const TRACKING_DIR = path.join(__dirname, '..', 'branch-tracking');
const SCRIPTS_DIR = __dirname;

/**
 * Initialize the sub-session system
 */
function initializeSubSessionSystem() {
    console.log('🔧 Initializing Sub-Session File Access Control System...');
    
    // Ensure tracking directory exists
    if (!fs.existsSync(TRACKING_DIR)) {
        fs.mkdirSync(TRACKING_DIR, { recursive: true });
    }

    // Initialize locks file if it doesn't exist
    const locksFile = path.join(TRACKING_DIR, '.sub-session-locks.json');
    if (!fs.existsSync(locksFile)) {
        const defaultStructure = {
            version: '1.0.0',
            lastUpdated: new Date().toISOString(),
            activeSessions: {},
            fileLocks: {},
            permissionRegistry: {},
            lockHistory: []
        };
        fs.writeFileSync(locksFile, JSON.stringify(defaultStructure, null, 2));
        console.log('✅ Created .sub-session-locks.json registry');
    }

    // Initialize coordination log
    const coordinationLog = path.join(TRACKING_DIR, 'coordination-log.json');
    if (!fs.existsSync(coordinationLog)) {
        fs.writeFileSync(coordinationLog, JSON.stringify({ entries: [] }, null, 2));
        console.log('✅ Created coordination-log.json');
    }

    console.log('✅ Sub-session system initialized');
    return { success: true };
}

/**
 * Start a new sub-session with full integration
 */
function startIntegratedSubSession(options) {
    const {
        mainAgent,
        subAgent,
        taskTitle,
        accessMode = ACCESS_MODES.RESTRICTED,
        allowedPaths = [],
        deniedPaths = [],
        autoSetupWorkspace = true
    } = options;

    console.log(`🚀 Starting integrated sub-session...`);
    console.log(`   Main Agent: ${mainAgent}`);
    console.log(`   Sub Agent: ${subAgent}`);
    console.log(`   Task: ${taskTitle}`);

    // Create the sub-session
    const sessionResult = createSubSession({
        mainAgent,
        subAgent,
        taskScope: taskTitle,
        accessMode,
        allowedPaths,
        deniedPaths
    });

    if (!sessionResult.success) {
        return { success: false, error: 'Failed to create sub-session' };
    }

    const sessionId = sessionResult.sessionId;

    // Setup workspace if requested
    if (autoSetupWorkspace) {
        const workspaceResult = setupSubSessionWorkspace(sessionId, taskTitle);
        if (!workspaceResult.success) {
            console.warn('⚠️ Workspace setup failed, but session created successfully');
        }
    }

    // Update branch tracking integration
    updateBranchTrackingForSubSession(sessionId, mainAgent, subAgent, taskTitle);

    // Generate coordination report
    const report = generateCoordinationReport();
    
    return {
        success: true,
        sessionId,
        workspace: autoSetupWorkspace ? path.join(process.cwd(), 'sub-sessions', sessionId) : null,
        coordinationReport: report,
        nextSteps: [
            `cd sub-sessions/${sessionId}`,
            'source .env-sub-session',
            'claude',
            'Load prompt from claude-prompt.txt'
        ]
    };
}

/**
 * Setup workspace for sub-session
 */
function setupSubSessionWorkspace(sessionId, taskTitle) {
    try {
        const repoRoot = execSync('git rev-parse --show-toplevel', { encoding: 'utf8' }).trim();
        const workspaceDir = path.join(repoRoot, 'sub-sessions', sessionId);
        
        // Create workspace directory
        fs.mkdirSync(workspaceDir, { recursive: true });

        // Create session environment
        const envContent = `
# Sub-Session Environment
SUB_SESSION_ID=${sessionId}
CLAUDE_SUB_SESSION=true
SUB_AGENT_MODE=true
WORKSPACE_DIR=${workspaceDir}
TASK_TITLE="${taskTitle}"
`;
        fs.writeFileSync(path.join(workspaceDir, '.env-sub-session'), envContent);

        // Create session ID file for detection
        fs.writeFileSync(path.join(workspaceDir, '.sub-session-id'), sessionId);

        // Generate Claude prompt
        const promptContent = generateClaudePromptAdditions(sessionId);
        fs.writeFileSync(path.join(workspaceDir, 'claude-prompt.txt'), promptContent);

        return { success: true, workspaceDir };
    } catch (error) {
        console.error('Error setting up workspace:', error.message);
        return { success: false, error: error.message };
    }
}

/**
 * Update branch tracking with sub-session information
 */
function updateBranchTrackingForSubSession(sessionId, mainAgent, subAgent, taskTitle) {
    try {
        const activeBranchesFile = path.join(TRACKING_DIR, 'active-branches.json');
        
        if (!fs.existsSync(activeBranchesFile)) {
            return false;
        }

        const activeBranches = JSON.parse(fs.readFileSync(activeBranchesFile, 'utf8'));
        const currentBranch = execSync('git symbolic-ref --short HEAD', { encoding: 'utf8' }).trim();
        const currentRepo = path.basename(execSync('git rev-parse --show-toplevel', { encoding: 'utf8' }).trim());

        // Find current branch and add sub-session info
        if (activeBranches.branches && activeBranches.branches[currentRepo]) {
            for (const branch of activeBranches.branches[currentRepo]) {
                if (branch.name === currentBranch) {
                    if (!branch.subSessions) {
                        branch.subSessions = [];
                    }
                    
                    branch.subSessions.push({
                        sessionId,
                        subAgent,
                        taskTitle,
                        startTime: new Date().toISOString(),
                        status: 'active'
                    });
                    
                    branch.lastActivity = new Date().toISOString();
                    break;
                }
            }
        }

        activeBranches.lastUpdated = new Date().toISOString();
        activeBranches.generatedBy = 'Sub-Session Integration';

        fs.writeFileSync(activeBranchesFile, JSON.stringify(activeBranches, null, 2));
        return true;
    } catch (error) {
        console.error('Error updating branch tracking:', error.message);
        return false;
    }
}

/**
 * Get comprehensive system status
 */
function getIntegratedSystemStatus() {
    const subSessionStatus = getSubSessionStatus();
    const coordinationStatus = getCoordinationStatus(true);
    const conflicts = detectConflicts();

    // Load branch tracking for context
    const activeBranchesFile = path.join(TRACKING_DIR, 'active-branches.json');
    let branchContext = {};
    
    if (fs.existsSync(activeBranchesFile)) {
        branchContext = JSON.parse(fs.readFileSync(activeBranchesFile, 'utf8'));
    }

    return {
        timestamp: new Date().toISOString(),
        subSessions: subSessionStatus,
        coordination: coordinationStatus,
        conflicts,
        branchContext: {
            totalActiveBranches: Object.values(branchContext.branches || {}).flat().length,
            branchesWithSubSessions: Object.values(branchContext.branches || {})
                .flat()
                .filter(branch => branch.subSessions && branch.subSessions.length > 0).length
        },
        recommendations: generateSystemRecommendations(subSessionStatus, conflicts)
    };
}

/**
 * Generate system-wide recommendations
 */
function generateSystemRecommendations(subSessionStatus, conflicts) {
    const recommendations = [];

    // Too many active sessions
    if (subSessionStatus.totalActiveSessions > 5) {
        recommendations.push({
            priority: 'medium',
            category: 'performance',
            message: 'High number of active sub-sessions',
            action: 'Consider consolidating or ending inactive sessions'
        });
    }

    // Lock contention
    if (subSessionStatus.totalActiveLocks > 15) {
        recommendations.push({
            priority: 'high',
            category: 'coordination',
            message: 'High file lock contention',
            action: 'Review file access patterns and consider more granular locking'
        });
    }

    // Frequent conflicts
    if (conflicts.length > 3) {
        recommendations.push({
            priority: 'high',
            category: 'conflicts',
            message: 'Multiple coordination conflicts detected',
            action: 'Implement conflict resolution strategies and improve task partitioning'
        });
    }

    // Permission request backlog
    if (subSessionStatus.totalPendingRequests > 8) {
        recommendations.push({
            priority: 'medium',
            category: 'permissions',
            message: 'High number of pending permission requests',
            action: 'Review and approve pending requests, or adjust default access modes'
        });
    }

    return recommendations;
}

/**
 * Run automated maintenance tasks
 */
function runMaintenanceTasks(options = {}) {
    const { dryRun = false, force = false } = options;
    
    console.log('🔧 Running sub-session maintenance tasks...');
    
    const maintenanceResults = {
        timestamp: new Date().toISOString(),
        tasks: [],
        summary: { completed: 0, failed: 0, skipped: 0 }
    };

    // Task 1: Cleanup expired sessions
    try {
        console.log('📋 Task 1: Cleaning up expired sessions...');
        const cleanupArgs = ['--auto'];
        if (dryRun) cleanupArgs.push('--dry-run');
        if (force) cleanupArgs.push('--force');

        const cleanupScript = path.join(SCRIPTS_DIR, 'sub-session-cleanup.sh');
        const cleanupOutput = execSync(`bash "${cleanupScript}" ${cleanupArgs.join(' ')}`, { encoding: 'utf8' });
        
        maintenanceResults.tasks.push({
            name: 'cleanup-expired-sessions',
            status: 'completed',
            output: cleanupOutput.trim()
        });
        maintenanceResults.summary.completed++;
    } catch (error) {
        maintenanceResults.tasks.push({
            name: 'cleanup-expired-sessions',
            status: 'failed',
            error: error.message
        });
        maintenanceResults.summary.failed++;
    }

    // Task 2: Conflict detection and reporting
    try {
        console.log('📋 Task 2: Detecting coordination conflicts...');
        const conflicts = detectConflicts();
        
        maintenanceResults.tasks.push({
            name: 'conflict-detection',
            status: 'completed',
            conflictsDetected: conflicts.length,
            conflicts
        });
        maintenanceResults.summary.completed++;
    } catch (error) {
        maintenanceResults.tasks.push({
            name: 'conflict-detection',
            status: 'failed',
            error: error.message
        });
        maintenanceResults.summary.failed++;
    }

    // Task 3: System health assessment
    try {
        console.log('📋 Task 3: Assessing system health...');
        const status = getIntegratedSystemStatus();
        
        maintenanceResults.tasks.push({
            name: 'system-health-assessment',
            status: 'completed',
            systemHealth: status.coordination.overview.systemHealth,
            recommendations: status.recommendations
        });
        maintenanceResults.summary.completed++;
    } catch (error) {
        maintenanceResults.tasks.push({
            name: 'system-health-assessment',
            status: 'failed',
            error: error.message
        });
        maintenanceResults.summary.failed++;
    }

    console.log(`✅ Maintenance completed: ${maintenanceResults.summary.completed} tasks`);
    if (maintenanceResults.summary.failed > 0) {
        console.log(`❌ Failed tasks: ${maintenanceResults.summary.failed}`);
    }

    return maintenanceResults;
}

/**
 * Create a comprehensive sub-session dashboard
 */
function createDashboard() {
    const status = getIntegratedSystemStatus();
    
    const dashboard = {
        title: 'Sub-Session File Access Control Dashboard',
        timestamp: new Date().toISOString(),
        overview: {
            activeSessions: status.subSessions.totalActiveSessions,
            activeLocks: status.subSessions.totalActiveLocks,
            pendingRequests: status.subSessions.totalPendingRequests,
            systemHealth: status.coordination.overview.systemHealth.level
        },
        sessions: Object.entries(status.subSessions.sessions).map(([id, session]) => ({
            sessionId: id,
            subAgent: session.subAgent,
            mainAgent: session.mainAgent,
            taskScope: session.taskScope,
            accessMode: session.accessMode,
            activeLocksCount: session.activeLocksCount,
            pendingRequestsCount: session.pendingRequestsCount,
            lastActivity: session.lastActivity,
            ageHours: Math.round((new Date() - new Date(session.startTime)) / (1000 * 60 * 60) * 10) / 10
        })),
        conflicts: status.conflicts,
        recommendations: status.recommendations,
        quickActions: generateQuickActions(status)
    };

    return dashboard;
}

/**
 * Generate quick action suggestions
 */
function generateQuickActions(status) {
    const actions = [];

    // Session management actions
    if (status.subSessions.totalActiveSessions > 0) {
        actions.push({
            category: 'session-management',
            action: 'view-session-details',
            command: 'node agentic-development/scripts/sub-session-manager.js status',
            description: 'View detailed session information'
        });
    }

    // Conflict resolution actions
    if (status.conflicts.length > 0) {
        actions.push({
            category: 'conflict-resolution',
            action: 'run-coordination-report',
            command: 'node agentic-development/scripts/coordination-manager.js coordination-report',
            description: 'Generate detailed coordination analysis'
        });
    }

    // Permission management actions
    if (status.subSessions.totalPendingRequests > 0) {
        actions.push({
            category: 'permission-management',
            action: 'review-pending-requests',
            command: 'node agentic-development/scripts/sub-session-manager.js status | jq .permissionRegistry',
            description: 'Review and approve pending permission requests'
        });
    }

    // Maintenance actions
    actions.push({
        category: 'maintenance',
        action: 'run-cleanup',
        command: 'bash agentic-development/scripts/sub-session-cleanup.sh --dry-run',
        description: 'Preview cleanup actions for expired sessions'
    });

    return actions;
}

// Command line interface
function main() {
    const args = process.argv.slice(2);
    const command = args[0];

    try {
        switch (command) {
            case 'init':
                const initResult = initializeSubSessionSystem();
                console.log(JSON.stringify(initResult, null, 2));
                break;

            case 'start':
                const startResult = startIntegratedSubSession({
                    mainAgent: args[1],
                    subAgent: args[2], 
                    taskTitle: args[3],
                    accessMode: args[4] || ACCESS_MODES.RESTRICTED,
                    allowedPaths: args[5] ? args[5].split(',') : [],
                    deniedPaths: args[6] ? args[6].split(',') : []
                });
                console.log(JSON.stringify(startResult, null, 2));
                break;

            case 'dashboard':
                const dashboard = createDashboard();
                console.log(JSON.stringify(dashboard, null, 2));
                break;

            case 'status':
                const integratedStatus = getIntegratedSystemStatus();
                console.log(JSON.stringify(integratedStatus, null, 2));
                break;

            case 'maintenance':
                const dryRun = args.includes('--dry-run');
                const force = args.includes('--force');
                const maintenanceResult = runMaintenanceTasks({ dryRun, force });
                console.log(JSON.stringify(maintenanceResult, null, 2));
                break;

            case 'detect-session':
                const sessionId = detectSubSession();
                const wrapper = createClaudeValidationWrapper();
                console.log(JSON.stringify({
                    detectedSession: sessionId,
                    validationWrapper: wrapper
                }, null, 2));
                break;

            default:
                console.log(`
Sub-Session Integration - Unified Sub-Agent File Access Control

Usage:
  node sub-session-integration.js init
  node sub-session-integration.js start <mainAgent> <subAgent> <taskTitle> [accessMode] [allowedPaths] [deniedPaths]
  node sub-session-integration.js dashboard
  node sub-session-integration.js status
  node sub-session-integration.js maintenance [--dry-run] [--force]
  node sub-session-integration.js detect-session

Commands:
  init                 - Initialize the sub-session system
  start                - Start new integrated sub-session
  dashboard            - Show comprehensive dashboard
  status               - Show detailed system status
  maintenance          - Run automated maintenance tasks
  detect-session       - Detect current session mode and setup validation

Examples:
  # Initialize system
  node sub-session-integration.js init

  # Start a restricted sub-session
  node sub-session-integration.js start vibe-coder test-runner "Run integration tests"

  # Start an expanded sub-session with specific paths
  node sub-session-integration.js start backend-dev validator "API validation" expanded "src/,tests/" ".env,package-lock.json"

  # View system dashboard
  node sub-session-integration.js dashboard

  # Run maintenance (dry run first)
  node sub-session-integration.js maintenance --dry-run
                `);
                break;
        }
    } catch (error) {
        console.error('Error:', error.message);
        process.exit(1);
    }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
    main();
}

export {
    initializeSubSessionSystem,
    startIntegratedSubSession,
    createDashboard,
    getIntegratedSystemStatus,
    runMaintenanceTasks
};