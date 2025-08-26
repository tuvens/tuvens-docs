#!/usr/bin/env bash
# File: update-comments.sh
# Purpose: Core implementation for /update command - GitHub comment updater
# 
# This script adds updates and progress reports to GitHub issues and PRs.
# Supports context inference and multiple argument formats.

set -euo pipefail

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

# Function to get current agent from git config or environment
get_current_agent() {
    # Try to get from git config first
    local agent
    agent=$(git config --get user.agent 2>/dev/null || echo "")
    
    # If not found, try to infer from branch name
    if [[ -z "$agent" ]]; then
        local current_branch
        current_branch=$(git branch --show-current 2>/dev/null || echo "")
        
        if [[ "$current_branch" =~ ^([^/]+)/ ]]; then
            agent="${BASH_REMATCH[1]}"
        fi
    fi
    
    # Default fallback
    if [[ -z "$agent" ]]; then
        agent="devops"
    fi
    
    echo "$agent"
}

# Function to create standardized update message
create_update_message() {
    local agent="$1"
    local custom_message="$2"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    cat << EOF
👤 **Identity**: $agent
🎯 **Addressing**: @all

## Progress Update
$custom_message

**Status**: in_progress
**Next Action**: continuing implementation
**Timeline**: $timestamp

---
*Generated via /update command*
EOF
}

# Function to prompt for update message if not provided
prompt_for_message() {
    local default_msg="Status update: work in progress"
    
    echo "📝 Enter update message (or press Enter for default):"
    echo "   Default: $default_msg"
    echo ""
    read -r -p "Message: " user_message
    
    if [[ -z "$user_message" ]]; then
        echo "$default_msg"
    else
        echo "$user_message"
    fi
}

# Function to add update to a PR
update_pr_comments() {
    local pr_number="$1"
    local message="$2"
    
    echo "📋 **PR #$pr_number**"
    
    # Check if PR exists
    if ! gh pr view "$pr_number" >/dev/null 2>&1; then
        echo "   ❌ PR not found"
        echo ""
        return 1
    fi
    
    # Get PR info for confirmation
    local pr_title
    local pr_state
    pr_title=$(gh pr view "$pr_number" --json title --jq '.title' 2>/dev/null || echo "Unknown")
    pr_state=$(gh pr view "$pr_number" --json state --jq '.state' 2>/dev/null || echo "Unknown")
    
    echo "   📌 Title: $pr_title"
    echo "   🏷️  State: $pr_state"
    
    # Add the comment
    if echo "$message" | gh pr comment "$pr_number" --body-file -; then
        echo "   ✅ Update posted successfully"
    else
        echo "   ❌ Failed to post update"
        return 1
    fi
    
    echo ""
    return 0
}

# Function to add update to an Issue
update_issue_comments() {
    local issue_number="$1"
    local message="$2"
    
    echo "📋 **Issue #$issue_number**"
    
    # Check if issue exists
    if ! gh issue view "$issue_number" >/dev/null 2>&1; then
        echo "   ❌ Issue not found"
        echo ""
        return 1
    fi
    
    # Get issue info for confirmation
    local issue_title
    local issue_state
    issue_title=$(gh issue view "$issue_number" --json title --jq '.title' 2>/dev/null || echo "Unknown")
    issue_state=$(gh issue view "$issue_number" --json state --jq '.state' 2>/dev/null || echo "Unknown")
    
    echo "   📌 Title: $issue_title"
    echo "   🏷️  State: $issue_state"
    
    # Add the comment
    if echo "$message" | gh issue comment "$issue_number" --body-file -; then
        echo "   ✅ Update posted successfully"
    else
        echo "   ❌ Failed to post update"
        return 1
    fi
    
    echo ""
    return 0
}

# Function to infer context from current branch/worktree
infer_context() {
    local message="$1"
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    
    if [[ -z "$current_branch" ]]; then
        echo "⚠️  Could not determine current branch for context inference"
        return 1
    fi
    
    echo "🔍 Inferring context from branch: $current_branch"
    echo ""
    
    # Look for PR associated with current branch
    local pr_number
    pr_number=$(gh pr list --head "$current_branch" --json number --jq '.[0].number' 2>/dev/null || echo "")
    
    if [[ -n "$pr_number" && "$pr_number" != "null" ]]; then
        echo "📍 Found PR associated with current branch"
        update_pr_comments "$pr_number" "$message"
        return 0
    fi
    
    # If no PR, look for issues that might mention this branch
    echo "📍 No PR found for branch. Checking for related issues..."
    
    # Search for issues that mention the branch name or related keywords
    local sanitized_branch
    sanitized_branch=$(echo "$current_branch" | sed 's/[^a-zA-Z0-9-]/ /g')
    
    local related_issues
    related_issues=$(gh issue list --search "$sanitized_branch" --json number --jq '.[].number' 2>/dev/null | head -1 || echo "")
    
    if [[ -n "$related_issues" ]]; then
        echo "📍 Found potentially related issue, updating the most relevant one:"
        while IFS= read -r issue_num; do
            if [[ -n "$issue_num" ]]; then
                update_issue_comments "$issue_num" "$message"
                return 0
            fi
        done <<< "$related_issues"
    fi
    
    echo "❓ No related PRs or Issues found for current branch"
    echo "   Try specifying PR or Issue numbers explicitly"
    echo ""
    return 1
}

# Function to parse argument and determine type (PR or Issue)
parse_argument() {
    local arg="$1"
    
    # Handle PR prefix (case insensitive)
    if [[ "$arg" =~ ^[Pp][Rr]([0-9]+)$ ]]; then
        echo "PR:${BASH_REMATCH[1]}"
        return 0
    fi
    
    # Handle Issue prefix (case insensitive)
    if [[ "$arg" =~ ^[Ii]([0-9]+)$ ]]; then
        echo "ISSUE:${BASH_REMATCH[1]}"
        return 0
    fi
    
    # Handle plain numbers (default to Issue)
    if [[ "$arg" =~ ^[0-9]+$ ]]; then
        echo "ISSUE:$arg"
        return 0
    fi
    
    echo "INVALID:$arg"
    return 1
}

# Function to extract custom message from arguments
extract_custom_message() {
    local args=("$@")
    local message=""
    local found_message=false
    
    # Look for arguments that don't match PR/Issue patterns
    for arg in "${args[@]}"; do
        if ! parse_argument "$arg" >/dev/null 2>&1; then
            # This doesn't look like a PR/Issue identifier, treat as message
            message="$arg"
            found_message=true
            break
        fi
    done
    
    if [[ "$found_message" == "true" ]]; then
        echo "$message"
    else
        echo ""
    fi
}

# Function to filter PR/Issue arguments
filter_target_arguments() {
    local args=("$@")
    local targets=()
    
    for arg in "${args[@]}"; do
        if parse_argument "$arg" >/dev/null 2>&1; then
            targets+=("$arg")
        fi
    done
    
    if [[ ${#targets[@]} -gt 0 ]]; then
        printf '%s\n' "${targets[@]}"
    fi
}

# Main execution
main() {
    local agent
    agent=$(get_current_agent)
    
    # Always prompt for message (keeping it simple like check command)
    local custom_message
    custom_message=$(prompt_for_message)
    
    # Create standardized update message
    local update_message
    update_message=$(create_update_message "$agent" "$custom_message")
    
    # If no arguments, infer from context
    if [[ $# -eq 0 ]]; then
        infer_context "$update_message"
        return $?
    fi
    
    # Process each argument (following check command pattern exactly)
    local processed_any=false
    
    for arg in "$@"; do
        local parsed
        if parsed=$(parse_argument "$arg" 2>/dev/null); then
            # Parsing successful
            :
        else
            echo "❌ Invalid argument format: $arg"
            echo "   Use PR<number>, I<number>, or just <number>"
            continue
        fi
        
        local type="${parsed%%:*}"
        local number="${parsed##*:}"
        
        case "$type" in
            "PR")
                update_pr_comments "$number" "$update_message"
                processed_any=true
                ;;
            "ISSUE")
                update_issue_comments "$number" "$update_message"
                processed_any=true
                ;;
            *)
                echo "❌ Invalid argument: $arg"
                ;;
        esac
    done
    
    if [[ "$processed_any" == "false" ]]; then
        echo "❌ No valid arguments processed"
        return 1
    fi
    
    return 0
}

# Execute main function only if not sourced
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi