# Claude Desktop Automation Guide

**Quick Start for Claude Desktop Users**

## 💬 Natural Language Agent Handoffs

Claude Desktop now understands natural language requests for agent handoffs! Simply ask in normal conversation.

### 🎯 Natural Language Examples

**Just say what you want:**
```
"Get vibe-coder to work on this documentation in Claude Code"
"Have the devops agent handle this deployment issue"
"Ask react-dev to fix this UI bug"
"Let's use Claude Code with laravel-dev for this database task"
"Get Claude Code working on this with the vibe coder"
```

**Claude Desktop will confirm:**
```
I understand you want vibe-coder to work on the documentation issue.
Should I set up a Claude Code session with:
• Agent: vibe-coder
• Task: Documentation Update  
• Context: Fix API reference docs

Would you like me to proceed? [Yes/No]
```

### ⚡ Direct Commands (Alternative)

For power users, the direct command still works:
```
/start-session [agent-name] "[task-title]" "[task-description]"
```

**Examples:**
```
/start-session vibe-coder "Fix Documentation" "Update API reference docs"
/start-session react-dev "UI Bug Fix" "Fix mobile menu not closing"  
/start-session devops "Deploy Pipeline" "Set up CI/CD for staging"
```

### What Happens Automatically

1. **Claude Desktop uses iTerm2 MCP** to open a terminal window
2. **Automation script runs** creating GitHub issue and Git worktree
3. **Agent prompt is displayed** with full task context
4. **Claude Code launches** in the prepared workspace
5. **You copy the prompt** and begin agent work immediately

### Behind the Scenes

When you type `/start-session`, Claude Desktop executes:
```bash
open_terminal name="[agent]-session"
execute_command terminal="[agent]-session" command="cd ~/Code/Tuvens/tuvens-docs && ./start-session [agent] \"[title]\" \"[description]\""
```

## 📁 Implementation Files

- **`/start-session`** - Main entry point script
- **`agentic-development/scripts/setup-agent-task-desktop.sh`** - Desktop adapter
- **`agentic-development/scripts/setup-agent-task.sh`** - Core automation engine
- **`agentic-development/desktop-project-instructions/`** - Detailed documentation

## 📖 Detailed Documentation

For complete instructions and advanced usage:
**→ [Desktop Project Instructions](./agentic-development/desktop-project-instructions/README.md)**

## 🔧 Requirements

- iTerm2 MCP server running
- Claude Desktop with MCP integration enabled
- Git repository structure: `~/Code/Tuvens/tuvens-docs`
- GitHub CLI (`gh`) authenticated

## ⚡ Quick Troubleshooting

**If automation fails:**
1. Ensure you're in the correct repository structure
2. Check that `./start-session` script exists in repo root
3. Verify GitHub CLI is authenticated: `gh auth status`
4. Check iTerm2 MCP is running: `ps aux | grep iterm_mcp_server`

**For detailed troubleshooting and advanced features:**
→ [Desktop Project Instructions](./agentic-development/desktop-project-instructions/README.md)

---

*This automation replicates the Claude Code `/start-session` workflow for Claude Desktop users, providing seamless agent handoffs with full context preservation.*