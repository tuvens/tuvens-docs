#!/usr/bin/env bash
# File: github-webhook-handler.sh
# Purpose: Process GitHub webhook events and trigger status updates
# Part of Phase 2 iTerm2 Status Automation

set -euo pipefail

# Source shared functions and patterns
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/status-determination-engine.sh"

# Function to process issue comment events
process_issue_comment() {
    local payload="$1"
    local issue_number
    local comment_body
    local comment_author
    local agent_name
    
    # Extract relevant fields from JSON payload
    issue_number=$(echo "$payload" | jq -r '.issue.number')
    comment_body=$(echo "$payload" | jq -r '.comment.body')
    comment_author=$(echo "$payload" | jq -r '.comment.user.login')
    
    # Check if this is an agent comment (follows protocol)
    if echo "$comment_body" | grep -q "^👤 \*\*Identity\*\*:"; then
        # Extract agent name from comment
        agent_name=$(echo "$comment_body" | grep -o "Identity\*\*: [a-z-]*" | cut -d' ' -f2)
        
        # Determine status from comment
        local new_status
        new_status=$(determine_status_from_comment "$comment_body" "$issue_number")
        
        # Update GitHub labels
        update_github_labels "$issue_number" "$new_status"
        
        # Update iTerm2 status
        "$SCRIPT_DIR/iterm-status-updater.sh" "$issue_number" "$new_status" "$agent_name"
        
        echo "✅ Processed comment from $agent_name on issue #$issue_number - Status: $new_status"
    fi
}

# Function to process pull request events
process_pull_request() {
    local payload="$1"
    local action
    local pr_number
    local issue_number
    local is_draft
    local state
    local merged
    
    # Extract PR details
    action=$(echo "$payload" | jq -r '.action')
    pr_number=$(echo "$payload" | jq -r '.pull_request.number')
    is_draft=$(echo "$payload" | jq -r '.pull_request.draft')
    state=$(echo "$payload" | jq -r '.pull_request.state')
    merged=$(echo "$payload" | jq -r '.pull_request.merged')
    
    # Try to find linked issue from PR body
    issue_number=$(echo "$payload" | jq -r '.pull_request.body' | grep -oE "(Fixes|Closes|Resolves) #[0-9]+" | grep -oE "[0-splits+" | head -1 || echo "")
    
    if [[ -z "$issue_number" ]]; then
        echo "⚠️  No linked issue found for PR #$pr_number"
        return 0
    fi
    
    # Determine status based on PR event
    local new_status=""
    case "$action" in
        "opened")
            if [[ "$is_draft" == "false" ]]; then
                new_status="reviewing"
            else
                new_status="active"
            fi
            ;;
        "ready_for_review")
            new_status="reviewing"
            ;;
        "closed")
            if [[ "$merged" == "true" ]]; then
                new_status="complete"
            else
                new_status="failed"
            fi
            ;;
        "review_requested")
            new_status="reviewing"
            ;;
    esac
    
    if [[ -n "$new_status" ]]; then
        # Update status
        update_github_labels "$issue_number" "$new_status"
        
        # Find agent from issue assignee or branch name
        local agent_name
        agent_name=$(get_agent_from_issue "$issue_number")
        
        # Update iTerm2
        "$SCRIPT_DIR/iterm-status-updater.sh" "$issue_number" "$new_status" "$agent_name"
        
        echo "✅ Processed PR #$pr_number event '$action' for issue #$issue_number - Status: $new_status"
    fi
}

# Function to process push events
process_push_event() {
    local payload="$1"
    local ref
    local branch_name
    local agent_name
    local issue_number
    
    # Extract push details
    ref=$(echo "$payload" | jq -r '.ref')
    branch_name="${ref#refs/heads/}"
    
    # Extract agent and issue from branch name (agent/type/task-name)
    if [[ "$branch_name" =~ ^([a-z-]+)/[^/]+/.*$ ]]; then
        agent_name="${BASH_REMATCH[1]}"
        
        # Try to find issue number from commit messages or branch tracking
        issue_number=$(find_issue_from_branch "$branch_name")
        
        if [[ -n "$issue_number" ]]; then
            # Check if there's an open PR
            local pr_exists
            pr_exists=$(gh pr list --head "$branch_name" --json number --jq '.[0].number' 2>/dev/null || echo "")
            
            local new_status
            if [[ -n "$pr_exists" ]]; then
                new_status="reviewing"
            else
                new_status="active"
            fi
            
            # Update status
            update_github_labels "$issue_number" "$new_status"
            "$SCRIPT_DIR/iterm-status-updater.sh" "$issue_number" "$new_status" "$agent_name"
            
            echo "✅ Processed push to $branch_name for issue #$issue_number - Status: $new_status"
        fi
    fi
}

# Function to process pull request review events
process_pr_review() {
    local payload="$1"
    local action
    local pr_number
    local review_state
    local reviewer
    local issue_number
    
    # Extract review details
    action=$(echo "$payload" | jq -r '.action')
    pr_number=$(echo "$payload" | jq -r '.pull_request.number')
    review_state=$(echo "$payload" | jq -r '.review.state')
    reviewer=$(echo "$payload" | jq -r '.review.user.login')
    
    # Find linked issue
    issue_number=$(echo "$payload" | jq -r '.pull_request.body' | grep -oE "(Fixes|Closes|Resolves) #[0-9]+" | grep -oE "[0-9]+" | head -1 || echo "")
    
    if [[ -z "$issue_number" ]]; then
        return 0
    fi
    
    # Determine status based on review state
    local new_status=""
    case "$review_state" in
        "changes_requested")
            new_status="active"  # Agent needs to address feedback
            ;;
        "approved")
            new_status="reviewing"  # Still reviewing, waiting for merge
            ;;
    esac
    
    if [[ -n "$new_status" ]]; then
        # Update status
        update_github_labels "$issue_number" "$new_status"
        
        # Find agent
        local agent_name
        agent_name=$(get_agent_from_issue "$issue_number")
        
        # Update iTerm2
        "$SCRIPT_DIR/iterm-status-updater.sh" "$issue_number" "$new_status" "$agent_name"
        
        echo "✅ Processed PR review on #$pr_number by $reviewer - Status: $new_status"
    fi
}

# Helper function to update GitHub labels
update_github_labels() {
    local issue_number="$1"
    local new_status="$2"
    
    # Remove all existing status labels
    local status_labels=("status/active" "status/waiting" "status/blocked" "status/reviewing" "status/complete" "status/failed")
    for label in "${status_labels[@]}"; do
        gh issue edit "$issue_number" --remove-label "$label" 2>/dev/null || true
    done
    
    # Add new status label
    gh issue edit "$issue_number" --add-label "status/$new_status" 2>/dev/null || true
}

# Helper function to get agent name from issue
get_agent_from_issue() {
    local issue_number="$1"
    
    # Try to get from agent/ labels
    local agent_label
    agent_label=$(gh issue view "$issue_number" --json labels --jq '.labels[].name' | grep "^agent/" | head -1 || echo "")
    
    if [[ -n "$agent_label" ]]; then
        echo "${agent_label#agent/}"
    else
        # Fallback: try to get from assignee
        gh issue view "$issue_number" --json assignees --jq '.assignees[0].login' 2>/dev/null || echo "unknown"
    fi
}

# Helper function to find issue from branch
find_issue_from_branch() {
    local branch_name="$1"
    
    # Check if .github-issue file exists in worktree
    local worktree_path
    worktree_path=$(git worktree list | grep -F "[$branch_name]" | awk '{print $1}' || echo "")
    
    if [[ -n "$worktree_path" ]] && [[ -f "$worktree_path/.github-issue" ]]; then
        cat "$worktree_path/.github-issue"
    else
        # Try to extract from branch name or recent commits
        echo ""
    fi
}

# Main webhook handler
main() {
    local event_type="$1"
    local event_payload="$2"
    
    echo "🔄 Processing GitHub webhook: $event_type"
    
    case "$event_type" in
        "issue_comment"|"issues")
            process_issue_comment "$event_payload"
            ;;
        "pull_request")
            process_pull_request "$event_payload"
            ;;
        "push")
            process_push_event "$event_payload"
            ;;
        "pull_request_review")
            process_pr_review "$event_payload"
            ;;
        *)
            echo "⚠️  Unknown event type: $event_type"
            ;;
    esac
}

# Execute main if called directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    if [[ $# -lt 2 ]]; then
        echo "Usage: $0 <event_type> <event_payload_json>"
        exit 1
    fi
    
    main "$@"
fi