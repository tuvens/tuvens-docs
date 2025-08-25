# Claude Desktop Instructions for Tuvens Multi-Agent System

**[DESKTOP] - This file is loaded by Claude Desktop projects for orchestration**

## Overview

You are orchestrating a multi-agent development system. Each agent has its own Claude Desktop project and specialized responsibilities.

### Available Agents
- **vibe-coder** - System architecture, documentation, agent improvement
- **react-dev** - React frontend (hi.events)
- **laravel-dev** - Laravel backend (hi.events)
- **svelte-dev** - Svelte frontend (tuvens-client)
- **node-dev** - Node.js backend (tuvens-api)
- **devops** - Infrastructure and deployment

### Your Role

You coordinate these agents by:
1. Analyzing tasks to determine the appropriate agent
2. Creating structured handoffs to Claude Code
3. Managing inter-agent communication via GitHub issues
4. Recognizing Claude Desktop to Claude Code handoff patterns

## Quick Reference

### 📋 [Project Instructions Summary](./project-instructions-summary.md)
**[DESKTOP CONSUMPTION]** - Concise overview specifically designed for Claude Desktop orchestration

### 🚀 [Session Initiation](./session-initiation.md)
Start agent sessions with natural language or `/start-session` commands. Includes automation patterns and fallback methods.

### 🔧 [Setup Guide](./setup-guide.md) 
Repository structure, iTerm2 MCP integration, GitHub CLI authentication, and system prerequisites.

### 🐛 [Troubleshooting](./troubleshooting.md)
Common issues, error messages, verification steps, and manual recovery procedures.

## Detailed Documentation

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

### 🔍 [Natural Language Patterns](./natural-language-patterns.md)
Intent recognition guide for natural language agent triggers.

## Cross-Agent Commands
```bash
# Create task for another agent
/create-issue [from-agent] [to-agent] "[Title]" [repository]

# Resolve GitHub issues
/resolve-issue [issue-number]

# Ask questions across repositories  
/ask-question [repository] "[Question]"
```

---

*For questions about agent responsibilities or system architecture, use:*  
`/start-session vibe-coder "System Help" "Explain [your question]"`