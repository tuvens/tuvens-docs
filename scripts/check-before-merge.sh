#!/bin/bash

# Pre-Merge Safety Integration Script
# Comprehensive safety validation before merging branches
# Integrates with branch tracking data and safety tools

set -e

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${CYAN}🛡️  Pre-Merge Safety Integration${NC}"
echo "=================================="
echo ""

# Configuration
BRANCH_TRACKING_DIR="agentic-development/branch-tracking"
ACTIVE_BRANCHES_FILE="$BRANCH_TRACKING_DIR/active-branches.json"
MERGE_LOG_FILE="$BRANCH_TRACKING_DIR/merge-log.json"

# Get current branch and target
# Use GitHub Actions environment variables if available, otherwise fallback to git
if [ -n "$GITHUB_HEAD_REF" ]; then
    CURRENT_BRANCH="$GITHUB_HEAD_REF"
else
    CURRENT_BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || echo "HEAD")
fi

if [ -n "$GITHUB_BASE_REF" ]; then
    TARGET_BRANCH="$GITHUB_BASE_REF"
else
    TARGET_BRANCH="${1:-dev}"  # Default to dev if no target specified
fi

echo -e "${BLUE}Current branch:${NC} $CURRENT_BRANCH"
echo -e "${BLUE}Target branch:${NC} $TARGET_BRANCH"
echo ""

# Safety validation results
VALIDATION_RESULTS=()
WARNINGS=()
CRITICAL_ISSUES=()

# Check 1: Branch Protection Validation
echo "1️⃣ Branch Protection Validation"
echo "--------------------------------"

# Run our existing branch-check tool with environment variables
if GITHUB_HEAD_REF="$GITHUB_HEAD_REF" GITHUB_BASE_REF="$GITHUB_BASE_REF" ./scripts/branch-check > /tmp/branch-check-output 2>&1; then
    echo -e "${GREEN}✅ Branch protection checks passed${NC}"
    VALIDATION_RESULTS+=("branch-protection:passed")
else
    echo -e "${RED}❌ Branch protection validation failed${NC}"
    echo -e "${YELLOW}Run: ./scripts/branch-check${NC} for details"
    CRITICAL_ISSUES+=("Branch protection validation failed")
    VALIDATION_RESULTS+=("branch-protection:failed")
fi
echo ""

# Check 2: Pre-commit Hook Validation
echo "2️⃣ Pre-commit Hook Safety"
echo "-------------------------"

if command -v pre-commit >/dev/null 2>&1; then
    if pre-commit run --all-files > /tmp/precommit-output 2>&1; then
        echo -e "${GREEN}✅ All pre-commit hooks passed${NC}"
        VALIDATION_RESULTS+=("pre-commit:passed")
    else
        echo -e "${RED}❌ Pre-commit hook failures detected${NC}"
        echo -e "${YELLOW}Run: pre-commit run --all-files${NC} for details"
        CRITICAL_ISSUES+=("Pre-commit hooks failed")
        VALIDATION_RESULTS+=("pre-commit:failed")
    fi
else
    echo -e "${YELLOW}⚠️  Pre-commit not installed${NC}"
    echo "   Install: pip install pre-commit && pre-commit install"
    WARNINGS+=("Pre-commit hooks not available")
    VALIDATION_RESULTS+=("pre-commit:missing")
fi
echo ""

# Check 3: Branch Tracking Integration
echo "3️⃣ Branch Tracking Analysis"
echo "----------------------------"

if [ -f "$ACTIVE_BRANCHES_FILE" ]; then
    echo -e "${GREEN}✅ Branch tracking data available${NC}"
    
    # Parse branch tracking data for current branch
    if command -v jq >/dev/null 2>&1; then
        # Get current branch info from tracking data
        BRANCH_INFO=$(jq -r --arg repo "tuvens-docs" --arg branch "$CURRENT_BRANCH" '.branches[$repo][]? | select(.name == $branch)' "$ACTIVE_BRANCHES_FILE" 2>/dev/null || echo "null")
        
        if [ "$BRANCH_INFO" != "null" ] && [ -n "$BRANCH_INFO" ]; then
            AGENT=$(echo "$BRANCH_INFO" | jq -r '.agent // "unknown"')
            STATUS=$(echo "$BRANCH_INFO" | jq -r '.status // "unknown"')
            TASK_GROUP=$(echo "$BRANCH_INFO" | jq -r '.taskGroup // "none"')
            
            echo -e "${BLUE}   Agent:${NC} $AGENT"
            echo -e "${BLUE}   Status:${NC} $STATUS"
            echo -e "${BLUE}   Task Group:${NC} $TASK_GROUP"
            
            # Validate branch status
            if [ "$STATUS" = "validated" ]; then
                echo -e "${GREEN}✅ Branch has passed validation${NC}"
                VALIDATION_RESULTS+=("tracking:validated")
            elif [ "$STATUS" = "active" ]; then
                echo -e "${YELLOW}⚠️  Branch status: active (not validated)${NC}"
                WARNINGS+=("Branch not yet validated through branch protection workflow")
                VALIDATION_RESULTS+=("tracking:unvalidated")
            else
                echo -e "${RED}❌ Branch status: $STATUS${NC}"
                CRITICAL_ISSUES+=("Branch has concerning status: $STATUS")
                VALIDATION_RESULTS+=("tracking:failed")
            fi
        else
            echo -e "${YELLOW}⚠️  Current branch not found in tracking data${NC}"
            echo "   This may be a new branch or tracking data is outdated"
            WARNINGS+=("Branch not in tracking system")
            VALIDATION_RESULTS+=("tracking:missing")
        fi
    else
        echo -e "${YELLOW}⚠️  jq not available for parsing tracking data${NC}"
        WARNINGS+=("Cannot parse branch tracking data (jq missing)")
        VALIDATION_RESULTS+=("tracking:unparseable")
    fi
else
    echo -e "${RED}❌ Branch tracking data not found${NC}"
    echo "   Expected: $ACTIVE_BRANCHES_FILE"
    CRITICAL_ISSUES+=("Branch tracking system unavailable")
    VALIDATION_RESULTS+=("tracking:missing")
fi
echo ""

# Check 4: Agent Workload Analysis
echo "4️⃣ Agent Workload Analysis"
echo "---------------------------"

if [ -f "$ACTIVE_BRANCHES_FILE" ] && command -v jq >/dev/null 2>&1; then
    # Count active branches by agent
    AGENT_WORKLOADS=$(jq -r '.branches."tuvens-docs"[]? | select(.status == "active") | .agent' "$ACTIVE_BRANCHES_FILE" 2>/dev/null | sort | uniq -c | sort -rn)
    
    if [ -n "$AGENT_WORKLOADS" ]; then
        echo -e "${BLUE}Current agent workloads:${NC}"
        while IFS= read -r line; do
            COUNT=$(echo "$line" | awk '{print $1}')
            AGENT=$(echo "$line" | awk '{print $2}')
            
            if [ "$COUNT" -gt 3 ]; then
                echo -e "${RED}   • $AGENT: $COUNT active branches (HIGH LOAD)${NC}"
                WARNINGS+=("Agent $AGENT has high workload: $COUNT active branches")
            elif [ "$COUNT" -gt 2 ]; then
                echo -e "${YELLOW}   • $AGENT: $COUNT active branches (MODERATE)${NC}"
                WARNINGS+=("Agent $AGENT has moderate workload: $COUNT active branches")
            else
                echo -e "${GREEN}   • $AGENT: $COUNT active branches${NC}"
            fi
        done <<< "$AGENT_WORKLOADS"
        
        echo ""
        echo -e "${BLUE}Workload recommendations:${NC}"
        echo "   • 1-2 branches: Optimal workload"
        echo "   • 3 branches: Monitor for completion"
        echo "   • 4+ branches: Consider task prioritization"
        
        VALIDATION_RESULTS+=("workload:analyzed")
    else
        echo -e "${GREEN}✅ No active branch workload data available${NC}"
        VALIDATION_RESULTS+=("workload:empty")
    fi
else
    echo -e "${YELLOW}⚠️  Cannot analyze agent workloads${NC}"
    echo "   Requires: branch tracking data + jq"
    VALIDATION_RESULTS+=("workload:unavailable")
fi
echo ""

# Check 5: Merge Target Validation
echo "5️⃣ Merge Target Validation"
echo "---------------------------"

# Validate merge target based on branch type
case "$CURRENT_BRANCH" in
    */hotfix/*)
        if [ "$TARGET_BRANCH" != "stage" ]; then
            echo -e "${RED}❌ Hotfix branches should target 'stage', not '$TARGET_BRANCH'${NC}"
            CRITICAL_ISSUES+=("Incorrect merge target for hotfix branch")
        else
            echo -e "${GREEN}✅ Hotfix → stage: Correct target${NC}"
        fi
        ;;
    */feature/*|*/bugfix/*|*/docs/*|*/workflow/*|*/refactor/*)
        if [ "$TARGET_BRANCH" != "dev" ]; then
            echo -e "${RED}❌ Feature/bugfix/docs branches should target 'dev', not '$TARGET_BRANCH'${NC}"
            CRITICAL_ISSUES+=("Incorrect merge target for feature branch")
        else
            echo -e "${GREEN}✅ Feature → dev: Correct target${NC}"
        fi
        ;;
    *)
        echo -e "${YELLOW}⚠️  Unknown branch type: $CURRENT_BRANCH${NC}"
        echo "   Validating against general merge rules"
        if [[ "$TARGET_BRANCH" == "main" || "$TARGET_BRANCH" == "stage" ]]; then
            echo -e "${RED}❌ Direct targeting of '$TARGET_BRANCH' not recommended${NC}"
            CRITICAL_ISSUES+=("Direct targeting of protected branch")
        else
            echo -e "${GREEN}✅ Target validation passed${NC}"
        fi
        ;;
esac

VALIDATION_RESULTS+=("target:validated")
echo ""

# Check 6: Change Impact Assessment
echo "6️⃣ Change Impact Assessment"
echo "----------------------------"

# Count changes by type
STAGED_CHANGES=$(git diff --cached --name-only | wc -l | tr -d ' ')

# Count workflow changes
WORKFLOW_FILES=$(git diff --cached --name-only | grep "\.github/workflows/" 2>/dev/null || echo "")
WORKFLOW_CHANGES=0
if [ -n "$WORKFLOW_FILES" ]; then
    WORKFLOW_CHANGES=$(echo "$WORKFLOW_FILES" | wc -l | tr -d ' ')
fi

# Count safety changes
SAFETY_FILES=$(git diff --cached --name-only | grep -E "(CLAUDE\.md|\.pre-commit|scripts/hooks)" 2>/dev/null || echo "")
SAFETY_CHANGES=0
if [ -n "$SAFETY_FILES" ]; then
    SAFETY_CHANGES=$(echo "$SAFETY_FILES" | wc -l | tr -d ' ')
fi

# Count documentation changes
DOCS_FILES=$(git diff --cached --name-only | grep -E "\.(md|txt)$" 2>/dev/null || echo "")
DOCS_CHANGES=0
if [ -n "$DOCS_FILES" ]; then
    DOCS_CHANGES=$(echo "$DOCS_FILES" | wc -l | tr -d ' ')
fi

echo -e "${BLUE}Change summary:${NC}"
echo "   • Total staged files: $STAGED_CHANGES"
echo "   • Workflow changes: $WORKFLOW_CHANGES"
echo "   • Safety tool changes: $SAFETY_CHANGES"  
echo "   • Documentation changes: $DOCS_CHANGES"

# Assess risk level
RISK_LEVEL="LOW"
if [ "$WORKFLOW_CHANGES" -gt 0 ]; then
    RISK_LEVEL="HIGH"
    echo -e "${RED}⚠️  HIGH RISK: Workflow changes detected${NC}"
    WARNINGS+=("Workflow changes require extra review")
elif [ "$SAFETY_CHANGES" -gt 0 ]; then
    RISK_LEVEL="MEDIUM"
    echo -e "${YELLOW}⚠️  MEDIUM RISK: Safety tool changes${NC}"
    WARNINGS+=("Safety tool changes should be tested thoroughly")
elif [ "$STAGED_CHANGES" -gt 10 ]; then
    RISK_LEVEL="MEDIUM"
    echo -e "${YELLOW}⚠️  MEDIUM RISK: Large changeset${NC}"
    WARNINGS+=("Large changeset - consider breaking into smaller merges")
else
    echo -e "${GREEN}✅ LOW RISK: Standard changes${NC}"
fi

VALIDATION_RESULTS+=("impact:$RISK_LEVEL")
echo ""

# Summary and Decision
echo "📋 Pre-Merge Safety Summary"
echo "============================"

echo -e "${BLUE}Validation Results:${NC}"
for result in "${VALIDATION_RESULTS[@]}"; do
    echo "   • $result"
done
echo ""

if [ ${#CRITICAL_ISSUES[@]} -gt 0 ]; then
    echo -e "${RED}❌ CRITICAL ISSUES FOUND - MERGE BLOCKED${NC}"
    echo ""
    echo -e "${RED}Critical issues:${NC}"
    for issue in "${CRITICAL_ISSUES[@]}"; do
        echo -e "${RED}   🚨 $issue${NC}"
    done
    echo ""
    echo -e "${RED}🛑 DO NOT MERGE until critical issues are resolved${NC}"
    echo ""
    echo "Resolution steps:"
    echo "   1. Fix all critical issues listed above"
    echo "   2. Re-run: npm run pre-merge"
    echo "   3. Proceed with merge only after all checks pass"
    exit 1
fi

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo -e "${YELLOW}⚠️  WARNINGS DETECTED - PROCEED WITH CAUTION${NC}"
    echo ""
    echo -e "${YELLOW}Warnings:${NC}"
    for warning in "${WARNINGS[@]}"; do
        echo -e "${YELLOW}   ⚠️  $warning${NC}"
    done
    echo ""
    echo -e "${YELLOW}💡 Review warnings and consider addressing before merge${NC}"
else
    echo -e "${GREEN}🎉 ALL CHECKS PASSED!${NC}"
    echo ""
    echo -e "${GREEN}✅ Safe to proceed with merge${NC}"
fi

echo ""
echo "🔧 Available commands:"
echo "   • npm run branch-check     - Detailed branch validation"
echo "   • npm run validate-hooks   - Test all pre-commit hooks" 
echo "   • npm run pre-merge [target] - Run this safety check"
echo ""
echo "📖 Documentation: CLAUDE.md, IMPLEMENTATION_NOTES.md"

# Record merge attempt in tracking system (if successful)
if [ ${#CRITICAL_ISSUES[@]} -eq 0 ] && [ -f "$ACTIVE_BRANCHES_FILE" ] && command -v node >/dev/null 2>&1; then
    echo -e "${BLUE}Recording pre-merge validation...${NC}"
    if [ -f "agentic-development/scripts/update-branch-tracking.js" ]; then
        node agentic-development/scripts/update-branch-tracking.js \
            --event-type=validate \
            --payload="{\"repository\":\"tuvens-docs\",\"branch\":\"$CURRENT_BRANCH\",\"agent\":\"pre-merge-check\",\"validation-status\":\"pre-merge-passed\",\"target-branch\":\"$TARGET_BRANCH\"}" \
            2>/dev/null || echo "Note: Could not record validation status"
    fi
fi

exit 0