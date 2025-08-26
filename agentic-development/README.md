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
│   ├── cleanup-merged-branches.sh  # **NEW: Automated branch cleanup**
│   ├── update-branch-tracking.js   # **NEW: Branch tracking updates**
│   ├── file-reference-scanner.js   # **NEW: File reference validation system**
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
- **Branch Tracking**: Context from `branch-tracking/` for coordination

**System Scripts:**
- `setup-agent-task.sh` - Creates worktrees, issues, prompts + updates branch tracking + **Enhanced Onboarding**
- `cleanup-merged-branches.sh` - Removes merged branches and worktrees automatically  
- `update-branch-tracking.js` - Updates central tracking from GitHub Actions
- `validate-environment.sh` - Checks prerequisites

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

**Quick Status Commands**:
```bash
# Clean up merged branches and obsolete worktrees
bash agentic-development/scripts/cleanup-merged-branches.sh

# Validate environment setup
bash agentic-development/scripts/validate-environment.sh
```

### 🔗 File Reference Validation System

**Automated file reference testing** ensures all documentation links and file paths remain valid across the entire repository ecosystem.

**Key Features:**
- **Comprehensive Scanning**: Detects markdown links, relative paths, agent files, documentation paths, and code imports
- **Merge Protection**: Tests every file reference when merging to dev branch via GitHub Actions
- **Coverage Tracking**: Maintains `.file-reference-coverage.json` baseline with 95%+ coverage requirement
- **Broken Link Detection**: Identifies and reports broken internal links automatically
- **Automated Issues**: Creates GitHub issues for broken references found in CI
- **Integration**: Works with existing test infrastructure, pre-commit hooks, and multi-agent workflows

**Usage Commands:**
```bash
# Validate all file references
npm run validate-references

# Run reference validation in CI mode (quiet)
npm run validate-references:ci

# Test file references as part of test suite
npm run test:references

# Check reference coverage
npm run coverage:references

# 🚀 NEW: Create GitHub issues for broken references automatically
npm run create-issues

# Combined: Validate references + test coverage + create issues
npm run create-issues:all
```

**Integration Points:**
- **GitHub Actions**: `.github/workflows/file-reference-validation.yml` runs on every push to dev/main
- **Test Infrastructure**: Integrated into `agentic-development/scripts/test.sh` for integration tests
- **Pre-commit Hooks**: Optional validation before commits in `.pre-commit-config.yaml`
- **Infrastructure Workflow**: Part of existing infrastructure validation workflow
- **Coverage Baseline**: Automatically maintained on successful merges to main branch

**File Types Scanned:**
- Markdown files (`.md`) - `[text](./path)` links and load statements
- JavaScript/Node.js (`.js`) - import/require statements
- Configuration files (`.json`, `.yml`, `.yaml`) - file path references
- Shell scripts (`.sh`) - relative file paths
- Agent files (`.claude/agents/*.md`) - agent references
- Documentation paths (`agentic-development/`) - internal documentation links

### 🔧 Automatic Issue Creation Feature

**Transform detection into action** - The scanner now automatically creates GitHub issues for broken references, ensuring nothing gets ignored:

#### **Smart Issue Management:**
- **Automatic Detection**: Every broken reference becomes a tracked issue
- **Batch Processing**: Groups multiple broken references per file into single issues
- **Duplicate Prevention**: Updates existing issues instead of creating duplicates
- **Auto-Resolution**: Automatically closes issues when references are fixed
- **Rich Context**: Issues include file location, line numbers, and resolution options

#### **Issue Template Structure:**
```markdown
# Broken File Reference in example.md

**File**: `example.md`
**Found**: 3 broken references

## Broken References
### ❌ `./missing-file.md`
- **Line**: 42
- **Type**: markdown-link
- **Resolved Path**: `path/to/missing-file.md`

## Resolution Options
- [ ] Fix Path: Update reference to correct location  
- [ ] Create Missing File: Create the referenced file
- [ ] Remove Reference: Remove if no longer needed
- [ ] Update Documentation: Replace with alternative

## Verification
1. Run `npm run validate-references` locally
2. Commit changes and push to trigger validation
3. Issue automatically closes when fixed
```

#### **Workflow Benefits:**
- ✅ **Zero Ignored Issues**: Every broken reference gets tracked
- ✅ **Team Visibility**: Immediate awareness of documentation problems  
- ✅ **Progress Tracking**: Clear metrics on reference health
- ✅ **Automated Workflow**: No manual issue creation required
- ✅ **Resolution Guidance**: Clear instructions for fixing issues

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