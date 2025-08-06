# Inter-Agent Communication Protocol

## Overview

Agents communicate through GitHub issues using structured templates. This ensures clear task ownership, authority, and acceptance criteria.

## Communication Flow

### 1. Task Assignment
Creating agent creates GitHub issue using `/create-issue` command:

```bash
/create-issue [creating-agent] [assigned-agent] [task-title] [repository]
```

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

Use these commands for inter-repository work:

### Asking Questions
```bash
/ask-question [repository] [question]
```

### Reporting Bugs
```bash
/report-bug [repository] [bug_description]
```

### Requesting Features
```bash
/send-rqts [repository] [requirements_description]
```

## Example Communication

```markdown
# CTO assigns task to node-dev
/create-issue cto node-dev "Implement OAuth2 endpoints" tuvens-api

# Node-dev needs clarification from laravel-dev
/ask-question hi.events "How does your OAuth implementation handle refresh tokens?"

# Svelte-dev reports API bug to node-dev
/report-bug tuvens-api "User profile endpoint returns 500 on missing avatar"
```

## Best Practices

1. **Be Specific**: Clear task descriptions prevent confusion
2. **Respect Authority**: Don't override domain decisions without evidence
3. **Document Decisions**: Record why choices were made
4. **Close Loop**: Always close issues when complete
5. **Escalate Properly**: Use CTO for cross-domain conflicts