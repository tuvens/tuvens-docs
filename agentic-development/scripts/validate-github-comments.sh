#!/usr/bin/env bash
# GitHub Comment Standards Protocol Validation Script
# Purpose: Validate GitHub issue comments for compliance with agentic-development/protocols/github-comment-standards.md

set -euo pipefail

# Usage function
usage() {
    echo "Usage: $0 [--issue ISSUE_NUMBER] [--comment-text 'COMMENT_TEXT'] [--help]"
    echo ""
    echo "Examples:"
    echo "  Validate specific issue comments:"
    echo "    $0 --issue 158"
    echo ""
    echo "  Validate comment text directly:"
    echo "    $0 --comment-text '👤 **Identity**: devops\n🎯 **Addressing**: @all\n\n## Test Comment'"
    echo ""
    echo "  Get help:"
    echo "    $0 --help"
    echo ""
    exit 1
}

# Initialize variables
ISSUE_NUMBER=""
COMMENT_TEXT=""
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROTOCOL_FILE="$SCRIPT_DIR/../protocols/github-comment-standards.md"

# Valid agent names from the protocol
VALID_AGENTS=(
    "vibe-coder"
    "docs-orchestrator"
    "devops"
    "qa"
    "laravel-dev"
    "react-dev"
    "python-dev"
    "security-audit"
    "performance-dev"
    "test-automation"
    "codehooks-dev"
    "node-dev"
    "svelte-dev"
    "mobile-dev"
)

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --issue)
            ISSUE_NUMBER="$2"
            shift 2
            ;;
        --comment-text)
            COMMENT_TEXT="$2"
            shift 2
            ;;
        --help|-h)
            usage
            ;;
        *)
            echo "Unknown option: $1"
            usage
            ;;
    esac
done

# Check if protocol file exists
if [[ ! -f "$PROTOCOL_FILE" ]]; then
    echo "❌ ERROR: GitHub Comment Standards Protocol file not found: $PROTOCOL_FILE"
    exit 1
fi

# Function to validate agent name
validate_agent_name() {
    local agent_name="$1"
    for valid_agent in "${VALID_AGENTS[@]}"; do
        if [[ "$agent_name" == "$valid_agent" ]]; then
            return 0
        fi
    done
    return 1
}

# Function to validate single comment
validate_comment() {
    local comment="$1"
    local violations=()
    local identity_line=""
    local addressing_line=""
    local has_status=false
    local has_next_action=false
    local has_timeline=false
    local has_vt_compliance=false
    
    echo "🔍 Validating comment format..."
    
    # Check for required identity header
    if echo "$comment" | grep -q "^👤 \*\*Identity\*\*:"; then
        identity_line=$(echo "$comment" | grep "^👤 \*\*Identity\*\*:" | head -1)
        agent_name=$(echo "$identity_line" | sed 's/^👤 \*\*Identity\*\*: *//g' | xargs)
        
        if [[ -z "$agent_name" ]]; then
            violations+=("Missing agent name in identity declaration")
        elif ! validate_agent_name "$agent_name"; then
            violations+=("Unregistered agent name: '$agent_name'")
        fi
    else
        violations+=("Missing required identity header (👤 **Identity**: [agent-name])")
    fi
    
    # Check for required addressing header
    if echo "$comment" | grep -q "^🎯 \*\*Addressing\*\*:"; then
        addressing_line=$(echo "$comment" | grep "^🎯 \*\*Addressing\*\*:" | head -1)
        target=$(echo "$addressing_line" | sed 's/^🎯 \*\*Addressing\*\*: *//g' | xargs)
        
        if [[ -z "$target" ]]; then
            violations+=("Missing target in addressing declaration")
        fi
    else
        violations+=("Missing required addressing header (🎯 **Addressing**: [target])")
    fi
    
    # Check for required status, next action, and timeline
    if echo "$comment" | grep -q "\*\*Status\*\*:"; then
        has_status=true
    else
        violations+=("Missing required **Status**: declaration")
    fi
    
    if echo "$comment" | grep -q "\*\*Next Action\*\*:"; then
        has_next_action=true
    else
        violations+=("Missing required **Next Action**: declaration")
    fi
    
    if echo "$comment" | grep -q "\*\*Timeline\*\*:"; then
        has_timeline=true
    else
        violations+=("Missing required **Timeline**: declaration")
    fi
    
    # Check for comment subject (H2 heading)
    if ! echo "$comment" | grep -q "^## "; then
        violations+=("Missing comment subject/title (## [Subject])")
    fi
    
    # Check for V/T principle compliance (for QA agents)
    if echo "$identity_line" | grep -q "qa"; then
        if echo "$comment" | grep -q -E "(V/T|Verify|independently verified|verified by running|evidence|verification)"; then
            has_vt_compliance=true
        else
            violations+=("QA agent comment missing V/T principle compliance evidence")
        fi
    fi
    
    # Report results
    if [[ ${#violations[@]} -eq 0 ]]; then
        echo "✅ Comment format is COMPLIANT with GitHub Comment Standards Protocol"
        return 0
    else
        echo "❌ Comment format violations detected:"
        for violation in "${violations[@]}"; do
            echo "   - $violation"
        done
        
        echo ""
        echo "📋 Required format:"
        echo "👤 **Identity**: [agent-name]"
        echo "🎯 **Addressing**: [target-agent or @all]"
        echo ""
        echo "## [Comment Subject]"
        echo "[Your comment content]"
        echo ""
        echo "**Status**: [status]"
        echo "**Next Action**: [next-action]"
        echo "**Timeline**: [timeline]"
        echo ""
        echo "📋 V/T Principle: QA agents must provide verification evidence"
        echo "📖 Reference: $PROTOCOL_FILE"
        return 1
    fi
}

# Function to validate issue comments
validate_issue_comments() {
    local issue_num="$1"
    echo "🔍 Validating comments for GitHub issue #$issue_num"
    
    # Check if gh CLI is available
    if ! command -v gh &>/dev/null; then
        echo "❌ ERROR: GitHub CLI (gh) is required but not installed"
        echo "   Install: https://cli.github.com/"
        exit 1
    fi
    
    # Get issue comments count first
    local comment_count
    comment_count=$(gh issue view "$issue_num" --json comments --jq '.comments | length' 2>/dev/null)
    
    if [[ -z "$comment_count" || "$comment_count" -eq 0 ]]; then
        echo "⚠️  No comments found for issue #$issue_num"
        return 0
    fi
    
    local total_comments=0
    local compliant_comments=0
    local violation_comments=0
    
    # Process each complete comment individually by index to handle multi-line content
    for ((i=0; i<comment_count; i++)); do
        local comment
        comment=$(gh issue view "$issue_num" --json comments --jq -r ".comments[$i].body" 2>/dev/null)
        
        if [[ -n "$comment" ]]; then
            total_comments=$((total_comments + 1))
            echo ""
            echo "--- Comment $total_comments ---"
            
            if validate_comment "$comment"; then
                compliant_comments=$((compliant_comments + 1))
            else
                violation_comments=$((violation_comments + 1))
            fi
        fi
    done
    
    # Final report
    echo ""
    echo "📊 VALIDATION SUMMARY for Issue #$issue_num"
    echo "=================================="
    echo "Total comments: $total_comments"
    echo "Compliant: $compliant_comments"
    echo "Violations: $violation_comments"
    echo "Compliance rate: $(( (compliant_comments * 100) / (total_comments > 0 ? total_comments : 1) ))%"
    
    if [[ $violation_comments -gt 0 ]]; then
        echo ""
        echo "⚠️  ACTION REQUIRED: $violation_comments comments need format correction"
        echo "📖 Reference: $PROTOCOL_FILE"
        return 1
    else
        echo ""
        echo "✅ ALL COMMENTS COMPLIANT with GitHub Comment Standards Protocol"
        return 0
    fi
}

# Main execution
if [[ -n "$ISSUE_NUMBER" ]]; then
    validate_issue_comments "$ISSUE_NUMBER"
elif [[ -n "$COMMENT_TEXT" ]]; then
    validate_comment "$COMMENT_TEXT"
else
    echo "❌ ERROR: Either --issue or --comment-text must be provided"
    usage
fi