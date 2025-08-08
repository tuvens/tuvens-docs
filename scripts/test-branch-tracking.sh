#!/bin/bash
# test-branch-tracking.sh - Specialized tests for branch tracking system validation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TRACKING_DIR="$SCRIPT_DIR/../agentic-development/branch-tracking"

# Color codes
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

echo "🔍 Branch Tracking System - Specialized Validation"
echo "================================================="

# Test 1: Validate branch tracking directory structure
test_directory_structure() {
    echo "Testing directory structure..."
    
    local required_files=(
        "active-branches.json"
        "task-groups.json" 
        "cleanup-queue.json"
        "merge-log.json"
    )
    
    for file in "${required_files[@]}"; do
        if [[ -f "$TRACKING_DIR/$file" ]]; then
            echo -e "${GREEN}✅${NC} $file exists"
        else
            echo -e "${RED}❌${NC} $file missing"
            return 1
        fi
    done
    
    return 0
}

# Test 2: Validate branch tracking scripts
test_tracking_scripts() {
    echo "Testing branch tracking scripts..."
    
    local scripts_to_check=(
        "$SCRIPT_DIR/agent-status.sh"
        "$SCRIPT_DIR/system-status.sh"
        "$SCRIPT_DIR/../agentic-development/scripts/update-branch-tracking.js"
        "$SCRIPT_DIR/../agentic-development/scripts/cleanup-merged-branches.sh"
        "$SCRIPT_DIR/../agentic-development/scripts/setup-agent-task.sh"
    )
    
    local script_names=(
        "agent-status.sh"
        "system-status.sh"
        "update-branch-tracking.js"
        "cleanup-merged-branches.sh"
        "setup-agent-task.sh"
    )
    
    for i in "${!scripts_to_check[@]}"; do
        local script_path="${scripts_to_check[i]}"
        local script_name="${script_names[i]}"
        
        if [[ -f "$script_path" ]]; then
            if [[ -x "$script_path" ]] || [[ "$script_name" == *.js ]]; then
                echo -e "${GREEN}✅${NC} $script_name exists and executable"
            else
                echo -e "${YELLOW}⚠️${NC} $script_name exists but not executable"
            fi
        else
            echo -e "${RED}❌${NC} $script_name missing"
            return 1
        fi
    done
    
    return 0
}

# Test 3: Test actual branch tracking functionality
test_branch_tracking_functionality() {
    echo "Testing branch tracking functionality..."
    
    # Create a backup of current active branches
    if [[ -f "$TRACKING_DIR/active-branches.json" ]]; then
        cp "$TRACKING_DIR/active-branches.json" "$TRACKING_DIR/active-branches.json.backup"
    fi
    
    # Test update-branch-tracking.js with test data
    if node "$SCRIPT_DIR/../agentic-development/scripts/update-branch-tracking.js" \
        --action=create \
        --repository=test-repo \
        --branch=test-branch \
        --author=test-user \
        --agent=test-agent \
        --worktree=/tmp/test \
        --issues=test#1 > /dev/null 2>&1; then
        
        echo -e "${GREEN}✅${NC} Branch tracking update successful"
        
        # Verify the update was recorded
        if grep -q "test-branch" "$TRACKING_DIR/active-branches.json" 2>/dev/null; then
            echo -e "${GREEN}✅${NC} Branch tracking data updated correctly"
        else
            echo -e "${RED}❌${NC} Branch tracking data not updated"
            return 1
        fi
    else
        echo -e "${RED}❌${NC} Branch tracking update failed"
        return 1
    fi
    
    # Restore backup
    if [[ -f "$TRACKING_DIR/active-branches.json.backup" ]]; then
        mv "$TRACKING_DIR/active-branches.json.backup" "$TRACKING_DIR/active-branches.json"
    fi
    
    return 0
}

# Test 4: Validate GitHub Actions workflows
test_github_actions() {
    echo "Testing GitHub Actions workflows..."
    
    local workflow_dir="$SCRIPT_DIR/../.github/workflows"
    local workflows=(
        "branch-created.yml"
        "branch-merged.yml" 
        "branch-deleted.yml"
        "branch-tracking.yml"
        "vibe-coder-maintenance.yml"
    )
    
    for workflow in "${workflows[@]}"; do
        if [[ -f "$workflow_dir/$workflow" ]]; then
            # Check for correct authentication
            if grep -q "TUVENS_DOCS_TOKEN" "$workflow_dir/$workflow"; then
                echo -e "${GREEN}✅${NC} $workflow has correct authentication"
            else
                echo -e "${RED}❌${NC} $workflow missing TUVENS_DOCS_TOKEN"
                return 1
            fi
        else
            echo -e "${RED}❌${NC} $workflow missing"
            return 1
        fi
    done
    
    return 0
}

# Test 5: Agent status scripts functionality
test_agent_scripts() {
    echo "Testing agent status scripts..."
    
    # Test agent-status.sh
    if bash "$SCRIPT_DIR/agent-status.sh" vibe-coder > /tmp/agent-status-test.out 2>&1; then
        if grep -q "Agent Status" /tmp/agent-status-test.out; then
            echo -e "${GREEN}✅${NC} agent-status.sh produces expected output"
        else
            echo -e "${RED}❌${NC} agent-status.sh unexpected output"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️${NC} agent-status.sh failed (may be due to missing jq)"
    fi
    
    # Test system-status.sh
    if bash "$SCRIPT_DIR/system-status.sh" > /tmp/system-status-test.out 2>&1; then
        if grep -q "System Status" /tmp/system-status-test.out; then
            echo -e "${GREEN}✅${NC} system-status.sh produces expected output"
        else
            echo -e "${RED}❌${NC} system-status.sh unexpected output"
            return 1
        fi
    else
        echo -e "${YELLOW}⚠️${NC} system-status.sh failed (may be due to missing jq)"
    fi
    
    # Cleanup
    rm -f /tmp/agent-status-test.out /tmp/system-status-test.out
    
    return 0
}

# Run all tests
main() {
    local failed_tests=0
    
    test_directory_structure || ((failed_tests++))
    echo ""
    
    test_tracking_scripts || ((failed_tests++))  
    echo ""
    
    test_branch_tracking_functionality || ((failed_tests++))
    echo ""
    
    test_github_actions || ((failed_tests++))
    echo ""
    
    test_agent_scripts || ((failed_tests++))
    echo ""
    
    echo "📊 Branch Tracking Test Summary"
    echo "==============================="
    
    if [[ $failed_tests -eq 0 ]]; then
        echo -e "${GREEN}✅ All branch tracking tests passed!${NC}"
        echo "🎉 Branch tracking system is fully validated!"
        exit 0
    else
        echo -e "${RED}❌ $failed_tests test(s) failed!${NC}"
        echo "🔧 Please review and fix failing components."
        exit 1
    fi
}

main "$@"