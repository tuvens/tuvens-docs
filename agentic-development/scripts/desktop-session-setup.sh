#!/usr/bin/env bash
# File: desktop-session-setup.sh
# Purpose: Setup agent tasks for Claude Desktop (no iTerm window creation)
# Based on setup-agent-task.sh but removes AppleScript iTerm automation

set -euo pipefail

# Usage function
usage() {
    echo "Usage: $0 <agent_name> <task_title> <task_description> [context_file] [--files=file1,file2] [--success-criteria='criteria']"
    echo ""
    echo "Examples:"
    echo "  Basic usage:"
    echo "    $0 vibe-coder 'API Documentation' 'Create comprehensive API docs'"
    echo ""
    echo "  With context file:"
    echo "    $0 vibe-coder 'Fix Docs' 'Update branching docs' /tmp/task-context.md"
    echo ""
    echo "  Full enhanced usage:"
    echo "    $0 vibe-coder 'Complex Task' 'Description' /tmp/context.md --files='a.md,b.md' --success-criteria='All tests pass'"
    echo ""
    exit 1
}

# Initialize variables
AGENT_NAME=""
TASK_TITLE=""
TASK_DESCRIPTION=""
CONTEXT_FILE=""
FILES_TO_EXAMINE=""
SUCCESS_CRITERIA=""

# Check minimum arguments first
if [[ $# -lt 3 ]]; then
    usage
fi

# Parse required arguments
AGENT_NAME="$1"
TASK_TITLE="$2" 
TASK_DESCRIPTION="$3"

# Parse optional arguments
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
                echo "Warning: Context file '$1' not found"
            fi
            shift
            ;;
    esac
done

# Constants and paths  
REPO_ROOT="$(git rev-parse --show-toplevel)"
SCRIPTS_DIR="$REPO_ROOT/agentic-development/scripts"
AGENT_DIR="$REPO_ROOT/.claude/agents"
BRANCH_TRACKING_DIR="$REPO_ROOT/agentic-development/branch-tracking"

echo "🤖 Setting up $AGENT_NAME agent session..."
echo "📋 Task: $TASK_TITLE"

# Step 1: Environment validation
echo "Step 1: Environment validation..."
if [[ ! -f "$AGENT_DIR/${AGENT_NAME}.md" ]]; then
    echo "❌ ERROR: Agent not found: $AGENT_DIR/${AGENT_NAME}.md"
    echo "Available agents:"
    ls -1 "$AGENT_DIR"/*.md | sed 's|.*/||' | sed 's|\.md$||' | sed 's/^/  /'
    exit 1
fi

# Validate gh CLI
if ! command -v gh &>/dev/null; then
    echo "❌ ERROR: GitHub CLI (gh) not found. Please install it."
    exit 1
fi

echo "✅ Environment validation complete"

# Step 2: Create GitHub issue
echo "Step 2: Creating GitHub issue..."

# Validate files if provided
VALIDATED_FILES=""
if [[ -n "$FILES_TO_EXAMINE" ]]; then
    echo "Validating file references..."
    IFS=',' read -ra FILE_ARRAY <<< "$FILES_TO_EXAMINE"
    for file in "${FILE_ARRAY[@]}"; do
        if [[ -f "$REPO_ROOT/$file" ]]; then
            VALIDATED_FILES="$VALIDATED_FILES- \`$file\`\n"
        else
            echo "⚠️  Warning: File not found: $file"
            VALIDATED_FILES="$VALIDATED_FILES- \`$file\` (⚠️ NOT FOUND)\n"
        fi
    done
fi

# Create comprehensive issue body
ISSUE_BODY="# $TASK_TITLE

**Agent**: $AGENT_NAME  
**Generated**: $(date '+%Y-%m-%d %H:%M:%S')

## Task Description
$TASK_DESCRIPTION"

# Add context if provided
if [[ -n "$CONTEXT_FILE" && -f "$CONTEXT_FILE" ]]; then
    ISSUE_BODY="$ISSUE_BODY

## Context Analysis
\`\`\`
$(cat "$CONTEXT_FILE")
\`\`\`"
fi

# Add files section if provided
if [[ -n "$VALIDATED_FILES" ]]; then
    ISSUE_BODY="$ISSUE_BODY

## Files to Examine
$VALIDATED_FILES"
fi

# Add success criteria if provided
if [[ -n "$SUCCESS_CRITERIA" ]]; then
    ISSUE_BODY="$ISSUE_BODY

## Success Criteria
$SUCCESS_CRITERIA"
fi

# Add standard implementation template
ISSUE_BODY="$ISSUE_BODY

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
- [ ] Issue updated with final results"

# Create the issue
GITHUB_ISSUE=$(gh issue create --title "$TASK_TITLE" --body "$ISSUE_BODY" --label "agent-task,$AGENT_NAME" | grep -o '#[0-9]*' | sed 's/#//')

if [[ -z "$GITHUB_ISSUE" ]]; then
    echo "❌ ERROR: Failed to create GitHub issue"
    exit 1
fi

echo "✅ Created GitHub issue #$GITHUB_ISSUE"

# Step 3: Create worktree and branch
echo "Step 3: Setting up worktree and branch..."

# Generate branch name
SAFE_TITLE=$(echo "$TASK_TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g')
TIMESTAMP=$(date +%Y%m%d-%H%M)
BRANCH_NAME="${AGENT_NAME}/${SAFE_TITLE}-${TIMESTAMP}"
WORKTREE_PATH="$REPO_ROOT/$AGENT_NAME/${SAFE_TITLE}-${TIMESTAMP}"

# Create worktree
echo "Creating worktree at: $WORKTREE_PATH"
git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" dev

if [[ ! -d "$WORKTREE_PATH" ]]; then
    echo "❌ ERROR: Failed to create worktree"
    exit 1
fi

echo "✅ Created worktree: $WORKTREE_PATH"
echo "✅ Created branch: $BRANCH_NAME"

# Step 4: Generate agent prompt
echo "Step 4: Generating agent prompt..."

PROMPT_FILE="$WORKTREE_PATH/.agent-prompt.txt"

# Create enhanced prompt based on existing template
cat > "$PROMPT_FILE" << EOF
═══════════════════════════════════════════════════════════════════════════════
$AGENT_NAME AGENT - GitHub Issue #$GITHUB_ISSUE

Worktree: $WORKTREE_PATH
Branch: $BRANCH_NAME
═══════════════════════════════════════════════════════════════════════════════

INSTRUCTIONS:
1. Type: claude
2. Copy and paste the prompt below

═══════════════════════════════════════════════════════════════════════════════
CLAUDE PROMPT:

I am the $AGENT_NAME agent working on GitHub issue #$GITHUB_ISSUE.

Context Loading:
- Load: .claude/agents/$AGENT_NAME.md
- Load: Implementation reports and workflow documentation
EOF

# Add context file loading if provided
if [[ -n "$CONTEXT_FILE" && -f "$CONTEXT_FILE" ]]; then
    echo "- Load: Context from $CONTEXT_FILE" >> "$PROMPT_FILE"
fi

cat >> "$PROMPT_FILE" << EOF

🚨 CRITICAL: Read GitHub Issue #$GITHUB_ISSUE for complete task context
Use: \`gh issue view $GITHUB_ISSUE\` to get the full problem analysis, requirements, and implementation details.

Task: $TASK_TITLE
Working Directory: $WORKTREE_PATH
Branch: $BRANCH_NAME
EOF

# Add files to examine if provided
if [[ -n "$FILES_TO_EXAMINE" ]]; then
    echo "" >> "$PROMPT_FILE"
    echo "Priority Files to Examine:" >> "$PROMPT_FILE"
    IFS=',' read -ra FILE_ARRAY <<< "$FILES_TO_EXAMINE"
    for file in "${FILE_ARRAY[@]}"; do
        echo "- $file" >> "$PROMPT_FILE"
    done
fi

# Add success criteria if provided
if [[ -n "$SUCCESS_CRITERIA" ]]; then
    echo "" >> "$PROMPT_FILE"
    echo "Success Criteria: $SUCCESS_CRITERIA" >> "$PROMPT_FILE"
fi

cat >> "$PROMPT_FILE" << EOF

The issue contains detailed analysis, specific file references, and success criteria that are essential for completing this task correctly.

Start your work by:
1. Running: \`gh issue view $GITHUB_ISSUE\` to read the full GitHub issue
2. Examining the specified files (if any) to understand current state
3. Following the 6-step agent workflow pattern
4. Updating the GitHub issue with your progress and findings

═══════════════════════════════════════════════════════════════════════════════
EOF

echo "✅ Created agent prompt: $PROMPT_FILE"

# Step 5: Display the prompt (NO iTerm window creation)
echo ""
echo "═══════════════════════════════════════════════════════════════════════════════"
echo "🎯 AGENT PROMPT READY FOR COPY/PASTE"
echo "═══════════════════════════════════════════════════════════════════════════════"
echo ""

# Navigate to worktree and display prompt
cd "$WORKTREE_PATH"
cat "$PROMPT_FILE"

echo ""
echo "🎉 Agent setup COMPLETE!"
echo "========================================"
echo "GitHub Issue: #$GITHUB_ISSUE"
echo "Worktree: $WORKTREE_PATH"  
echo "Branch: $BRANCH_NAME"
echo "Prompt File: $PROMPT_FILE"
echo ""
echo "Next steps:"
echo "1. Copy the prompt above"
echo "2. Type 'claude' to start Claude Code"
echo "3. Paste the prompt to begin agent work"
echo ""
echo "Issue URL: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues/$GITHUB_ISSUE"