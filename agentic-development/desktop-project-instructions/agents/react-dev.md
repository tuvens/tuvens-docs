# Starting React Dev Sessions

## When to Use React Dev
- React component development (hi.events frontend)
- React hooks and state management
- Material-UI or other React UI libraries
- React Router implementation
- React performance optimization

## Starting a Claude Code Session

### For React Development Tasks

```bash
/start-session react-dev
```

The command will analyze the current conversation and create:
1. GitHub issue with task details
2. Isolated worktree in hi.events repository
3. Prompt file with React-specific context

### Manual Session Start

If starting Claude Code manually, use this prompt structure:

```markdown
Load: .claude/agents/react-dev.md

Task: [React component or feature needed]
Repository: hi.events
Component: [specific component name]
Worktree: hi.events/react-dev/[descriptive-branch-name]

Start by reviewing the existing component structure and design patterns.
```

## Task Types and Context Loading

### New Component Creation
```markdown
Load: .claude/agents/react-dev.md
Load: hi.events/frontend/components/README.md

Create [ComponentName] with:
- Props: [prop specifications]
- State: [state requirements]
- Integration: [how it connects to other components]
```

### React Hook Development
```markdown
Load: .claude/agents/react-dev.md

Implement custom hook for [functionality]:
- Hook name: use[HookName]
- Dependencies: [what it needs]
- Return value: [what it provides]
```

### Performance Optimization
```markdown
Load: .claude/agents/react-dev.md

Optimize [component/feature] for:
- Issue: [performance problem]
- Metrics: [what to improve]
- Constraints: [what not to break]
```

## Key Context Files

Always available in react-dev sessions:
- `.claude/agents/react-dev.md` - Agent identity and React expertise
- `hi.events/frontend/` - React application structure
- Component library documentation
- React best practices guide

## Handoff Checklist

Before starting Claude Code session:
- [ ] Component specifications clear
- [ ] UI/UX requirements defined
- [ ] API endpoints identified (if needed)
- [ ] Testing requirements understood
- [ ] GitHub issue number (if using /start-session)