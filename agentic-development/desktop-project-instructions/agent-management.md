# Agent Management Guide

← [Back to Main](./README.md)

## Starting Agent Sessions

### Natural Language Method (Primary)
Simply ask in natural conversation:
```
"Get vibe-coder to work on this documentation in Claude Code"
"Have devops handle this deployment issue"
"Ask react-dev to fix this UI bug"
"Let's use Claude Code with laravel-dev for this"
```

**Claude Desktop will confirm and execute:**
- Creates GitHub issue with task details
- Sets up isolated worktree with branch mapping  
- Opens iTerm2 with ready-to-paste prompt
- Launches Claude Code with full agent context
- Maintains awareness of repository locations

### Direct Command Method (Alternative)
For power users:
```bash
/start-session [agent-name] "[task-title]" "[description]"
```
**Note**: In Claude Desktop, this pattern triggers the desktop setup script via iTerm2 MCP, not Claude Code's built-in command.

**Examples:**
```bash
/start-session vibe-coder "Fix Documentation" "Update API reference docs"
/start-session devops "Deploy Pipeline" "Set up CI/CD for staging"
```

**Full Implementation Details**: See [Desktop setup workflow](../scripts/setup-agent-task-desktop.sh)
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
- **Wiki content** → Direct wiki creation (natural language to vibe-coder)

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
- **Wiki documentation** → Direct creation via natural language to vibe-coder