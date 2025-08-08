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

# Create issue using temporary file to avoid complex variable expansion
TEMP_BODY_FILE="/tmp/github-issue-body-$$"
cat > "$TEMP_BODY_FILE" << EOF
Agent: $AGENT_NAME
Task: $TASK_TITLE
Description: $TASK_DESCRIPTION

Generated with Claude Code automation
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

# Step 3: Setup worktree
echo "Step 3: Setting up worktree..."
BRANCH_NAME="feature/$(echo "$TASK_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')"

# Determine if we're in tuvens-docs or another repository
if [[ "$(basename "$(pwd)")" == "tuvens-docs" ]]; then
    # We're in tuvens-docs - use agent-specific worktree path
    WORKTREE_PATH="/Users/ciarancarroll/Code/Tuvens/tuvens-docs/$AGENT_NAME/$BRANCH_NAME"
    IS_TUVENS_DOCS=true
else
    # We're in another repository - use repository-specific worktree path
    REPO_NAME="$(basename "$(pwd)")"
    WORKTREE_PATH="/Users/ciarancarroll/Code/Tuvens/$REPO_NAME/$AGENT_NAME/$BRANCH_NAME"
    IS_TUVENS_DOCS=false
fi

# Ensure we're not on the target branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" == "$BRANCH_NAME" ]]; then
    git checkout dev 2>/dev/null || git checkout develop 2>/dev/null || git checkout main
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

# Step 3a: Clone tuvens-docs (if not already in tuvens-docs)
if [[ "$IS_TUVENS_DOCS" == "false" ]]; then
    echo ""
    echo "Step 3a: Setting up tuvens-docs access..."
    cd "$WORKTREE_PATH"
    
    # Clone tuvens-docs for documentation access
    if [[ ! -d "tuvens-docs" ]]; then
        echo "   Cloning tuvens-docs for documentation access..."
        git clone https://github.com/tuvens/tuvens-docs.git tuvens-docs
        echo "✅ Cloned tuvens-docs to worktree"
    else
        echo "   tuvens-docs already exists, updating..."
        cd tuvens-docs && git pull origin main && cd ..
        echo "✅ Updated existing tuvens-docs"
    fi
    
    # Step 3b: Copy .env file from dev worktree
    echo "   Copying .env configuration from dev worktree..."
    DEV_WORKTREE_PATH="/Users/ciarancarroll/Code/Tuvens/$REPO_NAME/dev"
    if [[ -f "$DEV_WORKTREE_PATH/.env" ]]; then
        cp "$DEV_WORKTREE_PATH/.env" "$WORKTREE_PATH/.env"
        echo "✅ Copied .env file from dev worktree"
        # Copy any additional .env files in subdirectories
        find "$DEV_WORKTREE_PATH" -name ".env" -not -path "$DEV_WORKTREE_PATH/.env" | while read env_file; do
            relative_path=${env_file#$DEV_WORKTREE_PATH/}
            target_dir="$WORKTREE_PATH/$(dirname "$relative_path")"
            mkdir -p "$target_dir"
            cp "$env_file" "$target_dir/.env"
            echo "✅ Copied additional .env from $relative_path"
        done
    elif [[ -f "$DEV_WORKTREE_PATH/.env.example" ]]; then
        cp "$DEV_WORKTREE_PATH/.env.example" "$WORKTREE_PATH/.env"
        echo "✅ Copied .env.example as starting point"
        echo "   ⚠️  Remember to update .env with actual values"
    else
        echo "   ⚠️  No .env file found in dev worktree - you may need to create one at $DEV_WORKTREE_PATH/.env"
    fi
    
    cd - > /dev/null
fi
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
- Load: .claude/agents/$(echo "$AGENT_NAME").md
- Load: Implementation reports and workflow documentation

🚨 CRITICAL: Read GitHub Issue #$GITHUB_ISSUE for complete task context
Use: \`gh issue view $GITHUB_ISSUE\` to get the full problem analysis, requirements, and implementation details.

GitHub Issue: #$GITHUB_ISSUE
Task: $TASK_TITLE

Working Directory: $WORKTREE_PATH
Branch: $BRANCH_NAME

IMPORTANT: Start by reading the GitHub issue (#$GITHUB_ISSUE) with \`gh issue view $GITHUB_ISSUE\` to understand the complete context and requirements before proceeding with any work. The issue contains detailed analysis, specific file references, and success criteria that are essential for completing this task correctly.
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
        write text \"claude\"
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