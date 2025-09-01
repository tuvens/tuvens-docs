#!/usr/bin/env bash
# File: check
# Purpose: Claude Desktop /check command implementation
# 
# This script provides the /check functionality for checking comment status
# on GitHub issues and PRs without responding. Supports context inference.

set -euo pipefail

# Usage function
usage() {
    echo "Usage: /check [PR|I]<number> [PR|I]<number>..."
    echo ""
    echo "Claude Desktop /check command - Check comment status on GitHub issues/PRs"
    echo ""
    echo "Arguments:"
    echo "  No args    - Infer from current branch/worktree context"
    echo "  PR324      - Check PR #324"
    echo "  I325       - Check Issue #325"
    echo "  PR324 I325 - Check both PR #324 and Issue #325"
    echo ""
    echo "Examples:"
    echo "  /check              # Infer from current context"
    echo "  /check PR324        # Check PR #324"
    echo "  /check I325         # Check Issue #325"
    echo "  /check PR324 I325   # Check both"
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

echo "🔍 /check - GitHub Comment Status Checker"
echo "========================================="
echo ""

# Check if we have the check implementation script
CHECK_SCRIPT="$AGENTIC_SCRIPTS_DIR/check-comments.sh"

if [[ ! -f "$CHECK_SCRIPT" ]]; then
    echo "❌ ERROR: Check comments script not found: $CHECK_SCRIPT"
    echo "   The /check command requires the check-comments.sh script"
    exit 1
fi

# Execute the check script with all arguments
"$CHECK_SCRIPT" "$@"