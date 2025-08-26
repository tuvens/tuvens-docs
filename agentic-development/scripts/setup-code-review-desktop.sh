#!/usr/bin/env bash
# File: setup-code-review-desktop.sh
# Purpose: Claude Desktop adapter for code review setup using iTerm2 MCP integration
# 
# This script implements comprehensive code review functionality with QA agent
# specialization, following DRY, KISS, TDD, and D/E principles.

set -euo pipefail

# Usage function
usage() {
    echo "Usage: $0 <agent> <#PR> [#issue] [--context=file]"
    echo ""
    echo "Claude Desktop adapter for /code-review automation"
    echo "Uses iTerm2 MCP integration and comprehensive QA analysis"
    echo ""
    echo "Arguments:"
    echo "  <agent>   - Target agent for the review (qa, vibe-coder, etc.)"
    echo "  <#PR>     - Pull request number (with or without # prefix)"
    echo "  [#issue]  - Optional associated issue number for requirements context"
    echo ""
    echo "Options:"
    echo "  --context=file  - Additional context file for complex reviews"
    echo "  --help, -h      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 qa 123                    # Review PR #123 with QA agent"
    echo "  $0 qa #145 #144             # Review PR #145 related to issue #144"
    echo "  $0 vibe-coder 99 --context=/tmp/review-notes.md"
    echo ""
    exit 1
}

# Check minimum arguments
if [[ $# -lt 2 ]]; then
    usage
fi

echo "🔍 Claude Desktop Code Review Setup"
echo "===================================="
echo ""

# Source shared functions to prevent code duplication
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/shared-functions.sh"

# Parse arguments
AGENT_NAME="$1"
PR_NUMBER="$2"
ISSUE_NUMBER=""
CONTEXT_FILE=""

# Clean up PR number (remove # if present)
PR_NUMBER=${PR_NUMBER#"#"}

# Validate PR number is numeric
if ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
    echo "❌ ERROR: Invalid PR number: $2"
    echo "   PR number must be numeric (with or without # prefix)"
    exit 1
fi

# Parse remaining arguments
shift 2
while [[ $# -gt 0 ]]; do
    case $1 in
        --context=*)
            CONTEXT_FILE="${1#*=}"
            shift
            ;;
        --help|-h)
            usage
            ;;
        \#*)
            # This is an issue number
            if [[ -z "$ISSUE_NUMBER" ]]; then
                ISSUE_NUMBER="${1#"#"}"
                # Validate issue number is numeric
                if ! [[ "$ISSUE_NUMBER" =~ ^[0-9]+$ ]]; then
                    echo "❌ ERROR: Invalid issue number: $1"
                    echo "   Issue number must be numeric"
                    exit 1
                fi
            else
                echo "⚠️  Warning: Multiple issue numbers provided, using first one: #$ISSUE_NUMBER"
            fi
            shift
            ;;
        [0-9]*)
            # This might be an issue number without #
            if [[ -z "$ISSUE_NUMBER" ]]; then
                ISSUE_NUMBER="$1"
            else
                echo "⚠️  Warning: Multiple issue numbers provided, using first one: #$ISSUE_NUMBER"
            fi
            shift
            ;;
        -*)
            echo "⚠️  Warning: Unknown option: $1"
            shift
            ;;
        *)
            # Check if it's a context file
            if [[ -f "$1" && -z "$CONTEXT_FILE" ]]; then
                CONTEXT_FILE="$1"
            else
                echo "⚠️  Warning: Unknown argument or file not found: $1"
            fi
            shift
            ;;
    esac
done

# Validate context file if provided
if [[ -n "$CONTEXT_FILE" && ! -f "$CONTEXT_FILE" ]]; then
    echo "❌ ERROR: Context file not found: $CONTEXT_FILE"
    exit 1
fi

echo "📋 Review Parameters:"
echo "   Agent: $AGENT_NAME"
echo "   PR: #$PR_NUMBER"
if [[ -n "$ISSUE_NUMBER" ]]; then
    echo "   Associated Issue: #$ISSUE_NUMBER"
fi
if [[ -n "$CONTEXT_FILE" ]]; then
    echo "   Context File: $CONTEXT_FILE"
fi
echo ""

# Step 1: Fetch and analyze PR data
echo "Step 1: Fetching PR information..."

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ ERROR: GitHub CLI (gh) is required but not found"
    echo "   Install with: brew install gh"
    exit 1
fi

# Verify we're in a git repository
if ! git rev-parse --is-inside-work-tree &> /dev/null; then
    echo "❌ ERROR: Not in a git repository"
    exit 1
fi

# Fetch PR information
echo "   Fetching PR #$PR_NUMBER details..."
PR_JSON=$(gh pr view "$PR_NUMBER" --json title,body,author,state,isDraft,mergeable,url,headRefName,baseRefName,additions,deletions,changedFiles)

if [[ -z "$PR_JSON" ]]; then
    echo "❌ ERROR: Could not fetch PR #$PR_NUMBER"
    echo "   Make sure the PR exists and you have access to this repository"
    exit 1
fi

# Extract PR details
PR_TITLE=$(echo "$PR_JSON" | jq -r '.title // "No Title"')
PR_BODY=$(echo "$PR_JSON" | jq -r '.body // "No Description"')
PR_AUTHOR=$(echo "$PR_JSON" | jq -r '.author.login // "Unknown"')
PR_STATE=$(echo "$PR_JSON" | jq -r '.state // "UNKNOWN"')
PR_IS_DRAFT=$(echo "$PR_JSON" | jq -r '.isDraft // false')
PR_MERGEABLE=$(echo "$PR_JSON" | jq -r '.mergeable // "UNKNOWN"')
PR_URL=$(echo "$PR_JSON" | jq -r '.url // ""')
HEAD_BRANCH=$(echo "$PR_JSON" | jq -r '.headRefName // "unknown"')
BASE_BRANCH=$(echo "$PR_JSON" | jq -r '.baseRefName // "unknown"')
ADDITIONS=$(echo "$PR_JSON" | jq -r '.additions // 0')
DELETIONS=$(echo "$PR_JSON" | jq -r '.deletions // 0')
CHANGED_FILES=$(echo "$PR_JSON" | jq -r '.changedFiles // 0')

echo "   ✅ PR #$PR_NUMBER: $PR_STATE"
echo "      Title: $PR_TITLE"
echo "      Author: $PR_AUTHOR"
echo "      Changes: +$ADDITIONS -$DELETIONS ($CHANGED_FILES files)"
echo "      Branch: $HEAD_BRANCH → $BASE_BRANCH"
if [[ "$PR_IS_DRAFT" == "true" ]]; then
    echo "      Status: DRAFT"
fi
echo ""

# Fetch PR comments and reviews
echo "   Fetching PR comments and reviews..."
PR_COMMENTS=$(gh pr view "$PR_NUMBER" --json comments --jq '.comments[] | "**@" + .author.login + "** (" + .createdAt + "):\n" + .body + "\n"')
PR_REVIEWS=$(gh pr view "$PR_NUMBER" --json reviews --jq '.reviews[] | "**@" + .author.login + "** (" + .state + " - " + .createdAt + "):\n" + (.body // "No comment") + "\n"')

# Step 2: Fetch associated issue information if provided
ISSUE_CONTENT=""
if [[ -n "$ISSUE_NUMBER" ]]; then
    echo "Step 2: Fetching associated issue information..."
    echo "   Fetching issue #$ISSUE_NUMBER details..."
    
    ISSUE_JSON=$(gh issue view "$ISSUE_NUMBER" --json title,body,state,author,url 2>/dev/null || echo "")
    
    if [[ -n "$ISSUE_JSON" ]]; then
        ISSUE_TITLE=$(echo "$ISSUE_JSON" | jq -r '.title // "No Title"')
        ISSUE_BODY=$(echo "$ISSUE_JSON" | jq -r '.body // "No Description"')
        ISSUE_STATE=$(echo "$ISSUE_JSON" | jq -r '.state // "UNKNOWN"')
        ISSUE_AUTHOR=$(echo "$ISSUE_JSON" | jq -r '.author.login // "Unknown"')
        ISSUE_URL=$(echo "$ISSUE_JSON" | jq -r '.url // ""')
        
        echo "   ✅ Issue #$ISSUE_NUMBER: $ISSUE_STATE"
        echo "      Title: $ISSUE_TITLE"
        echo "      Author: $ISSUE_AUTHOR"
        
        ISSUE_CONTENT="## Associated Issue Context

### Issue #$ISSUE_NUMBER: $ISSUE_TITLE
**Author**: $ISSUE_AUTHOR  
**State**: $ISSUE_STATE  
**URL**: $ISSUE_URL

#### Original Requirements:
$ISSUE_BODY
"
    else
        echo "   ⚠️  Warning: Could not fetch issue #$ISSUE_NUMBER"
        ISSUE_CONTENT="## Associated Issue Context

Issue #$ISSUE_NUMBER was referenced but could not be fetched.
Please verify the issue exists and you have access to it."
    fi
    echo ""
fi

# Step 3: Load additional context if provided
ADDITIONAL_CONTEXT=""
if [[ -n "$CONTEXT_FILE" ]]; then
    echo "Step 3: Loading additional context..."
    echo "   Loading context from: $CONTEXT_FILE"
    ADDITIONAL_CONTEXT=$(cat "$CONTEXT_FILE")
    echo "   ✅ Context loaded ($(wc -l < "$CONTEXT_FILE") lines)"
    echo ""
fi

# Step 4: Create comprehensive GitHub issue for code review session
echo "Step 4: Creating comprehensive code review issue..."

# Generate descriptive task title
TASK_TITLE="Code Review: PR #$PR_NUMBER - $PR_TITLE"

# Create comprehensive task description
TASK_DESCRIPTION="Conduct comprehensive technical code review of PR #$PR_NUMBER using QA agent specialization.

**Review Focus Areas:**
1. **Requirements Alignment**: Verify implementation matches original requirements
2. **Technical Quality**: Enforce DRY, KISS, TDD, R/R, C/C principles
3. **D/E Principle**: Demonstrate claims with evidence, not explanations
4. **Test Coverage**: Validate comprehensive test coverage
5. **File/Folder Structure**: R/R validation of organization and structure
6. **Pattern Consistency**: C/C validation of project and framework conventions
7. **Code Standards**: Review for style, security, and best practices
8. **Automated Comments**: Address all existing review comments systematically

**QA Agent Responsibilities:**
- Lead technical quality assurance process
- Enforce DRY, KISS, TDD, R/R, C/C principle adherence with evidence
- Validate file/folder structure organization (R/R)
- Ensure pattern consistency and convention compliance (C/C)
- Validate test coverage and functionality
- Provide comprehensive review addressing all participants
- Break long reviews into manageable comment segments

**Expected Deliverables:**
- Comprehensive technical review following all principles
- Evidence-based validation of functionality and tests
- Systematic response to all automated and human review comments
- Actionable recommendations with specific file/line references"

# Create temporary file for issue body
TEMP_BODY_FILE="/tmp/code-review-issue-body-$$"

cat > "$TEMP_BODY_FILE" << EOF
# $TASK_TITLE

**Agent**: $AGENT_NAME  
**Type**: Code Review  
**Generated**: $(date '+%Y-%m-%d %H:%M:%S')

## Pull Request Analysis

### PR #$PR_NUMBER: $PR_TITLE
**Author**: $PR_AUTHOR  
**State**: $PR_STATE  
**URL**: $PR_URL  
**Branch**: $HEAD_BRANCH → $BASE_BRANCH  
**Changes**: +$ADDITIONS -$DELETIONS ($CHANGED_FILES files)
$(if [[ "$PR_IS_DRAFT" == "true" ]]; then echo "**Status**: DRAFT"; fi)
$(if [[ "$PR_MERGEABLE" != "MERGEABLE" && "$PR_MERGEABLE" != "null" ]]; then echo "**Mergeable**: $PR_MERGEABLE"; fi)

#### PR Description:
$PR_BODY

EOF

# Add existing comments if any
if [[ -n "$PR_COMMENTS" ]]; then
    cat >> "$TEMP_BODY_FILE" << EOF
#### Existing Comments:
$PR_COMMENTS

EOF
fi

# Add existing reviews if any
if [[ -n "$PR_REVIEWS" ]]; then
    cat >> "$TEMP_BODY_FILE" << EOF
#### Existing Reviews:
$PR_REVIEWS

EOF
fi

# Add issue context if provided
if [[ -n "$ISSUE_CONTENT" ]]; then
    cat >> "$TEMP_BODY_FILE" << EOF
$ISSUE_CONTENT

EOF
fi

# Add additional context if provided
if [[ -n "$ADDITIONAL_CONTEXT" ]]; then
    cat >> "$TEMP_BODY_FILE" << EOF
## Additional Context
$ADDITIONAL_CONTEXT

EOF
fi

# Add comprehensive task description and standards
cat >> "$TEMP_BODY_FILE" << EOF
## Task Description
$TASK_DESCRIPTION

## Quality Assurance Standards

### D/E Principle (Demonstration-over-Explanation)
**Definition**: Agents must PROVE their claims with evidence, not just explain them.

**Requirements**:
- Show actual proof of completeness (test results, coverage reports, working demos)
- Provide evidence before making claims about functionality
- Demonstrate features work with executable examples
- Document with screenshots, logs, or test output as proof
- NO unsubstantiated claims - every assertion must be backed by evidence

### Technical Review Checklist

#### Code Quality (DRY, KISS, TDD)
- [ ] **DRY**: No code duplication identified
- [ ] **KISS**: Simple, readable solutions preferred over complex ones
- [ ] **TDD**: Tests exist for all new functionality
- [ ] Error handling implemented appropriately
- [ ] Performance considerations addressed
- [ ] Security best practices followed

#### Test Coverage & Validation
- [ ] All tests pass (provide evidence)
- [ ] Coverage reports show adequate coverage (provide metrics)
- [ ] Edge cases tested and documented
- [ ] Integration tests validate cross-component behavior
- [ ] Manual testing completed for UI/UX changes

#### Anti-Over-Engineering Safeguards
- [ ] Solution complexity justified by requirements
- [ ] No unnecessary abstractions or bypasses
- [ ] Proper scope boundaries maintained
- [ ] File organization follows project conventions
- [ ] Directory structure appropriate

#### Review Response Protocol
- [ ] Address every automated review comment specifically
- [ ] Respond to all human reviewers systematically
- [ ] Break long reviews into manageable comment segments
- [ ] Reference specific files and line numbers
- [ ] Provide actionable recommendations with evidence

## Success Criteria
- [ ] Comprehensive technical review completed
- [ ] All review comments addressed with evidence
- [ ] D/E principle enforced throughout review
- [ ] Test coverage validated with proof
- [ ] Quality standards enforced
- [ ] Review posted addressing all participants

## Implementation Notes
- Use GitHub CLI to fetch PR diff and file changes
- Analyze each changed file systematically
- Run tests and capture output as evidence
- Review all existing comments and provide specific responses
- Document findings with file:line references
- Break review into multiple comments if needed to avoid field limits

---
*Generated with Claude Code automation*
EOF

# Create GitHub issue
echo "   Creating comprehensive review issue..."
ISSUE_URL=$(gh issue create \
    --title "$TASK_TITLE" \
    --body-file "$TEMP_BODY_FILE" \
    --assignee "@me" \
    --label "code-review,$AGENT_NAME,pr-$PR_NUMBER")

GITHUB_ISSUE=$(echo "$ISSUE_URL" | grep -o '[0-9]\+$')
rm -f "$TEMP_BODY_FILE"
echo "   ✅ Created GitHub issue #$GITHUB_ISSUE"
echo "      URL: https://github.com/$(gh repo view --json nameWithOwner -q .nameWithOwner)/issues/$GITHUB_ISSUE"
echo ""

# Step 5: Generate agent prompt and setup worktree
echo "Step 5: Setting up agent environment..."

# Generate branch name for code review
BRANCH_NAME=$(calculate_branch_name "$AGENT_NAME" "code-review-pr-$PR_NUMBER")
echo "   Generated branch: $BRANCH_NAME"

# Use shared functions to create worktree
create_agent_worktree "$BRANCH_NAME" "Code review for PR #$PR_NUMBER"

# Get worktree path
WORKTREE_PATH=$(get_worktree_path "$BRANCH_NAME")

if [[ -z "$WORKTREE_PATH" ]]; then
    echo "❌ ERROR: Failed to create or locate worktree for $BRANCH_NAME"
    exit 1
fi

echo "   ✅ Worktree created: $(make_path_portable "$WORKTREE_PATH")"

# Step 6: Generate comprehensive agent prompt
echo "Step 6: Generating QA agent prompt..."

PROMPT_FILE="$SCRIPT_DIR/qa-code-review-prompt.txt"

cat > "$PROMPT_FILE" << EOF
Context Loading:
- Load: .claude/agents/qa.md (if exists, fallback to devops.md)
- Load: Implementation reports and workflow documentation
- Load: CLAUDE.md (critical branch targeting and safety rules)
- Load: Quality assurance standards and D/E principle documentation

🚨 CRITICAL: Read GitHub Issue #$GITHUB_ISSUE for complete code review context
Use: \`gh issue view $GITHUB_ISSUE\` to get the full PR analysis, requirements, and review standards.

GitHub Issue: #$GITHUB_ISSUE
Task: Code Review - PR #$PR_NUMBER ($PR_TITLE)

Working Directory: $(make_path_portable "$WORKTREE_PATH")
Branch: $BRANCH_NAME

🔵 MANDATORY: GitHub Comment Standards Protocol
ALL GitHub issue and PR comments MUST use this format:
\`\`\`markdown
👤 **Identity**: $AGENT_NAME
🎯 **Addressing**: [@$PR_AUTHOR, @all-reviewers, or specific participants]

## [Comment Subject]
[Your comment content]

**Status**: [status]
**Next Action**: [next-action]
**Timeline**: [timeline]
\`\`\`

Reference: agentic-development/protocols/github-comment-standards.md

📋 CODE REVIEW PROTOCOL:

## 1. Requirements Review & Analysis
\`\`\`bash
# Read the GitHub issue for complete context
gh issue view $GITHUB_ISSUE

# Fetch PR details and changes
gh pr view $PR_NUMBER
gh pr diff $PR_NUMBER
\`\`\`
$(if [[ -n "$ISSUE_NUMBER" ]]; then echo "
# Review original requirements from associated issue
gh issue view $ISSUE_NUMBER"; fi)

## 2. Comprehensive PR Analysis
\`\`\`bash
# Get all PR comments and reviews
gh pr view $PR_NUMBER --json comments,reviews

# Analyze changed files
gh pr view $PR_NUMBER --json files
gh pr diff $PR_NUMBER --name-only
\`\`\`

## 3. D/E Principle Enforcement (CRITICAL)
**You MUST demonstrate every claim with evidence:**
- Run tests and show output
- Generate coverage reports
- Execute code and capture results
- Take screenshots of working features
- NEVER make claims without proof

## 4. Technical Quality Review
Follow DRY, KISS, TDD, R/R, C/C principles:
- **DRY**: Identify and document code duplication
- **KISS**: Flag unnecessary complexity
- **TDD**: Verify test coverage exists and passes
- **R/R**: Validate file/folder structure organization, eliminate loose files and redundant directories
- **C/C**: Ensure code follows project and framework conventions, no custom patterns invented

## 5. Test Validation & Evidence
\`\`\`bash
# Use TDD framework when available (PR #324)
npm run test:tdd                    # Complete TDD test suite
npm run test:tdd:unit              # Unit tests only
npm run test:tdd:integration       # Integration tests only
./tests/demonstrate-coverage.sh    # Coverage proof with evidence

# Fallback to standard testing
npm test  # or appropriate test command
pytest    # or appropriate test command

# Generate coverage report
npm run test:coverage  # or appropriate coverage command

# Document results with evidence
\`\`\`

## 6. Systematic Review Response
Address EVERY comment/review systematically:
- Reference specific files and line numbers
- Provide evidence for your assessments
- Break long reviews into multiple comments
- Use GitHub comment standards format

## 7. Anti-Over-Engineering Safeguards
Prevent:
- Frivolous complexity
- Unnecessary abstraction bypasses
- Improper scope violations
- Duplicate files
- Wrong directory structures

Success Criteria:
✅ Complete technical review with evidence
✅ All automated comments addressed
✅ D/E principle enforced throughout
✅ Test coverage validated with proof
✅ Quality standards documented
✅ Comprehensive review posted

IMPORTANT: Start by reading the GitHub issue (#$GITHUB_ISSUE) with \`gh issue view $GITHUB_ISSUE\` to understand the complete PR context, existing comments, and review requirements before proceeding with analysis.

Your role is QA Agent - you are responsible for ALL aspects of technical quality assurance. Lead with evidence, not explanations.
EOF

echo "   ✅ Generated QA agent prompt: qa-code-review-prompt.txt"
echo ""

# Change to worktree directory
cd "$WORKTREE_PATH" || {
    echo "❌ ERROR: Failed to change to worktree directory: $WORKTREE_PATH"
    exit 1
}

# Step 7: Launch Claude Code with comprehensive context
echo "Step 7: Launching Claude Code with QA context..."
echo ""
echo "📋 Code Review Context:"
echo "======================="
echo "• GitHub Issue: #$GITHUB_ISSUE"
echo "• Pull Request: #$PR_NUMBER"
echo "• Worktree: $(make_path_portable "$WORKTREE_PATH")"
echo "• Branch: $BRANCH_NAME"
echo "• Agent: $AGENT_NAME (QA Specialization)"
if [[ -n "$ISSUE_NUMBER" ]]; then
    echo "• Associated Issue: #$ISSUE_NUMBER"
fi
echo ""

# Display the full agent prompt
echo "🎯 COPY THIS PROMPT FOR CLAUDE CODE:"
echo "====================================="
cat "$PROMPT_FILE"
echo ""
echo "====================================="
echo ""

# Launch Claude Code
echo "🚀 Launching Claude Code..."
echo "When Claude Code opens, copy and paste the prompt above."
echo ""

# Check for review safeguards before enabling dangerous mode
CLAUDE_COMMAND="claude"
if check_pr_review_safeguards "$BRANCH_NAME"; then
    echo "✅ No active reviews detected, enabling dangerous mode for faster development"
    CLAUDE_COMMAND="claude --dangerously-skip-permissions"
else
    echo "🔒 Reviews detected, using standard Claude mode for safety"
fi

# Verify we can launch claude before exec
if ! command -v claude &> /dev/null; then
    echo "❌ ERROR: 'claude' command not found. Please install Claude Code CLI."
    echo "Current directory: $(pwd)"
    echo "Prompt file location: $PROMPT_FILE"
    exit 1
fi

echo "Launching: $CLAUDE_COMMAND"
echo ""

# Launch claude in the worktree with the QA context ready
exec $CLAUDE_COMMAND