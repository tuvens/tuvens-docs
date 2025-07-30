#!/usr/bin/env bash
# File: setup-agent-task.sh  
# Purpose: Master script for setting up agent tasks with full validation

set -euo pipefail

# Usage function
usage() {
    echo "Usage: $0 <agent_name> <task_title> <task_description>"
    echo ""
    echo "Example:"
    echo "  $0 vibe-coder 'API Documentation' 'Create comprehensive API docs'"
    echo ""
    exit 1
}

# Check arguments
if [[ $# -ne 3 ]]; then
    usage
fi

AGENT_NAME="$1"
TASK_TITLE="$2"
TASK_DESCRIPTION="$3"

echo "🚀 Setting up agent task: $AGENT_NAME"
echo "========================================"
echo "Task: $TASK_TITLE"
echo "Description: $TASK_DESCRIPTION"
echo ""

# Step 1: Environment validation
echo "Step 1: Environment validation..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/validate-environment.sh"
echo ""

# Step 2: Create GitHub issue
echo "Step 2: Creating GitHub issue..."
ISSUE_BODY="## Agent Assignment
**Agent**: $AGENT_NAME
**Task**: $TASK_TITLE

## Description
$TASK_DESCRIPTION

## Technical Requirements
- [ ] Load agent context from agent-identities.md
- [ ] Create worktree for branch isolation
- [ ] Follow agent-specific workflow pattern
- [ ] Create comprehensive documentation
- [ ] Test and validate solutions

## Success Criteria
- [ ] All deliverables completed
- [ ] Documentation updated
- [ ] Tests passing (if applicable)
- [ ] Code review completed
- [ ] Branch merged to develop

## Agent Workflow
Follow the standard agent workflow:
1. Context Assessment and Planning
2. Agent Coordination Setup  
3. Multi-Agent Workflow Initiation
4. Active Coordination and Monitoring
5. Integration and Quality Assurance
6. Workflow Completion and Knowledge Capture

🤖 Generated with [Claude Code](https://claude.ai/code) - CTO Agent

Co-Authored-By: Claude <noreply@anthropic.com>"

GITHUB_ISSUE=$(gh issue create \
    --title "$TASK_TITLE" \
    --body "$ISSUE_BODY" \
    --assignee "@me" \
    --label "agent-task,$AGENT_NAME" \
    | grep -o '#[0-9]*' | tr -d '#')

echo "✅ Created GitHub issue #$GITHUB_ISSUE"
echo "   URL: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues/$GITHUB_ISSUE"
echo ""

# Step 3: Setup worktree
echo "Step 3: Setting up worktree..."
BRANCH_NAME="feature/$(echo "$TASK_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"
WORKTREE_PATH="/Users/ciarancarroll/code/tuvens/worktrees/tuvens-docs/$AGENT_NAME/$BRANCH_NAME"

# Ensure we're not on the target branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" == "$BRANCH_NAME" ]]; then
    git checkout develop
fi

# Create worktree (remove if exists)
if [[ -d "$WORKTREE_PATH" ]]; then
    echo "   Removing existing worktree..."
    git worktree remove "$WORKTREE_PATH" --force || true
fi

mkdir -p "$(dirname "$WORKTREE_PATH")"
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"
echo "✅ Created worktree: $WORKTREE_PATH"
echo "✅ Created branch: $BRANCH_NAME"
echo ""

# Step 4: Create prompt file
echo "Step 4: Creating agent prompt..."
PROMPT_FILE="$SCRIPT_DIR/${AGENT_NAME}-prompt.txt"

cat > "$PROMPT_FILE" << EOF
═══════════════════════════════════════════════════════════════════════════════
$(echo "$AGENT_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' ' ') AGENT - READY FOR TASK

GitHub Issue: #$GITHUB_ISSUE
Worktree: $WORKTREE_PATH
Branch: $BRANCH_NAME
═══════════════════════════════════════════════════════════════════════════════

INSTRUCTIONS:
1. Type: claude
2. Copy and paste the prompt below

═══════════════════════════════════════════════════════════════════════════════
CLAUDE PROMPT:

I am the $(echo "$AGENT_NAME" | sed 's/-/ /g' | sed 's/\b\w/\U&/g') agent.

Context Loading:
- Load: agent-identities.md ($(echo "$AGENT_NAME" | sed 's/-/ /g') section)
- Load: $(echo "$AGENT_NAME")-spec.md
- Load: Implementation reports and workflow documentation

GitHub Issue: #$GITHUB_ISSUE
Task: $TASK_TITLE

Working Directory: $WORKTREE_PATH
Branch: $BRANCH_NAME

Start your work by analyzing the task requirements and following the 6-step agent workflow pattern.
═══════════════════════════════════════════════════════════════════════════════
EOF

echo "✅ Created agent prompt: $PROMPT_FILE"
echo ""

# Step 5: Create iTerm2 window (macOS only)
if [[ "$OSTYPE" == "darwin"* ]] && command -v osascript &>/dev/null; then
    echo "Step 5: Creating iTerm2 window..."
    
    # Create AppleScript for iTerm2 window
    APPLESCRIPT_CONTENT="
tell application \"iTerm\"
    create window with default profile
    tell current session of current window
        set name to \"$AGENT_NAME Agent\"
        write text \"cd \\\"$WORKTREE_PATH\\\"\"
        write text \"cat \\\"$PROMPT_FILE\\\"\"
        write text \"# Ready for Claude Code session\"
    end tell
end tell"
    
    echo "$APPLESCRIPT_CONTENT" | osascript
    echo "✅ Created iTerm2 window with agent prompt"
    echo ""
else
    echo "Step 5: iTerm2 window creation skipped (not macOS or osascript unavailable)"
    echo "   Manual setup: Open terminal, cd to $WORKTREE_PATH, then cat $PROMPT_FILE"
    echo ""
fi

# Step 6: Final validation
echo "Step 6: Final validation..."
if [[ -d "$WORKTREE_PATH" && -f "$PROMPT_FILE" ]]; then
    echo "✅ Worktree exists and is accessible"
    echo "✅ Prompt file created successfully"
else
    echo "❌ ERROR: Setup validation failed"
    exit 1
fi

echo ""
echo "🎉 Agent setup COMPLETE!"
echo "========================================"
echo "GitHub Issue: #$GITHUB_ISSUE"
echo "Worktree: $WORKTREE_PATH"  
echo "Branch: $BRANCH_NAME"
echo "Prompt File: $PROMPT_FILE"
echo ""
echo "Next steps:"
echo "1. Check the new iTerm2 window (if created)"
echo "2. Follow the prompt instructions to start Claude Code"
echo "3. Begin agent work following the 6-step workflow"
echo ""
echo "Issue URL: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues/$GITHUB_ISSUE"