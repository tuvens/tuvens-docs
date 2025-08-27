# Troubleshooting Guide

← [Back to Main](./README.md)

## 🐛 Common Issues and Solutions

### Important Context
**Claude Desktop vs Claude Code:**
- **Claude Code**: Uses the built-in `/start-session` slash command
- **Claude Desktop**: Executes `./agentic-development/scripts/setup-agent-task-desktop.sh` via iTerm2 MCP

### If automation fails to trigger:
1. Check repository structure: `ls ~/Code/Tuvens/` should show all repos
2. Verify desktop setup script: `ls ~/Code/Tuvens/tuvens-docs/agentic-development/scripts/setup-agent-task-desktop.sh`
3. Test GitHub CLI: `gh repo view` should work
4. Check iTerm MCP: Look for `iterm_mcp_server` in running processes

### Common Error Messages

**"Script not found"**: 
- Ensure you're in `~/Code/Tuvens/tuvens-docs`
- Verify the desktop setup script exists: `./agentic-development/scripts/setup-agent-task-desktop.sh`
- Check execute permissions: `chmod +x ./agentic-development/scripts/setup-agent-task-desktop.sh`

**"GitHub authentication failed"**: 
- Run `gh auth login` to authenticate
- Verify with `gh auth status`

**"iTerm not responding"**: 
- Restart iTerm MCP server
- Check if `iterm_mcp_server` is running: `ps aux | grep iterm_mcp_server`

### Verification Steps

#### 1. Repository Structure
```bash
ls ~/Code/Tuvens/
# Expected output:
# tuvens-docs/
# tuvens-client/ 
# tuvens-api/
# hi.events/
# eventsdigest-ai/
```

#### 2. Desktop Setup Script
```bash
ls ~/Code/Tuvens/tuvens-docs/agentic-development/scripts/setup-agent-task-desktop.sh
# Should exist and be executable
```

#### 3. GitHub CLI
```bash
gh auth status
# Should show authenticated status
gh repo view
# Should display repository information
```

#### 4. iTerm MCP Server
```bash
ps aux | grep iterm_mcp_server
# Should show running process
```

## Manual Recovery Steps

If automated workflows fail, you can manually create sessions:

### Using iTerm2 MCP (Claude Desktop):
```bash
open_terminal name="[agent]-session"
execute_command terminal="[agent]-session" command="cd ~/Code/Tuvens/tuvens-docs && ./agentic-development/scripts/setup-agent-task-desktop.sh [agent] \"[task-title]\" \"[task-description]\""
```

### 1. Create GitHub Issue
```bash
cd ~/Code/Tuvens/tuvens-docs
gh issue create --title "Task Title" --body "Task Description" --label "agent-task,agent-name"
```

### 2. Setup Git Worktree
```bash
git worktree add worktrees/agent-name/agent-name/feature/task-name
cd worktrees/agent-name/agent-name/feature/task-name
git checkout -b agent-name/feature/task-name
```

### 3. Launch Claude Code
```bash
claude code
# Then manually load agent context and begin work
# Note: In Claude Code, you can use the built-in /start-session command
```

## System Health Checks

Run these commands to verify system health:

```bash
# Check all repositories exist
ls ~/Code/Tuvens/

# Verify GitHub authentication  
gh auth status

# Check iTerm MCP server
ps aux | grep iterm_mcp_server

# Test desktop setup script
ls -la ~/Code/Tuvens/tuvens-docs/agentic-development/scripts/setup-agent-task-desktop.sh

# Verify git configuration
git config --list | grep user
```

## Getting Help

If troubleshooting steps don't resolve the issue:

1. **System Questions**: Ask "Get vibe-coder to help with system questions in Claude Code"
2. **Agent Issues**: Check [Agent Management](./agent-management.md) documentation
3. **Setup Problems**: Review [Setup Guide](./setup-guide.md) for prerequisites
4. **Session Issues**: Consult [Session Initiation Guide](./start-session.md) for alternatives

## Emergency Recovery

For severe system issues:

1. **Stop all automation**: Kill any running iTerm MCP processes
2. **Manual cleanup**: Remove problematic worktrees with `git worktree remove`
3. **Fresh start**: Re-clone repositories if corrupted
4. **Escalate**: Create GitHub issue with `emergency` label for manual intervention