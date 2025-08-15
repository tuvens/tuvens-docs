# Wiki Content Staging Directory

**Temporary staging area for wiki-destined content before publication**

## Overview

This directory provides organized staging for content that will be synchronized to the GitHub wiki by the vibe coder agent. Content placed here is temporary and will be moved to the GitHub wiki repository upon PR approval.

## Directory Structure

```
staging/
├── README.md              # This file - staging area documentation
├── architecture/          # System design and technical architecture
├── agents/                # Agent roles, capabilities, and protocols
├── workflows/             # Development processes and coordination
├── protocols/             # Standards, safety rules, and compliance
└── guides/                # User documentation and tutorials
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

### 🏗️ Architecture
**Purpose**: System design and technical specifications  
**Examples**: Multi-agent coordination patterns, repository organization, integration strategies  
**Target Audience**: Developers, system architects, technical leads  

### 🤖 Agents  
**Purpose**: Agent documentation and interaction protocols  
**Examples**: Role definitions, capabilities, handoff procedures  
**Target Audience**: Agent developers, coordination specialists  

### 🔄 Workflows
**Purpose**: Development processes and coordination patterns  
**Examples**: Branching strategies, quality assurance, cross-repo development  
**Target Audience**: All developers, project managers  

### 📋 Protocols
**Purpose**: Standards, rules, and compliance procedures  
**Examples**: Safety rules, branch protection, documentation standards  
**Target Audience**: All team members, compliance officers  

### 📖 Guides
**Purpose**: User documentation and instructional content  
**Examples**: Getting started guides, tutorials, troubleshooting  
**Target Audience**: New developers, end users  

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