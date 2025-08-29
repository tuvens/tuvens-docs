#!/usr/bin/env bash
# iTerm2 Status Bar Updater for Agent Sessions - Enhanced Version with Automation
# Updates iTerm2 status bar with meaningful GitHub issue information
# Part of Phase 2 iTerm2 Status Automation

set -euo pipefail

# Source automation components if available
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/status-determination-engine.sh" ]]; then
    source "$SCRIPT_DIR/status-determination-engine.sh"
fi

# Function to set iTerm2 user variables
set_iterm_var() {
    local var_name="$1"
    local var_value="$2"
    printf '\033]1337;SetUserVar=%s=%s\007' "$var_name" "$(echo -n "$var_value" | base64)"
}

# Function to get current issue from worktree path
get_current_issue() {
    local current_path="$PWD"
    
    # Try to extract from branch name in worktree path
    # Pattern: /worktrees/agent-name/agent-name/feature/task-name-ISSUE
    if [[ "$current_path" =~ -([0-9]+)(/|$) ]]; then
        echo "${BASH_REMATCH[1]}"
        return
    fi
    
    # Fallback: check for .github-issue file
    if [[ -f ".github-issue" ]]; then
        cat ".github-issue"
        return
    fi
    
    # Try to get from current branch name
    local branch_name
    branch_name=$(git branch --show-current 2>/dev/null || echo "")
    if [[ "$branch_name" =~ -([0-9]+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
        return
    fi
    
    echo ""
}

# Function to calculate time ago
time_ago() {
    local timestamp="$1"
    local now=$(date +%s)
    local then=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$timestamp" +%s 2>/dev/null || echo "$now")
    local diff=$((now - then))
    
    if [[ $diff -lt 3600 ]]; then
        echo "$((diff / 60))m ago"
    elif [[ $diff -lt 86400 ]]; then
        echo "$((diff / 3600))h ago"
    elif [[ $diff -lt 604800 ]]; then
        echo "$((diff / 86400))d ago"
    else
        echo "$((diff / 604800))w ago"
    fi
}

# Helper function to fetch issue data from GitHub
fetch_issue_data() {
    local issue_number="$1"
    
    if [[ -z "$issue_number" ]]; then
        echo "{}"
        return 1
    fi
    
    local issue_data
    issue_data=$(gh issue view "$issue_number" --json number,title,state,labels,updatedAt,url,comments 2>/dev/null || echo "{}")
    
    if [[ "$issue_data" == "{}" ]] || [[ -z "$issue_data" ]]; then
        echo "{}"
        return 1
    fi
    
    echo "$issue_data"
    return 0
}

# Helper function to calculate file changes summary
calculate_file_changes() {
    local changes_summary=""
    
    # Check if we're in a git repository
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        echo "no changes"
        return 0
    fi
    
    # Get current branch
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    
    if [[ -z "$current_branch" ]]; then
        echo "no changes"
        return 0
    fi
    
    # Get file statistics
    local modified
    modified=$(git diff --name-only dev...HEAD 2>/dev/null | wc -l | tr -d ' ')
    
    local staged
    staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
    
    local untracked
    untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
    
    # Build descriptive summary
    if [[ $modified -gt 0 ]]; then
        changes_summary="${modified} changed"
    fi
    
    if [[ $staged -gt 0 ]]; then
        if [[ -n "$changes_summary" ]]; then
            changes_summary="$changes_summary, ${staged} staged"
        else
            changes_summary="${staged} staged"
        fi
    fi
    
    if [[ $untracked -gt 0 ]]; then
        if [[ -n "$changes_summary" ]]; then
            changes_summary="$changes_summary, ${untracked} new"
        else
            changes_summary="${untracked} new"
        fi
    fi
    
    if [[ -z "$changes_summary" ]]; then
        changes_summary="no changes"
    fi
    
    echo "$changes_summary"
}

# Helper function to get PR information
get_pr_info() {
    local current_branch
    current_branch=$(git branch --show-current 2>/dev/null || echo "")
    
    if [[ -z "$current_branch" ]]; then
        echo ""
        return 0
    fi
    
    local pr_number
    pr_number=$(gh pr list --head "$current_branch" --json number,state --jq '.[0] | "\(.number):\(.state)"' 2>/dev/null || echo "")
    
    if [[ -z "$pr_number" || "$pr_number" == "null:null" ]]; then
        echo ""
        return 0
    fi
    
    local pr_num="${pr_number%%:*}"
    local pr_state="${pr_number##*:}"
    
    case "$pr_state" in
        "OPEN")
            echo "PR #$pr_num 🟢"
            ;;
        "CLOSED")
            echo "PR #$pr_num ⚫"
            ;;
        "MERGED")
            echo "PR #$pr_num 🟣"
            ;;
        *)
            echo "PR #$pr_num"
            ;;
    esac
}

# Helper function to format status display
format_status_display() {
    local status="$1"
    local comment_count="$2"
    
    # Status emoji and text
    local status_emoji
    local status_display
    
    case "$status" in
        "active")     
            status_emoji="🟢"
            status_display="Active"
            ;;
        "waiting")    
            status_emoji="🟡"
            status_display="Waiting"
            ;;
        "blocked")    
            status_emoji="🔴"
            status_display="Blocked"
            ;;
        "reviewing")  
            status_emoji="⚫"
            status_display="Review"
            ;;
        "complete")   
            status_emoji="✅"
            status_display="Done"
            ;;
        *)            
            status_emoji="⚪"
            status_display="Unknown"
            ;;
    esac
    
    # Add activity indicator if there are recent comments
    if [[ $comment_count -gt 0 ]]; then
        status_display="$status_display 💬$comment_count"
    fi
    
    echo "$status_emoji $status_display"
}

# Helper function to set all iTerm variables
set_iterm_status_variables() {
    local issue_number="$1"
    local status_display="$2"
    local changes_summary="$3"
    local time_display="$4"
    local pr_info="$5"
    
    # Set all variables for status bar
    set_iterm_var "issue_number" "#$issue_number"
    set_iterm_var "issue_status" "$status_display"
    set_iterm_var "file_changes" "$changes_summary"
    set_iterm_var "issue_updated" "$time_display"
    set_iterm_var "pr_info" "$pr_info"
    
    # Also set a combined status for simpler display
    local full_status="#$issue_number ${status_display%% *}"
    if [[ -n "$changes_summary" && "$changes_summary" != "no changes" ]]; then
        full_status="$full_status • $changes_summary"
    fi
    if [[ -n "$pr_info" ]]; then
        full_status="$full_status • $pr_info"
    fi
    if [[ -n "$time_display" ]]; then
        full_status="$full_status • $time_display"
    fi
    set_iterm_var "full_status" "$full_status"
}

# Function to update status from GitHub
update_status() {
    local issue_number="$1"
    
    # Handle case where no issue is provided
    if [[ -z "$issue_number" ]]; then
        set_iterm_var "issue_number" "No Issue"
        set_iterm_var "issue_status" "⚪ none"
        set_iterm_var "file_changes" "—"
        set_iterm_var "issue_updated" ""
        set_iterm_var "pr_info" ""
        echo "❌ No issue detected in current directory: $PWD"
        return
    fi
    
    # Fetch issue data from GitHub using helper function
    local issue_data
    if ! issue_data=$(fetch_issue_data "$issue_number"); then
        set_iterm_var "issue_number" "#$issue_number"
        set_iterm_var "issue_status" "❌ not found"
        set_iterm_var "file_changes" "—"
        set_iterm_var "issue_updated" ""
        set_iterm_var "pr_info" ""
        echo "❌ Issue #$issue_number not found"
        return
    fi
    
    # Extract status label
    local status_label
    status_label=$(echo "$issue_data" | jq -r '.labels[] | select(.name | startswith("status/")) | .name' 2>/dev/null | head -1)
    local status="${status_label#status/}"
    status="${status:-active}"
    
    # Get comment count for activity indicator
    local comment_count
    comment_count=$(echo "$issue_data" | jq '.comments | length' 2>/dev/null || echo "0")
    
    # Get file changes count - more accurate method
    local file_count=0
    local changes_summary=""
    
    # Check if we're in a git repository
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Get current branch
        local current_branch
        current_branch=$(git branch --show-current 2>/dev/null || echo "")
        
        # Get file statistics
        if [[ -n "$current_branch" ]]; then
            # Count modified files
            local modified
            modified=$(git diff --name-only dev...HEAD 2>/dev/null | wc -l | tr -d ' ')
            
            # Count staged files
            local staged
            staged=$(git diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
            
            # Count untracked files
            local untracked
            untracked=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | tr -d ' ')
            
            file_count=$modified
            
            # Build descriptive summary
            if [[ $modified -gt 0 ]]; then
                changes_summary="${modified} changed"
            fi
            
            if [[ $staged -gt 0 ]]; then
                if [[ -n "$changes_summary" ]]; then
                    changes_summary="$changes_summary, ${staged} staged"
                else
                    changes_summary="${staged} staged"
                fi
            fi
            
            if [[ $untracked -gt 0 ]]; then
                if [[ -n "$changes_summary" ]]; then
                    changes_summary="$changes_summary, ${untracked} new"
                else
                    changes_summary="${untracked} new"
                fi
            fi
            
            if [[ -z "$changes_summary" ]]; then
                changes_summary="no changes"
            fi
        fi
    fi
    
    # Check for associated PR
    local pr_info=""
    local pr_number
    pr_number=$(gh pr list --head "$(git branch --show-current 2>/dev/null)" --json number,state --jq '.[0] | "\(.number):\(.state)"' 2>/dev/null || echo "")
    
    if [[ -n "$pr_number" && "$pr_number" != "null:null" ]]; then
        local pr_num="${pr_number%%:*}"
        local pr_state="${pr_number##*:}"
        
        case "$pr_state" in
            "OPEN")
                pr_info="PR #$pr_num 🟢"
                ;;
            "CLOSED")
                pr_info="PR #$pr_num ⚫"
                ;;
            "MERGED")
                pr_info="PR #$pr_num 🟣"
                ;;
            *)
                pr_info="PR #$pr_num"
                ;;
        esac
    fi
    
    # Get last update time
    local updated_at
    updated_at=$(echo "$issue_data" | jq -r '.updatedAt' 2>/dev/null)
    local time_display=""
    if [[ "$updated_at" != "null" && -n "$updated_at" ]]; then
        time_display=$(time_ago "$updated_at")
    fi
    
    # Status emoji and text
    local status_emoji
    local status_display
    case "$status" in
        "active")     
            status_emoji="🟢"
            status_display="Active"
            ;;
        "waiting")    
            status_emoji="🟡"
            status_display="Waiting"
            ;;
        "blocked")    
            status_emoji="🔴"
            status_display="Blocked"
            ;;
        "reviewing")  
            status_emoji="⚫"
            status_display="Review"
            ;;
        "complete")   
            status_emoji="✅"
            status_display="Done"
            ;;
        *)            
            status_emoji="⚪"
            status_display="Unknown"
            ;;
    esac
    
    # Add activity indicator if there are recent comments
    if [[ $comment_count -gt 0 ]]; then
        status_display="$status_display 💬$comment_count"
    fi
    
    # Set all variables for status bar
    set_iterm_var "issue_number" "#$issue_number"
    set_iterm_var "issue_status" "$status_emoji $status_display"
    set_iterm_var "file_changes" "$changes_summary"
    set_iterm_var "issue_updated" "$time_display"
    set_iterm_var "pr_info" "$pr_info"
    
    # Also set a combined status for simpler display
    local full_status="#$issue_number $status_emoji"
    if [[ -n "$changes_summary" && "$changes_summary" != "no changes" ]]; then
        full_status="$full_status • $changes_summary"
    fi
    if [[ -n "$pr_info" ]]; then
        full_status="$full_status • $pr_info"
    fi
    if [[ -n "$time_display" ]]; then
        full_status="$full_status • $time_display"
    fi
    set_iterm_var "full_status" "$full_status"
    
    # Console output for debugging
    echo "✅ Status updated for issue #$issue_number"
    echo "   Status: $status_emoji $status_display"
    echo "   Files: $changes_summary"
    if [[ -n "$pr_info" ]]; then
        echo "   PR: $pr_info"
    fi
    if [[ -n "$time_display" ]]; then
        echo "   Updated: $time_display"
    fi
}

# Function to write issue number to file for persistence
save_issue_number() {
    local issue_number="$1"
    if [[ -n "$issue_number" ]] && [[ "$issue_number" =~ ^[0-9]+$ ]]; then
        echo "$issue_number" > .github-issue
        echo "   Saved issue #$issue_number to .github-issue"
    fi
}

# Function to update status with manual override
update_status_with_override() {
    local issue="$1"
    local status_override="$2"
    local agent_override="${3:-}"
    
    # Get issue data from GitHub
    local issue_data
    if ! issue_data=$(gh issue view "$issue" --json number,title,state,labels,updatedAt,comments 2>/dev/null); then
        echo "❌ Could not fetch issue #$issue from GitHub"
        return 1
    fi
    
    # Override status emoji based on provided status
    local status_emoji
    case "$status_override" in
        "active")     status_emoji="🟢" ;;
        "waiting")    status_emoji="🟡" ;;  
        "blocked")    status_emoji="🔴" ;;
        "reviewing")  status_emoji="⚫" ;;
        "complete")   status_emoji="✅" ;;
        "failed")     status_emoji="⚠️" ;;
        *)            status_emoji="⚪" ;;
    esac
    
    # Get file changes (if in git repo)
    local file_changes="—"
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local changed_count
        changed_count=$(git diff --name-only 2>/dev/null | wc -l | xargs)
        local new_count  
        new_count=$(git ls-files --others --exclude-standard 2>/dev/null | wc -l | xargs)
        
        if [[ "$changed_count" -gt 0 ]] || [[ "$new_count" -gt 0 ]]; then
            if [[ "$new_count" -gt 0 ]]; then
                file_changes="$changed_count changed, $new_count new"
            else
                file_changes="$changed_count changed"
            fi
        else
            file_changes="0 files"
        fi
    fi
    
    # Get time info
    local updated_at
    updated_at=$(echo "$issue_data" | jq -r '.updatedAt')
    local time_since
    time_since=$(time_ago "$updated_at")
    
    # Get comment count
    local comment_count
    comment_count=$(echo "$issue_data" | jq -r '.comments | length')
    
    # Build status display
    local status_capitalized="$(tr '[:lower:]' '[:upper:]' <<< ${status_override:0:1})${status_override:1}"
    local status_display="${status_emoji} ${status_capitalized}"
    if [[ "$comment_count" -gt 0 ]]; then
        status_display="${status_display} 💬${comment_count}"
    fi
    
    # Check for PR
    local pr_info=""
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local current_branch
        current_branch=$(git branch --show-current 2>/dev/null || echo "")
        if [[ -n "$current_branch" ]]; then
            local pr_number
            pr_number=$(gh pr list --head "$current_branch" --json number --jq '.[0].number' 2>/dev/null || echo "")
            if [[ -n "$pr_number" ]]; then
                pr_info="PR #$pr_number $status_emoji"
            fi
        fi
    fi
    
    # Set all iTerm2 variables
    set_iterm_var "issue_number" "#$issue"
    set_iterm_var "issue_status" "$status_display"
    set_iterm_var "file_changes" "$file_changes"
    set_iterm_var "issue_updated" "$time_since"
    set_iterm_var "pr_info" "$pr_info"
    
    # Create full status summary
    local full_status="#$issue $status_emoji"
    if [[ "$file_changes" != "—" ]]; then
        full_status="$full_status • $file_changes"
    fi
    if [[ -n "$pr_info" ]]; then
        full_status="$full_status • $pr_info"
    fi
    full_status="$full_status • $time_since"
    
    set_iterm_var "full_status" "$full_status"
    
    # Display confirmation
    local display_agent="${agent_override:-$(whoami)}"
    echo "✅ Status updated for issue #$issue"
    echo "   Status: $status_display"
    echo "   Files: $file_changes"  
    echo "   Updated: $time_since"
    if [[ -n "$agent_override" ]]; then
        echo "   Agent: $agent_override"
    fi
}

# Function to debug issue detection
debug_issue_detection() {
    local issue="$1"
    
    echo "🔍 Debug: Issue Detection Methods for #$issue"
    echo "================================================"
    
    # Method 1: Current directory detection
    local current_issue
    current_issue=$(get_current_issue)
    echo "1. Current directory detection: ${current_issue:-none}"
    
    # Method 2: .github-issue file
    if [[ -f ".github-issue" ]]; then
        local file_issue
        file_issue=$(cat ".github-issue")
        echo "2. .github-issue file: $file_issue"
    else
        echo "2. .github-issue file: not found"
    fi
    
    # Method 3: Branch name
    local branch_name
    branch_name=$(git branch --show-current 2>/dev/null || echo "")
    echo "3. Branch name: $branch_name"
    if [[ "$branch_name" =~ -([0-9]+)$ ]]; then
        echo "   Extracted issue: ${BASH_REMATCH[1]}"
    fi
    
    # Method 4: GitHub API check
    echo "4. GitHub API check:"
    if gh issue view "$issue" --json number,title >/dev/null 2>&1; then
        local title
        title=$(gh issue view "$issue" --json title --jq '.title')
        echo "   ✅ Issue exists: $title"
    else
        echo "   ❌ Issue not found or no access"
    fi
    
    # Method 5: Current worktree info
    local worktree_path
    worktree_path=$(git worktree list | grep -F "$(pwd)" | head -1 || echo "")
    echo "5. Worktree info: ${worktree_path:-not in worktree}"
    
    # Method 6: Status determination (if engine available)
    if command -v determine_final_status >/dev/null 2>&1; then
        local determined_status
        determined_status=$(determine_final_status "$issue" "" "" "$branch_name")
        echo "6. Status engine: $determined_status"
    else
        echo "6. Status engine: not available"
    fi
}

# Main execution
main() {
    case "${1:-auto}" in
        "auto")
            # Auto-detect issue from current directory
            issue=$(get_current_issue)
            if [[ -n "$issue" ]]; then
                update_status "$issue"
                save_issue_number "$issue"
            else
                echo "❌ No issue detected in current directory"
                echo "   Path: $PWD"
                echo ""
                echo "   Trying to detect from branch name..."
                branch=$(git branch --show-current 2>/dev/null)
                echo "   Current branch: $branch"
                echo ""
                echo "   To manually set: $0 [issue_number]"
                update_status ""
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
                else
                    # Try to detect issue and save it
                    branch=$(git branch --show-current 2>/dev/null)
                    if [[ "$branch" =~ -([0-9]+)$ ]]; then
                        issue="${BASH_REMATCH[1]}"
                        save_issue_number "$issue"
                        update_status "$issue"
                    fi
                fi
                sleep 30
            done
            ;;
        "test")
            # Test mode - show all variables
            echo "🧪 Test mode - setting example values..."
            set_iterm_var "issue_number" "#123"
            set_iterm_var "issue_status" "🟢 Active 💬3"
            set_iterm_var "file_changes" "5 changed, 2 staged"
            set_iterm_var "issue_updated" "2h ago"
            set_iterm_var "pr_info" "PR #456 🟢"
            set_iterm_var "full_status" "#123 🟢 • 5 changed • PR #456 • 2h ago"
            echo "✅ Test values set - check your status bar!"
            ;;
        "auto-status")
            # Automation mode: auto-detect with status override
            issue=$(get_current_issue)
            if [[ -n "$issue" ]] && [[ -n "${2:-}" ]]; then
                update_status_with_override "$issue" "$2"
                save_issue_number "$issue"
            else
                echo "Usage: $0 auto-status [status]"
                echo "  status: active|waiting|blocked|reviewing|complete|failed"
            fi
            ;;
        "webhook")
            # Webhook automation mode: issue + status + agent
            if [[ $# -ge 4 ]]; then
                local issue="$2"
                local status="$3"
                local agent="$4"
                update_status_with_override "$issue" "$status" "$agent"
                save_issue_number "$issue"
            else
                echo "Usage: $0 webhook [issue_number] [status] [agent_name]"
            fi
            ;;
        "debug")
            # Debug mode: show all detection methods
            if [[ -n "${2:-}" ]]; then
                debug_issue_detection "$2"
            else
                echo "Usage: $0 debug [issue_number]"
            fi
            ;;
        [0-9]*)
            # Manual issue number provided (with optional status)
            if [[ -n "${2:-}" ]]; then
                update_status_with_override "$1" "$2"
            else
                update_status "$1"
            fi
            save_issue_number "$1"
            ;;
        *)
            echo "Usage: $0 [auto|monitor|test|auto-status|webhook|debug|issue_number] [status] [agent]"
            echo ""
            echo "Modes:"
            echo "  auto             - Auto-detect issue from current directory (default)"
            echo "  monitor          - Continuous monitoring mode (updates every 30s)"
            echo "  test             - Set test values to verify status bar"
            echo "  auto-status [status] - Auto-detect issue with status override"
            echo "  webhook [issue] [status] [agent] - Update from webhook automation"
            echo "  debug [issue]    - Show detection methods for issue"
            echo "  [issue_number]   - Update specific issue number"
            echo "  [issue] [status] - Update issue with specific status"
            echo ""
            echo "Status values: active, waiting, blocked, reviewing, complete, failed"
            ;;
    esac
}

main "$@"