# Cross-Repository Sync Automation Templates

This directory contains template components for automated cross-repository documentation synchronization and notification systems.

## Directory Structure

### 📁 Template Components
- **[_common/](./_common/)** - Shared template components used across all repository types
- **[_repo-specific/](./_repo-specific/)** - Repository-type-specific template components
- **[github-actions/](./github-actions/)** - GitHub Actions workflow templates

### 📄 Generated Templates
- `backend-notification.md` - Complete notification template for backend repositories
- `frontend-notification.md` - Complete notification template for frontend repositories
- `integration-notification.md` - Complete notification template for integration repositories
- `mobile-notification.md` - Complete notification template for mobile repositories
- `repository-verification-workflow.yml` - GitHub Actions workflow for repository verification

## Use Cases

### For DevOps Engineers
- **Workflow automation**: Use GitHub Actions templates to set up automated documentation sync
- **Repository setup**: Deploy verification workflows across multiple repositories
- **Template maintenance**: Modify common components and regenerate repository-specific templates

### For Development Teams
- **Notification integration**: Use generated notification templates for cross-repo updates
- **Documentation sync**: Implement automated documentation propagation workflows
- **Quality assurance**: Use verification templates to ensure documentation consistency

### For System Architects
- **Multi-repo coordination**: Understand template system for large-scale documentation managemen
- **Cross-cutting concerns**: Implement shared standards across repository types
- **Automation design**: Design template-based automation systems

## Agent Selection Guide

### Recommended Agents by Task

#### **devops** - Primary template maintenance
- Modifying GitHub Actions workflows
- Template system architecture changes
- Cross-repository automation setup
- Verification script updates

#### **vibe-coder** - Content and documentation
- Template content updates
- Documentation structure improvements
- Notification message refinemen
- README maintenance

#### **node-dev** or **laravel-dev** - Repository-specific logic
- Backend-specific template components
- API integration templates
- Server-side workflow modifications

#### **react-dev** - Frontend integration
- Frontend notification handling
- UI-related template components
- Client-side documentation integration

## Quick Star

### Building Templates
```bash
# Generate all repository-specific templates from components
./build-templates.sh
```

### Customizing Templates
1. **Common changes**: Edit files in `_common/` directory
2. **Repository-specific changes**: Edit files in `_repo-specific/` directory
3. **Rebuild**: Run `./build-templates.sh` to regenerate final templates
4. **Deploy**: Copy generated templates to target repositories

### Adding New Repository Types
1. Create new component files in `_repo-specific/` following naming pattern
2. Update `build-templates.sh` to include new repository type
3. Test generated templates with target repository structure

## Template Architecture

The template system uses a modular approach:
- **Atomic components** in `_common/` provide reusable sections
- **Repository-specific components** customize content for each repo type
- **Build script** assembles components into complete, deployable templates
- **GitHub Actions templates** provide ready-to-use workflow automation

This design ensures consistency while allowing repository-specific customization and easy maintenance of shared content.
