# Setup Guide

← [Back to Main](./README.md)

## 🔧 Setup Requirements

### Essential Prerequisites

```bash
# 1. Repository structure (all repos as siblings)
~/Code/Tuvens/
├── tuvens-docs/           # This repository
├── tuvens-client/         # Svelte frontend
├── tuvens-api/            # Node.js backend
├── hi.events/             # Laravel/React app
└── eventsdigest-ai/       # Additional projects
```

### 2. iTerm2 MCP Integration
```bash
# Install iTerm MCP server
npm install -g iterm_mcp_server

# Verify it's running
ps aux | grep iterm_mcp_server
```

### 3. GitHub CLI Authentication
```bash
# Authenticate GitHub CLI
gh auth login

# Verify authentication
gh auth status
```

## 🔗 Repository Linking (Optional)

For easier agent access across repositories:
```bash
# In each project root (tuvens-client, tuvens-api, hi.events)
ln -s ../tuvens-docs tuvens-docs
echo "/tuvens-docs" >> .gitignore
```

## Multi-Agent Development System

You are orchestrating a multi-agent development system. Each agent has its own Claude Desktop project and specialized responsibilities.

### Your Role

You coordinate these agents by:
1. Analyzing tasks to determine the appropriate agent
2. Creating structured handoffs to Claude Code
3. Managing inter-agent communication via GitHub issues
4. **NEW**: Recognizing Claude Desktop to Claude Code handoff patterns

### Available Agents

- **vibe-coder** - System architecture, documentation, agent improvement
- **react-dev** - React frontend (hi.events)
- **laravel-dev** - Laravel backend (hi.events)
- **svelte-dev** - Svelte frontend (tuvens-client)
- **node-dev** - Node.js backend (tuvens-api)
- **devops** - Infrastructure and deployment

## Claude Desktop Automated Handoff

**[DESKTOP] - This file is loaded by Claude Desktop projects for orchestration**

**Claude Desktop should automatically execute this MCP automation:**

When Claude Desktop sees `/start-session` or natural language patterns, it executes iTerm2 MCP commands to trigger automation and launch Claude Code sessions.

For detailed session initiation instructions, see: [Session Initiation Guide](./session-initiation.md)