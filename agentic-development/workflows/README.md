# GitHub Actions Workflow Infrastructure Guide

> **📍 Navigation**: [agentic-development](../README.md) → [workflows](./README.md)

## 📚 When to Load This Document

### Primary Context Loading Scenarios
- **DevOps Agent Sessions**: Essential for all devops agent tasks and infrastructure work
- **CI/CD Troubleshooting**: When workflows fail or automation is not working as expected
- **Multi-Repository Coordination**: Before working on tasks that span multiple repositories
- **Branch Safety Issues**: When branch protection workflows are triggered or violated
- **Agent Session Setup**: Understanding workflow impacts on agent coordination

### Dependency Mapping
**Load Before:**
- [../protocols/README.md](../protocols/README.md) - Agent coordination foundation
- [CLAUDE.md](../../CLAUDE.md) - Safety rules that workflows enforce

**Load With:**
- [../branch-tracking/README.md](../branch-tracking/README.md) - Central coordination system
- [central-branch-tracking.md](./central-branch-tracking.md) - Branch tracking workflow details

**Load After:**
- [branching-strategy.md](./branching-strategy.md) - Development workflow patterns
- [../docs/branch-safety-guide.md](../docs/branch-safety-guide.md) - Safety implementation guide

### Context Integration
This document is critical for understanding the automated infrastructure that enables multi-agent coordination. Load when working with anything that involves GitHub Actions, branch management, or cross-repository synchronization.

## Quick Navigation Decision Tree

**Choose your path based on what you need:**

### 🤖 I need to understand agent coordination
→ **[Multi-Agent Coordination & Tracking](multi-agent-coordination-tracking.md)**
- Branch lifecycle management across repositories
- Agent task coordination and session continuity
- External feedback routing (Gemini integration)
- Central tracking system

### 🛡️ I need to understand safety rules and governance
→ **[AI Agent Safety & Governance](ai-agent-safety-governance.md)**
- CLAUDE.md safety rule enforcement
- Branch protection and naming conventions
- Quality gates and validation processes

### 📚 I need to understand context generation
→ **[Agent Context Generation](agent-context-generation.md)**
- Automatic documentation generation
- Agent session memory and onboarding
- Development continuity systems

### 🔧 I need to understand infrastructure monitoring
→ **[Infrastructure Health & Maintenance](infrastructure-health-maintenance.md)**
- System health monitoring and validation
- Proactive maintenance workflows
- Tool reliability assurance

### 📡 I need to understand cross-repository coordination
→ **[Cross-Repository Notification](cross-repository-notification.md)**
- Event propagation across repositories
- Dependency management and updates
- System-wide synchronization

### 🐛 I need to troubleshoot workflow issues
→ **[Troubleshooting & Debugging Guide](troubleshooting-debugging-guide.md)**
- Common workflow issues and solutions
- Debugging approaches and tools
- Network and API troubleshooting

### 🤖 I need to understand code review automation
→ **[Qodo Review Automation](qodo-review-automation.md)**
- Automatic code review triggering
- Review quality gates and standards
- Integration with agent workflows

## Overview

This guide provides agents with essential information about the GitHub Actions workflow infrastructure that powers the Tuvens agentic development system. Understanding these workflows helps agents work effectively within the automated coordination system.

## Quick Reference

| Workflow | Purpose | Agent Impact |
|----------|---------|--------------|
| `qodo-review-automation.yml` | Automatically triggers Qodo code reviews on PRs | 🤖 Ensures code quality for all agent PRs |
| `gemini-code-review-integration.yml` | Processes Gemini feedback into GitHub issues with agent assignment | 🤖 Auto-assigns critical feedback to agents |
| `branch-tracking.yml` | Central coordination of branch lifecycle across repositories | 📊 Updates agent task visibility and coordination |
| `branch-created.yml` | Notifies central system of new branches | 🌿 Triggers agent context loading and task setup |
| `branch-merged.yml` | Processes branch merges and cleanup | 🔀 Updates task completion status and cleanup queue |
| `branch-deleted.yml` | Handles branch deletion notifications | 🗑️ Cleans up agent tracking and task records |
| `branch-protection.yml` | Enforces safety rules and naming conventions | 🛡️ Validates agent work against safety standards |
| `notify-repositories.yml` | Cross-repository change notifications | 📡 Coordinates multi-repo agent tasks |
| `notify-repositories-test.yml` | Test version of cross-repository notifications | 🧪 Tests multi-repo coordination |
| `infrastructure-validation.yml` | Validates system infrastructure health | 🔍 Monitors infrastructure reliability |
| `auto-documentation.yml` | Generates context documentation automatically | 📚 Creates agent session context |
| `vibe-coder-maintenance.yml` | Automated maintenance and health checks | 🔧 Maintains agent coordination infrastructure |

## 🧠 Core Value Proposition

These workflows create a "nervous system" for AI agents providing:

1. **Memory** - Agents remember what happened across sessions
2. **Coordination** - Multiple agents can work together without conflicts  
3. **Safety** - Automated governance prevents destructive actions
4. **Context** - Agents understand the broader system state
5. **Reliability** - Infrastructure self-monitors and self-heals
6. **Quality** - Automated code reviews ensure consistent standards

## 🚨 Why Workflow Failures Matter

When these workflows fail:
- Agents lose session continuity
- Branch tracking becomes inconsistent  
- Safety validations don't run
- Cross-repository synchronization fails
- Code quality checks are bypassed
- The entire multi-agent system becomes unreliable

**Critical**: Always investigate workflow failures immediately as they can cascade and affect all agent operations.

## Integration with Agent Configuration

This workflow infrastructure integrates with agent configuration files in `agentic-development/desktop-project-instructions/agents/`. Each agent should:

1. **Reference this guide** in their configuration
2. **Understand workflow impacts** on their specific role
3. **Follow workflow-driven task assignment** 
4. **Report workflow issues** that affect their work
5. **Wait for automated reviews** before merging PRs

## Maintenance and Updates

### Regular Maintenance
- Workflow files are maintained by the **devops** agent
- Documentation updates are coordinated by **docs-orchestrator**
- Testing and validation are handled by **vibe-coder**

### Version Control
- All workflow changes go through PR review
- Safety-critical workflows require additional validation
- Documentation is updated with each workflow modification
- Code reviews are automatically triggered on all PRs

### Monitoring
- Workflow execution is logged and monitored
- Performance metrics are tracked for optimization
- Issues are automatically created for persistent failures

---

**Last Updated**: 2025-08-22  
**Version**: 2.1 - Added Qodo review automation  
**Maintained By**: DevOps Agent  
**Review Process**: Multi-agent collaborative review (DevOps + Task Orchestrator + Qodo + Gemini Code Assist)

*This guide is part of the Tuvens agentic development infrastructure. For questions or issues, create a GitHub issue with the `workflow-infrastructure` label.*
