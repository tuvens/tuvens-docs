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
4. Preparing commands for iTerm MCP execution

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
    
    # Build issue body
    ISSUE_BODY="## Task Description\n$TASK_DESCRIPTION\n\n"
    ISSUE_BODY+="## Agent Assignment\n- **Agent**: $AGENT_NAME\n"
    ISSUE_BODY+="- **Created**: $(date '+%Y-%m-%d %H:%M:%S')\n"
    ISSUE_BODY+="- **Mode**: Claude Desktop\n\n"
    
    if [ -n "$CONTEXT_FILE" ] && [ -f "$CONTEXT_FILE" ]; then
        ISSUE_BODY+="## Additional Context\n$(cat "$CONTEXT_FILE")\n\n"
    fi
    
    if [ -n "$FILES_LIST" ]; then
        ISSUE_BODY+="## Files to Validate\n"
        IFS=',' read -ra FILES <<< "$FILES_LIST"
        for file in "${FILES[@]}"; do
            ISSUE_BODY+="- \`$file\`\n"
        done
        ISSUE_BODY+="\n"
    fi
    
    if [ -n "$SUCCESS_CRITERIA" ]; then
        ISSUE_BODY+="## Success Criteria\n$SUCCESS_CRITERIA\n\n"
    fi
    
    ISSUE_BODY+="## Workflow\n"
    ISSUE_BODY+="1. Review task requirements\n"
    ISSUE_BODY+="2. Implement solution\n"
    ISSUE_BODY+="3. Test changes\n"
    ISSUE_BODY+="4. Update documentation\n"
    ISSUE_BODY+="5. Submit for review\n\n"
    ISSUE_BODY+="---\n"
    ISSUE_BODY+="*Generated by Claude Desktop workflow adapter*"
    
    # Create the issue
    GITHUB_ISSUE=$(gh issue create \
        --title "[$AGENT_NAME] $TASK_TITLE" \
        --body "$ISSUE_BODY" \
        --label "agent:$AGENT_NAME" \
        --label "automated" | \
        grep -oE '[0-9]+$')
    
    if [ -n "$GITHUB_ISSUE" ]; then
        print_success "Created GitHub issue #$GITHUB_ISSUE"
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

if [ -n "$CUSTOM_BRANCH" ]; then
    BRANCH_NAME="$CUSTOM_BRANCH"
else
    # Generate branch name from task title
    SAFE_TASK_TITLE=$(echo "$TASK_TITLE" | \
        tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9-]/-/g' | \
        sed 's/--*/-/g' | \
        sed 's/^-//' | \
        sed 's/-$//' | \
        cut -c1-50)
    
    if [ "$GITHUB_ISSUE" != "MANUAL" ]; then
        BRANCH_NAME="${AGENT_NAME}/issue-${GITHUB_ISSUE}-${SAFE_TASK_TITLE}"
    else
        TIMESTAMP=$(date +%Y%m%d-%H%M%S)
        BRANCH_NAME="${AGENT_NAME}/desktop-${TIMESTAMP}-${SAFE_TASK_TITLE}"
    fi
fi

print_success "Branch name: $BRANCH_NAME"
echo ""

# Step 3: Generate setup script for iTerm execution
print_step "Step 3: Generating iTerm setup script..."

# Determine repository for the agent
case $AGENT_NAME in
    vibe-coder|docs-orchestrator)
        TARGET_REPO="tuvens-docs"
        ;;
    svelte-dev|frontend-dev)
        TARGET_REPO="tuvens-client"
        ;;
    laravel-dev)
        TARGET_REPO="hi.events"
        ;;
    node-dev|backend-dev)
        TARGET_REPO="tuvens-api"
        ;;
    mobile-dev)
        TARGET_REPO="tuvens-mobile"
        ;;
    *)
        TARGET_REPO="tuvens-docs"  # Default
        ;;
esac

# Create the setup script that will run inside iTerm
SETUP_SCRIPT="$PROMPTS_DIR/desktop-setup-${AGENT_NAME}-$(date +%Y%m%d-%H%M%S).sh"
mkdir -p "$PROMPTS_DIR"

cat > "$SETUP_SCRIPT" << 'EOF'
#!/bin/bash

# This script runs INSIDE the iTerm window opened by MCP
# It sets up the worktree and prepares the Claude prompt

set -e

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Claude Desktop Worktree Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

EOF

# Add variables to the setup script
cat >> "$SETUP_SCRIPT" << EOF
# Configuration from desktop-agent-task.sh
AGENT_NAME="$AGENT_NAME"
BRANCH_NAME="$BRANCH_NAME"
TARGET_REPO="$TARGET_REPO"
GITHUB_ISSUE="$GITHUB_ISSUE"
TASK_TITLE="$TASK_TITLE"
TASK_DESCRIPTION="$TASK_DESCRIPTION"
REPO_ROOT="$REPO_ROOT"

EOF

# Add the worktree setup logic
cat >> "$SETUP_SCRIPT" << 'EOF'
# Navigate to repository
cd "$REPO_ROOT" || exit 1

# Get the actual repository name from current directory
ACTUAL_REPO=$(basename "$(pwd)")
echo -e "${GREEN}Working in repository: $ACTUAL_REPO${NC}"

# Determine worktree path
WORKTREE_BASE="$REPO_ROOT/worktrees/$AGENT_NAME"
mkdir -p "$WORKTREE_BASE"
WORKTREE_PATH="$WORKTREE_BASE/$BRANCH_NAME"

# Create the worktree
echo -e "\n${BLUE}Creating worktree...${NC}"
if [ -d "$WORKTREE_PATH" ]; then
    echo -e "${YELLOW}Worktree already exists, removing...${NC}"
    git worktree remove "$WORKTREE_PATH" --force 2>/dev/null || true
fi

# Create new worktree from dev/main
DEFAULT_BRANCH="dev"
if ! git show-ref --verify --quiet "refs/heads/$DEFAULT_BRANCH"; then
    DEFAULT_BRANCH="main"
fi

git worktree add -b "$BRANCH_NAME" "$WORKTREE_PATH" "origin/$DEFAULT_BRANCH"
echo -e "${GREEN}✅ Worktree created at: $WORKTREE_PATH${NC}"

# Navigate to worktree
cd "$WORKTREE_PATH"
echo -e "${GREEN}✅ Switched to worktree directory${NC}"

# Create the Claude prompt file
PROMPT_FILE="$WORKTREE_PATH/claude-prompt.txt"
cat > "$PROMPT_FILE" << 'PROMPT'
═══════════════════════════════════════════════════════════════════════════════
CLAUDE DESKTOP AGENT SESSION
═══════════════════════════════════════════════════════════════════════════════

I am the EOF
echo "$AGENT_NAME" >> "$PROMPT_FILE"
echo " agent working on GitHub issue #" >> "$PROMPT_FILE"
echo "$GITHUB_ISSUE" >> "$PROMPT_FILE"
cat >> "$PROMPT_FILE" << 'PROMPT'
.

Context Loading:
- Load: .claude/agents/EOF
echo "$AGENT_NAME" >> "$PROMPT_FILE"
cat >> "$PROMPT_FILE" << 'PROMPT'
.md
- Load: Relevant workflow and implementation documentation

🚨 CRITICAL: Read GitHub issue #EOF
echo "$GITHUB_ISSUE" >> "$PROMPT_FILE"
cat >> "$PROMPT_FILE" << 'PROMPT'
 for complete task context
Use: `gh issue view EOF
echo "$GITHUB_ISSUE" >> "$PROMPT_FILE"
cat >> "$PROMPT_FILE" << 'PROMPT'
` to get the full problem analysis

Task: EOF
echo "$TASK_TITLE" >> "$PROMPT_FILE"
echo "" >> "$PROMPT_FILE"
echo "Description: $TASK_DESCRIPTION" >> "$PROMPT_FILE"
cat >> "$PROMPT_FILE" << 'PROMPT'

Working Directory: EOF
echo "$WORKTREE_PATH" >> "$PROMPT_FILE"
echo "Branch: $BRANCH_NAME" >> "$PROMPT_FILE"
cat >> "$PROMPT_FILE" << 'PROMPT'


Start your work by:
1. Running: `gh issue view EOF
echo "$GITHUB_ISSUE" >> "$PROMPT_FILE"
cat >> "$PROMPT_FILE" << 'PROMPT'
` to read the full GitHub issue
2. Examining the relevant files and documentation
3. Following the agent workflow pattern for your task
4. Updating the GitHub issue with your progress

═══════════════════════════════════════════════════════════════════════════════
PROMPT

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo -e "${BLUE}Next steps:${NC}"
echo "1. Type: claude"
echo "2. Copy the prompt from: $PROMPT_FILE"
echo "3. Paste into Claude to begin work"
echo ""
echo -e "${GREEN}Worktree: $WORKTREE_PATH${NC}"
echo -e "${GREEN}Branch: $BRANCH_NAME${NC}"
echo -e "${GREEN}Issue: #$GITHUB_ISSUE${NC}"
echo ""
EOF

# Make the setup script executable
chmod +x "$SETUP_SCRIPT"

print_success "Created setup script: $SETUP_SCRIPT"
echo ""

# Step 4: Generate iTerm MCP command
print_step "Step 4: Generating iTerm MCP command..."

# Create the iTerm MCP command file
MCP_COMMAND_FILE="$PROMPTS_DIR/desktop-iterm-command-$(date +%Y%m%d-%H%M%S).txt"

cat > "$MCP_COMMAND_FILE" << EOF
═══════════════════════════════════════════════════════════════════════════════
CLAUDE DESKTOP - iTERM MCP COMMANDS
═══════════════════════════════════════════════════════════════════════════════

Step 1: Open a new iTerm window using the iTerm MCP tool

Step 2: In the opened iTerm window, run this command:

bash "$SETUP_SCRIPT"

This will:
- Create the Git worktree at: $REPO_ROOT/worktrees/$AGENT_NAME/$BRANCH_NAME
- Generate the Claude prompt file
- Prepare the development environment

Step 3: After setup completes, run:

claude

Step 4: Copy and paste the generated prompt to start your agent session

═══════════════════════════════════════════════════════════════════════════════
EOF

print_success "Created MCP command file: $MCP_COMMAND_FILE"
echo ""

# Step 5: Display final instructions
echo "========================================"
echo -e "${GREEN}🎉 Claude Desktop Setup Complete!${NC}"
echo "========================================"
echo ""
echo -e "${BLUE}GitHub Issue:${NC} #$GITHUB_ISSUE"
echo -e "${BLUE}Agent:${NC} $AGENT_NAME"
echo -e "${BLUE}Branch:${NC} $BRANCH_NAME"
echo -e "${BLUE}Target Repository:${NC} $TARGET_REPO"
echo ""
echo -e "${PURPLE}📋 Next Steps for Claude Desktop:${NC}"
echo ""
echo "1. ${GREEN}Use the iTerm MCP tool to open a new terminal window${NC}"
echo ""
echo "2. ${GREEN}In the new terminal, run:${NC}"
echo "   ${BLUE}bash \"$SETUP_SCRIPT\"${NC}"
echo ""
echo "3. ${GREEN}After setup completes, start Claude:${NC}"
echo "   ${BLUE}claude${NC}"
echo ""
echo "4. ${GREEN}Copy and paste the prompt from the generated file${NC}"
echo ""
echo -e "${YELLOW}📄 Reference Files:${NC}"
echo "   Setup Script: $SETUP_SCRIPT"
echo "   MCP Commands: $MCP_COMMAND_FILE"
echo ""

if [ "$GITHUB_ISSUE" != "MANUAL" ]; then
    echo -e "${BLUE}🔗 Issue URL:${NC} https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues/$GITHUB_ISSUE"
fi
echo ""
echo -e "${GREEN}Ready for Claude Desktop workflow!${NC}"
