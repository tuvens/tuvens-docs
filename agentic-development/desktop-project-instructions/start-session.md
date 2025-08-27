# Session Initiation Guide

← [Back to Main](./README.md)

## 🚀 Quick Start: Trigger Agent Automation

### Method 1: Natural Language (Recommended)
Simply ask in normal conversation:
```
"Get vibe-coder to work on this documentation in Claude Code"
"Have the devops agent handle this deployment issue"
"Ask react-dev to fix this UI bug"
"Let's use Claude Code with laravel-dev for this database task"
"Get Claude Code working on this documentation with vibe coder"
"Have devops set up the CI pipeline in Claude Code"
"Create wiki documentation for the API endpoints"
"Have vibe-coder document the authentication system in the wiki"
"Document the deployment process in the wiki"
```

Claude Desktop will automatically:
1. Recognize your intent and extract the task details
2. Confirm the agent and task with you
3. **Execute iTerm2 MCP commands** to trigger automation
4. Create GitHub issue, setup worktree, and launch Claude Code

### Method 2: Direct Command
**Important Distinction:**
- **Claude Code**: Uses the `/start-session` slash command directly
- **Claude Desktop**: Executes the setup script via iTerm2 MCP

**For Claude Desktop automation, the following patterns trigger the setup script:**

```
# Claude Desktop recognizes these patterns and runs:
# ./agentic-development/scripts/setup-agent-task-desktop.sh
/start-session [agent-name] "[task-title]" "[task-description]"
```

**Examples that trigger Claude Desktop automation:**
```
/start-session vibe-coder "Fix Documentation" "Update API reference docs"
/start-session react-dev UI Bug Fix
/start-session devops Deploy Pipeline Set up CI/CD for staging
/start-session agent-name task description
```

**Important**: In Claude Desktop, these patterns trigger the `setup-agent-task-desktop.sh` script via iTerm2 MCP. This is different from Claude Code's built-in `/start-session` command.

## ⚡ How The Automation Works

When Claude Desktop sees `/start-session` or natural language patterns, it executes:

```bash
# Opens iTerm2 with descriptive name
open_terminal name="[agent-name]-session"

# Runs the desktop setup automation script 
execute_command terminal="[agent-name]-session" command="cd ~/Code/Tuvens/tuvens-docs && ./agentic-development/scripts/setup-agent-task-desktop.sh [agent-name] \"[task-title]\" \"[task-description]\""
```

### What Happens Step-by-Step
1. **GitHub Issue Created** - Task is logged with agent assignment
2. **Git Worktree Setup** - Isolated workspace with proper branch naming
3. **Agent Prompt Generated** - Full context prompt appears in terminal
4. **Claude Code Launches** - Ready for you to paste the prompt and begin work

### 🚀 Automated Session Workflow

**Claude Desktop vs Claude Code:**
- **Claude Code**: Has a built-in `/start-session` slash command
- **Claude Desktop**: Uses iTerm2 MCP to run `setup-agent-task-desktop.sh`

**Claude Desktop triggers automation for patterns like:**
- `/start-session [agent-name] [task-title] [task-description]` 
- Natural language requests mentioning specific agents
- Any request to "use Claude Code" with an agent

**Important**: Claude Desktop executes the desktop setup script, NOT Claude Code's slash command.

### 📋 Manual Fallback (If Automation Fails)

If the automation doesn't work, use manual MCP commands:

**For any agent:**
```
open_terminal name="[agent-name]-session"
execute_command terminal="[agent-name]-session" command="cd ~/Code/Tuvens/tuvens-docs && ./agentic-development/scripts/setup-agent-task-desktop.sh [agent-name] \"[task-title]\" \"[task-description]\""
```

**Example:**
```
open_terminal name="vibe-coder-session"
execute_command terminal="vibe-coder-session" command="cd ~/Code/Tuvens/tuvens-docs && ./agentic-development/scripts/setup-agent-task-desktop.sh vibe-coder \"Documentation Fix\" \"Update API reference\""
```

## Available Agents

Choose the right agent for your task:

- **vibe-coder** - System architecture, documentation, agent improvement
- **react-dev** - React frontend (hi.events)
- **laravel-dev** - Laravel backend (hi.events)
- **svelte-dev** - Svelte frontend (tuvens-client)
- **node-dev** - Node.js backend (tuvens-api)
- **devops** - Infrastructure and deployment

## Cross-Agent Commands
```bash
# Create task for another agent
/create-issue [from-agent] [to-agent] "[Title]" [repository]

# Resolve GitHub issues
/resolve-issue [issue-number]

# Ask questions across repositories  
/ask-question [repository] "[Question]"
```

## ✅ Success Indicators

**You'll know the automation is working when:**
1. Your request triggers iTerm2 to open automatically
2. The terminal shows GitHub issue creation and worktree setup
3. Claude Code launches automatically with the agent context
4. The agent prompt appears ready to copy into Claude Code

**Note**: In Claude Desktop, this happens via the `setup-agent-task-desktop.sh` script, not Claude Code's `/start-session` command

**If any step fails, check the [Setup Guide](./setup-guide.md) and [Troubleshooting](./troubleshooting.md) sections.**

---

*For questions about agent responsibilities or system architecture, ask:*  
`"Get vibe-coder to help with system architecture questions in Claude Code"`

*Or use the manual fallback with the desktop script if needed.*