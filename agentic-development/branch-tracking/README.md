# Central Branch Tracking System

> **📍 Navigation**: [agentic-development](../README.md) → [branch-tracking](./README.md)

## 📚 When to Load This Document

### Primary Context Loading Scenarios
- **Session Coordination**: Before starting any agent session to check active work
- **Branch Creation**: When creating new feature branches to avoid conflicts
- **Task Handoffs**: When transferring work between agents or completing tasks
- **Cleanup Operations**: When branches are merged and worktrees need cleanup
- **System Status Checks**: When investigating coordination issues or system state

### Dependency Mapping
**Load Before:**
- [../workflows/central-branch-tracking.md](../workflows/central-branch-tracking.md) - Workflow implementation details
- [../scripts/update-branch-tracking.js](../scripts/update-branch-tracking.js) - Update script usage

**Load With:**
- [active-branches.json](./active-branches.json) - Current system state
- [task-groups.json](./task-groups.json) - Related branch groups
- [agent-sessions.json](./agent-sessions.json) - Active agent work

**Load After:**
- [cleanup-queue.json](./cleanup-queue.json) - Branches ready for cleanup
- [merge-log.json](./merge-log.json) - Recent merge history

### Context Integration
This system provides real-time coordination state across all repositories. Load when you need to understand what agents are working on and how to coordinate new work without conflicts.

---

This directory contains the implementation of the Central Branch Tracking System for coordinating multi-agent development across the Tuvens ecosystem.

## Files

### Data Files
- **`active-branches.json`** - Current active branches across all repositories
- **`task-groups.json`** - Related branches working on same features/tasks
- **`merge-log.json`** - Recently merged branches with metadata
- **`cleanup-queue.json`** - Branches ready for worktree cleanup

### Update Script
- **`../scripts/update-branch-tracking.js`** - Node.js script that updates tracking data

## Usage

### View Current Status
```bash
# View active branches
cat active-branches.json | jq '.branches'

# View task groups
cat task-groups.json | jq 'keys'

# View cleanup queue
cat cleanup-queue.json | jq '.eligibleForCleanup'
```

### Manual Updates
```bash
# Add new branch
node ../scripts/update-branch-tracking.js \
  --action=create \
  --repository=tuvens-docs \
  --branch=vibe-coder/new-feature \
  --agent=vibe-coder \
  --worktree=/path/to/worktree

# Record merge
node ../scripts/update-branch-tracking.js \
  --action=merge \
  --repository=tuvens-docs \
  --branch=vibe-coder/new-feature \
  --target-branch=dev \
  --merged-by=ciarancarroll
```

### GitHub Integration
The system is designed to work with GitHub Actions webhooks. See the main documentation in `../workflows/central-branch-tracking.md` for full integration details.

## Data Structure

### Active Branches
Each active branch entry contains:
- Branch name and repository
- Author and creation timestamp
- Current status and last activity
- Associated task group (if any)
- Agent responsible
- Related branches in other repositories
- GitHub URLs and issue references
- Local worktree path

### Task Groups
Task groups coordinate related work across repositories:
- Group title and description
- Coordinator and creation date
- Current status
- Branch assignments per repository
- Agent assignments and responsibilities
- Dependencies between branches
- Associated issues and documentation

### Merge Log
Tracks completed work for reporting and cleanup:
- Merge metadata (when, who, target branch)
- Task group association
- Cleanup eligibility status
- Worktree path for cleanup

## Integration with Workflows

This system integrates with:
- `/start-session` command for checking related work
- `setup-agent-task.sh` for registering new branches
- GitHub Actions for automated updates
- Cleanup scripts for worktree management

## Status

✅ **Data Structure**: Core JSON files created and initialized  
✅ **Update Script**: Node.js script for manual and automated updates  
⏳ **GitHub Integration**: Webhook handlers need to be deployed  
⏳ **Local Commands**: Enhanced /start-session integration needed  
⏳ **Cleanup Automation**: Cleanup scripts need enhancement  

This implementation provides the foundation for coordinated multi-agent development with proper branch lifecycle tracking.