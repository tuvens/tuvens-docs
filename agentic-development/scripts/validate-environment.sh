#!/usr/bin/env bash
# File: validate-environment.sh
# Purpose: Pre-flight validation for multi-agent development system

set -euo pipefail

echo "🔍 Multi-Agent Environment Validation"
echo "====================================="

# Git Repository Validation
echo "✅ Checking git repository status..."
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo "❌ ERROR: Not in a git repository"
    exit 1
fi
echo "   ✓ Git repository detected"

# Path Validation
echo "✅ Validating paths..."
EXPECTED_PATH="/Users/ciarancarroll/Code/Tuvens"
if [[ ! "$PWD" == *"$EXPECTED_PATH"* ]]; then
    echo "❌ ERROR: Not in expected path structure"
    echo "   Expected: $EXPECTED_PATH"
    echo "   Current:  $PWD"
    exit 1
fi
echo "   ✓ Path validation passed"

# Branch Status
echo "✅ Checking branch status..."
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo "   ✓ Current branch: $CURRENT_BRANCH"

# Worktree Directory
echo "✅ Checking worktree structure..."
# Following worktree organization strategy: [repo]/[agent]/[branch] pattern
REPO_BASE="/Users/ciarancarroll/Code/Tuvens"
if [[ ! -d "$REPO_BASE" ]]; then
    echo "❌ ERROR: Repository base directory missing"
    exit 1
fi
echo "   ✓ Worktree structure exists"

# GitHub CLI
echo "✅ Checking GitHub CLI..."
if ! command -v gh &> /dev/null; then
    echo "❌ ERROR: GitHub CLI not installed"
    exit 1
fi

# GitHub CLI Authentication
if ! gh auth status &>/dev/null; then
    echo "❌ ERROR: GitHub CLI not authenticated"
    echo "   Run: gh auth login"
    exit 1
fi
echo "   ✓ GitHub CLI available and authenticated"

# iTerm2 Check (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "✅ Checking iTerm2..."
    if ! osascript -e 'tell application "iTerm" to version' &>/dev/null; then
        echo "⚠️  WARNING: iTerm2 not available or not running"
    else
        echo "   ✓ iTerm2 available"
    fi
fi

echo ""
echo "🎉 Environment validation PASSED"
echo "Ready for multi-agent operations"