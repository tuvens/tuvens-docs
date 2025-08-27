# Inter-Agent Communication Protocol

## Overview

Agents communicate through GitHub issues using structured templates. This ensures clear task ownership, authority, and acceptance criteria.

## Communication Flow

### 1. Task Assignment
Coordinating agent creates GitHub issue through natural language request:

**Example**: "Get node-dev to implement OAuth2 endpoints in tuvens-api"
**Result**: MCP script creates GitHub issue with proper task details and agent assignment

### 2. Issue Template Structure

```markdown
## Agent Communication
**Created by**: [requesting-agent]
**Assigned to**: [responsible-agent] 
**Authority**: [agent-with-domain-authority]

## Request
[Detailed description of what needs to be done]

## Context
- Repository: [repo-name]
- Related work: [links to issues/PRs]
- Dependencies: [what this blocks/unblocks]

## Evidence Requirements
If challenging this request, provide:
- Technical evidence
- Error logs/screenshots
- Expected vs actual behavior
- Proposed alternative approach

## Acceptance Criteria
- [ ] [Specific deliverable 1]
- [ ] [Specific deliverable 2]
- [ ] [Testing completed]
- [ ] [Documentation updated]
```

### 3. Task Completion

Assigned agent:
1. Comments on issue with completion summary
2. Includes: files changed, blockers encountered, PR link

Creating agent:
1. Reviews delivered work
2. Closes issue after verification
3. Provides feedback if changes needed

## Authority Hierarchy

1. **CTO**: Ultimate technical authority
2. **Domain Specialists**: Authority over their repositories
   - `node-dev` → tuvens-api
   - `svelte-dev` → tuvens-client
   - `laravel-dev` → hi.events
3. **Evidence-Based Challenges**: Must provide technical proof

## Cross-Repository Communication

Use natural language patterns for inter-repository work:

### Asking Questions
**Pattern**: "Ask [agent] about [question] in [repository]"
**Example**: "Ask laravel-dev how OAuth implementation handles refresh tokens in hi.events"

### Reporting Bugs
**Pattern**: "Get [agent] to fix [bug_description] in [repository]"
**Example**: "Get node-dev to fix user profile endpoint returning 500 on missing avatar in tuvens-api"

### Requesting Features
**Pattern**: "Have [agent] implement [requirements_description] in [repository]"
**Example**: "Have svelte-dev add user dashboard analytics in tuvens-client"

## Example Communication

**Task Assignment**:
"Get node-dev to implement OAuth2 endpoints in tuvens-api"
→ Creates GitHub issue, sets up worktree, launches Claude Code for node-dev

**Cross-Agent Question**:
"Ask laravel-dev how OAuth implementation handles refresh tokens in hi.events"
→ Creates GitHub issue for laravel-dev with question context

**Bug Report**:
"Get node-dev to fix user profile endpoint returning 500 on missing avatar in tuvens-api"
→ Creates GitHub issue with bug details and debugging context

## Best Practices

1. **Be Specific**: Clear task descriptions prevent confusion
2. **Respect Authority**: Don't override domain decisions without evidence
3. **Document Decisions**: Record why choices were made
4. **Close Loop**: Always close issues when complete
5. **Escalate Properly**: Use CTO for cross-domain conflicts