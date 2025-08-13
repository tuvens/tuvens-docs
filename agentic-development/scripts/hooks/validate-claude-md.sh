#!/bin/bash

# Pre-commit Hook: CLAUDE.md Validation
# Validates CLAUDE.md file exists and contains required sections

set -e

# Check if CLAUDE.md exists
if [ ! -f "CLAUDE.md" ]; then
    echo "❌ CLAUDE.md MISSING"
    echo ""
    echo "The CLAUDE.md file is required for repository safety."
    echo ""
    echo "This file should contain:"
    echo "  • Critical Claude Code Safety Rules"
    echo "  • Mandatory Branch Naming Conventions"  
    echo "  • Pull Request Target Branch Rules"
    echo "  • Emergency Branch Recovery Procedures"
    echo "  • Testing Protocol Requirements"
    echo "  • Repository-Specific Safety Rules"
    echo ""
    echo "📖 See existing CLAUDE.md in other repositories for examples"
    echo ""
    exit 1
fi

# Required sections in CLAUDE.md
REQUIRED_SECTIONS=(
    "Critical Claude Code Safety Rules"
    "Mandatory Branch Naming Conventions"
    "Pull Request Target Branch Rules" 
    "Emergency Branch Recovery Procedures"
    "Testing Protocol Requirements"
    "Repository-Specific Safety Rules"
)

# Check for required sections
MISSING_SECTIONS=()
for section in "${REQUIRED_SECTIONS[@]}"; do
    if ! grep -q "$section" CLAUDE.md; then
        MISSING_SECTIONS+=("$section")
    fi
done

if [ ${#MISSING_SECTIONS[@]} -gt 0 ]; then
    echo "❌ CLAUDE.md INCOMPLETE"
    echo ""
    echo "CLAUDE.md is missing required sections:"
    for missing in "${MISSING_SECTIONS[@]}"; do
        echo "  • $missing"
    done
    echo ""
    echo "🛡️  These sections are critical for agent safety and coordination."
    echo ""
    echo "Please add the missing sections to ensure comprehensive safety coverage."
    echo ""
    exit 1
fi

# Check for 5-branch strategy documentation
if ! grep -q "main.*stage.*test.*dev.*feature" CLAUDE.md; then
    echo "⚠️  CLAUDE.md WARNING"
    echo ""
    echo "CLAUDE.md should document the 5-branch strategy:"
    echo "   main ← stage ← test ← dev ← feature/*"
    echo ""
    echo "This helps agents understand proper branch targeting."
    echo ""
    # Don't fail for this, just warn
fi

echo "✅ CLAUDE.md validation passed"
exit 0