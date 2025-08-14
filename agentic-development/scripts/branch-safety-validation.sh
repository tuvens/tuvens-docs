#!/bin/bash

# Branch Safety Pre-Work Validation Script
# Part of Phase 3: Branch Safety Implementation - Orchestration System Development
# 
# Purpose: Validates branch safety before agents begin work
# Integration: Works with Phase 1 System Orchestrator identity and Phase 2 protocols
# Safety: Prevents protected branch commits, validates environment, provides guidance

set -e

# Color codes for output formatting
readonly GREEN='\033[0;32m'
readonly RED='\033[0;31m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly NC='\033[0m' # No Color

# Configuration
readonly SCRIPT_NAME="Branch Safety Pre-Work Validation"
readonly VERSION="1.0.0"
readonly PROTECTED_BRANCHES=("main" "stage" "test")
readonly VALID_AGENTS=("vibe-coder" "docs-orchestrator" "devops" "laravel-dev" "react-dev" "node-dev" "svelte-dev")
readonly VALID_TASK_TYPES=("feature" "bugfix" "docs" "workflow" "hotfix" "refactor")

# Error exit codes
readonly ERR_PROTECTED_BRANCH=1
readonly ERR_INVALID_BRANCH_NAME=2
readonly ERR_MISSING_CLAUDE_MD=3
readonly ERR_ENVIRONMENT_UNSAFE=4
readonly ERR_STAGED_VIOLATIONS=5

# Utility Functions
log_header() {
    echo ""
    echo -e "${PURPLE}================================================${NC}"
    echo -e "${PURPLE}🛡️  $SCRIPT_NAME v$VERSION${NC}"
    echo -e "${PURPLE}================================================${NC}"
    echo ""
}

log_section() {
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}$(printf '%.0s-' {1..40})${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Core Validation Functions
get_current_branch() {
    # Use GitHub Actions environment if available, otherwise git
    if [ -n "$GITHUB_HEAD_REF" ]; then
        echo "$GITHUB_HEAD_REF"
    else
        git symbolic-ref --short HEAD 2>/dev/null || echo "HEAD"
    fi
}

validate_protected_branch() {
    local current_branch="$1"
    
    log_section "1️⃣ Protected Branch Safety Check"
    
    # Check for detached HEAD
    if [ "$current_branch" = "HEAD" ]; then
        log_warning "Detached HEAD state detected"
        log_info "This is typically safe for read-only operations"
        return 0
    fi
    
    # Check against protected branches
    for protected in "${PROTECTED_BRANCHES[@]}"; do
        if [ "$current_branch" = "$protected" ]; then
            log_error "CRITICAL: Cannot work on protected branch '$current_branch'"
            echo ""
            echo -e "${RED}🛡️  Tuvens 5-Branch Strategy Violation:${NC}"
            echo "   main ← stage ← test ← dev ← feature/*"
            echo ""
            echo -e "${GREEN}✅ Required Workflow:${NC}"
            echo "   1. Switch to 'dev' branch: ${YELLOW}git checkout dev${NC}"
            echo "   2. Create feature branch: ${YELLOW}git checkout -b {agent}/{type}/{description}${NC}"
            echo "   3. Make changes on feature branch"
            echo "   4. Submit PR targeting 'dev' branch"
            echo ""
            echo -e "${YELLOW}📖 Reference: CLAUDE.md > Git Safety and Branch Protection${NC}"
            return $ERR_PROTECTED_BRANCH
        fi
    done
    
    log_success "Safe to work on branch: $current_branch"
    return 0
}

validate_branch_naming() {
    local current_branch="$1"
    
    log_section "2️⃣ Branch Naming Convention Check"
    
    # Skip validation for detached HEAD
    if [ "$current_branch" = "HEAD" ]; then
        log_info "Detached HEAD - branch naming validation skipped"
        return 0
    fi
    
    # Validate branch naming pattern: {agent}/{type}/{description}
    if [[ "$current_branch" =~ ^([^/]+)/([^/]+)/([a-z0-9-]+)$ ]]; then
        local agent="${BASH_REMATCH[1]}"
        local task_type="${BASH_REMATCH[2]}"
        local description="${BASH_REMATCH[3]}"
        
        # Validate agent name
        local agent_valid=false
        for valid_agent in "${VALID_AGENTS[@]}"; do
            if [ "$agent" = "$valid_agent" ]; then
                agent_valid=true
                break
            fi
        done
        
        # Validate task type
        local type_valid=false
        for valid_type in "${VALID_TASK_TYPES[@]}"; do
            if [ "$task_type" = "$valid_type" ]; then
                type_valid=true
                break
            fi
        done
        
        if [ "$agent_valid" = true ] && [ "$type_valid" = true ]; then
            log_success "Branch naming follows conventions"
            log_info "Agent: $agent | Type: $task_type | Description: $description"
            return 0
        else
            log_error "Invalid branch naming components"
            [ "$agent_valid" = false ] && log_error "Invalid agent: $agent"
            [ "$type_valid" = false ] && log_error "Invalid task type: $task_type"
        fi
    else
        log_error "Branch naming format violation"
        log_info "Current: $current_branch"
    fi
    
    echo ""
    echo -e "${YELLOW}Required Format: {agent}/{type}/{description}${NC}"
    echo -e "${YELLOW}Valid Agents:${NC} $(IFS=', '; echo "${VALID_AGENTS[*]}")"
    echo -e "${YELLOW}Valid Types:${NC} $(IFS=', '; echo "${VALID_TASK_TYPES[*]}")"
    echo ""
    echo -e "${GREEN}Example:${NC} vibe-coder/feature/branch-safety-implementation"
    
    return $ERR_INVALID_BRANCH_NAME
}

validate_claude_md() {
    log_section "3️⃣ CLAUDE.md Safety File Validation"
    
    if [ ! -f "CLAUDE.md" ]; then
        log_error "CLAUDE.md safety file is missing"
        echo ""
        echo -e "${YELLOW}This file is required for repository safety and contains:${NC}"
        echo "   • Critical Claude Code Safety Rules"
        echo "   • Git Safety and Branch Protection guidelines"
        echo "   • Mandatory Branch Naming Conventions"
        echo "   • Emergency Protocols and Recovery Procedures"
        echo ""
        echo -e "${GREEN}📖 Reference:${NC} Create CLAUDE.md with safety rules"
        return $ERR_MISSING_CLAUDE_MD
    fi
    
    log_success "CLAUDE.md exists"
    
    # Validate required sections
    local required_sections=(
        "Critical Claude Code Safety Rules"
        "Mandatory Branch Naming Conventions" 
        "Pull Request Target Branch Rules"
        "Emergency Branch Recovery Procedures"
        "Testing Protocol Requirements"
    )
    
    local missing_sections=()
    for section in "${required_sections[@]}"; do
        if ! grep -q "$section" CLAUDE.md; then
            missing_sections+=("$section")
        fi
    done
    
    if [ ${#missing_sections[@]} -eq 0 ]; then
        log_success "All required safety sections present"
    else
        log_warning "Missing required sections in CLAUDE.md:"
        for missing in "${missing_sections[@]}"; do
            echo "   • $missing"
        done
    fi
    
    # Validate 5-branch strategy documentation
    if grep -q "main ← stage ← test ← dev ← feature" CLAUDE.md; then
        log_success "5-branch strategy properly documented"
    else
        log_warning "5-branch strategy not clearly documented"
    fi
    
    return 0
}

validate_environment() {
    log_section "4️⃣ Development Environment Check"
    
    local issues=0
    
    # Check for git repository
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_error "Not in a git repository"
        ((issues++))
    else
        log_success "Git repository detected"
    fi
    
    # Check for pre-commit configuration
    if [ -f ".pre-commit-config.yaml" ]; then
        log_success "Pre-commit configuration exists"
        
        # Check if pre-commit is installed
        if command -v pre-commit >/dev/null 2>&1; then
            log_success "Pre-commit tool is installed"
        else
            log_warning "Pre-commit tool not installed"
            log_info "Install with: pip install pre-commit"
        fi
    else
        log_warning "No pre-commit configuration found"
        log_info "Consider adding .pre-commit-config.yaml for safety hooks"
    fi
    
    # Check for safety hook scripts
    local hook_scripts=(
        "scripts/hooks/check-branch-naming.sh"
        "scripts/hooks/check-protected-branches.sh"
        "scripts/hooks/validate-claude-md.sh"
        "scripts/hooks/check-safety-rules.sh"
    )
    
    local missing_hooks=()
    for hook in "${hook_scripts[@]}"; do
        if [ ! -f "$hook" ]; then
            missing_hooks+=("$hook")
        fi
    done
    
    if [ ${#missing_hooks[@]} -eq 0 ]; then
        log_success "All safety hook scripts present"
    else
        log_warning "Missing safety hook scripts:"
        for hook in "${missing_hooks[@]}"; do
            echo "   • $hook"
        done
    fi
    
    return $issues
}

validate_staging_area() {
    log_section "5️⃣ Staging Area Safety Check"
    
    # Check for staged changes
    local staged_files
    staged_files=$(git diff --cached --name-only 2>/dev/null || echo "")
    
    if [ -z "$staged_files" ]; then
        log_success "No staged changes - clean state"
        return 0
    fi
    
    log_info "Staged files detected:"
    echo "$staged_files" | sed 's/^/   • /'
    echo ""
    
    local violations=()
    
    # Check for important file deletions
    local important_files=("CLAUDE.md" "README.md" "package.json" ".gitignore")
    for file in "${important_files[@]}"; do
        if git diff --cached --name-status 2>/dev/null | grep -q "^D.*$file$"; then
            violations+=("Attempting to delete critical file: $file")
        fi
    done
    
    # Check for workflow modifications
    if echo "$staged_files" | grep -q "\.github/workflows/"; then
        violations+=("GitHub Actions workflow changes detected - ensure proper review")
    fi
    
    # Check for binary files
    while IFS= read -r file; do
        if [ -f "$file" ] && file "$file" | grep -q "binary"; then
            violations+=("Binary file staged: $file")
        fi
    done <<< "$staged_files"
    
    if [ ${#violations[@]} -eq 0 ]; then
        log_success "No staging area safety violations detected"
        return 0
    else
        log_warning "Potential staging area issues:"
        for violation in "${violations[@]}"; do
            echo "   • $violation"
        done
        log_info "Review staged changes before committing"
        return 0  # Warnings, not errors
    fi
}

generate_safety_report() {
    local current_branch="$1"
    local validation_result="$2"
    
    log_section "📋 Branch Safety Validation Summary"
    
    if [ "$validation_result" -eq 0 ]; then
        log_success "All critical safety checks passed!"
        echo ""
        echo -e "${GREEN}🎉 Branch Safety Status: SAFE TO PROCEED${NC}"
        echo -e "${GREEN}   Current Branch: $current_branch${NC}"
        echo -e "${GREEN}   Agent can begin work following Phase 2 protocols${NC}"
        echo ""
        echo -e "${BLUE}📋 Next Steps:${NC}"
        echo "   1. Follow agent check-in protocol from Phase 2"
        echo "   2. Declare file scope to prevent conflicts"
        echo "   3. Use universal comment format in GitHub issues"
        echo "   4. Request vibe-coder approval before beginning work"
        echo ""
        echo -e "${YELLOW}📖 References:${NC}"
        echo "   • CLAUDE.md - Safety rules and protocols"
        echo "   • agentic-development/protocols/ - Phase 2 procedures"
        echo "   • .claude/agents/vibe-coder.md - System orchestrator identity"
    else
        log_error "Critical safety violations detected!"
        echo ""
        echo -e "${RED}🚨 Branch Safety Status: UNSAFE - WORK BLOCKED${NC}"
        echo -e "${RED}   Current Branch: $current_branch${NC}"
        echo -e "${RED}   Agent must resolve issues before proceeding${NC}"
        echo ""
        echo -e "${YELLOW}⚡ Quick Resolution Commands:${NC}"
        case $validation_result in
            $ERR_PROTECTED_BRANCH)
                echo "   git checkout dev"
                echo "   git checkout -b {agent}/{type}/{description}"
                ;;
            $ERR_INVALID_BRANCH_NAME)
                echo "   git checkout -b {agent}/{type}/{description}"
                ;;
            $ERR_MISSING_CLAUDE_MD)
                echo "   # Create CLAUDE.md with safety rules"
                ;;
            *)
                echo "   # Resolve specific issues mentioned above"
                ;;
        esac
        echo ""
        echo -e "${YELLOW}🆘 Need Help?${NC}"
        echo "   • Check CLAUDE.md for complete safety rules"
        echo "   • Review agentic-development/protocols/ for procedures"
        echo "   • Ask vibe-coder for guidance via GitHub issue"
    fi
    
    echo ""
    log_info "Branch Safety Validation completed"
    echo ""
}

# Command Processing
show_usage() {
    cat << EOF
$SCRIPT_NAME v$VERSION

USAGE:
    $0 [OPTIONS]

OPTIONS:
    --help                         Show this help message
    --version                      Show version information

DESCRIPTION:
    Comprehensive pre-work validation to ensure safe development environment
    before agents begin work. Validates protected branch safety, branch naming
    conventions, CLAUDE.md requirements, and development environment setup.

EXAMPLES:
    # Run comprehensive safety validation
    $0
    
    # Show help information
    $0 --help

For more information, see: agentic-development/docs/branch-safety-guide.md
EOF
}

# Main Execution
main() {
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --help)
                show_usage
                exit 0
                ;;
            --version)
                echo "$SCRIPT_NAME v$VERSION"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    log_header
    
    # Get current branch
    local current_branch
    current_branch=$(get_current_branch)
    
    log_info "Starting branch safety validation for: $current_branch"
    log_info "Working directory: $(pwd)"
    echo ""
    
    # Run all validations
    local validation_result=0
    
    # Critical validations (failure blocks work)
    validate_protected_branch "$current_branch" || validation_result=$?
    [ $validation_result -eq 0 ] && validate_branch_naming "$current_branch" || validation_result=$?
    [ $validation_result -eq 0 ] && validate_claude_md || validation_result=$?
    
    # Warning validations (don't block work)
    validate_environment
    validate_staging_area
    
    # Generate final report
    generate_safety_report "$current_branch" "$validation_result"
    
    return $validation_result
}

# Execute main function if script is run directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi