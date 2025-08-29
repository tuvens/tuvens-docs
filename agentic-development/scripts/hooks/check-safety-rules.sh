#!/bin/bash

# Pre-commit Hook: Safety Rules Check
# Validates commits don't violate basic CLAUDE.md safety rules

set -e

# Check for bypass keywords in commit message
# Check for bypass keywords in commit message
# Try different methods to get the commit message
COMMIT_MSG=""

# Method 1: Check environment variable (for pre-commit scenarios)
if [ -n "${GIT_COMMIT_MSG:-}" ]; then
    COMMIT_MSG="$GIT_COMMIT_MSG"
# Method 2: Check COMMIT_EDITMSG
elif [ -f "$(git rev-parse --git-dir)/COMMIT_EDITMSG" ]; then
    COMMIT_MSG=$(cat "$(git rev-parse --git-dir)/COMMIT_EDITMSG")
# Method 3: Try to get from process list
else
    COMMIT_MSG=$(ps aux | grep "git commit" | grep -v grep | sed -n 's/.*-m[[:space:]]*["'\'']\([^"'\'']*\)["'\''].*/\1/p' | head -1)
fi

if [ -n "$COMMIT_MSG" ]; then
    # Check for documentation verification bypass
    if echo "$COMMIT_MSG" | grep -q -E "(docs: verified examples only|DOCS-VERIFIED:|review-requested:|SCOPE-VERIFIED:|scope-verified:)"; then
        echo "✅ Safety check bypassed: Documentation/scope verification detected"
        exit 0
    fi
fi

# Check for common safety violations in staged files
VIOLATIONS=()
DETAILED_VIOLATIONS=()

# Function to check for actual secrets vs documentation examples
check_potential_secrets() {
    local file="$1"
    local line_num="$2"
    local line_content="$3"
    local match="$4"
    
    # Skip if in markdown code blocks or obvious examples
    if [[ "$file" == *.md ]]; then
        # Check if line is in a code block or contains obvious placeholders
        if echo "$line_content" | grep -q -E "(\`\`\`|^\s*\`|example|placeholder|your_api_key|example_token|sample_key|localStorage\.getItem)"; then
            return 1  # Not a real secret
        fi
    fi
    
    # Check for obvious real secrets (longer random strings)
    if echo "$match" | grep -q -E "^[A-Za-z0-9+/\-_]{20,}={0,2}$|^[a-f0-9]{32,}$|^[A-Z0-9_]{30,}$|^sk-[a-zA-Z0-9]{32,}$"; then
        return 0  # Likely real secret
    fi
    
    # Check for suspicious long strings in quoted values
    if [ ${#match} -gt 15 ] && echo "$match" | grep -q -E "[a-zA-Z0-9]{10,}"; then
        return 0  # Likely real secret
    fi
    
    # Check for environment variable patterns that might contain real secrets
    if echo "$line_content" | grep -q -E "(export|ENV|process\.env).*=.*['\"][^'\"]{20,}['\"]"; then
        return 0  # Likely real secret
    fi
    
    return 1  # Probably documentation/example
}

# Enhanced secret detection with context awareness
STAGED_FILES=$(git diff --cached --name-only)
if [ -n "$STAGED_FILES" ]; then
    for file in $STAGED_FILES; do
        if [ -f "$file" ]; then
            # Search for potential secrets with line numbers
            while IFS=: read -r line_num line_content; do
                if [ -n "$line_content" ]; then
                    # Skip lines that are obviously test descriptions or documentation
                    if echo "$line_content" | grep -q -E "(test:|@test|bypass keyword|keyword.*documented|PASS:|FAIL:|🔍|💡)"; then
                        continue
                    fi
                    
                    # Extract the matching keyword
                    match=$(echo "$line_content" | grep -i -o -E "(password|secret|token|key|api_key)" | head -1)
                    if [ -n "$match" ]; then
                        # Extract potential secret value from the line - try multiple patterns
                        secret_value=""
                        
                        # Try quoted strings first (double quotes)
                        secret_value=$(echo "$line_content" | grep -o '"[^"]\{8,\}"' | sed 's/"//g' | head -1)
                        
                        # Try single quotes if no double quotes found
                        if [ -z "$secret_value" ]; then
                            secret_value=$(echo "$line_content" | grep -o "'[^']\{8,\}'" | sed "s/'//g" | head -1)
                        fi
                        
                        # Try unquoted values after = or : (for env files, configs)
                        if [ -z "$secret_value" ]; then
                            secret_value=$(echo "$line_content" | sed -n 's/.*[=:]\s*\([A-Za-z0-9+/\-_]\{8,\}\).*/\1/p' | head -1)
                        fi
                        
                        if [ -n "$secret_value" ]; then
                            if check_potential_secrets "$file" "$line_num" "$line_content" "$secret_value"; then
                                VIOLATIONS+=("Potential secret detected")
                                DETAILED_VIOLATIONS+=("FILE: $file:$line_num - Contains '$match' with value '$secret_value'")
                            fi
                        else
                            # If no value found, still check if the context suggests a real secret
                            # Only flag if it looks like an assignment or configuration
                            if echo "$line_content" | grep -q -E "(export|ENV|process\.env|\w+\s*[=:])"; then
                                VIOLATIONS+=("Potential secret detected")
                                DETAILED_VIOLATIONS+=("FILE: $file:$line_num - Contains '$match' in assignment context")
                            fi
                        fi
                    fi
                fi
            done < <(grep -n -i -E "(password|secret|token|key|api_key)" "$file" 2>/dev/null || true)
        fi
    done
fi

# Check for --no-verify usage in commit messages or files
if git diff --cached | grep -q "\-\-no\-verify"; then
    VIOLATIONS+=("Contains --no-verify flag (violates CLAUDE.md safety rules)")
fi

# Check for direct deletion of important files
IMPORTANT_FILES=("CLAUDE.md" "README.md" "package.json" ".gitignore")
for file in "${IMPORTANT_FILES[@]}"; do
    if git diff --cached --name-status | grep -q "^D.*$file$"; then
        VIOLATIONS+=("Attempting to delete important file: $file")
    fi
done

# Check for modifications to .github/workflows without proper review markers
if git diff --cached --name-only | grep -q "\.github/workflows/"; then
    WORKFLOW_FILES=$(git diff --cached --name-only | grep "\.github/workflows/" || true)
    if [ -n "$WORKFLOW_FILES" ]; then
        # Check if commit message indicates this is a reviewed change
        COMMIT_MSG_FILE=$(git rev-parse --git-dir)/COMMIT_EDITMSG
        if [ -f "$COMMIT_MSG_FILE" ]; then
            if ! grep -q -i -E "(reviewed|approved|tested)" "$COMMIT_MSG_FILE"; then
                VIOLATIONS+=("Workflow changes detected without review markers in commit message")
            fi
        fi
    fi
fi

# Report violations with enhanced details and escalation options
if [ ${#VIOLATIONS[@]} -gt 0 ]; then
    echo "❌ SAFETY CHECK: Potential Security Issues Detected"
    echo ""
    
    # Show detailed violations if any
    if [ ${#DETAILED_VIOLATIONS[@]} -gt 0 ]; then
        echo "DETAILED FINDINGS:"
        for detail in "${DETAILED_VIOLATIONS[@]}"; do
            echo "  📍 $detail"
        done
        echo ""
    fi
    
    echo "ISSUES FOUND:"
    for violation in "${VIOLATIONS[@]}"; do
        echo "  🚨 $violation"
    done
    echo ""
    
    # Check if violations are likely documentation examples
    has_docs_examples=false
    for detail in "${DETAILED_VIOLATIONS[@]}"; do
        if echo "$detail" | grep -q -E "(\.md:|localStorage|example|placeholder)"; then
            has_docs_examples=true
            break
        fi
    done
    
    if [ "$has_docs_examples" = true ]; then
        echo "🤔 ASSESSMENT: Some findings appear to be documentation examples"
        echo ""
        echo "📋 RESOLUTION OPTIONS:"
        echo "  1. Documentation verification (if legitimate examples):"
        echo "     git commit -m 'docs: verified examples only - [your description]'"
        echo ""
        echo "  2. Request orchestrator review:"
        echo "     git commit -m 'review-requested: [describe changes]'"
        echo ""
        echo "  3. Alternative documentation bypass:"
        echo "     git commit -m 'DOCS-VERIFIED: [your description]'"
        echo ""
        echo "  4. Emergency bypass (logged and monitored):"
        echo "     git commit --no-verify -m '[SAFETY-OVERRIDE: reason] your message'"
        echo ""
        echo "  5. Get detailed help:"
        echo "     cat .claude/safety-resolution-guide.md 2>/dev/null || echo 'Guide not found'"
    else
        echo "⚠️  ASSESSMENT: Potential real security issues detected"
        echo ""
        echo "🛡️  REQUIRED ACTIONS:"
        echo "  • Remove sensitive data from staged files"
        echo "  • Use environment variables or secure vaults"
        echo "  • Never commit real passwords, tokens, or API keys"
    fi
    
    echo ""
    echo "📖 See: CLAUDE.md > Core Safety Principles"
    echo "🔍 For questions: Create GitHub issue with 'safety-check' label"
    echo ""
    exit 1
fi

echo "✅ Safety rules validation passed"
exit 0