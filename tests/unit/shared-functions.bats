#!/usr/bin/env bats
# Unit tests for agentic-development/scripts/shared-functions.sh
# TDD Test Suite - Testing shared utility functions

# Load test setup
load setup

# Setup for each test
setup() {
    # Source the shared functions for testing
    export SCRIPT_UNDER_TEST="$TEST_PROJECT_ROOT/agentic-development/scripts/shared-functions.sh"
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        source "$SCRIPT_UNDER_TEST"
    else
        skip "shared-functions.sh not found - create it first"
    fi
}

# Teardown after each test
teardown() {
    # Clean up any test artifacts
    if [ -d "$TEST_TEMP_DIR" ]; then
        rm -rf "$TEST_TEMP_DIR"/*
    fi
}

@test "calculate_branch_name: generates correct branch name from agent and title" {
    # Test the branch name calculation function
    result=$(calculate_branch_name "vibe-coder" "Implement Testing Framework")
    expected="vibe-coder/feature/implement-testing-framework"
    [ "$result" = "$expected" ]
}

@test "calculate_branch_name: handles special characters in title" {
    result=$(calculate_branch_name "docs-orchestrator" "Fix API & Documentation Issues!")
    expected="docs-orchestrator/feature/fix-api-documentation-issues"
    [ "$result" = "$expected" ]
}

@test "calculate_branch_name: handles empty or null title" {
    result=$(calculate_branch_name "vibe-coder" "")
    expected="vibe-coder/feature/untitled-task"
    [ "$result" = "$expected" ]
}

@test "calculate_worktree_path: generates correct worktree path" {
    result=$(calculate_worktree_path "vibe-coder" "vibe-coder/feature/test-branch")
    [[ "$result" =~ worktrees/vibe-coder/vibe-coder/feature/test-branch$ ]]
}

@test "make_path_portable: converts absolute paths to portable format" {
    input="/Users/testuser/Code/project/worktrees/agent/branch"
    result=$(make_path_portable "$input")
    expected="~/Code/project/worktrees/agent/branch"
    [ "$result" = "$expected" ]
}

@test "create_github_issue: creates issue with proper format" {
    # Mock gh command for testing
    gh() { mock_gh_command "$@"; }
    export -f gh
    
    result=$(create_github_issue "vibe-coder" "Test Task" "Test description" "" "" "All tests pass")
    [ "$result" = "123" ]
}

@test "validate_environment_setup: detects missing critical files" {
    # Test in temporary directory without CLAUDE.md
    cd "$TEST_TEMP_DIR"
    run validate_environment_setup
    [ "$status" -ne 0 ]
}

@test "validate_environment_setup: passes with proper setup" {
    # Create minimal required files
    mkdir -p "$TEST_TEMP_DIR/test-env"
    cd "$TEST_TEMP_DIR/test-env"
    echo "# CLAUDE.md" > CLAUDE.md
    echo '{"name": "test"}' > package.json
    
    run validate_environment_setup
    [ "$status" -eq 0 ]
}

@test "check_pr_review_safeguards: detects active reviews" {
    # Mock git commands for testing
    git() {
        case "$1 $2" in
            "log --oneline")
                echo "abc123 PR #456: Feature implementation"
                echo "def789 Normal commit"
                ;;
            *)
                command git "$@"
                ;;
        esac
    }
    export -f git
    
    run check_pr_review_safeguards "feature/test"
    [ "$status" -eq 1 ]  # Should detect active review
    
    # Should provide specific warning about detected PR
    [[ "$output" =~ "PR #456" ]] || [[ "$output" =~ "review" ]] || [[ "$output" =~ "detected" ]]
}

@test "check_pr_review_safeguards: allows when no reviews active" {
    # Mock git commands for testing  
    git() {
        case "$1 $2" in
            "log --oneline")
                echo "abc123 Regular commit"
                echo "def789 Another commit"
                ;;
            *)
                command git "$@"
                ;;
        esac
    }
    export -f git
    
    run check_pr_review_safeguards "feature/test"
    [ "$status" -eq 0 ]  # Should allow
}