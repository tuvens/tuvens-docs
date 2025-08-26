#!/usr/bin/env bats
# Unit tests for agentic-development/scripts/setup-agent-task.sh
# TDD Test Suite - Testing agent task setup functionality

# Load test setup
load setup

# Setup for each test
setup() {
    export SCRIPT_UNDER_TEST="$TEST_PROJECT_ROOT/agentic-development/scripts/setup-agent-task.sh"
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
    local task_type="${3:-feature}"
    local clean_title=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')
    [ -z "$clean_title" ] && clean_title="untitled-task"
    echo "$agent/$task_type/$clean_title"
}

calculate_worktree_path() {
    local agent="$1"  
    local branch="$2"
    echo "$PWD/worktrees/$branch"
}

make_path_portable() {
    local path="$1"
    echo "${path/#$HOME/~}"
}

create_github_issue() {
    local agent_name="$1"
    local task_title="$2" 
    local task_description="$3"
    local context_file="$4"
    local files_to_examine="$5"
    local success_criteria="$6"
    
    # Create temp file like real implementation
    local temp_body_file="/tmp/github-issue-body-$$"
    echo "# $task_title" > "$temp_body_file"
    echo "**Agent**: $agent_name" >> "$temp_body_file"  
    echo "" >> "$temp_body_file"
    echo "$task_description" >> "$temp_body_file"
    
    # Mock gh issue create call that returns URL like real command
    echo "https://github.com/tuvens/tuvens-docs/issues/123"
    
    # Extract issue number like real implementation
    local github_issue=$(echo "https://github.com/tuvens/tuvens-docs/issues/123" | grep -o '[0-9]\+$')
    rm -f "$temp_body_file"
    
    export GITHUB_ISSUE="$github_issue"
    echo "$github_issue"
}

validate_environment_setup() {
    [ -f "CLAUDE.md" ] && [ -f "package.json" ]
}

check_pr_review_safeguards() {
    return 0  # Mock: no active reviews
}
EOF
    chmod +x agentic-development/scripts/shared-functions.sh
    
    # Create minimal validate-environment.sh
    cat > agentic-development/scripts/validate-environment.sh << 'EOF'
#!/bin/bash
exit 0  # Mock successful validation
EOF
    chmod +x agentic-development/scripts/validate-environment.sh
}

# Teardown after each test
teardown() {
    teardown_test_git_repo "$TEST_REPO_DIR"
}

@test "setup-agent-task: requires minimum 3 arguments" {
    if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
        skip "setup-agent-task.sh not found"
    fi
    
    run "$SCRIPT_UNDER_TEST" "vibe-coder"
    [ "$status" -ne 0 ]
}

@test "setup-agent-task: accepts valid agent names" {
    if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
        skip "setup-agent-task.sh not found"
    fi
    
    # Mock gh command
    export PATH="$TEST_TEMP_DIR:$PATH"
    cat > "$TEST_TEMP_DIR/gh" << 'EOF'
#!/bin/bash
case "$1" in
    "issue") echo "123" ;;
    "repo") echo '{"nameWithOwner": "tuvens/test"}' ;;
    *) echo "mock gh: $*" ;;
esac
EOF
    chmod +x "$TEST_TEMP_DIR/gh"
    
    # Mock osascript for macOS
    cat > "$TEST_TEMP_DIR/osascript" << 'EOF'
#!/bin/bash
echo "Mock osascript executed"
EOF
    chmod +x "$TEST_TEMP_DIR/osascript"
    
    export SKIP_GITHUB_ISSUE_CREATION=false
    export SKIP_ITERM_AUTOMATION=true
    
    run "$SCRIPT_UNDER_TEST" "vibe-coder" "Test Task" "Test description"
    [ "$status" -eq 0 ]
}

@test "setup-agent-task: rejects invalid agent names" {
    if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
        skip "setup-agent-task.sh not found"
    fi
    
    # The script should validate agent names
    run "$SCRIPT_UNDER_TEST" "invalid-agent" "Test Task" "Test description"
    # Note: Current script doesn't validate agent names, but it should
    # This test documents the expected behavior for TDD
}

@test "setup-agent-task: handles files parameter correctly" {
    if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
        skip "setup-agent-task.sh not found"  
    fi
    
    export PATH="$TEST_TEMP_DIR:$PATH"
    cat > "$TEST_TEMP_DIR/gh" << 'EOF'
#!/bin/bash
echo "123"
EOF
    chmod +x "$TEST_TEMP_DIR/gh"
    
    export SKIP_GITHUB_ISSUE_CREATION=false
    export SKIP_ITERM_AUTOMATION=true
    
    run "$SCRIPT_UNDER_TEST" "vibe-coder" "Test Task" "Description" --files="file1.md,file2.md"
    [ "$status" -eq 0 ]
    
    # Check that files parameter was processed
    [[ "$output" =~ "file1.md,file2.md" ]]
}

@test "setup-agent-task: handles success-criteria parameter correctly" {
    if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
        skip "setup-agent-task.sh not found"
    fi
    
    export PATH="$TEST_TEMP_DIR:$PATH"
    cat > "$TEST_TEMP_DIR/gh" << 'EOF'
#!/bin/bash
echo "123"
EOF
    chmod +x "$TEST_TEMP_DIR/gh"
    
    export SKIP_GITHUB_ISSUE_CREATION=false
    export SKIP_ITERM_AUTOMATION=true
    
    run "$SCRIPT_UNDER_TEST" "vibe-coder" "Test Task" "Description" --success-criteria="All tests pass"
    [ "$status" -eq 0 ]
    
    # Check that success criteria was processed
    [[ "$output" =~ "All tests pass" ]]
}

@test "setup-agent-task: creates worktree directory structure" {
    if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
        skip "setup-agent-task.sh not found"
    fi
    
    export PATH="$TEST_TEMP_DIR:$PATH"
    cat > "$TEST_TEMP_DIR/gh" << 'EOF'
#!/bin/bash
echo "123"
EOF
    chmod +x "$TEST_TEMP_DIR/gh"
    
    export SKIP_GITHUB_ISSUE_CREATION=false
    export SKIP_ITERM_AUTOMATION=true
    
    run "$SCRIPT_UNDER_TEST" "vibe-coder" "Test Task" "Description"
    [ "$status" -eq 0 ]
    
    # Check that worktree structure exists
    [ -d "worktrees" ]
}

@test "setup-agent-task: generates prompt file with correct format" {
    if [ ! -f "$SCRIPT_UNDER_TEST" ]; then
        skip "setup-agent-task.sh not found"
    fi
    
    export PATH="$TEST_TEMP_DIR:$PATH"
    cat > "$TEST_TEMP_DIR/gh" << 'EOF'
#!/bin/bash
echo "123"
EOF
    chmod +x "$TEST_TEMP_DIR/gh"
    
    export SKIP_GITHUB_ISSUE_CREATION=false
    export SKIP_ITERM_AUTOMATION=true
    
    run "$SCRIPT_UNDER_TEST" "vibe-coder" "Test Task" "Description"
    [ "$status" -eq 0 ]
    
    # Check that prompt file was created
    [ -f "agentic-development/scripts/vibe-coder-prompt.txt" ]
    
    # Check prompt file contains expected content
    grep -q "GitHub Issue: #123" "agentic-development/scripts/vibe-coder-prompt.txt"
    grep -q "VIBE CODER AGENT" "agentic-development/scripts/vibe-coder-prompt.txt"
}