# Claude Code Commands Directory

This directory contains 9 slash commands that extend Claude Code functionality for the Tuvens ecosystem. These commands provide specialized workflows for cross-repository coordination, development tasks, and project management.

## Quick Reference

| Command | Purpose | Usage |
|---------|---------|--------|
| [`/ask-question`](ask-question.md) | Ask questions about another repository | `/ask-question <repository> <question>` |
| [`/create-issue`](create-issue.md) | Create GitHub issues with agent workflows | `/create-issue <agent> <assigned-agent> <title> <repo>` |
| [`/push`](push.md) | Push changes following branching strategy | `/push <commit-message>` |
| [`/refactor-code`](refactor-code.md) | Comprehensive code refactoring | `/refactor-code <target-path> [--dry-run]` |
| [`/report-bug`](report-bug.md) | Report bugs in another repository | `/report-bug <repository> <bug_description>` |
| [`/resolve-issue`](resolve-issue.md) | Analyze and resolve GitHub issues | `/resolve-issue <issue-number>` |
| [`/send-rqts`](send-rqts.md) | Send requirements to another repository | `/send-rqts <repository> <requirements>` |
| [`/start-session`](start-session.md) | Start new Claude Code sessions | `/start-session <agent-name> [task-hint]` |
| [`/update-current-state`](update-current-state.md) | Update project state documentation | `/update-current-state [notes]` |

## Commands by Category

### 🌐 Cross-Repository Communication

These commands facilitate coordination between different repositories in the Tuvens ecosystem:

#### [`/ask-question`](ask-question.md)
Ask questions about another repository's implementation, API, or architecture when clarification is needed for integration work.

**When to use:**
- Need clarification on API behavior or parameters
- Understanding integration requirements
- Clarifying implementation details before development

**Example scenarios:**
- "How does the event filtering API handle date ranges across different timezones?"
- "What authentication method should be used for webhook endpoints?"

#### [`/report-bug`](report-bug.md)
Report bugs in another repository that affect the current project's integration or functionality.

**When to use:**
- External API returning unexpected responses
- Integration failures due to external system issues
- Dependency issues affecting current development

**Example scenarios:**
- Authentication endpoint returns 500 error with valid tokens
- Webhook delivery failures or malformed payloads
- API rate limiting not matching documented limits

#### [`/send-rqts`](send-rqts.md)
Request features, changes, or capabilities from another repository that are needed for current development work.

**When to use:**
- Need new API endpoints or functionality
- Request changes to existing behavior
- Propose new features for ecosystem integration

**Example scenarios:**
- Need webhook endpoint with real-time event filtering
- Request additional data fields in API responses
- Propose new authentication methods for enhanced security

### 🔧 Development Workflow

Core development commands that handle code changes, quality, and git operations:

#### [`/push`](push.md)
Push changes following the Tuvens branching strategy with explicit branch protection and safety checks.

**When to use:**
- Committing and pushing development changes
- Following proper branching workflow
- Ensuring compliance with merge policies

**Safety features:**
- Automatic branching strategy validation
- Forward-only merge policy enforcement
- Protected branch checks
- Meaningful commit message requirements

#### [`/refactor-code`](refactor-code.md)
Optimize and refactor code from first principles for maintainability and scalability while preserving functionality.

**When to use:**
- Code cleanup and organization
- Performance optimization
- Architecture improvements
- Configuration management

**Capabilities:**
- Multi-agent workflow integration for complex refactoring
- Comprehensive code analysis and dependency mapping
- Configuration externalization and validation
- Test-driven refactoring with safety measures

#### [`/resolve-issue`](resolve-issue.md)
Analyze and resolve GitHub issues with proper closure, documentation, and workflow integration.

**When to use:**
- Fixing bugs reported in GitHub issues
- Resolving merge conflicts
- Addressing technical debt items
- Implementing feature requests

**Features:**
- Multi-agent workflow support for complex issues
- Automatic issue closure upon resolution
- Git workflow integration with proper push procedures
- Comprehensive validation and testing

### 📋 Task Management

Commands for managing development tasks, issues, and agent coordination:

#### [`/create-issue`](create-issue.md)
Create GitHub issues with proper agent workflow templates and lifecycle management for coordinated development.

**When to use:**
- Creating tasks for other agents
- Coordinating multi-agent development work
- Establishing clear task ownership and requirements

**Features:**
- Structured agent workflow templates
- Clear assignment and authority definition
- Complete lifecycle management protocols
- Integration with worktree organization

#### [`/start-session`](start-session.md)
Create fully automated Claude Code sessions using the enhanced setup-agent-task.sh script with comprehensive environment setup.

**When to use:**
- Starting new development tasks
- Creating isolated development environments
- Setting up agent-specific workflows

**Automation features:**
- Environment validation and setup
- GitHub issue creation with templates
- Worktree setup with proper directory structure
- iTerm2 integration and context file support

### 📚 Documentation Management

Commands for maintaining project documentation and state tracking:

#### [`/update-current-state`](update-current-state.md)
Update project current state documentation with consistent formatting and comprehensive change tracking.

**When to use:**
- End of development sessions
- Major milestone completions
- Documenting decisions and progress

**Formatting requirements:**
- Strict timestamp formatting (UTC with full dates)
- Structured section organization
- Historical preservation
- Consistent emoji and formatting standards

## Usage Guidelines

### Command Execution
All commands are invoked using the slash prefix in Claude Code:
```
/command-name arguments
```

### Multi-Agent Coordination
Several commands integrate with the multi-agent workflow system:
- Complex tasks are automatically delegated to appropriate specialized agents
- Proper issue tracking and worktree organization
- Coordinated development with clear ownership and accountability

### Safety and Compliance
All commands follow Tuvens ecosystem safety protocols:
- Branch protection and naming validation
- Pre-commit hook integration
- Never bypass quality checks or safety measures
- Proper git workflow with --force-with-lease safety

### Integration Points
Commands integrate with:
- `.github/workflows/` - Automated validation and CI/CD
- `agentic-development/` - Multi-agent coordination system
- Branch tracking and worktree organization
- Cross-repository sync automation

## Getting Help

For command-specific help, open the individual command files linked in the table above. Each command includes:
- Detailed usage instructions
- Process workflows and safety measures
- Examples and common scenarios
- Integration requirements and best practices

---
*Commands directory maintained by devops agent*
*Last updated: 2025-08-19*