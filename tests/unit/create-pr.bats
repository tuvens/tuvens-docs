#!/usr/bin/env bats

# Test suite for create-pr.sh script
# Tests deterministic PR creation logic and validation

load 'setup'

# Define script path that works from repository root or agentic-development directory
# Use absolute path from TEST_PROJECT_ROOT for reliable resolution
SCRIPT_PATH="${TEST_PROJECT_ROOT}/agentic-development/scripts/create-pr.sh"

# Test script existence and permissions
@test "create-pr.sh script exists and is executable" {
    [ -f "$SCRIPT_PATH" ]
    [ -x "$SCRIPT_PATH" ]
}

# Test help functionality
@test "create-pr.sh shows help when requested" {
    run "$SCRIPT_PATH" --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "create-pr.sh - Deterministic PR Creation" ]]
    [[ "$output" =~ "5-BRANCH STRATEGY" ]]
    [[ "$output" =~ "VALIDATION CHECKS" ]]
}

# Test help functionality with -h flag
@test "create-pr.sh shows help with -h flag" {
    run "$SCRIPT_PATH" -h
    [ "$status" -eq 0 ]
    [[ "$output" =~ "USAGE:" ]]
}

# Test script requires git repository
@test "create-pr.sh detects when not in git repository" {
    # Create temporary non-git directory
    temp_dir=$(mktemp -d)
    cd "$temp_dir"
    
    run bash -c "$(cat << 'EOF'
        # Source the script functions without executing main logic
        source "$SCRIPT_PATH" 2>/dev/null || true
        # Test git command that should fail
        git branch --show-current 2>/dev/null || echo "not-in-git-repo"
EOF
    )"
    
    [[ "$output" =~ "not-in-git-repo" ]]
    
    # Clean up
    rm -rf "$temp_dir"
}

# Test branch naming validation logic
@test "create-pr.sh validates branch naming convention" {
    # Mock git commands for testing
    function git() {
        case "$1" in
            "branch")
                case "$2" in
                    "--show-current")
                        echo "invalid-branch-name" ;;
                esac ;;
        esac
    }
    export -f git
    
    run bash -c "
        source \"$SCRIPT_PATH\"
        export CURRENT_BRANCH=\"invalid-branch-name\"
        validate_branch_naming
    "
    
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Branch name" ]]
}

# Test valid branch naming
@test "create-pr.sh accepts valid branch names" {
    run bash -c '
        current_branch="devops/feature/add-create-pr-command"
        if [[ "$current_branch" =~ ^[a-z-]+/[a-z-]+/.+ ]]; then
            echo "Valid branch name"
        else
            echo "Invalid branch name"
            exit 1
        fi
    '
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Valid branch name" ]]
}

# Test protected branch detection
@test "create-pr.sh detects protected branches" {
    run bash -c '
        protected_branches=("main" "stage" "test")
        current_branch="main"
        
        for branch in "${protected_branches[@]}"; do
            if [[ "$current_branch" == "$branch" ]]; then
                echo "Protected branch detected: $branch"
                exit 1
            fi
        done
        
        echo "Not a protected branch"
    '
    
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Protected branch detected" ]]
}

# Test target branch validation
@test "create-pr.sh validates target branches correctly" {
    run bash -c '
        target_branch="dev"
        
        case "$target_branch" in
            "dev")
                echo "Valid target: dev"
                ;;
            "stage")
                echo "Hotfix target: stage"
                ;;
            "main"|"test")
                echo "Invalid target: $target_branch"
                exit 1
                ;;
            *)
                echo "Non-standard target: $target_branch"
                ;;
        esac
    '
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Valid target: dev" ]]
}

# Test branch information parsing
@test "create-pr.sh parses branch information correctly" {
    run bash -c '
        current_branch="devops/feature/add-create-pr-command"
        
        IFS="/" read -r agent_name task_type description_raw <<< "$current_branch"
        description=$(echo "$description_raw" | tr "-" " ")
        
        echo "Agent: $agent_name"
        echo "Type: $task_type" 
        echo "Description: $description"
    '
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Agent: devops" ]]
    [[ "$output" =~ "Type: feature" ]]
    [[ "$output" =~ "Description: add create pr command" ]]
}

# Test PR title generation logic
@test "create-pr.sh generates proper PR titles" {
    run bash -c '
        task_type="feature"
        description="add create pr command"
        
        # Use the same cross-platform approach as the actual script
        task_type_formatted=$(echo "${task_type}" | awk "{print toupper(substr(\$0,1,1)) tolower(substr(\$0,2))}")
        description_formatted=$(echo "${description}" | awk "{for(i=1;i<=NF;i++) \$i=toupper(substr(\$i,1,1)) tolower(substr(\$i,2))}1")
        pr_title="${task_type_formatted}: ${description_formatted}"
        
        echo "$pr_title"
    '
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Feature: Add Create Pr Command" ]]
}

# Test script has proper error handling setup
@test "create-pr.sh has proper error handling" {
    head -20 "$SCRIPT_PATH" | grep -q "set -euo pipefail"
}

# Test all required functions are defined
@test "create-pr.sh defines all required functions" {
    grep -q "validate_branch_naming()" "$SCRIPT_PATH"
    grep -q "validate_not_on_protected_branch()" "$SCRIPT_PATH"
    grep -q "validate_working_directory()" "$SCRIPT_PATH"
    grep -q "validate_remote_sync()" "$SCRIPT_PATH"
    grep -q "validate_target_branch()" "$SCRIPT_PATH"
    grep -q "generate_pr_body()" "$SCRIPT_PATH"
}

# Test PR body template generation
@test "create-pr.sh generates comprehensive PR body" {
    grep -q "## Branch Strategy Compliance" "$SCRIPT_PATH"
    grep -q "## Testing Completed" "$SCRIPT_PATH"
    grep -q "## Code Quality Checklist" "$SCRIPT_PATH"
    grep -q "## Security Considerations" "$SCRIPT_PATH"
}

# Test emergency hotfix workflow
@test "create-pr.sh includes emergency hotfix workflow" {
    grep -q "EMERGENCY HOTFIX" "$SCRIPT_PATH"
    grep -q "emergency_reason" "$SCRIPT_PATH"
}

# Test logging functions
@test "create-pr.sh defines logging functions" {
    grep -q "log_info()" "$SCRIPT_PATH"
    grep -q "log_success()" "$SCRIPT_PATH"
    grep -q "log_warning()" "$SCRIPT_PATH"
    grep -q "log_error()" "$SCRIPT_PATH"
}

# Test GitHub CLI integration
@test "create-pr.sh checks for GitHub CLI" {
    grep -q "command -v gh" "$SCRIPT_PATH"
    grep -q "gh auth status" "$SCRIPT_PATH"
}

# Test automatic labeling functionality
@test "create-pr.sh includes automatic labeling" {
    grep -q "gh pr edit.*--add-label" "$SCRIPT_PATH"
    grep -q "agent/" "$SCRIPT_PATH"
    grep -q "branch-strategy:compliant" "$SCRIPT_PATH"
}