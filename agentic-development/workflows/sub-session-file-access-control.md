# Sub-Session File Access Control System

## Overview

The Sub-Session File Access Control System enables safe delegation of focused sub-tasks to specialized sub-agents with restricted file access permissions, automatic file lock management, and coordination mechanisms to prevent conflicts between main agents and sub-agents.

## Architecture

### Core Components

1. **Sub-Session Registry** (`.sub-session-locks.json`)
   - Central registry for tracking active sub-sessions
   - File lock management and coordination
   - Permission request tracking
   - Historical logging of all session activities

2. **Permission Management System** (`sub-session-manager.js`)
   - Creates and manages sub-sessions with access controls
   - Handles permission requests and approvals
   - Manages file locks and conflict resolution
   - Provides session lifecycle management

3. **Runtime Validation** (`claude-access-validator.js`)
   - Intercepts Claude tool operations
   - Validates file access permissions in real-time
   - Automatically acquires file locks for write operations
   - Provides suggestions for permission requests

4. **Coordination Manager** (`coordination-manager.js`)
   - Detects conflicts between sessions
   - Provides resolution strategies
   - Manages inter-session communication
   - Generates system health reports

5. **Integration Layer** (`sub-session-integration.js`)
   - Unified interface for all sub-session operations
   - Integrates with existing branch tracking system
   - Provides dashboard and monitoring capabilities
   - Automated maintenance and cleanup

## Access Modes

### Restricted Mode (Default)
- Limited to explicitly allowed paths only
- Requires permission requests for additional file access
- Ideal for focused, isolated sub-tasks
- Safest mode with maximum conflict prevention

**Default Allowed Paths:**
- `docs/` - Documentation files
- `README.md`, `CLAUDE.md` - Project documentation
- `/tmp/` - Temporary files

**Default Denied Paths:**
- `.git/` - Git repository files
- `.env` - Environment files
- `package-lock.json` - Dependency locks
- `node_modules/` - Dependencies
- `scripts/setup-*`, `scripts/cleanup-*` - Critical scripts

### Expanded Mode
- Broader access with protection for critical files
- Auto-approval for common development patterns
- Suitable for larger sub-tasks requiring multiple files
- Balanced security and productivity

**Additional Allowed Paths:**
- `src/` - Source code
- `tests/` - Test files

### Custom Mode
- Fully customizable permission sets
- Defined per sub-session requirements
- Maximum flexibility for specialized tasks

## File Lock Types

### Read Locks
- Multiple readers allowed simultaneously
- Prevents write conflicts
- Automatically shared between compatible sessions

### Write Locks
- Exclusive write access
- Prevents all other access during modification
- Automatically acquired for write operations

### Exclusive Locks
- Complete exclusive access
- Used for critical operations requiring isolation
- Highest level of protection

## Usage Guide

### Starting a Sub-Session

#### Using the Integrated Command
```bash
# Basic restricted sub-session
bash agentic-development/scripts/start-sub-session.sh vibe-coder test-runner "Run integration tests"

# Expanded access mode
bash agentic-development/scripts/start-sub-session.sh --access-mode expanded backend-dev validator "Validate API endpoints"

# Custom permissions
bash agentic-development/scripts/start-sub-session.sh --allow "docs/,tests/" --deny ".env,package-lock.json" frontend-dev component-builder "Build UI components"
```

#### Using the Integration Script
```bash
# Initialize the system (one-time setup)
node agentic-development/scripts/sub-session-integration.js init

# Start integrated sub-session
node agentic-development/scripts/sub-session-integration.js start vibe-coder test-runner "Run integration tests"
```

### Working in Sub-Sessions

1. **Setup Workspace**
   ```bash
   cd sub-sessions/[session-id]
   source .env-sub-session  # Load session environment
   claude                   # Start Claude with sub-session context
   ```

2. **Load Claude Prompt**
   Copy the generated prompt from `claude-prompt.txt` into Claude

3. **Validate File Access**
   ```bash
   # Check if you can access a file
   node agentic-development/scripts/claude-access-validator.js check-file [session-id] /path/to/file.js read
   ```

4. **Request Additional Permissions**
   ```bash
   # Request access to additional files
   node agentic-development/scripts/sub-session-manager.js request-permission [session-id] /path/to/file.js file-access "Need access for sub-task"
   ```

### Managing File Locks

File locks are automatically managed, but you can manually control them:

```bash
# Acquire a file lock
node agentic-development/scripts/sub-session-manager.js acquire-lock [session-id] /path/to/file.js write "Editing for sub-task"

# Release a file lock
node agentic-development/scripts/sub-session-manager.js release-lock [session-id] /path/to/file.js

# Check lock status
node agentic-development/scripts/sub-session-manager.js status
```

### Ending Sub-Sessions

```bash
# End session manually
node agentic-development/scripts/sub-session-manager.js end-session [session-id] "Task completed"

# Automated cleanup (removes expired sessions)
bash agentic-development/scripts/sub-session-cleanup.sh --auto

# Preview cleanup actions
bash agentic-development/scripts/sub-session-cleanup.sh --dry-run
```

## Monitoring and Coordination

### System Dashboard
```bash
# View comprehensive dashboard
node agentic-development/scripts/sub-session-integration.js dashboard

# Get detailed system status
node agentic-development/scripts/sub-session-integration.js status
```

### Conflict Detection and Resolution
```bash
# Detect coordination conflicts
node agentic-development/scripts/coordination-manager.js detect-conflicts

# Generate coordination report
node agentic-development/scripts/coordination-manager.js coordination-report

# Start formal coordination between sessions
node agentic-development/scripts/coordination-manager.js coordinate-sessions "session-1,session-2" file-lock-conflict
```

### Maintenance
```bash
# Run automated maintenance
node agentic-development/scripts/sub-session-integration.js maintenance

# Force cleanup of old sessions
bash agentic-development/scripts/sub-session-cleanup.sh --force --max-age 1
```

## Integration with Existing Systems

### Branch Tracking Integration
- Sub-sessions are automatically registered in `active-branches.json`
- Main agent sessions can see related sub-sessions
- Coordination information flows through existing tracking

### GitHub Actions Integration
- Sub-session events can be tracked through existing workflows
- Cleanup automation can be triggered via GitHub Actions
- Coordination reports can be generated on merge events

### Claude Desktop Integration
- Detection of sub-session mode in Claude prompts
- Automatic access validation for all Claude operations
- Permission request suggestions in error messages

## Security Features

### Permission Boundaries
- Strict path-based access controls
- Automatic denial of critical system files
- Escalation path for legitimate access needs

### Conflict Prevention
- Automatic file lock acquisition
- Deadlock detection and resolution
- Safe parallel work patterns

### Audit Trail
- Complete history of all file operations
- Permission request tracking
- Session lifecycle logging

## Auto-Resolution Features

### Smart Permission Approval
- Auto-approval for safe documentation paths
- Pattern-based permission grants
- Context-aware access decisions

### Conflict Resolution Suggestions
- File splitting recommendations for documentation
- Sequential work patterns for conflicting operations
- Coordination strategies for complex conflicts

## File Structure

```
agentic-development/
├── branch-tracking/
│   ├── .sub-session-locks.json         # Central registry
│   ├── coordination-log.json           # Coordination history
│   └── active-branches.json            # Integrated tracking
├── scripts/
│   ├── sub-session-manager.js          # Core management
│   ├── claude-access-validator.js      # Runtime validation
│   ├── coordination-manager.js         # Conflict resolution
│   ├── start-sub-session.sh            # Easy session creation
│   ├── sub-session-cleanup.sh          # Automated cleanup
│   └── sub-session-integration.js      # Unified interface
└── workflows/
    └── sub-session-file-access-control.md  # This documentation
```

## Best Practices

### Sub-Task Design
1. **Keep Tasks Focused** - Design sub-tasks with minimal file requirements
2. **Clear Boundaries** - Define clear scope to minimize permission requests
3. **Document Dependencies** - Specify required files upfront when possible

### Permission Management
1. **Request Early** - Request permissions at the start of work
2. **Justify Clearly** - Provide clear reasoning for permission requests
3. **Release Promptly** - End sessions when work is complete

### Coordination
1. **Check Status** - Review active sessions before starting work
2. **Communicate Intent** - Use coordination features for complex tasks
3. **Monitor Health** - Regular system health checks

### Maintenance
1. **Regular Cleanup** - Schedule automated cleanup for expired sessions
2. **Monitor Conflicts** - Address coordination conflicts promptly
3. **Review Patterns** - Analyze usage patterns for optimization

## Troubleshooting

### Common Issues

#### Permission Denied Errors
```bash
# Check current permissions
node agentic-development/scripts/claude-access-validator.js check-file [session-id] /path/to/file

# Request additional access
node agentic-development/scripts/sub-session-manager.js request-permission [session-id] /path/to/file file-access "Justification"
```

#### File Lock Conflicts
```bash
# Check who has the lock
node agentic-development/scripts/sub-session-manager.js status

# Start coordination with conflicting session
node agentic-development/scripts/coordination-manager.js coordinate-sessions "session-1,session-2" file-lock-conflict
```

#### Session Detection Issues
```bash
# Manually detect session
node agentic-development/scripts/claude-access-validator.js detect-session

# Check workspace setup
ls -la sub-sessions/[session-id]/
```

### Debug Commands
```bash
# System health check
node agentic-development/scripts/coordination-manager.js status --include-history

# Comprehensive status
node agentic-development/scripts/sub-session-integration.js status

# Maintenance dry run
node agentic-development/scripts/sub-session-integration.js maintenance --dry-run
```

## Examples

### Example 1: Testing Sub-Session
```bash
# Start a testing sub-session
bash agentic-development/scripts/start-sub-session.sh vibe-coder test-runner "Run comprehensive tests"

# The sub-session will have:
# - Access to tests/ directory
# - Read access to package.json
# - Restricted from modifying source code
# - Automatic cleanup after 24 hours
```

### Example 2: Documentation Sub-Session
```bash
# Start documentation work with expanded access
bash agentic-development/scripts/start-sub-session.sh --access-mode expanded technical-writer doc-updater "Update API documentation"

# This allows:
# - Full access to docs/ directory
# - Read access to source for reference
# - Auto-approval for documentation file requests
```

### Example 3: Code Review Sub-Session
```bash
# Restricted code review session
bash agentic-development/scripts/start-sub-session.sh --access-mode custom --allow "src/,tests/,README.md" --deny "package-lock.json,.env" code-reviewer analyzer "Analyze code quality"

# Features:
# - Read-only access to source and tests
# - Cannot modify dependencies or configuration
# - Can create reports and documentation
```

This sub-session file access control system provides a comprehensive framework for safe, coordinated parallel development with granular permission management and automatic conflict resolution.