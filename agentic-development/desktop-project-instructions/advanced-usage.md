# Advanced Usage Guide

← [Back to Main](./README.md)

> **💡 Quick Start**: For any scenario below, simply ask Claude Desktop naturally:  
> *"Get [agent] to work on [task description] in Claude Code"*  
> See [Agent Management](./agent-management.md) for details.

## Custom Prompt Templates

For task-specific prompts beyond the automated system:
```markdown
Load: agentic-development/workflows/agent-terminal-prompts.md
```

This provides detailed, copy-paste ready prompts for specific task types and contexts.

## Context Loading by Task Type

### Backend API Development
When working on Node.js/NestJS API tasks:
```markdown
Load: .claude/agents/node-dev.md
Load: tuvens-docs/implementation-guides/cross-app-authentication/README.md
Load: tuvens-docs/tuvens-docs/shared-protocols/ (API patterns)
```

### Frontend Component Work
For Svelte frontend development:
```markdown
Load: .claude/agents/svelte-dev.md
Load: tuvens-docs/tuvens-docs/shared-protocols/frontend-integration/README.md
Load: tuvens-docs/tuvens-docs/integration-examples/frontend-integration/README.md
```

For React frontend development:
```markdown
Load: .claude/agents/react-dev.md
Load: tuvens-docs/tuvens-docs/hi-events-integration/frontend-integration/README.md
Load: tuvens-docs/tuvens-docs/shared-protocols/frontend-integration/README.md
```

### Integration Tasks
For Hi.Events integration work:
```markdown
Load: .claude/agents/[relevant-dev].md
Load: tuvens-docs/tuvens-docs/hi-events-integration/README.md
Load: tuvens-docs/tuvens-docs/implementation-guides/cross-app-authentication/README.md
```

### DevOps/Infrastructure
For deployment and infrastructure:
```markdown
Load: .claude/agents/devops.md
Load: agentic-development/workflows/README.md
Load: tuvens-docs/tuvens-docs/repositories/[target-repo].md
Load: agentic-development/workflows/cross-repository-development/README.md
```

### Documentation Updates
For documentation improvements:
```markdown
Load: .claude/agents/vibe-coder.md
Load: agentic-development/workflows/worktree-organization.md
Load: [relevant section documentation]
```

## Repository-Specific Context

### Working in tuvens-client (Svelte)
Essential context files:
- `tuvens-docs/shared-protocols/frontend-integration/README.md`
- `tuvens-docs/shared-protocols/frontend-integration/architecture-standards.md`
- `tuvens-docs/repositories/tuvens-client.md`

### Working in tuvens-api (Node.js/NestJS)
Essential context files:
- `tuvens-docs/implementation-guides/cross-app-authentication/README.md`
- `tuvens-docs/implementation-guides/cross-app-authentication/database-implementation/README.md`
- `tuvens-docs/repositories/tuvens-api.md`

### Working in hi.events (Laravel/React)
Essential context files:
- `tuvens-docs/hi-events-integration/README.md`
- `tuvens-docs/hi-events-integration/backend-testing-guide.md`
- `tuvens-docs/repositories/hi-events.md`

## Common Task Scenarios

### "Add new API endpoint"
- **Agent**: `node-dev`
- **Context**: `implementation-guides/cross-app-authentication/` + `shared-protocols/`
- **Template**: `complex-feature.md`

### "Fix frontend component bug"
- **Agent**: `svelte-dev` or `react-dev` 
- **Context**: `shared-protocols/frontend-integration/` + specific component docs
- **Template**: `simple-task.md`

### "Update integration flow"
- **Agent**: Depends on primary repository
- **Context**: `hi-events-integration/` + `implementation-guides/`
- **Template**: `complex-feature.md`

### "Deploy new feature"
- **Agent**: `devops`
- **Context**: `repositories/` + `cross-repository-development/`
- **Template**: `complex-feature.md`

### "Write documentation"
- **Agent**: `vibe-coder`
- **Context**: Relevant domain documentation + `workflows/`
- **Template**: `simple-task.md`