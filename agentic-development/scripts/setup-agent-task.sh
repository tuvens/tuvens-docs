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

# Step 1: Environment validation
echo "Step 1: Environment validation..."
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/validate-environment.sh"
echo ""

# Step 2: Create GitHub issue
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

# Step 4: Create enhanced agent prompt
echo "Step 4: Creating enhanced agent prompt..."
PROMPT_FILE="$SCRIPT_DIR/${AGENT_NAME}-prompt.txt"

cat > "$PROMPT_FILE" << EOF
═══════════════════════════════════════════════════════════════════════════════
$(echo "$AGENT_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' ' ') AGENT - ENHANCED TASK CONTEXT

GitHub Issue: #$GITHUB_ISSUE
Worktree: $WORKTREE_PATH
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

I am the $(echo "$AGENT_NAME" | sed 's/-/ /g' | sed 's/\b\w/\U&/g') agent.

Context Loading:
- Load: .claude/agents/$(echo "$AGENT_NAME").md
- Load: Implementation reports and workflow documentation
EOF

# Add context file loading if provided
if [[ -n "$CONTEXT_FILE" ]]; then
    cat >> "$PROMPT_FILE" << EOF
- Load: Context from $CONTEXT_FILE
EOF
fi

cat >> "$PROMPT_FILE" << EOF

GitHub Issue: #$GITHUB_ISSUE
Task: $TASK_TITLE

Working Directory: $WORKTREE_PATH
Branch: $BRANCH_NAME

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
Start your work by:
1. Reading the comprehensive GitHub issue #$GITHUB_ISSUE for full context
2. Examining the specified files (if any) to understand current state
3. Following the 6-step agent workflow pattern
4. Updating the GitHub issue with your progress and findings

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