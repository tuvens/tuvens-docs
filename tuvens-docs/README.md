# Tuvens Documentation Templates

Shared Claude Code documentation templates and structure for the Tuvens ecosystem repositories.

## Purpose

This repository provides standardized documentation templates that enable:
- ✅ Consistent Claude Code experience across all Tuvens repositories
- ✅ Cross-repository communication via standardized commands
- ✅ Organized temporary documentation sharing between Claude sessions
- ✅ Reduced maintenance overhead through centralized templates

## Structure

```
claude-templates/
├── commands/
│   ├── commands.json          # Command registry
│   ├── resolve-issue.md       # Close GitHub issues properly
│   ├── update-current-state.md # Project status updates
│   ├── report-bug.md          # Cross-repo bug reports
│   ├── send-rqts.md           # Feature requests
│   ├── ask-question.md        # Cross-repo questions
│   ├── suggest-improvement.md # Optimization suggestions
│   └── propose-alternative.md # Architectural alternatives
├── INTEGRATION_REGISTRY.md   # Tuvens ecosystem repository registry
└── .temp/                     # Organized temporary documentation structure
    ├── complete/
    ├── redundant/
    ├── in-progress/
    ├── ready-for-implementation/
    ├── integration-rqts/
    ├── bug-reports/
    ├── archived/
    ├── deprecated/
    ├── screenshots/
    ├── reports/
    ├── implementation-guides/
    ├── integration-docs/
    ├── auto-generated/
    └── commands/
```

## How to Use in Your Repository

### Option 1: Git Submodule (Recommended)

Add as a submodule to get automatic updates:

```bash
# In your repository root
git submodule add https://github.com/tuvens/tuvens-docs.git docs/shared-templates
git submodule update --init --recursive

# Copy templates to your docs structure
mkdir -p docs/.claude
cp -r docs/shared-templates/claude-templates/* docs/.claude/
cp -r docs/shared-templates/claude-templates/.temp docs/
```

### Option 2: Direct Copy

For a one-time setup:

```bash
# Clone the templates
git clone https://github.com/tuvens/tuvens-docs.git temp-docs

# Copy to your docs structure  
mkdir -p docs/.claude
cp -r temp-docs/claude-templates/* docs/.claude/
cp -r temp-docs/claude-templates/.temp docs/

# Cleanup
rm -rf temp-docs
```

### Option 3: Subdirectory Include

Include the entire repository as a subdirectory:

```bash
# In your repository root
git clone https://github.com/tuvens/tuvens-docs.git docs/tuvens-shared

# Reference files from docs/tuvens-shared/claude-templates/
```

## Customization Required

After copying templates, **you must customize repository references**:

1. **Update commands.json**: Change the description to reflect your repository name
2. **Update INTEGRATION_REGISTRY.md**: Mark your repository as "Current Repository" 
3. **Update command templates**: Replace repository references throughout all .md files
4. **Create project-instructions.md**: If `docs/.claude/project-instructions.md` doesn't exist, generate it with your project's specific context

### Find and Replace Needed:
- `eventdigest-ai` → `your-repo-name`
- `eventdigest-ai/client` → `your-repo-name`

### Required Project Instructions File

**Important**: The shared templates reference `docs/.claude/project-instructions.md` for project-specific context. If this file doesn't exist in your repository, you should create it with:

- Project overview and purpose
- Architecture and technology stack details
- Development workflow and standards
- Testing requirements and guidelines
- Deployment information
- Repository-specific Claude Code instructions

Example structure:
```markdown
# [Your Project Name] - Claude Code Instructions

## Project Overview
[Brief description of your project's purpose and goals]

## Architecture
[Technology stack, framework choices, key architectural decisions]

## Development Workflow
[Branch strategy, code review process, testing requirements]

## Claude Code Specific Instructions
[Any project-specific guidance for Claude Code sessions]
```

## Tuvens Ecosystem Repositories

| Repository | Purpose | Status |
|------------|---------|--------|
| [tuvens-client](https://github.com/tuvens/tuvens-client) | Frontend application | Active |
| [tuvens-api](https://github.com/tuvens/tuvens-api) | Backend API services | Active |
| [hi.events](https://github.com/tuvens/hi.events) | Event management platform | Active |
| [eventdigest-ai](https://github.com/tuvens/eventdigest-ai) | AI-powered event analysis | Active |

## Update Protocols

### 🔄 Getting Latest Templates (For Claude Code Sessions)

**IMPORTANT**: At the start of each Claude Code session, check for template updates:

```bash
# If using subdirectory integration
cd docs/tuvens-shared  # or docs/shared-templates
git pull origin main

# If templates have been updated, re-copy them
cd ../..
cp -r docs/tuvens-shared/claude-templates/* docs/.claude/
# Re-customize placeholders for your repository
```

### 📢 Update Notifications

When this repository is updated, maintainers will create issues in all consuming repositories with the title:
**"[UPDATE] New Documentation Templates Available - Please Fetch"**

**When you see this issue:**
1. Follow the update steps above to fetch latest templates
2. Comment on the issue: "✅ Updated templates fetched in [repository-name]"
3. The issue will be closed when all repositories confirm updates

### 🔧 Contributing Template Improvements

**DO NOT** directly edit templates in your local repository. Instead:

1. **Create an issue** in https://github.com/tuvens/tuvens-docs describing the improvement
2. **Wait for the improvement** to be implemented in the shared repository
3. **Fetch the updates** using the protocol above

This ensures all repositories benefit from improvements and maintains consistency.

## Maintenance

This repository serves as the single source of truth for documentation templates across the ecosystem. Updates here automatically benefit all repositories using these templates.

### For Template Maintainers

To contribute improvements:
1. **Create an issue** describing the needed improvement
2. **Implement the improvement** in this repository
3. **🚀 AUTOMATED**: Push to main triggers automatic notification creation in all consuming repositories
4. **Monitor tracking issue** created automatically in tuvens-docs
5. **Verify integration** through automated repository verification

**New Automated System**: See `.github/README.md` for details on the automated notification and verification system.

### Update Notification Template

When templates are updated, create issues in consuming repositories:

```markdown
## 📢 Documentation Template Updates Available

New improvements have been made to the shared documentation templates:

### What's New
- [List specific improvements/fixes]

### How to Update
```bash
# Navigate to your shared templates directory
cd docs/tuvens-shared  # or docs/shared-templates

# Pull latest changes
git pull origin main

# Re-copy updated templates (if using copy method)
cd ../..
cp -r docs/tuvens-shared/claude-templates/* docs/.claude/

# Verify your repository-specific customizations are preserved
```

### Please Confirm
Comment "✅ Updated templates fetched in [repository-name]" when complete.

This issue will be closed when all repositories confirm updates.

---
*Created by: [maintainer] from tuvens-docs repository*
```

## Cross-Repository Communication Workflow

### When to Create Cross-Repository Issues

Claude Code should create issues in other repositories when encountering:

1. **Requirements for other systems** - When current work requires changes/features in another repo
2. **Integration bugs** - When issues are caused by problems in another system
3. **Questions** - When needing clarification about another system's behavior/API
4. **Suggestions** - When proposing improvements or optimizations that affect other systems
5. **Alternative approaches** - When suggesting different architectural solutions

### Quick Commands Available

- `/report-bug` - Report bugs in other repositories
- `/send-rqts` - Request features or capabilities
- `/ask-question` - Ask for clarification about implementations
- `/suggest-improvement` - Propose optimizations
- `/propose-alternative` - Suggest architectural changes
- `/resolve-issue` - Properly close GitHub issues
- `/update-current-state` - Maintain project status documentation

### GitHub CLI Setup Required

Ensure GitHub CLI is installed and authenticated:
```bash
# Check if gh is installed and authenticated
gh auth status

# If not authenticated, run:
gh auth login
```

### Issue Creation Process

1. **Determine Target Repository** - Use INTEGRATION_REGISTRY.md to identify the correct repository
2. **Use Appropriate Command** - Each command provides standardized issue templates
3. **Track and Follow Up** - Monitor created issues and respond to feedback

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

## Support

For questions about these templates or Claude Code integration:
- Reference the original implementation: [eventdigest-ai](https://github.com/tuvens/eventdigest-ai)
- Check existing GitHub issues in this repository
- Create new issues for template improvements

---

*Maintained by: Tuvens development team*  
*Last updated: 2025-07-24*