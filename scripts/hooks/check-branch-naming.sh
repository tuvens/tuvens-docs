#!/bin/bash

# Pre-commit Hook: Branch Naming Convention Check
# Validates branch names follow: {agent-name}/{task-type}/{descriptive-name}

set -e

# Get current branch name
BRANCH_NAME=$(git symbolic-ref --short HEAD 2>/dev/null || echo "HEAD")

# Skip check for HEAD (detached state)
if [ "$BRANCH_NAME" = "HEAD" ]; then
    exit 0
fi

# Define valid agents and task types
VALID_AGENTS="vibe-coder|docs-orchestrator|devops|laravel-dev|react-dev|node-dev|svelte-dev"
VALID_TASK_TYPES="feature|bugfix|docs|workflow|hotfix|refactor"

# Check branch naming pattern
if [[ ! "$BRANCH_NAME" =~ ^($VALID_AGENTS)/($VALID_TASK_TYPES)/[a-z0-9-]+$ ]]; then
    echo "❌ BRANCH NAMING VIOLATION"
    echo ""
    echo "Branch: $BRANCH_NAME"
    echo ""
    echo "Required format: {agent-name}/{task-type}/{descriptive-name}"
    echo ""
    echo "Valid agents:"
    echo "  • vibe-coder     - System building and experimentation"
    echo "  • docs-orchestrator - Documentation coordination"
    echo "  • devops         - Infrastructure and workflows"
    echo "  • laravel-dev    - Laravel/PHP development"
    echo "  • react-dev      - React frontend development"
    echo "  • node-dev       - Node.js development"
    echo "  • svelte-dev     - Svelte frontend development"
    echo ""
    echo "Valid task types:"
    echo "  • feature   - New functionality"
    echo "  • bugfix    - Bug fixes"
    echo "  • docs      - Documentation updates"
    echo "  • workflow  - Process/workflow changes"
    echo "  • hotfix    - Emergency fixes"
    echo "  • refactor  - Code refactoring"
    echo ""
    echo "Examples:"
    echo "  ✅ vibe-coder/feature/enhance-safety-system"
    echo "  ✅ docs-orchestrator/docs/api-reference-update"
    echo "  ✅ devops/workflow/branch-protection-setup"
    echo ""
    echo "🛡️  This check enforces CLAUDE.md safety rules"
    echo "📖 See: CLAUDE.md > Mandatory Branch Naming Conventions"
    echo ""
    exit 1
fi

echo "✅ Branch naming validation passed: $BRANCH_NAME"
exit 0