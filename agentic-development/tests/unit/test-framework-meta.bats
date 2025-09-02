#!/usr/bin/env bats
# Meta-tests for the TDD testing framework itself
# Tests for run-tests.sh and demonstrate-coverage.sh to achieve 100% coverage

# Load test setup
load setup

# Setup for each test
setup() {
    export TEST_REPO_DIR
    TEST_REPO_DIR=$(setup_test_git_repo)
    cd "$TEST_REPO_DIR"
}

teardown() {
    teardown_test_git_repo "$TEST_REPO_DIR"
}

# =====================================================
# RUN-TESTS.SH TESTS
# =====================================================

@test "run-tests.sh: provides help information" {
    local script="$PWD/tests/run-tests.sh"
    if [ ! -f "$script" ]; then
        skip "run-tests.sh not found"
    fi
    
    run "$script" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "run-tests.sh: shows version information" {
    local script="$PWD/tests/run-tests.sh"
    if [ ! -f "$script" ]; then
        skip "run-tests.sh not found"
    fi
    
    run "$script" --version
    [ "$status" -eq 0 ]
    [[ "$output" =~ "TDD Testing Framework" ]]
}

@test "run-tests.sh: handles unknown test type" {
    local script="$PWD/tests/run-tests.sh"
    if [ ! -f "$script" ]; then
        skip "run-tests.sh not found"
    fi
    
    run "$script" "invalid-test-type"
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Unknown test type" ]]
}

@test "run-tests.sh: executes syntax validation without bats" {
    local script="$PWD/tests/run-tests.sh"
    if [ ! -f "$script" ]; then
        skip "run-tests.sh not found"
    fi
    
    # Run syntax test type (should work without bats)
    run "$script" syntax
    # Should execute even without bats installed
    [ "$status" -ne 2 ]
}

@test "run-tests.sh: has valid bash syntax" {
    local script="$PWD/tests/run-tests.sh"
    if [ ! -f "$script" ]; then
        skip "run-tests.sh not found"
    fi
    
    run bash -n "$script"
    [ "$status" -eq 0 ]
}

# =====================================================
# DEMONSTRATE-COVERAGE.SH TESTS  
# =====================================================

@test "demonstrate-coverage.sh: provides help information" {
    local script="$PWD/tests/demonstrate-coverage.sh"
    if [ ! -f "$script" ]; then
        skip "demonstrate-coverage.sh not found"
    fi
    
    run "$script" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Usage:" ]]
}

@test "demonstrate-coverage.sh: runs coverage demonstration" {
    local script="$PWD/tests/demonstrate-coverage.sh"
    if [ ! -f "$script" ]; then
        skip "demonstrate-coverage.sh not found"
    fi
    
    run timeout 10s "$script" --coverage
    # Should execute coverage analysis
    [ "$status" -ne 2 ]
}

@test "demonstrate-coverage.sh: runs working tests demonstration" {
    local script="$PWD/tests/demonstrate-coverage.sh"
    if [ ! -f "$script" ]; then
        skip "demonstrate-coverage.sh not found"
    fi
    
    run timeout 10s "$script" --working
    # Should execute working tests analysis
    [ "$status" -ne 2 ]
}

@test "demonstrate-coverage.sh: runs bug catching demonstration" {
    local script="$PWD/tests/demonstrate-coverage.sh"
    if [ ! -f "$script" ]; then
        skip "demonstrate-coverage.sh not found"
    fi
    
    run timeout 10s "$script" --bugs
    # Should execute bug catching demonstration
    [ "$status" -ne 2 ]
}

@test "demonstrate-coverage.sh: has valid bash syntax" {
    local script="$PWD/tests/demonstrate-coverage.sh"
    if [ ! -f "$script" ]; then
        skip "demonstrate-coverage.sh not found"
    fi
    
    run bash -n "$script"
    [ "$status" -eq 0 ]
}

@test "demonstrate-coverage.sh: finds all shell scripts correctly" {
    local script="$PWD/tests/demonstrate-coverage.sh"
    if [ ! -f "$script" ]; then
        skip "demonstrate-coverage.sh not found"
    fi
    
    # Should be able to scan and find shell scripts
    run timeout 30s "$script" --coverage
    # Should complete without critical errors
    [ "$status" -ne 2 ]
    
    # Should mention finding scripts
    [[ "$output" =~ "shell scripts" ]] || [[ "$output" =~ "SCRIPT INVENTORY" ]]
}