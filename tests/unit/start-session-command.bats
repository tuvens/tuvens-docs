#!/usr/bin/env bats
# Unit tests for .claude/commands/start-session.md slash command

# Setup function runs before each test
setup() {
    # Create temporary test environment
    export TEST_PROJECT_ROOT="$(mktemp -d)"
    cd "$TEST_PROJECT_ROOT"
    
    # Initialize git repo
    git init --quiet
    git config user.email "test@example.com"
    git config user.name "Test User"
    
    # Create required directory structure
    mkdir -p agentic-development/scripts
    mkdir -p .claude/agents
    mkdir -p .claude/commands
    mkdir -p agentic-development/workflows
    
    # Create minimal CLAUDE.md
    cat > CLAUDE.md << 'EOF'
# Test CLAUDE.md
Basic safety rules for testing.
EOF

    # Create minimal workflow file
    cat > agentic-development/workflows/6-step-agent-workflow.md << 'EOF'
# 6-Step Agent Workflow
1. Context loading
2. Analysis
3. Planning
4. Implementation
5. Testing
6. Documentation
EOF

    # Create test agent configuration
    cat > .claude/agents/test-agent.md << 'EOF'
# Test Agent Configuration
Test agent for slash command testing.
EOF

    # Create mock setup-agent-task.sh script
    cat > agentic-development/scripts/setup-agent-task.sh << 'EOF'
#!/usr/bin/env bash
echo "Mock setup script called with:"
echo "Agent: $1"
echo "Title: $2"
echo "Description: $3"
exit 0
EOF
    chmod +x agentic-development/scripts/setup-agent-task.sh
    
    # Copy the actual start-session.md file to test location
    export ORIGINAL_DIR="$PWD"
    cp "/Users/ciarancarroll/Code/Tuvens/tuvens-docs/worktrees/vibe-coder/vibe-coder/feature/fix-desktop-agent-setup-issues/.claude/commands/start-session.md" .claude/commands/start-session.md
}

# Teardown function runs after each test
teardown() {
    if [[ -n "$TEST_PROJECT_ROOT" && -d "$TEST_PROJECT_ROOT" ]]; then
        rm -rf "$TEST_PROJECT_ROOT"
    fi
}

@test "start-session command file exists and has correct structure" {
    [ -f ".claude/commands/start-session.md" ]
    
    # Check for required YAML frontmatter
    grep -q "allowed-tools:" .claude/commands/start-session.md
    grep -q "description:" .claude/commands/start-session.md
    grep -q "argument-hint:" .claude/commands/start-session.md
}

@test "start-session command contains proper executable syntax" {
    # Check for executable command blocks using !` syntax
    grep -q "!\`" .claude/commands/start-session.md
    
    # Check for context loading with @ syntax
    grep -q "@CLAUDE.md" .claude/commands/start-session.md
}

@test "start-session command includes argument validation" {
    # Check for argument parsing logic
    grep -q "IFS=' ' read -ra ARGS" .claude/commands/start-session.md
    
    # Check for required argument validation
    grep -q "AGENT_NAME.*MISSING" .claude/commands/start-session.md
    
    # Check for error handling
    grep -q "❌ ERROR: Agent name is required" .claude/commands/start-session.md
}

@test "start-session command includes environment validation" {
    # Check for setup script validation
    grep -q "setup-agent-task.sh not found" .claude/commands/start-session.md
    
    # Check for git repository validation
    grep -q "Not in a git repository" .claude/commands/start-session.md
    
    # Check for GitHub CLI validation
    grep -q "GitHub CLI (gh) is not available" .claude/commands/start-session.md
}

@test "start-session command includes actual script execution" {
    # Check for setup script execution
    grep -q "./agentic-development/scripts/setup-agent-task.sh" .claude/commands/start-session.md
    
    # Check for proper variable usage in script call
    grep -q '\$AGENT_NAME.*\$TASK_TITLE.*\$TASK_DESCRIPTION' .claude/commands/start-session.md
}

@test "start-session command includes error handling for script execution" {
    # Check for success/failure handling
    grep -q "Agent session created successfully" .claude/commands/start-session.md
    
    grep -q "Failed to create agent session" .claude/commands/start-session.md
    
    # Check for proper exit codes
    grep -q "exit 1" .claude/commands/start-session.md
}

@test "start-session command follows established slash command patterns" {
    # Check for context section like other commands
    grep -q "Current Context" .claude/commands/start-session.md
    
    # Check for git context commands
    grep -q "git remote get-url origin" .claude/commands/start-session.md
    
    grep -q "git branch --show-current" .claude/commands/start-session.md
}

@test "start-session command includes complete workflow integration" {
    # Check for workflow file loading
    grep -q "6-step-agent-workflow.md" .claude/commands/start-session.md
    
    # Check for completion checklist
    grep -q "GitHub issue created and assigned" .claude/commands/start-session.md
    
    grep -q "Git worktree established" .claude/commands/start-session.md
    
    grep -q "iTerm2 window launched" .claude/commands/start-session.md
}