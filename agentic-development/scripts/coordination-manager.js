#!/usr/bin/env node

/**
 * Coordination Manager
 * 
 * Manages coordination between main agents and sub-agents, including
 * conflict detection, resolution strategies, and safe parallel work patterns.
 */

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// ES modules don't have __dirname, so we need to create it
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration
const TRACKING_DIR = path.join(__dirname, '..', 'branch-tracking');
const LOCKS_FILE = path.join(TRACKING_DIR, '.sub-session-locks.json');
const ACTIVE_BRANCHES_FILE = path.join(TRACKING_DIR, 'active-branches.json');
const COORDINATION_LOG_FILE = path.join(TRACKING_DIR, 'coordination-log.json');

// Import utilities
import { getSystemStatus } from './sub-session-manager.js';

/**
 * Coordination strategies for different conflict types
 */
const COORDINATION_STRATEGIES = {
    FILE_LOCK_CONFLICT: 'file-lock-conflict',
    BRANCH_CONFLICT: 'branch-conflict',
    RESOURCE_CONTENTION: 'resource-contention',
    PERMISSION_ESCALATION: 'permission-escalation'
};

/**
 * Resolution approaches
 */
const RESOLUTION_APPROACHES = {
    WAIT: 'wait',                    // Wait for resource to become available
    COORDINATE: 'coordinate',        // Active coordination between agents
    ESCALATE: 'escalate',           // Escalate to main agent
    PARTITION: 'partition',         // Divide work to avoid conflicts
    SEQUENTIAL: 'sequential'        // Work sequentially instead of parallel
};

// Utility functions
function loadJSON(filePath) {
    try {
        if (!fs.existsSync(filePath)) {
            return {};
        }
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (error) {
        console.error(`Error loading ${filePath}:`, error.message);
        return {};
    }
}

function saveJSON(filePath, data) {
    try {
        data.lastUpdated = new Date().toISOString();
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
        return true;
    } catch (error) {
        console.error(`Error saving ${filePath}:`, error.message);
        return false;
    }
}

function addCoordinationLog(action, details, sessionIds = [], resolution = null) {
    const log = loadJSON(COORDINATION_LOG_FILE);
    
    if (!log.entries) {
        log.entries = [];
    }

    log.entries.unshift({
        timestamp: new Date().toISOString(),
        action,
        details,
        sessionIds,
        resolution,
        id: generateCoordinationId()
    });

    // Keep only last 200 entries
    if (log.entries.length > 200) {
        log.entries = log.entries.slice(0, 200);
    }

    saveJSON(COORDINATION_LOG_FILE, log);
}

function generateCoordinationId() {
    return `coord-${Date.now()}-${Math.random().toString(36).substr(2, 6)}`;
}

/**
 * Detect conflicts between main agents and sub-agents
 */
function detectConflicts() {
    const locks = loadJSON(LOCKS_FILE);
    const activeBranches = loadJSON(ACTIVE_BRANCHES_FILE);
    const conflicts = [];

    // 1. File lock conflicts
    const lockConflicts = detectFileLockConflicts(locks);
    conflicts.push(...lockConflicts);

    // 2. Branch-level conflicts
    const branchConflicts = detectBranchConflicts(locks, activeBranches);
    conflicts.push(...branchConflicts);

    // 3. Resource contention
    const resourceConflicts = detectResourceContention(locks);
    conflicts.push(...resourceConflicts);

    return conflicts;
}

/**
 * Detect file lock conflicts
 */
function detectFileLockConflicts(locks) {
    const conflicts = [];
    
    // Look for recent lock conflicts in history
    const recentConflicts = locks.lockHistory?.filter(entry => 
        entry.action === 'lock-conflict' && 
        new Date(entry.timestamp) > new Date(Date.now() - 30 * 60 * 1000) // Last 30 minutes
    ) || [];

    // Group conflicts by file path
    const conflictsByFile = {};
    for (const conflict of recentConflicts) {
        if (!conflictsByFile[conflict.filePath]) {
            conflictsByFile[conflict.filePath] = [];
        }
        conflictsByFile[conflict.filePath].push(conflict);
    }

    // Generate conflict reports
    for (const [filePath, fileConflicts] of Object.entries(conflictsByFile)) {
        if (fileConflicts.length > 0) {
            const involvedSessions = [...new Set(fileConflicts.map(c => c.sessionId))];
            const currentLock = locks.fileLocks[filePath];

            conflicts.push({
                type: COORDINATION_STRATEGIES.FILE_LOCK_CONFLICT,
                filePath,
                involvedSessions,
                conflictCount: fileConflicts.length,
                currentLockHolder: currentLock?.lockedBy || null,
                lastConflictTime: fileConflicts[0].timestamp,
                suggestedResolution: suggestFileLockResolution(filePath, involvedSessions, currentLock)
            });
        }
    }

    return conflicts;
}

/**
 * Detect branch-level conflicts
 */
function detectBranchConflicts(locks, activeBranches) {
    const conflicts = [];

    // Check for sub-sessions working on the same files as main agent branches
    for (const [sessionId, session] of Object.entries(locks.activeSessions || {})) {
        const parentBranch = session.coordinationData?.parentBranch;
        
        if (!parentBranch) continue;

        // Find other sessions working on files in the same area
        const overlappingSessions = Object.entries(locks.activeSessions)
            .filter(([otherId, otherSession]) => 
                otherId !== sessionId && 
                otherSession.coordinationData?.parentBranch === parentBranch
            );

        if (overlappingSessions.length > 0) {
            conflicts.push({
                type: COORDINATION_STRATEGIES.BRANCH_CONFLICT,
                parentBranch,
                primarySession: sessionId,
                conflictingSessions: overlappingSessions.map(([id]) => id),
                suggestedResolution: suggestBranchConflictResolution(sessionId, overlappingSessions)
            });
        }
    }

    return conflicts;
}

/**
 * Detect resource contention
 */
function detectResourceContention(locks) {
    const conflicts = [];
    
    // Look for patterns of repeated permission requests
    const permissionStats = {};
    
    for (const [requestId, request] of Object.entries(locks.permissionRegistry || {})) {
        const lockId = `${request.sessionId}:${request.requestedResource}`;
        if (!permissionStats[lockId]) {
            permissionStats[lockId] = { count: 0, requests: [] };
        }
        permissionStats[lockId].count++;
        permissionStats[lockId].requests.push(request);
    }

    // Identify high-contention resources
    for (const [lockId, stats] of Object.entries(permissionStats)) {
        if (stats.count > 3) { // More than 3 requests for same resource
            const [sessionId, resourcePath] = lockId.split(':');
            conflicts.push({
                type: COORDINATION_STRATEGIES.RESOURCE_CONTENTION,
                sessionId,
                resourcePath,
                requestCount: stats.count,
                suggestedResolution: suggestResourceContentionResolution(resourcePath, stats.requests)
            });
        }
    }

    return conflicts;
}

/**
 * Suggest resolution for file lock conflicts
 */
function suggestFileLockResolution(filePath, involvedSessions, currentLock) {
    // If it's a documentation file, suggest coordination
    if (filePath.includes('/docs/') || filePath.endsWith('.md')) {
        return {
            approach: RESOLUTION_APPROACHES.COORDINATE,
            suggestion: 'Coordinate documentation updates - consider splitting into sections',
            actions: [
                'Split file into sections for each agent',
                'Use temporary files and merge later',
                'Work sequentially with clear handoff points'
            ]
        };
    }

    // If it's a source code file, suggest partitioning
    if (filePath.match(/\.(js|ts|jsx|tsx|py|java)$/)) {
        return {
            approach: RESOLUTION_APPROACHES.PARTITION,
            suggestion: 'Partition code changes to avoid conflicts',
            actions: [
                'Divide into separate functions/modules',
                'Work on different files in same feature',
                'Use feature flags for parallel development'
            ]
        };
    }

    // Default to sequential approach
    return {
        approach: RESOLUTION_APPROACHES.SEQUENTIAL,
        suggestion: 'Work sequentially to avoid conflicts',
        actions: [
            'Establish work order between sessions',
            'Use clear handoff protocols',
            'Implement checkpoint coordination'
        ]
    };
}

/**
 * Suggest resolution for branch conflicts
 */
function suggestBranchConflictResolution(primarySession, conflictingSessions) {
    return {
        approach: RESOLUTION_APPROACHES.COORDINATE,
        suggestion: 'Coordinate branch work between sub-sessions',
        actions: [
            'Establish primary and secondary roles',
            'Create communication protocol between sessions',
            'Define clear boundaries for each sub-task',
            'Implement regular sync checkpoints'
        ]
    };
}

/**
 * Suggest resolution for resource contention
 */
function suggestResourceContentionResolution(resourcePath, requests) {
    return {
        approach: RESOLUTION_APPROACHES.ESCALATE,
        suggestion: 'Escalate repeated permission requests to main agent',
        actions: [
            'Review if resource should be in allowed paths',
            'Consider upgrading session access mode',
            'Evaluate if sub-task scope needs adjustment'
        ]
    };
}

/**
 * Automatically resolve conflicts where possible
 */
function autoResolveConflicts(conflicts) {
    const resolutions = [];

    for (const conflict of conflicts) {
        switch (conflict.type) {
            case COORDINATION_STRATEGIES.RESOURCE_CONTENTION:
                // Auto-approve if it's a safe documentation path
                if (conflict.resourcePath.includes('/docs/') || conflict.resourcePath.endsWith('.md')) {
                    const resolution = autoApproveDocumentationAccess(conflict);
                    if (resolution.success) {
                        resolutions.push(resolution);
                    }
                }
                break;

            case COORDINATION_STRATEGIES.FILE_LOCK_CONFLICT:
                // Auto-suggest file splitting for documentation conflicts
                if (conflict.filePath.endsWith('.md')) {
                    const resolution = suggestDocumentationSplit(conflict);
                    resolutions.push(resolution);
                }
                break;

            default:
                // No auto-resolution available
                break;
        }
    }

    return resolutions;
}

/**
 * Auto-approve documentation access
 */
function autoApproveDocumentationAccess(conflict) {
    // Implementation would approve pending permission requests for documentation
    return {
        success: true,
        conflictId: conflict.id,
        action: 'auto-approved-documentation-access',
        details: `Auto-approved access to ${conflict.resourcePath} for documentation work`
    };
}

/**
 * Suggest documentation file splitting
 */
function suggestDocumentationSplit(conflict) {
    return {
        success: true,
        conflictId: conflict.id,
        action: 'documentation-split-suggestion',
        details: `Suggest splitting ${conflict.filePath} into separate sections for parallel work`,
        suggestedSplits: [
            `${conflict.filePath.replace('.md', '-section-1.md')}`,
            `${conflict.filePath.replace('.md', '-section-2.md')}`
        ]
    };
}

/**
 * Generate coordination report
 */
function generateCoordinationReport() {
    const status = getSystemStatus();
    const conflicts = detectConflicts();
    const autoResolutions = autoResolveConflicts(conflicts);

    const report = {
        timestamp: new Date().toISOString(),
        summary: {
            activeSessions: status.totalActiveSessions,
            activeLocks: status.totalActiveLocks,
            pendingRequests: status.totalPendingRequests,
            detectedConflicts: conflicts.length,
            autoResolutions: autoResolutions.length
        },
        conflicts,
        autoResolutions,
        recommendations: generateRecommendations(status, conflicts),
        systemHealth: assessSystemHealth(status, conflicts)
    };

    // Log the coordination check
    addCoordinationLog('coordination-report', 'System-wide coordination analysis', [], autoResolutions);

    return report;
}

/**
 * Generate recommendations based on current state
 */
function generateRecommendations(status, conflicts) {
    const recommendations = [];

    // High lock contention
    if (status.totalActiveLocks > 10) {
        recommendations.push({
            priority: 'medium',
            category: 'performance',
            message: 'High number of active file locks detected',
            action: 'Consider reviewing sub-session scopes to reduce lock contention'
        });
    }

    // Many pending permission requests
    if (status.totalPendingRequests > 5) {
        recommendations.push({
            priority: 'high',
            category: 'access-control',
            message: 'High number of pending permission requests',
            action: 'Review sub-session access modes - consider expanding permissions for common patterns'
        });
    }

    // Conflicts detected
    if (conflicts.length > 0) {
        recommendations.push({
            priority: 'high',
            category: 'conflicts',
            message: `${conflicts.length} coordination conflicts detected`,
            action: 'Review conflict resolution suggestions and implement coordination strategies'
        });
    }

    // Long-running sessions
    const now = new Date();
    for (const [sessionId, sessionInfo] of Object.entries(status.sessions)) {
        const sessionAge = now - new Date(sessionInfo.startTime);
        const hoursAge = sessionAge / (1000 * 60 * 60);
        
        if (hoursAge > 4) { // Sessions older than 4 hours
            recommendations.push({
                priority: 'medium',
                category: 'session-management',
                message: `Long-running sub-session detected: ${sessionId}`,
                action: `Review session ${sessionId} - consider breaking into smaller tasks or ending session`
            });
        }
    }

    return recommendations;
}

/**
 * Assess overall system health
 */
function assessSystemHealth(status, conflicts) {
    let score = 100;
    const issues = [];

    // Deduct points for conflicts
    score -= conflicts.length * 10;
    if (conflicts.length > 0) {
        issues.push(`${conflicts.length} active conflicts`);
    }

    // Deduct points for high resource usage
    if (status.totalActiveLocks > 15) {
        score -= 20;
        issues.push('High file lock usage');
    }

    if (status.totalPendingRequests > 10) {
        score -= 15;
        issues.push('High number of pending permission requests');
    }

    // Deduct points for stale sessions
    const staleSessions = Object.values(status.sessions).filter(session => {
        const age = new Date() - new Date(session.lastActivity);
        return age > (2 * 60 * 60 * 1000); // 2 hours of inactivity
    });

    score -= staleSessions.length * 5;
    if (staleSessions.length > 0) {
        issues.push(`${staleSessions.length} stale sessions`);
    }

    return {
        score: Math.max(0, score),
        level: score > 80 ? 'healthy' : score > 60 ? 'warning' : 'critical',
        issues,
        recommendations: score < 80 ? ['Review and resolve coordination issues'] : []
    };
}

/**
 * Coordinate between specific sessions
 */
function coordinateSessions(sessionIds, coordinationType, context = {}) {
    const locks = loadJSON(LOCKS_FILE);
    const coordinationId = generateCoordinationId();

    // Validate sessions exist
    for (const sessionId of sessionIds) {
        if (!locks.activeSessions[sessionId]) {
            throw new Error(`Session ${sessionId} not found`);
        }
    }

    // Create coordination record
    const coordination = {
        id: coordinationId,
        type: coordinationType,
        sessions: sessionIds,
        startTime: new Date().toISOString(),
        status: 'active',
        context,
        messages: [],
        resolution: null
    };

    // Add coordination to each session
    for (const sessionId of sessionIds) {
        if (!locks.activeSessions[sessionId].coordinations) {
            locks.activeSessions[sessionId].coordinations = [];
        }
        locks.activeSessions[sessionId].coordinations.push(coordinationId);
    }

    // Save coordination info to locks file
    if (!locks.coordinations) {
        locks.coordinations = {};
    }
    locks.coordinations[coordinationId] = coordination;

    addCoordinationLog('coordination-started', `Started ${coordinationType} coordination`, sessionIds, null);

    if (saveJSON(LOCKS_FILE, locks)) {
        console.log(`🤝 Started coordination: ${coordinationId}`);
        console.log(`   Type: ${coordinationType}`);
        console.log(`   Sessions: ${sessionIds.join(', ')}`);
        return { coordinationId, success: true };
    }

    return { coordinationId: null, success: false };
}

/**
 * Send message between coordinating sessions
 */
function sendCoordinationMessage(coordinationId, fromSessionId, message, messageType = 'info') {
    const locks = loadJSON(LOCKS_FILE);

    if (!locks.coordinations || !locks.coordinations[coordinationId]) {
        throw new Error(`Coordination ${coordinationId} not found`);
    }

    const coordination = locks.coordinations[coordinationId];
    
    if (!coordination.sessions.includes(fromSessionId)) {
        throw new Error(`Session ${fromSessionId} not part of coordination ${coordinationId}`);
    }

    const messageEntry = {
        timestamp: new Date().toISOString(),
        fromSession: fromSessionId,
        message,
        type: messageType,
        id: `msg-${Date.now()}-${Math.random().toString(36).substr(2, 4)}`
    };

    coordination.messages.push(messageEntry);

    addCoordinationLog('coordination-message', message, [fromSessionId], null);

    if (saveJSON(LOCKS_FILE, locks)) {
        console.log(`📨 Message sent in coordination ${coordinationId}`);
        return { messageId: messageEntry.id, success: true };
    }

    return { messageId: null, success: false };
}

/**
 * Resolve coordination
 */
function resolveCoordination(coordinationId, resolution, resolvedBy) {
    const locks = loadJSON(LOCKS_FILE);

    if (!locks.coordinations || !locks.coordinations[coordinationId]) {
        throw new Error(`Coordination ${coordinationId} not found`);
    }

    const coordination = locks.coordinations[coordinationId];
    coordination.status = 'resolved';
    coordination.resolution = {
        approach: resolution,
        resolvedBy,
        resolvedAt: new Date().toISOString()
    };

    addCoordinationLog('coordination-resolved', `Resolved via ${resolution}`, coordination.sessions, resolution);

    if (saveJSON(LOCKS_FILE, locks)) {
        console.log(`✅ Resolved coordination: ${coordinationId}`);
        console.log(`   Resolution: ${resolution}`);
        return { success: true };
    }

    return { success: false };
}

/**
 * Get detailed coordination status
 */
function getCoordinationStatus(includeHistory = false) {
    const status = getSystemStatus();
    const conflicts = detectConflicts();
    const autoResolutions = autoResolveConflicts(conflicts);
    const locks = loadJSON(LOCKS_FILE);

    const coordinationStatus = {
        overview: {
            activeSessions: status.totalActiveSessions,
            activeConflicts: conflicts.length,
            activeCoordinations: Object.entries(locks.coordinations || {}).length,
            systemHealth: assessSystemHealth(status, conflicts)
        },
        conflicts,
        autoResolutions,
        activeCoordinations: locks.coordinations || {}
    };

    if (includeHistory) {
        const coordinationLog = loadJSON(COORDINATION_LOG_FILE);
        coordinationStatus.recentActivity = coordinationLog.entries?.slice(0, 20) || [];
    }

    return coordinationStatus;
}

// Command line interface
function main() {
    const args = process.argv.slice(2);
    const command = args[0];

    try {
        switch (command) {
            case 'detect-conflicts':
                const conflicts = detectConflicts();
                console.log(JSON.stringify(conflicts, null, 2));
                break;

            case 'coordination-report':
                const report = generateCoordinationReport();
                console.log(JSON.stringify(report, null, 2));
                break;

            case 'coordinate-sessions':
                const sessionIds = args[1].split(',');
                const coordinationType = args[2] || 'general';
                const result = coordinateSessions(sessionIds, coordinationType);
                console.log(JSON.stringify(result, null, 2));
                break;

            case 'send-message':
                const coordinationId = args[1];
                const fromSessionId = args[2];
                const message = args[3];
                const messageResult = sendCoordinationMessage(coordinationId, fromSessionId, message);
                console.log(JSON.stringify(messageResult, null, 2));
                break;

            case 'resolve-coordination':
                const resolveId = args[1];
                const resolution = args[2];
                const resolvedBy = args[3] || 'system';
                const resolveResult = resolveCoordination(resolveId, resolution, resolvedBy);
                console.log(JSON.stringify(resolveResult, null, 2));
                break;

            case 'status':
                const includeHistory = args[1] === '--include-history';
                const coordinationStatus = getCoordinationStatus(includeHistory);
                console.log(JSON.stringify(coordinationStatus, null, 2));
                break;

            default:
                console.log(`
Coordination Manager - Sub-Agent Coordination and Conflict Resolution

Usage:
  node coordination-manager.js detect-conflicts
  node coordination-manager.js coordination-report
  node coordination-manager.js coordinate-sessions <sessionIds> [coordinationType]
  node coordination-manager.js send-message <coordinationId> <fromSessionId> <message>
  node coordination-manager.js resolve-coordination <coordinationId> <resolution> [resolvedBy]
  node coordination-manager.js status [--include-history]

Commands:
  detect-conflicts      - Scan for conflicts between sessions
  coordination-report   - Generate comprehensive coordination analysis
  coordinate-sessions   - Start formal coordination between sessions
  send-message         - Send message within coordination group
  resolve-coordination - Mark coordination as resolved
  status               - Show coordination system status

Coordination Types:
  file-lock-conflict   - File access conflicts
  branch-conflict      - Branch-level coordination
  resource-contention  - Resource access conflicts
  permission-escalation- Permission request escalation

Examples:
  # Detect current conflicts
  node coordination-manager.js detect-conflicts

  # Start coordination between two sessions
  node coordination-manager.js coordinate-sessions "session-1,session-2" file-lock-conflict

  # Get system status with history
  node coordination-manager.js status --include-history
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
    detectConflicts,
    coordinateSessions,
    sendCoordinationMessage,
    resolveCoordination,
    getCoordinationStatus,
    generateCoordinationReport,
    COORDINATION_STRATEGIES,
    RESOLUTION_APPROACHES
};