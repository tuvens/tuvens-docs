# Starting Svelte Dev Sessions

## When to Use Svelte Dev
- SvelteKit application development (tuvens-client)
- Svelte component creation
- Skeleton UI framework implementation
- TanStack integration (Query, Router)
- Svelte stores and reactivity

## Starting a Claude Code Session

### For Svelte Development Tasks

```bash
/start-session svelte-dev
```

The command will analyze the current conversation and create:
1. GitHub issue with task details
2. Isolated worktree: `tuvens-client/svelte-dev/[branch-name]`
3. Prompt file with Svelte-specific context

### Manual Session Start

If starting Claude Code manually, use this prompt structure:

```markdown
Load: .claude/agents/svelte-dev.md

Task: [Svelte component or feature needed]
Repository: tuvens-client
Route/Component: [specific location]
Worktree: tuvens-client/svelte-dev/[descriptive-branch-name]

Start by reviewing the existing Skeleton UI components and route structure.
```

## Task Types and Context Loading

### Route Creation
```markdown
Load: .claude/agents/svelte-dev.md
Load: tuvens-client/src/routes/README.md

Create route for [feature]:
- Path: /[route-path]
- Layout: [which layout to use]
- Data loading: [+page.ts requirements]
```

### Component Development
```markdown
Load: .claude/agents/svelte-dev.md

Build [ComponentName] using Skeleton UI:
- Base component: [Skeleton component to extend]
- Props: [component properties]
- Events: [custom events to dispatch]
- Styling: [Tailwind classes needed]
```

### Store Implementation
```markdown
Load: .claude/agents/svelte-dev.md

Create Svelte store for [data-type]:
- Store type: [writable/readable/derived]
- Initial state: [default values]
- Actions: [methods to expose]
```

### TanStack Integration
```markdown
Load: .claude/agents/svelte-dev.md

Implement data fetching for [feature]:
- Query key: [unique identifier]
- API endpoint: [backend route]
- Cache strategy: [how to handle updates]
```

## Key Context Files

Always available in svelte-dev sessions:
- `.claude/agents/svelte-dev.md` - Agent identity and Svelte expertise
- `tuvens-client/src/` - Application structure
- Skeleton UI documentation references
- TanStack Query/Router patterns

## Common Patterns

### File-based Routing
- `+page.svelte` - Page component
- `+page.ts` - Load function
- `+layout.svelte` - Layout wrapper
- `+server.ts` - API endpoints

### Skeleton UI Usage
- Always check existing theme configuration
- Use Skeleton's built-in components first
- Extend with custom Tailwind when needed
- Follow accessibility guidelines

## Handoff Checklist

Before starting Claude Code session:
- [ ] UI/UX requirements clear
- [ ] Skeleton components identified
- [ ] API endpoints documented
- [ ] Route structure planned
- [ ] GitHub issue number (if using /start-session)