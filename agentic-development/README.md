# Tuvens Multi-Agent Development System

> **📍 Navigation**: [Root](../README.md) → [agentic-development](./README.md)

## 📚 When to Load This Document

### Primary Context Loading Scenarios
- **System Overview**: First document for understanding the multi-agent development system
- **Agent Setup**: Before configuring or starting any agent session
- **Architecture Understanding**: When working with cross-agent coordination or system design
- **Directory Navigation**: As entry point for finding specific subsystem documentation
- **Integration Projects**: When working on features that span multiple system components

### Dependency Mapping
**Load First**: This is the main entry point - load before any other agentic-development documents

**Load With:**
- [CLAUDE.md](../CLAUDE.md) - Safety rules and agent guidelines
- [desktop-project-instructions/README.md](./desktop-project-instructions/README.md) - Claude Desktop specific guidance

**Key Subsystems to Load After:**
- [protocols/README.md](./protocols/README.md) - Agent coordination protocols
- [workflows/README.md](./workflows/README.md) - GitHub Actions infrastructure
- [branch-tracking/README.md](./branch-tracking/README.md) - Central coordination system

### Context Integration
This document provides the architectural overview that all other system components depend on. Load this first when working with any multi-agent system functionality.

## Final Production Structure

This directory contains only the essential files for the multi-agent system:

### 📁 Core Structure

```
agentic-development/
├── README.md                        # This file
├── desktop-project-instructions/    # Claude Desktop instructions
│   ├── README.md                      # Main entry point for Desktop
│   ├── agents/                      # Agent-specific handoffs
│   ├── handoff-templates/           # Task-type templates
│   ├── terminal-automation.md      # **NEW: iTerm MCP Server guide**
│   └── workflows/                   # Multi-agent protocols
├── workflows/                       # Technical workflows
│   ├── README.md                    # **NEW: GitHub Actions workflow infrastructure guide**
│   ├── worktree-organization.md    # [CODE] Worktree patterns
│   ├── branching-strategy.md       # [CODE] Git workflow guide
│   ├── agent-terminal-prompts.md   # [CODE] Task-specific prompt templates
│   ├── central-branch-tracking.md  # [CODE] Branch tracking system
│   ├── start-session-integration.md # [CODE] Enhanced session creation
│   └── cross-repository-development/   # [CODE] Repository standards for agents
│       ├── README.md                # Index of development standards
│       ├── repository-structure.md  # Repository setup standards
│       ├── cicd-standards.md        # CI/CD pipeline requirements
│       └── [6 other micro-docs]     # Focused development guidelines
├── branch-tracking/                 # **NEW: Central branch coordination**
│   ├── active-branches.json        # Current active branches across repos
│   ├── task-groups.json            # Related branches working together
│   ├── cleanup-queue.json          # Merged branches ready for cleanup
│   └── merge-log.json              # Recently merged branch history
├── scripts/                        # System automation
│   ├── setup-agent-task.sh         # Creates sessions + branch tracking
│   ├── setup-iterm-mcp.sh          # **NEW: iTerm MCP Server setup**
│   ├── cleanup-merged-branches.sh  # **NEW: Automated branch cleanup**
│   ├── update-branch-tracking.js   # **NEW: Branch tracking updates**
│   ├── validate-environment.sh     # Environment checks
│   └── maintenance-check.sh        # System health validation
└── cross-repo-sync-automation/     # Repository synchronization
    ├── README.md                   # Automation documentation
    └── templates/                  # Notification templates
```

### 🎯 File Purposes

**For Claude Desktop:**
- Load `desktop-project-instructions/README.md`
- References other files based on task needs
- **NEW**: Terminal automation via `terminal-automation.md`

**For Claude Code:**
- Loads agent identity from `.claude/agents/[agent].md`
- Additional context from `workflows/`
- **Branch Tracking**: Context from `branch-tracking/` for coordination
- **Terminal Automation**: Access to iTerm MCP Server capabilities

**System Scripts:**
- `setup-agent-task.sh` - Creates worktrees, issues, prompts + updates branch tracking + **Enhanced Onboarding**
- `setup-iterm-mcp.sh` - **NEW**: Installs and configures iTerm MCP Server for terminal automation
- `cleanup-merged-branches.sh` - Removes merged branches and worktrees automatically  
- `update-branch-tracking.js` - Updates central tracking from GitHub Actions
- `validate-environment.sh` - Checks prerequisites

### 🖥️ Terminal Automation System **NEW**

**iTerm MCP Server Integration:**
- **Agent Terminal Isolation**: Each agent maintains separate, named terminal sessions
- **Command Execution**: Automated command running with output monitoring
- **Development Environment**: Automated server startup, testing, and deployment
- **Cross-Repository Operations**: Coordinated terminal operations across all Tuvens repositories

**Key Features:**
1. **Session Management**: Named terminals per agent and purpose (`node-dev-main`, `laravel-dev-serve`, etc.)
2. **Command Monitoring**: Read output to verify command success and detect errors
3. **Environment Automation**: Automated development server startup and management
4. **Git Integration**: Terminal-based git operations with validation
5. **Multi-Process Coordination**: Parallel development servers, test runners, and monitoring

**Setup Requirements:**
- macOS with iTerm2 installed
- Node.js 14+
- Claude Desktop with MCP configuration

### 🌐 Branch Tracking System

**Enables cross-repository agent coordination:**
- **Active Branches**: See what other agents are working on across all repositories
- **Task Groups**: Coordinate related work spanning multiple repositories  
- **Automated Cleanup**: Remove merged branches and worktrees automatically
- **GitHub Integration**: Real-time updates via GitHub Actions webhooks

**Key Usage Scenarios:**
1. **Agent Coordination**: Check `active-branches.json` before starting to avoid duplicating work
2. **Cross-Repo Features**: Use `task-groups.json` to coordinate work across tuvens-client, tuvens-api, hi.events
3. **Enhanced Onboarding**: `/start-session` now includes task recommendations and coordination prompts
4. **Maintenance**: Run `cleanup-merged-branches.sh` to clean up obsolete worktrees
5. **Task Handoffs**: See related branches when taking over work from another agent

### 🚀 Enhanced Agent Onboarding Features

**Smart Task Recommendations**: The `/start-session` command now provides:
- **Activity Overview**: Current repository and system-wide branch activity
- **Task Group Discovery**: Automatic detection of related work for coordination
- **Workload Analysis**: Agent-specific recommendations based on current branches  
- **Interactive Coordination**: Prompts to join existing task groups or create new ones
- **Cross-Repository Awareness**: Shows related work in other repositories
- **Terminal Environment**: Automatic terminal session setup for development tasks

**Quick Status Commands**:
```bash
# Setup terminal automation
bash agentic-development/scripts/setup-iterm-mcp.sh

# Validate iTerm MCP Server installation specifically
bash validate-iterm-mcp.sh

# Clean up merged branches and obsolete worktrees
bash agentic-development/scripts/cleanup-merged-branches.sh

# Validate environment setup
bash agentic-development/scripts/validate-environment.sh
```

### 🗂️ Archived Materials

All design documents, analysis, and development artifacts are in `.temp/`:
- Design documentation
- System analysis  
- Development reports
- Migration guides
- Old templates

### 🚀 Quick Start

1. **Terminal Automation Setup**: Run `./scripts/setup-iterm-mcp.sh` for automated terminal capabilities
2. **Claude Desktop Project**: Use content from `.temp/migration-guides/DESKTOP_PROJECT_UPDATE.md`
3. **Start Session**: Use `/start-session [agent-name]` command with terminal automation
4. **Claude Code**: Will load appropriate agent identity automatically with terminal access

### 🔧 System Maintenance

**This documentation is maintained by the Vibe Coder agent.**

Automated maintenance issues are created via GitHub Actions on every push to `develop`. The Vibe Coder should:
- Verify structure accuracy in this README
- Update file counts and descriptions (currently 38 production files including iTerm MCP integration) 
- Check for orphaned or missing references
- Validate that all load paths work correctly
- Archive outdated files to `.temp/`
- Test terminal automation functionality

**Maintenance Issues**: Look for GitHub issues titled `[Vibe Coder] System Maintenance Check - [Date]`

This structure maintains only what's needed for production use of the multi-agent system, now enhanced with comprehensive terminal automation capabilities.
