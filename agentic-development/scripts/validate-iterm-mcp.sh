#!/bin/bash

# iTerm MCP Server Validation Script
# Part of Issue #203: Complete iTerm MCP Server integration
#
# Purpose: Validates iTerm MCP server installation and functionality
# Integration: Works with PR 204 handoff patterns and GitHub MCP protection system
# Usage: ./agentic-development/scripts/validate-iterm-mcp.sh [--verbose]

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
readonly SCRIPT_NAME="iTerm MCP Server Validation"
readonly VERSION="1.0.0"

# Validation flags
VERBOSE=false
VALIDATION_ERRORS=0

# Utility Functions
log_header() {
    echo ""
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}🔍 $SCRIPT_NAME v$VERSION${NC}"
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
}

log_warning() {
    local message="$1"
    echo -e "${YELLOW}⚠️  $message${NC}"
}

log_error() {
    local message="$1"
    echo -e "${RED}❌ $message${NC}"
    ((VALIDATION_ERRORS++))
}

log_info() {
    local message="$1"
    echo -e "${BLUE}ℹ️  $message${NC}"
}

log_verbose() {
    local message="$1"
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}🔍 $message${NC}"
    fi
}

# Core Validation Functions
validate_system_requirements() {
    log_section "🖥️ System Requirements Check"
    
    # Check macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        log_success "macOS detected - iTerm automation supported"
        log_verbose "macOS version: $(sw_vers -productVersion)"
    else
        log_warning "Non-macOS system detected - iTerm automation may not be available"
        log_info "This validation will check what's possible on your system"
    fi
    
    # Check iTerm2 installation
    if [ -d "/Applications/iTerm.app" ]; then
        log_success "iTerm2 application found"
        if [ "$VERBOSE" = true ]; then
            local iterm_version
            iterm_version=$(defaults read /Applications/iTerm.app/Contents/Info CFBundleShortVersionString 2>/dev/null || echo "unknown")
            log_verbose "iTerm2 version: $iterm_version"
        fi
    else
        log_error "iTerm2 not found in /Applications/"
        log_info "Install from: https://iterm2.com/"
    fi
    
    # Check Node.js for MCP server
    if command -v node >/dev/null 2>&1; then
        local node_version
        node_version=$(node --version)
        log_success "Node.js found: $node_version"
        
        # Check if version is recent enough for MCP
        local major_version
        major_version=$(echo "$node_version" | sed 's/v\([0-9]*\).*/\1/')
        if [ "$major_version" -ge 18 ]; then
            log_success "Node.js version is MCP compatible (>=18)"
        else
            log_warning "Node.js version may be too old for MCP server (recommend >=18)"
        fi
    else
        log_error "Node.js not found - required for MCP server"
        log_info "Install from: https://nodejs.org/"
    fi
    
    # Check npm
    if command -v npm >/dev/null 2>&1; then
        local npm_version
        npm_version=$(npm --version)
        log_success "npm found: v$npm_version"
    else
        log_error "npm not found - required for MCP server installation"
    fi
    
    return 0
}

validate_existing_integration() {
    log_section "🔗 Existing Integration Check"
    
    # Check GitHub MCP Protection System
    local protection_script="./agentic-development/scripts/github-mcp-protection.sh"
    if [ -f "$protection_script" ]; then
        log_success "GitHub MCP Protection System found"
        
        # Test if it can run
        if bash "$protection_script" --check >/dev/null 2>&1; then
            log_success "GitHub MCP Protection System is functional"
        else
            log_warning "GitHub MCP Protection System may have issues"
        fi
    else
        log_error "GitHub MCP Protection System not found"
        log_info "Expected at: $protection_script"
    fi
    
    # Check agent terminal prompts
    local terminal_prompts="./agentic-development/workflows/agent-terminal-prompts.md"
    if [ -f "$terminal_prompts" ]; then
        log_success "Agent terminal prompts documentation found"
        
        # Check if it contains iTerm automation patterns
        if grep -q "iTerm2" "$terminal_prompts" 2>/dev/null; then
            log_success "iTerm automation patterns documented"
        else
            log_warning "iTerm automation patterns may be missing"
        fi
    else
        log_error "Agent terminal prompts documentation not found"
    fi
    
    # Check handoff patterns (from PR 204)
    if grep -r "start-session" ./agentic-development/ >/dev/null 2>&1; then
        log_success "Claude Desktop handoff patterns found"
        log_verbose "Handoff patterns from PR 204 are available"
    else
        log_warning "Claude Desktop handoff patterns may not be implemented yet"
        log_info "This may be expected if PR 204 hasn't been merged"
    fi
    
    return 0
}

validate_mcp_server_capability() {
    log_section "🖲️ MCP Server Capability Check"
    
    # Check for MCP SDK availability
    if npm list -g @modelcontextprotocol/sdk >/dev/null 2>&1; then
        log_success "MCP SDK found globally"
    elif npm list @modelcontextprotocol/sdk >/dev/null 2>&1; then
        log_success "MCP SDK found locally"
    else
        log_warning "MCP SDK not found - needed for custom MCP servers"
        log_info "Install with: npm install -g @modelcontextprotocol/sdk"
    fi
    
    # Check for Claude Desktop
    if [ -d "/Applications/Claude.app" ]; then
        log_success "Claude Desktop found"
    else
        log_warning "Claude Desktop not found"
        log_info "Download from: https://claude.ai/download"
    fi
    
    # Check for Claude Desktop configuration directory
    local claude_config_dir="$HOME/Library/Application Support/Claude"
    if [ -d "$claude_config_dir" ]; then
        log_success "Claude Desktop configuration directory found"
        log_verbose "Config directory: $claude_config_dir"
        
        # Check if MCP configuration exists
        if [ -f "$claude_config_dir/claude_desktop_config.json" ]; then
            log_success "Claude Desktop MCP configuration file found"
            
            # Check if it mentions iTerm or any MCP servers
            if grep -q "iterm\|mcp" "$claude_config_dir/claude_desktop_config.json" 2>/dev/null; then
                log_success "MCP server configuration detected"
            else
                log_info "No iTerm MCP server configured yet"
            fi
        else
            log_info "No MCP configuration file found (will be created when needed)"
        fi
    else
        log_warning "Claude Desktop configuration directory not found"
        log_info "Run Claude Desktop at least once to create configuration"
    fi
    
    return 0
}

validate_automation_scripts() {
    log_section "🤖 Automation Scripts Check"
    
    # Check for AppleScript support
    if command -v osascript >/dev/null 2>&1; then
        log_success "AppleScript (osascript) available for iTerm automation"
        
        # Test basic AppleScript functionality
        if osascript -e "tell application \"System Events\" to get name of processes" >/dev/null 2>&1; then
            log_success "AppleScript system access is functional"
        else
            log_warning "AppleScript may have permission issues"
            log_info "May need to grant accessibility permissions"
        fi
    else
        log_error "AppleScript (osascript) not found - required for iTerm automation"
    fi
    
    # Check if iTerm is running
    if pgrep -f "iTerm" >/dev/null 2>&1; then
        log_success "iTerm is currently running"
    else
        log_info "iTerm is not currently running (normal if not in use)"
    fi
    
    # Check if we can communicate with iTerm (if running)
    if pgrep -f "iTerm" >/dev/null 2>&1; then
        if osascript -e 'tell application "iTerm2" to get name' >/dev/null 2>&1; then
            log_success "Can communicate with iTerm2 via AppleScript"
        else
            log_warning "Cannot communicate with iTerm2 via AppleScript"
            log_info "May need to enable automation permissions for iTerm"
        fi
    fi
    
    return 0
}

validate_claude_code_integration() {
    log_section "🧠 Claude Code Integration Check"
    
    # Check if claude-code is available
    if command -v claude >/dev/null 2>&1; then
        log_success "Claude Code CLI found"
        
        # Check version if possible
        if claude --version >/dev/null 2>&1; then
            local claude_version
            claude_version=$(claude --version 2>/dev/null || echo "unknown")
            log_verbose "Claude Code version: $claude_version"
        fi
        
        # Check if it supports agent flags
        if claude --help 2>&1 | grep -q "\--agent\|agent" 2>/dev/null; then
            log_success "Claude Code supports agent specification"
        else
            log_warning "Claude Code may not support --agent flag"
            log_info "Update Claude Code if needed"
        fi
    else
        log_error "Claude Code CLI not found"
        log_info "Install from: https://docs.anthropic.com/claude/docs/claude-code"
    fi
    
    return 0
}

generate_integration_report() {
    log_section "📊 Integration Status Report"
    
    echo ""
    echo "=== iTerm MCP Server Integration Status ==="
    echo ""
    
    if [ $VALIDATION_ERRORS -eq 0 ]; then
        log_success "All validations passed! iTerm MCP integration is ready"
        echo ""
        echo -e "${GREEN}🎉 Next Steps:${NC}"
        echo "   1. Install iTerm MCP server: npm install -g iterm_mcp_server"
        echo "   2. Configure Claude Desktop MCP settings"
        echo "   3. Test with: /start-session vibe-coder test the integration"
    else
        log_warning "$VALIDATION_ERRORS validation error(s) found"
        echo ""
        echo -e "${YELLOW}🔧 Action Required:${NC}"
        echo "   Review the errors above and install missing components"
        echo "   Run this script again after addressing issues"
    fi
    
    echo ""
    echo "=== Compatibility with PR 204 Handoff Patterns ==="
    echo ""
    log_info "This validation supports the handoff patterns documented in PR 204"
    log_info "Your iTerm MCP server will enhance the documented '/start-session' workflow"
    
    echo ""
    echo "=== Documentation References ==="
    echo "   • GitHub Issue #203: Complete iTerm MCP Server integration"
    echo "   • PR #204: Claude Desktop to Claude Code handoff patterns"
    echo "   • Agent Terminal Prompts: agentic-development/workflows/agent-terminal-prompts.md"
    echo ""
}

# Main Function
show_usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --verbose          Enable verbose logging with detailed information
    --help             Show this help message

DESCRIPTION:
    Validates iTerm MCP server integration capabilities and compatibility
    with existing Tuvens agentic development workflows.

    This script checks:
    • System requirements (macOS, iTerm2, Node.js)
    • Existing integration components
    • MCP server capabilities
    • Automation script functionality
    • Claude Code integration

EXAMPLES:
    # Basic validation
    $0

    # Verbose validation with detailed information
    $0 --verbose

For more information, see:
• GitHub Issue #203: Complete iTerm MCP Server integration
• PR #204: Claude Desktop to Claude Code handoff patterns
EOF
}

main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --verbose)
                VERBOSE=true
                shift
                ;;
            --help)
                show_usage
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    log_header

    # Run all validation checks
    validate_system_requirements
    validate_existing_integration
    validate_mcp_server_capability
    validate_automation_scripts
    validate_claude_code_integration
    
    # Generate final report
    generate_integration_report

    # Exit with appropriate code
    if [ $VALIDATION_ERRORS -eq 0 ]; then
        exit 0
    else
        exit 1
    fi
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi