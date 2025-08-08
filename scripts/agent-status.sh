#!/bin/bash
# agent-status.sh - Quick agent workload and task recommendation tool

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACKING_DIR="$SCRIPT_DIR/../branch-tracking"

# Usage function
usage() {
    echo "Usage: $0 <agent-name> [repository]"
    echo ""
    echo "Examples:"
    echo "  $0 vibe-coder                    # Show vibe-coder status across all repos"
    echo "  $0 svelte-dev tuvens-client     # Show svelte-dev status in tuvens-client only"
    echo ""
    echo "Available agents: vibe-coder, svelte-dev, node-dev, laravel-dev, react-dev, mobile-dev, devops"
    exit 1
}

# Check arguments
if [[ $# -lt 1 ]]; then
    usage
fi

AGENT_NAME="$1"
SPECIFIC_REPO="${2:-}"
CURRENT_REPO=$(basename "$(pwd)" 2>/dev/null || echo "unknown")

echo "🤖 Agent Status: $AGENT_NAME"
echo "================================"
echo "Current Directory: $(pwd)"
echo "Repository Context: $CURRENT_REPO"
echo ""

# Check if branch tracking files exist
if [ ! -f "$TRACKING_DIR/active-branches.json" ]; then
    echo "❌ Branch tracking not initialized"
    echo "   Run setup-agent-task.sh first to initialize the system"
    exit 1
fi

# Check for jq availability and provide fallback
if ! command -v jq &> /dev/null; then
    echo "⚠️  jq not available - using simplified analysis"
    echo ""
    
    # Simple grep-based analysis
    TOTAL_BRANCHES=$(grep -o '"name"' "$TRACKING_DIR/active-branches.json" | wc -l | tr -d ' ')
    AGENT_BRANCHES=$(grep -A 20 -B 5 "\"agent\": \"$AGENT_NAME\"" "$TRACKING_DIR/active-branches.json" | grep -c '"name"' || echo "0")
    
    echo "📊 System Overview (Simplified):"
    echo "   Total active branches: $TOTAL_BRANCHES"
    echo ""
    echo "👤 $AGENT_NAME Workload:"
    echo "   Active branches: $AGENT_BRANCHES"
    
    if [ "$AGENT_BRANCHES" -gt 0 ]; then
        echo ""
        echo "   💡 For detailed analysis, install jq: brew install jq (macOS) or apt-get install jq (Ubuntu)"
    fi
    echo ""
    echo "🔗 Quick Commands:"
    echo "   Install jq:       brew install jq"
    echo "   Start session:    /start-session $AGENT_NAME \"Task Title\" \"Description\""
    exit 0
fi

# Load active branches data
ACTIVE_BRANCHES_FILE="$TRACKING_DIR/active-branches.json"

# Show overall system activity
TOTAL_BRANCHES=$(jq -r '[.branches[] | length] | add' "$ACTIVE_BRANCHES_FILE" 2>/dev/null || echo "0")
echo "📊 System Overview:"
echo "   Total active branches: $TOTAL_BRANCHES"

if [ "$TOTAL_BRANCHES" -eq 0 ]; then
    echo "   ✅ No active development - good time to start new work"
    echo ""
    exit 0
fi

# Show agent-specific workload
echo ""
echo "👤 $AGENT_NAME Workload Analysis:"

if [ -n "$SPECIFIC_REPO" ]; then
    # Single repository analysis
    AGENT_BRANCHES=$(jq -r --arg agent "$AGENT_NAME" --arg repo "$SPECIFIC_REPO" '
        .branches[$repo]? // [] | 
        map(select(.agent == $agent)) | 
        length
    ' "$ACTIVE_BRANCHES_FILE" 2>/dev/null || echo "0")
    
    echo "   Repository: $SPECIFIC_REPO"
    echo "   Active branches: $AGENT_BRANCHES"
    
    if [ "$AGENT_BRANCHES" -gt 0 ]; then
        echo ""
        echo "   Current work:"
        jq -r --arg agent "$AGENT_NAME" --arg repo "$SPECIFIC_REPO" '
            .branches[$repo]? // [] | 
            map(select(.agent == $agent)) |
            .[] | "   📝 \(.name)"
        ' "$ACTIVE_BRANCHES_FILE" 2>/dev/null
    fi
else
    # Cross-repository analysis
    TOTAL_AGENT_WORK=$(jq -r --arg agent "$AGENT_NAME" '
        [.branches[] | .[] | select(.agent == $agent)] | length
    ' "$ACTIVE_BRANCHES_FILE" 2>/dev/null || echo "0")
    
    echo "   Total active branches: $TOTAL_AGENT_WORK"
    
    if [ "$TOTAL_AGENT_WORK" -gt 0 ]; then
        echo ""
        echo "   Work distribution:"
        jq -r --arg agent "$AGENT_NAME" '
            .branches | to_entries[] | 
            select(.value | map(select(.agent == $agent)) | length > 0) |
            "\(.key): \(.value | map(select(.agent == $agent)) | length) branches"
        ' "$ACTIVE_BRANCHES_FILE" 2>/dev/null | sed 's/^/   📁 /'
        
        echo ""
        echo "   Recent branches:"
        jq -r --arg agent "$AGENT_NAME" '
            [.branches[] | .[] | select(.agent == $agent)] |
            sort_by(.created) | reverse |
            .[0:3][] |
            "   📝 \(.name) (\(.created[0:10]))"
        ' "$ACTIVE_BRANCHES_FILE" 2>/dev/null
    fi
fi

echo ""

# Task group coordination status
if [ -f "$TRACKING_DIR/task-groups.json" ]; then
    ACTIVE_TASK_GROUPS=$(jq -r --arg agent "$AGENT_NAME" '
        to_entries[] | 
        select(.value.agents[$agent] != null and .value.status == "in-progress") |
        "\(.key): \(.value.title)"
    ' "$TRACKING_DIR/task-groups.json" 2>/dev/null)
    
    if [ -n "$ACTIVE_TASK_GROUPS" ]; then
        echo "🤝 Active Task Group Coordination:"
        echo "$ACTIVE_TASK_GROUPS" | sed 's/^/   🔗 /'
        echo ""
    fi
fi

# Recommendations based on current workload
echo "💡 Recommendations:"

if [ "$TOTAL_AGENT_WORK" -eq 0 ]; then
    echo "   ✅ No active work - good time to start a new task"
    echo "   💡 Consider checking task-groups.json for coordination opportunities"
elif [ "$TOTAL_AGENT_WORK" -eq 1 ]; then
    echo "   ✅ Light workload - capacity for additional work"
    echo "   💡 Consider coordinating with existing task groups"
elif [ "$TOTAL_AGENT_WORK" -le 3 ]; then
    echo "   ⚠️  Moderate workload - consider completing existing work first"
    echo "   💡 Focus on finishing current branches before starting new work"
else
    echo "   🚨 Heavy workload - strongly consider completing existing work"
    echo "   💡 Use cleanup-merged-branches.sh to clean up completed work"
fi

# Show cleanup opportunities
if [ -f "$TRACKING_DIR/cleanup-queue.json" ]; then
    CLEANUP_COUNT=$(jq -r '.eligibleForCleanup? // [] | length' "$TRACKING_DIR/cleanup-queue.json" 2>/dev/null || echo "0")
    if [ "$CLEANUP_COUNT" -gt 0 ]; then
        echo ""
        echo "🧹 Cleanup Opportunity:"
        echo "   $CLEANUP_COUNT merged branches ready for cleanup"
        echo "   💡 Run: bash agentic-development/scripts/cleanup-merged-branches.sh"
    fi
fi

echo ""
echo "🔗 Quick Commands:"
echo "   Start new session:  /start-session $AGENT_NAME \"Task Title\" \"Description\""
echo "   Check all agents:   bash agentic-development/scripts/agent-status.sh"
echo "   System cleanup:     bash agentic-development/scripts/cleanup-merged-branches.sh"