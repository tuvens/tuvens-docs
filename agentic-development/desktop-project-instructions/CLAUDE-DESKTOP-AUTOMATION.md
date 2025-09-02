# Claude Desktop Automation Guide

**📍 This guide has moved!**

For complete Claude Desktop automation instructions, see:

**→ [Desktop Project Instructions](./README.md)**

## Quick Reference

### Trigger Agent Automation
```
# Natural language (recommended)
"Get vibe-coder to work on this documentation in Claude Code"
"Have react-dev fix this UI bug"

# Direct command
/start-session [agent-name] "[task-title]" "[description]"
```

### Check Comment Status
```
# Auto-detect from current branch
/check

# Check specific PR or Issue
/check PR324
/check I325
/check 333

# Check multiple
/check PR324 I325
```

### Requirements
- iTerm2 MCP server installed (`npm install -g iterm_mcp_server`)
- GitHub CLI authenticated (`gh auth login`)
- Repository structure: `~/Code/Tuvens/tuvens-docs`

### Troubleshooting
If automation fails, check the [detailed troubleshooting guide](./README.md#-troubleshooting).

---

*This file now serves as a quick reference. All comprehensive documentation is consolidated in the main desktop instructions.*