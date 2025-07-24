# Contributing to Tuvens Documentation Templates

## 🚨 Important: Do Not Edit Templates Directly

**DO NOT** directly edit templates in individual repositories. All improvements must go through this shared repository to maintain consistency across the ecosystem.

## How to Contribute

### 1. Reporting Issues or Suggesting Improvements

Create an issue in this repository describing:
- **What you want to improve** (be specific about which template/file)
- **Why the improvement is needed** (what problem it solves)
- **Proposed solution** (if you have one)

### 2. Contributing Code Changes

1. **Fork this repository**
2. **Create a feature branch** from `main`
3. **Make your changes** to the templates in `claude-templates/`
4. **Test your changes** using the setup script with different repository configurations
5. **Submit a pull request** with a clear description of the improvements

### 3. Template Guidelines

When modifying templates:

#### Use Placeholder Syntax
- `{CURRENT_REPOSITORY}` - Current repository name
- `{PROJECT_NAME}` - Project/repository identifier
- `{ECOSYSTEM_NAME}` - Ecosystem/organization name
- `{PROJECT_1}`, `{PROJECT_2}`, etc. - Other ecosystem repositories
- `{CURRENT_PROJECT_URL}` - Current repository URL
- `{REFERENCE_PROJECT}` - Reference implementation repository

#### Maintain Generic Language
- Avoid hardcoded repository names
- Use descriptive but generic terminology
- Ensure templates work for any repository type

#### Test Placeholder Replacement
- Verify `setup.sh` correctly replaces all placeholders
- Test with different repository names and configurations
- Ensure no broken references remain after customization

### 4. Required Testing

Before submitting changes:

1. **Test setup script** with at least 2 different repository names
2. **Verify placeholder replacement** works correctly
3. **Check all command templates** load properly in Claude Code
4. **Validate GitHub CLI integration** works with generated commands

### 5. Documentation Updates

When adding new features:
- Update `README.md` with new instructions
- Update command registry in `claude-templates/commands/commands.json`
- Document any new placeholder variables
- Add examples for complex features

## Review Process

### Pull Request Requirements

- [ ] All templates use placeholder syntax (no hardcoded values)
- [ ] Setup script correctly handles new/modified templates
- [ ] Changes are tested with multiple repository configurations
- [ ] Documentation is updated to reflect changes
- [ ] Commit messages follow conventional commit format

### Testing Checklist

- [ ] `setup.sh` runs without errors
- [ ] All placeholders are replaced correctly
- [ ] Generated commands work with GitHub CLI
- [ ] No broken file references after setup
- [ ] Templates maintain consistent formatting

## Update Distribution Process

⚠️ **IMPORTANT**: The current manual process has known issues and is being replaced with automation.

### Current Status (Manual Process - Being Phased Out)
The existing manual notification process has several failure points:
- Protocol awareness gaps
- Unclear instructions in notifications
- Manual errors and missed repositories  
- No automated verification

### 🚀 NEW: Automated Change Notification Protocol
**See:** `shared-protocols/automated-change-notification.md`

This new protocol provides:
- **Phase 1**: Enhanced manual process with clearer instructions
- **Phase 2**: Semi-automated GitHub Actions workflows
- **Phase 3**: Fully automated repository updates and verification

### For Repository Maintainers (Transitional)

Until automation is fully implemented:
1. **Use the enhanced notification template** from `shared-protocols/automated-change-notification.md`
2. **Create update notification issues** in all consuming repositories with clearer instructions
3. **Track confirmation responses** and verify compliance
4. **Close notification issues** only after automated verification (when available)

### Update Notification Template

Copy this template when creating update issues:

```markdown
## 📢 Documentation Template Updates Available

New improvements have been made to the shared documentation templates:

### What's New
- [Describe specific improvements/fixes]

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

## Code Style Guidelines

### Markdown Templates
- Use consistent heading levels
- Include code block language specifications
- Maintain clear section organization
- Use bullet points for lists, not numbered unless order matters

### JSON Configuration
- Use 2-space indentation
- Include descriptive comments where helpful
- Maintain alphabetical ordering where logical
- Include version and metadata information

### Shell Scripts
- Include error handling (`set -e`)
- Use clear variable names
- Include help documentation
- Test on multiple platforms when possible

## Getting Help

If you need assistance:

1. **Check existing issues** for similar questions
2. **Review the README.md** for usage instructions
3. **Create a new issue** with the `question` label
4. **Reference specific files/lines** when asking about code

## Release Process

### Version Numbering
- Follow semantic versioning (major.minor.patch)
- Increment patch for bug fixes and template improvements
- Increment minor for new commands or features
- Increment major for breaking changes to template structure

### Release Notes
- Document all changes since last release
- Include migration instructions for breaking changes
- Highlight important new features
- Credit contributors

## Community Guidelines

- Be respectful and constructive in discussions
- Provide clear, actionable feedback
- Test your suggestions before proposing them
- Help others understand the impact of proposed changes

## Questions?

- Create an issue with the `question` label
- Reference the original implementation in [eventdigest-ai](https://github.com/tuvens/eventdigest-ai)
- Check the project's main documentation for context

---

*Thank you for contributing to the Tuvens documentation ecosystem!*