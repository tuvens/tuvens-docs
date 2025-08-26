#!/usr/bin/env bash
# File: test-check-command.sh
# Purpose: Test suite for /check slash command
# 
# This script validates the /check command functionality including
# context inference, argument parsing, and error handling.

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing /check Slash Command${NC}"
echo "================================"
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
    help_output=$(./check --help 2>&1 || true)
    if [[ "$help_output" == *"Usage: /check"* ]] && [[ "$help_output" == *"Examples:"* ]]; then
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
    
    # Capture output regardless of exit code
    output=$(./check XYZ123 2>&1 || true)
    if [[ "$output" == *"Invalid argument format"* ]]; then
        echo -e "  ${GREEN}✅ PASSED - Invalid arguments handled gracefully${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "  ${RED}❌ FAILED - Invalid arguments not handled properly${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
    fi
    echo ""
}

# Function to test context inference
test_context_inference() {
    local test_name="Context inference functionality"
    local output
    
    TESTS_RUN=$((TESTS_RUN + 1))
    echo -e "${YELLOW}Test $TESTS_RUN: $test_name${NC}"
    
    if output=$(./check 2>&1); then
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

# Main test execution
main() {
    # Check if /check script exists
    if ! check_script_exists "./check"; then
        echo -e "${RED}❌ ERROR: ./check script not found or not executable${NC}"
        exit 1
    fi
    
    # Check if core script exists
    if ! check_script_exists "./agentic-development/scripts/check-comments.sh"; then
        echo -e "${RED}❌ ERROR: ./agentic-development/scripts/check-comments.sh not found or not executable${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Scripts exist and are executable${NC}"
    echo ""
    
    # Run tests
    test_help
    test_argument_parsing
    test_context_inference
    
    # Test basic functionality
    run_test "Script exists and has execute permissions" "test -x ./check"
    run_test "Core script exists and has execute permissions" "test -x ./agentic-development/scripts/check-comments.sh"
    run_test "Help flag works" "./check -h" 1
    
    # Summary
    echo "================================"
    echo -e "${BLUE}📊 Test Results Summary${NC}"
    echo "================================"
    echo -e "Total tests run: ${TESTS_RUN}"
    echo -e "${GREEN}Passed: ${TESTS_PASSED}${NC}"
    echo -e "${RED}Failed: ${TESTS_FAILED}${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "\n${GREEN}🎉 ALL TESTS PASSED!${NC}"
        echo -e "${GREEN}/check command is working correctly${NC}"
        exit 0
    else
        echo -e "\n${RED}❌ Some tests failed${NC}"
        exit 1
    fi
}

# Execute main function
main "$@"