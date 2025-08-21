#!/bin/bash

# ========================================
# Claude Desktop Agent Task Setup Script
# ========================================
# Adapted from setup-agent-task.sh for Claude Desktop constraints
# Uses iTerm MCP to open terminal, then runs setup within that terminal
# No AppleScript, no direct window creation from script

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Script paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TRACKING_DIR="$REPO_ROOT/agentic-development/branch-tracking"
TEMPLATES_DIR="$REPO_ROOT/agentic-development/templates"
PROMPTS_DIR="$REPO_ROOT/agentic-development/prompts"

# Default values
AGENT_NAME=""
TASK_TITLE=""
TASK_DESCRIPTION=""
CONTEXT_FILE=""
FILES_LIST=""
SUCCESS_CRITERIA=""
MODE="desktop" # Claude Desktop mode

# Function to print colored output
print_step() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️ $1${NC}"
}

print_info() {
    echo -e "${PURPLE}ℹ️ $1${NC}"
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 <agent-name> "<task-title>" "<task-description>" [context-file] [options]

This script prepares a Claude Desktop agent task by:
1. Creating a GitHub issue for task tracking
2. Setting up a Git worktree for isolated development
3. Generating a Claude prompt file
4. Creating a setup script for iTerm MCP execution

Arguments:
    agent-name        Name of the agent (e.g., vibe-coder, backend-dev)
    task-title       Short title for the task
    task-description  Detailed description of what needs to be done
    context-file     Optional: Path to a markdown file with additional context

Options:
    --files="file1.md,file2.js"        Comma-separated list of files to validate
    --success-criteria="criteria"      Success criteria for the task
    --skip-issue                       Skip GitHub issue creation
    --branch-name="name"               Custom branch name (default: auto-generated)

Examples:
    $0 vibe-coder "Fix authentication" "Debug OAuth flow issues"
    $0 backend-dev "Add API endpoint" "Create /users endpoint" context.md
    $0 frontend-dev "Update UI" "Redesign dashboard" --files="App.svelte,Dashboard.svelte"

Note: This script is designed for Claude Desktop and outputs iTerm MCP commands.
EOF
}

# Parse command line arguments
if [ $# -lt 3 ]; then
    show_usage
    exit 1
fi

AGENT_NAME="$1"
TASK_TITLE="$2"
TASK_DESCRIPTION="$3"
shift 3

# Parse optional arguments
SKIP_ISSUE=false
CUSTOM_BRANCH=""

while [ $# -gt 0 ]; do
    case "$1" in
        --files=*)
            FILES_LIST="${1#*=}"
            shift
            ;;
        --success-criteria=*)
            SUCCESS_CRITERIA="${1#*=}"
            shift
            ;;
        --skip-issue)
            SKIP_ISSUE=true
            shift
            ;;
        --branch-name=*)
            CUSTOM_BRANCH="${1#*=}"
            shift
            ;;
        *.md)
            if [ -f "$1" ]; then
                CONTEXT_FILE="$1"
            else
                print_warning "Context file not found: $1"
            fi
            shift
            ;;
        *)
            print_warning "Unknown argument: $1"
            shift
            ;;
    esac
done

# Validate agent name
valid_agents=("vibe-coder" "backend-dev" "frontend-dev" "devops" "mobile-dev" "docs-orchestrator" 
              "svelte-dev" "react-dev" "laravel-dev" "node-dev" "integration-specialist")

if [[ ! " ${valid_agents[@]} " =~ " ${AGENT_NAME} " ]]; then
    print_error "Invalid agent name: $AGENT_NAME"
    echo "Valid agents: ${valid_agents[*]}"
    exit 1
fi

echo ""
echo "========================================"
echo "Claude Desktop Agent Task Setup"
echo "========================================"
echo "Agent: $AGENT_NAME"
echo "Task: $TASK_TITLE"
echo "Mode: Claude Desktop with iTerm MCP"
echo ""

# Step 1: Create GitHub issue (if not skipped)
GITHUB_ISSUE=""
if [ "$SKIP_ISSUE" = false ]; then
    print_step "Step 1: Creating GitHub issue..."
    
    # Create temporary file for issue body
    TEMP_BODY_FILE="/tmp/github-issue-body-$$"
    
    # Build issue body
    cat > "$TEMP_BODY_FILE" << EOF
# $TASK_TITLE

**Agent**: $AGENT_NAME  
**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**Mode**: Claude Desktop

## Task Description
$TASK_DESCRIPTION

EOF
    
    if [ -n "$CONTEXT_FILE" ] && [ -f "$CONTEXT_FILE" ]; then
        cat >> "$TEMP_BODY_FILE" << EOF
## Additional Context
$(cat "$CONTEXT_FILE")

EOF
    fi
    
    if [ -n "$FILES_LIST" ]; then
        echo "## Files to Validate" >> "$TEMP_BODY_FILE"
        IFS=',' read -ra FILES <<< "$FILES_LIST"
        for file in "${FILES[@]}"; do
            echo "- \`$file\`" >> "$TEMP_BODY_FILE"
        done
        echo "" >> "$TEMP_BODY_FILE"
    fi
    
    if [ -n "$SUCCESS_CRITERIA" ]; then
        cat >> "$TEMP_BODY_FILE" << EOF
## Success Criteria
$SUCCESS_CRITERIA

EOF
    fi
    
    cat >> "$TEMP_BODY_FILE" << EOF
## Workflow
1. Review task requirements
2. Implement solution
3. Test changes
4. Update documentation
5. Submit for review

---
*Generated by Claude Desktop workflow adapter*
EOF
    
    # Create the issue
    ISSUE_URL=$(gh issue create \
        --title "[$AGENT_NAME] $TASK_TITLE" \
        --body-file "$TEMP_BODY_FILE" \
        --label "agent:$AGENT_NAME" \
        --label "automated")
    
    GITHUB_ISSUE=$(echo "$ISSUE_URL" | grep -o '[0-9]\+$')
    rm -f "$TEMP_BODY_FILE"
    
    if [ -n "$GITHUB_ISSUE" ]; then
        print_success "Created GitHub issue #$GITHUB_ISSUE"
        echo "   URL: $ISSUE_URL"
    else
        print_error "Failed to create GitHub issue"
        exit 1
    fi
else
    print_step "Step 1: Skipping GitHub issue creation"
    GITHUB_ISSUE="MANUAL"
fi
echo ""

# Step 2: Determine branch name
print_step "Step 2: Determining branch name..."

# Function to sanitize for branch naming
sanitize_for_branch() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-'
}

if [ -n "$CUSTOM_BRANCH" ]; then
    BRANCH_NAME="$CUSTOM_BRANCH"
else
    SANITIZED_AGENT_NAME=$(sanitize_for_branch "$AGENT_NAME")
    SANITIZED_TASK_TITLE=$(sanitize_for_branch "$TASK_TITLE")
    
    if [ "$GITHUB_ISSUE" != "MANUAL" ]; then
        BRANCH_NAME="${SANITIZED_AGENT_NAME}/feature/${SANITIZED_TASK_TITLE}"
    else
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        BRANCH_NAME="${SANITIZED_AGENT_NAME}/desktop-${TIMESTAMP}-${SANITIZED_TASK_TITLE}"
    fi
fi

print_success "Branch name: $BRANCH_NAME"
echo ""

# Step 3: Create worktree
print_step "Step 3: Creating worktree..."

# Determine repository and worktree path (same logic as Claude Code)
REPO_NAME=$(basename "$REPO_ROOT")
WORKTREE_PATH="$REPO_ROOT/worktrees/$SANITIZED_AGENT_NAME/$BRANCH_NAME"

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
print_success "Created worktree: $WORKTREE_PATH"
print_success "Created branch: $BRANCH_NAME"
echo ""

# Step 4: Create enhanced agent prompt (in scripts directory like Claude Code)
print_step "Step 4: Creating enhanced agent prompt..."
PROMPT_FILE="$SCRIPT_DIR/${AGENT_NAME}-prompt.txt"

cat > "$PROMPT_FILE" << EOF
═══════════════════════════════════════════════════════════════════════════════
$(echo "$AGENT_NAME" | tr '[:lower:]' '[:upper:]' | tr '-' ' ') AGENT - DESKTOP SESSION

GitHub Issue: #$GITHUB_ISSUE
Worktree: $WORKTREE_PATH
Branch: $BRANCH_NAME
EOF

if [[ -n "$CONTEXT_FILE" ]]; then
    cat >> "$PROMPT_FILE" << EOF
Context File: $CONTEXT_FILE
EOF
fi

if [[ -n "$FILES_LIST" ]]; then
    cat >> "$PROMPT_FILE" << EOF
Files to Examine: $FILES_LIST
EOF
fi

cat >> "$PROMPT_FILE" << EOF
═══════════════════════════════════════════════════════════════════════════════

INSTRUCTIONS:
1. Type: claude
2. Copy and paste the prompt below

═══════════════════════════════════════════════════════════════════════════════
CLAUDE PROMPT:

I am the $(echo "$AGENT_NAME" | sed 's/-/ /g' | sed 's/\b\w/\U&/g') agent working on issue #$GITHUB_ISSUE.

Context Loading:
- Load: .claude/agents/$(echo "$AGENT_NAME").md
- Load: Implementation reports and workflow documentation
- Load: CLAUDE.md (critical branch targeting and safety rules)
EOF

if [[ -n "$CONTEXT_FILE" ]]; then
    cat >> "$PROMPT_FILE" << EOF
- Load: Context from $CONTEXT_FILE
EOF
fi

cat >> "$PROMPT_FILE" << EOF

🚨 CRITICAL: Read GitHub Issue #$GITHUB_ISSUE for complete task context
Use: \`gh issue view $GITHUB_ISSUE\` to get the full problem analysis, requirements, and implementation details.

Task: $TASK_TITLE
Working Directory: $WORKTREE_PATH
Branch: $BRANCH_NAME

EOF

if [[ -n "$FILES_LIST" ]]; then
    cat >> "$PROMPT_FILE" << EOF
Priority Files to Examine:
$(echo "$FILES_LIST" | tr ',' '\n' | sed 's/^/- /')

EOF
fi

if [[ -n "$SUCCESS_CRITERIA" ]]; then
    cat >> "$PROMPT_FILE" << EOF
Success Criteria:
$SUCCESS_CRITERIA

EOF
fi

cat >> "$PROMPT_FILE" << EOF
Start your work by:
1. Running: \`gh issue view $GITHUB_ISSUE\` to read the full GitHub issue
2. Examining the specified files (if any) to understand current state
3. Following the 6-step agent workflow pattern
4. Updating the GitHub issue with your progress and findings

═══════════════════════════════════════════════════════════════════════════════
EOF

print_success "Created agent prompt: $PROMPT_FILE"
echo ""

# Step 5: Generate setup script for iTerm MCP
print_step "Step 5: Generating iTerm setup script..."

# Create the setup script that will run inside iTerm
SETUP_SCRIPT="$PROMPTS_DIR/desktop-setup-${AGENT_NAME}-$(date +%Y%m%d-%H%M%S).sh"
mkdir -p "$PROMPTS_DIR"

cat > "$SETUP_SCRIPT" << EOF
#!/bin/bash

# This script runs INSIDE the iTerm window opened by MCP
# It navigates to the worktree and starts Claude

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "\${BLUE}========================================\${NC}"
echo -e "\${BLUE}Claude Desktop Agent Session\${NC}"
echo -e "\${BLUE}========================================\${NC}"
echo ""

# Navigate to worktree
cd "$WORKTREE_PATH"
echo -e "\${GREEN}✅ Switched to worktree: $WORKTREE_PATH\${NC}"
echo -e "\${GREEN}✅ Branch: $BRANCH_NAME\${NC}"
echo -e "\${GREEN}✅ Issue: #$GITHUB_ISSUE\${NC}"
echo ""

# Display the prompt
echo -e "\${BLUE}Loading prompt...\${NC}"
echo ""
cat "$PROMPT_FILE"
echo ""

# Start Claude
echo -e "\${GREEN}Starting Claude Code...\${NC}"
claude
EOF

chmod +x "$SETUP_SCRIPT"
print_success "Created setup script: $SETUP_SCRIPT"
echo ""

# Step 6: Display final instructions
echo "========================================"
echo -e "${GREEN}🎉 Claude Desktop Setup Complete!${NC}"
echo "========================================"
echo ""
echo -e "${BLUE}GitHub Issue:${NC} #$GITHUB_ISSUE"
echo -e "${BLUE}Agent:${NC} $AGENT_NAME"
echo -e "${BLUE}Branch:${NC} $BRANCH_NAME"
echo -e "${BLUE}Worktree:${NC} $WORKTREE_PATH"
echo ""
echo -e "${PURPLE}📋 Next Steps for Claude Desktop:${NC}"
echo ""
echo "1. ${GREEN}Use the iTerm MCP tool to open a new terminal window${NC}"
echo ""
echo "2. ${GREEN}In the new terminal, run:${NC}"
echo "   ${BLUE}bash \"$SETUP_SCRIPT\"${NC}"
echo ""
echo "3. ${GREEN}The script will:${NC}"
echo "   - Navigate to the worktree"
echo "   - Display the prompt"
echo "   - Start Claude automatically"
echo ""
echo "4. ${GREEN}Copy and paste the prompt when Claude starts${NC}"
echo ""
echo -e "${YELLOW}📄 Reference Files:${NC}"
echo "   Setup Script: $SETUP_SCRIPT"
echo "   Prompt File: $PROMPT_FILE"
echo ""

if [ "$GITHUB_ISSUE" != "MANUAL" ]; then
    REPO_INFO=$(gh repo view --json nameWithOwner -q .nameWithOwner)
    echo -e "${BLUE}🔗 Issue URL:${NC} https://github.com/$REPO_INFO/issues/$GITHUB_ISSUE"
fi
echo ""
echo -e "${GREEN}Ready for Claude Desktop workflow!${NC}"
