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

echo "🏢 Claude Desktop Agent Setup"
echo "=============================="

# Source shared functions to prevent code duplication and synchronization bugs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

# Step 1: Use existing setup-agent-task.sh for core functionality
# but skip the iTerm automation step
CORE_SCRIPT="$SCRIPT_DIR/setup-agent-task.sh"

if [[ ! -f "$CORE_SCRIPT" ]]; then
    echo "❌ ERROR: Core setup script not found: $CORE_SCRIPT"
    exit 1
fi

# Parse arguments
AGENT_NAME="$1"
TASK_TITLE="$2"
TASK_DESCRIPTION="$3"
CONTEXT_FILE=""
FILES_TO_EXAMINE=""
SUCCESS_CRITERIA=""

# Initialize variables that might be referenced later to prevent unbound variable errors
CONTEXT_CONTENT=""
VALIDATED_FILES=""

# Parse optional arguments same way as core script
shift 3
while [[ $# -gt 0 ]]; do
    case $1 in
        --files=*)
            FILES_TO_EXAMINE="${1#*=}"
            shift
            ;;
        --success-criteria=*)
            SUCCESS_CRITERIA="${1#*=}"
            shift
            ;;
        --help|-h)
            usage
            ;;
        -*)
            # Unknown option, skip
            shift
            ;;
        *)
            # Assume it's a context file if it exists
            if [[ -f "$1" ]]; then
                CONTEXT_FILE="$1"
                # Read context content if file exists
                CONTEXT_CONTENT=$(cat "$1" 2>/dev/null || echo "")
            fi
            shift
            ;;
    esac
done

# Set VALIDATED_FILES to FILES_TO_EXAMINE if provided
if [[ -n "$FILES_TO_EXAMINE" ]]; then
    VALIDATED_FILES="$FILES_TO_EXAMINE"
fi

# Step 1a: Create GitHub issue first (for desktop mode)
echo "Creating GitHub issue..."
GITHUB_ISSUE=$(create_github_issue "$AGENT_NAME" "$TASK_TITLE" "$TASK_DESCRIPTION" "$CONTEXT_FILE" "$FILES_TO_EXAMINE" "$SUCCESS_CRITERIA")

# Context enhancement reminder for complex tasks (condensed)
if [[ -z "$CONTEXT_CONTENT" ]] && [[ -z "$VALIDATED_FILES" ]] && [[ -z "$SUCCESS_CRITERIA" ]]; then
    echo ""
    echo "💡 TIP: For complex tasks, add detailed context with:"
    echo "   gh issue comment $GITHUB_ISSUE --body-file /path/to/context.md"
fi

# Export the GitHub issue number for the core script to use in prompt generation
export DESKTOP_GITHUB_ISSUE="$GITHUB_ISSUE"

# Step 1b: Now run the core script with GitHub issue creation disabled
echo "Setting up worktree and agent context..."
export CLAUDE_DESKTOP_MODE=true
export SKIP_ITERM_AUTOMATION=true
export SKIP_GITHUB_ISSUE_CREATION=true

# Run the core script with the properly reconstructed arguments
# Build the arguments array
CORE_ARGS=("$AGENT_NAME" "$TASK_TITLE" "$TASK_DESCRIPTION")

# Add context file if provided
if [[ -n "$CONTEXT_FILE" ]]; then
    CORE_ARGS+=("$CONTEXT_FILE")
fi

# Add optional arguments
if [[ -n "$FILES_TO_EXAMINE" ]]; then
    CORE_ARGS+=("--files=$FILES_TO_EXAMINE")
fi

if [[ -n "$SUCCESS_CRITERIA" ]]; then
    CORE_ARGS+=("--success-criteria=$SUCCESS_CRITERIA")
fi

# Run the core script with the reconstructed arguments (suppress verbose output)
"$CORE_SCRIPT" "${CORE_ARGS[@]}" | grep -E "(✅|❌|⚠️|🎉|GitHub Issue|Worktree|Branch)" || true

# Use shared library functions to prevent duplication and synchronization bugs
BRANCH_NAME=$(calculate_branch_name "$AGENT_NAME" "$TASK_TITLE")

# Get the actual worktree path from git using shared library function
# The core script already created the worktree, so query git for the real path
WORKTREE_PATH=$(get_worktree_path "$BRANCH_NAME")

# Fallback: If git worktree list fails, expand any portable paths manually
if [[ -z "$WORKTREE_PATH" ]]; then
    echo "⚠️  Could not find worktree for branch $BRANCH_NAME via git worktree list"
    echo "   Attempting to expand portable path from branch tracking..."
    
    # Try to get the portable path from the prompt file and expand it
    PROMPT_FILE="$SCRIPT_DIR/${AGENT_NAME}-prompt.txt"
    if [[ -f "$PROMPT_FILE" ]]; then
        PORTABLE_PATH=$(grep "Worktree:" "$PROMPT_FILE" | cut -d' ' -f2)
        WORKTREE_PATH=$(expand_portable_path "$PORTABLE_PATH")
    fi
fi

# Final check that we have a valid worktree path
if [[ -z "$WORKTREE_PATH" ]]; then
    echo "❌ ERROR: Could not determine worktree path for branch $BRANCH_NAME"
    echo "   This usually means the core script failed to create the worktree"
    exit 1
fi

PROMPT_FILE="$SCRIPT_DIR/${AGENT_NAME}-prompt.txt"

# Display clean agent context
echo ""
echo "📋 Agent Context:"
echo "• GitHub Issue: #$GITHUB_ISSUE"
echo "• Worktree: $(make_path_portable "$WORKTREE_PATH")"
echo "• Branch: $BRANCH_NAME"

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

echo ""
echo "🎯 COPY THIS PROMPT FOR CLAUDE CODE:"
echo "====================================="
cat "$PROMPT_FILE"
echo "====================================="
echo ""

# Launch Claude Code
echo "🚀 Launching Claude Code..."

# Check for review safeguards before enabling dangerous mode
CLAUDE_COMMAND="claude"
if check_pr_review_safeguards "$BRANCH_NAME"; then
    echo "✅ No active reviews detected, enabling dangerous mode for faster development"
    CLAUDE_COMMAND="claude --dangerously-skip-permissions"
else
    echo "🔒 Reviews detected, using standard Claude mode for safety"
fi

# Verify we can launch claude before exec
if ! command -v claude &> /dev/null; then
    echo "❌ ERROR: 'claude' command not found. Please install Claude Code CLI."
    echo "Current directory: $(pwd)"
    echo "Prompt file location: $PROMPT_FILE"
    exit 1
fi

echo "Launching: $CLAUDE_COMMAND"
echo ""

# Launch claude in the worktree with the agent context ready
exec $CLAUDE_COMMAND