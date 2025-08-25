#!/usr/bin/env bats
# Unit tests for agentic-development/scripts/test.sh
# TDD Test Suite - Testing the main test runner functionality

# Load test setup
load setup

# Setup for each test
setup() {
    export SCRIPT_UNDER_TEST="$PWD/agentic-development/scripts/test.sh"
    export TEST_REPO_DIR
    TEST_REPO_DIR=$(setup_test_git_repo)
    
    # Create minimal test environment
    cd "$TEST_REPO_DIR"
    echo "# CLAUDE.md" > CLAUDE.md
    echo '{"name": "test-project"}' > package.json
    mkdir -p agentic-development/scripts
    mkdir -p .github/workflows
}

# Teardown after each test
teardown() {
    teardown_test_git_repo "$TEST_REPO_DIR"
}

@test "validate_environment: passes with required files present" {
    # Source the test script functions
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "test.sh not found"
    fi
    
    run validate_environment
    [ "$status" -eq 0 ]
}

@test "validate_environment: fails when CLAUDE.md missing" {
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "test.sh not found"
    fi
    
    rm -f CLAUDE.md
    run validate_environment
    [ "$status" -ne 0 ]
}

@test "validate_environment: fails when package.json missing" {
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "test.sh not found"
    fi
    
    rm -f package.json
    run validate_environment
    [ "$status" -ne 0 ]
}

@test "validate_json_structure: validates active-branches.json format" {
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "test.sh not found"
    fi
    
    # Create valid active-branches.json
    cat > test-branches.json << 'EOF'
{
    "lastUpdated": "2025-08-25T20:00:00Z",
    "generatedBy": "test",
    "tuvensStrategy": "5-branch",
    "branches": {}
}
EOF
    
    run validate_json_structure "test-branches.json" "active-branches"
    [ "$status" -eq 0 ]
}

@test "validate_json_structure: rejects invalid active-branches.json format" {
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "test.sh not found"
    fi
    
    # Create invalid active-branches.json
    cat > test-branches.json << 'EOF'
{
    "invalid": "structure"
}
EOF
    
    run validate_json_structure "test-branches.json" "active-branches"
    [ "$status" -ne 0 ]
}

@test "determine_test_level: returns 'full' for CI environment" {
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "test.sh not found"
    fi
    
    export CI=true
    result=$(determine_test_level "")
    [ "$result" = "full" ]
}

@test "determine_test_level: returns 'quick' for feature branches" {
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "test.sh not found"
    fi
    
    # Mock current branch
    git checkout -b feature/test-branch
    export CI=false
    
    result=$(determine_test_level "")
    [ "$result" = "quick" ]
}

@test "determine_test_level: respects command line arguments" {
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "test.sh not found"
    fi
    
    result=$(determine_test_level "--integration")
    [ "$result" = "integration" ]
}

@test "run_test: executes test function and tracks results" {
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "test.sh not found"
    fi
    
    # Test function that passes
    test_function() { return 0; }
    
    run run_test "Test that passes" test_function
    [ "$status" -eq 0 ]
}

@test "run_test: handles failing test function" {
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "test.sh not found"
    fi
    
    # Test function that fails
    test_function() { return 1; }
    
    run run_test "Test that fails" test_function
    [ "$status" -eq 1 ]
}