---
allowed-tools: Bash, Read, Task
description: Check comments on PRs/issues and respond appropriately based on agent role
argument-hint: PR<number>|I<number> [PR<number>|I<number>...]
---

# Respond to Comments on PRs and Issues

Automatically check for comments on specified PRs and issues, then respond appropriately based on agent role.

This command eliminates the manual overhead of checking for comments across multiple PRs and issues.

## Arguments Provided
`$ARGUMENTS`

## Current Context
Agent: !`echo $USER`
Repository: !`git remote get-url origin | sed 's/.*\///' | sed 's/\.git//'`
Current branch: !`git branch --show-current`

## Parsing Arguments

I'll parse the provided arguments to extract PR and issue numbers:
- Format: PR324, I325, or multiple items like "PR324 I325"
- Case-insensitive (pr324, PR324, Pr324 all work)
- Can handle multiple items in one command

## Comment Standards Reference
@agentic-development/protocols/github-comment-standards.md

## Agent Roles

### Orchestrator Agents
- docs-orchestrator
- devops
- mobile-dev
- infra-engineer

**Response Style**: Encourage progress, provide guidance, coordinate between agents

### Executor Agents  
- vibe-coder
- laravel-dev
- react-dev
- ui-ux-designer

**Response Style**: Address feedback, report status, clarify implementation details

## Process

1. Parse arguments to extract PR/issue numbers
2. Check if gh CLI is available
3. Fetch comments for each PR/issue
4. Determine agent role (orchestrator vs executor)
5. Generate appropriate responses
6. Format responses using GitHub comment standards

## Implementation Steps

Let me process your request to check and respond to comments...

### Step 1: Parse Arguments

First, I'll parse the arguments to extract PR and issue numbers:

```bash
# Parse arguments to extract PR/issue numbers
args="$ARGUMENTS"
items=()

# Convert to uppercase and split by spaces
args_upper=$(echo "$args" | tr '[:lower:]' '[:upper:]')
IFS=' ' read -ra ADDR <<< "$args_upper"

for item in "${ADDR[@]}"; do
    if [[ $item =~ ^PR([0-9]+)$ ]]; then
        items+=("PR:${BASH_REMATCH[1]}")
    elif [[ $item =~ ^I([0-9]+)$ ]]; then
        items+=("ISSUE:${BASH_REMATCH[1]}")
    fi
done

echo "Parsed items: ${items[@]}"
```

### Step 2: Check Each Item for Comments

I'll check comments on each PR/issue:

```bash
# Get current agent name
agent_name=$(git config user.name || echo "unknown-agent")

# Determine agent role
orchestrator_agents=("docs-orchestrator" "devops" "mobile-dev" "infra-engineer")
is_orchestrator=false
for oa in "${orchestrator_agents[@]}"; do
    if [[ "$agent_name" == "$oa" ]]; then
        is_orchestrator=true
        break
    fi
done

# Process each item
for item in "${items[@]}"; do
    IFS=':' read -r type number <<< "$item"
    
    echo "Checking $type #$number for recent comments..."
    
    if [[ "$type" == "PR" ]]; then
        # Get PR comments
        recent_comments=$(gh pr view "$number" --json comments --jq '.comments[-3:] | .[] | "\(.createdAt) by \(.author.login): \(.body)"' 2>/dev/null || echo "")
    else
        # Get issue comments  
        recent_comments=$(gh issue view "$number" --json comments --jq '.comments[-3:] | .[] | "\(.createdAt) by \(.author.login): \(.body)"' 2>/dev/null || echo "")
    fi
    
    if [[ -n "$recent_comments" ]]; then
        echo "Recent comments on $type #$number:"
        echo "$recent_comments"
        echo ""
        
        # Generate response based on role
        if [[ "$is_orchestrator" == "true" ]]; then
            echo "As an orchestrator agent, I should provide guidance and coordinate..."
        else
            echo "As an executor agent, I should address feedback and report status..."
        fi
    else
        echo "No recent comments found on $type #$number"
    fi
done
```

### Step 3: Generate Appropriate Responses

Based on the comments found and agent role, I'll help generate appropriate responses following the GitHub comment standards.