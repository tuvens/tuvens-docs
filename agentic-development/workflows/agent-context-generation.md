# Agent Context Generation

## Overview

The agent context generation system automatically creates and maintains contextual information that helps AI agents understand the current state of development, historical decisions, and ongoing work across the ecosystem.

## System Components (1 workflow)

**Workflows**: `auto-documentation.yml`

## Core Functions

### Automatic Documentation Generation
- Generates context documents from git history and repository state
- Creates structured summaries of recent development activity
- Maintains up-to-date documentation of system changes
- Produces machine-readable context for agent consumption

### Agent Session Memory
- Provides new agent sessions with recent development context
- Maintains historical context for informed decision making  
- Creates session continuity across agent handoffs
- Preserves institutional knowledge between development cycles

### Development Continuity
- Ensures agents understand what happened in previous sessions
- Prevents duplication of work already completed
- Maintains awareness of ongoing multi-agent projects
- Provides context for complex, long-running development efforts

## Value to Agentic Development

- ✅ **Session memory** - Agents understand what happened in previous sessions
- ✅ **Reduces redundancy** - Agents don't repeat work already done  
- ✅ **Better decisions** - Context-aware agents make more informed choices
- ✅ **Continuity** - Seamless handoffs between different agent sessions

## Context Integration Points

### Agent Session Context
- **Context Loading**: Workflows prepare context for agent sessions from multiple sources
- **Task Coordination**: Branch tracking provides visibility into related agent work
- **Documentation**: Workflows maintain documentation that becomes agent context
- **Historical Awareness**: Agents receive context about previous development decisions

### Documentation Generation Process
- **Git History Analysis**: Extracts meaningful patterns from commit history
- **Branch Activity Summarization**: Creates summaries of ongoing branch work
- **Issue Integration**: Links documentation to relevant GitHub issues
- **Multi-Repository Context**: Aggregates context from related repositories

### Agent Onboarding
- **Session Initialization**: New agent sessions receive comprehensive context
- **Task Context**: Agents understand the broader context of their assigned tasks
- **Collaboration Context**: Agents know about related work by other agents
- **System State Context**: Agents understand current system health and status

## Detailed Workflow Functions

### auto-documentation.yml
- **Purpose**: Generates context documentation automatically
- **Triggers**: Scheduled runs, repository activity, agent session starts
- **Actions**: Analyzes git history, creates context documents, updates agent memory
- **Agent Impact**: Creates agent session context, maintains development continuity
- **Output**: Structured context files, session memory documents

## Context Generation Components

### Git History Analysis
```bash
# Analyzes recent commits for patterns and significance
git log --oneline --since="7 days ago" --all
git log --stat --since="7 days ago" --all  
git shortlog --summary --numbered --since="7 days ago"
```

### Branch Activity Summarization
```bash
# Summarizes active branch work and agent assignments
git branch -a --sort=-committerdate
git for-each-ref --sort=-committerdate refs/heads/ --format='%(committerdate:short) %(refname:short)'
```

### Issue Context Integration
```bash
# Links documentation to relevant GitHub issues and PRs
gh issue list --state=open --label=agent-task
gh pr list --state=open --author="@me"
```

### Multi-Repository Context
```bash
# Aggregates context from related Tuvens repositories
# Checks branch tracking data across repositories
# Reviews cross-repository dependencies and changes
```

## Best Practices for Agents

### Utilizing Generated Context
1. **Review Session Context**: Always read generated context before starting work
2. **Understand Historical Decisions**: Consider previous decisions when making changes
3. **Avoid Duplicate Work**: Check context to ensure work hasn't been completed
4. **Build on Previous Work**: Extend rather than replace existing solutions
5. **Maintain Context Accuracy**: Update context when completing significant work

### Contributing to Context Generation  
1. **Write Meaningful Commits**: Commit messages become part of context
2. **Document Decisions**: Significant decisions should be documented
3. **Update Issues**: Keep GitHub issues current for accurate context
4. **Link Related Work**: Reference related branches, issues, and PRs

### Context-Aware Development
1. **Read Before Writing**: Understand existing patterns before creating new ones
2. **Respect Previous Decisions**: Understand why previous decisions were made
3. **Consider System Impact**: Understand how changes affect the broader system
4. **Maintain Consistency**: Follow established patterns revealed by context

## Context File Structure

### Generated Context Documents
- **`development-context.md`** - Overall system development context
- **`agent-session-memory.json`** - Structured data for agent consumption
- **`recent-activity-summary.md`** - Summary of recent development activity
- **`branch-status-context.md`** - Current branch and task status
- **`multi-repo-context.md`** - Cross-repository development context

### Context Data Sources
- Git commit history and branch activity
- GitHub issue and pull request data  
- Branch tracking system data
- Agent coordination system records
- Workflow execution logs and status

### Context Update Triggers
- Agent session initialization
- Significant repository changes
- Scheduled maintenance cycles
- Cross-repository synchronization events
- Manual context refresh requests

## Troubleshooting Context Issues

### Context Generation Failures
**Symptoms**: Agents lack recent development context, outdated information
**Causes**:
- Workflow execution failures
- Git history access issues
- API rate limit exceeded

**Solutions**:
```bash
# Manually trigger context generation
gh workflow run auto-documentation.yml

# Check recent workflow runs
gh run list --workflow=auto-documentation.yml

# Verify context files exist and are current
ls -la agentic-development/context/
```

### Stale Context Information
**Symptoms**: Agents reference outdated information, duplicate work occurs
**Causes**:
- Infrequent context updates
- Missing repository events
- Context file corruption

**Solutions**:
```bash
# Force context refresh
rm agentic-development/context/*.json
gh workflow run auto-documentation.yml

# Check context file timestamps
find agentic-development/context/ -name "*.md" -exec ls -la {} \;

# Validate context file integrity
cat agentic-development/context/agent-session-memory.json | jq .
```

### Missing Multi-Repository Context
**Symptoms**: Agents unaware of related work in other repositories
**Causes**:
- Cross-repository sync failures
- Missing repository permissions
- Network connectivity issues

**Solutions**:
```bash
# Test cross-repository access
gh repo list tuvens --limit 10

# Check repository permissions
gh api user/repos --jq '.[].permissions'

# Manually sync cross-repository data
gh workflow run notify-repositories.yml
```

## Integration with Agent Workflows

### Context Loading in Agent Sessions
- Agents automatically receive context at session start
- Context includes recent development activity and ongoing work
- Historical context provides background for decision making
- Multi-repository context shows related work across the ecosystem

### Context Updates During Development
- Agent actions trigger context updates
- Significant changes are reflected in real-time context
- Context changes are propagated to other agents
- Context accuracy is maintained throughout development cycles

### Context Preservation Across Sessions
- Important context survives agent session boundaries
- Institutional knowledge is preserved between development cycles
- Historical decisions remain accessible for future reference
- Development patterns are documented and maintained

---

**Last Updated**: 2025-08-19  
**Version**: 2.0 - Extracted from main workflow guide  
**Maintained By**: DevOps Agent  

*This document is part of the Tuvens workflow infrastructure. For context generation issues, create a GitHub issue with the `agent-context` label.*