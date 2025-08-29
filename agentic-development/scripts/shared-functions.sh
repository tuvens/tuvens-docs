#!/usr/bin/env bash
# File: shared-functions.sh
# Purpose: Shared functions for agent task automation scripts
# 
# This library prevents synchronization bugs by providing a single source of truth
# for common operations used by both setup-agent-task.sh and setup-agent-task-desktop.sh

set -euo pipefail

# Function to convert absolute paths to portable format using ~
make_path_portable() {
    local abs_path="$1"
    # Replace user's home directory with ~
    echo "$abs_path" | sed "s|^$HOME|~|"
}

# Function to expand portable paths back to absolute format
expand_portable_path() {
    local path="$1"
    if [[ "$path" == \~/* ]]; then
        echo "${HOME}${path#\~}"
    else
        echo "$path"
    fi
}

# Function to sanitize names for branch naming (standardized)
sanitize_for_branch() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-'
}

# Function to calculate standardized branch name
calculate_branch_name() {
    local agent_name="$1"
    local task_title="$2"
    
    local sanitized_agent=$(sanitize_for_branch "$agent_name")
    
    # Handle empty or null task title
    if [[ -z "$task_title" || "$task_title" == "null" ]]; then
        task_title="untitled-task"
    fi
    
    local sanitized_task=$(sanitize_for_branch "$task_title")
    
    echo "$sanitized_agent/feature/$sanitized_task"
}

# Function to query actual worktree path from git (single source of truth)
get_worktree_path() {
    local branch_name="$1"
    
    # Query git for the actual worktree location with improved pattern matching
    local worktree_path
    worktree_path=$(git worktree list | grep -F "[$branch_name]" | head -n1 | awk '{print $1}')
    
    if [[ -n "$worktree_path" ]]; then
        echo "$worktree_path"
        return 0
    else
        return 1
    fi
}

# Function to determine repository structure paths
get_repo_paths() {
    local repo_root
    local repo_name
    
    repo_root=$(git rev-parse --show-toplevel)
    repo_name=$(basename "$repo_root")
    
    # Output each path on separate lines to handle spaces safely
    echo "$repo_root"
    echo "$repo_name"
}

# Function to calculate expected worktree path (for creation, not querying)
calculate_worktree_path() {
    local agent_name="$1"
    local branch_name="$2"
    
    # Get repository paths safely using temporary file approach
    local temp_file
    temp_file=$(mktemp)
    get_repo_paths > "$temp_file"
    
    local repo_root
    local repo_name
    repo_root=$(head -n1 "$temp_file")
    repo_name=$(tail -n1 "$temp_file")
    rm -f "$temp_file"
    
    local sanitized_agent
    sanitized_agent=$(sanitize_for_branch "$agent_name")
    
    if [[ "$repo_name" == "tuvens-docs" ]]; then
        echo "$repo_root/worktrees/$sanitized_agent/$branch_name"
    else
        local parent_dir
        parent_dir=$(dirname "$repo_root")
        echo "$parent_dir/$repo_name/worktrees/$sanitized_agent/$branch_name"
    fi
}

# Function to handle common error scenarios
handle_script_error() {
    local error_msg="$1"
    local exit_code="${2:-1}"
    
    echo "❌ ERROR: $error_msg" >&2
    echo "   This is a common issue. Check the troubleshooting guide." >&2
    exit "$exit_code"
}

# Function to validate that required tools are available
validate_required_tools() {
    local tools=("git" "gh")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        handle_script_error "Required tools missing: ${missing_tools[*]}"
    fi
}

# Function to ensure we're in a git repository
validate_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        handle_script_error "Not in a git repository"
    fi
}

# Function to validate environment setup
validate_environment_setup() {
    local validation_errors=0
    
    # Check required tools
    local required_tools=("git" "gh")
    for tool in "${required_tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            echo "❌ Required tool missing: $tool" >&2
            validation_errors=$((validation_errors + 1))
        fi
    done
    
    # Check git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "❌ Not in a git repository" >&2
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check for CLAUDE.md file
    if [[ ! -f "CLAUDE.md" ]]; then
        echo "❌ CLAUDE.md file not found" >&2
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check for required directories
    local required_dirs=("agentic-development" ".github/workflows")
    for dir in "${required_dirs[@]}"; do
        if [[ ! -d "$dir" ]]; then
            echo "❌ Required directory missing: $dir" >&2
            validation_errors=$((validation_errors + 1))
        fi
    done
    
    return $validation_errors
}

# Function to get current repository name for branch tracking
get_current_repo() {
    basename "$(git rev-parse --show-toplevel)"
}

# Function to check if current branch has a PR with reviewer comments
check_pr_review_safeguards() {
    local branch_name="$1"
    
    # Check if gh is available
    if ! command -v gh &> /dev/null; then
        echo "⚠️  Warning: gh CLI not available, skipping PR review check"
        return 0
    fi
    
    # Find PR for current branch
    local pr_number
    pr_number=$(gh pr list --head "$branch_name" --json number --jq '.[0].number' 2>/dev/null || echo "")
    
    if [[ -z "$pr_number" || "$pr_number" == "null" ]]; then
        # No PR exists for this branch
        return 0
    fi
    
    # Get PR comments from known reviewer accounts
    local reviewer_logins=("gemini-code-assist" "qodo-merge-pro" "tuvens")
    local has_reviews=false
    
    for reviewer in "${reviewer_logins[@]}"; do
        local review_count
        review_count=$(gh pr view "$pr_number" --json comments --jq "[.comments[] | select(.author.login == \"$reviewer\")] | length" 2>/dev/null || echo "0")
        
        if [[ "$review_count" -gt 0 ]]; then
            echo "🔒 REVIEW SAFEGUARD TRIGGERED"
            echo "   Branch: $branch_name"
            echo "   PR: #$pr_number"
            echo "   Reviewer comments found from: $reviewer ($review_count comments)"
            has_reviews=true
        fi
    done
    
    if [[ "$has_reviews" == "true" ]]; then
        echo ""
        echo "⚠️  DANGEROUS MODE DISABLED"
        echo "   This branch has active code review feedback that must be addressed"
        echo "   Using --dangerously-skip-permissions would bypass these important safeguards"
        echo ""
        echo "   To proceed with dangerous mode after addressing reviews:"
        echo "   1. Address all reviewer feedback"
        echo "   2. Get reviewer approval"
        echo "   3. Or use: claude --dangerously-skip-permissions (manual override)"
        echo ""
        return 1
    fi
    
    return 0
}

# Function to validate and format file references (shared between both setup scripts)
validate_files() {
    local files_input="$1"
    local validated_files=""
    local invalid_files=""
    
    if [[ -n "$files_input" ]]; then
        IFS=',' read -ra file_array <<< "$files_input"
        for file in "${file_array[@]}"; do
            file=$(echo "$file" | xargs) # trim whitespace
            if [[ -f "$file" ]]; then
                validated_files="${validated_files}- \`$file\`\n"
            else
                invalid_files="${invalid_files}- \`$file\` (NOT FOUND)\n"
            fi
        done
    fi
    
    echo -e "$validated_files"
    if [[ -n "$invalid_files" ]]; then
        echo "⚠️  Warning: Some files not found:" >&2
        echo -e "$invalid_files" >&2
    fi
}

# Function to create GitHub issue with standardized format and status labels
create_github_issue() {
    local agent_name="$1"
    local task_title="$2" 
    local task_description="$3"
    local context_file="$4"
    local files_to_examine="$5"
    local success_criteria="$6"
    
    # Create enhanced issue body using temporary file
    local temp_body_file
    temp_body_file=$(mktemp)
    
    # Load context from file if provided
    local context_content=""
    if [[ -n "$context_file" && -f "$context_file" ]]; then
        echo "📄 Loading context from: $context_file" >&2
        context_content=$(cat "$context_file")
    fi
    
    # Validate files if provided
    local validated_files=""
    if [[ -n "$files_to_examine" ]]; then
        echo "📁 Validating file references..." >&2
        validated_files=$(validate_files "$files_to_examine")
    fi
    
    # Create structured issue body
    cat > "$temp_body_file" << EOF
# $task_title

**Agent**: $agent_name  
**Generated**: $(date '+%Y-%m-%d %H:%M:%S')
**Status**: 🟢 Active

## Task Description
$task_description

EOF
    
    # Add context section if context file provided
    if [[ -n "$context_content" ]]; then
        cat >> "$temp_body_file" << EOF
## Context Analysis
$context_content

EOF
    fi
    
    # Add files section if files provided
    if [[ -n "$validated_files" ]]; then
        cat >> "$temp_body_file" << EOF
## Files to Examine
$validated_files

EOF
    fi
    
    # Add success criteria if provided
    if [[ -n "$success_criteria" ]]; then
        cat >> "$temp_body_file" << EOF
## Success Criteria
$success_criteria

EOF
    fi
    
    # Add standard sections for comprehensive context
    cat >> "$temp_body_file" << EOF
## Implementation Notes
- Review the task requirements carefully
- Follow the 6-step agent workflow pattern
- Update this issue with progress and findings
- Reference specific files and line numbers in comments
- Update status labels as work progresses

## Status Updates
- Use \`gh issue edit [number] --add-label 'status/waiting'\` when blocked
- Use \`gh issue edit [number] --add-label 'status/reviewing'\` when PR created
- Use \`gh issue edit [number] --add-label 'status/complete'\` when done

## Validation Checklist
- [ ] Task requirements understood
- [ ] Relevant files identified and examined
- [ ] Solution implemented according to requirements
- [ ] Testing completed (if applicable)
- [ ] Documentation updated (if applicable)
- [ ] Issue updated with final results

---
*Generated with Claude Code automation*
EOF
    
    # Create GitHub issue with status labels (send status to stderr to avoid interfering with return value)
    echo "   Creating issue with labels: $task_title" >&2
    local issue_url
    issue_url=$(gh issue create \
        --title "$task_title" \
        --body-file "$temp_body_file" \
        --assignee "@me" \
        --label "agent-task,agent/$agent_name,status/active,priority/medium")
    
    local github_issue
    github_issue=$(echo "$issue_url" | grep -o '[0-9]\+$')
    
    # Security and robustness validation for github_issue
    if [[ -z "$github_issue" ]]; then
        echo "❌ ERROR: Failed to extract GitHub issue number from URL: $issue_url" >&2
        [[ -f "$temp_body_file" ]] && rm -f "$temp_body_file"
        return 1
    fi
    
    # Additional security validation: ensure github_issue contains only digits
    if ! [[ "$github_issue" =~ ^[0-9]+$ ]]; then
        echo "❌ ERROR: Invalid GitHub issue number format: $github_issue" >&2
        echo "   Issue number must contain only digits for security" >&2
        [[ -f "$temp_body_file" ]] && rm -f "$temp_body_file"
        return 1
    fi
    
    # Clean up temp file
    [[ -f "$temp_body_file" ]] && rm -f "$temp_body_file"
    echo "✅ Created GitHub issue #$github_issue with status labels" >&2
    echo "   URL: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues/$github_issue" >&2
    echo "   Labels: agent-task, agent/$agent_name, status/active, priority/medium" >&2
    
    # Return the issue number via echo for caller to capture
    echo "$github_issue"
}


# Export functions so they can be used by sourcing scripts
export -f make_path_portable
export -f expand_portable_path
export -f sanitize_for_branch
export -f calculate_branch_name
export -f get_worktree_path
export -f get_repo_paths
export -f calculate_worktree_path
export -f handle_script_error
export -f validate_required_tools
export -f validate_git_repo
export -f validate_environment_setup
export -f get_current_repo
export -f check_pr_review_safeguards
export -f validate_files
export -f create_github_issue

# Prevent running this script directly
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    echo "❌ This is a function library and should not be executed directly"
    echo "   Usage: source shared-functions.sh"
    exit 1
fi