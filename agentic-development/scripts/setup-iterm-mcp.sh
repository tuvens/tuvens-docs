#!/bin/bash

# iTerm MCP Server Setup Script for Tuvens Multi-Agent System
# Integrates terminal automation capabilities for all agents

set -e

# Color output functions
print_status() { echo -e "\033[1;34m[INFO]\033[0m $1"; }
print_success() { echo -e "\033[1;32m[SUCCESS]\033[0m $1"; }
print_warning() { echo -e "\033[1;33m[WARNING]\033[0m $1"; }
print_error() { echo -e "\033[1;31m[ERROR]\033[0m $1"; }

# Check if running on macOS (iTerm2 requirement)
check_macos() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "iTerm MCP Server requires macOS and iTerm2"
        print_status "For other platforms, consider using a generic terminal MCP server"
        exit 1
    fi
    print_success "macOS detected - compatible with iTerm2"
}

# Check if iTerm2 is installed
check_iterm2() {
    if ! command -v iTerm &> /dev/null && [[ ! -d "/Applications/iTerm.app" ]]; then
        print_warning "iTerm2 not found"
        print_status "Please install iTerm2: https://iterm2.com/"
        echo "Would you like to continue setup anyway? (y/n)"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "iTerm2 installation detected"
    fi
}

# Check Node.js version
check_node() {
    if ! command -v node &> /dev/null; then
        print_error "Node.js is required but not installed"
        print_status "Install Node.js: https://nodejs.org/"
        exit 1
    fi
    
    NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
    if [[ $NODE_VERSION -lt 14 ]]; then
        print_error "Node.js version 14+ required (current: $(node -v))"
        exit 1
    fi
    print_success "Node.js $(node -v) detected"
}

# Install iTerm MCP Server
install_iterm_mcp() {
    print_status "Installing iTerm MCP Server..."
    
    # Install globally for system-wide access
    if npm install -g iterm_mcp_server; then
        print_success "iTerm MCP Server installed successfully"
    else
        print_error "Failed to install iTerm MCP Server"
        print_status "Trying local installation..."
        npm install iterm_mcp_server
        print_warning "Installed locally - you may need to adjust Claude Desktop config paths"
    fi
}

# Create Claude Desktop configuration template
create_claude_config() {
    local CONFIG_FILE="claude_desktop_config_iterm_template.json"
    
    print_status "Creating Claude Desktop configuration template..."
    
    cat > "$CONFIG_FILE" << 'EOF'
{
  "mcpServers": {
    "terminal": {
      "command": "npx",
      "args": ["iterm_mcp_server"]
    }
  }
}
EOF

    print_success "Claude Desktop config template created: $CONFIG_FILE"
    print_status "Merge this with your existing ~/.config/claude/claude_desktop_config.json"
}

# Create environment configuration
create_env_config() {
    local ENV_FILE=".env.iterm-mcp"
    
    print_status "Creating environment configuration..."
    
    cat > "$ENV_FILE" << 'EOF'
# iTerm MCP Server Configuration
# No additional environment variables required for basic iTerm MCP functionality

# Optional: Configure terminal preferences
ITERM_DEFAULT_PROFILE="Default"
ITERM_WORKING_DIRECTORY=""

# Security: Terminal command execution settings
ITERM_ALLOW_SHELL_COMMANDS=true
ITERM_RESTRICTED_MODE=false

# Multi-Agent Settings
AGENT_TERMINAL_PREFIX="tuvens-agent"
TERMINAL_SESSION_TIMEOUT=3600
EOF

    print_success "Environment config created: $ENV_FILE"
}

# Create validation script
create_validation_script() {
    local VALIDATION_SCRIPT="validate-iterm-mcp.sh"
    
    print_status "Creating validation script..."
    
    cat > "$VALIDATION_SCRIPT" << 'EOF'
#!/bin/bash

# iTerm MCP Server Validation Script

set -e

echo "🔧 iTerm MCP Server Validation"
echo "=============================="

# Check Node.js
if command -v node &> /dev/null; then
    echo "✅ Node.js: $(node -v)"
else
    echo "❌ Node.js not found"
    exit 1
fi

# Check iTerm MCP Server installation (handles both global and local)
if command -v iterm_mcp_server &> /dev/null || npm list -g iterm_mcp_server &> /dev/null || [ -f "./node_modules/.bin/iterm_mcp_server" ]; then
    echo "✅ iTerm MCP Server installed"
else
    echo "❌ iTerm MCP Server not found"
    echo "Run: npm install -g iterm_mcp_server"
    exit 1
fi

# Check iTerm2
if [[ -d "/Applications/iTerm.app" ]] || command -v iTerm &> /dev/null; then
    echo "✅ iTerm2 detected"
else
    echo "⚠️  iTerm2 not found - required for full functionality"
fi

# Check Claude Desktop config
CLAUDE_CONFIG="$HOME/.config/claude/claude_desktop_config.json"
if [[ -f "$CLAUDE_CONFIG" ]]; then
    if grep -q "iterm_mcp_server" "$CLAUDE_CONFIG"; then
        echo "✅ Claude Desktop configured for iTerm MCP"
    else
        echo "⚠️  Claude Desktop config exists but iTerm MCP not configured"
        echo "Add the configuration from claude_desktop_config_iterm_template.json"
    fi
else
    echo "⚠️  Claude Desktop config not found"
    echo "Create: $CLAUDE_CONFIG"
fi

echo ""
echo "Validation complete!"
EOF

    chmod +x "$VALIDATION_SCRIPT"
    print_success "Validation script created: $VALIDATION_SCRIPT"
}

# Create usage documentation
create_usage_docs() {
    local USAGE_FILE="ITERM_MCP_USAGE.md"
    
    print_status "Creating usage documentation..."
    
    cat > "$USAGE_FILE" << 'EOF'
# iTerm MCP Server Usage Guide

## Multi-Agent Terminal Sessions

### Available Tools

1. **open_terminal**: Create new terminal instances
2. **execute_command**: Run commands in specific terminals
3. **read_output**: Get command output from terminals
4. **close_terminal**: Clean up terminal sessions
5. **list_terminals**: View all active terminal sessions

## Agent-Specific Terminal Patterns

### Node.js Development (node-dev agent)
```
# Start dedicated Node.js development terminal
open_terminal name="node-dev-main" profile="Node Development"

# Run development server
execute_command terminal="node-dev-main" command="npm run dev"

# Run tests in separate terminal
open_terminal name="node-dev-test" 
execute_command terminal="node-dev-test" command="npm test -- --watch"
```

### Laravel Development (laravel-dev agent)
```
# PHP development environment
open_terminal name="laravel-dev-main"
execute_command terminal="laravel-dev-main" command="php artisan serve"

# Database operations
open_terminal name="laravel-db"
execute_command terminal="laravel-db" command="php artisan tinker"
```

### React Development (react-dev agent)
```
# React development server
open_terminal name="react-dev-main"
execute_command terminal="react-dev-main" command="npm start"

# Storybook for component development
open_terminal name="react-storybook"
execute_command terminal="react-storybook" command="npm run storybook"
```

### Svelte Development (svelte-dev agent)
```
# Svelte development server
open_terminal name="svelte-dev-main"
execute_command terminal="svelte-dev-main" command="npm run dev"
```

### DevOps Operations (devops agent)
```
# Docker operations
open_terminal name="devops-docker"
execute_command terminal="devops-docker" command="docker-compose up -d"

# Monitoring
open_terminal name="devops-logs"
execute_command terminal="devops-logs" command="kubectl logs -f deployment/api"
```

## Terminal Session Management

### Session Isolation
Each agent should create named terminal sessions to avoid conflicts:
- **Naming Convention**: `{agent-name}-{purpose}`
- **Example**: `node-dev-main`, `laravel-dev-test`, `devops-monitor`

### Cleanup Protocol
Always clean up terminal sessions when tasks complete:
```
# List active terminals
list_terminals

# Close specific terminal
close_terminal terminal="node-dev-main"
```

### Output Monitoring
Read command output to verify success:
```
# Execute command and read output
execute_command terminal="node-dev-main" command="npm run build"
read_output terminal="node-dev-main"
```

## Integration with Git Workflows

### Branch Operations
```
# Create and switch to feature branch
execute_command terminal="main" command="git checkout -b feature/new-component"

# Check branch status
execute_command terminal="main" command="git status"
read_output terminal="main"
```

### Automated Testing
```
# Run tests before commit
execute_command terminal="test" command="npm test"
read_output terminal="test"

# If tests pass, proceed with commit
execute_command terminal="main" command="git add . && git commit -m 'Add new component'"
```

## Security Considerations

### Command Validation
- Always validate commands before execution
- Use read_output to verify command success
- Implement timeouts for long-running commands

### Terminal Isolation
- Each agent uses separate terminal sessions
- Avoid sharing terminals between different tasks
- Clean up sessions after task completion

### Access Control
- Commands are executed with user permissions
- No elevated privileges by default
- Be cautious with destructive operations

## Troubleshooting

### Terminal Not Responding
```
# Check if terminal is still active
list_terminals

# If unresponsive, close and recreate
close_terminal terminal="problematic-terminal"
open_terminal name="new-terminal"
```

### Command Execution Failures
```
# Read error output
read_output terminal="terminal-name"

# Check terminal status
list_terminals
```

### iTerm2 Integration Issues
1. Ensure iTerm2 is running
2. Check iTerm2 preferences for automation access
3. Verify MCP server is properly connected

## Best Practices

1. **Always name your terminals** with descriptive, agent-specific names
2. **Read output after commands** to verify success
3. **Clean up terminals** when tasks complete
4. **Use separate terminals** for different purposes (dev server, tests, etc.)
5. **Monitor long-running processes** periodically
6. **Validate commands** before execution in production environments

For more information, see the iTerm MCP Server documentation at:
https://github.com/rishabkoul/iTerm-MCP-Server
EOF

    print_success "Usage documentation created: $USAGE_FILE"
}

# Create quick start guide
create_quick_start() {
    local QUICK_START="QUICK_START_ITERM.md"
    
    print_status "Creating quick start guide..."
    
    cat > "$QUICK_START" << 'EOF'
# iTerm MCP Server Quick Start

## 1. Prerequisites
- macOS with iTerm2 installed
- Node.js 14+ 
- Claude Desktop

## 2. Installation
```bash
# Run the setup script
./setup-iterm-mcp.sh
```

## 3. Configuration
```bash
# Update Claude Desktop config
# Merge claude_desktop_config_iterm_template.json with:
# ~/.config/claude/claude_desktop_config.json

# Apply environment settings
cp .env.iterm-mcp .env
```

## 4. Validation
```bash
# Verify installation
./validate-iterm-mcp.sh
```

## 5. Restart Claude Desktop
After configuration, restart Claude Desktop to load the iTerm MCP server.

## 6. Test Basic Functionality
In Claude Desktop, try:
```
open_terminal name="test-terminal"
execute_command terminal="test-terminal" command="echo 'Hello from iTerm MCP!'"
read_output terminal="test-terminal"
close_terminal terminal="test-terminal"
```

## 7. Multi-Agent Integration
See ITERM_MCP_USAGE.md for agent-specific terminal patterns and best practices.

## Troubleshooting
- Ensure iTerm2 is running
- Check Claude Desktop console for MCP connection errors
- Verify Node.js and npm are properly installed
- Run validation script to identify issues

For detailed usage, see ITERM_MCP_USAGE.md
EOF

    print_success "Quick start guide created: $QUICK_START"
}

# Main installation flow
main() {
    echo
    print_status "Starting iTerm MCP Server setup for Tuvens multi-agent system..."
    echo
    
    # Prerequisites
    check_macos
    check_iterm2
    check_node
    
    echo
    print_status "Installing iTerm MCP Server..."
    
    # Install MCP server
    install_iterm_mcp
    
    echo
    print_status "Creating configuration files..."
    
    # Create configuration files
    create_claude_config
    create_env_config
    create_validation_script
    create_usage_docs
    create_quick_start
    
    echo
    print_success "iTerm MCP Server setup completed!"
    echo
    print_status "Next steps:"
    echo "1. Merge claude_desktop_config_iterm_template.json with your Claude Desktop config"
    echo "2. Copy .env.iterm-mcp settings to your main .env file"
    echo "3. Restart Claude Desktop"
    echo "4. Run ./validate-iterm-mcp.sh to verify setup"
    echo "5. See QUICK_START_ITERM.md for testing instructions"
    echo "6. See ITERM_MCP_USAGE.md for multi-agent integration patterns"
    echo
}

# Run main function
main "$@"
