#!/usr/bin/env bash
# File: enhanced-window-management.sh
# Purpose: Enhanced iTerm2 window management with GitHub status integration
# 
# This script provides enhanced window titles, status tracking, and GitHub
# label management for better visibility in multi-agent development workflows.

set -euo pipefail

# Enhanced window management functions
source "$(dirname "${BASH_SOURCE[0]}")/shared-functions.sh"

# Agent emoji mapping for visual identification
get_agent_emoji() {
    local agent_name="$1"
    case "$agent_name" in
        "vibe-coder") echo "🎨" ;;
        "react-dev") echo "⚛️" ;;
        "laravel-dev") echo "🐘" ;;
        "svelte-dev") echo "🔥" ;;
        "node-dev") echo "🟢" ;;
        "devops") echo "🔧" ;;
        "qa") echo "✅" ;;
        "codehooks-dev") echo "🪝" ;;
        *) echo "🤖" ;;
    esac
}

# Status emoji mapping
get_status_emoji() {
    local status="$1"
    case "$status" in
        "ACTIVE") echo "🟢" ;;
        "WAITING") echo "🟡" ;;
        "BLOCKED") echo "🔴" ;;
        "REVIEW") echo "🟣" ;;
        "MERGED") echo "✅" ;;
        *) echo "⚪" ;;
    esac
}

# Detect agent status based on GitHub context
detect_agent_status() {
    local issue_num="$1"
    local pr_num="$2"
    local current_user
    
    # Get current GitHub user
    current_user=$(gh auth status 2>/dev/null | grep "Logged in" | awk '{print $NF}' | tr -d '()' || echo "unknown")
    
    # Check last comment author on issue
    local last_comment_author
    last_comment_author=$(gh issue view "$issue_num" --json comments \
        --jq '.comments[-1].author.login // empty' 2>/dev/null || echo "")
    
    # If PR exists, check its status
    if [[ -n "$pr_num" ]] && gh pr view "$pr_num" >/dev/null 2>&1; then
        local pr_status
        pr_status=$(gh pr view "$pr_num" --json state,reviewDecision,mergeable \
            --jq '{state: .state, decision: .reviewDecision, mergeable: .mergeable}' 2>/dev/null || echo '{}')
        
        local pr_state decision mergeable
        pr_state=$(echo "$pr_status" | jq -r '.state // "UNKNOWN"')
        decision=$(echo "$pr_status" | jq -r '.reviewDecision // "null"')
        mergeable=$(echo "$pr_status" | jq -r '.mergeable // "null"')
        
        # Determine status based on PR state
        case "$pr_state" in
            "MERGED")
                echo "MERGED"
                return
                ;;
            "CLOSED")
                echo "CLOSED"
                return
                ;;
            "OPEN")
                case "$decision" in
                    "CHANGES_REQUESTED")
                        echo "BLOCKED"
                        return
                        ;;
                    "APPROVED")
                        if [[ "$mergeable" == "MERGEABLE" ]]; then
                            echo "READY"
                        else
                            echo "BLOCKED"
                        fi
                        return
                        ;;
                    *)
                        echo "REVIEW"
                        return
                        ;;
                esac
                ;;
        esac
    fi
    
    # Fall back to comment analysis
    if [[ -n "$last_comment_author" && "$last_comment_author" != "$current_user" ]]; then
        echo "WAITING"  # Someone else commented, agent should respond
    else
        echo "ACTIVE"   # Agent was last to comment or no comments
    fi
}

# Generate enhanced window title
generate_window_title() {
    local agent_name="$1"
    local issue_num="$2"
    local task_title="$3"
    local pr_num="${4:-}"
    
    local agent_emoji status status_emoji task_summary
    agent_emoji=$(get_agent_emoji "$agent_name")
    status=$(detect_agent_status "$issue_num" "$pr_num")
    status_emoji=$(get_status_emoji "$status")
    
    # Create concise task summary (max 20 chars)
    task_summary=$(echo "$task_title" | tr '[:upper:]' '[:lower:]' | \
        sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-\|-$//g' | cut -c1-20)
    
    # Build title components
    local title="$agent_emoji $agent_name #$issue_num"
    
    if [[ -n "$pr_num" ]]; then
        title="$title→PR$pr_num"
    fi
    
    title="$title [$status_emoji$status] $task_summary"
    
    echo "$title"
}

# Set up GitHub labels for status tracking
setup_github_labels() {
    local issue_num="$1"
    local agent_name="$2"
    local status="$3"
    
    # Define status label mapping
    local status_label
    case "$status" in
        "ACTIVE") status_label="agent-active" ;;
        "WAITING") status_label="agent-waiting" ;;
        "BLOCKED") status_label="agent-blocked" ;;
        "REVIEW") status_label="review-ready" ;;
        "READY") status_label="merge-ready" ;;
        "MERGED") status_label="completed" ;;
        *) status_label="agent-active" ;;
    esac
    
    # Remove old status labels and add new ones
    gh issue edit "$issue_num" --remove-label "agent-active,agent-waiting,agent-blocked,review-ready,merge-ready" 2>/dev/null || true
    gh issue edit "$issue_num" --add-label "$status_label,agent-$agent_name" 2>/dev/null || true
    
    echo "✅ Updated GitHub labels: $status_label, agent-$agent_name"
}

# Create status monitoring script for iTerm2
create_status_monitor() {
    local issue_num="$1"
    local pr_num="$2"
    local worktree_path="$3"
    
    local status_script="$worktree_path/.iterm2_status.sh"
    
    cat > "$status_script" << 'EOF'
#!/bin/bash
# iTerm2 status monitoring script

ISSUE_NUM="$1"
PR_NUM="$2"

# Get current status
if [[ -n "$PR_NUM" ]] && gh pr view "$PR_NUM" >/dev/null 2>&1; then
    PR_INFO=$(gh pr view "$PR_NUM" --json state,reviewDecision,comments \
        --jq '{state: .state, decision: .reviewDecision, comments: .comments | length}')
    
    STATE=$(echo "$PR_INFO" | jq -r '.state')
    DECISION=$(echo "$PR_INFO" | jq -r '.decision // "PENDING"')
    COMMENT_COUNT=$(echo "$PR_INFO" | jq -r '.comments')
    
    echo "🔄 $STATE | 📝 $DECISION | 💬 $COMMENT_COUNT comments | Issue: #$ISSUE_NUM | PR: #$PR_NUM"
else
    COMMENT_COUNT=$(gh issue view "$ISSUE_NUM" --json comments --jq '.comments | length' 2>/dev/null || echo "0")
    echo "📝 In Progress | 💬 $COMMENT_COUNT comments | Issue: #$ISSUE_NUM"
fi
EOF
    
    chmod +x "$status_script"
    echo "$status_script"
}

# Enhanced AppleScript for iTerm2 with dynamic titles and status
create_enhanced_iterm_window() {
    local agent_name="$1"
    local issue_num="$2"
    local task_title="$3" 
    local worktree_path="$4"
    local prompt_file="$5"
    local pr_num="${6:-}"
    local claude_command="${7:-claude}"
    
    local window_title status_script
    window_title=$(generate_window_title "$agent_name" "$issue_num" "$task_title" "$pr_num")
    status_script=$(create_status_monitor "$issue_num" "$pr_num" "$worktree_path")
    
    echo "🪟 Creating enhanced iTerm2 window: $window_title"
    
    # Create enhanced AppleScript
    local applescript_content="
tell application \"iTerm\"
    create window with default profile
    tell current session of current window
        set name to \"$window_title\"
        write text \"cd \\\"$worktree_path\\\"\"
        write text \"echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'\"
        write text \"echo '🎭 Agent Status Dashboard'\"
        write text \"\\\"$status_script\\\" \\\"$issue_num\\\" \\\"$pr_num\\\"\"
        write text \"echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'\"
        write text \"echo ''\"
        write text \"cat \\\"$prompt_file\\\"\"
        write text \"$claude_command\"
    end tell
end tell"
    
    echo "$applescript_content" | osascript
    echo "✅ Created enhanced iTerm2 window with live status"
}

# Update window title for existing iTerm2 window
update_window_title() {
    local agent_name="$1"
    local issue_num="$2"
    local task_title="$3"
    local pr_num="${4:-}"
    
    local new_title
    new_title=$(generate_window_title "$agent_name" "$issue_num" "$task_title" "$pr_num")
    
    # Find and update the window
    osascript -e "
tell application \"iTerm\"
    repeat with w in windows
        repeat with t in tabs of w
            repeat with s in sessions of t
                if name of s contains \"#$issue_num\" then
                    set name of s to \"$new_title\"
                    return
                end if
            end repeat
        end repeat
    end repeat
end tell"
    
    echo "🔄 Updated window title: $new_title"