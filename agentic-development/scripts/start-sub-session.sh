#!/bin/bash

# Start Sub-Session Command
# Creates a sub-session with restricted file access control and coordination with main agents

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}🤖 Starting Sub-Session with File Access Control${NC}"
echo "=================================================="
echo ""

# Check if we're in a main agent session
CURRENT_DIR=$(pwd)
REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || echo "")

if [ -z "$REPO_ROOT" ]; then
    echo -e "${RED}❌ Error: Not in a git repository${NC}"
    exit 1
fi

# Configuration
TRACKING_DIR="$REPO_ROOT/agentic-development/branch-tracking"
SCRIPTS_DIR="$REPO_ROOT/agentic-development/scripts"
LOCKS_FILE="$TRACKING_DIR/.sub-session-locks.json"

# Parse arguments
MAIN_AGENT=""
SUB_AGENT=""
TASK_TITLE=""
ACCESS_MODE="restricted"
ALLOWED_PATHS=""
DENIED_PATHS=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --main-agent)
            MAIN_AGENT="$2"
            shift 2
            ;;
        --sub-agent)
            SUB_AGENT="$2"
            shift 2
            ;;
        --task)
            TASK_TITLE="$2"
            shift 2
            ;;
        --access-mode)
            ACCESS_MODE="$2"
            shift 2
            ;;
        --allow)
            ALLOWED_PATHS="$2"
            shift 2
            ;;
        --deny)
            DENIED_PATHS="$2"
            shift 2
            ;;
        *)
            if [ -z "$MAIN_AGENT" ]; then
                MAIN_AGENT="$1"
            elif [ -z "$SUB_AGENT" ]; then
                SUB_AGENT="$1"
            elif [ -z "$TASK_TITLE" ]; then
                TASK_TITLE="$1"
            fi
            shift
            ;;
    esac
done

# Validate required arguments
if [ -z "$MAIN_AGENT" ] || [ -z "$SUB_AGENT" ] || [ -z "$TASK_TITLE" ]; then
    echo -e "${RED}❌ Error: Missing required arguments${NC}"
    echo ""
    echo "Usage: start-sub-session.sh [options] <main-agent> <sub-agent> <task-title>"
    echo ""
    echo "Required:"
    echo "  main-agent    - Name of the main agent (vibe-coder, backend-dev, etc.)"
    echo "  sub-agent     - Name/role of the sub-agent"
    echo "  task-title    - Description of the sub-task"
    echo ""
    echo "Options:"
    echo "  --access-mode  - Access mode (restricted|expanded|custom) [default: restricted]"
    echo "  --allow        - Comma-separated list of allowed paths"
    echo "  --deny         - Comma-separated list of denied paths"
    echo ""
    echo "Examples:"
    echo "  start-sub-session.sh vibe-coder test-runner \"Run integration tests\""
    echo "  start-sub-session.sh --access-mode expanded backend-dev validator \"Validate API endpoints\""
    echo "  start-sub-session.sh --allow \"docs/,tests/\" frontend-dev component-builder \"Build UI components\""
    exit 1
fi

echo -e "${BLUE}Configuration:${NC}"
echo "  Main Agent: $MAIN_AGENT"
echo "  Sub Agent: $SUB_AGENT"
echo "  Task: $TASK_TITLE"
echo "  Access Mode: $ACCESS_MODE"
echo "  Working Directory: $CURRENT_DIR"
echo ""

# Step 1: Detect current main agent session
echo -e "${BLUE}Step 1: Detecting main agent context...${NC}"

CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "HEAD")
CURRENT_REPO=$(basename "$REPO_ROOT")

echo "  Repository: $CURRENT_REPO"
echo "  Branch: $CURRENT_BRANCH"

# Check if main agent is currently in an active session
MAIN_SESSION_ACTIVE=false
if [ -f "$TRACKING_DIR/active-branches.json" ]; then
    MAIN_SESSION_CHECK=$(jq -r --arg repo "$CURRENT_REPO" --arg branch "$CURRENT_BRANCH" '
        .branches[$repo][]? | select(.name == $branch) | .agent
    ' "$TRACKING_DIR/active-branches.json" 2>/dev/null || echo "")
    
    if [ "$MAIN_SESSION_CHECK" = "$MAIN_AGENT" ]; then
        MAIN_SESSION_ACTIVE=true
        echo -e "  ${GREEN}✅ Main agent session detected and active${NC}"
    else
        echo -e "  ${YELLOW}⚠️ Main agent session not detected in branch tracking${NC}"
    fi
else
    echo -e "  ${YELLOW}⚠️ Branch tracking not available${NC}"
fi
echo ""

# Step 2: Create sub-session
echo -e "${BLUE}Step 2: Creating sub-session...${NC}"

# Prepare allowed and denied paths arrays
ALLOWED_PATHS_ARRAY=()
DENIED_PATHS_ARRAY=()

if [ -n "$ALLOWED_PATHS" ]; then
    IFS=',' read -ra ALLOWED_PATHS_ARRAY <<< "$ALLOWED_PATHS"
fi

if [ -n "$DENIED_PATHS" ]; then
    IFS=',' read -ra DENIED_PATHS_ARRAY <<< "$DENIED_PATHS"
fi

# Set default paths based on access mode
case "$ACCESS_MODE" in
    "restricted")
        # Very limited access - only docs and temp files
        ALLOWED_PATHS_ARRAY+=("docs/" "README.md" "CLAUDE.md" "/tmp/")
        DENIED_PATHS_ARRAY+=(".git/" ".env" "package-lock.json" "node_modules/" "scripts/setup-" "scripts/cleanup-")
        ;;
    "expanded")
        # Broader access but protect critical files
        ALLOWED_PATHS_ARRAY+=("docs/" "src/" "tests/" "README.md" "CLAUDE.md")
        DENIED_PATHS_ARRAY+=(".git/" ".env" "package-lock.json" "scripts/setup-" "scripts/cleanup-")
        ;;
    "custom")
        # Use only what was explicitly provided
        ;;
esac

# Convert arrays to comma-separated strings for the manager script
ALLOWED_PATHS_STR=$(IFS=','; echo "${ALLOWED_PATHS_ARRAY[*]}")
DENIED_PATHS_STR=$(IFS=','; echo "${DENIED_PATHS_ARRAY[*]}")

# Create the sub-session
echo "  Creating sub-session with file access controls..."
SUB_SESSION_RESULT=$(node "$SCRIPTS_DIR/sub-session-manager.js" create-session \
    "$MAIN_AGENT" \
    "$SUB_AGENT" \
    "$TASK_TITLE" \
    "$ACCESS_MODE" \
    "$ALLOWED_PATHS_STR" \
    "$DENIED_PATHS_STR" 2>/dev/null)

if [ $? -eq 0 ]; then
    SESSION_ID=$(echo "$SUB_SESSION_RESULT" | jq -r '.sessionId')
    echo -e "  ${GREEN}✅ Sub-session created: $SESSION_ID${NC}"
else
    echo -e "  ${RED}❌ Failed to create sub-session${NC}"
    exit 1
fi
echo ""

# Step 3: Setup sub-session workspace
echo -e "${BLUE}Step 3: Setting up sub-session workspace...${NC}"

# Create sub-session workspace directory
SUB_SESSION_DIR="$REPO_ROOT/sub-sessions/$SESSION_ID"
mkdir -p "$SUB_SESSION_DIR"

# Create session info file
cat > "$SUB_SESSION_DIR/.session-info.json" << EOF
{
  "sessionId": "$SESSION_ID",
  "mainAgent": "$MAIN_AGENT",
  "subAgent": "$SUB_AGENT",
  "taskTitle": "$TASK_TITLE",
  "accessMode": "$ACCESS_MODE",
  "workspaceDir": "$SUB_SESSION_DIR",
  "parentRepo": "$CURRENT_REPO",
  "parentBranch": "$CURRENT_BRANCH",
  "createdAt": "$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")"
}
EOF

# Create session ID file for easy detection
echo "$SESSION_ID" > "$SUB_SESSION_DIR/.sub-session-id"

# Create session environment file
cat > "$SUB_SESSION_DIR/.env-sub-session" << EOF
# Sub-Session Environment
SUB_SESSION_ID=$SESSION_ID
CLAUDE_SUB_SESSION=true
SUB_AGENT_MODE=true
MAIN_AGENT=$MAIN_AGENT
SUB_AGENT=$SUB_AGENT
ACCESS_MODE=$ACCESS_MODE
WORKSPACE_DIR=$SUB_SESSION_DIR
PARENT_REPO=$CURRENT_REPO
PARENT_BRANCH=$CURRENT_BRANCH
EOF

echo "  Workspace: $SUB_SESSION_DIR"
echo "  Session info created: .session-info.json"
echo "  Environment variables: .env-sub-session"
echo ""

# Step 4: Generate Claude prompt for sub-session
echo -e "${BLUE}Step 4: Generating Claude prompt...${NC}"

CLAUDE_PROMPT_FILE="$SUB_SESSION_DIR/claude-prompt.txt"
cat > "$CLAUDE_PROMPT_FILE" << EOF
═══════════════════════════════════════════════════════════════════════════════
SUB-SESSION CLAUDE PROMPT - RESTRICTED FILE ACCESS MODE
═══════════════════════════════════════════════════════════════════════════════

Session ID: $SESSION_ID
Main Agent: $MAIN_AGENT
Sub Agent Role: $SUB_AGENT
Task: $TASK_TITLE
Access Mode: $ACCESS_MODE

🔒 FILE ACCESS CONTROL ACTIVE
==============================

You are running in a SUB-SESSION with RESTRICTED FILE ACCESS. This means:

1. File operations are validated against permission system
2. Some files may require permission requests before access
3. File locks are automatically managed to prevent conflicts
4. Coordination with main agent ($MAIN_AGENT) is enforced

WORKSPACE:
- Working Directory: $SUB_SESSION_DIR
- Parent Repository: $CURRENT_REPO
- Parent Branch: $CURRENT_BRANCH

IMPORTANT COMMANDS:
- Check file access: node agentic-development/scripts/claude-access-validator.js check-file $SESSION_ID <file-path>
- Request permission: node agentic-development/scripts/sub-session-manager.js request-permission $SESSION_ID <file-path> file-access "<justification>"
- Check session status: node agentic-development/scripts/sub-session-manager.js status
- End session: node agentic-development/scripts/sub-session-manager.js end-session $SESSION_ID

WORKFLOW INSTRUCTIONS:
1. Before any file operation, validate access using claude-access-validator.js
2. If access is denied, use the permission request system
3. Focus on your specific sub-task: "$TASK_TITLE"
4. Coordinate with main agent if you need expanded permissions
5. When complete, end the session to release all locks

ALLOWED PATHS (Current):
$(for path in "${ALLOWED_PATHS_ARRAY[@]}"; do echo "  - $path"; done)

DENIED PATHS (Current):
$(for path in "${DENIED_PATHS_ARRAY[@]}"; do echo "  - $path"; done)

START YOUR WORK:
1. Load this prompt in Claude
2. Validate your access permissions for the task
3. Begin focused work on: $TASK_TITLE
4. Request additional permissions only if absolutely necessary

═══════════════════════════════════════════════════════════════════════════════
EOF

echo "  Claude prompt: $CLAUDE_PROMPT_FILE"
echo ""

# Step 5: Update branch tracking with sub-session info
echo -e "${BLUE}Step 5: Updating branch tracking...${NC}"

if [ -f "$TRACKING_DIR/active-branches.json" ]; then
    # Add sub-session info to the current branch
    UPDATED_TRACKING=$(jq --arg repo "$CURRENT_REPO" \
                          --arg branch "$CURRENT_BRANCH" \
                          --arg sessionId "$SESSION_ID" \
                          --arg subAgent "$SUB_AGENT" \
                          --arg taskTitle "$TASK_TITLE" \
                          '
        if .branches[$repo] then
            .branches[$repo] = [
                .branches[$repo][] |
                if .name == $branch then
                    .subSessions = (.subSessions // []) + [{
                        sessionId: $sessionId,
                        subAgent: $subAgent,
                        taskTitle: $taskTitle,
                        startTime: now | strftime("%Y-%m-%dT%H:%M:%S.%3NZ"),
                        status: "active"
                    }] |
                    .lastActivity = now | strftime("%Y-%m-%dT%H:%M:%S.%3NZ")
                else
                    .
                end
            ]
        else
            .
        end |
        .lastUpdated = now | strftime("%Y-%m-%dT%H:%M:%S.%3NZ") |
        .generatedBy = "Sub-Session Manager"
    ' "$TRACKING_DIR/active-branches.json")

    echo "$UPDATED_TRACKING" > "$TRACKING_DIR/active-branches.json"
    echo -e "  ${GREEN}✅ Updated branch tracking with sub-session info${NC}"
else
    echo -e "  ${YELLOW}⚠️ Branch tracking file not found${NC}"
fi
echo ""

# Step 6: Display coordination information
echo -e "${BLUE}Step 6: Coordination Summary${NC}"
echo "----------------------------"

# Show active sessions for coordination awareness
ACTIVE_SESSIONS=$(node "$SCRIPTS_DIR/sub-session-manager.js" status 2>/dev/null | jq -r '.totalActiveSessions' || echo "0")
echo "  Active Sub-Sessions: $ACTIVE_SESSIONS"

# Show related main agent work
if [ -f "$TRACKING_DIR/active-branches.json" ]; then
    RELATED_WORK=$(jq -r --arg agent "$MAIN_AGENT" '
        [.branches[][]? | select(.agent == $agent) | "\(.name) (\(.status))"] | join(", ")
    ' "$TRACKING_DIR/active-branches.json" 2>/dev/null)
    
    if [ -n "$RELATED_WORK" ] && [ "$RELATED_WORK" != "" ]; then
        echo "  $MAIN_AGENT Active Work: $RELATED_WORK"
    fi
fi

echo ""

# Step 7: Final instructions
echo -e "${PURPLE}🚀 Sub-Session Ready${NC}"
echo "==================="
echo ""
echo -e "${GREEN}Next Steps:${NC}"
echo "1. ${BLUE}cd $SUB_SESSION_DIR${NC}"
echo "2. ${BLUE}source .env-sub-session${NC}  # Load session environment"
echo "3. ${BLUE}claude${NC}  # Start Claude with sub-session context"
echo "4. Copy and paste the prompt from: ${BLUE}claude-prompt.txt${NC}"
echo ""
echo -e "${YELLOW}Important Notes:${NC}"
echo "• File access is restricted - validate permissions before operations"
echo "• Use permission request system if you need access to additional files"
echo "• File locks are automatically managed to prevent conflicts"
echo "• End session when complete to release all resources"
echo ""
echo -e "${GREEN}Session Created Successfully!${NC}"
echo "Session ID: ${BLUE}$SESSION_ID${NC}"
echo "Workspace: ${BLUE}$SUB_SESSION_DIR${NC}"
echo ""

# Provide quick reference commands
echo -e "${PURPLE}Quick Reference Commands:${NC}"
echo "• Check session status: ${BLUE}node agentic-development/scripts/sub-session-manager.js status${NC}"
echo "• Check file access: ${BLUE}node agentic-development/scripts/claude-access-validator.js check-file $SESSION_ID <file-path>${NC}"
echo "• Request permission: ${BLUE}node agentic-development/scripts/sub-session-manager.js request-permission $SESSION_ID <file-path> file-access \"<reason>\"${NC}"
echo "• End session: ${BLUE}node agentic-development/scripts/sub-session-manager.js end-session $SESSION_ID${NC}"
echo ""