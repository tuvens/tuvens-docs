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

# Source shared functions to prevent code duplication and synchronization bugs
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

# Step 1a: Create GitHub issue first (for desktop mode - we need the issue number immediately)
echo "Step 1a: Creating GitHub issue for Claude Desktop mode..."

# Store original arguments for passing to core script
ORIGINAL_ARGS=("$@")

# Parse arguments to extract what we need for GitHub issue creation
AGENT_NAME="$1"
TASK_TITLE="$2"
TASK_DESCRIPTION="$3"
CONTEXT_FILE=""
FILES_TO_EXAMINE=""
SUCCESS_CRITERIA=""

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
            echo "Unknown option: $1"
            usage
            ;;
        *)
            # Assume it's a context file if it exists
            if [[ -f "$1" ]]; then
                CONTEXT_FILE="$1"
            else
                echo "Warning: Context file '$1' not found, ignoring"
            fi
            shift
            ;;
    esac
done

# Use shared function for GitHub issue creation
GITHUB_ISSUE=$(create_github_issue "$AGENT_NAME" "$TASK_TITLE" "$TASK_DESCRIPTION" "$CONTEXT_FILE" "$FILES_TO_EXAMINE" "$SUCCESS_CRITERIA")
echo ""

# Context enhancement reminder for complex tasks (same as core script)
echo "💡 CONTEXT ENHANCEMENT GUIDANCE"
echo "================================"
echo ""

# Check if enhanced context was provided by looking for context indicators
has_context=false
if [[ -n "$CONTEXT_FILE" && -f "$CONTEXT_FILE" ]] || [[ -n "$FILES_TO_EXAMINE" ]] || [[ -n "$SUCCESS_CRITERIA" ]]; then
    has_context=true
fi

if [[ "$has_context" == "true" ]]; then
    echo "✅ Task includes enhanced context (context file, files, or success criteria)"
    echo "   The receiving agent will have comprehensive task information"
else
    echo "📋 For complex tasks requiring detailed analysis or planning:"
    echo ""
    echo "   1. Add a GitHub comment with complete context using this format:"
    echo "      👤 **Identity**: [your-agent-name] (coordinating agent)"  
    echo "      🎯 **Addressing**: $AGENT_NAME"
    echo ""
    echo "      ## Complete Context Analysis"
    echo "      [Include your detailed analysis, findings, and requirements]"
    echo ""
    echo "   2. Include specific implementation guidance, discovered patterns,"
    echo "      file locations, and any complex requirements you've identified"
    echo ""
    echo "   3. Add timeline expectations and coordination notes if relevant"
    echo ""
    echo "   Command to add context comment:"
    echo "   gh issue comment $GITHUB_ISSUE --body-file /path/to/context.md"
    echo ""
    echo "   This prevents the receiving agent from having to rediscover"
    echo "   context that you already have, improving task handoff efficiency."
fi
echo ""

# Export the GitHub issue number for the core script to use
export DESKTOP_GITHUB_ISSUE="$GITHUB_ISSUE"

# Step 1b: Now run the core script with GitHub issue creation disabled and iTerm automation disabled
echo "Step 1b: Running core agent setup (skipping GitHub issue creation and iTerm automation)..."
export CLAUDE_DESKTOP_MODE=true
export SKIP_ITERM_AUTOMATION=true
export SKIP_GITHUB_ISSUE_CREATION=true

# Call the core script with the original arguments
"$SCRIPT_DIR/setup-agent-task.sh" "${ORIGINAL_ARGS[@]}"

# The core script handles everything else - we just need to launch Claude Code at the end
# Agent name and task title are already captured above

# Use shared library functions to get the worktree path
BRANCH_NAME=$(calculate_branch_name "$AGENT_NAME" "$TASK_TITLE")
WORKTREE_PATH=$(get_worktree_path "$BRANCH_NAME")

if [[ -z "$WORKTREE_PATH" ]]; then
    echo "❌ ERROR: Could not determine worktree path for branch $BRANCH_NAME"
    exit 1
fi

PROMPT_FILE="$SCRIPT_DIR/${AGENT_NAME}-prompt.txt"

if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "❌ ERROR: Agent prompt file not found: $PROMPT_FILE"
    exit 1
fi

echo ""
echo "Step 2: Displaying prompt and launching Claude Code..."

# Display the agent context
echo ""
echo "📋 Agent Context:"
echo "================"
echo "• GitHub Issue: #$GITHUB_ISSUE"
echo "• Worktree: $(make_path_portable "$WORKTREE_PATH")"
echo "• Branch: $BRANCH_NAME"
echo ""

# Verify worktree exists before changing to it
if [[ ! -d "$WORKTREE_PATH" ]]; then
    echo "❌ ERROR: Worktree path does not exist: $WORKTREE_PATH"
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