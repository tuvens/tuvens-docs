#!/usr/bin/env bash
# File: install-iterm-mcp.sh
# Purpose: Clean installation script for iTerm MCP Server integration with Claude Desktop
# Author: DevOps Agent
# Version: 1.0

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    case "$level" in
        "INFO")  echo -e "${BLUE}[INFO]${NC} $*" ;;
        "WARN")  echo -e "${YELLOW}[WARN]${NC} $*" ;;
        "ERROR") echo -e "${RED}[ERROR]${NC} $*" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $*" ;;
    esac
}

# Usage function
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Install and configure iTerm MCP Server for Claude Desktop integration

Options:
    --dry-run           Show what would be installed without making changes
    --force             Force reinstallation even if already installed
    --config-only       Only update Claude Desktop configuration
    --validate-only     Only run validation checks
    --uninstall         Remove iTerm MCP server configuration
    -h, --help          Show this help message

Examples:
    $0                  # Standard installation
    $0 --dry-run        # Preview installation steps
    $0 --force          # Force reinstall
    $0 --validate-only  # Check current installation

EOF
    exit 1
}

# Parse command line arguments
DRY_RUN=false
FORCE=false
CONFIG_ONLY=false
VALIDATE_ONLY=false
UNINSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --force)
            FORCE=true
            shift
            ;;
        --config-only)
            CONFIG_ONLY=true
            shift
            ;;
        --validate-only)
            VALIDATE_ONLY=true
            shift
            ;;
        --uninstall)
            UNINSTALL=true
            shift
            ;;
        -h|--help)
            usage
            ;;
        *)
            log "ERROR" "Unknown option: $1"
            usage
            ;;
    esac
done

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Platform detection
detect_platform() {
    case "$OSTYPE" in
        darwin*)
            PLATFORM="macos"
            CLAUDE_CONFIG_DIR="$HOME/Library/Application Support/Claude"
            ;;
        msys*|win32*|cygwin*)
            PLATFORM="windows"
            CLAUDE_CONFIG_DIR="$APPDATA/Claude"
            ;;
        linux*)
            PLATFORM="linux"
            CLAUDE_CONFIG_DIR="$HOME/.config/claude"
            ;;
        *)
            log "ERROR" "Unsupported platform: $OSTYPE"
            exit 1
            ;;
    esac
    
    CLAUDE_CONFIG_FILE="$CLAUDE_CONFIG_DIR/claude_desktop_config.json"
}

# Validation functions
check_prerequisites() {
    log "INFO" "Checking prerequisites..."
    
    # Check if we're on macOS (iTerm2 requirement)
    if [[ "$PLATFORM" != "macos" ]]; then
        log "ERROR" "iTerm MCP server requires macOS and iTerm2"
        log "INFO" "For other platforms, consider using alternative MCP servers"
        exit 1
    fi
    
    # Check for iTerm2
    if ! command -v osascript &> /dev/null; then
        log "ERROR" "osascript not found - AppleScript support required for iTerm2 integration"
        exit 1
    fi
    
    # Check if iTerm2 is installed
    if [[ ! -d "/Applications/iTerm.app" ]]; then
        log "WARN" "iTerm2 not found in /Applications/iTerm.app"
        log "INFO" "Please install iTerm2 from https://iterm2.com/"
        read -p "Continue anyway? (y/n): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi
    
    # Check for Node.js (required for npx)
    if ! command -v node &> /dev/null; then
        log "ERROR" "Node.js not found - required for npx execution"
        log "INFO" "Install Node.js from https://nodejs.org/"
        exit 1
    fi
    
    # Check for npx
    if ! command -v npx &> /dev/null; then
        log "ERROR" "npx not found - comes with Node.js"
        exit 1
    fi
    
    # Check Claude Desktop installation
    if [[ ! -d "$CLAUDE_CONFIG_DIR" ]]; then
        log "WARN" "Claude Desktop configuration directory not found: $CLAUDE_CONFIG_DIR"
        log "INFO" "Claude Desktop may not be installed or hasn't been run yet"
    fi
    
    log "SUCCESS" "Prerequisites check completed"
}

# Test iTerm MCP server availability
test_iterm_mcp_availability() {
    log "INFO" "Testing iTerm MCP server availability..."
    
    if $DRY_RUN; then
        log "INFO" "[DRY RUN] Would test: npx -y iterm-mcp --version"
        return 0
    fi
    
    # Test if we can fetch the package
    if ! timeout 30 npx -y iterm-mcp --version &> /dev/null; then
        log "ERROR" "Failed to fetch or run iTerm MCP server"
        log "INFO" "Check your internet connection and npm registry access"
        return 1
    fi
    
    log "SUCCESS" "iTerm MCP server is available"
    return 0
}

# Backup existing Claude Desktop config
backup_claude_config() {
    if [[ -f "$CLAUDE_CONFIG_FILE" ]]; then
        local backup_file="${CLAUDE_CONFIG_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        if $DRY_RUN; then
            log "INFO" "[DRY RUN] Would backup: $CLAUDE_CONFIG_FILE -> $backup_file"
        else
            cp "$CLAUDE_CONFIG_FILE" "$backup_file"
            log "SUCCESS" "Backed up existing config to: $backup_file"
        fi
    fi
}

# Update Claude Desktop configuration
update_claude_config() {
    log "INFO" "Updating Claude Desktop configuration..."
    
    # Create config directory if it doesn't exist
    if $DRY_RUN; then
        log "INFO" "[DRY RUN] Would create directory: $CLAUDE_CONFIG_DIR"
    else
        mkdir -p "$CLAUDE_CONFIG_DIR"
    fi
    
    # Prepare the MCP server configuration
    local mcp_config='{
  "mcpServers": {
    "iterm-mcp": {
      "command": "npx",
      "args": ["-y", "iterm-mcp"]
    }
  }
}'
    
    if [[ -f "$CLAUDE_CONFIG_FILE" ]]; then
        # Config exists, merge with existing
        backup_claude_config
        
        if $DRY_RUN; then
            log "INFO" "[DRY RUN] Would merge iTerm MCP config into existing file"
            log "INFO" "[DRY RUN] Current config:"
            [[ -f "$CLAUDE_CONFIG_FILE" ]] && cat "$CLAUDE_CONFIG_FILE" | head -10
        else
            # Use jq to merge if available, otherwise manual merge
            if command -v jq &> /dev/null; then
                # Create temporary merged config
                local temp_config="/tmp/claude_config_merged_$$"
                jq -s '.[0] * .[1]' "$CLAUDE_CONFIG_FILE" <(echo "$mcp_config") > "$temp_config"
                mv "$temp_config" "$CLAUDE_CONFIG_FILE"
                log "SUCCESS" "Merged iTerm MCP configuration with existing config"
            else
                log "WARN" "jq not available - manual configuration required"
                log "INFO" "Please add the following to your Claude Desktop config:"
                echo "$mcp_config"
                return 1
            fi
        fi
    else
        # No existing config, create new
        if $DRY_RUN; then
            log "INFO" "[DRY RUN] Would create new config file: $CLAUDE_CONFIG_FILE"
            echo "$mcp_config"
        else
            echo "$mcp_config" > "$CLAUDE_CONFIG_FILE"
            log "SUCCESS" "Created new Claude Desktop configuration"
        fi
    fi
}

# Validate installation
validate_installation() {
    log "INFO" "Validating installation..."
    
    # Check config file exists and is valid JSON
    if [[ ! -f "$CLAUDE_CONFIG_FILE" ]]; then
        log "ERROR" "Claude Desktop config file not found: $CLAUDE_CONFIG_FILE"
        return 1
    fi
    
    # Validate JSON syntax
    if command -v jq &> /dev/null; then
        if ! jq empty "$CLAUDE_CONFIG_FILE" &> /dev/null; then
            log "ERROR" "Invalid JSON in Claude Desktop config file"
            return 1
        fi
        
        # Check if iTerm MCP is configured
        if jq -e '.mcpServers."iterm-mcp"' "$CLAUDE_CONFIG_FILE" &> /dev/null; then
            log "SUCCESS" "iTerm MCP server is configured in Claude Desktop"
        else
            log "ERROR" "iTerm MCP server not found in Claude Desktop configuration"
            return 1
        fi
    else
        log "WARN" "jq not available - skipping JSON validation"
    fi
    
    # Test iTerm MCP server execution
    log "INFO" "Testing iTerm MCP server execution..."
    if timeout 10 npx -y iterm-mcp --version &> /dev/null; then
        log "SUCCESS" "iTerm MCP server is executable"
    else
        log "ERROR" "iTerm MCP server failed to execute"
        return 1
    fi
    
    return 0
}

# Uninstall function
uninstall_iterm_mcp() {
    log "INFO" "Uninstalling iTerm MCP server configuration..."
    
    if [[ ! -f "$CLAUDE_CONFIG_FILE" ]]; then
        log "INFO" "No Claude Desktop config found - nothing to remove"
        return 0
    fi
    
    backup_claude_config
    
    if command -v jq &> /dev/null; then
        if $DRY_RUN; then
            log "INFO" "[DRY RUN] Would remove iTerm MCP from Claude config"
        else
            # Remove iTerm MCP server from config
            local temp_config="/tmp/claude_config_cleaned_$$"
            jq 'del(.mcpServers."iterm-mcp")' "$CLAUDE_CONFIG_FILE" > "$temp_config"
            
            # If mcpServers is now empty, remove it entirely
            if [[ "$(jq '.mcpServers | length' "$temp_config")" == "0" ]]; then
                jq 'del(.mcpServers)' "$temp_config" > "${temp_config}_final"
                mv "${temp_config}_final" "$temp_config"
            fi
            
            mv "$temp_config" "$CLAUDE_CONFIG_FILE"
            log "SUCCESS" "Removed iTerm MCP configuration from Claude Desktop"
        fi
    else
        log "WARN" "jq not available - manual configuration removal required"
        log "INFO" "Please manually remove iterm-mcp from your Claude Desktop config"
    fi
}

# Main execution
main() {
    log "INFO" "iTerm MCP Server Installation Script v1.0"
    log "INFO" "=========================================="
    
    detect_platform
    log "INFO" "Platform: $PLATFORM"
    log "INFO" "Claude config: $CLAUDE_CONFIG_FILE"
    
    if [[ $DRY_RUN == true ]]; then
        log "INFO" "DRY RUN MODE - No changes will be made"
    fi
    
    # Handle uninstall
    if [[ $UNINSTALL == true ]]; then
        uninstall_iterm_mcp
        exit 0
    fi
    
    # Handle validate-only
    if [[ $VALIDATE_ONLY == true ]]; then
        if validate_installation; then
            log "SUCCESS" "Installation validation passed"
            exit 0
        else
            log "ERROR" "Installation validation failed"
            exit 1
        fi
    fi
    
    # Check prerequisites
    check_prerequisites
    
    # Test iTerm MCP availability
    if ! test_iterm_mcp_availability; then
        log "ERROR" "Cannot proceed - iTerm MCP server unavailable"
        exit 1
    fi
    
    # Skip config if config-only is false and we're checking existence
    if [[ $CONFIG_ONLY == false ]]; then
        # Check if already configured (unless force)
        if [[ $FORCE == false && -f "$CLAUDE_CONFIG_FILE" ]]; then
            if command -v jq &> /dev/null && jq -e '.mcpServers."iterm-mcp"' "$CLAUDE_CONFIG_FILE" &> /dev/null; then
                log "INFO" "iTerm MCP server already configured"
                log "INFO" "Use --force to reinstall or --validate-only to check installation"
                exit 0
            fi
        fi
    fi
    
    # Update Claude Desktop configuration
    if ! update_claude_config; then
        log "ERROR" "Failed to update Claude Desktop configuration"
        exit 1
    fi
    
    # Validate installation
    if ! $DRY_RUN; then
        if validate_installation; then
            log "SUCCESS" "Installation completed successfully!"
            log "INFO" ""
            log "INFO" "Next steps:"
            log "INFO" "1. Restart Claude Desktop to load the new configuration"
            log "INFO" "2. Open iTerm2 (the MCP server will interact with your active iTerm session)"
            log "INFO" "3. Test the integration by asking Claude to run terminal commands"
            log "INFO" ""
            log "INFO" "Example prompts to try:"
            log "INFO" "- 'Show me what's in the current directory'"
            log "INFO" "- 'Run ls -la and tell me about the files'"
            log "INFO" "- 'Check the git status of this repository'"
        else
            log "ERROR" "Installation validation failed"
            exit 1
        fi
    else
        log "INFO" "DRY RUN completed - use without --dry-run to perform installation"
    fi
}

# Run main function
main "$@"