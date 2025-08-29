#!/usr/bin/env bash
# File: status-determination-engine.sh  
# Purpose: Analyze events and determine appropriate status based on patterns and context
# Part of Phase 2 iTerm2 Status Automation

set -euo pipefail

# Pattern definitions for status determination

# BLOCKED patterns (highest priority after explicit status)
declare -a BLOCKED_PATTERNS=(
    "^BLOCKED:"
    "^blocked:"
    "cannot proceed"
    "stuck on"
    "blocker:"
    "impediment:"
    "merge conflict"
    "failing tests"
    "broken dependency"
    "fatal error"
    "compilation failed"
    "test failures blocking"
)

# WAITING patterns  
declare -a WAITING_PATTERNS=(
    "waiting for"
    "need clarification"
    "please advise"
    "awaiting feedback"
    "pending approval"
    "need input"
    "need help"
    "questions\?"
    "\?[[:space:]]*$"
)

# COMPLETE patterns
declare -a COMPLETE_PATTERNS=(
    "task complete"
    "work finished" 
    "done"
    "completed"
    "resolved"
    "fixed"
    "implemented successfully"
    "ready for deployment"
    "all requirements met"
)

# ACTIVE patterns (default for most activity)
declare -a ACTIVE_PATTERNS=(
    "working on"
    "implementing" 
    "in progress"
    "resuming work"
    "continuing with"
    "addressing feedback"
    "fixing"
    "updating"
    "refactoring"
    "testing"
)

# Function to determine status from comment content
determine_status_from_comment() {
    local comment_body="$1"
    local issue_number="$2"
    
    # Priority 1: Explicit Status declarations (highest priority)
    if echo "$comment_body" | grep -q "\*\*Status\*\*:"; then
        local explicit_status
        explicit_status=$(echo "$comment_body" | grep -o "\*\*Status\*\*:[^*]*" | cut -d':' -f2 | xargs | tr '[:upper:]' '[:lower:]')
        
        case "$explicit_status" in
            *"active"*|*"in progress"*|*"working"*) echo "active" ;;
            *"blocked"*) echo "blocked" ;;
            *"waiting"*|*"pending"*|*"on hold"*) echo "waiting" ;;
            *"review"*|*"reviewing"*) echo "reviewing" ;;
            *"complete"*|*"done"*|*"finished"*) echo "complete" ;;
            *"failed"*|*"cannot complete"*) echo "failed" ;;
            *) echo "active" ;;  # Default for unclear status
        esac
        return 0
    fi
    
    # Priority 2: Check for blocking keywords (case-insensitive)
    for pattern in "${BLOCKED_PATTERNS[@]}"; do
        if echo "$comment_body" | grep -qi "$pattern"; then
            echo "blocked"
            return 0
        fi
    done
    
    # Priority 3: Check for waiting indicators
    for pattern in "${WAITING_PATTERNS[@]}"; do
        if echo "$comment_body" | grep -qi "$pattern"; then
            echo "waiting"
            return 0
        fi
    done
    
    # Priority 4: Check for completion indicators  
    for pattern in "${COMPLETE_PATTERNS[@]}"; do
        if echo "$comment_body" | grep -qi "$pattern"; then
            echo "complete"
            return 0
        fi
    done
    
    # Priority 5: Check for active work indicators
    for pattern in "${ACTIVE_PATTERNS[@]}"; do
        if echo "$comment_body" | grep -qi "$pattern"; then
            echo "active"
            return 0
        fi
    done
    
    # Check context for additional clues
    local context_status
    context_status=$(analyze_comment_context "$comment_body" "$issue_number")
    
    if [[ -n "$context_status" ]]; then
        echo "$context_status"
    else
        # Default: If an agent is commenting, they're likely active
        echo "active"
    fi
}

# Function to analyze comment context for status hints
analyze_comment_context() {
    local comment_body="$1"
    local issue_number="$2"
    
    # Check if comment ends with a question (waiting for response)
    if echo "$comment_body" | grep -qE "\?[[:space:]]*$"; then
        echo "waiting"
        return 0
    fi
    
    # Check if comment mentions PR creation/submission
    if echo "$comment_body" | grep -qi "created pr\|submitted pr\|pull request\|ready for review"; then
        echo "reviewing"
        return 0
    fi
    
    # Check if comment addresses feedback (active work)
    if echo "$comment_body" | grep -qi "addressing\|fixed\|updated based on\|per feedback"; then
        echo "active"  
        return 0
    fi
    
    # Check if commenting on own PR (likely addressing reviews)
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    if [[ -n "$current_branch" ]]; then
        local pr_number
        pr_number=$(gh pr list --head "$current_branch" --json number --jq '.[0].number' 2>/dev/null || echo "")
        if [[ -n "$pr_number" ]]; then
            echo "active"  # Working on PR feedback
            return 0
        fi
    fi
    
    # No clear context indicators
    echo ""
}

# Function to determine status from git activity
determine_status_from_git() {
    local branch_name="$1"
    local issue_number="$2"
    
    # Check if there are recent commits (active work)
    local recent_commits
    recent_commits=$(git log --oneline --since="10 minutes ago" | wc -l | xargs)
    
    if [[ "$recent_commits" -gt 0 ]]; then
        # Check if there's an open PR
        local pr_number
        pr_number=$(gh pr list --head "$branch_name" --json number --jq '.[0].number' 2>/dev/null || echo "")
        
        if [[ -n "$pr_number" ]]; then
            # Recent commits on branch with PR = addressing feedback or continued work
            echo "active"
        else
            # Recent commits without PR = active development
            echo "active"
        fi
    else
        # No recent commits - maintain current status or default
        echo ""
    fi
}

# Function to check PR status for status determination
determine_status_from_pr() {
    local pr_number="$1"
    local issue_number="$2"
    
    if [[ -z "$pr_number" ]]; then
        echo ""
        return 0
    fi
    
    # Get PR details
    local pr_data
    pr_data=$(gh pr view "$pr_number" --json state,isDraft,reviewDecision,mergeable 2>/dev/null || echo "{}")
    
    local state
    local is_draft
    local review_decision
    local mergeable
    
    state=$(echo "$pr_data" | jq -r '.state')
    is_draft=$(echo "$pr_data" | jq -r '.isDraft')
    review_decision=$(echo "$pr_data" | jq -r '.reviewDecision')
    mergeable=$(echo "$pr_data" | jq -r '.mergeable')
    
    case "$state" in
        "MERGED")
            echo "complete"
            ;;
        "CLOSED")
            echo "failed"
            ;;
        "OPEN")
            if [[ "$is_draft" == "true" ]]; then
                echo "active"
            elif [[ "$review_decision" == "CHANGES_REQUESTED" ]]; then
                echo "active"  # Need to address feedback
            elif [[ "$review_decision" == "APPROVED" ]]; then
                echo "reviewing"  # Approved, waiting for merge
            elif [[ "$mergeable" == "CONFLICTING" ]]; then
                echo "blocked"  # Merge conflicts
            else
                echo "reviewing"  # Default for open PR
            fi
            ;;
        *)
            echo ""
            ;;
    esac
}

# Function to get current status from GitHub labels
get_current_status() {
    local issue_number="$1"
    
    local current_label
    current_label=$(gh issue view "$issue_number" --json labels --jq '.labels[].name' | grep "^status/" | head -1 2>/dev/null || echo "")
    
    if [[ -n "$current_label" ]]; then
        echo "${current_label#status/}"
    else
        echo "active"  # Default if no status label
    fi
}

# Main status determination function with priority resolution
determine_final_status() {
    local issue_number="$1"
    local comment_body="${2:-}"
    local pr_number="${3:-}"
    local branch_name="${4:-}"
    
    # Priority 1: Comment-based status (if comment provided)
    if [[ -n "$comment_body" ]]; then
        local comment_status
        comment_status=$(determine_status_from_comment "$comment_body" "$issue_number")
        if [[ -n "$comment_status" ]]; then
            echo "$comment_status"
            return 0
        fi
    fi
    
    # Priority 2: PR-based status (terminal states like merged/closed)
    if [[ -n "$pr_number" ]]; then
        local pr_status
        pr_status=$(determine_status_from_pr "$pr_number" "$issue_number")
        if [[ -n "$pr_status" ]] && [[ "$pr_status" =~ ^(complete|failed)$ ]]; then
            echo "$pr_status"
            return 0
        fi
    fi
    
    # Priority 3: Git activity status
    if [[ -n "$branch_name" ]]; then
        local git_status
        git_status=$(determine_status_from_git "$branch_name" "$issue_number")
        if [[ -n "$git_status" ]]; then
            echo "$git_status"
            return 0
        fi
    fi
    
    # Priority 4: PR status (non-terminal)
    if [[ -n "$pr_number" ]]; then
        local pr_status
        pr_status=$(determine_status_from_pr "$pr_number" "$issue_number")
        if [[ -n "$pr_status" ]]; then
            echo "$pr_status"
            return 0
        fi
    fi
    
    # Priority 5: Current status (no change)
    local current_status
    current_status=$(get_current_status "$issue_number")
    echo "$current_status"
}

# Function to validate status transitions
is_valid_transition() {
    local from_status="$1"
    local to_status="$2"
    
    # Define invalid transitions (mostly none for now, but could add logic)
    case "$from_status->$to_status" in
        "complete->active"|"complete->blocked"|"complete->waiting")
            # Completed tasks shouldn't go back to work states without explicit action
            return 1
            ;;
        "failed->active"|"failed->blocked"|"failed->waiting")  
            # Failed tasks shouldn't auto-resume
            return 1
            ;;
        *)
            return 0
            ;;
    esac
}

# Export functions for use by other scripts
export -f determine_status_from_comment
export -f determine_status_from_git
export -f determine_status_from_pr
export -f determine_final_status
export -f get_current_status
export -f is_valid_transition

# Test mode for debugging
if [[ "${BASH_SOURCE[0]}" == "${0}" ]] && [[ "${1:-}" == "test" ]]; then
    echo "🧪 Testing Status Determination Engine"
    echo ""
    
    # Test comment analysis
    echo "Testing comment patterns:"
    
    test_comments=(
        "BLOCKED: Cannot proceed due to merge conflict"
        "Working on implementing the new feature" 
        "Task completed successfully!"
        "Need clarification on requirements?"
        "**Status**: In Progress - fixing the issue"
        "Waiting for feedback from review"
    )
    
    for comment in "${test_comments[@]}"; do
        status=$(determine_status_from_comment "$comment" "123")
        echo "  '$comment' -> $status"
    done
fi