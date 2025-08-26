#!/usr/bin/env bash
# File: test-update-command.sh
# Purpose: Test suite for /update slash command
# 
# This script validates the /update command functionality including
# context inference, argument parsing, and error handling.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing /update Slash Command${NC}"
echo "================================="
echo ""

# Test counter
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run test
run_test() {
    local test_name="$1"
    local test_command="$2"
    local expected_exit_code="${3:-0}"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: $test_name${NC}"
    
    if eval "$test_command" >/dev/null 2>&1; then
        actual_exit_code=0
    else
        actual_exit_code=$?
    fi
    
    if [[ "$actual_exit_code" -eq "$expected_exit_code" ]]; then
        echo -e "  ${GREEN}✅ PASSED${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}❌ FAILED (expected exit code $expected_exit_code, got $actual_exit_code)${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# Function to check if script exists and is executable
check_script_exists() {
    local script_path="$1"
    if [[ -f "$script_path" && -x "$script_path" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to test help functionality
test_help() {
    local test_name="Help functionality"
    local help_output
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: $test_name${NC}"
    
    # Help exits with code 1, so capture that properly
    help_output=$(./update --help 2>&1 || true)
    if [[ "$help_output" == *"Usage: /update"* ]] && [[ "$help_output" == *"Examples:"* ]]; then
        echo -e "  ${GREEN}✅ PASSED - Help displays usage and examples${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}❌ FAILED - Help output incomplete${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# Function to test argument parsing
test_argument_parsing() {
    local test_name="Invalid argument handling"
    local output
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: $test_name${NC}"
    
    # Test with a predefined message to avoid interactive prompt
    # Capture output regardless of exit code
    output=$(echo "test message" | ./update XYZ123 2>&1 || true)
    if [[ "$output" == *"Invalid argument format"* ]]; then
        echo -e "  ${GREEN}✅ PASSED - Invalid arguments handled gracefully${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}❌ FAILED - Invalid arguments not handled properly${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# Function to test context inference (dry run style)
test_context_inference() {
    local test_name="Context inference functionality"
    local output
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: $test_name${NC}"
    
    # Test with a predefined message to avoid interactive prompt
    if output=$(echo "test context inference" | ./update 2>&1 || true); then
        if [[ "$output" == *"Inferring context from branch"* ]]; then
            echo -e "  ${GREEN}✅ PASSED - Context inference attempted${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "  ${RED}❌ FAILED - Context inference not working${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "  ${RED}❌ FAILED - Context inference failed${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# Function to test message creation
test_message_creation() {
    local test_name="Message standardization"
    local script_dir
    script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: $test_name${NC}"
    
    # Test that the script can create standardized messages
    # We'll test the core script directly to avoid GitHub API calls
    if [[ -f "$script_dir/update-comments.sh" ]]; then
        local output
        # Mock a test to verify message functions exist
        output=$(bash -c "source '$script_dir/update-comments.sh'; declare -f create_update_message >/dev/null && echo 'function_exists'" 2>/dev/null || echo "function_missing")
        
        if [[ "$output" == "function_exists" ]]; then
            echo -e "  ${GREEN}✅ PASSED - Message creation functions available${NC}"
            TESTS_PASSED=$((TESTS_PASSED + 1))
        else
            echo -e "  ${RED}❌ FAILED - Message creation functions missing${NC}"
            TESTS_FAILED=$((TESTS_FAILED + 1))
        fi
    else
        echo -e "  ${RED}❌ FAILED - Core script not found${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# Main test execution
main() {
    # Check if /update script exists
    if ! check_script_exists "./update"; then
        echo -e "${RED}❌ ERROR: ./update script not found or not executable${NC}"
        exit 1
    fi
    
    # Check if core script exists
    if ! check_script_exists "./agentic-development/scripts/update-comments.sh"; then
        echo -e "${RED}❌ ERROR: ./agentic-development/scripts/update-comments.sh not found or not executable${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Scripts exist and are executable${NC}"
    echo ""
    
    # Run tests
    test_help
    test_argument_parsing
    test_context_inference
    test_message_creation
    
    # Test basic functionality
    run_test "Script exists and has execute permissions" "test -x ./update"
    run_test "Core script exists and has execute permissions" "test -x ./agentic-development/scripts/update-comments.sh"
    run_test "Help flag works" "./update -h" 1
    
    # Summary
    echo "================================="
    echo -e "${BLUE}📊 Test Results Summary${NC}"
    echo "================================="
    echo -e "Total tests run: ${TESTS_RUN}"
    echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
    echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 ALL TESTS PASSED!${NC}"
        echo -e "${GREEN}/update command is working correctly${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Some tests failed${NC}"
        exit 1
    fi
}

# Execute main function
main "$@"