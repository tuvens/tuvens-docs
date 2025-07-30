#!/usr/bin/env bash
# File: fix-common-errors.sh
# Purpose: Automated fixes for the 12 documented technical failures

set -euo pipefail

echo "🔧 Multi-Agent System Error Recovery"
echo "===================================="

fix_git_repository_error() {
    echo "🔧 Checking git repository..."
    if [[ ! -d ".git" ]]; then
        echo "   Initializing git repository..."
        git init
        # Note: Update with actual repository URL
        echo "   ⚠️  Manual step required: Add remote origin"
        echo "      git remote add origin <your-repo-url>"
        echo "✅ Git repository initialized"
    else
        echo "   ✓ Git repository exists"
    fi
}

fix_missing_develop_branch() {
    echo "🔧 Checking develop branch..."
    if ! git show-ref --verify --quiet refs/heads/develop 2>/dev/null; then
        echo "   Creating develop branch..."
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        git checkout -b develop
        if git remote get-url origin &>/dev/null; then
            git push -u origin develop
            echo "✅ Develop branch created and pushed"
        else
            echo "✅ Develop branch created (push manually when remote is set)"
        fi
        git checkout "$CURRENT_BRANCH"
    else
        echo "   ✓ Develop branch exists"
    fi
}

fix_worktree_structure() {
    echo "🔧 Checking worktree structure..."
    local worktree_base="/Users/ciarancarroll/code/tuvens/worktrees"
    
    if [[ ! -d "$worktree_base" ]]; then
        echo "   Creating worktree base directory..."
        mkdir -p "$worktree_base"
    fi
    
    # Create agent-specific directories
    for agent in "vibe-coder" "frontend-developer" "backend-developer" "integration-specialist"; do
        mkdir -p "$worktree_base/tuvens-docs/$agent"
    done
    
    # Create repository directories
    mkdir -p "$worktree_base/tuvens-api"
    mkdir -p "$worktree_base/tuvens-frontend"
    
    echo "✅ Worktree structure verified/created"
}

fix_github_cli() {
    echo "🔧 Checking GitHub CLI..."
    if ! command -v gh &>/dev/null; then
        echo "❌ ERROR: GitHub CLI not installed"
        echo "   Install with: brew install gh"
        return 1
    fi
    
    if ! gh auth status &>/dev/null; then
        echo "❌ ERROR: GitHub CLI not authenticated"
        echo "   Run: gh auth login"
        return 1
    fi
    
    echo "   ✓ GitHub CLI authenticated and ready"
}

fix_path_confusion() {
    echo "🔧 Checking path structure..."
    local expected_path="/Users/ciarancarroll/code/tuvens"
    
    if [[ ! "$PWD" == *"$expected_path"* ]]; then
        echo "❌ WARNING: Not in expected path structure"
        echo "   Current:  $PWD"
        echo "   Expected: $expected_path"
        echo "   Please navigate to the correct directory"
        return 1
    fi
    
    echo "   ✓ Path structure correct"
}

fix_agentic_development_structure() {
    echo "🔧 Checking agentic development structure..."
    
    # Core directories
    mkdir -p agentic-development/{agent-system,workflows,scripts,reports}
    mkdir -p agentic-development/claude-templates
    mkdir -p agentic-development/integration-guides
    
    # Ensure key files exist (create minimal versions if missing)
    if [[ ! -f "agentic-development/agent-system/agent-identities.md" ]]; then
        echo "   Creating minimal agent-identities.md..."
        cat > "agentic-development/agent-system/agent-identities.md" << 'EOF'
# Agent Identities

## Core Agents

### Vibe Coder
Experimental agent for creative system building and pattern discovery.

### Frontend Developer
Specialized in React, TypeScript, and modern frontend development.

### Backend Developer  
Expert in Node.js, APIs, databases, and server-side architecture.

### Integration Specialist
Focuses on system integration, DevOps, and deployment workflows.
EOF
    fi
    
    echo "✅ Agentic development structure verified"
}

fix_gitignore_temp_directories() {
    echo "🔧 Checking .gitignore for .temp directories..."
    
    if [[ ! -f ".gitignore" ]]; then
        echo "   Creating .gitignore..."
        touch .gitignore
    fi
    
    if ! grep -q "\.temp/" .gitignore 2>/dev/null; then
        echo "   Adding .temp/ to .gitignore..."
        echo "" >> .gitignore
        echo "# Temporary agent communication files" >> .gitignore  
        echo ".temp/" >> .gitignore
        echo "**/.temp/" >> .gitignore
    fi
    
    echo "   ✓ .gitignore configured for .temp directories"
}

clean_failed_worktrees() {
    echo "🔧 Cleaning failed worktrees..."
    
    # List and remove any corrupted worktrees
    if git worktree list &>/dev/null; then
        git worktree prune
        echo "   ✓ Pruned stale worktree references"
    fi
}

# Main execution
main() {
    echo "Running automated error recovery..."
    echo ""
    
    # Core fixes (must succeed)
    fix_path_confusion || exit 1
    fix_git_repository_error
    fix_agentic_development_structure
    fix_gitignore_temp_directories
    
    # Optional fixes (warnings only)
    fix_missing_develop_branch || echo "   ⚠️  Develop branch issue - may need manual fix"
    fix_worktree_structure
    fix_github_cli || echo "   ⚠️  GitHub CLI issue - may need manual fix"
    clean_failed_worktrees
    
    echo ""
    echo "🎉 Error recovery COMPLETE"
    echo "System should now be ready for multi-agent operations"
    echo ""
    echo "If issues persist, check the manual troubleshooting guide:"
    echo "  agentic-development/workflows/cto-technical-improvements.md"
}

# Help function
if [[ "${1:-}" == "--help" || "${1:-}" == "-h" ]]; then
    echo "Multi-Agent System Error Recovery Script"
    echo ""
    echo "This script automatically fixes common issues in the multi-agent development system:"
    echo "  - Git repository initialization"
    echo "  - Missing develop branch"
    echo "  - Worktree structure problems"
    echo "  - GitHub CLI authentication"
    echo "  - Path confusion issues"
    echo "  - Agentic development structure"
    echo "  - .gitignore configuration"
    echo "  - Failed worktree cleanup"
    echo ""
    echo "Usage: $0 [--help|-h]"
    exit 0
fi

# Run main function
main