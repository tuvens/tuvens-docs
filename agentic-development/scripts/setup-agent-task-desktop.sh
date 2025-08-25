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

# Step 1: Use existing setup-agent-task.sh for core functionality
# but skip the iTerm automation step
CORE_SCRIPT="$SCRIPT_DIR/setup-agent-task.sh"

if [[ ! -f "$CORE_SCRIPT" ]]; then
    echo "❌ ERROR: Core setup script not found: $CORE_SCRIPT"
    exit 1
fi

echo "Step 1: Running core agent setup (without iTerm automation)..."

# Step 1a: Create GitHub issue first (for desktop mode)
echo ""
echo "Step 1a: Creating GitHub issue for Claude Desktop mode..."
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
            # Unknown option, skip
            shift
            ;;
        *)
            # Assume it's a context file if it exists
            if [[ -f "$1" ]]; then
                CONTEXT_FILE="$1"
            fi
            shift
            ;;
    esac
done

# Function to validate and format file references (copied from core script)
validate_files() {
    local files_input="$1"
    local validated_files=""
    local invalid_files=""
    
    if [[ -n "$files_input" ]]; then
        IFS=',' read -ra file_array <<< "$files_input"
        for file in "${file_array[@]}"; do
            file=$(echo "$file" | xargs) # trim whitespace
            if [[ -f "$file" ]]; then
                validated_files="${validated_files}- \`$file\`\n"
            else
                invalid_files="${invalid_files}- \`$file\` (NOT FOUND)\n"
            fi
        done
    fi
    
    echo -e "$validated_files"
    if [[ -n "$invalid_files" ]]; then
        echo "⚠️  Warning: Some files not found:"
        echo -e "$invalid_files"
    fi
}

# Create enhanced issue body using temporary file
TEMP_BODY_FILE="/tmp/github-issue-body-desktop-$$"

# Load context from file if provided
CONTEXT_CONTENT=""
if [[ -n "$CONTEXT_FILE" && -f "$CONTEXT_FILE" ]]; then
    echo "📄 Loading context from: $CONTEXT_FILE"
    CONTEXT_CONTENT=$(cat "$CONTEXT_FILE")
fi

# Validate files if provided
VALIDATED_FILES=""
if [[ -n "$FILES_TO_EXAMINE" ]]; then
    echo "📁 Validating file references..."
    VALIDATED_FILES=$(validate_files "$FILES_TO_EXAMINE")
fi

# Create structured issue body (same format as core script)
cat > "$TEMP_BODY_FILE" << EOF
# $TASK_TITLE

**Agent**: $AGENT_NAME  
**Generated**: $(date '+%Y-%m-%d %H:%M:%S')

## Task Description
$TASK_DESCRIPTION

EOF

# Add context section if context file provided
if [[ -n "$CONTEXT_CONTENT" ]]; then
    cat >> "$TEMP_BODY_FILE" << EOF
## Context Analysis
$CONTEXT_CONTENT

EOF
fi

# Add files section if files provided
if [[ -n "$VALIDATED_FILES" ]]; then
    cat >> "$TEMP_BODY_FILE" << EOF
## Files to Examine
$VALIDATED_FILES

EOF
fi

# Add success criteria if provided
if [[ -n "$SUCCESS_CRITERIA" ]]; then
    cat >> "$TEMP_BODY_FILE" << EOF
## Success Criteria
$SUCCESS_CRITERIA

EOF
fi

# Add standard sections for comprehensive context
cat >> "$TEMP_BODY_FILE" << EOF
## Implementation Notes
- Review the task requirements carefully
- Follow the 6-step agent workflow pattern
- Update this issue with progress and findings
- Reference specific files and line numbers in comments

## Validation Checklist
- [ ] Task requirements understood
- [ ] Relevant files identified and examined
- [ ] Solution implemented according to requirements
- [ ] Testing completed (if applicable)
- [ ] Documentation updated (if applicable)
- [ ] Issue updated with final results

---
*Generated with Claude Code automation*
EOF

# Create GitHub issue
echo "   Creating issue: $TASK_TITLE"
ISSUE_URL=$(gh issue create \
    --title "$TASK_TITLE" \
    --body-file "$TEMP_BODY_FILE" \
    --assignee "@me" \
    --label "agent-task,$AGENT_NAME")

GITHUB_ISSUE=$(echo "$ISSUE_URL" | grep -o '[0-9]\+$')
rm -f "$TEMP_BODY_FILE"
echo "✅ Created GitHub issue #$GITHUB_ISSUE"
echo "   URL: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues/$GITHUB_ISSUE"
echo ""

# Context enhancement reminder for complex tasks
echo "💡 CONTEXT ENHANCEMENT GUIDANCE"
echo "================================"
echo ""
if [[ -n "$CONTEXT_CONTENT" ]] || [[ -n "$VALIDATED_FILES" ]] || [[ -n "$SUCCESS_CRITERIA" ]]; then
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

# Export the GitHub issue number for the core script to use in prompt generation
export DESKTOP_GITHUB_ISSUE="$GITHUB_ISSUE"

# Step 1b: Now run the core script with GitHub issue creation disabled
echo "Step 1b: Running core agent setup (without GitHub issue creation and iTerm automation)..."
export CLAUDE_DESKTOP_MODE=true
export SKIP_ITERM_AUTOMATION=true
export SKIP_GITHUB_ISSUE_CREATION=true

# Run the core script with all provided arguments
"$CORE_SCRIPT" "$@"

# AGENT_NAME and TASK_TITLE already captured above

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