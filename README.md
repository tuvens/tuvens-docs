# Tuvens Documentation Repository

**Central documentation hub for the Tuvens product suite and multi-agent development system**

## Repository Structure

### 📁 Core Directories

```
tuvens-docs/
├── .claude/              # Claude Code agent definitions
├── .github/              # GitHub Actions and workflows
├── agentic-development/  # Multi-agent development system
├── tuvens-docs/          # Product documentation
└── .gitignore           # Git ignore configuration
```

## Directory Purpose

### `.claude/`
**Claude Code Integration**
- Agent identity files for Claude Code sessions
- Commands and configurations for development workflow
- **Used by**: Claude Code sessions

### `.github/`
**GitHub Automation**
- GitHub Actions workflows
- Automated maintenance and CI/CD
- **Used by**: GitHub platform

### `agentic-development/`
**Multi-Agent Development System**
- Claude Desktop orchestration instructions
- Agent handoff templates and workflows
- System automation scripts
- **Used by**: Claude Desktop for agent coordination

### `tuvens-docs/`
**Product Documentation**
- Tuvens suite documentation
- Integration guides and API references
- Authentication and implementation guides
- **Used by**: Developers, agents working on product features

## Getting Started

### For Claude Desktop Users
Load the orchestration system:
```markdown
Load: agentic-development/desktop-project-instructions/README.md
```

### For Claude Code Users
Agent identities are loaded automatically from `.claude/agents/[agent-name].md`

### For Developers
Product documentation is in `tuvens-docs/` directory.

## Multi-Agent Development

This repository implements a multi-agent development system where:
- **Claude Desktop** orchestrates and coordinates agents
- **Claude Code** executes tasks with specialized agent identities
- **GitHub Actions** automate system maintenance

### Available Agents
- `vibe-coder` - System architecture and documentation
- `react-dev` - React frontend development (hi.events)
- `laravel-dev` - Laravel backend development (hi.events)
- `svelte-dev` - Svelte frontend development (tuvens-client)
- `node-dev` - Node.js backend development (tuvens-api)
- `devops` - Infrastructure and deployment

### Starting Agent Sessions
```bash
/start-session [agent-name]
```

## System Maintenance

The system maintains itself through automated GitHub Actions:
- **Maintenance checks** run on every push to `develop`
- **Vibe Coder agent** receives automated maintenance issues
- **Documentation** stays current without manual intervention

## Repository Health

- **Production files**: 22 essential files in `agentic-development/`
- **Archive system**: Design docs in `agentic-development/.temp/`
- **Clean separation**: No redundancy between Desktop/Code contexts
- **Automated validation**: GitHub Actions ensure system integrity

## Documentation Index

### Core Documentation
- [`agentic-development/README.md`](agentic-development/README.md) - Multi-agent system overview and maintenance
- [`agentic-development/desktop-project-instructions/README.md`](agentic-development/desktop-project-instructions/README.md) - Claude Desktop orchestration instructions
- [`tuvens-docs/README.md`](tuvens-docs/README.md) - Product documentation overview

### Product Documentation
- [`tuvens-docs/hi-events-integration/README.md`](tuvens-docs/hi-events-integration/README.md) - Hi.events integration documentation
- [`tuvens-docs/implementation-guides/cross-app-authentication/README.md`](tuvens-docs/implementation-guides/cross-app-authentication/README.md) - Cross-application authentication guide
- [`tuvens-docs/integration-examples/frontend-integration/README.md`](tuvens-docs/integration-examples/frontend-integration/README.md) - Frontend integration examples

### Navigation Guide
- **System Architecture**: Start with `agentic-development/README.md`
- **Agent Orchestration**: See `agentic-development/desktop-project-instructions/README.md`
- **Product Development**: Browse `tuvens-docs/` subdirectories
- **Integration Guides**: Check specific guides in `tuvens-docs/` folders

---

**🤖 This repository demonstrates advanced multi-agent orchestration with Claude Desktop and Claude Code integration.**

> Workflows tested on test branch: 2025-08-07