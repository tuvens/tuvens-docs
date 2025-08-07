#!/bin/bash

# Vibe Coder Maintenance Check Script
# Validates agentic-development system integrity

set -e

echo "🔧 Vibe Coder System Maintenance Check"
echo "======================================="

# Count production files
echo "📊 File Counts:"
TOTAL_FILES=$(find /Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development -name "*.md" -o -name "*.sh" | grep -v ".temp" | wc -l | tr -d ' ')
DESKTOP_FILES=$(find /Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development/desktop-project-instructions -name "*.md" | wc -l | tr -d ' ')
CODE_FILES=$(find /Users/ciarancarroll/Code/Tuvens/tuvens-docs/.claude /Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development/workflows -name "*.md" | wc -l | tr -d ' ')
SCRIPT_FILES=$(find /Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development/scripts -name "*.sh" | wc -l | tr -d ' ')

echo "  Total production files: $TOTAL_FILES"
echo "  Desktop instruction files: $DESKTOP_FILES" 
echo "  Code context files: $CODE_FILES"
echo "  System scripts: $SCRIPT_FILES"

# Check for broken references
echo ""
echo "🔗 Reference Integrity:"

# Check if main Desktop README exists and is accessible
if [[ -f "/Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development/desktop-project-instructions/README.md" ]]; then
    echo "  ✅ Desktop README exists"
else
    echo "  ❌ Desktop README missing"
fi

# Check for orphaned files (files not referenced anywhere)
echo ""
echo "🔍 Orphaned File Check:"
ORPHANS=0

# Basic check for .md files that aren't referenced in main README
while IFS= read -r -d '' file; do
    filename=$(basename "$file")
    if ! grep -r "$filename" /Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development/desktop-project-instructions/README.md >/dev/null 2>&1 && 
       ! grep -r "$filename" /Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development/README.md >/dev/null 2>&1; then
        echo "  ⚠️  Potentially orphaned: $file"
        ((ORPHANS++))
    fi
done < <(find /Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development -name "*.md" -not -path "*/.temp/*" -print0)

if [[ $ORPHANS -eq 0 ]]; then
    echo "  ✅ No orphaned files detected"
fi

# Check .temp directory organization
echo ""
echo "📁 Archive Organization:"
TEMP_SUBDIRS=$(find /Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development/.temp -type d -maxdepth 1 | wc -l | tr -d ' ')
echo "  Temp subdirectories: $((TEMP_SUBDIRS - 1))"

# Environment validation
echo ""
echo "🌍 Environment Check:"
if [[ -f "/Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development/scripts/validate-environment.sh" ]]; then
    echo "  ✅ Environment validator exists"
    # Don't run it here to avoid side effects, just check it exists
else
    echo "  ❌ Environment validator missing"
fi

echo ""
echo "📋 Summary:"
echo "  Production files: $TOTAL_FILES"
echo "  Potentially orphaned: $ORPHANS"
echo "  Archive subdirectories: $((TEMP_SUBDIRS - 1))"

if [[ $ORPHANS -eq 0 ]]; then
    echo "  Status: ✅ System appears healthy"
else
    echo "  Status: ⚠️  Review orphaned files"
fi

echo ""
echo "💡 Next Steps:"
echo "  1. Update README.md if file counts changed"
echo "  2. Investigate any orphaned files"
echo "  3. Test /start-session command functionality"
echo "  4. Verify all load paths work correctly"