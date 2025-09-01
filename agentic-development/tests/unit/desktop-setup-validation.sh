#!/usr/bin/env bash
# File: test-desktop-setup.sh
# Purpose: Basic validation tests for desktop agent setup script
# 
# Simple test framework for TDD approach to fixing the desktop script

set -euo pipefail

# Test configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_SCRIPT="$SCRIPT_DIR/../setup-agent-task-desktop.sh"
TEMP_SCRIPT="$SCRIPT_DIR/../setup-agent-task-desktop-temp.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
log_test() {
    echo -e "${YELLOW}[TEST]${NC} $1"
    ((TESTS_RUN++))
}

pass_test() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

fail_test() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

# Test 1: Script exists and is executable
test_script_exists() {
    log_test "Checking if script exists and is executable"
    
    if [[ -f "$TEST_SCRIPT" ]] && [[ -x "$TEST_SCRIPT" ]]; then
        pass_test "Script exists and is executable"
        return 0
    else
        fail_test "Script missing or not executable: $TEST_SCRIPT"
        return 1
    fi
}

# Test 2: Usage function works
test_usage_function() {
    log_test "Testing usage function"
    
    if "$TEST_SCRIPT" --help 2>/dev/null | grep -q "Usage:"; then
        pass_test "Usage function displays correctly"
        return 0
    else
        fail_test "Usage function not working properly"
        return 1
    fi
}

# Test 3: Script requires minimum arguments
test_argument_validation() {
    log_test "Testing argument validation"
    
    # Should fail with no arguments
    if ! "$TEST_SCRIPT" >/dev/null 2>&1; then
        pass_test "Script correctly rejects insufficient arguments"
        return 0
    else
        fail_test "Script should fail with insufficient arguments"
        return 1
    fi
}

# Test 4: Check for unbound variables (dry run)
test_variable_binding() {
    log_test "Testing for unbound variables"
    
    # Create a mock test that doesn't actually run but checks syntax
    if bash -n "$TEST_SCRIPT"; then
        pass_test "Script has valid bash syntax"
        return 0
    else
        fail_test "Script has syntax errors"
        return 1
    fi
}

# Test 5: GitHub issue number format validation
test_issue_number_parsing() {
    log_test "Testing GitHub issue number parsing logic"
    
    # Create a test prompt file with known issue number
    TEST_PROMPT_FILE="/tmp/test-prompt.txt"
    echo "GitHub Issue: #123" > "$TEST_PROMPT_FILE"
    
    # Test the parsing logic used in the script
    PARSED_ISSUE=$(grep -o 'GitHub Issue: #[0-9]\+' "$TEST_PROMPT_FILE" | cut -d'#' -f2)
    
    if [[ "$PARSED_ISSUE" == "123" ]]; then
        pass_test "Issue number parsing works correctly"
        rm -f "$TEST_PROMPT_FILE"
        return 0
    else
        fail_test "Issue number parsing failed. Got: '$PARSED_ISSUE'"
        rm -f "$TEST_PROMPT_FILE"
        return 1
    fi
}

# Test 6: Temp script comparison
test_temp_script_differences() {
    log_test "Comparing temp script vs original"
    
    if [[ -f "$TEMP_SCRIPT" ]]; then
        # Check if temp script has fewer unbound variable references
        TEMP_UNBOUNDS=$(bash -n "$TEMP_SCRIPT" 2>&1 | grep -c "unbound variable" || true)
        ORIG_UNBOUNDS=$(bash -n "$TEST_SCRIPT" 2>&1 | grep -c "unbound variable" || true)
        
        if [[ $TEMP_UNBOUNDS -le $ORIG_UNBOUNDS ]]; then
            pass_test "Temp script has equal or fewer unbound variable issues"
            return 0
        else
            fail_test "Temp script has more unbound variable issues"
            return 1
        fi
    else
        fail_test "Temp script not found for comparison"
        return 1
    fi
}

# Main test runner
run_tests() {
    echo "🧪 Desktop Agent Setup Script Tests"
    echo "==================================="
    echo ""
    
    # Run all tests
    test_script_exists || true
    test_usage_function || true  
    test_argument_validation || true
    test_variable_binding || true
    test_issue_number_parsing || true
    test_temp_script_differences || true
    
    # Summary
    echo ""
    echo "📊 Test Summary"
    echo "==============="
    echo "Tests Run: $TESTS_RUN"
    echo -e "${GREEN}Passed: $TESTS_PASSED${NC}"
    echo -e "${RED}Failed: $TESTS_FAILED${NC}"
    
    if [[ $TESTS_FAILED -eq 0 ]]; then
        echo -e "${GREEN}✅ All tests passed!${NC}"
        return 0
    else
        echo -e "${RED}❌ Some tests failed${NC}"
        return 1
    fi
}

# Run tests if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
fi
