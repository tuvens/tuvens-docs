#!/usr/bin/env bash
# File: test-code-review-system.sh
# Purpose: Comprehensive test suite for /code-review slash command and QA agent
# 
# Tests the code review system functionality including command parsing,
# script execution, QA agent setup, and D/E principle enforcement

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test result tracking
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Find script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

echo -e "${BLUE}🧪 Code Review System Test Suite${NC}"
echo "=================================="
echo "Testing /code-review command and QA agent functionality"
echo ""

# Helper functions
log_test() {
    echo -e "${BLUE}Testing:${NC} $1"
}

log_success() {
    echo -e "${GREEN}✓ PASS:${NC} $1"
    ((TESTS_PASSED++))
}

log_failure() {
    echo -e "${RED}✗ FAIL:${NC} $1"
    ((TESTS_FAILED++))
}

log_warning() {
    echo -e "${YELLOW}⚠ WARNING:${NC} $1"
}

run_test() {
    ((TESTS_RUN++))
    "$@"
}

# Test 1: Code Review Command Existence and Permissions
test_code_review_command_exists() {
    log_test "Code review command exists and is executable"
    
    local code_review_cmd="$REPO_ROOT/code-review"
    
    if [[ ! -f "$code_review_cmd" ]]; then
        log_failure "Code review command not found at: $code_review_cmd"
        return 1
    fi
    
    if [[ ! -x "$code_review_cmd" ]]; then
        log_failure "Code review command is not executable: $code_review_cmd"
        return 1
    fi
    
    log_success "Code review command exists and is executable"
    return 0
}

# Test 2: Code Review Desktop Script Existence
test_code_review_desktop_script_exists() {
    log_test "Code review desktop script exists and is executable"
    
    local desktop_script="$SCRIPT_DIR/setup-code-review-desktop.sh"
    
    if [[ ! -f "$desktop_script" ]]; then
        log_failure "Desktop script not found at: $desktop_script"
        return 1
    fi
    
    if [[ ! -x "$desktop_script" ]]; then
        log_failure "Desktop script is not executable: $desktop_script"
        return 1
    fi
    
    log_success "Code review desktop script exists and is executable"
    return 0
}

# Test 3: QA Agent Configuration Exists
test_qa_agent_config_exists() {
    log_test "QA agent configuration exists and is valid"
    
    local qa_config="$REPO_ROOT/agentic-development/desktop-project-instructions/agents/qa.md"
    
    if [[ ! -f "$qa_config" ]]; then
        log_failure "QA agent configuration not found at: $qa_config"
        return 1
    fi
    
    # Check for required sections
    local required_sections=(
        "Agent Identity"
        "D/E Principle"
        "Technical Quality Standards"
        "Test Coverage"
        "Anti-Over-Engineering Safeguards"
        "GitHub Comment Standards"
    )
    
    for section in "${required_sections[@]}"; do
        if ! grep -q "$section" "$qa_config"; then
            log_failure "QA agent config missing required section: $section"
            return 1
        fi
    done
    
    log_success "QA agent configuration exists with required sections"
    return 0
}

# Test 4: Command Usage Display
test_code_review_usage() {
    log_test "Code review command displays proper usage information"
    
    local code_review_cmd="$REPO_ROOT/code-review"
    
    # Test help flag
    if ! "$code_review_cmd" --help 2>/dev/null | grep -q "Usage:"; then
        log_failure "Code review command doesn't display usage with --help"
        return 1
    fi
    
    # Test no arguments
    if ! "$code_review_cmd" 2>&1 | grep -q "Usage:"; then
        log_failure "Code review command doesn't display usage with no arguments"
        return 1
    fi
    
    log_success "Code review command displays proper usage information"
    return 0
}

# Test 5: Shared Functions Integration
test_shared_functions_integration() {
    log_test "Code review scripts properly integrate with shared functions"
    
    local desktop_script="$SCRIPT_DIR/setup-code-review-desktop.sh"
    local shared_functions="$SCRIPT_DIR/shared-functions.sh"
    
    if [[ ! -f "$shared_functions" ]]; then
        log_failure "Shared functions file not found: $shared_functions"
        return 1
    fi
    
    # Check if desktop script sources shared functions
    if ! grep -q "source.*shared-functions.sh" "$desktop_script"; then
        log_failure "Desktop script doesn't source shared functions"
        return 1
    fi
    
    # Check for usage of shared functions
    local shared_function_usage=(
        "calculate_branch_name"
        "get_worktree_path"
        "make_path_portable"
        "check_pr_review_safeguards"
    )
    
    for func in "${shared_function_usage[@]}"; do
        if ! grep -q "$func" "$desktop_script"; then
            log_warning "Desktop script may not use shared function: $func"
        fi
    done
    
    log_success "Code review scripts integrate with shared functions"
    return 0
}

# Test 6: Parameter Parsing Validation
test_parameter_parsing() {
    log_test "Code review command parameter parsing"
    
    local desktop_script="$SCRIPT_DIR/setup-code-review-desktop.sh"
    
    # Check for proper parameter parsing patterns
    local parsing_patterns=(
        "PR_NUMBER.*#"
        "ISSUE_NUMBER"
        "CONTEXT_FILE"
        "--context="
        "while.*\[\[ \$# -gt 0 \]\]"
    )
    
    for pattern in "${parsing_patterns[@]}"; do
        if ! grep -q "$pattern" "$desktop_script"; then
            log_failure "Desktop script missing parameter parsing for: $pattern"
            return 1
        fi
    done
    
    log_success "Code review command has proper parameter parsing"
    return 0
}

# Test 7: Technical Principles Documentation Validation
test_technical_principles_documentation() {
    log_test "All technical principles (D/E, R/R, C/C) properly documented and enforced"
    
    local qa_config="$REPO_ROOT/agentic-development/desktop-project-instructions/agents/qa.md"
    
    # Check for all principle key concepts
    local principle_concepts=(
        "Demonstration-over-Explanation"
        "PROVE their claims with evidence"
        "Show actual proof"
        "NO unsubstantiated claims"
        "every assertion must be backed by evidence"
        "Recognition-over-Recall"
        "file.*folder.*structure"
        "Convention-over-Configuration"
        "framework.*pattern"
        "DRY.*KISS.*TDD.*R/R.*C/C"
    )
    
    for concept in "${principle_concepts[@]}"; do
        if ! grep -q "$concept" "$qa_config"; then
            log_failure "QA config missing principle concept: $concept"
            return 1
        fi
    done
    
    log_success "All technical principles (D/E, R/R, C/C) properly documented"
    return 0
}

# Test 8: GitHub CLI Integration
test_github_cli_integration() {
    log_test "GitHub CLI integration for PR and issue fetching"
    
    local desktop_script="$SCRIPT_DIR/setup-code-review-desktop.sh"
    
    # Check for GitHub CLI command usage
    local gh_commands=(
        "gh pr view"
        "gh issue view"
        "gh issue create"
        "gh pr diff"
    )
    
    for cmd in "${gh_commands[@]}"; do
        if ! grep -q "$cmd" "$desktop_script"; then
            log_failure "Desktop script missing GitHub CLI command: $cmd"
            return 1
        fi
    done
    
    # Check for JSON parsing with jq
    if ! grep -q "jq -r" "$desktop_script"; then
        log_failure "Desktop script missing jq JSON parsing"
        return 1
    fi
    
    log_success "GitHub CLI integration properly implemented"
    return 0
}

# Test 9: Test Coverage Analysis Integration
test_coverage_analysis_integration() {
    log_test "Test coverage analysis and validation features"
    
    local qa_config="$REPO_ROOT/agentic-development/desktop-project-instructions/agents/qa.md"
    
    # Check for test coverage commands and patterns
    local coverage_patterns=(
        "npm.*coverage"
        "pytest.*coverage"
        "jest.*coverage"
        "Coverage Standards"
        "85% line coverage"
    )
    
    for pattern in "${coverage_patterns[@]}"; do
        if ! grep -q "$pattern" "$qa_config"; then
            log_failure "QA config missing coverage pattern: $pattern"
            return 1
        fi
    done
    
    log_success "Test coverage analysis properly integrated"
    return 0
}

# Test 10: Comment Management System
test_comment_management_system() {
    log_test "Comment management system for long reviews"
    
    local qa_config="$REPO_ROOT/agentic-development/desktop-project-instructions/agents/qa.md"
    local desktop_script="$SCRIPT_DIR/setup-code-review-desktop.sh"
    
    # Check for comment management features
    local comment_features=(
        "Break.*comment.*segment"
        "GitHub Comment Standards"
        "manageable comment segments"
        "Part 1:"
        "Part 2:"
    )
    
    for feature in "${comment_features[@]}"; do
        if ! grep -q "$feature" "$qa_config"; then
            log_failure "QA config missing comment management feature: $feature"
            return 1
        fi
    done
    
    log_success "Comment management system properly implemented"
    return 0
}

# Test 11: Safety Integration with CLAUDE.md
test_safety_integration() {
    log_test "Safety integration with CLAUDE.md rules"
    
    local desktop_script="$SCRIPT_DIR/setup-code-review-desktop.sh"
    local qa_config="$REPO_ROOT/agentic-development/desktop-project-instructions/agents/qa.md"
    
    # Check for CLAUDE.md references
    if ! grep -q "CLAUDE.md" "$desktop_script"; then
        log_failure "Desktop script doesn't reference CLAUDE.md safety rules"
        return 1
    fi
    
    # Check for safety considerations in QA config
    local safety_features=(
        "Safety"
        "Branch.*target"
        "Quality.*gate"
        "Standards"
    )
    
    for feature in "${safety_features[@]}"; do
        if ! grep -qi "$feature" "$qa_config"; then
            log_warning "QA config may be missing safety feature: $feature"
        fi
    done
    
    log_success "Safety integration properly implemented"
    return 0
}

# Test 12: Prompt Generation Validation
test_prompt_generation() {
    log_test "QA agent prompt generation functionality"
    
    local desktop_script="$SCRIPT_DIR/setup-code-review-desktop.sh"
    
    # Check for prompt file creation
    if ! grep -q "qa-code-review-prompt.txt" "$desktop_script"; then
        log_failure "Desktop script doesn't create QA prompt file"
        return 1
    fi
    
    # Check for comprehensive prompt sections
    local prompt_sections=(
        "GitHub Issue:"
        "D/E Principle Enforcement"
        "Technical Quality Review"
        "Test Validation"
        "Systematic Review Response"
        "Success Criteria"
    )
    
    for section in "${prompt_sections[@]}"; do
        if ! grep -q "$section" "$desktop_script"; then
            log_failure "Desktop script prompt missing section: $section"
            return 1
        fi
    done
    
    log_success "QA agent prompt generation properly implemented"
    return 0
}

# Test 13: Desktop Script Principles Integration
test_desktop_script_principles_integration() {
    log_test "Desktop script integrates all technical principles"
    
    local desktop_script="$SCRIPT_DIR/setup-code-review-desktop.sh"
    
    # Check for principle integration in desktop script
    local desktop_principle_patterns=(
        "DRY.*KISS.*TDD.*R/R.*C/C"
        "file.*folder.*structure"
        "pattern.*consistency"
        "convention.*compliance"
        "Recognition-over-Recall"
        "Convention-over-Configuration"
    )
    
    for pattern in "${desktop_principle_patterns[@]}"; do
        if ! grep -q "$pattern" "$desktop_script"; then
            log_failure "Desktop script missing principle pattern: $pattern"
            return 1
        fi
    done
    
    log_success "Desktop script integrates all technical principles"
    return 0
}

# Test 14: Script Integration Test (Dry Run)
test_script_integration_dry_run() {
    log_test "Script integration dry run (syntax and basic validation)"
    
    local code_review_cmd="$REPO_ROOT/code-review"
    local desktop_script="$SCRIPT_DIR/setup-code-review-desktop.sh"
    
    # Test bash syntax
    if ! bash -n "$code_review_cmd"; then
        log_failure "Code review command has syntax errors"
        return 1
    fi
    
    if ! bash -n "$desktop_script"; then
        log_failure "Desktop script has syntax errors"
        return 1
    fi
    
    # Test with invalid arguments (should show usage)
    if "$code_review_cmd" invalid-args 2>&1 | grep -q "ERROR"; then
        log_success "Code review command properly handles invalid arguments"
    else
        log_failure "Code review command doesn't handle invalid arguments properly"
        return 1
    fi
    
    log_success "Script integration dry run successful"
    return 0
}

# Main test execution
main() {
    echo "Starting comprehensive code review system tests..."
    echo ""
    
    # Run all tests
    run_test test_code_review_command_exists
    run_test test_code_review_desktop_script_exists
    run_test test_qa_agent_config_exists
    run_test test_code_review_usage
    run_test test_shared_functions_integration
    run_test test_parameter_parsing
    run_test test_technical_principles_documentation
    run_test test_github_cli_integration
    run_test test_coverage_analysis_integration
    run_test test_comment_management_system
    run_test test_safety_integration
    run_test test_prompt_generation
    run_test test_desktop_script_principles_integration
    run_test test_script_integration_dry_run
    
    # Display results
    echo ""
    echo "=================================="
    echo -e "${BLUE}Test Results Summary${NC}"
    echo "=================================="
    echo "Tests Run: $TESTS_RUN"
    echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
    
    if [[ $TESTS_FAILED -gt 0 ]]; then
        echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"
        echo ""
        echo -e "${RED}Some tests failed. Please review the failures above.${NC}"
        exit 1
    else
        echo -e "Tests Failed: ${GREEN}0${NC}"
        echo ""
        echo -e "${GREEN}All tests passed! Code review system is properly implemented.${NC}"
        exit 0
    fi
}

# Run main function
main "$@"