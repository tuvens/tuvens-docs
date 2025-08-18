#!/bin/bash
# system-status.sh - Quick overview of all agent activity across the system

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACKING_DIR="$SCRIPT_DIR/../branch-tracking"

echo "🌐 Tuvens Multi-Agent Development System Status"
echo "=============================================="
echo "Generated: $(date)"
echo ""

# Check if branch tracking is initialized
if [ ! -f "$TRACKING_DIR/active-branches.json" ]; then
    echo "❌ Branch tracking system not initialized"
    echo "   Initialize with: /start-session [agent-name] [task] [description]"
    exit 1
fi

# Check for jq availability and provide fallback
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not available - using simplified system overview"
    echo ""
    
    # Simple grep-based analysis
    ACTIVE_BRANCHES_FILE="$TRACKING_DIR/active-branches.json"
    TOTAL_BRANCHES=$(grep -o '"name"' "$ACTIVE_BRANCHES_FILE" | wc -l | tr -d ' ')
    
    echo "📊 System Overview (Simplified):"
    echo "   Total active branches: $TOTAL_BRANCHES"
    
    if [ "$TOTAL_BRANCHES" -eq 0 ]; then
        echo "   ✅ No active development - all agents available"
    else
        echo "   ⚠️  Active development in progress"
        echo ""
        echo "   Agent distribution:"
        for agent in "vibe-coder" "svelte-dev" "node-dev" "laravel-dev" "react-dev" "mobile-dev" "devops"; do
            AGENT_COUNT=$(grep -A 20 -B 5 "\"agent\": \"$agent\"" "$ACTIVE_BRANCHES_FILE" | grep -c '"name"' 2>/dev/null || echo "0")
            AGENT_COUNT=$(echo "$AGENT_COUNT" | head -n1)  # Take only first line if multiple
            if [ "$AGENT_COUNT" -gt 0 ]; then
                echo "   - $agent: $AGENT_COUNT branches"
            fi
        done
    fi
    
    echo ""
    echo "💡 For detailed analysis, install jq:"
    echo "   macOS: brew install jq"
    echo "   Linux: sudo apt-get install jq"
    echo ""
    echo "🔗 Quick Commands:"
    echo "   Agent status:     bash agentic-development/scripts/agent-status.sh [agent-name]"
    echo "   Start session:    /start-session [agent-name] \"Task\" \"Description\""
    exit 0
fi

# Load data files
ACTIVE_BRANCHES_FILE="$TRACKING_DIR/active-branches.json"
TASK_GROUPS_FILE="$TRACKING_DIR/task-groups.json"
CLEANUP_QUEUE_FILE="$TRACKING_DIR/cleanup-queue.json"

# System overview
TOTAL_BRANCHES=$(jq -r '[.branches[] | length] | add' "$ACTIVE_BRANCHES_FILE" 2>/dev/null || echo "0")
LAST_UPDATED=$(jq -r '.lastUpdated' "$ACTIVE_BRANCHES_FILE" 2>/dev/null || echo "unknown")

echo "📊 System Overview:"
echo "   Total active branches: $TOTAL_BRANCHES"
echo "   Last updated: $LAST_UPDATED"
echo ""

if [ "$TOTAL_BRANCHES" -eq 0 ]; then
    echo "✅ No active development - all agents available for new work"
    echo ""
    exit 0
fi

# Repository breakdown
echo "📁 Repository Activity:"
jq -r '.branches | to_entries[] | "\(.key): \(.value | length) branches"' "$ACTIVE_BRANCHES_FILE" 2>/dev/null | while read repo_info; do
    echo "   $repo_info"
done
echo ""

# Agent workload distribution
echo "🤖 Agent Workload:"
AGENTS=("vibe-coder" "svelte-dev" "node-dev" "laravel-dev" "react-dev" "mobile-dev" "devops")

for agent in "${AGENTS[@]}"; do
    AGENT_WORK=$(jq -r --arg agent "$agent" '
        [.branches[] | .[] | select(.agent == $agent)] | length
    ' "$ACTIVE_BRANCHES_FILE" 2>/dev/null || echo "0")
    
    if [ "$AGENT_WORK" -gt 0 ]; then
        # Show workload level
        if [ "$AGENT_WORK" -eq 1 ]; then
            STATUS="✅ Light"
        elif [ "$AGENT_WORK" -le 2 ]; then
            STATUS="⚠️  Moderate"
        else
            STATUS="🚨 Heavy"
        fi
        
        echo "   $agent: $AGENT_WORK branches ($STATUS)"
    else
        echo "   $agent: 0 branches (✅ Available)"
    fi
done
echo ""

# Task group coordination
if [ -f "$TASK_GROUPS_FILE" ]; then
    ACTIVE_TASK_GROUPS=$(jq -r 'to_entries | map(select(.value.status == "in-progress")) | length' "$TASK_GROUPS_FILE" 2>/dev/null || echo "0")
    
    if [ "$ACTIVE_TASK_GROUPS" -gt 0 ]; then
        echo "🤝 Active Task Group Coordination:"
        jq -r 'to_entries[] | select(.value.status == "in-progress") | 
            "   🔗 \(.key): \(.value.title) (\(.value.branches | keys | length) repos)"' "$TASK_GROUPS_FILE" 2>/dev/null
        echo ""
    fi
fi

# Recent activity (last 7 days)
echo "📅 Recent Activity (Last 7 days):"
SEVEN_DAYS_AGO=$(date -v-7d '+%Y-%m-%d' 2>/dev/null || date -d '7 days ago' '+%Y-%m-%d' 2>/dev/null || echo "2020-01-01")

RECENT_BRANCHES=$(jq -r --arg date "$SEVEN_DAYS_AGO" '
    [.branches[] | .[] | select(.created >= $date)] | 
    sort_by(.created) | reverse |
    .[0:5][] |
    "   📝 \(.name) by \(.agent) (\(.created[0:10]))"
' "$ACTIVE_BRANCHES_FILE" 2>/dev/null)

if [ -n "$RECENT_BRANCHES" ]; then
    echo "$RECENT_BRANCHES"
else
    echo "   No recent branch activity"
fi
echo ""

# Cleanup opportunities
if [ -f "$CLEANUP_QUEUE_FILE" ]; then
    CLEANUP_COUNT=$(jq -r '.eligibleForCleanup? // [] | length' "$CLEANUP_QUEUE_FILE" 2>/dev/null || echo "0")
    
    if [ "$CLEANUP_COUNT" -gt 0 ]; then
        echo "🧹 Maintenance Needed:"
        echo "   $CLEANUP_COUNT merged branches ready for cleanup"
        echo "   💡 Run: bash agentic-development/scripts/cleanup-merged-branches.sh"
        echo ""
    fi
fi

# System health indicators
echo "🏥 System Health:"

# Check for stale branches (older than 30 days)
THIRTY_DAYS_AGO=$(date -v-30d '+%Y-%m-%d' 2>/dev/null || date -d '30 days ago' '+%Y-%m-%d' 2>/dev/null || echo "2020-01-01")
STALE_BRANCHES=$(jq -r --arg date "$THIRTY_DAYS_AGO" '
    [.branches[] | .[] | select(.created < $date)] | length
' "$ACTIVE_BRANCHES_FILE" 2>/dev/null || echo "0")

if [ "$STALE_BRANCHES" -gt 0 ]; then
    echo "   ⚠️  $STALE_BRANCHES potentially stale branches (>30 days old)"
else
    echo "   ✅ No stale branches detected"
fi

# Check for high agent workload
HIGH_WORKLOAD_AGENTS=$(jq -r '
    [.branches[] | .[] | .agent] | group_by(.) | 
    map(select(length > 2)) | length
' "$ACTIVE_BRANCHES_FILE" 2>/dev/null || echo "0")

if [ "$HIGH_WORKLOAD_AGENTS" -gt 0 ]; then
    echo "   ⚠️  $HIGH_WORKLOAD_AGENTS agents with high workload (>2 branches)"
else
    echo "   ✅ Balanced agent workload distribution"
fi

echo ""
echo "🔗 Quick Commands:"
echo "   Agent status:     bash agentic-development/scripts/agent-status.sh [agent-name]"
echo "   Start session:    /start-session [agent-name] \"Task\" \"Description\""
echo "   System cleanup:   bash agentic-development/scripts/cleanup-merged-branches.sh"
echo "   View branches:    cat agentic-development/branch-tracking/active-branches.json | jq"