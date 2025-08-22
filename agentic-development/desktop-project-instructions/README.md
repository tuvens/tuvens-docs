# Claude Desktop Instructions for Tuvens Multi-Agent System

**[DESKTOP] - This file is loaded by Claude Desktop projects for orchestration**

## 🚀 Quick Start: Trigger Agent Automation

### Method 1: Enhanced Natural Language Recognition
Claude Desktop now recognizes MANY flexible patterns:

**Start Session Patterns:**
```
"start session with vibe-coder"
"begin devops session for deployment"
"start working with react-dev on this bug"
"initiate laravel-dev session"
"get vibe-coder started on documentation"
```

**Traditional Handoff Patterns:**
```
"Get vibe-coder to work on this documentation in Claude Code"
"Have the devops agent handle this deployment issue"
"Ask react-dev to fix this UI bug"
"Let's use Claude Code with laravel-dev for this database task"
"Get Claude Code working on this documentation with vibe coder"
"Have devops set up the CI pipeline in Claude Code"
```

**Casual /start-session Commands:**
```
"/start-session vibe-coder fix the docs"
"/start-session react-dev UI bug"
"/start-session devops"
"/start-session laravel-dev API endpoints"
```

Claude Desktop will automatically:
1. **Recognize flexible patterns** - `/start-session`, natural language, or casual formats
2. **Extract context intelligently** - from conversation, explicit descriptions, or recent messages  
3. **Fuzzy match agent names** - "vibe" → "vibe-coder", "react" → "react-dev"
4. **Confirm and trigger** - Show confirmation then execute iTerm2 MCP automation
5. **Complete automation** - Create GitHub issue, setup worktree, and launch Claude Code

### Method 2: Direct Command
For precise control:
```
/start-session [agent-name] "[task-title]" "[task-description]"
```

**Examples:**
```
/start-session vibe-coder "Fix Documentation" "Update API reference docs"
/start-session react-dev "UI Bug Fix" "Fix mobile menu not closing"
/start-session devops "Deploy Pipeline" "Set up CI/CD for staging"
```

---

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
4. **NEW**: Recognizing flexible Claude Desktop to Claude Code handoff patterns

## Claude Desktop Automated Handoff

### 🚀 NEW: Enhanced /start-session Pattern Recognition

**Claude Desktop now recognizes FLEXIBLE /start-session patterns:**

**Exact Command Format:**
```
/start-session [agent-name] [task-title] [task-description]
```

**Natural Language Variations:**
```
"start session with [agent]"
"begin [agent] session"  
"start [agent] work on [task]"
"initiate [agent] session for [task]"
"/start-session [agent]" (with context from conversation)
"start working with [agent] on this"
"get [agent] started on [task]"
```

**Casual Format Examples:**
```
"/start-session vibe-coder fix the docs"
"/start-session react-dev UI bug fix" 
"start session with devops for deployment"
"start working with laravel-dev on the API"
```

**Claude Desktop should automatically execute this MCP automation for ANY of these patterns:**

## ⚡ How The Automation Works

When Claude Desktop sees `/start-session` or natural language patterns, it executes:

```bash
# Opens iTerm2 with descriptive name
open_terminal name="[agent-name]-session"

# Runs automation in the terminal 
execute_command terminal="[agent-name]-session" command="cd ~/Code/Tuvens/tuvens-docs && ./start-session [agent-name] \"[task-title]\" \"[task-description]\""
```

### What Happens Step-by-Step
1. **GitHub Issue Created** - Task is logged with agent assignment
2. **Git Worktree Setup** - Isolated workspace with proper branch naming
3. **Agent Prompt Generated** - Full context prompt appears in terminal
4. **Claude Code Launches** - Ready for you to paste the prompt and begin work

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

## 🐛 Troubleshooting

**If automation fails to trigger:**
1. Check repository structure: `ls ~/Code/Tuvens/` should show all repos
2. Verify start-session script: `ls ~/Code/Tuvens/tuvens-docs/start-session`
3. Test GitHub CLI: `gh repo view` should work
4. Check iTerm MCP: Look for `iterm_mcp_server` in running processes

**Common issues:**
- **"Script not found"**: Ensure you're in `~/Code/Tuvens/tuvens-docs`
- **"GitHub authentication failed"**: Run `gh auth login`
- **"iTerm not responding"**: Restart iTerm MCP server

### 📋 Manual Fallback (If Automation Fails)

If the automated `/start-session` doesn't work, use manual MCP commands:

**For any agent:**
```
open_terminal name="[agent-name]-session"
execute_command terminal="[agent-name]-session" command="cd ~/Code/Tuvens/tuvens-docs && ./start-session [agent-name] \"[task-title]\" \"[task-description]\""
```

**Example:**
```
open_terminal name="vibe-coder-session"
execute_command terminal="vibe-coder-session" command="cd ~/Code/Tuvens/tuvens-docs && ./start-session vibe-coder \"Documentation Fix\" \"Update API reference\""
```

### 🔗 Repository Linking (Optional)
For easier agent access across repositories:
```bash
# In each project root (tuvens-client, tuvens-api, hi.events)
ln -s ../tuvens-docs tuvens-docs
echo "/tuvens-docs" >> .gitignore
```

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

---

## 📋 Available Agents

Choose the right agent for your task:

- **vibe-coder** - System architecture, documentation, agent coordination
- **react-dev** - React frontend development (hi.events)
- **laravel-dev** - Laravel backend development (hi.events)
- **svelte-dev** - Svelte frontend development (tuvens-client)
- **node-dev** - Node.js backend development (tuvens-api)
- **devops** - Infrastructure, deployment, CI/CD

## 📖 Additional Resources

### Cross-Agent Commands
```bash
# Create task for another agent
/create-issue [from-agent] [to-agent] "[Title]" [repository]

# Resolve GitHub issues
/resolve-issue [issue-number]

# Ask questions across repositories  
/ask-question [repository] "[Question]"
```

### Advanced Guides
- **[Agent Management](./agent-management.md)** - Detailed agent selection and task routing
- **[Natural Language Patterns](./natural-language-patterns.md)** - Intent recognition guide
- **[Advanced Usage](./advanced-usage.md)** - Complex scenarios and best practices

## ✅ Success Indicators

**You'll know the automation is working when:**
1. Typing `/start-session [agent] "[task]" "[description]"` opens iTerm2
2. The terminal shows GitHub issue creation and worktree setup
3. Claude Code launches automatically with the agent context
4. The agent prompt appears ready to copy into Claude Code

**If any step fails, check the [Troubleshooting](#-troubleshooting) section above.**

---

*For questions about agent responsibilities or system architecture, use:*  
`/start-session vibe-coder "System Help" "Explain [your question]"`
