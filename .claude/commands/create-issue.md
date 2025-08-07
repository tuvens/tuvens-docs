---
allowed-tools: Bash, Write, Read
description: Create GitHub issue with proper agent workflow template and lifecycle management
argument-hint: [creating-agent] [assigned-agent] [task-title] [repository]
---

# Create Agent Task Issue

Create a properly formatted GitHub issue for agent coordination with complete workflow instructions and lifecycle management.

## Arguments Provided
`$ARGUMENTS`

## Current Context
Repository: !`git remote get-url origin | sed 's/.*\///' | sed 's/\.git//'`
Current branch: !`git branch --show-current`
Working directory: !`pwd`

## Agent Workflow Template
@agentic-development/.temp/updated-project-instructions.md

## Inter-Agent Communication Template
@agentic-development/workflows/worktree-organization.md

## Issue Creation Process

I'll create a GitHub issue with the following structure:

### Title Format
`[AGENT-TASK] [Assigned Agent]: [Task Title]`

### Issue Template Structure
1. **Agent Assignment** - Clear ownership and authority
2. **Task Description** - Complete technical requirements  
3. **Implementation Details** - Specific technical steps
4. **Success Criteria** - Measurable deliverables
5. **Agent Workflow Instructions** - What to do when complete
6. **Acceptance Criteria** - Checklist for completion

### Agent Workflow Protocol

**For the ASSIGNED AGENT (doing the work):**
1. When task is complete, COMMENT on the issue with:
   - Summary of work completed
   - Files changed/created
   - Any blockers or issues encountered
   - Confirmation of acceptance criteria met
   - PR link if applicable

**For the CREATING AGENT (task owner):**
1. Monitor issue for completion comment
2. Review delivered work and PR
3. CLOSE the issue only after verifying completion
4. Provide feedback or request changes if needed

### Issue Lifecycle
- **Open**: Task assigned and ready to work
- **Comment Added**: Agent reports completion
- **Closed**: Creating agent verifies and accepts work

Let me parse your arguments and create the properly formatted issue...