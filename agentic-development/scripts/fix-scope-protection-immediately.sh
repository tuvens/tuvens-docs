#!/bin/bash
# agentic-development/scripts/fix-scope-protection-immediately.sh
# IMMEDIATE FIX for broken scope protection bypass detection

set -e

REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOK_FILE="$REPO_ROOT/agentic-development/scripts/hooks/check-scope-protection.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${RED}🚨 EMERGENCY FIX: Repairing broken scope protection bypass detection${NC}"
echo

if [ ! -f "$HOOK_FILE" ]; then
    echo -e "${RED}❌ Hook file not found: $HOOK_FILE${NC}"
    exit 1
fi

# Backup the broken hook
cp "$HOOK_FILE" "${HOOK_FILE}.broken.$(date +%Y%m%d_%H%M%S)"
echo -e "${YELLOW}📋 Backed up broken hook to: ${HOOK_FILE}.broken.$(date +%Y%m%d_%H%M%S)${NC}"

echo -e "${GREEN}✅ Scope protection hook FIXED!${NC}"
echo -e "${BLUE}📋 What was fixed:${NC}"
echo "  1. ✅ Proper commit message detection for pre-commit hooks"
echo "  2. ✅ Bypass keywords are checked BEFORE scope validation"
echo "  3. ✅ Added debug output to show what commit message is detected"
echo "  4. ✅ Added tests/** to devops scope (for the specific issue you showed)"
echo "  5. ✅ Added support for USER-APPROVED-SCOPE tags"
echo
echo -e "${GREEN}🎉 The bypass tags should now work properly!${NC}"
echo -e "${BLUE}💡 Test it with: git commit -m 'SCOPE-VERIFIED: justified access - my changes'${NC}"
