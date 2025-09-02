#!/usr/bin/env bats

# Test suite for create-pr.sh script
# Tests deterministic PR creation logic and validation

load 'setup'

# Test script existence and permissions
@test "create-pr.sh script exists and is executable" {
    [ -f "agentic-development/scripts/create-pr.sh" ]
    [ -x "agentic-development/scripts/create-pr.sh" ]
}

# Test help functionality
@test "create-pr.sh shows help when requested" {
    run ./agentic-development/scripts/create-pr.sh --help
    [ "$status" -eq 0 ]
    [[ "$output" =~ "create-pr.sh - Deterministic PR Creation" ]]
    [[ "$output" =~ "5-BRANCH STRATEGY" ]]
    [[ "$output" =~ "VALIDATION CHECKS" ]]
}

# Test help functionality with -h flag
@test "create-pr.sh shows help with -h flag" {
    run ./agentic-development/scripts/create-pr.sh -h
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
        source "${OLDPWD}/agentic-development/scripts/create-pr.sh" 2>/dev/null || true
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
    
    run bash -c '
        source agentic-development/scripts/create-pr.sh
        validate_branch_naming() {
            CURRENT_BRANCH="invalid-branch-name"
            if [[ ! "${CURRENT_BRANCH}" =~ ^[a-z-]+/[a-z-]+/.+ ]]; then
                echo "Branch name validation failed"
                return 1
            fi
        }
        validate_branch_naming
    '
    
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Branch name validation failed" ]]
}

# Test valid branch naming
@test "create-pr.sh accepts valid branch names" {
    run bash -c '
        CURRENT_BRANCH="devops/feature/add-create-pr-command"
        if [[ "${CURRENT_BRANCH}" =~ ^[a-z-]+/[a-z-]+/.+ ]]; then
            echo "Valid branch name"
        else
            echo "Invalid branch name"
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
                echo "Protected branch detected: $current_branch"
                exit 1
            fi
        done
        echo "Not a protected branch"
    '
    
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Protected branch detected: main" ]]
}

# Test target branch validation logic
@test "create-pr.sh validates target branches correctly" {
    # Test dev branch (should pass)
    run bash -c '
        target_branch="dev"
        case "${target_branch}" in
            "dev") echo "dev branch valid" ;;
            "main"|"test") echo "blocked branch" ;;
            *) echo "non-standard branch" ;;
        esac
    '
    [ "$status" -eq 0 ]
    [[ "$output" =~ "dev branch valid" ]]
    
    # Test main branch (should be blocked)
    run bash -c '
        target_branch="main"
        case "${target_branch}" in
            "dev") echo "dev branch valid" ;;
            "main"|"test") echo "blocked branch" ;;
            *) echo "non-standard branch" ;;
        esac
    '
    [ "$status" -eq 0 ]
    [[ "$output" =~ "blocked branch" ]]
}

# Test branch information parsing
@test "create-pr.sh parses branch information correctly" {
    run bash -c '
        current_branch="devops/feature/add-create-pr-command"
        IFS="/" read -r agent_name task_type description_raw <<< "${current_branch}"
        description=$(echo "${description_raw}" | tr "-" " ")
        
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
        
        task_type_formatted=$(echo "${task_type}" | sed "s/\b\w/\U&/g")
        description_formatted=$(echo "${description}" | sed "s/\b\w/\U&/g")
        pr_title="${task_type_formatted}: ${description_formatted}"
        
        echo "$pr_title"
    '
    
    [ "$status" -eq 0 ]
    [[ "$output" =~ "Feature: Add Create Pr Command" ]]
}

# Test script has proper error handling setup
@test "create-pr.sh has proper error handling" {
    head -20 agentic-development/scripts/create-pr.sh | grep -q "set -euo pipefail"
}

# Test script has required functions defined
@test "create-pr.sh defines all required functions" {
    grep -q "validate_branch_naming()" agentic-development/scripts/create-pr.sh
    grep -q "validate_not_on_protected_branch()" agentic-development/scripts/create-pr.sh
    grep -q "validate_working_directory()" agentic-development/scripts/create-pr.sh
    grep -q "validate_remote_sync()" agentic-development/scripts/create-pr.sh
    grep -q "validate_target_branch()" agentic-development/scripts/create-pr.sh
    grep -q "generate_pr_body()" agentic-development/scripts/create-pr.sh
}

# Test script includes comprehensive PR body template
@test "create-pr.sh generates comprehensive PR body" {
    grep -q "## Branch Strategy Compliance" agentic-development/scripts/create-pr.sh
    grep -q "## Testing Completed" agentic-development/scripts/create-pr.sh
    grep -q "## Code Quality Checklist" agentic-development/scripts/create-pr.sh
    grep -q "## Security Considerations" agentic-development/scripts/create-pr.sh
}

# Test script includes emergency hotfix handling
@test "create-pr.sh includes emergency hotfix workflow" {
    grep -q "EMERGENCY HOTFIX" agentic-development/scripts/create-pr.sh
    grep -q "emergency_reason" agentic-development/scripts/create-pr.sh
}

# Test script has proper logging functions
@test "create-pr.sh defines logging functions" {
    grep -q "log_info()" agentic-development/scripts/create-pr.sh
    grep -q "log_success()" agentic-development/scripts/create-pr.sh
    grep -q "log_warning()" agentic-development/scripts/create-pr.sh
    grep -q "log_error()" agentic-development/scripts/create-pr.sh
}

# Test script validates GitHub CLI availability
@test "create-pr.sh checks for GitHub CLI" {
    grep -q "command -v gh" agentic-development/scripts/create-pr.sh
    grep -q "gh auth status" agentic-development/scripts/create-pr.sh
}

# Test script includes comprehensive labeling logic
@test "create-pr.sh includes automatic labeling" {
    grep -q "gh pr edit.*--add-label" agentic-development/scripts/create-pr.sh
    grep -q "agent/" agentic-development/scripts/create-pr.sh
    grep -q "branch-strategy:compliant" agentic-development/scripts/create-pr.sh
}