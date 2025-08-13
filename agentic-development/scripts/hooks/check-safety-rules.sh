#!/bin/bash

# Pre-commit Hook: Safety Rules Check
# Validates commits don't violate basic CLAUDE.md safety rules

set -e

# Check for common safety violations in staged files
VIOLATIONS=()

# Check for potential secrets in staged files
STAGED_FILES=$(git diff --cached --name-only)
if [ -n "$STAGED_FILES" ]; then
    if echo "$STAGED_FILES" | xargs grep -l -i -E "(password|secret|token|key|api_key)" 2>/dev/null; then
        SECRET_FILES=$(echo "$STAGED_FILES" | xargs grep -l -i -E "(password|secret|token|key|api_key)" 2>/dev/null)
        VIOLATIONS+=("Potential secrets detected in: $SECRET_FILES")
    fi
fi

# Check for --no-verify usage in commit messages or files
if git diff --cached | grep -q "\-\-no\-verify"; then
    VIOLATIONS+=("Contains --no-verify flag (violates CLAUDE.md safety rules)")
fi

# Check for direct deletion of important files
IMPORTANT_FILES=("CLAUDE.md" "README.md" "package.json" ".gitignore")
for file in "${IMPORTANT_FILES[@]}"; do
    if git diff --cached --name-status | grep -q "^D.*$file$"; then
        VIOLATIONS+=("Attempting to delete important file: $file")
    fi
done

# Check for modifications to .github/workflows without proper review markers
if git diff --cached --name-only | grep -q "\.github/workflows/"; then
    WORKFLOW_FILES=$(git diff --cached --name-only | grep "\.github/workflows/" || true)
    if [ -n "$WORKFLOW_FILES" ]; then
        # Check if commit message indicates this is a reviewed change
        COMMIT_MSG_FILE=$(git rev-parse --git-dir)/COMMIT_EDITMSG
        if [ -f "$COMMIT_MSG_FILE" ]; then
            if ! grep -q -i -E "(reviewed|approved|tested)" "$COMMIT_MSG_FILE"; then
                VIOLATIONS+=("Workflow changes detected without review markers in commit message")
            fi
        fi
    fi
fi

# Report violations
if [ ${#VIOLATIONS[@]} -gt 0 ]; then
    echo "❌ SAFETY RULE VIOLATIONS DETECTED"
    echo ""
    echo "The following safety violations were found:"
    for violation in "${VIOLATIONS[@]}"; do
        echo "  🚨 $violation"
    done
    echo ""
    echo "🛡️  CLAUDE.md Safety Rules require:"
    echo "  • No sensitive information in commits"
    echo "  • No bypassing of safety checks (--no-verify)"
    echo "  • Explicit approval for workflow changes"
    echo "  • Protection of critical repository files"
    echo ""
    echo "To fix:"
    echo "  • Remove sensitive data from staged files"
    echo "  • Add proper review documentation for workflow changes"
    echo "  • Use git-secret or environment variables for sensitive data"
    echo ""
    echo "📖 See: CLAUDE.md > Core Safety Principles"
    echo ""
    exit 1
fi

echo "✅ Safety rules validation passed"
exit 0