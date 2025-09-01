#!/usr/bin/env bats
# Test: status-determination-engine.sh
# Tests for status determination pattern matching

# Load test setup
load setup

# Setup for each test
setup() {
    export SCRIPT_UNDER_TEST="$TEST_PROJECT_ROOT/agentic-development/scripts/status-determination-engine.sh"
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        # Source shared functions first
        source "$TEST_PROJECT_ROOT/agentic-development/scripts/shared-functions.sh"
        source "$SCRIPT_UNDER_TEST"
    else
        skip "status-determination-engine.sh not found"
    fi
}

@test "determine_status_from_comment: detects blocked status" {
    comment="I'm blocked on this issue. Cannot proceed without dependencies."
    
    run determine_status_from_comment "$comment" "123"
    [ "$status" -eq 0 ]
    [ "$output" = "blocked" ]
}

@test "determine_status_from_comment: detects waiting status" {
    comment="Waiting for review approval before continuing."
    
    run determine_status_from_comment "$comment" "123"
    [ "$status" -eq 0 ]
    [ "$output" = "waiting" ]
}

@test "determine_status_from_comment: detects active status" {
    comment="Currently working on implementing the feature."
    
    run determine_status_from_comment "$comment" "123"
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]
}

@test "determine_status_from_comment: detects reviewing status from PR context" {
    comment="Created PR for review. Please check the implementation."
    
    run determine_status_from_comment "$comment" "123"
    [ "$status" -eq 0 ]
    [ "$output" = "reviewing" ]
}

@test "determine_status_from_comment: prioritizes explicit status declarations" {
    # Should detect explicit status even with other keywords present
    comment="Working on this but currently blocked. **Status: waiting**"
    
    run determine_status_from_comment "$comment" "123"
    [ "$status" -eq 0 ]
    [ "$output" = "waiting" ]
}

@test "determine_status_from_comment: handles edge cases" {
    # Empty comment
    run determine_status_from_comment "" "123"
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]  # Default status
    
    # Comment with no status indicators
    run determine_status_from_comment "Just a regular comment" "123"
    [ "$status" -eq 0 ]
    [ "$output" = "active" ]  # Default status
}

@test "determine_status_from_comment: handles multiple status indicators with priority" {
    # Blocked should take priority over active when both are present
    comment="I was working on this but now I'm blocked by missing API keys."
    
    run determine_status_from_comment "$comment" "123"
    [ "$status" -eq 0 ]
    [ "$output" = "blocked" ]
}

@test "determine_final_status: integrates comment and context analysis" {
    # Mock gh command to return sample comment
    gh() {
        if [[ "$1" == "issue" && "$2" == "view" ]]; then
            echo '{"comments":[{"body":"Currently blocked on dependencies","author":{"login":"test-agent"}}]}'
        fi
    }
    export -f gh
    
    run determine_final_status "123" "test-comment" "test-agent" "feature/test-branch"
    [ "$status" -eq 0 ]
    [ "$output" = "blocked" ]
}

@test "script syntax validation" {
    run bash -n "$SCRIPT_UNDER_TEST"
    [ "$status" -eq 0 ]
}

@test "can source status determination engine" {
    run bash -c "source '$TEST_PROJECT_ROOT/agentic-development/scripts/shared-functions.sh'; source '$SCRIPT_UNDER_TEST'; echo 'Loaded successfully'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Loaded successfully" ]]
}