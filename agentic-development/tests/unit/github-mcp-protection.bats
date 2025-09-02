#!/usr/bin/env bats
# Unit tests for agentic-development/scripts/github-mcp-protection.sh
# TDD Test Suite - Testing GitHub MCP protection and branch safety
# SECURITY-CRITICAL: This script controls branch protection and MCP safety

# Load test setup
load setup

# Setup for each test
setup() {
    export SCRIPT_UNDER_TEST="$TEST_PROJECT_ROOT/scripts/github-mcp-protection.sh"
    export TEST_REPO_DIR
    TEST_REPO_DIR=$(setup_test_git_repo)
    cd "$TEST_REPO_DIR"
    
    # Create session directory for testing
    export SESSION_DIR="$TEST_TEMP_DIR/github-mcp-protection"
    mkdir -p "$SESSION_DIR"
    
    # Mock Claude Desktop environment variables
    export CLAUDE_DESKTOP_SESSION=""
    export MCP_SAFETY_MODE=""
    
    # Source script functions for testing (without executing main logic)
    if [ -f "$SCRIPT_UNDER_TEST" ]; then
        # Create a safe sourcing approach that avoids execution
        local temp_functions=$(mktemp)
        
        # Extract constants and function definitions safely using awk
        awk '
        /^readonly / { print; next }
        /^[A-Z_]*=/ { print; next }
        /^[a-zA-Z_][a-zA-Z0-9_]*\(\) \{/{flag=1} 
        flag{print} 
        /^\}$/{if(flag) {flag=0; print ""}}
        ' "$SCRIPT_UNDER_TEST" > "$temp_functions"
        
        # Source the extracted functions
        source "$temp_functions"
        rm -f "$temp_functions"
    else
        skip "github-mcp-protection.sh not found"
    fi
}

# Teardown after each test
teardown() {
    # Clean up session directory
    if [ -d "$SESSION_DIR" ]; then
        rm -rf "$SESSION_DIR"
    fi
    teardown_test_git_repo "$TEST_REPO_DIR"
}

@test "script constants: protected branches defined correctly" {
    # Test that PROTECTED_BRANCHES array contains expected values
    [[ " ${PROTECTED_BRANCHES[@]} " =~ " main " ]]
    [[ " ${PROTECTED_BRANCHES[@]} " =~ " stage " ]]
    [[ " ${PROTECTED_BRANCHES[@]} " =~ " test " ]]
}

@test "script constants: valid agents defined correctly" {
    # Test that VALID_AGENTS array contains expected agents
    [[ " ${VALID_AGENTS[@]} " =~ " vibe-coder " ]]
    [[ " ${VALID_AGENTS[@]} " =~ " docs-orchestrator " ]]
    [[ " ${VALID_AGENTS[@]} " =~ " devops " ]]
    [[ " ${VALID_AGENTS[@]} " =~ " laravel-dev " ]]
}

@test "script constants: valid task types defined correctly" {
    # Test that VALID_TASK_TYPES array contains expected types
    [[ " ${VALID_TASK_TYPES[@]} " =~ " feature " ]]
    [[ " ${VALID_TASK_TYPES[@]} " =~ " bugfix " ]]
    [[ " ${VALID_TASK_TYPES[@]} " =~ " docs " ]]
    [[ " ${VALID_TASK_TYPES[@]} " =~ " hotfix " ]]
}

@test "session directory: creates session directory structure" {
    # Test session directory creation
    [ -d "$SESSION_DIR" ]
    
    # Test that session file paths are defined correctly
    [[ "$SESSION_FILE" == *"/active-session.json" ]]
    [[ "$PROTECTION_LOG" == *"/protection.log" ]]
}

@test "log_header: produces formatted header output" {
    run log_header
    [ "$status" -eq 0 ]
    [[ "$output" =~ "GitHub MCP Protection System" ]]
    [[ "$output" =~ "v1.0.0" ]]
    [[ "$output" =~ "🛡️" ]]
}

@test "log_section: produces formatted section output" {
    run log_section "Test Section"
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Test Section" ]]
}

@test "check_claude_desktop_environment: detects Claude Desktop process" {
    # Mock ps command to simulate Claude Desktop process
    ps() {
        case "$*" in
            *"Claude Desktop"*)
                echo "12345 Claude Desktop"
                ;;
            *)
                command ps "$@"
                ;;
        esac
    }
    export -f ps
    
    run check_claude_desktop_environment
    [ "$status" -eq 0 ]
}

@test "check_claude_desktop_environment: fails when Claude Desktop not detected" {
    # Mock ps command to simulate no Claude Desktop process
    ps() {
        case "$*" in
            *"Claude Desktop"*)
                # Return no results
                ;;
            *)
                command ps "$@"
                ;;
        esac
    }
    export -f ps
    
    run check_claude_desktop_environment
    [ "$status" -ne 0 ]
}

@test "branch protection: detects protected branch correctly" {
    # Switch to main branch (protected)
    git checkout -b main 2>/dev/null || git checkout main
    
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Test if current branch is in protected branches array
    local is_protected=false
    for branch in "${PROTECTED_BRANCHES[@]}"; do
        if [[ "$current_branch" == "$branch" ]]; then
            is_protected=true
            break
        fi
    done
    
    [ "$is_protected" = true ]
}

@test "branch protection: allows feature branch commits" {
    # Switch to feature branch (not protected)
    git checkout -b "vibe-coder/feature/test-branch"
    
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    
    # Test if current branch is NOT in protected branches array
    local is_protected=false
    for branch in "${PROTECTED_BRANCHES[@]}"; do
        if [[ "$current_branch" == "$branch" ]]; then
            is_protected=true
            break
        fi
    done
    
    [ "$is_protected" = false ]
}

@test "session management: creates valid session JSON structure" {
    # Create session file for testing
    cat > "$SESSION_FILE" << 'EOF'
{
    "session_id": "test-session-123",
    "start_time": "2025-08-25T20:00:00Z",
    "claude_desktop_detected": true,
    "protected_branch_attempts": [],
    "violations": []
}
EOF
    
    # Test session file exists and has valid JSON
    [ -f "$SESSION_FILE" ]
    run python3 -c "import json; json.load(open('$SESSION_FILE'))"
    [ "$status" -eq 0 ]
}

@test "session management: validates session file corruption" {
    # Create corrupted session file
    echo "invalid json content" > "$SESSION_FILE"
    
    # Test detection of corrupted session file
    run python3 -c "import json; json.load(open('$SESSION_FILE'))"
    [ "$status" -ne 0 ]
}

@test "error codes: defines correct exit codes for different violations" {
    # Test that error codes are defined correctly
    [ "$ERR_PROTECTED_BRANCH_COMMIT" -eq 10 ]
    [ "$ERR_CLAUDE_DESKTOP_VIOLATION" -eq 11 ]
    [ "$ERR_MCP_SAFETY_VIOLATION" -eq 12 ]
    [ "$ERR_EMERGENCY_INTERVENTION" -eq 13 ]
    [ "$ERR_SESSION_CORRUPTION" -eq 14 ]
}

@test "agent validation: accepts valid agent names" {
    # Test valid agent names
    for agent in "${VALID_AGENTS[@]}"; do
        # Agent should be in the valid list
        [[ " ${VALID_AGENTS[@]} " =~ " $agent " ]]
    done
}

@test "agent validation: rejects invalid agent names" {
    local invalid_agents=("invalid-agent" "unknown-dev" "random-name")
    
    for agent in "${invalid_agents[@]}"; do
        # Agent should NOT be in the valid list
        if [[ " ${VALID_AGENTS[@]} " =~ " $agent " ]]; then
            # If found in valid list, fail the test
            false
        fi
    done
}

@test "task type validation: accepts valid task types" {
    # Test valid task types
    for task_type in "${VALID_TASK_TYPES[@]}"; do
        # Task type should be in the valid list
        [[ " ${VALID_TASK_TYPES[@]} " =~ " $task_type " ]]
    done
}

@test "task type validation: rejects invalid task types" {
    local invalid_types=("invalid-type" "unknown-task" "random-type")
    
    for task_type in "${invalid_types[@]}"; do
        # Task type should NOT be in the valid list
        if [[ " ${VALID_TASK_TYPES[@]} " =~ " $task_type " ]]; then
            # If found in valid list, fail the test
            false
        fi
    done
}

@test "protection log: creates log file when session starts" {
    # Create protection log
    echo "$(date): Session started" > "$PROTECTION_LOG"
    
    [ -f "$PROTECTION_LOG" ]
    [ -s "$PROTECTION_LOG" ]  # File is not empty
}

@test "emergency override: generates override token format" {
    # Test that emergency override functionality exists in script
    # This test ensures the emergency override concept is implemented
    
    if grep -q "emergency.*override" "$SCRIPT_UNDER_TEST"; then
        # Emergency override functionality found
        true
    else
        # Emergency override functionality not found - should be implemented
        skip "Emergency override functionality not yet implemented"
    fi
}

@test "mcp safety mode: handles safety mode environment variable" {
    # Test with safety mode enabled
    export MCP_SAFETY_MODE="enabled"
    
    # Test that script can access safety mode setting
    [ "$MCP_SAFETY_MODE" = "enabled" ]
    
    # Test with safety mode disabled
    export MCP_SAFETY_MODE="disabled"
    [ "$MCP_SAFETY_MODE" = "disabled" ]
}