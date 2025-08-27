#!/bin/bash

# Pre-commit Hook: Protected Branch Check
# Prevents direct commits to main, stage, and test branches

set -e

# Get current branch name
BRANCH_NAME=$(git symbolic-ref --short HEAD 2>/dev/null || echo "HEAD")

# Protected branches
PROTECTED_BRANCHES=("main" "stage" "test")

# Check if current branch is protected
for protected in "${PROTECTED_BRANCHES[@]}"; do
    if [ "$BRANCH_NAME" = "$protected" ]; then
        echo "❌ PROTECTED BRANCH VIOLATION"
        echo ""
        echo "Cannot commit directly to protected branch: $BRANCH_NAME"
        echo ""
        echo "🛡️  Tuvens 5-Branch Strategy:"
        echo "   main ← stage ← test ← dev ← feature/*"
        echo ""
        echo "✅ Allowed workflow:"
        echo "  1. Create feature branch from 'dev'"
        echo "  2. Make changes in feature branch"
        echo "  3. Submit Pull Request targeting 'dev'"
        echo "  4. Merge through proper review process"
        echo ""
        echo "🚨 Emergency hotfixes:"
        echo "  • Use hotfix branches targeting 'stage'"
        echo "  • Format: {agent}/hotfix/{issue-description}"
        echo ""
        echo "📖 See: CLAUDE.md > Git Safety and Branch Protection"
        echo ""
        echo "To fix this:"
        echo "  git checkout dev"
        echo "  git checkout -b {agent-name}/{task-type}/{description}"
        echo "  # Make your changes and commit"
        echo ""
        exit 1
    fi
done

echo "✅ Protected branch validation passed"
exit 0