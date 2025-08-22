#!/usr/bin/env bash
# File: setup-agent-task-desktop.sh  
# Purpose: Claude Desktop adapter for agent task setup using iTerm2 MCP integration
# 
# This script is a Claude Desktop-specific wrapper around setup-agent-task.sh
# that replaces AppleScript iTerm automation with iTerm2 MCP integration.

set -euo pipefail

# Usage function
usage() {
    echo "Usage: $0 <agent_name> <task_title> <task_description> [context_file] [--files=file1,file2] [--success-criteria='criteria']"
    echo ""
    echo "Claude Desktop adapter for /start-session automation"
    echo "Uses iTerm2 MCP integration instead of AppleScript"
    echo ""
    echo "Examples:"
    echo "  $0 vibe-coder 'API Documentation' 'Create comprehensive API docs'"
    echo "  $0 vibe-coder 'Fix Docs' 'Update branching docs' /tmp/task-context.md"
    echo "  $0 vibe-coder 'Fix Issue' 'Description' --files='file1.md,file2.md'"
    echo ""
    exit 1
}

# Check minimum arguments
if [[ $# -lt 3 ]]; then
    usage
fi

echo "🏢 Claude Desktop Agent Setup (via iTerm2 MCP)"
echo "=============================================="
echo ""

# Function to convert absolute paths to portable format using ~
make_path_portable() {
    local abs_path="$1"
    # Replace user's home directory with ~
    echo "$abs_path" | sed "s|^$HOME|~|"
}

# Step 1: Use existing setup-agent-task.sh for core functionality
# but skip the iTerm automation step
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CORE_SCRIPT="$SCRIPT_DIR/setup-agent-task.sh"

if [[ ! -f "$CORE_SCRIPT" ]]; then
    echo "❌ ERROR: Core setup script not found: $CORE_SCRIPT"
    exit 1
fi

echo "Step 1: Running core agent setup (without iTerm automation)..."

# Create a modified version of the core script that skips iTerm automation
# We'll do this by setting a flag that the core script can check
export CLAUDE_DESKTOP_MODE=true
export SKIP_ITERM_AUTOMATION=true

# Run the core script with all provided arguments
"$CORE_SCRIPT" "$@"

# Capture the essential information we need for MCP automation
AGENT_NAME="$1"
TASK_TITLE="$2"

# Extract branch info that the core script created
SANITIZED_AGENT_NAME=$(echo "$AGENT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
SANITIZED_TASK_TITLE=$(echo "$TASK_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
BRANCH_NAME="$SANITIZED_AGENT_NAME/feature/$SANITIZED_TASK_TITLE"

# Get the actual worktree path from git (don't calculate it ourselves)
# The core script already created the worktree, so query git for the real path
# Use the simple git worktree list format which is more reliable
WORKTREE_PATH=$(git worktree list | grep "\\[$BRANCH_NAME\\]" | awk '{print $1}')

# Fallback: If git worktree list fails, expand any portable paths manually
if [[ -z "$WORKTREE_PATH" ]]; then
    echo "⚠️  Could not find worktree for branch $BRANCH_NAME via git worktree list"
    echo "   Attempting to expand portable path from branch tracking..."
    
    # Try to get the portable path from the prompt file and expand it
    PROMPT_FILE="$SCRIPT_DIR/${AGENT_NAME}-prompt.txt"
    if [[ -f "$PROMPT_FILE" ]]; then
        PORTABLE_PATH=$(grep "Worktree:" "$PROMPT_FILE" | cut -d' ' -f2)
        if [[ "$PORTABLE_PATH" == \~/* ]]; then
            WORKTREE_PATH="${HOME}${PORTABLE_PATH#\~}"
        else
            WORKTREE_PATH="$PORTABLE_PATH"
        fi
    fi
fi

# Final check that we have a valid worktree path
if [[ -z "$WORKTREE_PATH" ]]; then
    echo "❌ ERROR: Could not determine worktree path for branch $BRANCH_NAME"
    echo "   This usually means the core script failed to create the worktree"
    exit 1
fi

PROMPT_FILE="$SCRIPT_DIR/${AGENT_NAME}-prompt.txt"

echo ""
echo "Step 2: Displaying prompt and launching Claude Code..."

# Display the agent prompt directly
echo ""
echo "📋 Agent Context:"
echo "================"
echo "• GitHub Issue: #$(grep -o 'GitHub Issue: #[0-9]\+' "$PROMPT_FILE" | cut -d'#' -f2)"
echo "• Worktree: $(make_path_portable "$WORKTREE_PATH")"
echo "• Branch: $BRANCH_NAME"
echo ""

# Verify worktree exists before changing to it
if [[ ! -d "$WORKTREE_PATH" ]]; then
    echo "❌ ERROR: Worktree path does not exist: $WORKTREE_PATH"
    echo "   This indicates the worktree creation failed."
    exit 1
fi

# Change to the worktree directory
cd "$WORKTREE_PATH" || {
    echo "❌ ERROR: Failed to change to worktree directory: $WORKTREE_PATH"
    exit 1
}
echo "✅ Changed to worktree directory: $(pwd)"
echo ""

# Display the full agent prompt
echo "🎯 COPY THIS PROMPT FOR CLAUDE CODE:"
echo "====================================="
cat "$PROMPT_FILE"
echo ""
echo "====================================="
echo ""

# Launch Claude Code in the current terminal
echo "🚀 Launching Claude Code..."
echo "When Claude Code opens, copy and paste the prompt above."
echo ""

# Verify we can launch claude before exec
if ! command -v claude &> /dev/null; then
    echo "❌ ERROR: 'claude' command not found. Please install Claude Code CLI."
    echo "Current directory: $(pwd)"
    echo "Prompt file location: $PROMPT_FILE"
    exit 1
fi

# Launch claude in the worktree with the agent context ready
exec claude