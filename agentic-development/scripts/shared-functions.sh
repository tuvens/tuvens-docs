#!/usr/bin/env bash
# File: shared-functions.sh
# Purpose: Shared functions for agent task automation scripts
# 
# This library prevents synchronization bugs by providing a single source of truth
# for common operations used by both setup-agent-task.sh and setup-agent-task-desktop.sh

set -euo pipefail

# Function to convert absolute paths to portable format using ~
make_path_portable() {
    local abs_path="$1"
    # Replace user's home directory with ~
    echo "$abs_path" | sed "s|^$HOME|~|"
}

# Function to expand portable paths back to absolute format
expand_portable_path() {
    local path="$1"
    if [[ "$path" == \~/* ]]; then
        echo "${HOME}${path#\~}"
    else
        echo "$path"
    fi
}

# Function to sanitize names for branch naming (standardized)
sanitize_for_branch() {
    echo "$1" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-'
}

# Function to calculate standardized branch name
calculate_branch_name() {
    local agent_name="$1"
    local task_title="$2"
    
    local sanitized_agent=$(sanitize_for_branch "$agent_name")
    local sanitized_task=$(sanitize_for_branch "$task_title")
    
    echo "$sanitized_agent/feature/$sanitized_task"
}

# Function to query actual worktree path from git (single source of truth)
get_worktree_path() {
    local branch_name="$1"
    
    # Query git for the actual worktree location
    local worktree_path
    worktree_path=$(git worktree list | grep "\\[$branch_name\\]" | awk '{print $1}')
    
    if [[ -n "$worktree_path" ]]; then
        echo "$worktree_path"
        return 0
    else
        return 1
    fi
}

# Function to determine repository structure paths
get_repo_paths() {
    local repo_root
    local repo_name
    
    repo_root=$(git rev-parse --show-toplevel)
    repo_name=$(basename "$repo_root")
    
    echo "$repo_root" "$repo_name"
}

# Function to calculate expected worktree path (for creation, not querying)
calculate_worktree_path() {
    local agent_name="$1"
    local branch_name="$2"
    
    local repo_info
    repo_info=($(get_repo_paths))
    local repo_root="${repo_info[0]}"
    local repo_name="${repo_info[1]}"
    
    local sanitized_agent
    sanitized_agent=$(sanitize_for_branch "$agent_name")
    
    if [[ "$repo_name" == "tuvens-docs" ]]; then
        echo "$repo_root/worktrees/$sanitized_agent/$branch_name"
    else
        local parent_dir
        parent_dir=$(dirname "$repo_root")
        echo "$parent_dir/$repo_name/worktrees/$sanitized_agent/$branch_name"
    fi
}

# Function to handle common error scenarios
handle_script_error() {
    local error_msg="$1"
    local exit_code="${2:-1}"
    
    echo "❌ ERROR: $error_msg" >&2
    echo "   This is a common issue. Check the troubleshooting guide." >&2
    exit "$exit_code"
}

# Function to validate that required tools are available
validate_required_tools() {
    local tools=("git" "gh")
    local missing_tools=()
    
    for tool in "${tools[@]}"; do
        if ! command -v "$tool" &> /dev/null; then
            missing_tools+=("$tool")
        fi
    done
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        handle_script_error "Required tools missing: ${missing_tools[*]}"
    fi
}

# Function to ensure we're in a git repository
validate_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        handle_script_error "Not in a git repository"
    fi
}

# Function to get current repository name for branch tracking
get_current_repo() {
    basename "$(git rev-parse --show-toplevel)"
}

# Export functions so they can be used by sourcing scripts
export -f make_path_portable
export -f expand_portable_path
export -f sanitize_for_branch
export -f calculate_branch_name
export -f get_worktree_path
export -f get_repo_paths
export -f calculate_worktree_path
export -f handle_script_error
export -f validate_required_tools
export -f validate_git_repo
export -f get_current_repo

# Prevent running this script directly
if [[ "${BASH_SOURCE[0]:-}" == "${0}" ]]; then
    echo "❌ This is a function library and should not be executed directly"
    echo "   Usage: source shared-functions.sh"
    exit 1
fi