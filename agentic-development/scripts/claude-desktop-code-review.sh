#!/usr/bin/env bash
# File: code-review
# Purpose: Claude Desktop /code-review command implementation
# 
# This script provides the /code-review functionality for Claude Desktop
# using iTerm2 MCP integration and the QA agent specialization

set -euo pipefail

# Usage function
usage() {
    echo "Usage: /code-review <agent> <#PR> [#issue] [--context=file]"
    echo ""
    echo "Claude Desktop /code-review command"
    echo "Comprehensive code review with QA agent specialization"
    echo ""
    echo "Arguments:"
    echo "  <agent>   - Target agent for the review (qa, vibe-coder, etc.)"
    echo "  <#PR>     - Pull request number (e.g., #123 or 123)"
    echo "  [#issue]  - Optional associated issue number for requirements context"
    echo ""
    echo "Options:"
    echo "  --context=file  - Additional context file for complex reviews"
    echo "  --help, -h      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  /code-review qa 123                    # Review PR #123 with QA agent"
    echo "  /code-review qa #145 #144             # Review PR #145 related to issue #144"
    echo "  /code-review vibe-coder 99 --context=/tmp/review-notes.md"
    echo ""
    echo "Features:"
    echo "  • Requirements review from associated issue"
    echo "  • Comprehensive PR analysis including all comments"
    echo "  • Technical review following DRY, KISS, TDD, D/E, R/R, C/C principles"
    echo "  • File/folder structure validation (R/R - Recognition-over-Recall)"
    echo "  • Framework convention compliance checking (C/C - Convention-over-Configuration)"
    echo "  • Test validation and coverage analysis"
    echo "  • Automated response to all review participants"
    echo "  • Comment management for long reviews"
    echo ""
    exit 1
}

# Check minimum arguments
if [[ $# -lt 2 ]]; then
    usage
fi

# Parse help option early
for arg in "$@"; do
    if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
        usage
    fi
done

# Find the script directory relative to this file
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
AGENTIC_SCRIPTS_DIR="$SCRIPT_DIR/agentic-development/scripts"

# Check if we have the code review script
CODE_REVIEW_SCRIPT="$AGENTIC_SCRIPTS_DIR/setup-code-review-desktop.sh"

if [[ ! -f "$CODE_REVIEW_SCRIPT" ]]; then
    echo "❌ ERROR: Code review script not found: $CODE_REVIEW_SCRIPT"
    echo "   Make sure you're running this from the tuvens-docs root directory"
    exit 1
fi

echo "🔍 /code-review for Claude Desktop"
echo "=================================="
echo ""

# Execute the code review adapter with all arguments
"$CODE_REVIEW_SCRIPT" "$@"