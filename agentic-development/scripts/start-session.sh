#!/bin/bash

# Simple Start Session Script
# Issue #203: Complete iTerm MCP Server integration - SIMPLIFIED APPROACH
# 
# Purpose: Opens iTerm2 window with agent-specific commands
# Usage: ./start-session.sh [agent-name] [optional-task-description]
# Integration: Works with PR #204 Claude Desktop handoff patterns

set -e

# Configuration - matches PR #204 specifications exactly
readonly SCRIPT_NAME="Start Session"
readonly VERSION="1.0.0"

# Agent to directory mapping (MUST match PR #204)
get_agent_directory() {
    case "$1" in
        "vibe-coder"|"devops") echo "$HOME/Code/Tuvens/tuvens-docs" ;;
        "react-dev"|"laravel-dev") echo "$HOME/Code/Tuvens/hi.events" ;;
        "node-dev") echo "$HOME/Code/Tuvens/tuvens-api" ;;
        "svelte-dev") echo "$HOME/Code/Tuvens/tuvens-client" ;;
        *) echo "" ;;
    esac
}

# Colors for output
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

show_usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION

USAGE:
    $0 [agent-name] [optional-task-description]

SUPPORTED AGENTS:
    vibe-coder      → ~/Code/Tuvens/tuvens-docs
    devops          → ~/Code/Tuvens/tuvens-docs  
    react-dev       → ~/Code/Tuvens/hi.events
    laravel-dev     → ~/Code/Tuvens/hi.events
    node-dev        → ~/Code/Tuvens/tuvens-api
    svelte-dev      → ~/Code/Tuvens/tuvens-client

EXAMPLES:
    $0 react-dev
    $0 react-dev "fix button styling"
    $0 vibe-coder "update documentation"

DESCRIPTION:
    Opens iTerm2 window, navigates to correct directory, starts Claude Code 
    with specified agent. Simple and direct - no complex MCP setup required.

INTEGRATION:
    • Works with PR #204 Claude Desktop handoff patterns
    • Compatible with existing GitHub MCP protection system
    • Fallback solution when iTerm MCP server has permission issues
EOF
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

validate_requirements() {
    # Check macOS
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "This script requires macOS (for iTerm2 and AppleScript)"
        exit 1
    fi

    # Check iTerm2
    if [ ! -d "/Applications/iTerm.app" ]; then
        log_error "iTerm2 not found. Install from: https://iterm2.com/"
        exit 1
    fi

    # Check osascript
    if ! command -v osascript >/dev/null 2>&1; then
        log_error "AppleScript (osascript) not found"
        exit 1
    fi

    # Check Claude Code
    if ! command -v claude >/dev/null 2>&1; then
        log_warning "Claude Code CLI not found - session will only navigate to directory"
        log_info "Install Claude Code from: https://docs.anthropic.com/claude/docs/claude-code"
        return 1
    fi

    return 0
}

create_agent_session() {
    local agent_name="$1"
    local task_description="$2"
    local target_dir
    target_dir=$(get_agent_directory "$agent_name")
    
    # Validate agent
    if [ -z "$target_dir" ]; then
        log_error "Unknown agent: $agent_name"
        echo "Supported agents: vibe-coder, devops, react-dev, laravel-dev, node-dev, svelte-dev"
        exit 1
    fi

    # Validate directory exists
    if [ ! -d "$target_dir" ]; then
        log_error "Directory not found: $target_dir"
        log_info "Ensure the repository is cloned to the expected location"
        exit 1
    fi

    log_info "Creating $agent_name session in $target_dir"
    if [ -n "$task_description" ]; then
        log_info "Task: $task_description"
    fi

    # Create iTerm session with AppleScript
    local session_name="$agent_name-session"
    local claude_command="claude-code --agent $agent_name"
    
    # Add task description if provided
    if [ -n "$task_description" ]; then
        claude_command="$claude_command --message '$task_description'"
    fi

    # Execute AppleScript to create iTerm session
    osascript << EOF
tell application "iTerm"
    activate
    create window with default profile
    tell current session of current window
        set name to "$session_name"
        write text "cd $target_dir"
        write text "clear"
        write text "echo '======================================'"
        write text "echo '$agent_name AGENT SESSION'"
        write text "echo '======================================'"
        write text "echo 'Directory: $target_dir'"
        write text "echo 'Agent: $agent_name'"
$([ -n "$task_description" ] && echo "        write text \"echo 'Task: $task_description'\"")
        write text "echo '======================================'"
        write text "echo ''"
        write text "$claude_command"
    end tell
end tell
EOF

    local applescript_exit=$?
    
    if [ $applescript_exit -eq 0 ]; then
        log_success "iTerm session created successfully"
        log_info "Session name: $session_name"
        log_info "Agent: $agent_name"
        log_info "Directory: $target_dir"
        [ -n "$task_description" ] && log_info "Task: $task_description"
    else
        log_error "Failed to create iTerm session"
        log_warning "You may need to grant iTerm automation permissions"
        log_info "Go to: System Preferences → Security & Privacy → Privacy → Automation"
        log_info "Enable: Terminal → iTerm.app"
        exit 1
    fi
}

main() {
    local agent_name="$1"
    local task_description="$2"

    # Show usage if no arguments
    if [ $# -eq 0 ]; then
        show_usage
        exit 0
    fi

    # Handle help flags
    case "$agent_name" in
        --help|-h)
            show_usage
            exit 0
            ;;
        --version|-v)
            echo "$SCRIPT_NAME v$VERSION"
            exit 0
            ;;
    esac

    echo -e "${BLUE}🚀 $SCRIPT_NAME v$VERSION${NC}"
    echo ""

    # Validate system requirements
    validate_requirements
    
    # Create the agent session
    create_agent_session "$agent_name" "$task_description"

    echo ""
    log_success "Session creation complete!"
    log_info "Switch to iTerm to begin working with $agent_name"
    
    # Integration note
    echo ""
    echo -e "${YELLOW}📋 Integration Notes:${NC}"
    echo "• This implements the simple solution for Issue #203"
    echo "• Works with PR #204 Claude Desktop handoff patterns"
    echo "• No complex MCP server or excessive permissions required"
    echo "• Direct AppleScript automation - safe and reliable"
}

# Execute main function
main "$@"