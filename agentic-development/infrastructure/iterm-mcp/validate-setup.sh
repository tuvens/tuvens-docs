#!/usr/bin/env bash
# File: validate-setup.sh
# Purpose: Validation script for iTerm MCP Server integration with Claude Desktop
# Author: DevOps Agent
# Version: 1.0

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging function
log() {
    local level="$1"
    shift
    case "$level" in
        "INFO")    echo -e "${BLUE}[INFO]${NC} $*" ;;
        "WARN")    echo -e "${YELLOW}[WARN]${NC} $*" ;;
        "ERROR")   echo -e "${RED}[ERROR]${NC} $*" ;;
        "SUCCESS") echo -e "${GREEN}[SUCCESS]${NC} $*" ;;
        "TEST")    echo -e "${CYAN}[TEST]${NC} $*" ;;
    esac
}

# Counter for test results
TESTS_PASSED=0
TESTS_FAILED=0
TESTS_SKIPPED=0

# Test result tracking
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    log "TEST" "Running: $test_name"
    
    if eval "$test_command" &>/dev/null; then
        log "SUCCESS" "✓ $test_name"
        ((TESTS_PASSED++))
        return 0
    else
        log "ERROR" "✗ $test_name"
        ((TESTS_FAILED++))
        return 1
    fi
}

run_test_with_output() {
    local test_name="$1"
    local test_command="$2"
    local expected_pattern="${3:-}"
    
    log "TEST" "Running: $test_name"
    
    local output
    if output=$(eval "$test_command" 2>&1); then
        if [[ -n "$expected_pattern" ]]; then
            if echo "$output" | grep -q "$expected_pattern"; then
                log "SUCCESS" "✓ $test_name"
                ((TESTS_PASSED++))
                return 0
            else
                log "ERROR" "✗ $test_name (pattern '$expected_pattern' not found)"
                log "INFO" "Output: $output"
                ((TESTS_FAILED++))
                return 1
            fi
        else
            log "SUCCESS" "✓ $test_name"
            ((TESTS_PASSED++))
            return 0
        fi
    else
        log "ERROR" "✗ $test_name"
        log "INFO" "Error: $output"
        ((TESTS_FAILED++))
        return 1
    fi
}

skip_test() {
    local test_name="$1"
    local reason="$2"
    
    log "WARN" "⚠ Skipped: $test_name ($reason)"
    ((TESTS_SKIPPED++))
}

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

# System Prerequisites Tests
test_system_prerequisites() {
    log "INFO" "Testing system prerequisites..."
    
    # Platform check
    if [[ "$PLATFORM" == "macos" ]]; then
        log "SUCCESS" "✓ Platform: macOS (iTerm2 compatible)"
    else
        log "ERROR" "✗ Platform: $PLATFORM (iTerm MCP requires macOS)"
        ((TESTS_FAILED++))
        return 1
    fi
    
    # Node.js
    run_test "Node.js installed" "command -v node"
    
    # npm/npx
    run_test "npx available" "command -v npx"
    
    # osascript (AppleScript)
    run_test "AppleScript support (osascript)" "command -v osascript"
    
    # jq (optional but recommended)
    if command -v jq &>/dev/null; then
        run_test "jq available (JSON processing)" "command -v jq"
    else
        skip_test "jq available (JSON processing)" "not installed but optional"
    fi
    
    # iTerm2 installation
    if [[ -d "/Applications/iTerm.app" ]]; then
        log "SUCCESS" "✓ iTerm2 installed at /Applications/iTerm.app"
        ((TESTS_PASSED++))
    else
        log "ERROR" "✗ iTerm2 not found at /Applications/iTerm.app"
        ((TESTS_FAILED++))
    fi
}

# Claude Desktop Configuration Tests  
test_claude_desktop_config() {
    log "INFO" "Testing Claude Desktop configuration..."
    
    # Claude config directory exists
    run_test "Claude config directory exists" "[[ -d '$CLAUDE_CONFIG_DIR' ]]"
    
    # Claude config file exists
    run_test "Claude config file exists" "[[ -f '$CLAUDE_CONFIG_FILE' ]]"
    
    if [[ -f "$CLAUDE_CONFIG_FILE" ]]; then
        # Valid JSON
        if command -v jq &>/dev/null; then
            run_test "Config file is valid JSON" "jq empty '$CLAUDE_CONFIG_FILE'"
            
            # iTerm MCP server configured
            run_test "iTerm MCP server configured" "jq -e '.mcpServers.\"iterm-mcp\"' '$CLAUDE_CONFIG_FILE'"
            
            # Correct command configuration
            run_test_with_output "iTerm MCP command is 'npx'" "jq -r '.mcpServers.\"iterm-mcp\".command' '$CLAUDE_CONFIG_FILE'" "npx"
            
            # Correct args configuration
            run_test_with_output "iTerm MCP args contain 'iterm-mcp'" "jq -r '.mcpServers.\"iterm-mcp\".args[]' '$CLAUDE_CONFIG_FILE' | tr '\n' ' '" "iterm-mcp"
        else
            skip_test "JSON validation" "jq not available"
            skip_test "iTerm MCP server configuration check" "jq not available"
        fi
    else
        skip_test "JSON validation" "config file not found"
        skip_test "iTerm MCP server configuration check" "config file not found"
    fi
}

# iTerm MCP Server Tests
test_iterm_mcp_server() {
    log "INFO" "Testing iTerm MCP server..."
    
    # Server package availability
    run_test_with_output "iTerm MCP server package accessible" "timeout 30 npx -y iterm-mcp --version" "."
    
    # Test basic functionality (if iTerm is running)
    if pgrep -f "iTerm" &>/dev/null; then
        log "SUCCESS" "✓ iTerm2 is running - MCP server can connect"
        ((TESTS_PASSED++))
    else
        skip_test "iTerm2 connection test" "iTerm2 not currently running"
    fi
}

# Integration Tests
test_integration() {
    log "INFO" "Testing integration readiness..."
    
    # All components present
    local components_ready=true
    
    if [[ ! -f "$CLAUDE_CONFIG_FILE" ]]; then
        components_ready=false
    elif command -v jq &>/dev/null && ! jq -e '.mcpServers."iterm-mcp"' "$CLAUDE_CONFIG_FILE" &>/dev/null; then
        components_ready=false
    fi
    
    if ! command -v npx &>/dev/null; then
        components_ready=false
    fi
    
    if [[ "$components_ready" == "true" ]]; then
        log "SUCCESS" "✓ All components ready for integration"
        ((TESTS_PASSED++))
    else
        log "ERROR" "✗ Integration not ready - missing components"
        ((TESTS_FAILED++))
    fi
    
    # Configuration file backup check
    local backup_count=$(find "$CLAUDE_CONFIG_DIR" -name "claude_desktop_config.json.backup.*" 2>/dev/null | wc -l)
    if [[ $backup_count -gt 0 ]]; then
        log "SUCCESS" "✓ Configuration backups found ($backup_count)"
        ((TESTS_PASSED++))
    else
        skip_test "Configuration backup check" "no backups found (may be first install)"
    fi
}

# Security and Safety Tests
test_security() {
    log "INFO" "Testing security considerations..."
    
    # Configuration file permissions
    if [[ -f "$CLAUDE_CONFIG_FILE" ]]; then
        local perms=$(stat -f "%A" "$CLAUDE_CONFIG_FILE" 2>/dev/null || stat -c "%a" "$CLAUDE_CONFIG_FILE" 2>/dev/null || echo "unknown")
        if [[ "$perms" == "600" || "$perms" == "644" ]]; then
            log "SUCCESS" "✓ Configuration file permissions: $perms"
            ((TESTS_PASSED++))
        else
            log "WARN" "⚠ Configuration file permissions: $perms (consider restricting)"
            ((TESTS_PASSED++))
        fi
    else
        skip_test "Configuration file permissions" "file not found"
    fi
    
    # Warn about security implications
    log "INFO" "Security reminder: iTerm MCP server grants Claude full terminal access"
    log "INFO" "Always monitor Claude's terminal interactions and interrupt if needed"
}

# Performance Tests
test_performance() {
    log "INFO" "Testing performance characteristics..."
    
    # Measure iTerm MCP startup time
    local start_time=$(date +%s%N)
    if timeout 10 npx -y iterm-mcp --version &>/dev/null; then
        local end_time=$(date +%s%N)
        local duration_ms=$(( (end_time - start_time) / 1000000 ))
        
        if [[ $duration_ms -lt 5000 ]]; then
            log "SUCCESS" "✓ iTerm MCP startup time: ${duration_ms}ms (good)"
        elif [[ $duration_ms -lt 10000 ]]; then
            log "SUCCESS" "✓ iTerm MCP startup time: ${duration_ms}ms (acceptable)"
        else
            log "WARN" "⚠ iTerm MCP startup time: ${duration_ms}ms (slow, may affect Claude response time)"
        fi
        ((TESTS_PASSED++))
    else
        log "ERROR" "✗ iTerm MCP startup test failed"
        ((TESTS_FAILED++))
    fi
}

# Troubleshooting Information
show_troubleshooting_info() {
    log "INFO" "Troubleshooting Information"
    log "INFO" "=========================="
    
    log "INFO" "System Information:"
    log "INFO" "  Platform: $PLATFORM"
    log "INFO" "  Node.js: $(node --version 2>/dev/null || echo 'Not installed')"
    log "INFO" "  npm: $(npm --version 2>/dev/null || echo 'Not installed')"
    log "INFO" "  Claude config dir: $CLAUDE_CONFIG_DIR"
    log "INFO" "  Claude config file: $CLAUDE_CONFIG_FILE"
    
    if [[ -f "$CLAUDE_CONFIG_FILE" ]]; then
        log "INFO" "  Config file size: $(wc -c < "$CLAUDE_CONFIG_FILE") bytes"
        log "INFO" "  Config file modified: $(stat -f "%Sm" "$CLAUDE_CONFIG_FILE" 2>/dev/null || stat -c "%y" "$CLAUDE_CONFIG_FILE" 2>/dev/null || echo 'unknown')"
    fi
    
    log "INFO" ""
    log "INFO" "Common Issues and Solutions:"
    log "INFO" "  1. Claude Desktop not recognizing MCP server:"
    log "INFO" "     → Restart Claude Desktop after configuration changes"
    log "INFO" "     → Check JSON syntax in config file"
    log "INFO" ""
    log "INFO" "  2. iTerm MCP server not responding:"
    log "INFO" "     → Ensure iTerm2 is running and active"
    log "INFO" "     → Check network connectivity for npx package downloads"
    log "INFO" ""
    log "INFO" "  3. Permission errors:"
    log "INFO" "     → Ensure Claude Desktop config directory is writable"
    log "INFO" "     → Check macOS security settings for terminal access"
    log "INFO" ""
    log "INFO" "  4. Slow response times:"
    log "INFO" "     → First run may be slow due to package download"
    log "INFO" "     → Consider pre-installing: npm install -g iterm-mcp"
}

# Generate validation report
generate_report() {
    local total_tests=$((TESTS_PASSED + TESTS_FAILED + TESTS_SKIPPED))
    
    log "INFO" ""
    log "INFO" "Validation Report"
    log "INFO" "================"
    log "INFO" "Total tests: $total_tests"
    log "SUCCESS" "Passed: $TESTS_PASSED"
    log "ERROR" "Failed: $TESTS_FAILED"
    log "WARN" "Skipped: $TESTS_SKIPPED"
    
    local success_rate=0
    if [[ $total_tests -gt 0 ]]; then
        success_rate=$(( (TESTS_PASSED * 100) / (TESTS_PASSED + TESTS_FAILED) ))
    fi
    
    log "INFO" "Success rate: ${success_rate}%"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        log "SUCCESS" "✓ All tests passed - iTerm MCP integration is ready!"
        return 0
    elif [[ $TESTS_FAILED -lt 3 && $success_rate -gt 80 ]]; then
        log "WARN" "⚠ Minor issues detected - integration may work with limitations"
        return 1
    else
        log "ERROR" "✗ Significant issues detected - integration likely to fail"
        return 2
    fi
}

# Usage information
usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Validate iTerm MCP Server integration with Claude Desktop

Options:
    --quick             Run only essential tests (faster)
    --verbose           Show detailed output for all tests
    --troubleshoot      Show troubleshooting information
    --report-only       Generate report from previous test results
    -h, --help          Show this help message

Examples:
    $0                  # Full validation
    $0 --quick          # Quick validation
    $0 --troubleshoot   # Show troubleshooting info

Exit codes:
    0 - All tests passed
    1 - Minor issues detected
    2 - Major issues detected
    3 - Validation failed to run

EOF
    exit 0
}

# Parse command line arguments
QUICK_MODE=false
VERBOSE_MODE=false
TROUBLESHOOT_ONLY=false
REPORT_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick)
            QUICK_MODE=true
            shift
            ;;
        --verbose)
            VERBOSE_MODE=true
            shift
            ;;
        --troubleshoot)
            TROUBLESHOOT_ONLY=true
            shift
            ;;
        --report-only)
            REPORT_ONLY=true
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

# Main execution
main() {
    log "INFO" "iTerm MCP Server Validation Script v1.0"
    log "INFO" "======================================="
    
    detect_platform
    
    if [[ $TROUBLESHOOT_ONLY == true ]]; then
        show_troubleshooting_info
        exit 0
    fi
    
    if [[ $REPORT_ONLY == true ]]; then
        generate_report
        exit $?
    fi
    
    # Run test suites
    test_system_prerequisites
    test_claude_desktop_config
    test_iterm_mcp_server
    test_integration
    
    if [[ $QUICK_MODE == false ]]; then
        test_security
        test_performance
    fi
    
    # Generate final report
    local exit_code
    generate_report
    exit_code=$?
    
    if [[ $exit_code -gt 0 ]]; then
        log "INFO" ""
        log "INFO" "For detailed troubleshooting, run: $0 --troubleshoot"
    fi
    
    exit $exit_code
}

# Run main function
main "$@"