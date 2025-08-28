---
allowed-tools: Bash, Write, Read, LS, Grep, Task
description: Create fully automated Claude Code session using setup-agent-task.sh
argument-hint: [agent-name] [task-title] [task-description]
---

# Start New Claude Code Session

I'll create a fully automated Claude Code session using the existing `setup-agent-task.sh` script with complete validation and workflow integration.

## Arguments Provided
`$ARGUMENTS`

## Current Context
- Repository: !`git remote get-url origin | sed 's/.*\///' | sed 's/\.git//'`
- Current branch: !`git branch --show-current`
- Working directory: !`pwd`

## CRITICAL: Load Safety Rules and Workflow
**⚠️ MANDATORY**: I MUST load safety rules and workflow patterns before proceeding.

@CLAUDE.md
@agentic-development/workflows/6-step-agent-workflow.md

## Agent Configuration Loading
I'll validate the agent and load their specific configuration:

@.claude/agents/$1.md

## Argument Parsing and Validation

Let me parse and validate the provided arguments:

!`
# Parse arguments into array
IFS=' ' read -ra ARGS <<< "$ARGUMENTS"
AGENT_NAME="${ARGS[0]:-}"
TASK_TITLE="${ARGS[1]:-}"
TASK_DESCRIPTION="${ARGS[2]:-}"

echo "🔍 Argument Validation:"
echo "Agent: ${AGENT_NAME:-[MISSING]}"
echo "Title: ${TASK_TITLE:-[MISSING]}"
echo "Description: ${TASK_DESCRIPTION:-[MISSING]}"
echo ""

# Validate required arguments
if [[ -z "$AGENT_NAME" ]]; then
    echo "❌ ERROR: Agent name is required"
    echo ""
    echo "Usage: /start-session [agent-name] [task-title] [task-description]"
    echo ""
    echo "Available agents:"
    find .claude/agents -name "*.md" -exec basename {} .md \; 2>/dev/null | sort | sed 's/^/  - /' || echo "  - vibe-coder, devops, react-dev, laravel-dev, svelte-dev, node-dev"
    echo ""
    echo "Example: /start-session devops \"Deploy Pipeline\" \"Set up staging deployment\""
    exit 1
fi

# Validate agent exists
if [[ ! -f ".claude/agents/${AGENT_NAME}.md" ]]; then
    echo "⚠️  WARNING: Agent configuration file not found: .claude/agents/${AGENT_NAME}.md"
    echo "Available agents:"
    find .claude/agents -name "*.md" -exec basename {} .md \; 2>/dev/null | sort | sed 's/^/  - /' || echo "  - vibe-coder, devops, react-dev, laravel-dev, svelte-dev, node-dev"
    echo ""
fi

# Set defaults for missing optional arguments
if [[ -z "$TASK_TITLE" ]]; then
    TASK_TITLE="Agent Task $(date +%Y%m%d-%H%M)"
    echo "📝 Using default task title: $TASK_TITLE"
fi

if [[ -z "$TASK_DESCRIPTION" ]]; then
    TASK_DESCRIPTION="Task assigned to $AGENT_NAME agent via /start-session command"
    echo "📝 Using default description: $TASK_DESCRIPTION"
fi

echo "✅ Arguments validated successfully"
echo ""
`

## Environment Validation

Let me validate the environment is ready for agent task creation:

!`
echo "🔍 Environment Validation:"

# Check if setup-agent-task.sh exists and is executable
if [[ ! -f "agentic-development/scripts/setup-agent-task.sh" ]]; then
    echo "❌ ERROR: setup-agent-task.sh not found"
    exit 1
fi

if [[ ! -x "agentic-development/scripts/setup-agent-task.sh" ]]; then
    echo "❌ ERROR: setup-agent-task.sh is not executable"
    exit 1
fi

# Check git repository status
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ ERROR: Not in a git repository"
    exit 1
fi

# Check GitHub CLI availability
if ! command -v gh &> /dev/null; then
    echo "❌ ERROR: GitHub CLI (gh) is not available"
    exit 1
fi

echo "✅ Environment validation passed"
echo ""
`

## Agent Session Creation

Now I'll execute the setup-agent-task.sh script with the validated arguments:

!`
echo "🚀 Creating agent session..."
echo "Agent: $AGENT_NAME"
echo "Task: $TASK_TITLE"
echo "Description: $TASK_DESCRIPTION"
echo ""

# Execute the setup script with proper quoting and error handling
if ./agentic-development/scripts/setup-agent-task.sh "$AGENT_NAME" "$TASK_TITLE" "$TASK_DESCRIPTION"; then
    echo ""
    echo "🎉 Agent session created successfully!"
    echo ""
    echo "Next steps:"
    echo "1. Check for the new iTerm2 window (should open automatically)"
    echo "2. Follow the agent prompt instructions in the terminal"
    echo "3. Begin work following the 6-step agent workflow"
else
    echo ""
    echo "❌ Failed to create agent session"
    echo "Check the error messages above for details"
    exit 1
fi
`

## Session Completion

The agent session has been set up with:
- ✅ GitHub issue created and assigned
- ✅ Git worktree established with proper branch naming
- ✅ Agent context and prompt generated
- ✅ iTerm2 window launched (if environment supports it)
- ✅ Integration with central branch tracking system

The agent is now ready to begin work following the established 6-step workflow pattern.