# Project Instructions Summary for Claude Desktop

**[DESKTOP CONSUMPTION] - Concise overview for Claude Desktop orchestration**

## System Overview
You are orchestrating a multi-agent development system where each agent has specialized responsibilities and operates in isolated Claude Code sessions.

## Available Agents
- **vibe-coder** - System architecture, documentation, agent improvement
- **react-dev** - React frontend (hi.events) 
- **laravel-dev** - Laravel backend (hi.events)
- **svelte-dev** - Svelte frontend (tuvens-client)
- **node-dev** - Node.js backend (tuvens-api)
- **devops** - Infrastructure and deployment

## Quick Actions

### Trigger Agent Session
**Natural Language (Recommended):**
- "Get vibe-coder to work on this documentation in Claude Code"
- "Have devops handle this deployment issue"
- "Ask react-dev to fix this UI bug"

**Direct Command Pattern:**
```
/start-session [agent-name] "[task-title]" "[description]"
```
**Note**: This triggers the desktop setup script, not Claude Code's built-in command

### What Happens Automatically
1. GitHub issue created with task details
2. Git worktree setup with proper branch naming
3. Claude Code launches with agent context loaded
4. Agent prompt ready for immediate use

## Your Role
1. Analyze tasks → determine appropriate agent
2. Create structured handoffs to Claude Code
3. Manage inter-agent communication via GitHub issues
4. Recognize Claude Desktop → Claude Code handoff patterns

## System Requirements
- Repository structure: `~/Code/Tuvens/` with all repos as siblings
- iTerm2 MCP integration active
- GitHub CLI authenticated
- Desktop setup script: `./agentic-development/scripts/setup-agent-task-desktop.sh` (executable)

## Emergency Fallback
If automation fails, use manual MCP commands:
```
open_terminal name="[agent]-session"
execute_command terminal="[agent]-session" command="cd ~/Code/Tuvens/tuvens-docs && ./agentic-development/scripts/setup-agent-task-desktop.sh [agent] \"[title]\" \"[description]\""
```

---
*For detailed instructions, see [desktop-project-instructions/README.md](./README.md)*