#!/usr/bin/env bash
# File: setup-agent-task.sh  
# Purpose: Master script for setting up agent tasks with full validation

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
    echo "  With file references:"
    echo "    $0 vibe-coder 'Fix Issue' 'Description' --files='file1.md,file2.md'"
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
                echo "Warning: Context file '$1' not found, ignoring"
            fi
            shift
            ;;
    esac
done

echo "🚀 Setting up agent task: $AGENT_NAME"
echo "========================================"
echo "Task: $TASK_TITLE"
echo "Description: $TASK_DESCRIPTION"
[[ -n "$CONTEXT_FILE" ]] && echo "Context File: $CONTEXT_FILE"
[[ -n "$FILES_TO_EXAMINE" ]] && echo "Files to Examine: $FILES_TO_EXAMINE"
[[ -n "$SUCCESS_CRITERIA" ]] && echo "Success Criteria: $SUCCESS_CRITERIA"
echo ""

# Step 1: Environment validation and shared library setup
echo "Step 1: Environment validation and shared library setup..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared functions to prevent code duplication and synchronization bugs
source "$SCRIPT_DIR/shared-functions.sh"

"$SCRIPT_DIR/validate-environment.sh"
echo ""

# Step 2: Create GitHub issue (skip if called from desktop script)
if [[ "${SKIP_GITHUB_ISSUE_CREATION:-false}" == "true" ]]; then
    echo "Step 2: Skipping GitHub issue creation (handled by desktop wrapper)..."
    # Use the issue number provided by desktop script
    GITHUB_ISSUE="${DESKTOP_GITHUB_ISSUE:-TBD}"
    echo ""
else
    echo "Step 2: Creating GitHub issue..."

# Function to validate and format file references
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
TEMP_BODY_FILE="/tmp/github-issue-body-$$"

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

# Create structured issue body
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

# Security and robustness validation for GITHUB_ISSUE
if [[ -z "$GITHUB_ISSUE" ]]; then
    echo "❌ ERROR: Failed to extract GitHub issue number from URL: $ISSUE_URL"
    rm -f "$TEMP_BODY_FILE"
    exit 1
fi

# Additional security validation: ensure GITHUB_ISSUE contains only digits
if ! [[ "$GITHUB_ISSUE" =~ ^[0-9]+$ ]]; then
    echo "❌ ERROR: Invalid GitHub issue number format: $GITHUB_ISSUE"
    echo "   Issue number must contain only digits for security"
    rm -f "$TEMP_BODY_FILE"
    exit 1
fi

rm -f "$TEMP_BODY_FILE"
echo "✅ Created GitHub issue #$GITHUB_ISSUE"
echo "   URL: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues/$GITHUB_ISSUE"
echo ""
fi

# Step 3: Setup worktree
echo "Step 3: Setting up worktree..."
# Use shared library functions to prevent duplication and synchronization bugs
BRANCH_NAME=$(calculate_branch_name "$AGENT_NAME" "$TASK_TITLE")

# Calculate worktree path using shared library function
WORKTREE_PATH=$(calculate_worktree_path "$AGENT_NAME" "$BRANCH_NAME")

# Determine repository type for legacy compatibility
REPO_ROOT=$(git rev-parse --show-toplevel)
REPO_NAME=$(basename "$REPO_ROOT")
if [[ "$REPO_NAME" == "tuvens-docs" ]]; then
    IS_TUVENS_DOCS=true
else
    IS_TUVENS_DOCS=false
fi

# Step 3a: Update branch tracking (local)
echo ""
echo "Step 3a: Updating branch tracking..."
CURRENT_REPO=$(basename "$(pwd)")

# Step 3a1: Enhanced Agent Onboarding - Task Recommendations
TRACKING_DIR="$SCRIPT_DIR/../branch-tracking"
echo "🚀 Enhanced Agent Onboarding"
echo "============================"

# Show current repository activity
if [ -f "$TRACKING_DIR/active-branches.json" ]; then
    CURRENT_BRANCHES=$(jq -r --arg repo "$CURRENT_REPO" '.branches[$repo]? // [] | length' "$TRACKING_DIR/active-branches.json" 2>/dev/null || echo "0")
    TOTAL_BRANCHES=$(jq -r '[.branches[] | length] | add' "$TRACKING_DIR/active-branches.json" 2>/dev/null || echo "0")
    
    echo "📊 Current Activity:"
    echo "   - Active branches in $CURRENT_REPO: $CURRENT_BRANCHES"
    echo "   - Total active branches across all repos: $TOTAL_BRANCHES"
    echo ""
fi

# Check for related task groups and show recommendations
if [ -f "$TRACKING_DIR/task-groups.json" ]; then
    echo "🔍 Checking for task coordination opportunities..."
    
    # Look for existing task groups that might be related using simple keyword matching
    RELATED_GROUPS=$(jq -r --arg title "$(echo "$TASK_TITLE" | tr '[:upper:]' '[:lower:]')" '
        to_entries[] | 
        select(.value.title | ascii_downcase | contains($title)) |
        "\(.key): \(.value.title) (Status: \(.value.status))"
    ' "$TRACKING_DIR/task-groups.json" 2>/dev/null)
    
    if [ -n "$RELATED_GROUPS" ]; then
        echo ""
        echo "📋 Related task groups found:"
        echo "$RELATED_GROUPS"
        echo ""
        echo "💡 Auto-joining first related task group for coordination"
        echo "🤝 Task group coordination will be set up"
        TASK_GROUP_ID=$(echo "$RELATED_GROUPS" | head -n1 | cut -d: -f1)
    else
        echo "   No related task groups found - creating new coordination context"
        TASK_GROUP_ID=$(echo "$TASK_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
    fi
    echo ""
else
    TASK_GROUP_ID=$(echo "$TASK_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
fi

# Show agent-specific recommendations based on current branches
if [ -f "$TRACKING_DIR/active-branches.json" ]; then
    echo "🎯 Agent-specific recommendations for $AGENT_NAME:"
    
    AGENT_BRANCHES=$(jq -r --arg agent "$AGENT_NAME" --arg repo "$CURRENT_REPO" '
        .branches[$repo]? // [] | 
        map(select(.agent == $agent)) | 
        length
    ' "$TRACKING_DIR/active-branches.json" 2>/dev/null || echo "0")
    
    if [ "$AGENT_BRANCHES" -gt 0 ]; then
        echo "   ⚠️  You already have $AGENT_BRANCHES active branch(es) in $CURRENT_REPO"
        echo "   💡 Consider completing existing work before starting new tasks"
        echo ""
        
        # Show current agent branches
        CURRENT_WORK=$(jq -r --arg agent "$AGENT_NAME" --arg repo "$CURRENT_REPO" '
            .branches[$repo]? // [] | 
            map(select(.agent == $agent)) |
            .[] | "   - \(.name) (created: \(.created[0:10]))"
        ' "$TRACKING_DIR/active-branches.json" 2>/dev/null)
        
        if [ -n "$CURRENT_WORK" ]; then
            echo "   Current $AGENT_NAME branches in $CURRENT_REPO:"
            echo "$CURRENT_WORK"
            echo ""
        fi
    else
        echo "   ✅ No active branches for $AGENT_NAME in $CURRENT_REPO - good to start"
        echo ""
    fi
    
    # Show cross-repository coordination opportunities
    CROSS_REPO_WORK=$(jq -r --arg agent "$AGENT_NAME" '
        [.branches[] | .[] | select(.agent == $agent)] | length
    ' "$TRACKING_DIR/active-branches.json" 2>/dev/null || echo "0")
    
    if [ "$CROSS_REPO_WORK" -gt 0 ] && [ "$CROSS_REPO_WORK" != "$AGENT_BRANCHES" ]; then
        echo "   🔗 You have work in other repositories that might benefit from coordination"
        echo ""
    fi
fi

echo "✅ Agent onboarding analysis complete"
echo ""

# Update local branch tracking
if [ -f "$SCRIPT_DIR/update-branch-tracking.js" ]; then
    echo "📊 Updating central branch tracking locally..."
    PORTABLE_WORKTREE_PATH=$(make_path_portable "$WORKTREE_PATH")
    node "$SCRIPT_DIR/update-branch-tracking.js" \
        --action="create" \
        --repository="$CURRENT_REPO" \
        --branch="$BRANCH_NAME" \
        --author="$(git config user.name || echo 'local-user')" \
        --worktree="$PORTABLE_WORKTREE_PATH" \
        --agent="$AGENT_NAME" \
        --task-group="$TASK_GROUP_ID" \
        --issues="$CURRENT_REPO#$GITHUB_ISSUE"
    echo "✅ Updated local branch tracking"
fi

# Ensure we're not on the target branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [[ "$CURRENT_BRANCH" == "$BRANCH_NAME" ]]; then
    git checkout dev 2>/dev/null || git checkout develop 2>/dev/null || git checkout main
fi

# Check if worktree already exists - if so, use it instead of creating new one
if [[ -d "$WORKTREE_PATH" ]]; then
    echo "   Existing worktree found: $WORKTREE_PATH"
    echo "   Using existing worktree instead of creating new one"
    echo "✅ Using existing worktree: $WORKTREE_PATH"
    
    # Check if branch exists and is associated with this worktree
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        echo "✅ Using existing branch: $BRANCH_NAME"
    else
        echo "⚠️  Branch $BRANCH_NAME doesn't exist, but worktree does"
        echo "   This is fine - continuing with existing worktree"
    fi
else
    # Create new worktree since it doesn't exist
    mkdir -p "$(dirname "$WORKTREE_PATH")"
    
    # Remove existing branch if it exists (only if we're creating new worktree)
    if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
        echo "   Removing existing orphaned branch: $BRANCH_NAME"
        git branch -D "$BRANCH_NAME" 2>/dev/null || true
    fi
    
    if git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"; then
        echo "✅ Created worktree: $WORKTREE_PATH"
        echo "✅ Created branch: $BRANCH_NAME"
    else
        echo "❌ ERROR: Failed to create worktree: $WORKTREE_PATH"
        echo "   This may indicate a Git configuration issue"
        exit 1
    fi
fi

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
    if [[ "$REPO_NAME" == "tuvens-docs" ]]; then
        DEV_WORKTREE_PATH="$REPO_ROOT/worktrees/dev"
    else
        PARENT_DIR=$(dirname "$REPO_ROOT")
        DEV_WORKTREE_PATH="$PARENT_DIR/$REPO_NAME/worktrees/dev"
    fi
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

# Step 4: Create enhanced agent prompt
echo "Step 4: Creating enhanced agent prompt..."
PROMPT_FILE="$SCRIPT_DIR/${AGENT_NAME}-prompt.txt"

cat > "$PROMPT_FILE" << EOF
═══════════════════════════════════════════════════════════════════════════════
$(echo "$AGENT_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' ' ') AGENT - ENHANCED TASK CONTEXT

GitHub Issue: #$GITHUB_ISSUE
Worktree: $(make_path_portable "$WORKTREE_PATH")
Branch: $BRANCH_NAME
EOF

# Add context file reference if provided
if [[ -n "$CONTEXT_FILE" ]]; then
    cat >> "$PROMPT_FILE" << EOF
Context File: $CONTEXT_FILE
EOF
fi

# Add file references if provided
if [[ -n "$FILES_TO_EXAMINE" ]]; then
    cat >> "$PROMPT_FILE" << EOF
Files to Examine: $FILES_TO_EXAMINE
EOF
fi

cat >> "$PROMPT_FILE" << EOF
═══════════════════════════════════════════════════════════════════════════════

INSTRUCTIONS:
1. Type: claude
2. Copy and paste the prompt below

═══════════════════════════════════════════════════════════════════════════════
CLAUDE PROMPT:

I am the $(echo "$AGENT_NAME" | sed 's/-/ /g' | sed 's/\b\w/\U&/g') $GITHUB_ISSUE agent.

Context Loading:
- Load: .claude/agents/$(echo "$AGENT_NAME").md
- Load: Implementation reports and workflow documentation
- Load: CLAUDE.md (critical branch targeting and safety rules)
EOF

# Add context file loading if provided
if [[ -n "$CONTEXT_FILE" ]]; then
    cat >> "$PROMPT_FILE" << EOF
- Load: Context from $CONTEXT_FILE
EOF
fi

cat >> "$PROMPT_FILE" << EOF

🚨 CRITICAL: Read GitHub Issue #$GITHUB_ISSUE for complete task context
Use: \`gh issue view $GITHUB_ISSUE\` to get the full problem analysis, requirements, and implementation details.

GitHub Issue: #$GITHUB_ISSUE
Task: $TASK_TITLE

Working Directory: $(make_path_portable "$WORKTREE_PATH")
Branch: $BRANCH_NAME

🔵 MANDATORY: GitHub Comment Standards Protocol
ALL GitHub issue comments MUST use this format:
\`\`\`markdown
👤 **Identity**: $AGENT_NAME
🎯 **Addressing**: [target-agent or @all]

## [Comment Subject]
[Your comment content]

**Status**: [status]
**Next Action**: [next-action]
**Timeline**: [timeline]
\`\`\`

Reference: agentic-development/protocols/github-comment-standards.md

EOF

# Add files to examine if provided
if [[ -n "$FILES_TO_EXAMINE" ]]; then
    cat >> "$PROMPT_FILE" << EOF
Priority Files to Examine:
$(echo "$FILES_TO_EXAMINE" | tr ',' '\n' | sed 's/^/- /')

EOF
fi

# Add success criteria if provided
if [[ -n "$SUCCESS_CRITERIA" ]]; then
    cat >> "$PROMPT_FILE" << EOF
Success Criteria:
$SUCCESS_CRITERIA

EOF
fi

cat >> "$PROMPT_FILE" << EOF
IMPORTANT: Start by reading the GitHub issue (#$GITHUB_ISSUE) with \`gh issue view $GITHUB_ISSUE\` to understand the complete context and requirements before proceeding with any work. The issue contains detailed analysis, specific file references, and success criteria that are essential for completing this task correctly.

Start your work by:
1. Running: \`gh issue view $GITHUB_ISSUE\` to read the full GitHub issue
2. Examining the specified files (if any) to understand current state
3. Following the 6-step agent workflow pattern
4. Updating the GitHub issue with your progress and findings

═══════════════════════════════════════════════════════════════════════════════
EOF

echo "✅ Created agent prompt: $PROMPT_FILE"
echo ""

# Step 5: Create iTerm2 window (Claude Code mode only)
if [[ "${SKIP_ITERM_AUTOMATION:-false}" == "true" ]]; then
    echo "Step 5: iTerm2 window creation skipped (Claude Desktop mode)"
    echo "   iTerm automation will be handled by Claude Desktop MCP integration"
    echo ""
elif [[ "$OSTYPE" == "darwin"* ]] && command -v osascript &>/dev/null; then
    echo "Step 5: Creating iTerm2 window..."
    
    # Enable dangerous mode for faster development workflow
    CLAUDE_COMMAND="claude --dangerously-skip-permissions"
    echo "✅ Enabling dangerous mode for faster development workflow"
    
    # Create AppleScript for iTerm2 window
    # Security note: GITHUB_ISSUE is validated above to contain only digits (^[0-9]+$)
    # This prevents command injection in the AppleScript context
    APPLESCRIPT_CONTENT="
tell application \"iTerm\"
    create window with default profile
    tell current session of current window
        set name to \"$AGENT_NAME #$GITHUB_ISSUE\"
        write text \"cd \\\"$WORKTREE_PATH\\\"\"
        write text \"cat \\\"$PROMPT_FILE\\\"\"
        write text \"$CLAUDE_COMMAND\"
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