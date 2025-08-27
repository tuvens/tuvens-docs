# Repository-Specific Template Components

This directory contains the repository-specific components that are used to build the notification templates for each repository type.

## Structure

Each repository type (backend, frontend, integration, mobile) has six component files:

### 1. Critical Changes
`{repo-type}-critical-changes.md`
- Contains repository-specific items that need immediate review
- Highlights unique aspects for each repository type

### 2. Verification
`{repo-type}-verification.md` 
- Commands to verify new documentation access
- Includes repository-specific file paths and checks

### 3. Specific Actions
`{repo-type}-specific-actions.md`
- Step 3 actions tailored to each repository type
- Implementation verification commands
- Testing procedures specific to the repository

### 4. Completion Template
`{repo-type}-completion.md`
- Repository-specific completion confirmation template
- Includes unique verification commands and status checks

### 5. Quality Standards
`{repo-type}-quality-standards.md`
- Quality requirements specific to each repository type
- Additional checklists (e.g., security, integration, mobile platform compliance)

### 6. Help Additions
`{repo-type}-help-additions.md`
- Additional help resources specific to each repository type
- Links to repository-specific documentation

## Usage

These components are automatically assembled by the `build-templates.sh` script to create the final notification templates. 

To modify content:
- **Common sections**: Edit files in `_common/` directory
- **Repository-specific sections**: Edit files in this `_repo-specific/` directory
- **Rebuild templates**: Run `./build-templates.sh`

## Repository Types

- **Backend**: API endpoints, database schemas, authentication implementation
- **Frontend**: Design system compliance, component standards, UI testing
- **Integration**: Cross-app authentication, widget integration, Hi.Events specific requirements
- **Mobile**: Platform compliance, mobile-specific design patterns, performance requirements

## Maintenance

When updating templates:
1. Extract changes to appropriate component files
2. Run build script to regenerate final templates
3. Test templates to ensure functionality is preserved