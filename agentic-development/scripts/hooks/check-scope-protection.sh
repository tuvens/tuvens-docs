#!/bin/bash

# Pre-commit Hook: Agent Scope Protection
# Validates that agents only modify files within their declared scope
# Includes DRY principle validation requiring agents to search before creating new files

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check for bypass keywords in commit message  
# For pre-commit hooks, we need to check the commit message from different sources
COMMIT_MSG=""

# Method 1: Check if commit message is provided via environment variable
if [ -n "${GIT_COMMIT_MSG:-}" ]; then
    COMMIT_MSG="$GIT_COMMIT_MSG"
# Method 2: Check COMMIT_EDITMSG (for commit-msg hooks and interactive commits)
elif [ -f "$(git rev-parse --git-dir)/COMMIT_EDITMSG" ]; then
    COMMIT_MSG=$(cat "$(git rev-parse --git-dir)/COMMIT_EDITMSG")
# Method 3: Check if commit message file is provided
elif [ -f "${COMMIT_MSG_FILE:-}" ]; then
    COMMIT_MSG=$(cat "$COMMIT_MSG_FILE")
# Method 4: For pre-commit hooks with -m flag, check process list for commit message
else
    # Try to extract commit message from the git commit command line
    COMMIT_MSG=$(ps aux | grep "git commit" | grep -v grep | sed -n 's/.*-m[[:space:]]*["'\'']\([^"'\'']*\)["'\''].*/\1/p' | head -1)
fi

# Debug output to help troubleshooting
echo -e "${BLUE}🔍 DEBUG: Commit message detected: '$COMMIT_MSG'${NC}"

if [ -n "$COMMIT_MSG" ]; then
    # Check for scope validation bypass
    if echo "$COMMIT_MSG" | grep -q -E "(scope-verified:|SCOPE-VERIFIED:|emergency-scope-bypass:)"; then
        echo -e "${GREEN}✅ Scope check bypassed: Manual scope verification detected${NC}"
        exit 0
    fi
    # Check for DRY principle bypass
    if echo "$COMMIT_MSG" | grep -q -E "DRY-VERIFIED:"; then
        echo -e "${GREEN}✅ DRY check bypassed: Manual DRY verification detected${NC}"
        exit 0
    fi
    # Check for documentation bypass
    if echo "$COMMIT_MSG" | grep -q -E "(DOCS-VERIFIED:|docs: verified examples only)"; then
        echo -e "${GREEN}✅ Scope check bypassed: Documentation verification detected${NC}"
        exit 0
    fi
else
    echo -e "${YELLOW}⚠️  No commit message detected for bypass checking${NC}"
fi

# Helper functions
detect_agent_from_branch() {
    local branch_name=$(git branch --show-current 2>/dev/null || echo "unknown")
    
    # Extract agent name from branch pattern: agent-name/type/description
    if [[ "$branch_name" =~ ^([^/]+)/([^/]+)/(.+)$ ]]; then
        echo "${BASH_REMATCH[1]}"
    else
        echo ""
    fi
}

get_agent_scope_patterns() {
    local agent="$1"
    
    case "$agent" in
        "devops")
            echo ".github/workflows/** agentic-development/scripts/hooks/** infrastructure/** docker/** k8s/** terraform/** monitoring/** .pre-commit-config.yaml"
            ;;
        "laravel-dev")
            echo "app/** database/** routes/** config/** resources/views/** tests/Feature/** tests/Unit/** composer.json composer.lock artisan"
            ;;
        "react-dev"|"svelte-dev")
            echo "src/components/** src/hooks/** src/utils/** src/assets/** src/styles/** public/** package.json package-lock.json vite.config.* tsconfig.json"
            ;;
        "node-dev")
            echo "src/** lib/** api/** middleware/** controllers/** services/** package.json package-lock.json tsconfig.json"
            ;;
        "docs-orchestrator")
            echo "docs/** README.md *.md agentic-development/docs/** tuvens-docs/**"
            ;;
        "vibe-coder")
            echo "agentic-development/protocols/** agentic-development/workflows/** CLAUDE.md .claude/**"
            ;;
        "mobile-dev")
            echo "mobile/** android/** ios/** src/mobile/** package.json"
            ;;
        *)
            echo ""
            ;;
    esac
}

file_matches_pattern() {
    local file="$1"
    local pattern="$2"
    
    # Convert glob pattern to regex-like matching
    case "$pattern" in
        *"**/"*)
            # Recursive directory pattern
            local dir_pattern=$(echo "$pattern" | sed 's|\*\*/|.*|g' | sed 's|\*|[^/]*|g')
            [[ "$file" =~ ^$dir_pattern ]]
            ;;
        *"*")
            # Simple wildcard pattern
            local regex_pattern=$(echo "$pattern" | sed 's|\*|[^/]*|g')
            [[ "$file" =~ ^$regex_pattern ]]
            ;;
        *)
            # Exact match or directory prefix
            [[ "$file" == "$pattern" || "$file" == "$pattern"/* ]]
            ;;
    esac
}

check_file_in_agent_scope() {
    local file="$1"
    local agent="$2"
    local scope_patterns="$3"
    
    # Check if file matches any of the agent's scope patterns
    for pattern in $scope_patterns; do
        if file_matches_pattern "$file" "$pattern"; then
            return 0  # File is in scope
        fi
    done
    
    return 1  # File is not in scope
}

check_dry_principle() {
    local new_files=("$@")
    local violations=()
    
    if [ ${#new_files[@]} -eq 0 ]; then
        return 0
    fi
    
    echo -e "${BLUE}🔍 Checking DRY principle for new files...${NC}"
    
    for new_file in "${new_files[@]}"; do
        local filename=$(basename "$new_file")
        local dirname=$(dirname "$new_file")
        
        # Skip common files that are expected to be duplicated
        if [[ "$filename" =~ ^(README\.md|index\.(js|ts|html)|package\.json|\.gitignore|Dockerfile)$ ]]; then
            continue
        fi
        
        # Search for similar filenames in the repository
        local similar_files=$(find . -type f -name "*${filename%.*}*" -not -path "./.git/*" -not -path "$new_file" 2>/dev/null | head -5)
        
        if [ -n "$similar_files" ]; then
            violations+=("$new_file")
            echo -e "${YELLOW}⚠️  Potential DRY violation: $new_file${NC}"
            echo -e "   Similar files found:"
            while IFS= read -r similar; do
                echo -e "   📁 $similar"
            done <<< "$similar_files"
            echo
        fi
    done
    
    if [ ${#violations[@]} -gt 0 ]; then
        return 1
    fi
    
    return 0
}

get_scope_expansion_guidance() {
    local agent="$1"
    local out_of_scope_files=("${@:2}")
    
    echo -e "${BLUE}📋 SCOPE EXPANSION GUIDANCE:${NC}"
    echo
    echo -e "${YELLOW}Current agent: $agent${NC}"
    echo -e "${YELLOW}Files outside scope: ${#out_of_scope_files[@]}${NC}"
    echo
    echo "To request scope expansion, use one of these approaches:"
    echo
    echo "1. 🎯 Agent Coordination Request:"
    echo "   Create GitHub issue with title: \"Scope Expansion Request: $agent\""
    echo "   Include:"
    echo "   - List of specific files needed"
    echo "   - Justification for access"
    echo "   - Duration of access needed"
    echo
    echo "2. 🤝 Cross-Agent Collaboration:"
    echo "   If files belong to another agent's domain:"
    for file in "${out_of_scope_files[@]}"; do
        local suggested_agent=""
        case "$file" in
            app/*|database/*|routes/*)
                suggested_agent="laravel-dev"
                ;;
            src/components/*|src/hooks/*)
                suggested_agent="react-dev or svelte-dev"
                ;;
            .github/workflows/*|infrastructure/*)
                suggested_agent="devops"
                ;;
            docs/*|*.md)
                suggested_agent="docs-orchestrator"
                ;;
            agentic-development/protocols/*)
                suggested_agent="vibe-coder"
                ;;
        esac
        if [ -n "$suggested_agent" ]; then
            echo "   - $file → Consider coordinating with: $suggested_agent"
        fi
    done
    echo
    echo "3. 🚨 Emergency Override (monitored):"
    echo "   git commit -m 'emergency-scope-bypass: [reason] your message'"
    echo
    echo "4. ✅ Manual Verification (case sensitive):"
    echo "   git commit -m 'scope-verified: confirmed file access justified - [description]'"
    echo "   git commit -m 'SCOPE-VERIFIED: confirmed file access justified - [description]'"
    echo
}

# Main validation logic
main() {
    local agent=$(detect_agent_from_branch)
    
    if [ -z "$agent" ]; then
        echo -e "${YELLOW}⚠️  Warning: Could not detect agent from branch name${NC}"
        echo -e "   Branch pattern should be: agent-name/type/description"
        echo -e "   Current branch: $(git branch --show-current)"
        echo -e "   Skipping scope protection validation"
        exit 0
    fi
    
    local scope_patterns=$(get_agent_scope_patterns "$agent")
    
    if [ -z "$scope_patterns" ]; then
        echo -e "${YELLOW}⚠️  Warning: Unknown agent '$agent' - no scope patterns defined${NC}"
        echo -e "   Skipping scope protection validation"
        exit 0
    fi
    
    echo -e "${BLUE}🛡️  Agent Scope Protection Check${NC}"
    echo -e "${GREEN}Agent: $agent${NC}"
    echo -e "${GREEN}Scope patterns: $scope_patterns${NC}"
    echo
    
    # Get staged files
    local staged_files=$(git diff --cached --name-only --diff-filter=AM 2>/dev/null || true)
    local new_files=$(git diff --cached --name-only --diff-filter=A 2>/dev/null || true)
    
    if [ -z "$staged_files" ]; then
        echo -e "${GREEN}✅ No files to validate${NC}"
        exit 0
    fi
    
    local out_of_scope_files=()
    local violations=()
    
    # Check each staged file against agent scope
    while IFS= read -r file; do
        if [ -n "$file" ]; then
            if ! check_file_in_agent_scope "$file" "$agent" "$scope_patterns"; then
                out_of_scope_files+=("$file")
                violations+=("Agent '$agent' attempting to modify file outside scope: $file")
            fi
        fi
    done <<< "$staged_files"
    
    # Check DRY principle for new files
    local dry_violation=false
    if [ -n "$new_files" ]; then
        local new_files_array=()
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                new_files_array+=("$file")
            fi
        done <<< "$new_files"
        
        if [ ${#new_files_array[@]} -gt 0 ]; then
            if ! check_dry_principle "${new_files_array[@]}"; then
                dry_violation=true
            fi
        fi
    fi
    
    # Report violations
    if [ ${#violations[@]} -gt 0 ] || [ "$dry_violation" = true ]; then
        echo -e "${RED}❌ SCOPE PROTECTION: Violations detected${NC}"
        echo
        
        if [ ${#violations[@]} -gt 0 ]; then
            echo -e "${RED}SCOPE VIOLATIONS:${NC}"
            for violation in "${violations[@]}"; do
                echo -e "  🚨 $violation"
            done
            echo
            
            get_scope_expansion_guidance "$agent" "${out_of_scope_files[@]}"
        fi
        
        if [ "$dry_violation" = true ]; then
            echo -e "${RED}DRY PRINCIPLE VIOLATIONS:${NC}"
            echo -e "  💡 Consider reusing existing functionality instead of creating new files"
            echo -e "  📝 If new files are necessary, ensure they serve a unique purpose"
            echo -e "  🔍 Search the codebase thoroughly before creating similar functionality"
            echo
            echo -e "${BLUE}DRY RESOLUTION OPTIONS:${NC}"
            echo "  1. Reuse existing similar files/functionality"
            echo "  2. Extend existing files instead of creating new ones"
            echo "  3. If truly necessary, commit with: 'DRY-VERIFIED: [justification] - description'"
            echo
        fi
        
        echo -e "${BLUE}📖 See: agentic-development/protocols/file-scope-management.md${NC}"
        echo -e "${BLUE}🔍 For questions: Create GitHub issue with 'scope-protection' label${NC}"
        echo
        exit 1
    fi
    
    echo -e "${GREEN}✅ Scope protection validation passed${NC}"
    echo -e "${GREEN}✅ All ${#staged_files[@]} files are within agent scope${NC}"
    
    if [ -n "$new_files" ]; then
        local new_files_count=$(echo "$new_files" | wc -l)
        echo -e "${GREEN}✅ DRY principle check passed for $new_files_count new files${NC}"
    fi
    
    exit 0
}

# Run main function
main "$@"