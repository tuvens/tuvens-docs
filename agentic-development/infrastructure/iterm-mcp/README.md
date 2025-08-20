# iTerm MCP Server Infrastructure

Complete infrastructure setup for integrating iTerm MCP Server with Claude Desktop to enable automated `/start-session` workflows.

## Quick Start

### 1. Install iTerm MCP Server
```bash
# Navigate to the infrastructure directory
cd agentic-development/infrastructure/iterm-mcp

# Run the installation script
./install-iterm-mcp.sh

# Validate the setup
./validate-setup.sh
```

### 2. Restart Claude Desktop
After installation, restart Claude Desktop to load the new MCP server configuration.

### 3. Test Integration
Open Claude Desktop and try:
- "Show me what's in the current directory"
- "Run a git status check"
- "List all files and tell me about them"

## What This Integration Provides

### For Claude Desktop Users
- **Direct Terminal Control**: Claude can execute commands in your iTerm session
- **Real-time Output Reading**: Claude can see and respond to terminal output
- **Interactive Workflows**: Claude can guide you through complex multi-step processes
- **Automated Setup**: `/start-session` workflows can be fully automated

### For Tuvens Development
- **Seamless Agent Onboarding**: New agent tasks can be set up without manual terminal work
- **Live Debugging**: Claude can troubleshoot setup issues in real-time  
- **Workflow Automation**: Complex development workflows become single-command operations
- **Cross-Repository Coordination**: Claude can navigate between repositories automatically

## Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  Claude Desktop │◄──►│  iTerm MCP      │◄──►│   iTerm2        │
│                 │    │  Server         │    │   Terminal      │
└─────────────────┘    └─────────────────┘    └─────────────────┘
        │                       │                       │
        │                       │                       │
        ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│ MCP Protocol    │    │ npx iterm-mcp   │    │ Active Shell    │
│ Configuration   │    │ Package         │    │ Session         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## File Structure

```
agentic-development/infrastructure/iterm-mcp/
├── install-iterm-mcp.sh          # Main installation script
├── validate-setup.sh             # Comprehensive validation  
├── claude-desktop-config.json    # Configuration template
├── README.md                     # This documentation
└── troubleshooting/
    ├── common-issues.md          # Common problems and solutions
    └── reset-config.sh           # Reset configuration if needed
```

## Detailed Installation Guide

### Prerequisites

1. **macOS Required**: iTerm MCP server only works on macOS with iTerm2
2. **Node.js**: Required for `npx` command execution  
3. **iTerm2**: Available at https://iterm2.com/
4. **Claude Desktop**: Must be installed and configured

### Installation Options

#### Option 1: Automatic Installation (Recommended)
```bash
./install-iterm-mcp.sh
```

#### Option 2: Manual Installation
```bash
# 1. Create/update Claude Desktop config
mkdir -p ~/Library/Application\ Support/Claude

# 2. Add iTerm MCP server configuration
cat > ~/Library/Application\ Support/Claude/claude_desktop_config.json << EOF
{
  "mcpServers": {
    "iterm-mcp": {
      "command": "npx",
      "args": ["-y", "iterm-mcp"]
    }
  }
}
EOF

# 3. Test the server
npx -y iterm-mcp --version
```

#### Option 3: Smithery Installation
```bash
# Using Smithery package manager
npx -y @smithery/cli install iterm-mcp --client claude
```

### Advanced Configuration

#### Custom Configuration Options
```json
{
  "mcpServers": {
    "iterm-mcp": {
      "command": "npx",
      "args": ["-y", "iterm-mcp"],
      "env": {
        "ITERM_MCP_DEBUG": "true"
      }
    }
  }
}
```

#### Multiple MCP Servers
```json
{
  "mcpServers": {
    "iterm-mcp": {
      "command": "npx", 
      "args": ["-y", "iterm-mcp"]
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/allowed/files"]
    }
  }
}
```

## Validation and Testing

### Comprehensive Validation
```bash
# Run full validation suite
./validate-setup.sh

# Quick validation (essential tests only)
./validate-setup.sh --quick

# Show troubleshooting information
./validate-setup.sh --troubleshoot
```

### Manual Testing Steps

1. **Basic Connection Test**:
   ```bash
   # Test if iTerm MCP server responds
   npx -y iterm-mcp --version
   ```

2. **Claude Desktop Integration Test**:
   - Open Claude Desktop
   - Ask: "Can you see my terminal?"
   - Ask: "Run 'echo Hello from iTerm MCP'"

3. **Workflow Integration Test**:
   ```bash
   # Test setup-agent-task.sh via Claude Desktop
   # Ask Claude: "Please run the agent setup script for a test task"
   ```

### Validation Results

The validation script tests:
- ✅ System prerequisites (macOS, Node.js, iTerm2)
- ✅ Claude Desktop configuration
- ✅ iTerm MCP server accessibility
- ✅ JSON configuration validity
- ✅ Integration readiness
- ✅ Security considerations
- ✅ Performance characteristics

## Integration with /start-session Workflow

### Traditional Workflow
1. User runs `/start-session agent-name "Task Title" "Description"`
2. Script creates GitHub issue and worktree
3. Script generates prompt file
4. User manually opens iTerm, navigates to directory
5. User manually runs `claude` command
6. User manually copies and pastes prompt

### Enhanced MCP-Enabled Workflow
1. User runs `/start-session` command **from Claude Desktop**
2. Claude Desktop executes setup-agent-task.sh directly via iTerm MCP
3. Claude Desktop reads command output in real-time
4. Claude Desktop automatically navigates to worktree directory
5. Claude Desktop launches Claude Code session automatically
6. **Zero manual intervention required**

### Example MCP-Enhanced Session Creation

**User in Claude Desktop**: "Please create a new svelte-dev task called 'Fix Button Component' to resolve the non-responsive button in the header"

**Claude Desktop Response**:
```
I'll create that task for you using the iTerm MCP integration.

*Executing setup-agent-task.sh...*
✅ Created GitHub issue #247
✅ Created branch: svelte-dev/feature/fix-button-component  
✅ Created worktree: ~/Code/Tuvens/tuvens-client/worktrees/svelte-dev-fix-button-component
✅ Generated agent prompt

*Navigating to worktree...*
*Launching Claude Code session...*

Your svelte-dev agent session is now ready! The Claude Code session should be starting automatically in your terminal.
```

## Security Considerations

### Important Safety Notes

⚠️ **FULL TERMINAL ACCESS**: iTerm MCP grants Claude Desktop complete access to your terminal
⚠️ **COMMAND EXECUTION**: Claude can run any command you can run
⚠️ **FILE SYSTEM ACCESS**: Claude can read/write files within terminal permissions

### Security Best Practices

1. **Monitor All Activity**: Always watch what Claude is doing in your terminal
2. **Interrupt When Needed**: Use Ctrl+C to stop unwanted command execution
3. **Start Small**: Begin with simple tasks to understand Claude's behavior
4. **Review Commands**: Ask Claude to explain commands before execution
5. **Backup Important Data**: Ensure backups before complex operations

### Emergency Procedures

#### Stop All Claude Activity
```bash
# In iTerm terminal
Ctrl+C          # Stop current command
killall node    # Stop all Node.js processes (including MCP server)
```

#### Disable MCP Integration
```bash
# Temporarily disable by removing config
mv ~/Library/Application\ Support/Claude/claude_desktop_config.json ~/Library/Application\ Support/Claude/claude_desktop_config.json.disabled

# Restart Claude Desktop
```

#### Reset Configuration
```bash
./troubleshooting/reset-config.sh
```

## Troubleshooting

### Common Issues

1. **"MCP server not responding"**
   - Restart Claude Desktop
   - Check iTerm2 is running and active
   - Verify network connectivity for npx downloads

2. **"Permission denied" errors**  
   - Check macOS security settings
   - Ensure Claude Desktop has terminal access permissions
   - Verify file permissions on config directory

3. **"Command not found" errors**
   - Ensure Node.js and npx are installed
   - Check PATH environment variable
   - Try running `npx -y iterm-mcp --version` manually

4. **"JSON syntax error"**
   - Validate configuration with: `jq . ~/Library/Application\ Support/Claude/claude_desktop_config.json`
   - Use the provided template: `claude-desktop-config.json`
   - Restore from backup if needed

### Getting Help

1. **Run Validation**: `./validate-setup.sh --troubleshoot`
2. **Check Logs**: Look in Claude Desktop logs (typically in ~/Library/Logs/)  
3. **Reset Configuration**: Use `./troubleshooting/reset-config.sh`
4. **Report Issues**: File issues in the tuvens-docs repository with validation output

## Performance Optimization

### First Run Optimization
```bash
# Pre-install iterm-mcp globally to avoid download delays
npm install -g iterm-mcp

# Update Claude Desktop config to use global install
{
  "mcpServers": {
    "iterm-mcp": {
      "command": "iterm-mcp"
    }
  }
}
```

### Connection Speed
- First MCP connection may take 5-10 seconds (package download)
- Subsequent connections should be under 2 seconds
- Global package installation eliminates download delays

## Development and Contributing

### Testing Changes
```bash
# Test installation script
./install-iterm-mcp.sh --dry-run

# Test validation
./validate-setup.sh --quick

# Test uninstallation  
./install-iterm-mcp.sh --uninstall --dry-run
```

### Adding Features
1. Update installation script with new functionality
2. Add corresponding validation tests
3. Update documentation
4. Test across different environments

## Version History

- **v1.0**: Initial implementation with basic iTerm MCP integration
  - Installation script with dry-run support
  - Comprehensive validation suite  
  - Claude Desktop configuration management
  - Integration with existing /start-session workflow

## Related Documentation

- [Model Context Protocol Documentation](https://modelcontextprotocol.io/)
- [iTerm MCP Server Repository](https://github.com/ferrislucas/iterm-mcp)
- [Claude Desktop MCP Configuration Guide](https://docs.anthropic.com/claude/docs/desktop-mcp)
- [Tuvens /start-session Integration Guide](../workflows/start-session-integration.md)