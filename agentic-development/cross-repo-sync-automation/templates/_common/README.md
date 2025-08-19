# Common Template Components

This directory contains reusable template components that are shared across all repository types in the cross-repository sync automation system.

## Components

### 📋 Template Structure
- **`header-template.md`** - Standard notification header with update details
- **`footer.md`** - Closing section with additional resources and contact information
- **`help-section.md`** - Help and support information section
- **`timeline-requirements.md`** - Timeline expectations and scheduling information

### 🔧 Automation Components  
- **`automated-verification-setup.md`** - Instructions for setting up automated verification
- **`submodule-update-step.md`** - Step-by-step submodule update procedures

## Use Cases

### For Template Developers
- **Content standardization**: Ensure consistent messaging across all repository types
- **Maintenance efficiency**: Update shared content once, deploy everywhere
- **Component reuse**: Build new templates using proven, tested components

### For DevOps Engineers
- **Automation setup**: Use verification and update components in CI/CD pipelines
- **Process standardization**: Implement consistent procedures across repositories
- **Error reduction**: Use standardized components to reduce manual setup errors

### For Documentation Teams
- **Message consistency**: Maintain uniform communication style across notifications
- **Content management**: Centralize common messaging for easier updates
- **Brand compliance**: Ensure all automated messages follow organizational standards

## Agent Selection Guide

### Recommended Agents by Component Type

#### **vibe-coder** - Content and messaging
- Updating notification text and messaging
- Improving clarity and readability
- Managing help and support content
- README and documentation updates

#### **devops** - Automation and procedures
- Modifying verification setup procedures
- Updating submodule and automation steps
- Timeline and scheduling requirements
- Technical procedure documentation

#### **Any specialist agent** - Domain-specific content
- For content related to specific technology stacks
- When components need technical accuracy review
- For integration with specific development workflows

## Component Details

### Template Variables
Common components use placeholder variables that are replaced during template building:
- `[REPO_TYPE]` - Repository type (backend, frontend, integration, mobile)
- `[COMMIT_SHA]` - Git commit identifier
- `[COMMIT_MESSAGE]` - Commit description
- `[CHANGED_FILES]` - List of modified files
- `[REPO_NAME]` - Target repository name

### Modification Guidelines
1. **Preserve variables**: Keep placeholder syntax intact when editing content
2. **Test compatibility**: Verify changes work across all repository types
3. **Update build script**: If adding new components, update `../build-templates.sh`
4. **Document changes**: Update this README when adding or removing components

## Usage in Build Process

These components are automatically included in generated templates by the build script:
1. Components are read from this directory
2. Variables are replaced with repository-specific values
3. Components are assembled into complete notification templates
4. Final templates are written to the parent templates directory

To rebuild templates after modifying components:
```bash
cd ..
./build-templates.sh
```