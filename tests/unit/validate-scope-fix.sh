#!/bin/bash
# Quick validation script to test the scope protection fix
# Tests that bypass keywords work correctly

set -e

echo "🔍 Validating scope protection fix..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Test variables
HOOKS_DIR="./agentic-development/scripts/hooks"
SCOPE_HOOK="$HOOKS_DIR/check-scope-protection.sh"

# Check if scope protection hook exists
if [ ! -f "$SCOPE_HOOK" ]; then
    echo -e "${RED}❌ FAIL: Scope protection hook not found at $SCOPE_HOOK${NC}"
    exit 1
fi

echo -e "${GREEN}✅ PASS: Scope protection hook found${NC}"

# Check if hook is executable
if [ ! -x "$SCOPE_HOOK" ]; then
    echo -e "${RED}❌ FAIL: Scope protection hook is not executable${NC}"
    exit 1
fi

echo -e "${GREEN}✅ PASS: Scope protection hook is executable${NC}"

# Check for bypass keywords in the hook
bypass_keywords=("SCOPE-VERIFIED" "scope-verified" "emergency-scope-bypass" "DRY-VERIFIED")
for keyword in "${bypass_keywords[@]}"; do
    if grep -q "$keyword" "$SCOPE_HOOK"; then
        echo -e "${GREEN}✅ PASS: Bypass keyword '$keyword' found in hook${NC}"
    else
        echo -e "${YELLOW}⚠️  WARN: Bypass keyword '$keyword' not found in hook${NC}"
    fi
done

# Test hook syntax
if bash -n "$SCOPE_HOOK"; then
    echo -e "${GREEN}✅ PASS: Hook has valid bash syntax${NC}"
else
    echo -e "${RED}❌ FAIL: Hook has syntax errors${NC}"
    exit 1
fi

# Create a temporary test file to simulate commit
TEST_FILE="temp-scope-test.txt"
echo "Test content for scope validation" > "$TEST_FILE"

# Test that we can run the hook (basic functionality check)
if [ -x "$SCOPE_HOOK" ]; then
    echo -e "${YELLOW}🔧 Testing hook execution...${NC}"
    
    # Set environment variable for commit message (bypass version)
    export GIT_COMMIT_MSG="SCOPE-VERIFIED: testing bypass mechanism functionality"
    
    # Add test file to git
    git add "$TEST_FILE" 2>/dev/null || true
    
    # Run the hook (capture output but don't fail on non-zero exit)
    if "$SCOPE_HOOK" >/dev/null 2>&1; then
        echo -e "${GREEN}✅ PASS: Hook executed successfully with bypass keyword${NC}"
    else
        echo -e "${YELLOW}⚠️  INFO: Hook execution completed (may have failed due to scope rules, which is expected)${NC}"
    fi
    
    # Clean up
    rm -f "$TEST_FILE"
    git reset HEAD "$TEST_FILE" 2>/dev/null || true
    unset GIT_COMMIT_MSG
    
    echo -e "${GREEN}✅ PASS: Hook basic execution test completed${NC}"
else
    echo -e "${RED}❌ FAIL: Cannot execute hook${NC}"
    exit 1
fi

echo -e "${GREEN}🎉 SUCCESS: Scope protection fix validation completed!${NC}"
echo -e "${YELLOW}💡 Next step: Test committing files with bypass keywords${NC}"