#!/usr/bin/env bash
# iTerm2 Status Bar Updater for Agent Sessions
# Updates iTerm2 status bar with real-time GitHub issue information

set -euo pipefail

# Function to set iTerm2 user variables
set_iterm_var() {
    local var_name="$1"
    local var_value="$2"
    printf '\033]1337;SetUserVar=%s=%s\007' "$var_name" "$(echo -n "$var_value" | base64)"
}

# Function to get current issue from worktree path
get_current_issue() {
    local current_path="$PWD"
    if [[ "$current_path" =~ /([^/]+)/([^/]+)-([0-9]+)$ ]]; then
        echo "${BASH_REMATCH[3]}"
    elif [[ -f ".github-issue" ]]; then
        cat ".github-issue"
    else
        echo ""
    fi
}

# Function to update status from GitHub
update_status() {
    local issue_number="$1"
    
    if [[ -z "$issue_number" ]]; then
        set_iterm_var "issue_number" "No Issue"
        set_iterm_var "issue_status" "⚪ none"
        set_iterm_var "file_changes" "0 files"
        set_iterm_var "issue_updated" "--:--"
        return
    fi
    
    # Get issue data from GitHub
    local issue_data
    issue_data=$(gh issue view "$issue_number" --json number,title,state,labels,updatedAt,url 2>/dev/null || echo "{}")
    
    if [[ "$issue_data" == "{}" ]]; then
        set_iterm_var "issue_number" "#$issue_number"
        set_iterm_var "issue_status" "❌ not found"
        set_iterm_var "file_changes" "0 files"
        set_iterm_var "issue_updated" "--:--"
        return
    fi
    
    # Extract status label
    local status_label
    status_label=$(echo "$issue_data" | jq -r '.labels[] | select(.name | startswith("status/")) | .name' 2>/dev/null | head -1)
    local status="${status_label#status/}"
    status="${status:-active}"
    
    # Get file changes count
    local file_count
    file_count=$(git diff --name-only dev...HEAD 2>/dev/null | wc -l | tr -d ' ')
    
    # Check for associated PR
    local pr_number
    pr_number=$(gh pr list --head "$(git branch --show-current 2>/dev/null)" --json number --jq '.[0].number' 2>/dev/null || echo "")
    
    # Status emoji
    local status_emoji
    case "$status" in
        "active")     status_emoji="🟢" ;;
        "waiting")    status_emoji="🟡" ;;
        "blocked")    status_emoji="🔴" ;;
        "reviewing")  status_emoji="⚫" ;;
        "complete")   status_emoji="✅" ;;
        *)            status_emoji="⚪" ;;
    esac
    
    # Set all variables for status bar
    set_iterm_var "issue_number" "#$issue_number"
    set_iterm_var "issue_status" "$status_emoji $status"
    set_iterm_var "issue_updated" "$(date +%H:%M)"
    set_iterm_var "file_changes" "$file_count files"
    
    # Set PR info if exists
    if [[ -n "$pr_number" ]]; then
        set_iterm_var "pr_info" "PR #$pr_number"
    else
        set_iterm_var "pr_info" ""
    fi
    
    echo "✅ Updated status: #$issue_number - $status_emoji $status ($file_count files)"
}

# Main execution
case "${1:-auto}" in
    "auto")
        # Auto-detect issue from current directory
        issue=$(get_current_issue)
        if [[ -n "$issue" ]]; then
            update_status "$issue"
        else
            echo "❌ No issue detected in current directory"
            echo "   Current path: $PWD"
            set_iterm_var "issue_number" "No Issue"
            set_iterm_var "issue_status" "⚪ none"
            set_iterm_var "file_changes" "0 files"
            set_iterm_var "issue_updated" "--:--"
        fi
        ;;
    "monitor")
        # Continuous monitoring mode
        echo "🔄 Starting continuous status monitoring (updates every 30s)..."
        echo "   Press Ctrl+C to stop"
        while true; do
            issue=$(get_current_issue)
            if [[ -n "$issue" ]]; then
                update_status "$issue" 2>/dev/null || true
            fi
            sleep 30
        done
        ;;
    [0-9]*)
        # Manual issue number provided
        update_status "$1"
        ;;
    *)
        echo "Usage: $0 [auto|monitor|issue_number]"
        echo "  auto         - Auto-detect issue from current directory (default)"
        echo "  monitor      - Continuous monitoring mode (updates every 30s)"
        echo "  issue_number - Update specific issue number"
        ;;
esac