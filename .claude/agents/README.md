# Agent Discovery Index

This directory contains agent configuration files for the Tuvens ecosystem multi-agent system.

## Available Agents

### System Orchestration
- **[vibe-coder.md](./vibe-coder.md)** - System orchestrator and creative agent for multi-agent coordination. Responsible for coordinating agents, enforcing protocols, and validating completed work.

### Infrastructure & Operations
- **[devops.md](./devops.md)** - DevOps agent specializing in infrastructure, deployment, CI/CD, and operational excellence across the entire Tuvens ecosystem.

### Backend Development
- **[laravel-dev.md](./laravel-dev.md)** - Laravel/PHP development agent for backend APIs, database architecture, and server-side business logic.
- **[node-dev.md](./node-dev.md)** - Node.js development agent specializing in backend services and API development.
- **[codehooks-dev.md](./codehooks-dev.md)** - CodeHooks.io platform specialist for serverless backend development.

### Frontend Development
- **[react-dev.md](./react-dev.md)** - React development agent for modern web applications and user interfaces.
- **[svelte-dev.md](./svelte-dev.md)** - Svelte/SvelteKit development agent for high-performance frontend applications.
- **[mobile-dev.md](./mobile-dev.md)** - Mobile development agent for cross-platform mobile applications.

### Documentation & Content
- **[docs-orchestrator.md](./docs-orchestrator.md)** - Documentation orchestrator for maintaining comprehensive project documentation.

## Loading Guidance

### For Claude Code Users
To load an agent identity, use the Claude Code context loading feature:
```
Context Loading:
- Load: .claude/agents/{agent-name}.md
```

### Agent File Structure
Each agent file contains:
- **Technology Focus**: Primary technologies and domains
- **Responsibilities**: Core duties and areas of authority
- **Repository Involvement**: Which repositories the agent works in
- **Collaboration Patterns**: How the agent works with others
- **Workflow Protocols**: Standard operating procedures

### Agent Selection Guidelines
1. **System Coordination**: Use `vibe-coder` for multi-agent orchestration and system-level tasks
2. **Infrastructure**: Use `devops` for deployment, CI/CD, monitoring, and operational concerns
3. **Backend Development**: Choose based on technology stack:
   - `laravel-dev` for PHP/Laravel projects
   - `node-dev` for Node.js/Express projects
   - `codehooks-dev` for serverless/CodeHooks projects
4. **Frontend Development**: Choose based on framework:
   - `react-dev` for React applications
   - `svelte-dev` for Svelte/SvelteKit applications
   - `mobile-dev` for mobile applications
5. **Documentation**: Use `docs-orchestrator` for documentation tasks

### Multi-Agent Coordination
- The `vibe-coder` agent coordinates complex tasks requiring multiple specialists
- Cross-repository work typically involves the `devops` agent for operational concerns
- Technology-specific agents focus on their domain expertise within their primary repositories

---
*Last Updated: 2025-08-19*  
*Maintained By: DevOps Agent*
