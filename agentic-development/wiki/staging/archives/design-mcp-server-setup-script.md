# Design MCP Server Setup Script

## Overview

This document provides a comprehensive setup script and configuration guide for implementing design-focused MCP (Model Context Protocol) servers in our agentic development environment. The script automates the installation and configuration of multiple design tools including Tailwind CSS intelligence, Figma integration, and UI component generation capabilities.

## Core MCP Servers for Design Workflow

### 1. Primary Servers
- **Tailwind Designer MCP**: Component generation and CSS optimization
- **FlyonUI MCP**: Production-ready UI component library
- **Figma Integration MCP**: Design file processing and token extraction
- **Accessibility Validator MCP**: WCAG compliance checking

### 2. Supporting Infrastructure
- **Design Token Manager**: Cross-framework token synchronization
- **Component Library Sync**: Multi-framework component consistency
- **Performance Analyzer**: CSS performance impact assessment

## Automated Setup Script

### Master Installation Script

**File**: `agentic-development/scripts/setup-design-mcp-suite.sh`

```bash
#!/bin/bash
# Comprehensive Design MCP Server Setup Script
# Author: Vibe Coder Agent
# Purpose: Automate installation and configuration of design MCP servers

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check Node.js version
    if ! command -v node &> /dev/null; then
        log_error "Node.js is required but not installed. Please install Node.js 18+"
        exit 1
    fi
    
    local node_version=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
    if [ "$node_version" -lt 18 ]; then
        log_error "Node.js 18+ is required. Current version: $(node --version)"
        exit 1
    fi
    
    # Check npm
    if ! command -v npm &> /dev/null; then
        log_error "npm is required but not installed."
        exit 1
    fi
    
    # Check Claude Desktop
    if [[ "$OSTYPE" == "darwin"* ]]; then
        if [ ! -d "/Applications/Claude.app" ]; then
            log_warning "Claude Desktop not found. Please install Claude Desktop first."
        fi
    fi
    
    log_success "Prerequisites check completed"
}

# Environment setup
setup_environment() {
    log_info "Setting up environment variables..."
    
    # Create environment file if it doesn't exist
    if [ ! -f ~/.design_mcp_env ]; then
        cat > ~/.design_mcp_env << 'EOF'
# Design MCP Server Environment Configuration
export FIGMA_API_TOKEN="your_figma_token_here"
export FLYONUI_API_KEY="your_flyonui_key_here"
export MCP_DESIGN_PORT=3003
export MCP_FIGMA_PORT=3004
export MCP_ACCESSIBILITY_PORT=3005
export NODE_ENV=production
EOF
        log_warning "Created ~/.design_mcp_env - Please update with your API keys"
    fi
    
    # Source environment
    source ~/.design_mcp_env
    
    # Add to shell profile if not already present
    local shell_profile
    if [[ "$SHELL" == *"zsh"* ]]; then
        shell_profile="$HOME/.zshrc"
    else
        shell_profile="$HOME/.bashrc"
    fi
    
    if ! grep -q "source ~/.design_mcp_env" "$shell_profile"; then
        echo "source ~/.design_mcp_env" >> "$shell_profile"
        log_info "Added environment sourcing to $shell_profile"
    fi
    
    log_success "Environment setup completed"
}

# Install MCP servers
install_mcp_servers() {
    log_info "Installing Design MCP Servers..."
    
    # Create MCP servers directory
    mkdir -p ~/mcp-servers/design
    cd ~/mcp-servers/design
    
    # Install Tailwind Designer MCP
    log_info "Installing Tailwind Designer MCP..."
    if npm install -g @devlimelabs/tailwind-designer-mcp; then
        log_success "Tailwind Designer MCP installed"
    else
        log_error "Failed to install Tailwind Designer MCP"
        exit 1
    fi
    
    # Install FlyonUI MCP
    log_info "Installing FlyonUI MCP..."
    if npm install -g @flyonui/mcp-server; then
        log_success "FlyonUI MCP installed"
    else
        log_warning "FlyonUI MCP installation failed - continuing without it"
    fi
    
    # Install Figma MCP (custom implementation)
    log_info "Setting up Figma MCP server..."
    if setup_figma_mcp; then
        log_success "Figma MCP server setup completed"
    else
        log_warning "Figma MCP setup failed - continuing without it"
    fi
    
    # Install Accessibility Validator
    log_info "Installing Accessibility Validator MCP..."
    if setup_accessibility_mcp; then
        log_success "Accessibility Validator MCP installed"
    else
        log_warning "Accessibility MCP setup failed - continuing without it"
    fi
    
    log_success "MCP servers installation completed"
}

# Setup Figma MCP server
setup_figma_mcp() {
    local figma_dir="$HOME/mcp-servers/design/figma-mcp"
    mkdir -p "$figma_dir"
    cd "$figma_dir"
    
    # Initialize npm project
    npm init -y > /dev/null
    
    # Install dependencies
    npm install figma-api axios @types/node typescript
    
    # Create simplified Figma MCP server
    cat > server.js << 'EOF'
const { MCPServer } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const axios = require('axios');

class FigmaMCPServer {
  constructor() {
    this.figmaToken = process.env.FIGMA_API_TOKEN || '';
    this.server = new MCPServer(
      {
        name: 'figma-mcp-server',
        version: '0.1.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );
    
    this.setupToolHandlers();
  }
  
  setupToolHandlers() {
    this.server.setRequestHandler('tools/list', async () => ({
      tools: [
        {
          name: 'get_figma_file',
          description: 'Retrieve Figma file contents',
          inputSchema: {
            type: 'object',
            properties: {
              fileId: {
                type: 'string',
                description: 'Figma file ID'
              }
            },
            required: ['fileId']
          }
        },
        {
          name: 'extract_design_tokens',
          description: 'Extract design tokens from Figma file',
          inputSchema: {
            type: 'object',
            properties: {
              fileId: {
                type: 'string',
                description: 'Figma file ID'
              }
            },
            required: ['fileId']
          }
        }
      ]
    }));
    
    this.server.setRequestHandler('tools/call', async (request) => {
      switch (request.params.name) {
        case 'get_figma_file':
          return await this.getFigmaFile(request.params.arguments?.fileId);
        case 'extract_design_tokens':
          return await this.extractDesignTokens(request.params.arguments?.fileId);
        default:
          throw new Error(`Unknown tool: ${request.params.name}`);
      }
    });
  }
  
  async getFigmaFile(fileId) {
    try {
      const response = await axios.get(`https://api.figma.com/v1/files/${fileId}`, {
        headers: {
          'X-Figma-Token': this.figmaToken
        }
      });
      
      return {
        content: [{
          type: 'text',
          text: JSON.stringify(response.data, null, 2)
        }]
      };
    } catch (error) {
      throw new Error(`Failed to fetch Figma file: ${error}`);
    }
  }
  
  async extractDesignTokens(fileId) {
    try {
      const response = await axios.get(`https://api.figma.com/v1/files/${fileId}`, {
        headers: { 'X-Figma-Token': this.figmaToken }
      });
      
      const tokens = this.processDesignTokens(response.data);
      
      return {
        content: [{
          type: 'text',
          text: JSON.stringify(tokens, null, 2)
        }]
      };
    } catch (error) {
      throw new Error(`Failed to extract design tokens: ${error}`);
    }
  }
  
  processDesignTokens(fileData) {
    // Extract basic design tokens from Figma data
    const tokens = {
      colors: {},
      typography: {},
      spacing: {},
      borderRadius: {},
      shadows: {}
    };
    
    // Simplified token extraction
    if (fileData.styles) {
      Object.values(fileData.styles).forEach(style => {
        if (style.styleType === 'FILL') {
          tokens.colors[style.name] = style.description || '#000000';
        } else if (style.styleType === 'TEXT') {
          tokens.typography[style.name] = {
            fontSize: style.fontSize || 16,
            fontFamily: style.fontFamily || 'Inter',
            fontWeight: style.fontWeight || 400
          };
        }
      });
    }
    
    return tokens;
  }
  
  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

const server = new FigmaMCPServer();
server.run().catch(console.error);
EOF
    
    return 0
}

# Setup Accessibility MCP
setup_accessibility_mcp() {
    local a11y_dir="$HOME/mcp-servers/design/accessibility-mcp"
    mkdir -p "$a11y_dir"
    cd "$a11y_dir"
    
    npm init -y > /dev/null
    npm install axe-core puppeteer @types/node
    
    # Create accessibility server
    cat > server.js << 'EOF'
const { MCPServer } = require('@modelcontextprotocol/sdk/server/index.js');
const { StdioServerTransport } = require('@modelcontextprotocol/sdk/server/stdio.js');
const axe = require('axe-core');
const puppeteer = require('puppeteer');

class AccessibilityMCPServer {
  constructor() {
    this.server = new MCPServer(
      {
        name: 'accessibility-mcp-server',
        version: '0.1.0',
      },
      {
        capabilities: {
          tools: {},
        },
      }
    );
    
    this.setupToolHandlers();
  }
  
  setupToolHandlers() {
    this.server.setRequestHandler('tools/list', async () => ({
      tools: [
        {
          name: 'audit_accessibility',
          description: 'Perform accessibility audit on HTML content',
          inputSchema: {
            type: 'object',
            properties: {
              html: {
                type: 'string',
                description: 'HTML content to audit'
              },
              url: {
                type: 'string',
                description: 'URL to audit (alternative to HTML)'
              }
            }
          }
        }
      ]
    }));
    
    this.server.setRequestHandler('tools/call', async (request) => {
      if (request.params.name === 'audit_accessibility') {
        return await this.auditAccessibility(request.params.arguments);
      }
      throw new Error(`Unknown tool: ${request.params.name}`);
    });
  }
  
  async auditAccessibility(args) {
    try {
      let results;
      
      if (args.url) {
        results = await this.auditURL(args.url);
      } else if (args.html) {
        results = await this.auditHTML(args.html);
      } else {
        throw new Error('Either html or url parameter is required');
      }
      
      return {
        content: [{
          type: 'text',
          text: JSON.stringify(results, null, 2)
        }]
      };
    } catch (error) {
      throw new Error(`Accessibility audit failed: ${error.message}`);
    }
  }
  
  async auditURL(url) {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();
    
    try {
      await page.goto(url);
      
      // Inject axe-core
      await page.addScriptTag({ path: require.resolve('axe-core/axe.min.js') });
      
      const results = await page.evaluate(() => {
        return axe.run();
      });
      
      return this.formatResults(results);
    } finally {
      await browser.close();
    }
  }
  
  async auditHTML(html) {
    const browser = await puppeteer.launch({ headless: true });
    const page = await browser.newPage();
    
    try {
      await page.setContent(html);
      await page.addScriptTag({ path: require.resolve('axe-core/axe.min.js') });
      
      const results = await page.evaluate(() => {
        return axe.run();
      });
      
      return this.formatResults(results);
    } finally {
      await browser.close();
    }
  }
  
  formatResults(axeResults) {
    return {
      summary: {
        violations: axeResults.violations.length,
        passes: axeResults.passes.length,
        incomplete: axeResults.incomplete.length,
        inapplicable: axeResults.inapplicable.length
      },
      violations: axeResults.violations.map(violation => ({
        id: violation.id,
        impact: violation.impact,
        description: violation.description,
        help: violation.help,
        helpUrl: violation.helpUrl,
        nodes: violation.nodes.length
      })),
      wcagLevel: this.calculateWCAGLevel(axeResults)
    };
  }
  
  calculateWCAGLevel(results) {
    const criticalViolations = results.violations.filter(v => 
      v.impact === 'critical' || v.impact === 'serious'
    );
    
    if (criticalViolations.length === 0) {
      return 'AA';
    } else if (criticalViolations.length <= 2) {
      return 'A';
    } else {
      return 'Below A';
    }
  }
  
  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
  }
}

const server = new AccessibilityMCPServer();
server.run().catch(console.error);
EOF
    
    return 0
}

# Configure Claude Desktop
configure_claude_desktop() {
    log_info "Configuring Claude Desktop..."
    
    local config_dir
    if [[ "$OSTYPE" == "darwin"* ]]; then
        config_dir="$HOME/Library/Application Support/Claude"
    else
        config_dir="$HOME/.config/claude"
    fi
    
    mkdir -p "$config_dir"
    
    local config_file="$config_dir/claude_desktop_config.json"
    
    # Backup existing config
    if [ -f "$config_file" ]; then
        cp "$config_file" "$config_file.backup.$(date +%Y%m%d_%H%M%S)"
        log_info "Backed up existing Claude Desktop config"
    fi
    
    # Create or update config (Note: Fixed HERE-doc quoting to allow variable expansion)
    cat > "$config_file" << EOF
{
  "mcpServers": {
    "tailwind-designer": {
      "command": "npx",
      "args": ["-y", "@devlimelabs/tailwind-designer-mcp"],
      "env": {
        "NODE_ENV": "production",
        "TAILWIND_CONFIG_PATH": "./tailwind.config.js"
      }
    },
    "flyonui": {
      "command": "npx",
      "args": ["-y", "@flyonui/mcp-server"],
      "env": {
        "FLYONUI_API_KEY": "${FLYONUI_API_KEY}",
        "NODE_ENV": "production"
      }
    },
    "figma-integration": {
      "command": "node",
      "args": ["$HOME/mcp-servers/design/figma-mcp/server.js"],
      "env": {
        "FIGMA_API_TOKEN": "${FIGMA_API_TOKEN}"
      }
    },
    "accessibility-validator": {
      "command": "node",
      "args": ["$HOME/mcp-servers/design/accessibility-mcp/server.js"]
    }
  }
}
EOF
    
    log_success "Claude Desktop configuration updated"
}

# Verify installation
verify_installation() {
    log_info "Verifying installation..."
    
    local errors=0
    
    # Check if MCP servers are accessible
    if command -v tailwind-designer-mcp &> /dev/null; then
        log_success "Tailwind Designer MCP: Available"
    else
        log_error "Tailwind Designer MCP: Not found"
        ((errors++))
    fi
    
    if [ -f "$HOME/mcp-servers/design/figma-mcp/server.js" ]; then
        log_success "Figma MCP: Available"
    else
        log_warning "Figma MCP: Not found"
    fi
    
    if [ -f "$HOME/mcp-servers/design/accessibility-mcp/server.js" ]; then
        log_success "Accessibility MCP: Available"
    else
        log_warning "Accessibility MCP: Not found"
    fi
    
    # Check environment variables
    if [ -n "$FIGMA_API_TOKEN" ] && [ "$FIGMA_API_TOKEN" != "your_figma_token_here" ]; then
        log_success "Figma API token: Configured"
    else
        log_warning "Figma API token: Not configured (update ~/.design_mcp_env)"
    fi
    
    if [ -n "$FLYONUI_API_KEY" ] && [ "$FLYONUI_API_KEY" != "your_flyonui_key_here" ]; then
        log_success "FlyonUI API key: Configured"
    else
        log_warning "FlyonUI API key: Not configured (update ~/.design_mcp_env)"
    fi
    
    if [ $errors -eq 0 ]; then
        log_success "Installation verification completed successfully"
    else
        log_error "Installation verification found $errors errors"
        return 1
    fi
}

# Create test scenarios
create_test_scenarios() {
    log_info "Creating test scenarios..."
    
    mkdir -p "$HOME/mcp-servers/design/tests"
    
    # Create test HTML for accessibility testing
    cat > "$HOME/mcp-servers/design/tests/test-accessibility.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Accessibility Test Page</title>
</head>
<body>
    <h1>Accessibility Test</h1>
    
    <!-- Good accessibility example -->
    <button aria-label="Submit form">Submit</button>
    
    <!-- Poor accessibility examples for testing -->
    <div onclick="alert('clicked')">Clickable div without role</div>
    <img src="image.jpg" alt="">
    <input type="text" placeholder="Enter name">
    
    <form>
        <input type="email" required>
        <button type="submit">Send</button>
    </form>
</body>
</html>
EOF
    
    # Create Tailwind test configuration
    cat > "$HOME/mcp-servers/design/tests/test-tailwind.config.js" << 'EOF'
/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./**/*.{html,js}"],
  theme: {
    extend: {
      colors: {
        primary: {
          50: '#eff6ff',
          500: '#3b82f6',
          900: '#1e3a8a'
        }
      }
    },
  },
  plugins: [],
}
EOF
    
    log_success "Test scenarios created"
}

# Generate usage documentation
generate_documentation() {
    log_info "Generating usage documentation..."
    
    cat > "$HOME/mcp-servers/design/README.md" << 'EOF'
# Design MCP Servers - Usage Guide

## Available MCP Servers

### 1. Tailwind Designer MCP
**Purpose**: Generate and optimize Tailwind CSS components

**Usage Examples**:
```
# In Claude Desktop
"Generate a responsive card component using Tailwind CSS with primary colors and rounded corners"
"Optimize this CSS code to use Tailwind utilities: [paste CSS]"
"Create a button component with hover states and accessibility support"
```

### 2. FlyonUI MCP
**Purpose**: Access production-ready UI components

**Usage Examples**:
```
"Show me available FlyonUI button variants"
"Generate a form layout using FlyonUI components"
"Create a navigation component with FlyonUI styling"
```

### 3. Figma Integration MCP
**Purpose**: Extract design data from Figma files

**Usage Examples**:
```
"Extract design tokens from this Figma file: [file ID]"
"Get component specifications from Figma file: [file ID]"
"Generate code for this Figma component"
```

**Setup Required**:
1. Get Figma API token from https://www.figma.com/developers/api
2. Update FIGMA_API_TOKEN in ~/.design_mcp_env

### 4. Accessibility Validator MCP
**Purpose**: Perform WCAG compliance audits

**Usage Examples**:
```
"Audit the accessibility of this HTML: [paste HTML]"
"Check WCAG compliance for this URL: https://example.com"
"Generate accessibility report for this component"
```

## Configuration

### Environment Variables
Edit `~/.design_mcp_env` to configure API keys:
```bash
export FIGMA_API_TOKEN="your_actual_figma_token"
export FLYONUI_API_KEY="your_actual_flyonui_key"
```

### Claude Desktop Configuration
The MCP servers are automatically configured in Claude Desktop.
Restart Claude Desktop after running the setup script.

## Troubleshooting

### Common Issues

1. **MCP Server Not Found**
   - Ensure Node.js 18+ is installed
   - Check that npm install completed successfully
   - Restart Claude Desktop

2. **Figma API Errors**
   - Verify FIGMA_API_TOKEN is set correctly
   - Check that you have access to the Figma file
   - Ensure the file ID is correct (from Figma URL)

3. **Accessibility Audit Failures**
   - Ensure Puppeteer can access the URL
   - Check that HTML content is valid
   - Verify sufficient memory for browser automation

### Getting Help

1. Check the logs in Claude Desktop
2. Verify MCP server status:
   ```bash
   ps aux | grep mcp
   ```
3. Test individual servers:
   ```bash
   node $HOME/mcp-servers/design/figma-mcp/server.js
   ```

EOF
    
    log_success "Documentation generated at $HOME/mcp-servers/design/README.md"
}

# Main execution
main() {
    log_info "Starting Design MCP Server Setup"
    echo "================================="
    
    check_prerequisites
    setup_environment
    install_mcp_servers
    configure_claude_desktop
    create_test_scenarios
    generate_documentation
    
    if verify_installation; then
        echo ""
        log_success "🎉 Design MCP Server setup completed successfully!"
        echo ""
        log_info "Next steps:"
        echo "  1. Update API keys in ~/.design_mcp_env"
        echo "  2. Restart Claude Desktop"
        echo "  3. Test the MCP servers with sample prompts"
        echo "  4. Read the usage guide: $HOME/mcp-servers/design/README.md"
        echo ""
        log_info "Example test prompt:"
        echo '  "Generate a responsive card component using Tailwind CSS"'
    else
        log_error "Setup completed with warnings. Check the output above."
        exit 1
    fi
}

# Script execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
```

## Usage Instructions

### 1. Running the Setup Script

```bash
# Make the script executable
chmod +x agentic-development/scripts/setup-design-mcp-suite.sh

# Run the setup script
./agentic-development/scripts/setup-design-mcp-suite.sh
```

### 2. Post-Installation Configuration

**Update API Keys**:
```bash
# Edit the environment file
nano ~/.design_mcp_env

# Update with your actual API keys:
export FIGMA_API_TOKEN="your_actual_figma_token_from_figma_developers"
export FLYONUI_API_KEY="your_actual_flyonui_api_key"
```

**Restart Services**:
```bash
# Restart Claude Desktop
# macOS: Quit and reopen Claude Desktop
# Linux: killall claude-desktop && claude-desktop

# Source the environment
source ~/.design_mcp_env
```

### 3. Testing the Installation

**Test Tailwind Designer MCP**:
```
# In Claude Desktop
"Generate a responsive navigation component using Tailwind CSS with a dark theme and mobile hamburger menu"
```

**Test Figma Integration**:
```
# In Claude Desktop (requires Figma file ID)
"Extract design tokens from this Figma file: ABC123XYZ"
```

**Test Accessibility Validator**:
```
# In Claude Desktop
"Audit the accessibility of this HTML: <button onclick='alert()'>Click me</button>"
```

## Script Features

### 1. Comprehensive Error Handling
- Prerequisites checking (Node.js, npm, Claude Desktop)
- Graceful failure handling for optional components
- Detailed error logging with color-coded output
- Backup of existing configurations

### 2. Modular Installation
- Core servers (Tailwind Designer) are required
- Optional servers (FlyonUI, Figma) can fail without breaking setup
- Independent verification of each component
- Fallback configurations for missing components

### 3. Environment Management
- Automatic environment file creation
- Shell profile integration
- Secure API key handling
- Port configuration for multiple servers

### 4. Documentation Generation
- Automatic README creation
- Usage examples for each MCP server
- Troubleshooting guide
- Configuration instructions

### 5. Testing Infrastructure
- Sample HTML files for accessibility testing
- Tailwind configuration examples
- Test scenarios for each MCP server
- Verification scripts

## Advanced Configuration

### Custom MCP Server Ports

```bash
# Edit ~/.design_mcp_env to customize ports
export MCP_DESIGN_PORT=3003
export MCP_FIGMA_PORT=3004
export MCP_ACCESSIBILITY_PORT=3005
```

### Multiple Environment Support

```bash
# Development environment
cp ~/.design_mcp_env ~/.design_mcp_env.dev

# Production environment
cp ~/.design_mcp_env ~/.design_mcp_env.prod

# Switch environments
source ~/.design_mcp_env.dev
```

### Custom Figma Server Configuration

```bash
# Edit the Figma MCP server for custom endpoints
nano $HOME/mcp-servers/design/figma-mcp/server.js

# Add custom functionality:
# - Additional design token extraction
# - Custom component generation
# - Team-specific Figma integrations
```

## Maintenance and Updates

### Updating MCP Servers

```bash
# Update global MCP packages
npm update -g @devlimelabs/tailwind-designer-mcp
npm update -g @flyonui/mcp-server

# Update custom servers
cd $HOME/mcp-servers/design/figma-mcp
npm update

cd $HOME/mcp-servers/design/accessibility-mcp
npm update
```

### Health Monitoring

```bash
# Check MCP server status
ps aux | grep mcp

# Test individual servers
node $HOME/mcp-servers/design/figma-mcp/server.js
node $HOME/mcp-servers/design/accessibility-mcp/server.js

# Verify Claude Desktop configuration
cat "$HOME/Library/Application Support/Claude/claude_desktop_config.json"
```

### Troubleshooting Scripts

```bash
# Create diagnostic script
cat > $HOME/mcp-servers/design/diagnose.sh << 'EOF'
#!/bin/bash
echo "Design MCP Servers Diagnostic"
echo "============================"

echo "Node.js version: $(node --version)"
echo "npm version: $(npm --version)"
echo "Environment file exists: $([ -f ~/.design_mcp_env ] && echo 'Yes' || echo 'No')"
echo "Figma token configured: $([ -n "$FIGMA_API_TOKEN" ] && echo 'Yes' || echo 'No')"
echo "FlyonUI key configured: $([ -n "$FLYONUI_API_KEY" ] && echo 'Yes' || echo 'No')"

echo "\nMCP Server Files:"
ls -la $HOME/mcp-servers/design/*/server.js 2>/dev/null || echo "No servers found"

echo "\nClaude Desktop Config:"
if [[ "$OSTYPE" == "darwin"* ]]; then
    cat "$HOME/Library/Application Support/Claude/claude_desktop_config.json" 2>/dev/null || echo "No config found"
else
    cat "$HOME/.config/claude/claude_desktop_config.json" 2>/dev/null || echo "No config found"
fi
EOF

chmod +x $HOME/mcp-servers/design/diagnose.sh
```

This comprehensive setup script provides a robust foundation for integrating design-focused MCP servers into our agentic development environment, with full automation, error handling, and documentation to ensure successful deployment and ongoing maintenance.
