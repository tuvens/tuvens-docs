# Handoff Templates & Communication

← [Back to Main](./README.md)

> **💡 Quick Handoff**: Simply ask Claude Desktop: *"Get [agent] to handle this [task type] in Claude Code"*

## Handoff Templates

Load the appropriate template based on task complexity:

### Simple Tasks (1-2 files)
```markdown
Load: agentic-development/desktop-project-instructions/handoff-templates/simple-task.md
```

### Complex Features (multi-file)
```markdown
Load: agentic-development/desktop-project-instructions/handoff-templates/complex-feature.md
```

### Refactoring
```markdown
Load: agentic-development/desktop-project-instructions/handoff-templates/refactoring.md
```

### Debugging
```markdown
Load: agentic-development/desktop-project-instructions/handoff-templates/debugging.md
```

## Inter-Agent Communication

For tasks requiring multiple agents:
```markdown
Load: agentic-development/desktop-project-instructions/workflows/inter-agent-communication.md
```

## System Improvements

When agents fail or need enhancement:
```markdown
Load: agentic-development/desktop-project-instructions/workflows/system-improvement.md
```

## Best Practices

### DO
- ✅ Use natural language requests for intuitive handoffs
- ✅ Use `/start-session` pattern to trigger desktop automation
- ✅ Create GitHub issues for task tracking (automatic)
- ✅ Respect agent domain authority
- ✅ Understand Claude Desktop uses setup script, not Claude Code command
- ✅ Load only necessary instruction files
- ✅ Keep handoffs focused and specific

### DON'T
- ❌ Duplicate agent context (it's in `.claude/agents/`)
- ❌ Override domain decisions without evidence
- ❌ Start complex tasks without proper setup
- ❌ Mix multiple unrelated tasks
- ❌ Skip the worktree organization