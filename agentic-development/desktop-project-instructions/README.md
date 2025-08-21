# Claude Desktop Instructions for Tuvens Multi-Agent System

**[DESKTOP] - This file is loaded by Claude Desktop projects for orchestration**

## 🚀 NATURAL LANGUAGE AGENT HANDOFFS

**Claude Desktop now recognizes natural language requests for agent handoffs!**

Instead of rigid commands, users can naturally say:

### 💬 Natural Language Examples

**Common Patterns:**
```
"Get vibe-coder to work on this in Claude Code"
"Have the devops agent handle this deployment issue"
"Ask react-dev to fix this UI bug" 
"Let's use Claude Code with laravel-dev for this database task"
"Get Claude Code working on this documentation with vibe coder"
"Have devops set up the CI pipeline in Claude Code"
```

**Claude Desktop Response:**
```
I understand you want [agent] to work on [parsed-task]. 
Should I set up a Claude Code session with:
- Agent: [agent-name]
- Task: [task-title] 
- Context: [description]

Would you like me to proceed? [Yes/No]
```

### ⚡ Quick Commands (Alternative)
For power users, the direct command still works:
```
/start-session [agent-name] "[task-title]" "[description]"
```

**Status: Enhanced Natural Language Support** - Much more intuitive!

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
4. **NEW**: Recognizing Claude Desktop to Claude Code handoff patterns

## Claude Desktop Automated Handoff

### 🚀 NEW: Automated /start-session Workflow

When you see this pattern:
```
/start-session [agent-name] [task-title] [task-description]
```

**Claude Desktop should automatically execute this MCP automation:**

#### **MCP Automation Pattern**
```bash
# Open iTerm terminal with descriptive name
open_terminal name="[agent-name]-session"

# Execute the automation script in that terminal
execute_command terminal="[agent-name]-session" command="cd ~/Code/Tuvens/tuvens-docs && ./start-session [agent-name] \"[task-title]\" \"[task-description]\""
```

**Examples:**
```bash
# When user says: /start-session vibe-coder "API Documentation" "Create comprehensive API docs"
open_terminal name="vibe-coder-session"
execute_command terminal="vibe-coder-session" command="cd ~/Code/Tuvens/tuvens-docs && ./start-session vibe-coder \"API Documentation\" \"Create comprehensive API docs\""

# When user says: /start-session react-dev "Fix UI Bug" "Button not responding on mobile"  
open_terminal name="react-dev-session"
execute_command terminal="react-dev-session" command="cd ~/Code/Tuvens/tuvens-docs && ./start-session react-dev \"Fix UI Bug\" \"Button not responding on mobile\""
```

#### **What Happens in the Terminal:**
1. **Script runs** `setup-agent-task.sh` to create GitHub issue
2. **Sets up** isolated Git worktree with proper branch naming
3. **Generates** agent prompt with full context
4. **Changes directory** to the new worktree
5. **Displays** the agent prompt for copying
6. **Launches** Claude Code automatically (`exec claude`)

#### **User Experience:**
- User types `/start-session` in Claude Desktop chat
- Claude Desktop opens iTerm and runs the automation
- Terminal shows progress, displays prompt, launches Claude Code
- User copies the displayed prompt into Claude Code
- Agent work begins with full context

### 📋 Manual Fallback (Legacy)

If automation fails, use manual MCP commands:

#### **Vibe Coder (System Architecture)**
```
open_terminal name="vibe-coder-session"
execute_command terminal="vibe-coder-session" command="cd ~/Code/Tuvens/tuvens-docs && claude-code --agent vibe-coder --message '[task description]'"
```

#### **Other Agents**
Similar patterns for node-dev, laravel-dev, react-dev, svelte-dev - adjust repository paths accordingly.

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
# 🚀 NEW: Automated start-session (type in Claude Desktop chat)
/start-session [agent-name] "[task-title]" "[task-description]"

# Examples to type in Claude Desktop:
/start-session vibe-coder "Fix Documentation" "Update API reference docs"
/start-session react-dev "UI Bug Fix" "Fix mobile menu not closing"
/start-session devops "Deploy Fix" "Fix staging deployment"

# Claude Desktop will automatically:
# 1. Open iTerm terminal
# 2. Run: cd ~/Code/Tuvens/tuvens-docs && ./start-session [agent] "[title]" "[desc]"
# 3. Create GitHub issue, worktree, and launch Claude Code

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
