# Simple Task Handoff Template

## When to Use
- Single file changes
- Quick bug fixes
- Documentation updates
- Configuration changes
- Minor refactoring

## Claude Desktop Analysis

Before handoff, determine:
1. **File(s) affected**: [specific paths]
2. **Change type**: [fix/update/add]
3. **Testing needed**: [yes/no]
4. **Agent**: [appropriate specialist]

## Handoff Methods

### Option 1: Direct in Current Session
For very simple changes, proceed directly:
```markdown
Task: [specific change needed]
File: [exact file path]
Change: [what to modify]
```

### Option 2: Quick Claude Code Session
For changes needing better tools:
```bash
claude [repository-path]
```

Then provide:
```markdown
Load: .claude/agents/[agent-name].md

Quick task: [specific change]
File: [path]
Current issue: [what's wrong]
Desired outcome: [what should happen]

Make the change and verify it works.
```

## Examples

### Bug Fix
```markdown
Load: .claude/agents/node-dev.md

Quick fix: API returns 404 for valid user IDs
File: backend/routes/users.js
Issue: Incorrect parameter parsing
Fix: Parse userId as integer before database query
```

### Documentation Update
```markdown
Load: .claude/agents/vibe-coder.md

Quick task: Update README with new environment variables
File: README.md
Add: DATABASE_URL and REDIS_URL configuration examples
```

### Configuration Change
```markdown
Load: .claude/agents/devops.md

Quick task: Update nginx config for new API endpoint
File: config/nginx.conf
Add: Proxy rule for /api/v2/* to port 8081
```

## Checklist

- [ ] Task fits in 1-2 files
- [ ] Clear before/after state
- [ ] No complex dependencies
- [ ] Can be tested quickly
- [ ] No architectural changes

If any checkbox is NO, use complex-feature.md instead.