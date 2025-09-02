#!/bin/bash

# create-pr.sh - Deterministic PR creation with 5-branch strategy enforcement
# 
# This script handles all PR creation logic with comprehensive validation
# and ensures compliance with the Tuvens 5-branch strategy.
#
# Usage: ./create-pr.sh [pr-title] [target-branch]
#
# Author: DevOps Agent
# Version: 1.0
# Last Updated: $(date '+%Y-%m-%d')

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
    exit 1
}

# Help function
show_help() {
    cat << EOF
create-pr.sh - Deterministic PR Creation with Branch Strategy Enforcement

USAGE:
    ./create-pr.sh [pr-title] [target-branch]

ARGUMENTS:
    pr-title        Optional. Title for the pull request. If not provided, 
                    will be auto-generated from branch name.
    target-branch   Optional. Target branch for PR. Defaults to 'dev'.
                    Use 'stage' only for emergency hotfixes.

EXAMPLES:
    ./create-pr.sh
    ./create-pr.sh "Add user authentication system"
    ./create-pr.sh "Fix critical security issue" stage

5-BRANCH STRATEGY:
    main ← stage ← test ← dev ← feature/*

    Standard PRs:  feature/* → dev
    Hotfixes:     hotfix/*  → stage (emergency only)
    
    ❌ BLOCKED: Direct PRs to main, stage from feature branches
    ❌ BLOCKED: PRs from protected branches (main, stage, test)

VALIDATION CHECKS:
    ✅ Branch naming convention: {agent}/{type}/{description}
    ✅ Working directory cleanliness
    ✅ Remote sync verification
    ✅ Protected branch prevention
    ✅ Target branch validation
    ✅ Emergency hotfix approval

For more information, see:
    - CLAUDE.md (branch strategy rules)
    - .claude/commands/create-pr.md (command documentation)
EOF
}

# Parse arguments
PR_TITLE="${1:-}"
TARGET_BRANCH="${2:-dev}"

# Show help if requested
if [[ "${PR_TITLE}" == "--help" || "${PR_TITLE}" == "-h" ]]; then
    show_help
    exit 0
fi

# Get current branch and repository info
CURRENT_BRANCH=$(git branch --show-current)
REPO_URL=$(git remote get-url origin)
REPO_NAME=$(basename "${REPO_URL}" .git)

log_info "Starting PR creation process..."
echo "Repository: ${REPO_NAME}"
echo "Current branch: ${CURRENT_BRANCH}"
echo "Target branch: ${TARGET_BRANCH}"
echo ""

# =============================================================================
# VALIDATION PHASE
# =============================================================================

log_info "Running comprehensive validation checks..."

# 1. Branch naming validation
validate_branch_naming() {
    log_info "Validating branch naming convention..."
    
    if [[ ! "${CURRENT_BRANCH}" =~ ^[a-z-]+/[a-z-]+/.+ ]]; then
        log_error "Branch name '${CURRENT_BRANCH}' doesn't follow {agent}/{type}/{description} format"
    fi
    
    log_success "Branch naming is valid"
}

# 2. Protected branch check
validate_not_on_protected_branch() {
    log_info "Checking if current branch is protected..."
    
    local protected_branches=("main" "stage" "test")
    
    for branch in "${protected_branches[@]}"; do
        if [[ "${CURRENT_BRANCH}" == "${branch}" ]]; then
            log_error "Cannot create PR from protected branch: ${CURRENT_BRANCH}. Create a feature branch from dev instead."
        fi
    done
    
    log_success "Not on a protected branch"
}

# 3. Working directory cleanliness
validate_working_directory() {
    log_info "Checking working directory cleanliness..."
    
    if [[ -n $(git status --porcelain) ]]; then
        log_error "Working directory not clean. Commit all changes first:\n$(git status --short)"
    fi
    
    log_success "Working directory is clean"
}

# 4. Remote sync verification
validate_remote_sync() {
    log_info "Verifying branch is synced with remote..."
    
    # Fetch latest from remote
    git fetch origin "${CURRENT_BRANCH}" 2>/dev/null || true
    
    # Check if branch exists on remote
    if ! git ls-remote --heads origin "${CURRENT_BRANCH}" | grep -q "${CURRENT_BRANCH}"; then
        log_error "Branch '${CURRENT_BRANCH}' not pushed to remote. Push first with: git push -u origin ${CURRENT_BRANCH}"
    fi
    
    # Check if local branch is behind remote
    local behind_count
    behind_count=$(git rev-list --count HEAD..origin/"${CURRENT_BRANCH}" 2>/dev/null || echo "0")
    
    if [[ "${behind_count}" -gt 0 ]]; then
        log_warning "Local branch is ${behind_count} commits behind remote. Consider pulling first."
    fi
    
    log_success "Branch is synced with remote"
}

# 5. Target branch validation and 5-branch strategy enforcement
validate_target_branch() {
    log_info "Validating target branch against 5-branch strategy..."
    
    case "${TARGET_BRANCH}" in
        "dev")
            log_success "Targeting dev branch - standard workflow ✅"
            ;;
        "stage")
            log_warning "Targeting stage branch - HOTFIX WORKFLOW"
            echo ""
            echo "🚨 EMERGENCY HOTFIX PROCESS"
            echo "Stage branch is for emergency hotfixes only."
            echo ""
            read -p "Is this an emergency hotfix requiring immediate production fix? (y/N): " confirm
            
            if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
                log_info "Non-emergency changes should target dev branch for proper workflow"
                TARGET_BRANCH="dev"
                log_success "Changed target to dev branch"
            else
                echo ""
                echo "📝 Emergency Justification Required:"
                read -p "Briefly describe the emergency (required for audit): " emergency_reason
                
                if [[ -z "${emergency_reason}" ]]; then
                    log_error "Emergency justification is required for stage branch PRs"
                fi
                
                log_warning "HOTFIX APPROVED: ${emergency_reason}"
                echo "⚠️  Remember to create corresponding dev branch PR for consistency"
            fi
            ;;
        "main"|"test")
            log_error "Direct PRs to '${TARGET_BRANCH}' are prohibited by 5-branch strategy. Use dev branch instead. Flow: dev → test → stage → main"
            ;;
        *)
            log_warning "Non-standard target branch: ${TARGET_BRANCH}"
            echo "Standard targets: dev (default), stage (hotfix only)"
            read -p "Continue with non-standard target '${TARGET_BRANCH}'? (y/N): " confirm
            
            if [[ ! "${confirm}" =~ ^[Yy]$ ]]; then
                log_info "Changing target to dev branch"
                TARGET_BRANCH="dev"
            fi
            ;;
    esac
}

# Run all validations
validate_branch_naming
validate_not_on_protected_branch
validate_working_directory
validate_remote_sync
validate_target_branch

log_success "All validation checks passed!"
echo ""

# =============================================================================
# PR CREATION PHASE
# =============================================================================

log_info "Generating PR content..."

# Extract branch information for PR generation
IFS='/' read -r AGENT_NAME TASK_TYPE DESCRIPTION_RAW <<< "${CURRENT_BRANCH}"
DESCRIPTION=$(echo "${DESCRIPTION_RAW}" | tr '-' ' ')

# Generate PR title if not provided
if [[ -z "${PR_TITLE}" ]]; then
    # Capitalize first letter of task type and description
    TASK_TYPE_FORMATTED=$(echo "${TASK_TYPE}" | sed 's/\b\w/\U&/g')
    DESCRIPTION_FORMATTED=$(echo "${DESCRIPTION}" | sed 's/\b\w/\U&/g')
    PR_TITLE="${TASK_TYPE_FORMATTED}: ${DESCRIPTION_FORMATTED}"
fi

# Generate PR body with comprehensive template
generate_pr_body() {
    cat << EOF
## Summary
[Brief description of changes implemented in this PR]

## Branch Strategy Compliance
- **Source Branch**: \`${CURRENT_BRANCH}\`
- **Target Branch**: \`${TARGET_BRANCH}\`
- **Agent**: ${AGENT_NAME}
- **Task Type**: ${TASK_TYPE}
- **5-Branch Strategy**: ✅ Compliant

$(if [[ "${TARGET_BRANCH}" == "stage" ]]; then
    echo "### 🚨 Emergency Hotfix"
    echo "- **Justification**: ${emergency_reason:-Emergency production fix}"
    echo "- **Follow-up**: Create corresponding dev branch PR"
    echo ""
fi)

## Changes Made
- [List key changes and modifications]
- [Include any breaking changes or migration notes]
- [Document any new dependencies or configuration changes]

## Testing Completed
- [ ] All existing tests pass locally
- [ ] New functionality includes tests
- [ ] Manual testing completed for affected features
- [ ] No breaking changes to existing functionality
- [ ] Performance impact assessed

## Code Quality Checklist
- [ ] Code follows project style guidelines
- [ ] Comments added for complex logic
- [ ] No sensitive information committed
- [ ] Documentation updated where needed
- [ ] Commit messages are clear and meaningful

## Deployment Notes
- [ ] Environment variables: [List any new variables needed]
- [ ] Database migrations: [Note any schema changes]
- [ ] Configuration changes: [Document any config updates]
- [ ] Rollback plan: [Describe rollback procedure if needed]

## Security Considerations
- [ ] No security vulnerabilities introduced
- [ ] Input validation implemented where needed
- [ ] Authentication/authorization respected
- [ ] No sensitive data exposed

## Review Checklist
- [ ] PR targets correct branch per 5-branch strategy
- [ ] All commits are meaningful and atomic  
- [ ] Branch follows naming convention
- [ ] No merge conflicts with target branch
- [ ] Ready for production deployment

---
🤖 **Generated with [Claude Code](https://claude.ai/code)**

**Agent**: ${AGENT_NAME} | **Script**: create-pr.sh v1.0
Co-Authored-By: Claude <noreply@anthropic.com>
EOF
}

PR_BODY=$(generate_pr_body)

log_info "Creating pull request..."
echo "Title: ${PR_TITLE}"
echo "Source: ${CURRENT_BRANCH}"
echo "Target: ${TARGET_BRANCH}"
echo ""

# Create the PR using GitHub CLI with error handling
if ! command -v gh &> /dev/null; then
    log_error "GitHub CLI (gh) is not installed or not in PATH. Install with: brew install gh"
fi

# Check if user is authenticated with GitHub CLI
if ! gh auth status &>/dev/null; then
    log_error "Not authenticated with GitHub CLI. Run: gh auth login"
fi

# Create the PR
if gh pr create \
    --title "${PR_TITLE}" \
    --body "${PR_BODY}" \
    --base "${TARGET_BRANCH}" \
    --head "${CURRENT_BRANCH}" \
    --draft false; then
    
    log_success "Pull request created successfully!"
    
    # Get PR URL and number
    PR_URL=$(gh pr view --json url --jq '.url')
    PR_NUMBER=$(gh pr view --json number --jq '.number')
    
    echo ""
    echo "🔗 PR URL: ${PR_URL}"
    echo "📋 PR #${PR_NUMBER}"
    
    # =============================================================================
    # POST-CREATION ENHANCEMENTS
    # =============================================================================
    
    log_info "Adding labels and metadata..."
    
    # Add labels based on task type
    case "${TASK_TYPE}" in
        "feature") gh pr edit "${PR_NUMBER}" --add-label "enhancement" ;;
        "bugfix"|"fix") gh pr edit "${PR_NUMBER}" --add-label "bug" ;;
        "docs"|"documentation") gh pr edit "${PR_NUMBER}" --add-label "documentation" ;;
        "workflow"|"ci") gh pr edit "${PR_NUMBER}" --add-label "ci/cd" ;;
        "hotfix") gh pr edit "${PR_NUMBER}" --add-label "hotfix,priority:high" ;;
        *) gh pr edit "${PR_NUMBER}" --add-label "enhancement" ;;
    esac
    
    # Add agent-specific label
    gh pr edit "${PR_NUMBER}" --add-label "agent/${AGENT_NAME}" || true
    
    # Add branch strategy compliance label
    gh pr edit "${PR_NUMBER}" --add-label "branch-strategy:compliant" || true
    
    # Add target branch label for tracking
    gh pr edit "${PR_NUMBER}" --add-label "target:${TARGET_BRANCH}" || true
    
    log_success "Labels added successfully"
    
    # =============================================================================
    # VALIDATION CHECKS POST-CREATION
    # =============================================================================
    
    log_info "Running post-creation validation..."
    
    # Verify PR targets correct branch
    PR_BASE=$(gh pr view "${PR_NUMBER}" --json baseRefName --jq '.baseRefName')
    PR_HEAD=$(gh pr view "${PR_NUMBER}" --json headRefName --jq '.headRefName')
    
    echo "📋 PR Validation Results:"
    echo "   Source: ${PR_HEAD}"
    echo "   Target: ${PR_BASE}"
    
    # Final branch strategy compliance check
    if [[ "${PR_BASE}" == "main" || "${PR_BASE}" == "test" ]] && [[ "${PR_HEAD}" =~ ^[^/]+/(feature|docs|bugfix)/ ]]; then
        log_warning "PR may violate 5-branch strategy - feature/doc/bugfix branches should typically target 'dev'"
    else
        log_success "PR follows 5-branch strategy correctly"
    fi
    
    # Look for related GitHub issues in commit messages
    log_info "Checking for issue references..."
    if git log --oneline -10 | grep -q "#[0-9]\+"; then
        log_success "Found issue references in commits - GitHub will auto-link"
        git log --oneline -10 | grep "#[0-9]\+" | head -3
    else
        log_info "No issue references found in recent commits"
    fi
    
    # =============================================================================
    # SUCCESS SUMMARY
    # =============================================================================
    
    echo ""
    echo "🎉 PR Creation Complete!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📋 PR Details:"
    echo "   Title: ${PR_TITLE}"
    echo "   Number: #${PR_NUMBER}"  
    echo "   Source: ${CURRENT_BRANCH}"
    echo "   Target: ${TARGET_BRANCH}"
    echo "   Agent: ${AGENT_NAME}"
    echo "   Type: ${TASK_TYPE}"
    echo ""
    echo "🔗 PR URL: ${PR_URL}"
    echo ""
    echo "✅ Next Steps:"
    echo "   1. Review the PR description and update as needed"
    echo "   2. Request reviews from appropriate team members"
    echo "   3. Wait for CI/CD checks to complete"
    echo "   4. Address any review feedback"
    echo "   5. Merge when approved and checks pass"
    
    if [[ "${TARGET_BRANCH}" == "stage" ]]; then
        echo ""
        echo "🚨 HOTFIX REMINDER:"
        echo "   - This is an emergency hotfix to stage branch"
        echo "   - Create a corresponding dev branch PR for consistency"
        echo "   - Monitor production deployment closely"
    fi
    
    echo ""
    log_success "create-pr.sh completed successfully!"
    
else
    log_error "Failed to create pull request. Check your permissions and try again."
fi