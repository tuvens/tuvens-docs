#!/usr/bin/env bash
# File: update
# Purpose: Claude Desktop /update command implementation
# 
# This script provides the /update functionality for adding updates and progress
# reports to GitHub issues and PRs. Supports context inference.

set -euo pipefail

# Usage function
usage() {
    echo "Usage: /update [PR|I]<number> [PR|I]<number>... [message]"
    echo ""
    echo "Claude Desktop /update command - Add updates to GitHub issues/PRs"
    echo ""
    echo "Arguments:"
    echo "  No args    - Infer from current branch/worktree context"
    echo "  PR324      - Update PR #324"
    echo "  I325       - Update Issue #325"
    echo "  PR324 I325 - Update both PR #324 and Issue #325"
    echo "  message    - Optional custom message (will prompt if not provided)"
    echo ""
    echo "Examples:"
    echo "  /update              # Infer from current context"
    echo "  /update PR324        # Update PR #324"
    echo "  /update I325         # Update Issue #325"
    echo "  /update PR324 I325   # Update both"
    echo "  /update PR324 'Status update: implementation complete'"
    echo ""
    exit 1
}

# Check for help flag
if [[ ${1:-} == "--help" || ${1:-} == "-h" ]]; then
    usage
fi

# Find the script directory relative to this file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTIC_SCRIPTS_DIR="$SCRIPT_DIR/agentic-development/scripts"

# Check if we have the shared functions
SHARED_FUNCTIONS="$AGENTIC_SCRIPTS_DIR/shared-functions.sh"

if [[ ! -f "$SHARED_FUNCTIONS" ]]; then
    echo "❌ ERROR: Shared functions not found: $SHARED_FUNCTIONS"
    echo "   Make sure you're running this from the tuvens-docs root directory"
    exit 1
fi

# Source shared functions
source "$SHARED_FUNCTIONS"

# Validate required tools
validate_required_tools
validate_git_repo

echo "📝 /update - GitHub Update Publisher"
echo "==================================="
echo ""

# Check if we have the update implementation script
UPDATE_SCRIPT="$AGENTIC_SCRIPTS_DIR/update-comments.sh"

if [[ ! -f "$UPDATE_SCRIPT" ]]; then
    echo "❌ ERROR: Update comments script not found: $UPDATE_SCRIPT"
    echo "   The /update command requires the update-comments.sh script"
    exit 1
fi

# Execute the update script with all arguments
"$UPDATE_SCRIPT" "$@"