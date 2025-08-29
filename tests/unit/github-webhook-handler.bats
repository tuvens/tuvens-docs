#!/usr/bin/env bats
# Test: github-webhook-handler.sh
# Tests for GitHub webhook event processing

# Load test helpers
setup() {
    # Create test fixtures
    export TEST_PAYLOAD_ISSUE_COMMENT='{"action":"created","issue":{"number":123},"comment":{"body":"👤 **Identity**: test-agent","user":{"login":"test-user"}}}'
    export TEST_PAYLOAD_PR='{"action":"opened","pull_request":{"number":456,"body":"Fixes #123","draft":false,"state":"open","merged":false}}'
    export TEST_PAYLOAD_INVALID='{"invalid":true}'
    export SCRIPTS_DIR="$BATS_TEST_DIRNAME/../../agentic-development/scripts"
}

@test "processes issue comment webhook with valid agent format" {
    # Mock GitHub CLI commands
    function gh() {
        if [[ "$1" == "issue" && "$2" == "edit" ]]; then
            echo "Label updated successfully"
        fi
    }
    export -f gh
    
    # Mock status determination
    function determine_status_from_comment() {
        echo "active"
    }
    export -f determine_status_from_comment
    
    # Mock iterm status updater
    function "$SCRIPTS_DIR/iterm-status-updater.sh"() {
        echo "Status updated"
    }
    
    run bash -c "source '$SCRIPTS_DIR/shared-functions.sh'; source '$SCRIPTS_DIR/github-webhook-handler.sh'; process_issue_comment '$TEST_PAYLOAD_ISSUE_COMMENT'"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Processed comment from test-agent" ]]
}

@test "handles invalid JSON payload gracefully" {
    run bash -c "source '$SCRIPTS_DIR/shared-functions.sh'; source '$SCRIPTS_DIR/github-webhook-handler.sh'; process_issue_comment 'invalid-json'"
    
    [ "$status" -eq 1 ]
    [[ "$output" =~ "ERROR: Invalid payload format" ]]
}

@test "processes pull request webhook" {
    # Mock GitHub CLI
    function gh() {
        if [[ "$1" == "issue" && "$2" == "edit" ]]; then
            echo "Label updated"
        fi
    }
    export -f gh
    
    # Mock get_agent_from_issue
    function get_agent_from_issue() {
        echo "test-agent"
    }
    export -f get_agent_from_issue
    
    run bash -c "source '$SCRIPTS_DIR/shared-functions.sh'; source '$SCRIPTS_DIR/github-webhook-handler.sh'; process_pull_request '$TEST_PAYLOAD_PR'"
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Processed PR" ]]
}

@test "validates webhook handler syntax" {
    run bash -n "$SCRIPTS_DIR/github-webhook-handler.sh"
    [ "$status" -eq 0 ]
}

@test "can load webhook handler without errors" {
    run bash -c "source '$SCRIPTS_DIR/shared-functions.sh'; source '$SCRIPTS_DIR/github-webhook-handler.sh'; echo 'Loaded successfully'"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Loaded successfully" ]]
}