#!/usr/bin/env bash
# Fix Legacy Pre-commit Hook Issue
# Removes problematic legacy pre-commit hook files that reference node_modules/pre-commit/hook
# 
# This script addresses the issue where legacy files .git/hooks/pre-commit.legacy and 
# .git/hooks/pre-commit.old cause commits to hang by trying to execute non-existent 
# ./node_modules/pre-commit/hook

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to log messages
log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Find the git root directory
find_git_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]] || [[ -f "$dir/.git" ]]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    return 1
}

# Get the actual git directory (handles worktrees)
get_git_dir() {
    local git_root="$1"
    if [[ -f "$git_root/.git" ]]; then
        # This is a worktree, read the gitdir from .git file
        local gitdir_line=$(head -n1 "$git_root/.git")
        local gitdir_path="${gitdir_line#gitdir: }"
        
        # If path is relative, make it absolute
        if [[ ! "$gitdir_path" =~ ^/ ]]; then
            gitdir_path="$git_root/$gitdir_path"
        fi
        
        # The hooks directory is in the main .git directory, not the worktree-specific one
        # Navigate up to find the main .git directory
        local main_git_dir=$(dirname "$(dirname "$gitdir_path")")
        echo "$main_git_dir"
    else
        echo "$git_root/.git"
    fi
}

# Check if a file contains the problematic node_modules reference
contains_problematic_reference() {
    local file="$1"
    if [[ -f "$file" ]]; then
        grep -q "node_modules/pre-commit/hook" "$file" 2>/dev/null
    else
        return 1
    fi
}

# Main function to fix legacy pre-commit hooks
fix_legacy_hooks() {
    log_info "Starting legacy pre-commit hook cleanup..."
    
    # Find git root
    local git_root
    if ! git_root=$(find_git_root); then
        log_error "Not in a git repository"
        exit 1
    fi
    
    log_info "Git repository found at: $git_root"
    
    # Get git directory (handles worktrees)
    local git_dir
    git_dir=$(get_git_dir "$git_root")
    local hooks_dir="$git_dir/hooks"
    
    log_info "Hooks directory: $hooks_dir"
    
    if [[ ! -d "$hooks_dir" ]]; then
        log_warn "Hooks directory does not exist: $hooks_dir"
        return 0
    fi
    
    # Array of problematic legacy files to check and remove
    local legacy_files=(
        "$hooks_dir/pre-commit.legacy"
        "$hooks_dir/pre-commit.old"
        "$hooks_dir/pre-commit.backup"
    )
    
    local found_issues=false
    
    # Check for and remove legacy files
    for legacy_file in "${legacy_files[@]}"; do
        if [[ -f "$legacy_file" ]]; then
            log_warn "Found legacy file: $legacy_file"
            
            if contains_problematic_reference "$legacy_file"; then
                log_warn "File contains problematic node_modules/pre-commit/hook reference"
                
                # Create backup before removing
                local backup_file="${legacy_file}.$(date +%Y%m%d_%H%M%S).backup"
                cp "$legacy_file" "$backup_file"
                log_info "Created backup: $backup_file"
                
                # Remove the problematic file
                rm "$legacy_file"
                log_info "Removed problematic legacy file: $legacy_file"
                found_issues=true
            else
                log_info "File does not contain problematic reference, leaving it alone"
            fi
        fi
    done
    
    # Check if the current pre-commit hook has any issues
    local current_hook="$hooks_dir/pre-commit"
    if [[ -f "$current_hook" ]]; then
        if contains_problematic_reference "$current_hook"; then
            log_error "Current pre-commit hook contains problematic reference!"
            log_error "This suggests the hook was corrupted. Please reinstall pre-commit hooks:"
            log_error "  pip install pre-commit && pre-commit install"
            found_issues=true
        else
            log_info "Current pre-commit hook is clean"
        fi
    fi
    
    # Additional cleanup: remove any other files in hooks directory that reference the problematic path
    log_info "Scanning for other files with problematic references..."
    local other_files_found=false
    
    while IFS= read -r -d '' file; do
        if contains_problematic_reference "$file"; then
            log_warn "Found additional file with problematic reference: $file"
            
            # Don't auto-remove these, just warn
            log_warn "Please manually inspect and fix this file if needed"
            other_files_found=true
        fi
    done < <(find "$hooks_dir" -type f -print0 2>/dev/null)
    
    # Summary
    if [[ "$found_issues" == true ]]; then
        log_info "Legacy pre-commit hook cleanup completed with issues resolved"
        log_info "You may need to reinstall pre-commit hooks: pip install pre-commit && pre-commit install"
    elif [[ "$other_files_found" == true ]]; then
        log_warn "Some files need manual inspection, but no automatic cleanup was needed"
    else
        log_info "No problematic legacy pre-commit hooks found - repository is clean"
    fi
}

# Show usage if help requested
if [[ "${1:-}" == "--help" ]] || [[ "${1:-}" == "-h" ]]; then
    echo "Usage: $0 [--dry-run]"
    echo ""
    echo "Fix legacy pre-commit hook issues that cause commits to hang."
    echo "This script removes .git/hooks/pre-commit.legacy and .git/hooks/pre-commit.old"
    echo "files that reference the problematic ./node_modules/pre-commit/hook path."
    echo ""
    echo "Options:"
    echo "  --dry-run    Show what would be done without making changes"
    echo "  --help, -h   Show this help message"
    exit 0
fi

# Dry run mode
if [[ "${1:-}" == "--dry-run" ]]; then
    log_info "DRY RUN MODE - No changes will be made"
    # In a real implementation, you'd add dry-run logic here
    log_warn "Dry run mode not fully implemented yet"
    exit 0
fi

# Run the main function
fix_legacy_hooks