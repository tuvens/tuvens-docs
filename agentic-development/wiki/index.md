# Tuvens Documentation Wiki Index

**Central index for GitHub wiki content integration with Claude Desktop + Claude Code workflow**

## Overview

This directory provides the coordination interface between:
- **Claude Desktop** agents creating wiki-destined content on branches
- **Claude Code vibe coder** agent syncing content to the actual GitHub wiki
- **GitHub Wiki**: https://github.com/tuvens/tuvens-docs/wiki

## Content Organization

### 🏠 Local Wiki Directory Structure
```
agentic-development/wiki/
├── index.md              # This file - wiki content index and navigation
├── instructions.md       # Claude Desktop agent wiki workflow instructions
├── vibe-coder-workflow.md # Claude Code sync process documentation
├── claude-desktop-project-instructions.md # Concise Claude Desktop reference
└── staging/              # Temporary directory for wiki-ready content
    ├── README.md         # Staging area documentation
    ├── guides/          # User documentation and tutorials
    ├── drafts/          # Ideas that evolve into permanent docs
    ├── archives/        # Historical implementation logs
    ├── architecture/    # High-level system design (WHY decisions)
    └── protocols/       # Deep protocol documentation (rare reference)
```

### 🌐 GitHub Wiki Organization
**Access**: https://github.com/tuvens/tuvens-docs/wiki

#### Home Page
- System overview and quick navigation
- Getting started with Tuvens multi-agent system
- Link to this wiki workflow documentation

#### Architecture Section
- Multi-agent system design
- Repository organization and coordination
- Branch management and workflow strategies
- Cross-repository synchronization patterns

#### Agent Documentation
- Individual agent roles and capabilities
- Agent interaction protocols
- Development workflow patterns
- Handoff and coordination procedures

#### Development Workflows
- Branching strategies and conventions
- Quality assurance and testing protocols
- Cross-repository development patterns
- Mobile and desktop development integration

#### Protocols & Standards
- Safety rules and compliance validation
- Branch protection and security protocols
- Documentation standards and templates
- Issue management and coordination

#### User Guides
- Getting started for new developers
- Agent-specific usage instructions
- Mobile artifact handling procedures
- Troubleshooting and error recovery

## Content Categories

### 📋 Permanent GitHub Wiki Content
- **User Guides**: Getting started documentation, tutorials, and how-to guides
- **Draft Ideas**: Brainstorming, preliminary concepts, and evolving documentation
- **Architecture Documentation**: High-level system design and WHY decisions were made
- **Protocol Documentation**: Deep protocol philosophy and design rationale
- **Historical Archives**: Implementation logs and project evolution records

### 🔄 Staged Content (Temporary)
- **guides/**: User-facing documentation and tutorials
- **drafts/**: Ideas that evolve into permanent documentation
- **archives/**: Historical implementation logs (when no longer actively needed)
- **architecture/**: System design philosophy and decision rationale
- **protocols/**: Deep protocol understanding and design principles

### 🎯 **WHY vs HOW Distinction**
- **Wiki Content (WHY)**: Design rationale, architectural decisions, deep understanding
- **Agentic-Development (HOW)**: Operational procedures, implementation steps, daily workflows

### 🏠 Local Repository Files (Minimal)
- **index.md**: This navigation and organization file
- **instructions.md**: Claude Desktop workflow instructions
- **vibe-coder-workflow.md**: Claude Code sync process documentation
- **staging/**: Temporary directory for content preparation (cleaned after sync)

## Requesting Access to Wiki Content

### For Claude Desktop Agents
1. **Check this index** for content organization and categories
2. **Follow staging workflow** in `instructions.md` for creating new content
3. **Use appropriate categories** when staging content for wiki publication
4. **Mark content ready** using standard PR labeling when complete

### For Claude Code Agents
1. **Review staging content** for quality and completeness
2. **Follow sync workflow** in `vibe-coder-workflow.md` for wiki publication
3. **Update this index** when wiki organization changes
4. **Clean staging directory** after successful wiki publication

### For Developers
1. **Browse GitHub wiki** for published documentation and guides
2. **Submit requests via issues** for new documentation or updates
3. **Follow mobile workflow** for content created on phone Claude app
4. **Use desktop workflow** for complex documentation development

## Mobile Support

### Artifact Processing
- **Mobile Creation**: Content created on phone Claude app saved locally
- **Desktop Processing**: Transfer to desktop for proper wiki staging
- **Category Assignment**: Proper categorization during desktop processing
- **Quality Review**: Standard review process before wiki publication

### Workflow Integration
- Mobile artifacts marked with special identifiers
- Desktop agents process mobile content into proper staging format
- Standard wiki sync process handles all content regardless of origin
- Clear documentation trail for mobile-originated content

## Separation of Concerns

### Main Repository (`agentic-development/wiki/`)
- **Purpose**: Workflow coordination and staging only
- **Content**: Index, instructions, workflow documentation, temporary staging
- **Maintenance**: Keep minimal and clean, remove staged content after sync

### GitHub Wiki Repository
- **Purpose**: Permanent documentation and knowledge base
- **Content**: All published documentation, guides, and reference materials
- **Maintenance**: Organized, searchable, versioned documentation

## Success Criteria

✅ **Content Organization**: Clear categorization and navigation structure  
✅ **Workflow Integration**: Seamless Claude Desktop to GitHub wiki publishing  
✅ **Mobile Compatibility**: Support for phone-based content creation  
✅ **Quality Control**: Review and validation before wiki publication  
✅ **Clean Repository**: Minimal permanent files in main repo wiki directory  
✅ **Easy Navigation**: Clear index and organization for finding content  

## Quality Standards

### Content Requirements
- **Professional Writing**: Clear, concise, and well-structured documentation
- **Technical Accuracy**: Validated information with proper references
- **Consistent Formatting**: Following established templates and style guides
- **Current Information**: Up-to-date with latest system changes and protocols

### Review Process
- **Agent Review**: Initial quality check by creating agent
- **Vibe Coder Validation**: Final review before wiki publication
- **Category Verification**: Proper organization and categorization
- **Link Validation**: Working references and navigation paths

## Maintenance Schedule

### Weekly
- Review staging directory for orphaned content
- Validate wiki organization and navigation
- Update index with new categories or significant changes
- Clean up completed staging content

### Monthly  
- Audit GitHub wiki for outdated information
- Review and update workflow documentation
- Validate mobile artifact processing procedures
- Update success criteria and quality standards

---

**Last Updated**: 2025-08-15  
**Maintained By**: DevOps Agent  
**Version**: 1.0 - Initial wiki workflow implementation  

*This index coordinates the integration between local wiki workflow staging and the permanent GitHub wiki knowledge base.*