# Wiki Content Staging Directory

**Temporary staging area for wiki-destined content before publication**

## Overview

This directory provides organized staging for content that will be synchronized to the GitHub wiki by the vibe coder agent. Content placed here is temporary and will be moved to the GitHub wiki repository upon PR approval.

## Directory Structure

```
staging/
├── README.md              # This file - staging area documentation
├── guides/                # User documentation and tutorials
├── drafts/                # Ideas that evolve into permanent docs
├── archives/              # Historical implementation logs
├── architecture/          # High-level system design (WHY decisions)
└── protocols/             # Deep protocol documentation (rare reference)
```

## Usage Instructions

### For Content Creators (Claude Desktop Agents)
1. **Choose appropriate category** for your content
2. **Create descriptive filename** using hyphenated naming convention
3. **Follow content template** as outlined in `../instructions.md`
4. **Create PR with `wiki-ready` label** when content is complete

### For Vibe Coder Agent (Claude Code)
1. **Detect `wiki-ready` PRs** and validate content quality
2. **Review staged content** for completeness and accuracy
3. **Sync to GitHub wiki** using category-based organization
4. **Clean up staging files** after successful publication
5. **Merge PR** with minimal permanent changes

## Content Categories

### 📖 Guides
**Purpose**: User documentation and tutorials  
**Examples**: Getting started guides, how-to tutorials, troubleshooting guides  
**Target Audience**: Human users, new developers, end users  

### 💡 Drafts  
**Purpose**: Ideas that evolve into permanent documentation (core wiki function)  
**Examples**: Brainstorming sessions, preliminary concepts, collaborative development ideas  
**Target Audience**: Development team, stakeholders, collaborators  

### 📚 Archives
**Purpose**: Historical implementation logs and completed project records  
**Examples**: Implementation logs no longer actively needed, project evolution documentation  
**Target Audience**: Future reference, historical context, project archaeology  

### 🏗️ Architecture
**Purpose**: High-level system design and WHY decisions were made  
**Examples**: Architectural decision rationale, system design philosophy, integration reasoning  
**Target Audience**: System architects, senior developers (deep understanding needs)  

### 📋 Protocols
**Purpose**: Deep protocol philosophy and design rationale (not daily procedures)  
**Examples**: Protocol decision reasoning, standards background, compliance philosophy  
**Target Audience**: Protocol designers, compliance architects (rare reference needs)  

## File Naming Conventions

Use descriptive, hyphenated names that clearly indicate content:
- `multi-agent-coordination-overview.md`
- `vibe-coder-orchestration-protocols.md`  
- `cross-repository-development-guide.md`
- `branch-protection-implementation.md`
- `getting-started-developer-guide.md`

## Quality Standards

### Before Staging Content
✅ **Complete Information**: Self-contained with necessary context  
✅ **Professional Writing**: Clear, concise, well-structured  
✅ **Technical Accuracy**: Validated procedures and information  
✅ **Proper Formatting**: Consistent markdown structure  
✅ **Working Links**: Valid internal and external references  

### Content Template Compliance
✅ **Standard Structure**: Title, overview, main sections, examples  
✅ **Metadata**: Author, date, version information  
✅ **Related Documentation**: Links to relevant content  
✅ **Troubleshooting**: Common issues and solutions where applicable  

## Staging Lifecycle

### 1. Content Creation
- Agent identifies need for wiki content
- Creates branch with `[agent]/wiki/[description]` naming
- Develops content in appropriate staging category
- Validates quality and completeness

### 2. Review and Approval
- Creates PR with `wiki-ready` label targeting `dev` branch
- Vibe coder agent reviews content quality and accuracy
- Feedback provided through PR comments if improvements needed
- Approval granted when content meets quality standards

### 3. Wiki Publication  
- Vibe coder syncs approved content to GitHub wiki repository
- Updates wiki navigation and cross-references
- Content organized by category in wiki structure
- Source staging files marked for cleanup

### 4. Cleanup and Completion
- Staging files removed from main repository  
- PR merged with minimal permanent changes
- Wiki content live and accessible
- Workflow completion confirmed in PR comments

## Temporary Nature Notice

⚠️ **IMPORTANT**: Content in this staging directory is temporary and will be removed after successful wiki publication. Do not rely on staging files for permanent reference - always use the published GitHub wiki content.

## Success Metrics

✅ **Quality Publication**: All content meets documentation standards  
✅ **Organized Structure**: Proper categorization and wiki organization  
✅ **Clean Repository**: Staging cleaned after publication  
✅ **Accessible Content**: Published content findable in GitHub wiki  
✅ **Efficient Workflow**: Consistent processing time and quality  

---

**Last Updated**: 2025-08-15  
**Maintained By**: DevOps Agent  
**Version**: 1.0 - Initial wiki staging implementation  

*This staging area enables organized, quality-controlled publication of documentation to the GitHub wiki while maintaining repository cleanliness.*