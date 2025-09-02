#!/usr/bin/env bats
# Unit tests for agentic-development/scripts/setup-code-review-desktop.sh
# TDD Test Suite - Testing code review desktop setup functionality

# Load test setup
load setup

# Setup for each test
setup() {
    export SCRIPT_UNDER_TEST="$TEST_PROJECT_ROOT/scripts/setup-code-review-desktop.sh"
    export TEST_REPO_DIR
    TEST_REPO_DIR=$(setup_test_git_repo)
    
    # Create minimal test environment
    cd "$TEST_REPO_DIR"
    echo "# CLAUDE.md" > CLAUDE.md
    echo '{"name": "test-project"}' > package.json
    mkdir -p agentic-development/{scripts,branch-tracking}
    
    # Create minimal shared-functions.sh for testing
    cat > agentic-development/scripts/shared-functions.sh << 'EOF'
#!/bin/bash
calculate_branch_name() {
    local agent="$1"
    local title="$2"
    echo "$agent/code-review/$title"
}
get_worktree_path() {
    echo "/tmp/test-worktree"
}
make_path_portable() {
    echo "$1"
}
check_pr_review_safeguards() {
    return 0
}
EOF
    chmod +x agentic-development/scripts/shared-functions.sh
    
    # Mock gh command for testing
    export PATH="$TEST_TEMP_DIR/bin:$PATH"
    mkdir -p "$TEST_TEMP_DIR/bin"
    
    cat > "$TEST_TEMP_DIR/bin/gh" << 'EOF'
#!/bin/bash
case "$1" in
    pr)
        case "$2" in
            view)
                echo '{"title":"Test PR","body":"Test description","author":{"login":"testuser"},"state":"OPEN","isDraft":false,"mergeable":"MERGEABLE","url":"https://github.com/test/test/pull/123","headRefName":"feature-branch","baseRefName":"dev","additions":100,"deletions":10,"changedFiles":5}'
                ;;
        esac
        ;;
    issue)
        case "$2" in
            view)
                echo '{"title":"Test Issue","body":"Test issue body","state":"OPEN","author":{"login":"testuser"},"url":"https://github.com/test/test/issues/456"}'
                ;;
            create)
                echo "https://github.com/test/test/issues/789"
                ;;
        esac
        ;;
esac
EOF
    chmod +x "$TEST_TEMP_DIR/bin/gh"
    
    # Mock jq command
    cat > "$TEST_TEMP_DIR/bin/jq" << 'EOF'
#!/bin/bash
if [[ "$*" == *"title"* ]]; then
    echo "Test PR"
elif [[ "$*" == *"body"* ]]; then
    echo "Test description"
elif [[ "$*" == *"author.login"* ]]; then
    echo "testuser"
else
    echo "test-value"
fi
EOF
    chmod +x "$TEST_TEMP_DIR/bin/jq"
}

# Cleanup after each test
teardown() {
    if [ -n "${TEST_REPO_DIR:-}" ]; then
        teardown_test_git_repo "$TEST_REPO_DIR"
    fi
}

# Test: Script exists and is executable
@test "setup-code-review-desktop.sh exists and is executable" {
    [ -f "$SCRIPT_UNDER_TEST" ]
    [ -x "$SCRIPT_UNDER_TEST" ]
}

# Test: Script has valid bash syntax
@test "setup-code-review-desktop.sh has valid bash syntax" {
    bash -n "$SCRIPT_UNDER_TEST"
}

# Test: Script displays usage when no arguments provided
@test "setup-code-review-desktop.sh shows usage with no arguments" {
    run "$SCRIPT_UNDER_TEST"
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"code-review"* ]]
}

# Test: Script displays usage with --help flag
@test "setup-code-review-desktop.sh shows usage with --help" {
    run "$SCRIPT_UNDER_TEST" --help
    [ "$status" -eq 1 ]
    [[ "$output" == *"Usage:"* ]]
    [[ "$output" == *"Examples:"* ]]
}

# Test: Script validates PR number parameter
@test "setup-code-review-desktop.sh validates PR number parameter" {
    run "$SCRIPT_UNDER_TEST" qa invalid-pr-number
    [ "$status" -eq 1 ]
    [[ "$output" == *"Invalid PR number"* ]]
}

# Test: Script sources shared functions
@test "setup-code-review-desktop.sh sources shared functions" {
    grep -q "source.*shared-functions.sh" "$SCRIPT_UNDER_TEST"
}

# Test: Script has proper parameter parsing
@test "setup-code-review-desktop.sh has parameter parsing logic" {
    grep -q "while.*\[\[ \$# -gt 0 \]\]" "$SCRIPT_UNDER_TEST"
    grep -q "PR_NUMBER" "$SCRIPT_UNDER_TEST"
    grep -q "AGENT_NAME" "$SCRIPT_UNDER_TEST"
}

# Test: Script integrates with GitHub CLI
@test "setup-code-review-desktop.sh integrates with GitHub CLI" {
    grep -q "gh pr view" "$SCRIPT_UNDER_TEST"
    grep -q "gh issue create" "$SCRIPT_UNDER_TEST"
}

# Test: Script handles context file parameter
@test "setup-code-review-desktop.sh handles context file parameter" {
    grep -q "CONTEXT_FILE" "$SCRIPT_UNDER_TEST"
    grep -q "\--context=" "$SCRIPT_UNDER_TEST"
}

# Test: Script creates comprehensive review prompts
@test "setup-code-review-desktop.sh creates QA review prompts" {
    grep -q "QA agent" "$SCRIPT_UNDER_TEST"
    grep -q "D/E.*Principle" "$SCRIPT_UNDER_TEST"
    grep -q "Technical.*Quality" "$SCRIPT_UNDER_TEST"
}

# Test: Script follows D/E principle requirements
@test "setup-code-review-desktop.sh enforces D/E principle" {
    grep -q "evidence" "$SCRIPT_UNDER_TEST"
    grep -q "PROVE.*claims" "$SCRIPT_UNDER_TEST"
}

# Test: Script integrates R/R and C/C principles  
@test "setup-code-review-desktop.sh includes R/R and C/C principles" {
    grep -q "R/R" "$SCRIPT_UNDER_TEST"
    grep -q "C/C" "$SCRIPT_UNDER_TEST"
    grep -q "Recognition-over-Recall" "$SCRIPT_UNDER_TEST"
    grep -q "Convention-over-Configuration" "$SCRIPT_UNDER_TEST"
}

# Test: Script has TDD framework integration
@test "setup-code-review-desktop.sh integrates TDD framework" {
    grep -q "test:tdd" "$SCRIPT_UNDER_TEST"
    grep -q "demonstrate-coverage" "$SCRIPT_UNDER_TEST"
}

# Test: Script generates branch names correctly
@test "setup-code-review-desktop.sh generates proper branch names" {
    grep -q "calculate_branch_name" "$SCRIPT_UNDER_TEST"
    grep -q "code-review" "$SCRIPT_UNDER_TEST"
}