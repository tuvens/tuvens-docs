# Tuvens Multi-Agent Development System

## Final Production Structure

This directory contains only the essential files for the multi-agent system:

> Test commit: 2025-08-07 - Testing workflow triggers

### 📁 Core Structure

```
agentic-development/
├── README.md                        # This file
├── desktop-project-instructions/    # Claude Desktop instructions
│   ├── README.md                      # Main entry point for Desktop
│   ├── agents/                      # Agent-specific handoffs
│   ├── handoff-templates/           # Task-type templates
│   └── workflows/                   # Multi-agent protocols
├── workflows/                       # Technical workflows
│   ├── worktree-organization.md    # [CODE] Worktree patterns
│   ├── branching-strategy.md       # [CODE] Git workflow guide
│   ├── agent-terminal-prompts.md   # [CODE] Task-specific prompt templates
│   └── cross-repository-development/   # [CODE] Repository standards for agents
│       ├── README.md                # Index of development standards
│       ├── repository-structure.md  # Repository setup standards
│       ├── cicd-standards.md        # CI/CD pipeline requirements
│       └── [6 other micro-docs]     # Focused development guidelines
├── scripts/                        # System automation
│   ├── setup-agent-task.sh         # Creates sessions
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

**For Claude Code:**
- Loads agent identity from `.claude/agents/[agent].md`
- Additional context from `workflows/`

**System Scripts:**
- `setup-agent-task.sh` - Creates worktrees, issues, prompts
- `validate-environment.sh` - Checks prerequisites

### 🗂️ Archived Materials

All design documents, analysis, and development artifacts are in `.temp/`:
- Design documentation
- System analysis  
- Development reports
- Migration guides
- Old templates

### 🚀 Quick Start

1. **Claude Desktop Project**: Use content from `.temp/migration-guides/DESKTOP_PROJECT_UPDATE.md`
2. **Start Session**: Use `/start-session [agent-name]` command
3. **Claude Code**: Will load appropriate agent identity automatically

### 🔧 System Maintenance

**This documentation is maintained by the Vibe Coder agent.**

Automated maintenance issues are created via GitHub Actions on every push to `develop`. The Vibe Coder should:
- Verify structure accuracy in this README
- Update file counts and descriptions (currently 37 production files) 
- Check for orphaned or missing references
- Validate that all load paths work correctly
- Archive outdated files to `.temp/`

**Maintenance Issues**: Look for GitHub issues titled `[Vibe Coder] System Maintenance Check - [Date]`

This structure maintains only what's needed for production use of the multi-agent system.