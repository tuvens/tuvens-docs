#!/usr/bin/env bats
# Test: iterm-status-updater.sh
# Tests for iTerm2 status bar integration

# Load test setup
load setup

# Setup for each test
setup() {
    export SCRIPT_UNDER_TEST="$TEST_PROJECT_ROOT/scripts/iterm-status-updater.sh"
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        # Source dependencies first
        source "$TEST_PROJECT_ROOT/scripts/shared-functions.sh"
        source "$TEST_PROJECT_ROOT/scripts/status-determination-engine.sh"
    else
        skip "iterm-status-updater.sh not found"
    fi
    
    # Create test git repo
    mkdir -p "$TEST_TEMP_DIR/test-repo"
    cd "$TEST_TEMP_DIR/test-repo"
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
}

@test "fetch_issue_data: handles valid issue number" {
    source "$SCRIPT_UNDER_TEST"
    
    # Mock gh command
    gh() {
        if [[ "$1" == "issue" && "$2" == "view" && "$3" == "123" ]]; then
            echo '{"number":123,"title":"Test Issue","labels":[{"name":"status/active"}]}'
        fi
    }
    export -f gh
    
    run fetch_issue_data "123"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test Issue" ]]
}

@test "fetch_issue_data: handles invalid issue number" {
    source "$SCRIPT_UNDER_TEST"
    
    # Mock gh command to fail
    gh() {
        return 1
    }
    export -f gh
    
    run fetch_issue_data "999"
    [ "$status" -eq 1 ]
    [ "$output" = "{}" ]
}

@test "calculate_file_changes: detects git changes" {
    source "$SCRIPT_UNDER_TEST"
    
    # Create test files
    echo "content" > test1.txt
    echo "content" > test2.txt
    git add test1.txt
    git commit -m "Initial commit" --quiet
    
    # Modify files
    echo "modified" > test1.txt  # Modified file
    echo "new" > test3.txt       # Untracked file
    git add test2.txt           # Staged file
    
    run calculate_file_changes
    [ "$status" -eq 0 ]
    [[ "$output" =~ "changed" ]] || [[ "$output" =~ "staged" ]] || [[ "$output" =~ "new" ]]
}

@test "calculate_file_changes: handles no git repo" {
    source "$SCRIPT_UNDER_TEST"
    
    # Move to non-git directory
    cd "$TEST_TEMP_DIR"
    
    run calculate_file_changes
    [ "$status" -eq 0 ]
    [ "$output" = "no changes" ]
}

@test "get_pr_info: detects open PR" {
    source "$SCRIPT_UNDER_TEST"
    
    # Create unique branch
    local branch_name="feature/test-pr-open-$$"
    git checkout -b "$branch_name" --quiet
    
    # Mock gh command
    gh() {
        if [[ "$1" == "pr" && "$2" == "list" ]]; then
            echo '456:OPEN'
        fi
    }
    export -f gh
    
    run get_pr_info
    [ "$status" -eq 0 ]
    [[ "$output" =~ "PR #456" ]]
    [[ "$output" =~ "🟢" ]]
}

@test "get_pr_info: handles no PR" {
    source "$SCRIPT_UNDER_TEST"
    
    # Mock gh command to return empty
    gh() {
        echo ""
    }
    export -f gh
    
    run get_pr_info
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "format_status_display: formats status with emojis" {
    source "$SCRIPT_UNDER_TEST"
    
    run format_status_display "active" "0"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "🟢" ]]
    [[ "$output" =~ "Active" ]]
    
    run format_status_display "blocked" "3"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "🔴" ]]
    [[ "$output" =~ "Blocked" ]]
    [[ "$output" =~ "💬3" ]]
}

@test "get_current_issue: detects from .github-issue file" {
    source "$SCRIPT_UNDER_TEST"
    
    echo "789" > .github-issue
    
    run get_current_issue
    [ "$status" -eq 0 ]
    [ "$output" = "789" ]
}

@test "get_current_issue: detects from branch name" {
    source "$SCRIPT_UNDER_TEST"
    
    git checkout -b "feature/task-456" --quiet
    
    run get_current_issue
    [ "$status" -eq 0 ]
    [ "$output" = "456" ]
}

@test "get_current_issue: returns empty when no issue found" {
    source "$SCRIPT_UNDER_TEST"
    
    # Create unique branch without issue number
    local branch_name="feature/no-issue-$$"
    git checkout -b "$branch_name" --quiet
    
    run get_current_issue
    [ "$status" -eq 0 ]
    [ "$output" = "" ]
}

@test "script syntax validation" {
    run bash -n "$SCRIPT_UNDER_TEST"
    [ "$status" -eq 0 ]
}

@test "script has test mode" {
    # Test that the script supports test mode
    run bash "$SCRIPT_UNDER_TEST" test
    [ "$status" -eq 0 ]
    # Check for test mode indicators in output (case insensitive)
    [[ "$output" =~ [Tt]est ]] || [[ "$output" =~ "🧪" ]]
}