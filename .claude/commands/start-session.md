---
allowed-tools: Bash, Write, Read, LS, Grep, Task
description: Create fully automated Claude Code session using setup-agent-task.sh
argument-hint: [agent-name] [task-title] [task-description] [options...]
---

# Start New Claude Code Session

I'll create a fully automated Claude Code session using the existing `setup-agent-task.sh` script.

## Agent Assignment
Agent: `$ARGUMENTS`

## Automated Session Creation

I will use the enhanced `setup-agent-task.sh` script which provides:
- Environment validation
- GitHub issue creation with comprehensive templates
- Worktree setup with proper directory structure
- Enhanced agent prompt generation
- iTerm2 automation
- Branch tracking integration
- Context file support
- File validation support
- Success criteria definition

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

## Execution

I'll analyze the conversation context to determine task details and execute the setup-agent-task.sh script with appropriate parameters.

!`./agentic-development/scripts/setup-agent-task.sh $ARGUMENTS`