#!/bin/bash

# Cleanup Merged Branches and Worktrees
# Based on central branch tracking system

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACKING_DIR="$SCRIPT_DIR/../branch-tracking"
CLEANUP_QUEUE="$TRACKING_DIR/cleanup-queue.json"
TUVENS_ROOT="${TUVENS_ROOT:-$HOME/Code/Tuvens}"

echo "🧹 Tuvens Branch and Worktree Cleanup"
echo "======================================="
echo "Tuvens Root: $TUVENS_ROOT"
echo "Tracking Directory: $TRACKING_DIR"
echo ""

# Check if cleanup queue exists
if [ ! -f "$CLEANUP_QUEUE" ]; then
    echo "❌ Cleanup queue not found: $CLEANUP_QUEUE"
    echo "Run this script from the tuvens-docs repository root"
    exit 1
fi

# Check if cleanup queue is empty
CLEANUP_COUNT=$(jq 'length' "$CLEANUP_QUEUE" 2>/dev/null || echo "0")
if [ "$CLEANUP_COUNT" -eq 0 ]; then
    echo "✅ No branches in cleanup queue"
    exit 0
fi

echo "📋 Found $CLEANUP_COUNT branches eligible for cleanup:"
echo ""

# Display branches eligible for cleanup
jq -r '.[] | "  \(.repository):\(.branch) (merged \(.mergedAt[0:10]))"' "$CLEANUP_QUEUE"
echo ""

# Ask for confirmation
read -p "❓ Proceed with cleanup? This will delete worktrees and remote branches. (y/N): " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cleanup cancelled"
    exit 0
fi

echo ""
echo "🗑️  Starting cleanup process..."
echo ""

# Track cleanup results
SUCCESSFUL_CLEANUPS=0
FAILED_CLEANUPS=0
CLEANUP_LOG=$(mktemp)

# Process each branch in cleanup queue
jq -c '.[]' "$CLEANUP_QUEUE" | while read -r branch_data; do
    repo=$(echo "$branch_data" | jq -r '.repository')
    branch=$(echo "$branch_data" | jq -r '.branch')
    worktree_path=$(echo "$branch_data" | jq -r '.worktreePath')
    merged_at=$(echo "$branch_data" | jq -r '.mergedAt')
    
    echo "🔧 Processing: $repo/$branch"
    
    # Resolve worktree path (handle ~ expansion)
    resolved_worktree="${worktree_path/#\~/$HOME}"
    
    # Navigate to repository
    repo_path="$TUVENS_ROOT/$repo"
    if [ ! -d "$repo_path" ]; then
        echo "  ⚠️  Repository not found: $repo_path"
        echo "ERROR: $repo - repository not found" >> "$CLEANUP_LOG"
        continue
    fi
    
    cd "$repo_path" || {
        echo "  ❌ Cannot access repository: $repo_path"
        echo "ERROR: $repo - cannot access repository" >> "$CLEANUP_LOG"
        continue
    }
    
    # Remove worktree if it exists
    if [ -d "$resolved_worktree" ]; then
        echo "  🗑️  Removing worktree: $resolved_worktree"
        if git worktree remove "$resolved_worktree" --force 2>/dev/null; then
            echo "  ✅ Worktree removed successfully"
        else
            echo "  ⚠️  Failed to remove worktree, trying manual cleanup..."
            rm -rf "$resolved_worktree" 2>/dev/null || {
                echo "  ❌ Manual worktree cleanup failed"
                echo "ERROR: $repo/$branch - worktree cleanup failed" >> "$CLEANUP_LOG"
            }
        fi
    else
        echo "  ℹ️  Worktree not found: $resolved_worktree"
    fi
    
    # Check if branch exists locally
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        echo "  🗑️  Deleting local branch: $branch"
        if git branch -D "$branch" 2>/dev/null; then
            echo "  ✅ Local branch deleted"
        else
            echo "  ⚠️  Failed to delete local branch"
            echo "WARNING: $repo/$branch - local branch deletion failed" >> "$CLEANUP_LOG"
        fi
    else
        echo "  ℹ️  Local branch not found: $branch"
    fi
    
    # Delete remote branch (if it still exists)
    echo "  🗑️  Checking remote branch: origin/$branch"
    if git ls-remote --heads origin "$branch" | grep -q "$branch"; then
        if git push origin --delete "$branch" 2>/dev/null; then
            echo "  ✅ Remote branch deleted"
        else
            echo "  ⚠️  Failed to delete remote branch (may already be deleted)"
            echo "WARNING: $repo/$branch - remote branch deletion failed" >> "$CLEANUP_LOG"
        fi
    else
        echo "  ℹ️  Remote branch not found: origin/$branch"
    fi
    
    echo "  ✅ Cleanup completed for $repo/$branch"
    echo ""
    
    # Increment success counter
    SUCCESSFUL_CLEANUPS=$((SUCCESSFUL_CLEANUPS + 1))
done

# Return to original directory
cd "$SCRIPT_DIR" || exit 1

echo ""
echo "🧹 Cleanup Summary:"
echo "==================="

# Count results
if [ -f "$CLEANUP_LOG" ] && [ -s "$CLEANUP_LOG" ]; then
    ERROR_COUNT=$(grep -c "ERROR:" "$CLEANUP_LOG" || echo "0")
    WARNING_COUNT=$(grep -c "WARNING:" "$CLEANUP_LOG" || echo "0")
    
    echo "✅ Successfully processed: $CLEANUP_COUNT branches"
    
    if [ "$ERROR_COUNT" -gt 0 ]; then
        echo "❌ Errors encountered: $ERROR_COUNT"
        echo ""
        echo "Errors:"
        grep "ERROR:" "$CLEANUP_LOG" | sed 's/ERROR: /  - /'
    fi
    
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo "⚠️  Warnings: $WARNING_COUNT"
        echo ""
        echo "Warnings:"
        grep "WARNING:" "$CLEANUP_LOG" | sed 's/WARNING: /  - /'
    fi
else
    echo "✅ All branches processed successfully"
fi

# Clear the cleanup queue
echo "[]" > "$CLEANUP_QUEUE"
echo ""
echo "🗑️  Cleanup queue cleared"

# Update tracking summary
cat > "$TRACKING_DIR/last-cleanup.md" << EOF
# Last Cleanup Run
**Date**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Branches Processed**: $CLEANUP_COUNT
**Successful**: $CLEANUP_COUNT
**Errors**: ${ERROR_COUNT:-0}
**Warnings**: ${WARNING_COUNT:-0}

## Cleaned Up Branches
$(jq -r '.[] | "- \(.repository):\(.branch) (merged \(.mergedAt[0:10]))"' "$CLEANUP_QUEUE" 2>/dev/null || echo "Queue already cleared")

## Next Steps
- Cleanup queue has been cleared
- All eligible worktrees and branches removed  
- Run this script again when more branches are merged
- Check central branch tracking for current active branches
EOF

# Cleanup temporary files
rm -f "$CLEANUP_LOG"

echo ""
echo "✅ Branch and worktree cleanup completed!"
echo ""
echo "💡 Tips:"
echo "   - Check active branches: cat $TRACKING_DIR/active-branches.json"
echo "   - View cleanup history: cat $TRACKING_DIR/last-cleanup.md"
echo "   - This script runs automatically when branches are merged"
echo ""