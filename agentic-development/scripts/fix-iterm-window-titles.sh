#!/usr/bin/env bash
# File: fix-iterm-window-titles.sh
# Purpose: Immediate fix for iTerm2 window title issues in agent workflow
# 
# This script addresses the problem where all agent windows show "Vibe Coder #1"
# instead of proper agent names and issue numbers.

set -euo pipefail

echo "🔧 iTerm2 Window Title Fix"
echo "=========================="
echo ""

# Function to get GitHub issue status and info
get_issue_status() {
    local issue_number="$1"
    local issue_data
    
    if issue_data=$(gh issue view "$issue_number" --json number,title,state,labels,updatedAt 2>/dev/null); then
        local status_label
        status_label=$(echo "$issue_data" | jq -r '.labels[] | select(.name | startswith("status/")) | .name' | head -1)
        local status="${status_label#status/}"
        local updated_at
        updated_at=$(echo "$issue_data" | jq -r '.updatedAt')
        local time_ago
        time_ago=$(date -j -f "%Y-%m-%dT%H:%M:%SZ" "$updated_at" "+%s" 2>/dev/null | xargs -I {} bash -c 'echo $(( ($(date +%s) - {}) / 3600 ))h ago' 2>/dev/null || echo "recently")
        
        echo "${status:-active}|${time_ago}"
    else
        echo "unknown|unknown"
    fi
}

# Function to get file change count for current branch
get_file_changes() {
    local base_branch="${1:-dev}"
    local file_count
    file_count=$(git diff --name-only "$base_branch"...HEAD 2>/dev/null | wc -l | tr -d ' ')
    echo "${file_count:-0} files"
}

# Function to update iTerm2 window title and badge
update_iterm_title() {
    local agent_name="$1"
    local issue_number="$2"
    local status_info="$3"
    local file_changes="$4"
    
    local status
    local time_ago
    IFS='|' read -r status time_ago <<< "$status_info"
    
    # Status emoji mapping
    local status_emoji
    case "$status" in
        "active")     status_emoji="🟢" ;;
        "waiting")    status_emoji="🟡" ;;
        "blocked")    status_emoji="🔴" ;;
        "reviewing")  status_emoji="⚫" ;;
        "complete")   status_emoji="✅" ;;
        *)            status_emoji="⚪" ;;
    esac
    
    local window_title="$agent_name #$issue_number - ${status_emoji} ${status^^}"
    local badge_text="${status_emoji} ${status^^}\\n${file_changes}\\n${time_ago}"
    
    echo "Updating iTerm2 title: $window_title"
    
    # Update window title using escape sequence (works in most terminals)
    printf '\e]0;%s\a' "$window_title"
    
    # Update iTerm2 badge if available
    if [[ "${TERM_PROGRAM:-}" == "iTerm.app" ]]; then
        printf '\e]1337;SetBadgeFormat=%s\a' "$badge_text"
    fi
    
    # Also try AppleScript method for iTerm2
    if command -v osascript >/dev/null 2>&1 && [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "
        tell application \"iTerm2\"
            try
                tell current session of current window
                    set name to \"$window_title\"
                end tell
            on error
                -- Ignore errors if not in iTerm2
            end try
        end tell" 2>/dev/null || true
    fi
    
    echo "✅ Updated window title and badge"
}

# Function to fix all agent windows
fix_all_windows() {
    echo "🔍 Scanning for agent worktrees..."
    
    # Find all git worktrees that match agent patterns
    if command -v git >/dev/null 2>&1; then
        local worktree_list
        worktree_list=$(git worktree list --porcelain 2>/dev/null || echo "")
        
        if [[ -n "$worktree_list" ]]; then
            echo "$worktree_list" | grep "^worktree " | while read -r line; do
                local worktree_path="${line#worktree }"
                
                # Check if this looks like an agent worktree
                if [[ "$worktree_path" =~ /worktrees/[^/]+/([^/]+)/([^/]+) ]]; then
                    local agent_name="${BASH_REMATCH[1]}"
                    local branch_part="${BASH_REMATCH[2]}"
                    
                    # Try to extract issue number from branch or directory
                    local issue_number
                    if [[ "$branch_part" =~ \#([0-9]+) ]] || [[ "$branch_part" =~ -([0-9]+)$ ]]; then
                        issue_number="${BASH_REMATCH[1]}"
                    else
                        # Look for issue files or other indicators
                        if [[ -f "$worktree_path/.github-issue" ]]; then
                            issue_number=$(cat "$worktree_path/.github-issue")
                        else
                            continue  # Skip if we can't determine issue number
                        fi
                    fi
                    
                    echo "Found agent worktree: $agent_name #$issue_number"
                    
                    # Get status and file changes (in context of the worktree)
                    local status_info
                    status_info=$(cd "$worktree_path" && get_issue_status "$issue_number")
                    
                    local file_changes
                    file_changes=$(cd "$worktree_path" && get_file_changes "dev")
                    
                    # Update the window title for this worktree
                    update_iterm_title "$agent_name" "$issue_number" "$status_info" "$file_changes"
                fi
            done
        else
            echo "No worktrees found or not in a git repository"
        fi
    else
        echo "Git not available, cannot scan worktrees"
    fi
}

# Function to fix current window
fix_current_window() {
    local current_path="$PWD"
    
    echo "🔍 Analyzing current location: $current_path"
    
    # Try to extract agent and issue from current path
    if [[ "$current_path" =~ /worktrees/[^/]+/([^/]+)/([^/]+) ]]; then
        local agent_name="${BASH_REMATCH[1]}"
        local branch_part="${BASH_REMATCH[2]}"
        
        # Extract issue number
        local issue_number
        if [[ "$branch_part" =~ \#([0-9]+) ]] || [[ "$branch_part" =~ -([0-9]+)$ ]]; then
            issue_number="${BASH_REMATCH[1]}"
        elif [[ -f ".github-issue" ]]; then
            issue_number=$(cat ".github-issue")
        else
            echo "❌ Cannot determine issue number from current location"
            echo "   Path: $current_path"
            echo "   Expected pattern: /worktrees/.../agent/task-with-issue-number"
            return 1
        fi
        
        echo "✅ Detected: Agent '$agent_name', Issue #$issue_number"
        
        # Get status and file changes
        local status_info
        status_info=$(get_issue_status "$issue_number")
        
        local file_changes
        file_changes=$(get_file_changes "dev")
        
        # Update window
        update_iterm_title "$agent_name" "$issue_number" "$status_info" "$file_changes"
        
    else
        echo "❌ Current location doesn't appear to be an agent worktree"
        echo "   Path: $current_path"
        echo "   Expected pattern: /worktrees/.../agent/task-name"
        
        # Try manual title setting
        echo ""
        echo "🔧 Manual title setting available:"
        echo "   Usage: $0 --manual [agent] [issue_number]"
        return 1
    fi
}

# Function to start background status monitoring
start_monitoring() {
    local pid_file="/tmp/iterm-status-monitor.pid"
    
    if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
        echo "✅ Status monitoring already running (PID: $(cat "$pid_file"))"
        return
    fi
    
    echo "🚀 Starting background status monitoring..."
    
    (
        while true; do
            sleep 60  # Check every minute
            
            # Only update if we're in an agent worktree
            if [[ "$PWD" =~ /worktrees/ ]]; then
                "$0" --current 2>/dev/null || true
            fi
        done
    ) &
    
    local monitor_pid=$!
    echo "$monitor_pid" > "$pid_file"
    disown
    
    echo "✅ Background monitoring started (PID: $monitor_pid)"
    echo "   Use '$0 --stop' to stop monitoring"
}

# Function to stop background monitoring
stop_monitoring() {
    local pid_file="/tmp/iterm-status-monitor.pid"
    
    if [[ -f "$pid_file" ]]; then
        local pid
        pid=$(cat "$pid_file")
        if kill "$pid" 2>/dev/null; then
            echo "✅ Stopped background monitoring (PID: $pid)"
        else
            echo "⚠️  Background monitor process not found"
        fi
        rm -f "$pid_file"
    else
        echo "⚠️  No background monitoring found"
    fi
}

# Function to create GitHub labels for status tracking
create_status_labels() {
    echo "🏷️  Creating GitHub status labels..."
    
    local labels=(
        "status/active:28a745:Agent actively working on task"
        "status/waiting:ffc107:Agent waiting for instructions or review"
        "status/blocked:dc3545:Agent blocked by external dependencies" 
        "status/reviewing:6f42c1:Work completed, PR submitted for review"
        "status/complete:28a745:Task completed successfully"
    )
    
    for label_def in "${labels[@]}"; do
        IFS=':' read -r name color desc <<< "$label_def"
        if gh label create "$name" --color "$color" --description "$desc" 2>/dev/null; then
            echo "✅ Created label: $name"
        else
            echo "⚠️  Label exists or error: $name"
        fi
    done
    
    echo ""
    echo "✅ Status labels ready. Usage:"
    echo "   gh issue edit [number] --add-label 'status/active'"
    echo "   gh issue edit [number] --remove-label 'status/waiting' --add-label 'status/reviewing'"
}

# Main function
main() {
    case "${1:-}" in
        "--all")
            fix_all_windows
            ;;
        "--current")
            fix_current_window
            ;;
        "--manual")
            if [[ $# -lt 3 ]]; then
                echo "Usage: $0 --manual [agent_name] [issue_number]"
                exit 1
            fi
            local agent_name="$2"
            local issue_number="$3"
            local status_info
            status_info=$(get_issue_status "$issue_number")
            local file_changes
            file_changes=$(get_file_changes "dev")
            update_iterm_title "$agent_name" "$issue_number" "$status_info" "$file_changes"
            ;;
        "--monitor")
            start_monitoring
            ;;
        "--stop")
            stop_monitoring
            ;;
        "--labels")
            create_status_labels
            ;;
        "--help"|"-h"|"")
            echo "iTerm2 Window Title Fix Tool"
            echo ""
            echo "Usage:"
            echo "  $0 --current          Fix current window title"
            echo "  $0 --all              Fix all agent window titles"
            echo "  $0 --manual [agent] [issue#]  Manually set window title"  
            echo "  $0 --monitor          Start background status monitoring"
            echo "  $0 --stop             Stop background monitoring"
            echo "  $0 --labels           Create GitHub status labels"
            echo "  $0 --help             Show this help"
            echo ""
            echo "Examples:"
            echo "  $0 --current                    # Fix current window"
            echo "  $0 --manual devops 145          # Set window to 'devops #145'"
            echo "  $0 --monitor                    # Start background updates"
            echo ""
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
