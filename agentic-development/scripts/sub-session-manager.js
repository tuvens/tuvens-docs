#!/usr/bin/env node

/**
 * Sub-Session Manager
 * 
 * Manages file access control, permissions, and coordination between main agents
 * and sub-agents to enable safe parallel work without file conflicts.
 */

import fs from 'fs';
import path from 'path';
import crypto from 'crypto';
import { fileURLToPath } from 'url';

// ES modules don't have __dirname, so we need to create it
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Configuration
const TRACKING_DIR = path.join(__dirname, '..', 'branch-tracking');
const LOCKS_FILE = path.join(TRACKING_DIR, '.sub-session-locks.json');
const ACTIVE_BRANCHES_FILE = path.join(TRACKING_DIR, 'active-branches.json');

// Access modes
const ACCESS_MODES = {
    RESTRICTED: 'restricted',      // Limited to specific files/directories
    EXPANDED: 'expanded',          // Broader access with some restrictions
    CUSTOM: 'custom'               // Custom permission set
};

// Lock types
const LOCK_TYPES = {
    READ: 'read',         // Multiple readers allowed
    WRITE: 'write',       // Exclusive write access
    EXCLUSIVE: 'exclusive' // Complete exclusive access
};

// Permission request types
const PERMISSION_TYPES = {
    FILE_ACCESS: 'file-access',
    DIRECTORY_ACCESS: 'directory-access',
    TOOL_PERMISSION: 'tool-permission'
};

// Utility functions
function loadJSON(filePath) {
    try {
        if (!fs.existsSync(filePath)) {
            return getDefaultStructure();
        }
        return JSON.parse(fs.readFileSync(filePath, 'utf8'));
    } catch (error) {
        console.error(`Error loading ${filePath}:`, error.message);
        return getDefaultStructure();
    }
}

function saveJSON(filePath, data) {
    try {
        data.lastUpdated = new Date().toISOString();
        fs.writeFileSync(filePath, JSON.stringify(data, null, 2));
        console.log(`✅ Updated: ${path.basename(filePath)}`);
        return true;
    } catch (error) {
        console.error(`Error saving ${filePath}:`, error.message);
        return false;
    }
}

function getDefaultStructure() {
    return {
        version: '1.0.0',
        lastUpdated: new Date().toISOString(),
        activeSessions: {},
        fileLocks: {},
        permissionRegistry: {},
        lockHistory: []
    };
}

function generateSessionId(agent, taskType = 'sub-task') {
    const timestamp = Date.now();
    const random = crypto.randomBytes(4).toString('hex');
    return `${agent}-${taskType}-${timestamp}-${random}`;
}

function generateRequestId() {
    return crypto.randomBytes(8).toString('hex');
}

function addLockHistory(locks, action, sessionId, filePath, details = '') {
    locks.lockHistory.unshift({
        timestamp: new Date().toISOString(),
        action,
        sessionId,
        filePath,
        details
    });

    // Keep only last 100 history entries
    if (locks.lockHistory.length > 100) {
        locks.lockHistory = locks.lockHistory.slice(0, 100);
    }
}

/**
 * Create a new sub-session with restricted file access
 */
function createSubSession(options) {
    const {
        mainAgent,
        subAgent,
        taskScope,
        accessMode = ACCESS_MODES.RESTRICTED,
        allowedPaths = [],
        deniedPaths = [],
        parentBranch,
        subBranch,
        autoExpiry = null
    } = options;

    if (!mainAgent || !subAgent) {
        throw new Error('Both mainAgent and subAgent are required');
    }

    const locks = loadJSON(LOCKS_FILE);
    const sessionId = generateSessionId(subAgent);

    // Create session entry
    locks.activeSessions[sessionId] = {
        mainAgent,
        subAgent,
        startTime: new Date().toISOString(),
        lastActivity: new Date().toISOString(),
        accessMode,
        allowedPaths: [...allowedPaths],
        deniedPaths: [...deniedPaths],
        lockAcquisitions: [],
        permissionRequests: [],
        coordinationData: {
            relatedMainSession: null, // Will be populated if main agent has active session
            taskScope,
            parentBranch,
            subBranch
        },
        autoExpiry
    };

    // Add to history
    addLockHistory(locks, 'session-created', sessionId, '', `Sub-session created for ${subAgent} by ${mainAgent}`);

    if (saveJSON(LOCKS_FILE, locks)) {
        console.log(`✅ Created sub-session: ${sessionId}`);
        console.log(`   Main Agent: ${mainAgent}`);
        console.log(`   Sub Agent: ${subAgent}`);
        console.log(`   Access Mode: ${accessMode}`);
        console.log(`   Task Scope: ${taskScope}`);
        return { sessionId, success: true };
    }

    return { sessionId: null, success: false };
}

/**
 * Request permission for file or directory access
 */
function requestPermission(sessionId, resourcePath, requestType, justification) {
    const locks = loadJSON(LOCKS_FILE);

    if (!locks.activeSessions[sessionId]) {
        throw new Error(`Session ${sessionId} not found`);
    }

    const requestId = generateRequestId();
    
    locks.permissionRegistry[requestId] = {
        sessionId,
        requestType,
        requestedResource: resourcePath,
        justification,
        status: 'pending',
        requestedAt: new Date().toISOString(),
        respondedAt: null,
        respondedBy: null,
        autoApprovalRules: checkAutoApprovalRules(resourcePath, requestType),
        restrictions: []
    };

    // Add to session's request list
    locks.activeSessions[sessionId].permissionRequests.push(requestId);
    locks.activeSessions[sessionId].lastActivity = new Date().toISOString();

    // Check for auto-approval
    if (locks.permissionRegistry[requestId].autoApprovalRules.length > 0) {
        locks.permissionRegistry[requestId].status = 'approved';
        locks.permissionRegistry[requestId].respondedAt = new Date().toISOString();
        locks.permissionRegistry[requestId].respondedBy = 'auto-approval-system';
        
        // Add to allowed paths
        locks.activeSessions[sessionId].allowedPaths.push(resourcePath);
        
        console.log(`🤖 Auto-approved permission request: ${requestId}`);
    }

    addLockHistory(locks, 'permission-requested', sessionId, resourcePath, `Request: ${requestType}`);

    if (saveJSON(LOCKS_FILE, locks)) {
        return { requestId, autoApproved: locks.permissionRegistry[requestId].status === 'approved' };
    }

    return { requestId: null, autoApproved: false };
}

/**
 * Check if a permission request qualifies for auto-approval
 */
function checkAutoApprovalRules(resourcePath, requestType) {
    const autoRules = [];

    // Safe read-only paths that can be auto-approved
    const safeReadPaths = [
        '/README.md',
        '/package.json',
        '/docs/',
        '/agentic-development/workflows/',
        '/.github/workflows/',
        '/scripts/',
        '/CLAUDE.md'
    ];

    // Safe write paths for documentation
    const safeWritePaths = [
        '/docs/',
        '/agentic-development/auto-generated/',
        '/IMPLEMENTATION_NOTES.md',
        '/ENHANCEMENT_DOCUMENTATION.md'
    ];

    if (requestType === PERMISSION_TYPES.FILE_ACCESS) {
        // Auto-approve read access to safe files
        if (safeReadPaths.some(safePath => resourcePath.includes(safePath))) {
            autoRules.push('safe-read-path');
        }

        // Auto-approve write access to safe documentation paths
        if (safeWritePaths.some(safePath => resourcePath.includes(safePath))) {
            autoRules.push('safe-documentation-write');
        }
    }

    return autoRules;
}

/**
 * Acquire a file lock
 */
function acquireFileLock(sessionId, filePath, lockType = LOCK_TYPES.WRITE, reason = '', relatedFiles = []) {
    const locks = loadJSON(LOCKS_FILE);

    if (!locks.activeSessions[sessionId]) {
        throw new Error(`Session ${sessionId} not found`);
    }

    // Check if file is already locked
    if (locks.fileLocks[filePath]) {
        const existingLock = locks.fileLocks[filePath];
        
        // Allow multiple read locks
        if (lockType === LOCK_TYPES.READ && existingLock.lockType === LOCK_TYPES.READ) {
            // Add this session as a co-reader
            if (!existingLock.coReaders) existingLock.coReaders = [];
            existingLock.coReaders.push(sessionId);
            locks.activeSessions[sessionId].lockAcquisitions.push(filePath);
            
            addLockHistory(locks, 'read-lock-shared', sessionId, filePath, `Shared with ${existingLock.lockedBy}`);
            saveJSON(LOCKS_FILE, locks);
            return { success: true, shared: true };
        }

        // Conflict for write or exclusive locks
        addLockHistory(locks, 'lock-conflict', sessionId, filePath, `Blocked by ${existingLock.lockedBy}`);
        return { 
            success: false, 
            conflict: true, 
            conflictWith: existingLock.lockedBy,
            conflictType: existingLock.lockType
        };
    }

    // Acquire the lock
    locks.fileLocks[filePath] = {
        lockedBy: sessionId,
        lockType,
        acquiredAt: new Date().toISOString(),
        expiresAt: null, // Could add auto-expiry later
        reason,
        relatedFiles: [...relatedFiles]
    };

    // Add to session's lock list
    locks.activeSessions[sessionId].lockAcquisitions.push(filePath);
    locks.activeSessions[sessionId].lastActivity = new Date().toISOString();

    addLockHistory(locks, 'acquire', sessionId, filePath, reason);

    if (saveJSON(LOCKS_FILE, locks)) {
        console.log(`🔒 Acquired ${lockType} lock on ${filePath} for session ${sessionId}`);
        return { success: true, shared: false };
    }

    return { success: false };
}

/**
 * Release a file lock
 */
function releaseFileLock(sessionId, filePath) {
    const locks = loadJSON(LOCKS_FILE);

    if (!locks.activeSessions[sessionId]) {
        throw new Error(`Session ${sessionId} not found`);
    }

    if (!locks.fileLocks[filePath]) {
        return { success: false, error: 'File not locked' };
    }

    const lock = locks.fileLocks[filePath];

    // Check if this session owns the lock or is a co-reader
    if (lock.lockedBy === sessionId || (lock.coReaders && lock.coReaders.includes(sessionId))) {
        
        // Handle shared read locks
        if (lock.coReaders && lock.coReaders.includes(sessionId)) {
            lock.coReaders = lock.coReaders.filter(id => id !== sessionId);
            
            // If no more co-readers and main locker is different, keep the main lock
            if (lock.coReaders.length === 0 && lock.lockedBy !== sessionId) {
                delete lock.coReaders;
            }
            // If this was the main locker and there are co-readers, promote one
            else if (lock.lockedBy === sessionId && lock.coReaders.length > 0) {
                lock.lockedBy = lock.coReaders.shift();
            }
            // If this was the last reader, remove the lock entirely
            else if (lock.lockedBy === sessionId && lock.coReaders.length === 0) {
                delete locks.fileLocks[filePath];
            }
        } else {
            // Remove the lock entirely
            delete locks.fileLocks[filePath];
        }

        // Remove from session's lock list
        locks.activeSessions[sessionId].lockAcquisitions = 
            locks.activeSessions[sessionId].lockAcquisitions.filter(path => path !== filePath);
        
        locks.activeSessions[sessionId].lastActivity = new Date().toISOString();

        addLockHistory(locks, 'release', sessionId, filePath, '');

        if (saveJSON(LOCKS_FILE, locks)) {
            console.log(`🔓 Released lock on ${filePath} for session ${sessionId}`);
            return { success: true };
        }
    }

    return { success: false, error: 'Lock not owned by this session' };
}

/**
 * Check if a session has access to a specific file
 */
function checkFileAccess(sessionId, filePath, operation = 'read') {
    const locks = loadJSON(LOCKS_FILE);

    if (!locks.activeSessions[sessionId]) {
        return { allowed: false, reason: 'Session not found' };
    }

    const session = locks.activeSessions[sessionId];

    // Check if explicitly denied
    if (session.deniedPaths.some(deniedPath => filePath.includes(deniedPath))) {
        return { allowed: false, reason: 'Explicitly denied path' };
    }

    // Check if explicitly allowed
    if (session.allowedPaths.some(allowedPath => filePath.includes(allowedPath))) {
        return { allowed: true, reason: 'Explicitly allowed path' };
    }

    // Check access mode defaults
    if (session.accessMode === ACCESS_MODES.RESTRICTED) {
        return { allowed: false, reason: 'Restricted mode - request permission' };
    }

    if (session.accessMode === ACCESS_MODES.EXPANDED) {
        // Allow access to most files except critical system files
        const criticalPaths = [
            '/.git/',
            '/.env',
            '/package-lock.json',
            '/node_modules/',
            '/scripts/setup-',
            '/scripts/cleanup-'
        ];

        if (criticalPaths.some(criticalPath => filePath.includes(criticalPath))) {
            return { allowed: false, reason: 'Critical system file - requires permission' };
        }

        return { allowed: true, reason: 'Expanded mode default access' };
    }

    // Custom mode - check specific rules (implementation depends on requirements)
    return { allowed: false, reason: 'Custom mode - specific rules not implemented' };
}

/**
 * End a sub-session and release all locks
 */
function endSubSession(sessionId, reason = 'Session completed') {
    const locks = loadJSON(LOCKS_FILE);

    if (!locks.activeSessions[sessionId]) {
        return { success: false, error: 'Session not found' };
    }

    const session = locks.activeSessions[sessionId];

    // Release all file locks held by this session
    const releasedLocks = [];
    for (const filePath of session.lockAcquisitions) {
        const result = releaseFileLock(sessionId, filePath);
        if (result.success) {
            releasedLocks.push(filePath);
        }
    }

    // Mark any pending permission requests as expired
    for (const requestId of session.permissionRequests) {
        if (locks.permissionRegistry[requestId] && locks.permissionRegistry[requestId].status === 'pending') {
            locks.permissionRegistry[requestId].status = 'expired';
            locks.permissionRegistry[requestId].respondedAt = new Date().toISOString();
            locks.permissionRegistry[requestId].respondedBy = 'system-session-end';
        }
    }

    // Remove session
    delete locks.activeSessions[sessionId];

    addLockHistory(locks, 'session-ended', sessionId, '', reason);

    if (saveJSON(LOCKS_FILE, locks)) {
        console.log(`✅ Ended sub-session: ${sessionId}`);
        console.log(`   Released ${releasedLocks.length} file locks`);
        console.log(`   Reason: ${reason}`);
        return { success: true, releasedLocks };
    }

    return { success: false };
}

/**
 * Get system status including active sessions and locks
 */
function getSystemStatus() {
    const locks = loadJSON(LOCKS_FILE);
    const activeBranches = loadJSON(ACTIVE_BRANCHES_FILE);

    const status = {
        totalActiveSessions: Object.entries(locks.activeSessions).length,
        totalActiveLocks: Object.entries(locks.fileLocks).length,
        totalPendingRequests: Object.values(locks.permissionRegistry).filter(req => req.status === 'pending').length,
        sessions: {},
        lockConflicts: [],
        recentActivity: locks.lockHistory.slice(0, 10)
    };

    // Process each session
    for (const [sessionId, session] of Object.entries(locks.activeSessions)) {
        status.sessions[sessionId] = {
            subAgent: session.subAgent,
            mainAgent: session.mainAgent,
            startTime: session.startTime,
            lastActivity: session.lastActivity,
            accessMode: session.accessMode,
            activeLocksCount: session.lockAcquisitions.length,
            pendingRequestsCount: session.permissionRequests.filter(reqId => 
                locks.permissionRegistry[reqId] && locks.permissionRegistry[reqId].status === 'pending'
            ).length,
            taskScope: session.coordinationData.taskScope
        };
    }

    // Check for potential conflicts (files with multiple lock attempts)
    const lockAttempts = {};
    for (const historyEntry of locks.lockHistory) {
        if (historyEntry.action === 'lock-conflict') {
            if (!lockAttempts[historyEntry.filePath]) {
                lockAttempts[historyEntry.filePath] = [];
            }
            lockAttempts[historyEntry.filePath].push(historyEntry);
        }
    }

    for (const [filePath, conflicts] of Object.entries(lockAttempts)) {
        if (conflicts.length > 0) {
            status.lockConflicts.push({
                filePath,
                conflictCount: conflicts.length,
                lastConflict: conflicts[0].timestamp,
                involveSessions: [...new Set(conflicts.map(c => c.sessionId))]
            });
        }
    }

    return status;
}

// Command line interface
function main() {
    const args = process.argv.slice(2);
    const command = args[0];

    try {
        switch (command) {
            case 'create-session':
                const createResult = createSubSession({
                    mainAgent: args[1],
                    subAgent: args[2],
                    taskScope: args[3] || 'Sub-task',
                    accessMode: args[4] || ACCESS_MODES.RESTRICTED,
                    allowedPaths: args[5] ? args[5].split(',') : [],
                    deniedPaths: args[6] ? args[6].split(',') : []
                });
                console.log(JSON.stringify(createResult, null, 2));
                break;

            case 'request-permission':
                const requestResult = requestPermission(args[1], args[2], args[3] || PERMISSION_TYPES.FILE_ACCESS, args[4] || 'Sub-task requires access');
                console.log(JSON.stringify(requestResult, null, 2));
                break;

            case 'acquire-lock':
                const lockResult = acquireFileLock(args[1], args[2], args[3] || LOCK_TYPES.WRITE, args[4] || 'Sub-task file modification');
                console.log(JSON.stringify(lockResult, null, 2));
                break;

            case 'release-lock':
                const releaseResult = releaseFileLock(args[1], args[2]);
                console.log(JSON.stringify(releaseResult, null, 2));
                break;

            case 'check-access':
                const accessResult = checkFileAccess(args[1], args[2], args[3] || 'read');
                console.log(JSON.stringify(accessResult, null, 2));
                break;

            case 'end-session':
                const endResult = endSubSession(args[1], args[2] || 'Manual termination');
                console.log(JSON.stringify(endResult, null, 2));
                break;

            case 'status':
                const statusResult = getSystemStatus();
                console.log(JSON.stringify(statusResult, null, 2));
                break;

            default:
                console.log(`
Sub-Session Manager - File Access Control for Sub-Agents

Usage:
  node sub-session-manager.js create-session <mainAgent> <subAgent> <taskScope> [accessMode] [allowedPaths] [deniedPaths]
  node sub-session-manager.js request-permission <sessionId> <resourcePath> [requestType] [justification]
  node sub-session-manager.js acquire-lock <sessionId> <filePath> [lockType] [reason]
  node sub-session-manager.js release-lock <sessionId> <filePath>
  node sub-session-manager.js check-access <sessionId> <filePath> [operation]
  node sub-session-manager.js end-session <sessionId> [reason]
  node sub-session-manager.js status

Commands:
  create-session    - Create new sub-session with access controls
  request-permission- Request permission for file/directory access
  acquire-lock      - Acquire exclusive lock on file
  release-lock      - Release file lock
  check-access      - Check if session has access to file
  end-session       - End session and release all locks
  status            - Show system status and active sessions

Access Modes:
  restricted        - Limited to specific allowed paths only
  expanded          - Broader access with some restrictions
  custom            - Custom permission set

Lock Types:
  read              - Multiple readers allowed
  write             - Exclusive write access
  exclusive         - Complete exclusive access
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

// Export functions for use as module
export {
    createSubSession,
    requestPermission,
    acquireFileLock,
    releaseFileLock,
    checkFileAccess,
    endSubSession,
    getSystemStatus,
    ACCESS_MODES,
    LOCK_TYPES,
    PERMISSION_TYPES
};