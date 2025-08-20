---
allowed-tools: Bash, Write, Read, LS, Grep, Task
description: Create fully automated Claude Code session using setup-agent-task.sh
argument-hint: [agent-name] [optional-task-hint]
---

# Start New Claude Code Session

I'll create a fully automated Claude Code session using the existing `setup-agent-task.sh` script.

## Agent Assignment
Agent: `$ARGUMENTS`

## Automated Session Creation

I will use the enhanced `setup-agent-task.sh` script with iTerm MCP integration:
- Environment validation
- GitHub issue creation with comprehensive templates
- Worktree setup with proper directory structure
- Enhanced agent prompt generation
- **iTerm MCP automation** (uses configured iTerm MCP server)
- Branch tracking integration
- Context file support
- File validation support
- Success criteria definition

After creating the session setup, I will automatically open iTerm with Claude Code using the iTerm MCP bridge.

## Usage Patterns Supported

The script supports multiple usage patterns:

**Basic Usage:**
```bash
./agentic-development/scripts/setup-agent-task.sh <agent> "<task-title>" "<description>"
```

**With Context File:**
```bash
./agentic-development/scripts/setup-agent-task.sh <agent> "<task-title>" "<description>" /path/to/context.md
```

**With File References:**
```bash
./agentic-development/scripts/setup-agent-task.sh <agent> "<task-title>" "<description>" --files="file1.md,file2.js"
```

**Full Enhanced Usage:**
```bash
./agentic-development/scripts/setup-agent-task.sh <agent> "<task-title>" "<description>" context.md --files="a.md,b.md" --success-criteria="All tests pass"
```

## Context Analysis and Execution

Based on the provided arguments (`$ARGUMENTS`) and our conversation context, I will:

1. **Parse Arguments**: Extract the agent name and any task hints
2. **Analyze Context**: Review our recent discussion to understand the specific task
3. **Generate Task Details**: Create appropriate task title and description
4. **Execute Setup**: Call the setup-agent-task.sh script with context-derived parameters

The setup script will be called with the format:
```bash
./agentic-development/scripts/setup-agent-task.sh [agent] "[context-derived-title]" "[context-derived-description]"
```

## iTerm MCP Integration

The setup script now includes automatic iTerm MCP integration:
- If iTerm MCP server is configured, it will be used automatically
- Falls back to AppleScript if MCP is unavailable  
- Provides manual instructions as final fallback

This ensures the session opens in iTerm automatically using your configured MCP server when available.