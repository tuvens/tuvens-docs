# Agent Profiles Index

This directory contains desktop project instruction files for all specialized agents in the Tuvens ecosystem. Each profile provides context loading patterns, task types, and handoff guidance for starting Claude Code sessions.

## Available Agents

### Development Agents

#### [codehooks-dev.md](./codehooks-dev.md)
**Specialization**: Codehooks serverless platform development
**Use for**: Codehooks cloud functions, serverless APIs, backend integrations

#### [laravel-dev.md](./laravel-dev.md)
**Specialization**: Laravel PHP framework development
**Use for**: Laravel applications, PHP backends, API development

#### [node-dev.md](./node-dev.md)
**Specialization**: Node.js backend development
**Use for**: Node.js APIs, Express servers, npm package development

#### [react-dev.md](./react-dev.md)
**Specialization**: React frontend development
**Use for**: React components, hooks, state management, UI/UX implementation

#### [svelte-dev.md](./svelte-dev.md)
**Specialization**: Svelte frontend development
**Use for**: Svelte components, SvelteKit applications, lightweight frontends

### Operations Agents

#### [devops.md](./devops.md)
**Specialization**: Infrastructure and deployment operations
**Use for**: Docker, Kubernetes, CI/CD pipelines, monitoring, security

### Architecture Agents

#### [vibe-coder.md](./vibe-coder.md)
**Specialization**: System architecture and agent coordination
**Use for**: Agent improvements, workflow automation, documentation organization

## Quick Selection Guide

### By Technology Stack
- **React Frontend**: `react-dev`
- **Svelte Frontend**: `svelte-dev`
- **Laravel Backend**: `laravel-dev`
- **Node.js Backend**: `node-dev`
- **Serverless Functions**: `codehooks-dev`
- **Infrastructure**: `devops`
- **System Improvements**: `vibe-coder`

### By Task Type
- **New Feature Development**: Choose stack-specific agent (`react-dev`, `laravel-dev`, etc.)
- **Bug Fixes**: Use agent matching the affected technology
- **Performance Optimization**: Technology-specific agent or `devops` for infrastructure
- **Deployment Issues**: `devops`
- **Agent Coordination Problems**: `vibe-coder`
- **Documentation Organization**: `vibe-coder`

## Starting Sessions

### Automated Session Start
```bash
/start-session [agent-name]
```

### Manual Session Start
1. Choose appropriate agent from list above
2. Load the agent's profile file: `Load: .claude/agents/[agent-name].md`
3. Follow the specific patterns outlined in each profile
4. Create worktree: `[repo]/[agent-name]/[descriptive-branch-name]`

## Agent Selection Decision Tree

```
Task involves frontend code?
├─ Yes: React or Svelte?
│   ├─ React → react-dev
│   └─ Svelte → svelte-dev
└─ No: Backend or infrastructure?
    ├─ Backend: What framework?
    │   ├─ Laravel → laravel-dev
    │   ├─ Node.js → node-dev
    │   └─ Serverless → codehooks-dev
    ├─ Infrastructure → devops
    └─ System/Agent Issues → vibe-coder
```

## Integration Notes

- All agents follow the 5-branch strategy: `main ← stage ← test ← dev ← feature/[agent]/[task]/[name]`
- Agents coordinate through GitHub issues and central branch tracking
- Each agent has specific context loading patterns for optimal performance
- Cross-agent handoffs should update relevant GitHub issues with progress

## Contributing

When adding new agent profiles:
1. Follow existing file structure and naming conventions
2. Include all required sections: When to Use, Session Start, Task Types, Context Files, Handoff Checklist
3. Update this README.md with the new agent entry
4. Test the profile with actual Claude Code sessions