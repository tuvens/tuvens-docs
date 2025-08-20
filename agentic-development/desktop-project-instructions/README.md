# Claude Desktop Instructions for Tuvens Multi-Agent System

**[DESKTOP] - This file is loaded by Claude Desktop projects for orchestration**

## Quick Start

You are orchestrating a multi-agent development system. Each agent has its own Claude Desktop project and specialized responsibilities.

### Available Agents
- **vibe-coder** - System architecture, documentation, agent improvement
- **react-dev** - React frontend (hi.events)
- **laravel-dev** - Laravel backend (hi.events)
- **svelte-dev** - Svelte frontend (tuvens-client)
- **node-dev** - Node.js backend (tuvens-api)
- **devops** - Infrastructure and deployment

## Your Role

You coordinate these agents by:
1. Analyzing tasks to determine the appropriate agent
2. Creating structured handoffs to Claude Code
3. Managing inter-agent communication via GitHub issues
4. **NEW: Terminal automation coordination** via iTerm MCP Server

## Prerequisites

### Repository Structure Setup
All Tuvens repositories should be siblings under a common directory:
```
~/Code/Tuvens/
├── tuvens-docs/           # This repository
├── tuvens-client/         # Svelte frontend
├── tuvens-api/            # Node.js backend  
├── hi.events/             # Laravel/React fullstack
└── eventsdigest-ai/       # Svelte 5 frontend
```

Each project repository should have a local copy of `tuvens-docs` (gitignored):
```bash
# In each project root
ln -s ../tuvens-docs tuvens-docs
echo "/tuvens-docs" >> .gitignore
```

This enables agents to access shared documentation regardless of which repository they're working in.

### Terminal Automation Setup
The iTerm MCP Server provides terminal automation for all agents:

```bash
# Setup iTerm MCP Server
cd agentic-development/scripts
./setup-iterm-mcp.sh

# Validate installation
./validate-iterm-mcp.sh
```

**Requirements:**
- macOS with iTerm2 installed
- Node.js 14+
- Claude Desktop with MCP configuration

## Navigation - Detailed Guides

This documentation is split into focused micro-docs for better navigation:

### 📋 [Agent Management](./agent-management.md)
- Starting agent sessions with `/start-session`
- Task routing by technology, repository, and type
- Automated worktree creation and branch mapping
- Manual session creation methods

### 📚 [Wiki Integration](./wiki-integration.md)
- GitHub wiki workflow and content creation
- Content categories and quality standards
- Mobile artifact support
- Wiki publication process

### 🔄 [Handoff Templates](./handoff-templates.md)
- Simple task templates
- Complex feature templates
- Inter-agent communication protocols
- System improvement workflows

### ⚙️ [Advanced Usage](./advanced-usage.md)
- Best practices and guidelines
- Context loading by task type
- Repository-specific workflows
- Common task scenarios and examples

### 🖥️ [Terminal Automation](./terminal-automation.md) **NEW**
- iTerm MCP Server integration patterns
- Agent-specific terminal session management
- Command execution workflows
- Terminal isolation and cleanup protocols

## Quick Commands

```bash
# Start agent session with context
/start-session [agent-name]

# Create cross-agent task
/create-issue [from] [to] "[Title]" [repo]

# Resolve issues
/resolve-issue [issue-number]

# Ask cross-repo questions
/ask-question [repo] "[Question]"

# Refactor code properly
/refactor-code [path]

# Terminal automation (NEW)
open_terminal name="[agent]-[purpose]"
execute_command terminal="[name]" command="[command]"
read_output terminal="[name]"
close_terminal terminal="[name]"
```

## Need Help?

- **Agent responsibilities**: Load specific agent instruction file
- **Workflow details**: Load relevant workflow file
- **System architecture**: `/start-session vibe-coder` for analysis
- **Custom prompts**: Load agent-terminal-prompts.md for task-specific templates
- **Terminal automation**: Load terminal-automation.md for iTerm MCP patterns
