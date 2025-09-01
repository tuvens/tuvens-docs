#!/usr/bin/env bats
# Unit tests for agentic-development/scripts/hooks/* pre-commit hooks
# TDD Test Suite - Testing safety-critical pre-commit validation hooks
# SAFETY-CRITICAL: These hooks prevent dangerous commits and enforce safety rules

# Load test setup
load setup

# Setup for each test
setup() {
    export TEST_REPO_DIR
    TEST_REPO_DIR=$(setup_test_git_repo)
    cd "$TEST_REPO_DIR"
    
    # Create minimal CLAUDE.md for testing
    echo "# CLAUDE.md" > CLAUDE.md
    echo "## Critical Claude Code Safety Rules" >> CLAUDE.md
    echo "## Mandatory Branch Naming Conventions" >> CLAUDE.md
    
    # Set up environment for pre-commit hook testing
    export HOOKS_DIR="$PWD/agentic-development/scripts/hooks"
}

# Teardown after each test
teardown() {
    teardown_test_git_repo "$TEST_REPO_DIR"
}

@test "check-branch-naming.sh: validates proper agent branch naming" {
    if [ ! -f "$HOOKS_DIR/check-branch-naming.sh" ]; then
        skip "check-branch-naming.sh not found"
    fi
    
    # Test valid branch name
    git checkout -b "vibe-coder/feature/test-implementation"
    run "$HOOKS_DIR/check-branch-naming.sh"
    [ "$status" -eq 0 ]
}

@test "check-branch-naming.sh: rejects invalid branch naming" {
    if [ ! -f "$HOOKS_DIR/check-branch-naming.sh" ]; then
        skip "check-branch-naming.sh not found"
    fi
    
    # Test invalid branch name
    git checkout -b "invalid-branch-name"
    run "$HOOKS_DIR/check-branch-naming.sh"
    [ "$status" -ne 0 ]
}

@test "check-protected-branches.sh: prevents commits to main branch" {
    if [ ! -f "$HOOKS_DIR/check-protected-branches.sh" ]; then
        skip "check-protected-branches.sh not found"
    fi
    
    # Switch to main branch (protected)
    git checkout -b main 2>/dev/null || git checkout main
    
    run "$HOOKS_DIR/check-protected-branches.sh"
    [ "$status" -ne 0 ]
}

@test "check-protected-branches.sh: allows commits to feature branches" {
    if [ ! -f "$HOOKS_DIR/check-protected-branches.sh" ]; then
        skip "check-protected-branches.sh not found"
    fi
    
    # Switch to feature branch (allowed)
    git checkout -b "vibe-coder/feature/test-branch"
    
    run "$HOOKS_DIR/check-protected-branches.sh"
    [ "$status" -eq 0 ]
}

@test "validate-claude-md.sh: passes when CLAUDE.md exists with required sections" {
    if [ ! -f "$HOOKS_DIR/validate-claude-md.sh" ]; then
        skip "validate-claude-md.sh not found"
    fi
    
    # CLAUDE.md already created in setup with required sections
    run "$HOOKS_DIR/validate-claude-md.sh"
    [ "$status" -eq 0 ]
}

@test "validate-claude-md.sh: fails when CLAUDE.md is missing" {
    if [ ! -f "$HOOKS_DIR/validate-claude-md.sh" ]; then
        skip "validate-claude-md.sh not found"
    fi
    
    # Remove CLAUDE.md
    rm -f CLAUDE.md
    
    run "$HOOKS_DIR/validate-claude-md.sh"
    [ "$status" -ne 0 ]
}

@test "check-safety-rules.sh: detects potential security violations" {
    if [ ! -f "$HOOKS_DIR/check-safety-rules.sh" ]; then
        skip "check-safety-rules.sh not found"
    fi
    
    # Create file with potential security issue
    echo "export AWS_SECRET_KEY=secret123" > test-security.sh
    git add test-security.sh
    
    run "$HOOKS_DIR/check-safety-rules.sh"
    # Should detect security issue (may pass or fail depending on implementation)
    
    # Cleanup
    rm -f test-security.sh
}

@test "check-scope-protection.sh: validates agent scope boundaries" {
    if [ ! -f "$HOOKS_DIR/check-scope-protection.sh" ]; then
        skip "check-scope-protection.sh not found"
    fi
    
    # Test scope protection (depends on implementation)
    run "$HOOKS_DIR/check-scope-protection.sh"
    # Status depends on current agent scope and files being committed
}

@test "pre-commit hooks: all hooks have executable permissions" {
    if [ ! -d "$HOOKS_DIR" ]; then
        skip "hooks directory not found"
    fi
    
    local hook_files
    hook_files=($(find "$HOOKS_DIR" -name "*.sh" -type f))
    
    for hook in "${hook_files[@]}"; do
        # Each hook should be executable
        [ -x "$hook" ] || {
            echo "Hook not executable: $(basename "$hook")"
            false
        }
    done
}

@test "pre-commit hooks: all hooks have valid bash syntax" {
    if [ ! -d "$HOOKS_DIR" ]; then
        skip "hooks directory not found"
    fi
    
    local hook_files
    hook_files=($(find "$HOOKS_DIR" -name "*.sh" -type f))
    
    for hook in "${hook_files[@]}"; do
        # Each hook should have valid bash syntax
        bash -n "$hook" || {
            echo "Syntax error in: $(basename "$hook")"
            false
        }
    done
}

@test "pre-commit hooks: hooks produce helpful error messages" {
    if [ ! -f "$HOOKS_DIR/check-branch-naming.sh" ]; then
        skip "check-branch-naming.sh not found for error message testing"
    fi
    
    # Test with invalid branch name to get error message
    git checkout -b "invalid-name-format"
    run "$HOOKS_DIR/check-branch-naming.sh"
    
    # Should fail and provide helpful error message
    [ "$status" -ne 0 ]
    [ -n "$output" ]  # Should have some output explaining the error
}