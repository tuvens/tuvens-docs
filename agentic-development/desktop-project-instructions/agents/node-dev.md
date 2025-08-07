# Starting Node Dev Sessions

## When to Use Node Dev
- Node.js backend development (tuvens-api)
- Express/Fastify API endpoints
- Database operations and migrations
- Authentication and authorization
- WebSocket implementations
- Background jobs and queues

## Starting a Claude Code Session

### For Node.js Development Tasks

```bash
/start-session node-dev
```

The command will analyze the current conversation and create:
1. GitHub issue with task details
2. Isolated worktree: `tuvens-api/node-dev/[branch-name]`
3. Prompt file with Node.js-specific context

### Manual Session Start

If starting Claude Code manually, use this prompt structure:

```markdown
Load: .claude/agents/node-dev.md

Task: [API feature or backend service needed]
Repository: tuvens-api
Module: [specific module/service]
Worktree: tuvens-api/node-dev/[descriptive-branch-name]

Start by reviewing the existing API structure and database schema.
```

## Task Types and Context Loading

### API Endpoint Creation
```markdown
Load: .claude/agents/node-dev.md
Load: tuvens-api/src/routes/README.md

Create endpoint for [resource]:
- Method: [GET/POST/PUT/DELETE]
- Path: /api/v1/[resource-path]
- Auth: [authentication requirements]
- Validation: [input validation rules]
```

### Database Operations
```markdown
Load: .claude/agents/node-dev.md
Load: tuvens-api/src/models/README.md

Implement database logic for [feature]:
- Model: [which model to use/create]
- Operations: [CRUD operations needed]
- Relationships: [joins/associations]
- Migration: [schema changes needed]
```

### Authentication/Authorization
```markdown
Load: .claude/agents/node-dev.md

Implement auth for [feature]:
- Strategy: [JWT/OAuth/Session]
- Permissions: [role-based access]
- Middleware: [protection needed]
```

### WebSocket Implementation
```markdown
Load: .claude/agents/node-dev.md

Create real-time feature for [functionality]:
- Events: [socket events to handle]
- Rooms: [grouping logic]
- State: [what to track]
- Client sync: [update strategy]
```

## Key Context Files

Always available in node-dev sessions:
- `.claude/agents/node-dev.md` - Agent identity and Node.js expertise
- `tuvens-api/src/` - Application structure
- Database schema documentation
- API documentation and patterns

## Common Patterns

### Project Structure
- `src/routes/` - API endpoints
- `src/models/` - Database models
- `src/services/` - Business logic
- `src/middleware/` - Express middleware
- `src/utils/` - Helper functions

### Best Practices
- Use TypeScript for type safety
- Implement proper error handling
- Add request validation (Joi/Zod)
- Include API documentation
- Write integration tests

## Integration Points

### With Frontend (svelte-dev)
- Coordinate API contracts
- Ensure consistent data formats
- Plan WebSocket events together

### With Database
- Review existing schema first
- Plan migrations carefully
- Consider performance impacts

## Handoff Checklist

Before starting Claude Code session:
- [ ] API specifications defined
- [ ] Database schema reviewed
- [ ] Authentication requirements clear
- [ ] Integration points identified
- [ ] GitHub issue number (if using /start-session)