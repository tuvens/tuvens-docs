# Complex Feature Handoff Template

## When to Use
- Multi-file implementations
- New features requiring architecture
- Cross-service integrations
- Database schema changes
- API endpoint additions

## Claude Desktop Planning

### 1. Feature Analysis
```markdown
Feature: [name]
Scope:
- [ ] Frontend components
- [ ] Backend endpoints
- [ ] Database changes
- [ ] API integration
- [ ] Documentation

Repositories affected:
- [ ] tuvens-client
- [ ] tuvens-api
- [ ] tuvens-docs
- [ ] hi.events
```

### 2. Branch Tracking Check
Before assigning agents, check for existing work:
```bash
# Check active branches for related work
cat agentic-development/branch-tracking/active-branches.json | jq '.branches'

# Look for related task groups
cat agentic-development/branch-tracking/task-groups.json | jq 'keys'
```

### 3. Agent Assignment
Determine primary agent based on core work:
- Frontend-heavy → `svelte-dev` or `react-dev`
- Backend-heavy → `node-dev` or `laravel-dev`
- Infrastructure → `devops`
- Cross-cutting → `vibe-coder` coordinates

### 3. Create Structured Task
```bash
/create-issue [your-agent] [assigned-agent] "[Feature Name]" [repository]
```

## Claude Code Session Template

### Automated Start
```bash
/start-session [agent-name]
```

### Manual Start Template
```markdown
Load: .claude/agents/[agent-name].md

GitHub Issue: #[number]
Feature: [name]
Repository: [primary-repo]

## Branch Tracking Context
Check active branches and task groups:
- Read: agentic-development/branch-tracking/active-branches.json
- Read: agentic-development/branch-tracking/task-groups.json
- Look for task group: [feature-name-task-group]

## Implementation Plan
1. [First major step]
2. [Second major step]
3. [Third major step]

## Technical Requirements
- [Requirement 1]
- [Requirement 2]
- [Requirement 3]

## Files to Create/Modify
- [Path 1]: [what to do]
- [Path 2]: [what to do]
- [Path 3]: [what to do]

## Related Work Coordination
- Related branches in other repos: [list from task group]
- Dependencies: [from task group dependencies]
- Communication channel: [GitHub issue comments]

## Testing Strategy
- [ ] Unit tests for [components]
- [ ] Integration tests for [workflows]
- [ ] Manual testing of [user flows]

Begin by checking the branch tracking context, then create the worktree and review existing code structure.
```

## Multi-Agent Features

For features spanning multiple services:

### 1. Create Parent Issue
```bash
/create-issue cto cto "Feature: [Name]" tuvens-docs
```

### 2. Create Sub-tasks
```bash
/create-issue cto node-dev "API: [Feature] endpoints" tuvens-api
/create-issue cto svelte-dev "UI: [Feature] components" tuvens-client
```

### 3. Coordination Template
```markdown
Parent Issue: #[number]

## Task Group Setup
Create task group in: agentic-development/branch-tracking/task-groups.json
```json
{
  "[feature-name-task-group]": {
    "title": "[Feature Name] Implementation",
    "description": "[Feature description]",
    "coordinator": "[your-username]",
    "created": "[current-date]",
    "status": "in-progress",
    "branches": {
      "tuvens-api": "feature/[feature-name]-api",
      "tuvens-client": "feature/[feature-name]-ui",
      "tuvens-docs": "docs/[feature-name]"
    },
    "agents": {
      "node-dev": "API endpoints and business logic",
      "svelte-dev": "UI components and integration", 
      "vibe-coder": "Documentation and coordination"
    },
    "dependencies": [
      "API branch must be merged before UI integration",
      "Documentation after implementation complete"
    ],
    "issues": ["#[api-issue]", "#[ui-issue]", "#[docs-issue]"]
  }
}
```

Sub-tasks:
- API Implementation: #[number] (node-dev)
- UI Implementation: #[number] (svelte-dev)  
- Documentation: #[number] (vibe-coder)

Dependencies:
- API must be complete before UI integration
- Documentation after implementation
```

## Success Criteria

### Technical
- [ ] All tests passing
- [ ] No linting errors
- [ ] Performance acceptable
- [ ] Security reviewed

### Functional
- [ ] Feature works as specified
- [ ] Edge cases handled
- [ ] Error states implemented
- [ ] User feedback clear

### Documentation
- [ ] API documented
- [ ] User guide updated
- [ ] Technical notes added
- [ ] Examples provided

### Branch Tracking & Cleanup
- [ ] Task group status updated to "completed"
- [ ] All related branches merged and tracked in merge-log.json
- [ ] Worktrees cleaned up via cleanup-merged-branches.sh
- [ ] active-branches.json reflects completion status

## Example: User Dashboard Feature

```markdown
Load: .claude/agents/svelte-dev.md

GitHub Issue: #45
Feature: User Analytics Dashboard
Repository: tuvens-client

## Implementation Plan
1. Create dashboard route and layout
2. Build analytics component library
3. Integrate with API endpoints
4. Add real-time updates via WebSocket
5. Implement data visualization

## Technical Requirements
- Use Skeleton UI components
- Chart.js for visualizations
- TanStack Query for data fetching
- WebSocket for real-time updates

## Files to Create/Modify
- src/routes/dashboard/+page.svelte: Main dashboard page
- src/lib/components/analytics/: Component library
- src/lib/stores/analytics.ts: Data management
- src/lib/api/analytics.ts: API integration

## Testing Strategy
- [ ] Component tests for each analytics widget
- [ ] Integration tests for data flow
- [ ] E2E tests for complete dashboard flow
- [ ] Performance tests for real-time updates

Begin by creating the worktree and reviewing the existing routing structure.
```