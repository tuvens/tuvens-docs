---
allowed-tools: Bash, Write, Read, Grep
description: Push changes following Tuvens branching strategy with explicit branch protection
argument-hint: [commit-message]
---

# Push Changes Following Branching Strategy

I'll help you push changes following the Tuvens branching strategy to ensure we never push to the wrong branch.

## Commit Message
`$ARGUMENTS`

## Current Repository State
- Repository: !`git remote get-url origin | sed 's/.*\///' | sed 's/\.git//'`
- Current branch: !`git branch --show-current`
- Working directory: !`pwd`

## CRITICAL: Load Branching Strategy

**⚠️ MANDATORY**: I MUST load and follow the branching strategy before any push operation.

@agentic-development/workflows/branching-strategy.md

This document contains the STRICT forward-only merge policy that MUST be followed with NO exceptions. The branching rules loaded above are the authoritative source and MUST be followed.

## Push Process

I'll analyze the current branch and determine the appropriate push strategy:

1. **Verify Branching Compliance**: Check current branch against the loaded branching strategy rules
2. **Apply Forward-Only Policy**: Enforce the STRICT merge direction from the branching strategy
3. **Determine Safe Push Action**: Based on current branch and the strategy rules
4. **Stage and Commit**: Add changes with meaningful commit message  
5. **Execute Push**: Follow the appropriate path per the branching strategy
6. **Create PR if Required**: Follow PR requirements from the branching strategy

## Safety Checks

Before pushing, I'll verify against the loaded branching strategy:
- Current branch complies with the forward-only merge policy
- Not violating any protected branch rules
- Following the correct merge flow direction
- Commit message is meaningful
- All changes are intentional  
- Branch naming follows conventions from the strategy

Let me analyze the current situation and execute the appropriate push strategy.