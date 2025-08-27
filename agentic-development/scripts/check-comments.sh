#!/usr/bin/env bash
# File: check-comments.sh
# Purpose: Core implementation for /check command - GitHub comment status checker
# 
# This script checks comment status on GitHub issues and PRs without responding.
# Supports context inference and multiple argument formats.

set -euo pipefail

# Source shared functions
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

# Function to display comment summary for a PR
check_pr_comments() {
    local pr_number="$1"
    
    echo "📋 **PR #$pr_number**"
    
    # Check if PR exists
    if ! gh pr view "$pr_number" >/dev/null 2>&1; then
        echo "   ❌ PR not found"
        echo ""
        return 1
    fi
    
    # Get PR info
    local pr_title
    local pr_author
    local pr_state
    pr_title=$(gh pr view "$pr_number" --json title --jq '.title' 2>/dev/null || echo "Unknown")
    pr_author=$(gh pr view "$pr_number" --json author --jq '.author.login' 2>/dev/null || echo "Unknown")
    pr_state=$(gh pr view "$pr_number" --json state --jq '.state' 2>/dev/null || echo "Unknown")
    
    echo "   📌 Title: $pr_title"
    echo "   👤 Author: $pr_author"
    echo "   🏷️  State: $pr_state"
    
    # Get comment count and latest comments
    local comment_count
    comment_count=$(gh pr view "$pr_number" --json comments --jq '.comments | length' 2>/dev/null || echo "0")
    
    echo "   💬 Comments: $comment_count"
    
    if [[ "$comment_count" -gt 0 ]]; then
        # Get latest 3 comments with author and preview
        local latest_comments
        latest_comments=$(gh pr view "$pr_number" --json comments --jq '.comments[-3:] | reverse | .[] | "   └─ \(.author.login): \(.body | split("\n")[0] | .[0:80])\(if (.body | length) > 80 then "..." else "" end)"' 2>/dev/null || echo "")
        
        if [[ -n "$latest_comments" ]]; then
            echo "$latest_comments"
        fi
        
        # Check for reviewer comments (from known review accounts)
        local reviewer_logins=("gemini-code-assist" "qodo-merge-pro" "tuvens")
        local has_reviews=false
        
        for reviewer in "${reviewer_logins[@]}"; do
            local review_count
            review_count=$(gh pr view "$pr_number" --json comments --jq "[.comments[] | select(.author.login == \"$reviewer\")] | length" 2>/dev/null || echo "0")
            
            if [[ "$review_count" -gt 0 ]]; then
                echo "   🔍 Reviewer comments from $reviewer: $review_count"
                has_reviews=true
            fi
        done
        
        if [[ "$has_reviews" == "true" ]]; then
            echo "   ⚠️  Active reviewer feedback detected"
        fi
    else
        echo "   ✨ No comments yet"
    fi
    
    echo ""
    return 0
}

# Function to display comment summary for an Issue
check_issue_comments() {
    local issue_number="$1"
    
    echo "📋 **Issue #$issue_number**"
    
    # Check if issue exists
    if ! gh issue view "$issue_number" >/dev/null 2>&1; then
        echo "   ❌ Issue not found"
        echo ""
        return 1
    fi
    
    # Get issue info
    local issue_title
    local issue_author
    local issue_state
    issue_title=$(gh issue view "$issue_number" --json title --jq '.title' 2>/dev/null || echo "Unknown")
    issue_author=$(gh issue view "$issue_number" --json author --jq '.author.login' 2>/dev/null || echo "Unknown")
    issue_state=$(gh issue view "$issue_number" --json state --jq '.state' 2>/dev/null || echo "Unknown")
    
    echo "   📌 Title: $issue_title"
    echo "   👤 Author: $issue_author"
    echo "   🏷️  State: $issue_state"
    
    # Get comment count and latest comments
    local comment_count
    comment_count=$(gh issue view "$issue_number" --json comments --jq '.comments | length' 2>/dev/null || echo "0")
    
    echo "   💬 Comments: $comment_count"
    
    if [[ "$comment_count" -gt 0 ]]; then
        # Get latest 3 comments with author and preview
        local latest_comments
        latest_comments=$(gh issue view "$issue_number" --json comments --jq '.comments[-3:] | reverse | .[] | "   └─ \(.author.login): \(.body | split("\n")[0] | .[0:80])\(if (.body | length) > 80 then "..." else "" end)"' 2>/dev/null || echo "")
        
        if [[ -n "$latest_comments" ]]; then
            echo "$latest_comments"
        fi
    else
        echo "   ✨ No comments yet"
    fi
    
    echo ""
    return 0
}

# Function to infer context from current branch/worktree
infer_context() {
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
        check_pr_comments "$pr_number"
        return 0
    fi
    
    # If no PR, look for issues that might mention this branch
    echo "📍 No PR found for branch. Checking for related issues..."
    
    # Search for issues that mention the branch name or related keywords
    local sanitized_branch
    sanitized_branch=$(echo "$current_branch" | sed 's/[^a-zA-Z0-9-]/ /g')
    
    local related_issues
    related_issues=$(gh issue list --search "$sanitized_branch" --json number --jq '.[].number' 2>/dev/null | head -3 || echo "")
    
    if [[ -n "$related_issues" ]]; then
        echo "📍 Found potentially related issues:"
        while IFS= read -r issue_num; do
            if [[ -n "$issue_num" ]]; then
                check_issue_comments "$issue_num"
            fi
        done <<< "$related_issues"
        return 0
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

# Main execution
main() {
    # If no arguments, infer from context
    if [[ $# -eq 0 ]]; then
        infer_context
        return $?
    fi
    
    # Process each argument
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
                check_pr_comments "$number"
                processed_any=true
                ;;
            "ISSUE")
                check_issue_comments "$number"
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

# Execute main function
main "$@"