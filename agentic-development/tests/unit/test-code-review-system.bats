#!/usr/bin/env bats
# Unit tests for agentic-development/scripts/test-code-review-system.sh
# TDD Test Suite - Testing code review system test functionality

# Load test setup
load setup

# Setup for each test
setup() {
    export SCRIPT_UNDER_TEST="$TEST_PROJECT_ROOT/scripts/test-code-review-system.sh"
    export TEST_REPO_DIR
    TEST_REPO_DIR=$(setup_test_git_repo)
    
    # Create minimal test environment
    cd "$TEST_REPO_DIR"
    echo "# CLAUDE.md" > CLAUDE.md
    echo '{"name": "test-project"}' > package.json
    mkdir -p agentic-development/{scripts,desktop-project-instructions/agents,docs}
    
    # Create the files that the test script expects to exist
    touch code-review
    chmod +x code-review
    
    touch agentic-development/scripts/setup-code-review-desktop.sh
    chmod +x agentic-development/scripts/setup-code-review-desktop.sh
    
    # Create QA agent configuration
    cat > agentic-development/desktop-project-instructions/agents/qa.md << 'EOF'
# QA Agent - Technical Quality Assurance Specialist

## Agent Identity
**Primary Role**: Technical Quality Assurance and Code Review Leadership

## D/E Principle (Demonstration-over-Explanation)
PROVE their claims with evidence
Show actual proof
NO unsubstantiated claims
every assertion must be backed by evidence

## Technical Quality Standards (DRY, KISS, TDD, R/R, C/C)
Recognition-over-Recall
file folder structure
Convention-over-Configuration
framework pattern
DRY KISS TDD R/R C/C
EOF

    # Create D/E principle documentation
    cat > agentic-development/docs/de-principle-documentation.md << 'EOF'
# D/E Principle: Demonstration-over-Explanation
Demonstration-over-Explanation
PROVE their claims with evidence
Show actual proof
Recognition-over-Recall
file folder structure
Convention-over-Configuration
framework pattern
DRY KISS TDD R/R C/C
EOF

    # Create shared functions
    cat > agentic-development/scripts/shared-functions.sh << 'EOF'
#!/bin/bash
echo "shared functions available"
EOF
    chmod +x agentic-development/scripts/shared-functions.sh
}

# Cleanup after each test
teardown() {
    if [ -n "${TEST_REPO_DIR:-}" ]; then
        teardown_test_git_repo "$TEST_REPO_DIR"
    fi
}

# Test: Script exists and is executable
@test "test-code-review-system.sh exists and is executable" {
    [ -f "$SCRIPT_UNDER_TEST" ]
    [ -x "$SCRIPT_UNDER_TEST" ]
}

# Test: Script has valid bash syntax
@test "test-code-review-system.sh has valid bash syntax" {
    bash -n "$SCRIPT_UNDER_TEST"
}

# Test: Script defines test functions
@test "test-code-review-system.sh defines test functions" {
    grep -q "test_code_review_command_exists" "$SCRIPT_UNDER_TEST"
    grep -q "test_qa_agent_config_exists" "$SCRIPT_UNDER_TEST"
    grep -q "test_technical_principles_documentation" "$SCRIPT_UNDER_TEST"
}

# Test: Script has proper test result tracking
@test "test-code-review-system.sh tracks test results" {
    grep -q "TESTS_RUN" "$SCRIPT_UNDER_TEST"
    grep -q "TESTS_PASSED" "$SCRIPT_UNDER_TEST"
    grep -q "TESTS_FAILED" "$SCRIPT_UNDER_TEST"
}

# Test: Script has color output support
@test "test-code-review-system.sh has colored output" {
    grep -q "RED=" "$SCRIPT_UNDER_TEST"
    grep -q "GREEN=" "$SCRIPT_UNDER_TEST"
    grep -q "NC=" "$SCRIPT_UNDER_TEST"
}

# Test: Script has helper functions
@test "test-code-review-system.sh has helper functions" {
    grep -q "log_test" "$SCRIPT_UNDER_TEST"
    grep -q "log_success" "$SCRIPT_UNDER_TEST"
    grep -q "log_failure" "$SCRIPT_UNDER_TEST"
    grep -q "run_test" "$SCRIPT_UNDER_TEST"
}

# Test: Script validates code review command
@test "test-code-review-system.sh validates code review command" {
    grep -q "code-review.*executable" "$SCRIPT_UNDER_TEST"
}

# Test: Script validates QA agent configuration
@test "test-code-review-system.sh validates QA configuration" {
    grep -q "qa.md" "$SCRIPT_UNDER_TEST"
    grep -q "Agent Identity" "$SCRIPT_UNDER_TEST"
}

# Test: Script validates D/E principle documentation
@test "test-code-review-system.sh validates D/E documentation" {
    grep -q "D/E.*principle" "$SCRIPT_UNDER_TEST"
    grep -q "principle_concepts" "$SCRIPT_UNDER_TEST"
}

# Test: Script validates GitHub CLI integration
@test "test-code-review-system.sh validates GitHub CLI" {
    grep -q "gh.*pr.*view" "$SCRIPT_UNDER_TEST"
    grep -q "gh.*issue.*create" "$SCRIPT_UNDER_TEST"
}

# Test: Script validates test coverage integration
@test "test-code-review-system.sh validates test coverage" {
    grep -q "coverage.*analysis" "$SCRIPT_UNDER_TEST"
    grep -q "npm.*coverage" "$SCRIPT_UNDER_TEST"
}

# Test: Script validates comment management
@test "test-code-review-system.sh validates comment management" {
    grep -q "comment.*management" "$SCRIPT_UNDER_TEST"
    grep -q "GitHub.*Comment.*Standards" "$SCRIPT_UNDER_TEST"
}

# Test: Script validates safety integration
@test "test-code-review-system.sh validates safety integration" {
    grep -q "CLAUDE.md" "$SCRIPT_UNDER_TEST"
    grep -q "safety" "$SCRIPT_UNDER_TEST"
}

# Test: Script validates prompt generation
@test "test-code-review-system.sh validates prompt generation" {
    grep -q "qa-code-review-prompt.txt" "$SCRIPT_UNDER_TEST"
    grep -q "prompt.*generation" "$SCRIPT_UNDER_TEST"
}

# Test: Script validates all technical principles
@test "test-code-review-system.sh validates all principles" {
    grep -q "R/R" "$SCRIPT_UNDER_TEST"
    grep -q "C/C" "$SCRIPT_UNDER_TEST"
    grep -q "Recognition-over-Recall" "$SCRIPT_UNDER_TEST"
    grep -q "Convention-over-Configuration" "$SCRIPT_UNDER_TEST"
}

# Test: Script has main execution function
@test "test-code-review-system.sh has main execution" {
    grep -q "main()" "$SCRIPT_UNDER_TEST"
    grep -q "run_test.*test_" "$SCRIPT_UNDER_TEST"
}

# Test: Script provides comprehensive results summary
@test "test-code-review-system.sh provides results summary" {
    grep -q "Test.*Results.*Summary" "$SCRIPT_UNDER_TEST"
    grep -q "Tests.*Run" "$SCRIPT_UNDER_TEST"
    grep -q "Tests.*Passed" "$SCRIPT_UNDER_TEST"
    grep -q "Tests.*Failed" "$SCRIPT_UNDER_TEST"
}