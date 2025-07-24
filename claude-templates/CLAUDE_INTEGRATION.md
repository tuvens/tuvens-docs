# Claude Code Inter-Project Communication Instructions

## Overview
This document provides standardized instructions for Claude Code sessions to communicate across multiple project repositories using GitHub issues. Each Claude Code session should follow these procedures when integration issues, questions, or collaboration needs arise.

## Setup Instructions

### 1. GitHub CLI Configuration
Ensure GitHub CLI is installed and authenticated:
```bash
# Check if gh is installed and authenticated
gh auth status

# If not authenticated, run:
gh auth login
```

### 2. Project Registry
**{ECOSYSTEM_NAME} Integration Points**

Refer to `docs/.claude/INTEGRATION_REGISTRY.md` for the complete list of ecosystem repositories.

## Communication Workflow

### When to Create Cross-Repository Issues

Claude Code should create issues in other repositories when encountering:

1. **Requirements for other systems** - When current work requires changes/features in another repo
2. **Integration bugs** - When issues are caused by problems in another system
3. **Questions** - When needing clarification about another system's behavior/API
4. **Suggestions** - When proposing improvements or optimizations that affect other systems
5. **Alternative approaches** - When suggesting different architectural solutions

### Quick Commands

Use these Claude Code commands for cross-repository communication:

- `/report-bug` - Report bugs in other repositories
- `/send-rqts` - Request features or capabilities
- `/ask-question` - Ask for clarification about implementations
- `/suggest-improvement` - Propose optimizations
- `/propose-alternative` - Suggest architectural changes

### Issue Creation Process

#### Step 1: Determine Target Repository
Based on the issue type, identify which repository should receive the issue using the Project Registry in INTEGRATION_REGISTRY.md.

#### Step 2: Use Appropriate Command
Use one of the commands above to create a properly formatted issue. Each command includes:
- Standardized issue template
- Automatic repository context
- Priority settings
- Clear categorization

#### Step 3: Track and Follow Up
Monitor created issues and respond to feedback:
```bash
# Check status of created issues
gh issue list --author @me --state open

# View specific issue
gh issue view <ISSUE_NUMBER> --repo <OWNER/REPO>
```

### Issue Labels and Organization

Consistent labels used across repositories:

- `claude-code` - Issues created by Claude Code sessions
- `integration` - Cross-repository integration issues
- `blocking` - Issues that block other work
- `question` - Questions requiring clarification
- `enhancement` - Suggestions for improvements
- `bug` - Bug reports from other systems

### User Communication Protocol

Always communicate to the user when:

1. **Creating cross-repo issues**: "I'm creating an issue in [REPO] because..."
2. **Waiting for external responses**: "I'm blocked waiting for response from [REPO] on issue [URL]"
3. **Receiving responses**: "The other Claude Code session responded to our issue: [SUMMARY]"
4. **Alternative approaches**: "While waiting, I could try [ALTERNATIVE] instead"

## Best Practices

1. **Be specific** - Provide clear, actionable descriptions
2. **Include context** - Always explain why the issue matters to current work
3. **Set realistic priorities** - Not everything is blocking
4. **Follow up** - Check on issues you've created
5. **Be responsive** - Address issues created by other Claude Code sessions promptly
6. **Document decisions** - Comment on closed issues with final outcomes

## Troubleshooting

If GitHub CLI commands fail:
```bash
# Re-authenticate
gh auth login

# Check permissions
gh auth status

# Verify repo access
gh repo view OWNER/REPO
```

## Integration Notes

This file works in conjunction with:
- `/CLAUDE.md` - Main project instructions
- `docs/.claude/commands/` - Command definitions for cross-repo communication
- `docs/.claude/project-instructions.md` - Detailed project context (if present)

---

**Remember**: Always load `docs/.claude/project-instructions.md` first, if present, for complete project context, then use these integration commands as needed for cross-repository communication.