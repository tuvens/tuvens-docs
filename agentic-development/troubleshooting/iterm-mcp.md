# iTerm MCP Server Troubleshooting Guide

**[ISSUE #203] - Complete iTerm MCP Server Integration**

## Overview

This guide helps troubleshoot common issues with iTerm MCP server integration in the Tuvens agentic development system. It complements the handoff patterns documented in PR #204.

## Quick Diagnostics

### 🔍 Run Validation First

Before troubleshooting, run the validation script:

```bash
./agentic-development/scripts/validate-iterm-mcp.sh --verbose
```

This will identify most common issues and provide specific guidance.

## Common Issues & Solutions

### 1. iTerm Automation Not Working

**Symptoms:**
- `/start-session` commands don't open iTerm windows
- "Could not communicate with iTerm" errors
- AppleScript timeout errors

**Solutions:**

#### A. Grant Accessibility Permissions

1. Open **System Preferences** → **Security & Privacy** → **Privacy**
2. Select **Accessibility** from the list
3. Add and enable:
   - **iTerm2** (if not listed, drag from `/Applications/iTerm.app`)
   - **Claude** (Claude Desktop app)
   - **Terminal** (if using Terminal instead of iTerm)

#### B. Enable iTerm Automation

1. In iTerm2: **Preferences** → **General** → **Magic**
2. Check **"Enable Python API"**
3. Check **"Allow AI assistant to control iTerm"**
4. Restart iTerm2

#### C. Test AppleScript Communication

```bash
# Test basic iTerm communication
osascript -e 'tell application "iTerm2" to get name'

# Test window creation
osascript -e 'tell application "iTerm2" to create window with default profile'
```

### 2. Claude Desktop MCP Connection Issues

**Symptoms:**
- MCP server not found in Claude Desktop
- Connection timeouts
- "Server not responding" errors

**Solutions:**

#### A. Check Claude Desktop Configuration

Configuration file location:
```
~/Library/Application Support/Claude/claude_desktop_config.json
```

Example configuration:
```json
{
  "mcpServers": {
    "iterm": {
      "command": "node",
      "args": ["/path/to/iterm-mcp-server/src/index.js"],
      "env": {
        "ITERM_MCP_DEBUG": "1"
      }
    }
  }
}
```

#### B. Verify Server Installation

```bash
# Check if MCP server is installed
npm list -g iterm_mcp_server

# If not found, install
npm install -g iterm_mcp_server

# Test server directly
node /usr/local/lib/node_modules/iterm_mcp_server/src/index.js
```

#### C. Debug MCP Connection

1. Enable debug mode in configuration
2. Check Claude Desktop logs:
   ```bash
   tail -f ~/Library/Logs/Claude/claude.log
   ```
3. Look for MCP connection errors

### 3. Agent Session Handoff Failures

**Symptoms:**
- `/start-session` recognized but agent doesn't start correctly
- Wrong repository directory
- Agent identity not loaded

**Solutions:**

#### A. Verify Agent Mapping

Check that the agent exists in the system:
```bash
ls -la ~/.claude/agents/
# Should show: vibe-coder.md, node-dev.md, etc.
```

#### B. Test Repository Paths

Ensure directories exist:
```bash
# Test common agent directories
ls -la ~/Code/Tuvens/tuvens-docs  # vibe-coder
ls -la ~/Code/Tuvens/tuvens-api   # node-dev
ls -la ~/Code/Tuvens/tuvens-client # svelte-dev
```

#### C. Manual Session Test

Try starting agent sessions manually:
```bash
cd ~/Code/Tuvens/tuvens-docs
claude-code --agent vibe-coder --message "test session"
```

### 4. GitHub MCP Protection Conflicts

**Symptoms:**
- MCP protection blocking operations
- Branch switching issues
- Emergency override needed

**Solutions:**

#### A. Check Protection Status

```bash
./agentic-development/scripts/github-mcp-protection.sh --check
```

#### B. Proper Branch Creation

Ensure branch follows naming convention:
```bash
git checkout -b vibe-coder/feature/descriptive-name
```

#### C. Emergency Override (Use Sparingly)

```bash
./agentic-development/scripts/github-mcp-protection.sh --emergency "reason for override"
# Follow the generated instructions
```

### 5. Node.js and MCP SDK Issues

**Symptoms:**
- "Cannot find module @modelcontextprotocol/sdk"
- Node.js version compatibility errors
- npm installation failures

**Solutions:**

#### A. Update Node.js

```bash
# Check current version
node --version

# Update to latest LTS (18+ required for MCP)
# Using nvm:
nvm install --lts
nvm use --lts

# Using homebrew:
brew upgrade node
```

#### B. Install/Reinstall MCP SDK

```bash
# Clean install
npm uninstall -g @modelcontextprotocol/sdk
npm install -g @modelcontextprotocol/sdk

# Verify installation
npm list -g @modelcontextprotocol/sdk
```

#### C. Fix npm Permissions

```bash
# If getting permission errors
sudo chown -R $(whoami) $(npm config get prefix)/{lib/node_modules,bin,share}
```

### 6. Performance and Timeout Issues

**Symptoms:**
- Slow iTerm window creation
- AppleScript timeouts
- MCP server lag

**Solutions:**

#### A. Increase Timeouts

In MCP configuration, add timeout settings:
```json
{
  "mcpServers": {
    "iterm": {
      "command": "node",
      "args": ["/path/to/iterm-mcp-server/src/index.js"],
      "timeout": 30000
    }
  }
}
```

#### B. Optimize iTerm Settings

1. **iTerm2** → **Preferences** → **Profiles** → **Session**
2. Uncheck **"Automatically log session input to files in:"**
3. Set **"Scrollback lines"** to reasonable number (1000-10000)

#### C. Reduce System Load

- Close unnecessary applications
- Restart iTerm2 if it's been running for a long time
- Check Activity Monitor for high CPU processes

## Advanced Troubleshooting

### Debug Mode

Enable verbose logging by setting environment variable:
```bash
export ITERM_MCP_DEBUG=1
export MCP_CLIENT_DEBUG=1
```

### Log Locations

- **Claude Desktop:** `~/Library/Logs/Claude/claude.log`
- **iTerm MCP Server:** Check console output when running manually
- **GitHub MCP Protection:** `${TMPDIR}/github-mcp-protection/protection.log`

### Manual Testing Sequence

1. **Test iTerm AppleScript:**
   ```bash
   osascript -e 'tell application "iTerm2" to create window with default profile'
   ```

2. **Test Claude Code:**
   ```bash
   claude-code --version
   claude-code --help
   ```

3. **Test MCP Server:**
   ```bash
   node /path/to/iterm-mcp-server/src/index.js
   # Should start without errors
   ```

4. **Test Full Handoff:**
   In Claude Desktop, try: `/start-session vibe-coder test integration`

## Getting Help

### 1. Validation Script Output
Always include the output of:
```bash
./agentic-development/scripts/validate-iterm-mcp.sh --verbose
```

### 2. System Information
```bash
# System info
uname -a
sw_vers

# Node.js info
node --version
npm --version

# iTerm info
defaults read /Applications/iTerm.app/Contents/Info CFBundleShortVersionString
```

### 3. Error Logs
Include relevant log excerpts from:
- Claude Desktop logs
- Terminal/iTerm output
- Console.app (for system-level errors)

## Integration with PR #204

This troubleshooting guide works with the handoff patterns documented in PR #204:

- **Pattern Recognition:** `/start-session [agent] [task]` should work after resolving issues above
- **Agent Mapping:** Troubleshoot specific agent-to-repository mappings
- **Command Translation:** Debug the Claude Desktop → iTerm command translation

## Prevention

### Regular Maintenance

1. **Weekly:** Run validation script to catch issues early
2. **After macOS updates:** Re-grant accessibility permissions if needed
3. **After Claude Desktop updates:** Verify MCP configuration still works
4. **After iTerm updates:** Test AppleScript automation

### Best Practices

- Keep Node.js and npm updated
- Use specific iTerm2 profiles for agent work
- Don't modify system security settings unnecessarily
- Test handoffs in non-production environments first

---

**Related Documents:**
- GitHub Issue #203: Complete iTerm MCP Server integration
- PR #204: Claude Desktop to Claude Code handoff patterns
- `agentic-development/scripts/validate-iterm-mcp.sh`
- `agentic-development/scripts/github-mcp-protection.sh`

**Last Updated:** 2025-08-20  
**Maintained By:** Vibe Coder Agent