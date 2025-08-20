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
4. **NEW**: Recognizing Claude Desktop to Claude Code handoff patterns

## Claude Desktop Handoff Pattern

### When you see this pattern:
```
/start-session [agent-name] [task description]
```

**Immediately translate it to iTerm commands with task context:**

#### **Vibe Coder (System Architecture)**
```
open_terminal name="vibe-coder-session"
execute_command terminal="vibe-coder-session" command="cd ~/Code/Tuvens/tuvens-docs && claude-code --agent vibe-coder --message '[task description]'"
```

#### **Node Dev (tuvens-api)**
```
open_terminal name="node-dev-session"
execute_command terminal="node-dev-session" command="cd ~/Code/Tuvens/tuvens-api && claude-code --agent node-dev --message '[task description]'"
```

#### **Laravel Dev (hi.events)**
```
open_terminal name="laravel-dev-session"
execute_command terminal="laravel-dev-session" command="cd ~/Code/Tuvens/hi.events && claude-code --agent laravel-dev --message '[task description]'"
```

#### **React Dev (hi.events frontend)**
```
open_terminal name="react-dev-session"
execute_command terminal="react-dev-session" command="cd ~/Code/Tuvens/hi.events && claude-code --agent react-dev --message '[task description]'"
```

#### **Svelte Dev (tuvens-client)**
```
open_terminal name="svelte-dev-session"
execute_command terminal="svelte-dev-session" command="cd ~/Code/Tuvens/tuvens-client && claude-code --agent svelte-dev --message '[task description]'"
```

#### **DevOps (Infrastructure) - Context Sensitive**
*Note: DevOps tasks may affect any repository. Ask for clarification if needed.*
```
# Default to infrastructure scripts repository
open_terminal name="devops-session"
execute_command terminal="devops-session" command="cd ~/Code/Tuvens/tuvens-docs && claude-code --agent devops --message '[task description]'"

# For repository-specific DevOps tasks, adjust the path:
# cd ~/Code/Tuvens/[target-repository] && claude-code --agent devops --message '[task description]'
```

**Pattern Recognition:**
- Always recognize variations like `/start-session vibe-coder fix the thing we're talking about`
- Extract the task description and pass it as `--message '[task description]'`
- Map the agent name to the correct repository and claude-code command
- Use descriptive terminal names that include the agent name
- For DevOps: clarify target repository if the task isn't infrastructure-specific

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
Optional enhancement for Claude Desktop to Claude Code handoffs:
```bash
# Install iTerm MCP Server (optional)
npm install -g iterm_mcp_server
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

## Quick Commands

```bash
# Start agent session with context (now works from Claude Desktop!)
/start-session [agent-name] [task description]

# Terminal automation (when iTerm MCP configured)
open_terminal name="[agent]-session"
execute_command terminal="[agent]-session" command="cd ~/Code/Tuvens/[repo] && claude-code --agent [agent] --message '[task description]'"

# Create cross-agent task
/create-issue [from] [to] "[Title]" [repo]

# Resolve issues
/resolve-issue [issue-number]

# Ask cross-repo questions
/ask-question [repo] "[Question]"

# Refactor code properly
/refactor-code [path]
```

## Need Help?

- **Agent responsibilities**: Load specific agent instruction file
- **Workflow details**: Load relevant workflow file
- **System architecture**: `/start-session vibe-coder` for analysis
- **Custom prompts**: Load agent-terminal-prompts.md for task-specific templates
- **Terminal handoffs**: Use the patterns above for Claude Desktop to Claude Code transitions
