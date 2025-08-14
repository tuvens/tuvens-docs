#!/bin/bash

# GitHub MCP Protection Script
# Part of Phase 3: Branch Safety Implementation - Orchestration System Development
#
# Purpose: Prevents commits to protected branches via GitHub MCP in Claude Desktop sessions
# Integration: Works with GitHub MCP, Phase 1 System Orchestrator, Phase 2 protocols
# Safety: Automated branch switching, emergency override protocols, session protection

set -e

# Color codes for output formatting
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_NAME="GitHub MCP Protection System"
readonly VERSION="1.0.0"
readonly PROTECTED_BRANCHES=("main" "stage" "test")
readonly VALID_AGENTS=("vibe-coder" "docs-orchestrator" "devops" "laravel-dev" "react-dev" "node-dev" "svelte-dev")
readonly VALID_TASK_TYPES=("feature" "bugfix" "docs" "workflow" "hotfix" "refactor")

# Session tracking directory
readonly SESSION_DIR="${TMPDIR:-/tmp}/github-mcp-protection"
readonly SESSION_FILE="$SESSION_DIR/active-session.json"
readonly PROTECTION_LOG="$SESSION_DIR/protection.log"

# Error exit codes
readonly ERR_PROTECTED_BRANCH_COMMIT=10
readonly ERR_CLAUDE_DESKTOP_VIOLATION=11
readonly ERR_MCP_SAFETY_VIOLATION=12
readonly ERR_EMERGENCY_INTERVENTION=13
readonly ERR_SESSION_CORRUPTION=14

# Utility Functions
log_header() {
    echo ""
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}🛡️  $SCRIPT_NAME v$VERSION${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
}

log_section() {
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}$(printf '%.0s-' {1..50})${NC}"
}

log_success() {
    local message="$1"
    echo -e "${GREEN}✅ $message${NC}"
    log_to_file "SUCCESS" "$message"
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}⚠️  $message${NC}"
    log_to_file "WARNING" "$message"
}

log_error() {
    local message="$1"
    echo -e "${RED}❌ $message${NC}"
    log_to_file "ERROR" "$message"
}

log_info() {
    local message="$1"
    echo -e "${BLUE}ℹ️  $message${NC}"
    log_to_file "INFO" "$message"
}

log_emergency() {
    local message="$1"
    echo -e "${RED}🚨 EMERGENCY: $message${NC}"
    log_to_file "EMERGENCY" "$message"
}

log_to_file() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    # Ensure log directory exists
    mkdir -p "$SESSION_DIR"
    
    # Append to protection log
    echo "[$timestamp] [$level] $message" >> "$PROTECTION_LOG"
}

# Session Management Functions
initialize_session() {
    local agent_name="$1"
    local target_task="$2"
    
    mkdir -p "$SESSION_DIR"
    
    local session_data=$(cat <<EOF
{
  "session_id": "$(date +%s)-$$",
  "agent_name": "$agent_name",
  "target_task": "$target_task",
  "start_time": "$(date -Iseconds)",
  "current_branch": "$(git branch --show-current 2>/dev/null || echo "unknown")",
  "repository": "$(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo "unknown")")",
  "protection_active": true,
  "violations": [],
  "last_check": "$(date -Iseconds)"
}
EOF
)
    
    echo "$session_data" > "$SESSION_FILE"
    log_success "MCP protection session initialized for $agent_name"
}

update_session() {
    local field="$1"
    local value="$2"
    
    if [ ! -f "$SESSION_FILE" ]; then
        log_warning "No active protection session found"
        return 1
    fi
    
    # Update using jq if available, otherwise simple replacement
    if command -v jq >/dev/null 2>&1; then
        local temp_file
        temp_file=$(mktemp)
        jq --arg field "$field" --arg value "$value" '.[$field] = $value | .last_check = now | strftime("%Y-%m-%dT%H:%M:%S%z")' "$SESSION_FILE" > "$temp_file"
        mv "$temp_file" "$SESSION_FILE"
    else
        log_warning "jq not available - using basic session tracking"
    fi
}

get_session_info() {
    local field="$1"
    
    if [ ! -f "$SESSION_FILE" ]; then
        echo "unknown"
        return 1
    fi
    
    if command -v jq >/dev/null 2>&1; then
        jq -r ".${field} // \"unknown\"" "$SESSION_FILE" 2>/dev/null || echo "unknown"
    else
        echo "unknown"
    fi
}

# Core Protection Functions
check_claude_desktop_environment() {
    log_section "🖥️ Claude Desktop Environment Detection"
    
    local claude_indicators=()
    
    # Check for Claude Desktop environment variables
    [ -n "$CLAUDE_DESKTOP_SESSION" ] && claude_indicators+=("CLAUDE_DESKTOP_SESSION environment variable")
    [ -n "$MCP_SERVER_NAME" ] && claude_indicators+=("MCP server detected: $MCP_SERVER_NAME")
    
    # Check for common Claude Desktop process indicators
    if pgrep -f "Claude" >/dev/null 2>&1; then
        claude_indicators+=("Claude process running")
    fi
    
    # Check for MCP-specific environment
    if [ -n "$MCP_TRANSPORT" ] || [ -n "$MCP_CLIENT_ID" ]; then
        claude_indicators+=("MCP transport layer detected")
    fi
    
    # Check current shell and parent processes for Claude Desktop
    local parent_proc
    parent_proc=$(ps -o comm= -p $PPID 2>/dev/null || echo "unknown")
    if [[ "$parent_proc" == *"Claude"* ]]; then
        claude_indicators+=("Parent process: $parent_proc")
    fi
    
    if [ ${#claude_indicators[@]} -gt 0 ]; then
        log_success "Claude Desktop environment detected"
        for indicator in "${claude_indicators[@]}"; do
            log_info "$indicator"
        done
        return 0
    else
        log_info "Standard terminal environment (non-Claude Desktop)"
        return 1
    fi
}

validate_mcp_safety() {
    log_section "🔗 MCP Safety Protocol Check"
    
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "HEAD")
    
    # Check for protected branch access through MCP
    for protected in "${PROTECTED_BRANCHES[@]}"; do
        if [ "$current_branch" = "$protected" ]; then
            log_emergency "MCP attempting to operate on protected branch: $protected"
            echo ""
            echo -e "${RED}🚨 CRITICAL VIOLATION: GitHub MCP Protection Triggered${NC}"
            echo -e "${RED}   Claude Desktop session blocked from protected branch access${NC}"
            echo -e "${RED}   Branch: $current_branch${NC}"
            echo -e "${RED}   Repository: $(basename "$(git rev-parse --show-toplevel 2>/dev/null || echo "unknown")")${NC}"
            echo ""
            
            # Log violation to session
            add_session_violation "MCP_PROTECTED_BRANCH_ACCESS" "$current_branch"
            
            return $ERR_PROTECTED_BRANCH_COMMIT
        fi
    done
    
    log_success "MCP branch access validated - safe branch: $current_branch"
    return 0
}

add_session_violation() {
    local violation_type="$1"
    local details="$2"
    local timestamp=$(date -Iseconds)
    
    local violation_entry=$(cat <<EOF
{
  "type": "$violation_type",
  "details": "$details",
  "timestamp": "$timestamp",
  "action_taken": "block_operation"
}
EOF
)
    
    # Add to session file if jq available
    if command -v jq >/dev/null 2>&1 && [ -f "$SESSION_FILE" ]; then
        local temp_file
        temp_file=$(mktemp)
        jq --argjson violation "$violation_entry" '.violations += [$violation]' "$SESSION_FILE" > "$temp_file"
        mv "$temp_file" "$SESSION_FILE"
    fi
    
    log_to_file "VIOLATION" "$violation_type: $details"
}

perform_automatic_branch_switch() {
    local current_branch="$1"
    local suggested_agent="$2"
    
    log_section "🔄 Automatic Branch Safety Switch"
    
    # Check if we can determine agent from current directory or session
    local agent_name="$suggested_agent"
    if [ -z "$agent_name" ]; then
        agent_name=$(get_session_info "agent_name")
        if [ "$agent_name" = "unknown" ]; then
            agent_name="vibe-coder"  # Default fallback
        fi
    fi
    
    # Generate safe branch name
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local safe_branch="${agent_name}/feature/mcp-safety-switch-${timestamp}"
    
    echo -e "${YELLOW}⚡ Attempting automatic branch switch to protect from MCP violation${NC}"
    log_info "Current unsafe branch: $current_branch"
    log_info "Target safe branch: $safe_branch"
    echo ""
    
    # Check if dev branch exists and switch from there
    if git show-ref --verify --quiet refs/heads/dev; then
        log_info "Switching to dev branch first..."
        if git checkout dev >/dev/null 2>&1; then
            log_success "Switched to dev branch"
        else
            log_error "Failed to switch to dev branch"
            return 1
        fi
    else
        log_warning "No dev branch found - creating feature branch from current position"
    fi
    
    # Create and switch to safe branch
    log_info "Creating safe feature branch: $safe_branch"
    if git checkout -b "$safe_branch" >/dev/null 2>&1; then
        log_success "Successfully switched to safe branch: $safe_branch"
        echo ""
        echo -e "${GREEN}🎉 MCP Protection Applied Successfully${NC}"
        echo -e "${GREEN}   Safe Branch: $safe_branch${NC}"
        echo -e "${GREEN}   Agent can now proceed with work${NC}"
        echo ""
        
        # Update session with new safe branch
        update_session "current_branch" "$safe_branch"
        
        return 0
    else
        log_error "Failed to create safe branch: $safe_branch"
        return 1
    fi
}

check_git_hooks_integration() {
    log_section "🪝 Git Hooks Integration Check"
    
    local hooks_ok=true
    
    # Check for pre-commit hook integration
    if [ -f ".git/hooks/pre-commit" ]; then
        if grep -q "github-mcp-protection" ".git/hooks/pre-commit" 2>/dev/null; then
            log_success "Pre-commit hook integrated with MCP protection"
        else
            log_warning "Pre-commit hook exists but not integrated with MCP protection"
            hooks_ok=false
        fi
    else
        log_warning "No pre-commit hook found"
        hooks_ok=false
    fi
    
    # Check for pre-push hook integration  
    if [ -f ".git/hooks/pre-push" ]; then
        if grep -q "github-mcp-protection" ".git/hooks/pre-push" 2>/dev/null; then
            log_success "Pre-push hook integrated with MCP protection"
        else
            log_warning "Pre-push hook exists but not integrated with MCP protection"
        fi
    else
        log_info "No pre-push hook found (optional for MCP protection)"
    fi
    
    if [ "$hooks_ok" = false ]; then
        echo ""
        echo -e "${YELLOW}🔧 Integration Recommendation:${NC}"
        echo "   Add this script to your git hooks for automatic protection:"
        echo "   echo '#!/bin/bash' > .git/hooks/pre-commit"
        echo "   echo './agentic-development/scripts/github-mcp-protection.sh --pre-commit' >> .git/hooks/pre-commit"
        echo "   chmod +x .git/hooks/pre-commit"
    fi
    
    return 0
}

generate_emergency_override() {
    local override_reason="$1"
    local current_branch="$2"
    
    log_section "🆘 Emergency Override Protocol"
    
    log_emergency "Emergency override requested"
    log_info "Reason: $override_reason"
    log_info "Branch: $current_branch"
    
    local override_token
    local hash_suffix
    if command -v md5sum >/dev/null 2>&1; then
        hash_suffix=$(echo "$override_reason" | md5sum | cut -c1-8)
    elif command -v md5 >/dev/null 2>&1; then
        hash_suffix=$(echo "$override_reason" | md5 | cut -c1-8)
    else
        hash_suffix="FALLBACK"
    fi
    override_token="EMERGENCY_$(date +%s)_${hash_suffix}"
    
    echo ""
    echo -e "${RED}🚨 EMERGENCY OVERRIDE GENERATED${NC}"
    echo -e "${RED}   Token: $override_token${NC}"
    echo -e "${RED}   Reason: $override_reason${NC}"
    echo -e "${RED}   Branch: $current_branch${NC}"
    echo -e "${RED}   Timestamp: $(date -Iseconds)${NC}"
    echo ""
    echo -e "${YELLOW}⚠️  IMPORTANT WARNINGS:${NC}"
    echo "   • Override bypasses all MCP protections"
    echo "   • Use only for genuine emergencies"
    echo "   • Document usage in incident report"
    echo "   • Report to vibe-coder system orchestrator"
    echo ""
    echo -e "${YELLOW}📋 To use override:${NC}"
    echo "   export MCP_EMERGENCY_OVERRIDE=\"$override_token\""
    echo "   # Proceed with emergency operation"
    echo "   unset MCP_EMERGENCY_OVERRIDE"
    echo ""
    
    # Log emergency override
    add_session_violation "EMERGENCY_OVERRIDE_GENERATED" "$override_reason"
    log_to_file "EMERGENCY" "Override token generated: $override_token for reason: $override_reason"
    
    return 0
}

# Command Processing Functions
process_pre_commit_check() {
    log_info "Running pre-commit MCP protection check..."
    
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "HEAD")
    
    # Check for emergency override
    if [ -n "$MCP_EMERGENCY_OVERRIDE" ]; then
        log_warning "Emergency override detected: $MCP_EMERGENCY_OVERRIDE"
        log_warning "Allowing commit to proceed - override active"
        return 0
    fi
    
    # Run MCP safety validation
    if ! validate_mcp_safety; then
        log_error "Pre-commit check failed - commit blocked by MCP protection"
        return $ERR_MCP_SAFETY_VIOLATION
    fi
    
    return 0
}

process_session_init() {
    local agent_name="$1"
    local target_task="$2"
    
    if [ -z "$agent_name" ] || [ -z "$target_task" ]; then
        log_error "Session initialization requires agent name and target task"
        echo "Usage: $0 --init-session [agent-name] [target-task]"
        return 1
    fi
    
    initialize_session "$agent_name" "$target_task"
    
    # Perform initial safety checks
    check_claude_desktop_environment
    validate_mcp_safety
    
    return $?
}

process_safety_check() {
    log_header
    log_info "Running comprehensive MCP safety check..."
    
    local issues=0
    
    # Environment detection
    check_claude_desktop_environment
    
    # MCP safety validation
    validate_mcp_safety || ((issues++))
    
    # Git hooks integration
    check_git_hooks_integration
    
    # Session status
    if [ -f "$SESSION_FILE" ]; then
        local agent_name
        agent_name=$(get_session_info "agent_name")
        log_info "Active protection session: $agent_name"
    else
        log_info "No active protection session"
    fi
    
    # Summary
    echo ""
    if [ $issues -eq 0 ]; then
        log_success "MCP protection system operational - no issues detected"
    else
        log_warning "$issues issue(s) detected - review output above"
    fi
    
    return $issues
}

# Main Function and Command Processing
show_usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION

USAGE:
    $0 [OPTIONS] [COMMAND]

COMMANDS:
    --init-session [agent] [task]  Initialize MCP protection session
    --check                        Run comprehensive safety check
    --pre-commit                   Pre-commit hook integration
    --auto-switch [agent]          Attempt automatic safe branch switch  
    --emergency [reason]           Generate emergency override token
    --session-status               Show active session information

OPTIONS:
    --help                         Show this help message
    --version                      Show version information
    --verbose                      Enable verbose logging

EXAMPLES:
    # Initialize protection for agent session
    $0 --init-session vibe-coder "feature implementation"
    
    # Run safety check
    $0 --check
    
    # Generate emergency override
    $0 --emergency "production hotfix required"
    
    # Pre-commit hook usage
    echo '$0 --pre-commit' >> .git/hooks/pre-commit

For more information, see: agentic-development/docs/branch-safety-guide.md
EOF
}

main() {
    local command=""
    local verbose=false
    local agent_name=""
    local task_description=""
    local emergency_reason=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_usage
                exit 0
                ;;
            --version)
                echo "$SCRIPT_NAME v$VERSION"
                exit 0
                ;;
            --verbose)
                verbose=true
                shift
                ;;
            --init-session)
                command="init-session"
                shift
                agent_name="$1"
                shift
                task_description="$1"
                shift
                ;;
            --check)
                command="check"
                shift
                ;;
            --pre-commit)
                command="pre-commit"
                shift
                ;;
            --auto-switch)
                command="auto-switch"
                shift
                agent_name="$1"
                shift
                ;;
            --emergency)
                command="emergency"
                shift
                emergency_reason="$1"
                shift
                ;;
            --session-status)
                command="session-status"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Default to safety check if no command specified
    if [ -z "$command" ]; then
        command="check"
    fi
    
    # Process commands
    case $command in
        "init-session")
            process_session_init "$agent_name" "$task_description"
            ;;
        "check")
            process_safety_check
            ;;
        "pre-commit")
            process_pre_commit_check
            ;;
        "auto-switch")
            local current_branch
            current_branch=$(git branch --show-current 2>/dev/null || echo "HEAD")
            perform_automatic_branch_switch "$current_branch" "$agent_name"
            ;;
        "emergency")
            local reason="${emergency_reason:-Manual emergency override}"
            local current_branch
            current_branch=$(git branch --show-current 2>/dev/null || echo "HEAD")
            generate_emergency_override "$reason" "$current_branch"
            ;;
        "session-status")
            if [ -f "$SESSION_FILE" ]; then
                echo "Active MCP Protection Session:"
                cat "$SESSION_FILE" | (command -v jq >/dev/null 2>&1 && jq . || cat)
            else
                echo "No active MCP protection session"
            fi
            ;;
        *)
            log_error "Invalid command: $command"
            show_usage
            exit 1
            ;;
    esac
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi