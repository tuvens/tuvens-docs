#!/bin/bash
# Vibe Coder Orchestration Automation Scripts
# Location: agentic-development/scripts/vibe-coder-orchestration.sh

set -euo pipefail

# Configuration
TUVENS_ROOT="${HOME}/Code/Tuvens"
TRACKING_DIR="${TUVENS_ROOT}/tuvens-docs/agentic-development/branch-tracking"
# Fixed: Use persistent storage instead of /tmp
RESERVATIONS_FILE="${TRACKING_DIR}/active_file_reservations.txt"
SESSION_LOG="${TRACKING_DIR}/active_agent_sessions.txt"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        "ERROR")
            echo -e "${RED}❌ [$timestamp] ERROR: $message${NC}" >&2
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  [$timestamp] WARNING: $message${NC}"
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  [$timestamp] INFO: $message${NC}"
            ;;
        "SUCCESS")
            echo -e "${GREEN}✅ [$timestamp] SUCCESS: $message${NC}"
            ;;
    esac
}

# Cross-platform date function
add_hours_to_date() {
    local hours="$1"
    
    # Check if we're on macOS (BSD) or Linux (GNU)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS/BSD date
        date -v "+${hours}H" '+%Y-%m-%d %H:%M:%S'
    else
        # GNU date
        date -d "+${hours} hours" '+%Y-%m-%d %H:%M:%S'
    fi
}

# Cross-platform sed function
sed_inplace() {
    local pattern="$1"
    local file="$2"
    
    # Check if we're on macOS (BSD) or Linux (GNU)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS/BSD sed requires backup extension
        sed -i '' "$pattern" "$file"
    else
        # GNU sed
        sed -i "$pattern" "$file"
    fi
}

# Initialize tracking files
initialize_tracking() {
    log "INFO" "Initializing Vibe Coder tracking systems"
    
    # Ensure tracking directory exists
    mkdir -p "$TRACKING_DIR"
    
    # Create reservations file if it doesn't exist
    if [[ ! -f "$RESERVATIONS_FILE" ]]; then
        echo "# Active File Reservations - Managed by Vibe Coder" > "$RESERVATIONS_FILE"
        echo "# Format: AGENT|REPOSITORY|FILES|RESERVED_UNTIL|STATUS" >> "$RESERVATIONS_FILE"
    fi
    
    # Create session log if it doesn't exist
    if [[ ! -f "$SESSION_LOG" ]]; then
        echo "# Active Agent Sessions - Managed by Vibe Coder" > "$SESSION_LOG"
        echo "# Format: AGENT|REPOSITORY|BRANCH|TASK|START_TIME|STATUS" >> "$SESSION_LOG"
    fi
    
    log "SUCCESS" "Tracking systems initialized"
}

# Agent identity validation
validate_agent_identity() {
    local agent_name="$1"
    local repository="$2"
    local current_branch="$3"
    local workspace_path="$4"
    
    log "INFO" "Validating agent identity: $agent_name"
    
    # Check if agent is in protected branch
    if [[ "$current_branch" == "dev" ]] || [[ "$current_branch" == "main" ]] || [[ "$current_branch" == "master" ]]; then
        log "ERROR" "Agent $agent_name attempting to work on protected branch: $current_branch"
        echo "🚨 PROTOCOL VIOLATION: Cannot work directly on protected branch"
        echo "🛑 REQUIRED ACTION: Create feature branch following pattern: $agent_name/feature/description"
        return 1
    fi
    
    # Verify branch naming convention
    if [[ ! "$current_branch" =~ ^[a-z-]+/(feature|fix|update|experiment)/ ]]; then
        log "WARN" "Branch name doesn't follow convention: $current_branch"
        echo "⚠️  Branch should follow pattern: [agent]/[type]/[description]"
        echo "📋 Current: $current_branch"
    fi
    
    # Check workspace location
    if [[ "$workspace_path" == *"/worktrees/"* ]]; then
        log "SUCCESS" "Agent in dedicated worktree: $workspace_path"
    else
        log "WARN" "Agent not in dedicated worktree. Consider isolation for parallel work."
    fi
    
    # Verify CLAUDE.md exists
    local repo_path="${TUVENS_ROOT}/$repository"
    if [[ "$workspace_path" == *"/worktrees/"* ]]; then
        repo_path="$workspace_path"
    fi
    
    if [[ ! -f "$repo_path/CLAUDE.md" ]]; then
        log "ERROR" "CLAUDE.md safety file missing in $repo_path"
        echo "🚨 PROTOCOL VIOLATION: CLAUDE.md safety file required"
        return 1
    fi
    
    log "SUCCESS" "Agent identity validation passed for $agent_name"
    return 0
}

# File scope conflict detection
check_file_conflicts() {
    local agent_name="$1"
    local repository="$2"
    shift 2
    local files=("$@")
    
    log "INFO" "Checking file conflicts for agent: $agent_name"
    
    for file in "${files[@]}"; do
        # Fixed: Use exact field matching with grep -F to avoid regex issues
        if grep -Fq "|$repository|$file|" "$RESERVATIONS_FILE" 2>/dev/null; then
            local conflicting_agent=$(grep -F "|$repository|$file|" "$RESERVATIONS_FILE" | head -1 | cut -d'|' -f1)
            if [[ "$conflicting_agent" != "$agent_name" ]]; then
                log "ERROR" "File conflict detected: $file already reserved by $conflicting_agent"
                echo "🚨 FILE CONFLICT: $file"
                echo "📋 Reserved by: $conflicting_agent"
                echo "🛑 Request Vibe Coder arbitration"
                return 1
            fi
        fi
    done
    
    log "SUCCESS" "No file conflicts detected for $agent_name"
    return 0
}

# Reserve files for agent
reserve_files() {
    local agent_name="$1"
    local repository="$2"
    local duration_hours="${3:-4}"
    shift 3
    local files=("$@")
    
    log "INFO" "Reserving files for agent: $agent_name"
    
    # Calculate reservation end time using cross-platform function
    local reservation_end=$(add_hours_to_date "$duration_hours")
    
    # Add reservations
    for file in "${files[@]}"; do
        echo "$agent_name|$repository|$file|$reservation_end|ACTIVE" >> "$RESERVATIONS_FILE"
        log "INFO" "Reserved $file for $agent_name until $reservation_end"
    done
    
    log "SUCCESS" "Files reserved for $agent_name"
}

# Release file reservations
release_file_reservations() {
    local agent_name="$1"
    local repository="$2"
    
    log "INFO" "Releasing file reservations for agent: $agent_name in $repository"
    
    # Remove reservations for this agent and repository
    if [[ -f "$RESERVATIONS_FILE" ]]; then
        grep -v "^$agent_name|$repository|" "$RESERVATIONS_FILE" > "${RESERVATIONS_FILE}.tmp" || true
        mv "${RESERVATIONS_FILE}.tmp" "$RESERVATIONS_FILE"
    fi
    
    log "SUCCESS" "File reservations released for $agent_name"
}

# Start agent session
start_agent_session() {
    local agent_name="$1"
    local repository="$2"
    local branch_name="$3"
    local task_description="$4"
    
    log "INFO" "Starting agent session: $agent_name on $repository"
    
    local start_time=$(date '+%Y-%m-%d %H:%M:%S')
    echo "$agent_name|$repository|$branch_name|$task_description|$start_time|ACTIVE" >> "$SESSION_LOG"
    
    # Display session information
    echo "🚀 AGENT SESSION STARTED"
    echo "Agent: $agent_name"
    echo "Repository: $repository"
    echo "Branch: $branch_name"
    echo "Task: $task_description"
    echo "Started: $start_time"
    echo "Status: ACTIVE"
    
    log "SUCCESS" "Agent session started for $agent_name"
}

# End agent session
end_agent_session() {
    local agent_name="$1"
    local repository="$2"
    
    log "INFO" "Ending agent session: $agent_name on $repository"
    
    # Update session status using cross-platform sed
    if [[ -f "$SESSION_LOG" ]]; then
        sed_inplace "s/^$agent_name|$repository|.*|ACTIVE$/$agent_name|$repository|.*|COMPLETED|$(date '+%Y-%m-%d %H:%M:%S')/g" "$SESSION_LOG"
    fi
    
    # Release file reservations
    release_file_reservations "$agent_name" "$repository"
    
    log "SUCCESS" "Agent session ended for $agent_name"
}

# Independent work validation
validate_agent_work() {
    local agent_name="$1"
    local repository="$2"
    local branch_name="$3"
    local issue_number="${4:-}"
    
    log "INFO" "Starting independent validation of work by $agent_name"
    
    # Determine work location
    local work_path="${TUVENS_ROOT}/$repository"
    local worktree_path="${work_path}/worktrees/$branch_name"
    
    if [[ -d "$worktree_path" ]]; then
        work_path="$worktree_path"
        log "INFO" "Validating in worktree: $work_path"
    else
        cd "$work_path"
        git checkout "$branch_name" 2>/dev/null || {
            log "ERROR" "Could not checkout branch $branch_name in $work_path"
            return 1
        }
        log "INFO" "Validating in main repo on branch: $branch_name"
    fi
    
    cd "$work_path"
    
    # Validation steps
    local validation_passed=true
    
    echo "🔍 VIBE CODER INDEPENDENT VALIDATION"
    echo "Agent: $agent_name"
    echo "Repository: $repository"
    echo "Branch: $branch_name"
    echo "Location: $work_path"
    
    # Test execution
    echo "🧪 Running tests..."
    if command -v npm &> /dev/null && [[ -f "package.json" ]]; then
        if npm test; then
            log "SUCCESS" "Tests passed"
        else
            log "ERROR" "Tests failed"
            validation_passed=false
        fi
    elif command -v composer &> /dev/null && [[ -f "composer.json" ]]; then
        if composer test 2>/dev/null || php artisan test 2>/dev/null || phpunit 2>/dev/null; then
            log "SUCCESS" "PHP tests passed"
        else
            log "ERROR" "PHP tests failed"
            validation_passed=false
        fi
    else
        log "WARN" "No test runner detected"
    fi
    
    # Code quality check
    echo "🔍 Checking code quality..."
    if command -v npm &> /dev/null && [[ -f "package.json" ]]; then
        if npm run lint 2>/dev/null; then
            log "SUCCESS" "Linting passed"
        else
            log "WARN" "Linting issues detected"
        fi
    fi
    
    # Security scan
    echo "🔒 Security scan..."
    if command -v npm &> /dev/null && [[ -f "package.json" ]]; then
        if npm audit --audit-level high; then
            log "SUCCESS" "Security scan passed"
        else
            log "WARN" "Security vulnerabilities detected"
        fi
    fi
    
    # Change analysis
    echo "📋 Analyzing changes..."
    local changed_files=$(git diff --name-only HEAD~1 HEAD 2>/dev/null || echo "No changes detected")
    echo "Files changed: $changed_files"
    
    # CLAUDE.md compliance
    if [[ -f "CLAUDE.md" ]]; then
        log "SUCCESS" "CLAUDE.md compliance maintained"
    else
        log "ERROR" "CLAUDE.md safety file missing"
        validation_passed=false
    fi
    
    # Final validation result
    if $validation_passed; then
        echo "✅ VALIDATION PASSED"
        log "SUCCESS" "Work validation passed for $agent_name"
        return 0
    else
        echo "❌ VALIDATION FAILED"
        log "ERROR" "Work validation failed for $agent_name"
        return 1
    fi
}

# Display active sessions dashboard
show_active_sessions() {
    echo "📊 ACTIVE AGENT SESSIONS DASHBOARD"
    echo "=================================="
    
    if [[ -f "$SESSION_LOG" ]] && [[ -s "$SESSION_LOG" ]]; then
        echo "| Agent | Repository | Branch | Task | Start Time | Status |"
        echo "|-------|------------|--------|------|------------|--------|"
        
        grep -v "^#" "$SESSION_LOG" | grep "ACTIVE" | while IFS='|' read -r agent repo branch task start_time status; do
            # Truncate long values for display
            agent_short="${agent:0:12}"
            repo_short="${repo:0:15}"
            branch_short="${branch:0:20}"
            task_short="${task:0:30}..."
            
            echo "| $agent_short | $repo_short | $branch_short | $task_short | $start_time | $status |"
        done
    else
        echo "No active sessions"
    fi
    
    echo ""
    echo "📁 ACTIVE FILE RESERVATIONS"
    echo "==========================="
    
    if [[ -f "$RESERVATIONS_FILE" ]] && [[ -s "$RESERVATIONS_FILE" ]]; then
        echo "| Agent | Repository | File | Reserved Until | Status |"
        echo "|-------|------------|------|----------------|--------|"
        
        grep -v "^#" "$RESERVATIONS_FILE" | grep "ACTIVE" | while IFS='|' read -r agent repo file until status; do
            # Check if reservation is still valid
            if [[ "$(date)" < "$until" ]]; then
                agent_short="${agent:0:12}"
                repo_short="${repo:0:15}"
                file_short="${file:0:30}..."
                
                echo "| $agent_short | $repo_short | $file_short | $until | $status |"
            fi
        done
    else
        echo "No active file reservations"
    fi
}

# Clean expired reservations
clean_expired_reservations() {
    log "INFO" "Cleaning expired file reservations"
    
    if [[ -f "$RESERVATIONS_FILE" ]]; then
        local current_time=$(date '+%Y-%m-%d %H:%M:%S')
        
        # Create temporary file with only valid reservations
        {
            grep "^#" "$RESERVATIONS_FILE"
            grep -v "^#" "$RESERVATIONS_FILE" | while IFS='|' read -r agent repo file until status; do
                if [[ "$current_time" < "$until" ]]; then
                    echo "$agent|$repo|$file|$until|$status"
                else
                    log "INFO" "Expired reservation: $agent - $file"
                fi
            done
        } > "${RESERVATIONS_FILE}.tmp"
        
        mv "${RESERVATIONS_FILE}.tmp" "$RESERVATIONS_FILE"
    fi
    
    log "SUCCESS" "Expired reservations cleaned"
}

# Main command handler
main() {
    local command="${1:-help}"
    
    case "$command" in
        "init")
            initialize_tracking
            ;;
        "validate-identity")
            if [[ $# -lt 5 ]]; then
                echo "Usage: $0 validate-identity <agent> <repository> <branch> <workspace_path>"
                exit 1
            fi
            validate_agent_identity "$2" "$3" "$4" "$5"
            ;;
        "check-conflicts")
            # Fixed: Correct argument parsing
            if [[ $# -lt 4 ]]; then
                echo "Usage: $0 check-conflicts <agent> <repository> <file1> [file2] [...]"
                exit 1
            fi
            local agent_name="$2"
            local repository="$3"
            shift 3
            check_file_conflicts "$agent_name" "$repository" "$@"
            ;;
        "reserve-files")
            # Fixed: Correct argument parsing
            if [[ $# -lt 5 ]]; then
                echo "Usage: $0 reserve-files <agent> <repository> <duration_hours> <file1> [file2] [...]"
                exit 1
            fi
            local agent_name="$2"
            local repository="$3"
            local duration_hours="$4"
            shift 4
            reserve_files "$agent_name" "$repository" "$duration_hours" "$@"
            ;;
        "release-files")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 release-files <agent> <repository>"
                exit 1
            fi
            release_file_reservations "$2" "$3"
            ;;
        "start-session")
            if [[ $# -lt 5 ]]; then
                echo "Usage: $0 start-session <agent> <repository> <branch> <task_description>"
                exit 1
            fi
            start_agent_session "$2" "$3" "$4" "$5"
            ;;
        "end-session")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 end-session <agent> <repository>"
                exit 1
            fi
            end_agent_session "$2" "$3"
            ;;
        "validate-work")
            if [[ $# -lt 4 ]]; then
                echo "Usage: $0 validate-work <agent> <repository> <branch> [issue_number]"
                exit 1
            fi
            validate_agent_work "$2" "$3" "$4" "${5:-}"
            ;;
        "dashboard")
            show_active_sessions
            ;;
        "cleanup")
            clean_expired_reservations
            ;;
        "help")
            echo "Vibe Coder Orchestration Script"
            echo "==============================="
            echo "Commands:"
            echo "  init                     - Initialize tracking systems"
            echo "  validate-identity        - Validate agent workspace and identity"
            echo "  check-conflicts          - Check for file conflicts"
            echo "  reserve-files           - Reserve files for agent work"
            echo "  release-files           - Release agent file reservations"
            echo "  start-session           - Start agent work session"
            echo "  end-session             - End agent work session"
            echo "  validate-work           - Independent validation of agent work"
            echo "  dashboard               - Show active sessions and reservations"
            echo "  cleanup                 - Clean expired reservations"
            echo "  help                    - Show this help message"
            ;;
        *)
            echo "Unknown command: $command"
            echo "Use '$0 help' for available commands"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
