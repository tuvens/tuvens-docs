#!/usr/bin/env node

/**
 * Claude Access Validator
 * 
 * Runtime validation system for Claude prompts to enforce file access controls
 * for sub-agents. This system intercepts and validates file operations before
 * they are executed.
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

// Import sub-session manager functions
import { checkFileAccess, acquireFileLock, LOCK_TYPES } from './sub-session-manager.js';

/**
 * File operation types that Claude might attempt
 */
const CLAUDE_OPERATIONS = {
    READ: 'read',
    WRITE: 'write',
    CREATE: 'create',
    DELETE: 'delete',
    EDIT: 'edit',
    GLOB: 'glob',
    BASH: 'bash'
};

/**
 * Extract file paths from Claude tool calls
 */
function extractFilePathsFromOperation(operation, params) {
    const filePaths = [];

    switch (operation) {
        case CLAUDE_OPERATIONS.READ:
            if (params.file_path) filePaths.push(params.file_path);
            break;

        case CLAUDE_OPERATIONS.WRITE:
        case CLAUDE_OPERATIONS.CREATE:
            if (params.file_path) filePaths.push(params.file_path);
            break;

        case CLAUDE_OPERATIONS.EDIT:
            if (params.file_path) filePaths.push(params.file_path);
            break;

        case CLAUDE_OPERATIONS.GLOB:
            // Glob operations might access multiple files
            if (params.path) filePaths.push(params.path);
            break;

        case CLAUDE_OPERATIONS.BASH:
            // Parse bash commands for file operations
            const bashPaths = extractPathsFromBashCommand(params.command);
            filePaths.push(...bashPaths);
            break;

        default:
            // Unknown operation - be conservative
            break;
    }

    return filePaths;
}

/**
 * Extract file paths from bash commands
 */
function extractPathsFromBashCommand(command) {
    const paths = [];
    
    // Common file operation patterns
    const patterns = [
        /(?:cat|less|head|tail|nano|vim|code)\s+([^\s]+)/g,  // File viewers/editors
        /(?:cp|mv|rm)\s+([^\s]+)/g,                          // File operations
        /(?:mkdir|rmdir)\s+([^\s]+)/g,                       // Directory operations
        /(?:chmod|chown)\s+[^\s]+\s+([^\s]+)/g,              // Permission changes
        />\s*([^\s]+)/g,                                     // Output redirection
        /(?:^|\s)([^|\s]*\.(?:js|ts|json|md|txt|py|sh|yml|yaml))/g  // File extensions
    ];

    for (const pattern of patterns) {
        let match;
        while ((match = pattern.exec(command)) !== null) {
            const filePath = match[1];
            if (filePath && !filePath.startsWith('-') && filePath !== '/dev/null') {
                paths.push(filePath);
            }
        }
    }

    return paths;
}

/**
 * Validate a Claude operation against sub-session permissions
 */
function validateOperation(sessionId, operation, params) {
    if (!sessionId) {
        // No session ID means this is a main agent - allow all operations
        return {
            allowed: true,
            reason: 'Main agent - unrestricted access',
            autoLockAcquired: false
        };
    }

    const filePaths = extractFilePathsFromOperation(operation, params);
    const validationResults = [];
    let autoLockAcquired = false;

    for (const filePath of filePaths) {
        // Normalize path to absolute
        const absolutePath = path.isAbsolute(filePath) ? filePath : path.resolve(filePath);
        
        // Check access permissions
        const accessResult = checkFileAccess(sessionId, absolutePath, operation);
        
        if (!accessResult.allowed) {
            return {
                allowed: false,
                reason: `Access denied to ${absolutePath}: ${accessResult.reason}`,
                suggestedAction: generatePermissionRequestSuggestion(sessionId, absolutePath, operation),
                filePath: absolutePath
            };
        }

        // For write operations, try to acquire a file lock
        if ([CLAUDE_OPERATIONS.WRITE, CLAUDE_OPERATIONS.CREATE, CLAUDE_OPERATIONS.EDIT].includes(operation)) {
            const lockResult = acquireFileLock(
                sessionId, 
                absolutePath, 
                LOCK_TYPES.WRITE, 
                `Claude ${operation} operation`
            );

            if (!lockResult.success && lockResult.conflict) {
                return {
                    allowed: false,
                    reason: `File lock conflict: ${absolutePath} is locked by ${lockResult.conflictWith}`,
                    suggestedAction: `Wait for lock release or coordinate with session ${lockResult.conflictWith}`,
                    filePath: absolutePath,
                    conflictWith: lockResult.conflictWith
                };
            }

            if (lockResult.success) {
                autoLockAcquired = true;
            }
        }

        validationResults.push({
            filePath: absolutePath,
            operation,
            allowed: true,
            reason: accessResult.reason
        });
    }

    return {
        allowed: true,
        reason: 'All file operations validated',
        autoLockAcquired,
        validatedPaths: validationResults
    };
}

/**
 * Generate suggestion for permission request
 */
function generatePermissionRequestSuggestion(sessionId, filePath, operation) {
    const requestType = operation === CLAUDE_OPERATIONS.READ ? 'file-access' : 'file-access';
    
    return {
        command: `node agentic-development/scripts/sub-session-manager.js request-permission ${sessionId} ${filePath} ${requestType} "Required for Claude ${operation} operation"`,
        description: `Request permission to ${operation} ${filePath}`,
        autoRequestAvailable: true
    };
}

/**
 * Check if current environment is a sub-session
 */
function detectSubSession() {
    // Check environment variables that might indicate a sub-session
    const subSessionIndicators = [
        process.env.SUB_SESSION_ID,
        process.env.CLAUDE_SUB_SESSION,
        process.env.SUB_AGENT_MODE
    ];

    for (const indicator of subSessionIndicators) {
        if (indicator) {
            return indicator;
        }
    }

    // Check if we're in a sub-session worktree based on path patterns
    const cwd = process.cwd();
    const subSessionPatterns = [
        /\/sub-sessions?\//,
        /\/[^/]+-sub-[^/]+\//,
        /\/temp-[^/]+\//
    ];

    for (const pattern of subSessionPatterns) {
        if (pattern.test(cwd)) {
            // Try to find session ID from path or nearby files
            return extractSessionIdFromPath(cwd);
        }
    }

    return null;
}

/**
 * Extract session ID from current working directory
 */
function extractSessionIdFromPath(workingDir) {
    // Look for session files that might contain session ID
    const sessionFiles = [
        path.join(workingDir, '.sub-session-id'),
        path.join(workingDir, '.claude-session'),
        path.join(workingDir, '.session-info.json')
    ];

    for (const sessionFile of sessionFiles) {
        try {
            if (fs.existsSync(sessionFile)) {
                const content = fs.readFileSync(sessionFile, 'utf8').trim();
                if (content) {
                    return content;
                }
            }
        } catch (error) {
            // Continue checking other files
        }
    }

    return null;
}

/**
 * Create a Claude-compatible wrapper that validates operations
 */
function createClaudeValidationWrapper() {
    const sessionId = detectSubSession();
    
    if (!sessionId) {
        console.log('🔓 Running as main agent - no access restrictions');
        return { sessionId: null, restrictionsActive: false };
    }

    console.log(`🔒 Running as sub-agent - session: ${sessionId}`);
    console.log('📋 File access restrictions are active');

    return {
        sessionId,
        restrictionsActive: true,
        validateOperation: (operation, params) => validateOperation(sessionId, operation, params),
        requestPermission: (filePath, justification) => requestPermission(sessionId, filePath, 'file-access', justification)
    };
}

/**
 * Generate Claude prompt additions for sub-session awareness
 */
function generateClaudePromptAdditions(sessionId) {
    if (!sessionId) {
        return '';
    }

    return `

🔒 SUB-SESSION ACCESS CONTROL ACTIVE
=====================================

Session ID: ${sessionId}

IMPORTANT RESTRICTIONS:
- You are running in sub-session mode with restricted file access
- Before accessing files, check permissions using the access validation system
- Some file operations may require permission requests
- File locks are automatically managed to prevent conflicts

AVAILABLE COMMANDS:
- Check file access: node agentic-development/scripts/claude-access-validator.js check-file <file-path>
- Request permission: node agentic-development/scripts/sub-session-manager.js request-permission ${sessionId} <file-path> file-access "<justification>"
- Check session status: node agentic-development/scripts/sub-session-manager.js status

WORKFLOW:
1. Before file operations, validate access permissions
2. Request additional permissions if needed
3. Acquire file locks for write operations automatically
4. Release locks when done with files

If you encounter access restrictions, use the permission request system rather than attempting to bypass the controls.
`;
}

/**
 * Command line interface
 */
function main() {
    const args = process.argv.slice(2);
    const command = args[0];

    try {
        switch (command) {
            case 'validate-operation':
                const sessionId = args[1] || detectSubSession();
                const operation = args[2];
                const paramsJson = args[3];
                
                if (!operation) {
                    throw new Error('Operation type required');
                }

                let params = {};
                if (paramsJson) {
                    params = JSON.parse(paramsJson);
                }

                const result = validateOperation(sessionId, operation, params);
                console.log(JSON.stringify(result, null, 2));
                break;

            case 'check-file':
                const checkSessionId = args[1] || detectSubSession();
                const filePath = args[2];
                const operationType = args[3] || 'read';

                if (!filePath) {
                    throw new Error('File path required');
                }

                const accessResult = checkFileAccess(checkSessionId, filePath, operationType);
                console.log(JSON.stringify(accessResult, null, 2));
                break;

            case 'detect-session':
                const detectedSessionId = detectSubSession();
                console.log(JSON.stringify({ 
                    sessionId: detectedSessionId,
                    isSubSession: !!detectedSessionId,
                    workingDirectory: process.cwd()
                }, null, 2));
                break;

            case 'generate-prompt':
                const promptSessionId = args[1] || detectSubSession();
                const promptAdditions = generateClaudePromptAdditions(promptSessionId);
                console.log(promptAdditions);
                break;

            case 'init-validation':
                const wrapper = createClaudeValidationWrapper();
                console.log(JSON.stringify(wrapper, null, 2));
                break;

            default:
                console.log(`
Claude Access Validator - Runtime Validation for Sub-Sessions

Usage:
  node claude-access-validator.js validate-operation [sessionId] <operation> [paramsJson]
  node claude-access-validator.js check-file [sessionId] <filePath> [operationType]
  node claude-access-validator.js detect-session
  node claude-access-validator.js generate-prompt [sessionId]
  node claude-access-validator.js init-validation

Commands:
  validate-operation - Validate a Claude tool operation against permissions
  check-file        - Check access permissions for a specific file
  detect-session    - Detect if running in sub-session mode
  generate-prompt   - Generate Claude prompt additions for sub-session
  init-validation   - Initialize validation wrapper for Claude session

Examples:
  # Check if sub-session can read a file
  node claude-access-validator.js check-file sub-session-123 /path/to/file.js read

  # Validate a Write operation
  node claude-access-validator.js validate-operation sub-session-123 write '{"file_path":"/path/to/file.js","content":"..."}'

  # Detect current session mode
  node claude-access-validator.js detect-session
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
    validateOperation,
    detectSubSession,
    createClaudeValidationWrapper,
    generateClaudePromptAdditions,
    extractFilePathsFromOperation
};