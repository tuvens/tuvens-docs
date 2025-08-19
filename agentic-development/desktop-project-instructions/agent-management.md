# Agent Management Guide

← [Back to Main](./README.md)

## Starting Agent Sessions

### Automated Method (Preferred)
```bash
/start-session [agent-name]
```

This command:
- Analyzes current conversation context
- Creates GitHub issue with task details
- Sets up isolated worktree with branch mapping
- Opens iTerm2 with ready-to-paste prompt
- Maintains awareness of repository locations

**Full Implementation Details**: See [start-session integration guide](../workflows/start-session-integration.md)
**Branching Strategy**: See [Tuvens branching strategy](../workflows/tuvens-branching-strategy.md)
**Central Tracking**: See [central branch tracking system](../workflows/central-branch-tracking.md)

#### Worktree Structure
Each session creates a dedicated worktree matching the branch name:
```
~/Code/Tuvens/tuvens-client/worktrees/svelte-dev-feature-auth-ui/
~/Code/Tuvens/tuvens-api/worktrees/node-dev-fix-validation/
~/Code/Tuvens/hi.events/worktrees/laravel-dev-update-cors/
```

This enables parallel work and easy cleanup when branches are merged.

### Manual Method
For specific control over the task:
```bash
/create-issue [your-agent] [target-agent] "[Task Title]" [repository]
```

Then start Claude Code in the appropriate repository.

## Task Routing Guide

### By Technology
- **React components** → react-dev
- **Svelte components** → svelte-dev  
- **Node.js APIs** → node-dev
- **Laravel/PHP** → laravel-dev
- **Docker/K8s** → devops
- **Documentation** → vibe-coder
- **Wiki content** → Wiki workflow (see Wiki Guidelines below)

### By Repository
- **tuvens-client** → svelte-dev
- **tuvens-api** → node-dev
- **hi.events** → laravel-dev (backend) or react-dev (frontend)
- **tuvens-docs** → vibe-coder
- **tuvens-mobile** → integration specialist

### By Task Type
- **Bug fix** → Domain specialist for that service
- **New feature** → Primary implementation agent
- **Integration** → Multiple agents coordinated by CTO
- **Refactoring** → Domain specialist with vibe-coder guidance
- **System improvement** → vibe-coder
- **Wiki documentation** → Wiki workflow (any agent can create, vibe-coder syncs)