# Wiki Content Creation Instructions for Claude Desktop

**Direct workflow guide for creating wiki content using Claude Desktop natural language integration**

## Overview

This document provides instructions for creating wiki content using Claude Desktop's natural language interface with direct Claude Code workflow integration.

## When to Create Wiki Content

### ✅ Appropriate Wiki Content
- **User Guides**: Getting started documentation, tutorials, how-to guides for human users
- **Draft Ideas**: Brainstorming, preliminary concepts, and evolving documentation (core wiki function)
- **Architecture Documentation**: High-level system design and WHY decisions were made  
- **Protocol Documentation**: Deep protocol philosophy and design rationale (not daily procedures)
- **Historical Archives**: Implementation logs when no longer actively needed by agents

### ❌ Not Appropriate for Wiki
- **Agent Operational Documentation**: Daily workflows, procedures agents need constant access to
- **Implementation Steps**: HOW-to procedures for agent operations (belongs in agentic-development)
- **Temporary Work Notes**: Implementation-specific notes and debugging information
- **PR-Specific Content**: Pull request descriptions and code review comments
- **Private Information**: Sensitive configuration, credentials, or internal-only content

### 🎯 **WHY vs HOW Distinction**
**Key Principle**: Wiki content explains design rationale and deep understanding, while agentic-development contains operational procedures.

- **Wiki (WHY)**: Why was this architecture chosen? What was the reasoning behind this protocol design?
- **Agentic-Dev (HOW)**: How do I implement this? What are the step-by-step procedures?

**Example**: 
- Wiki: "Multi-agent coordination architecture: rationale and design principles"
- Agentic-dev: "Agent coordination protocols: implementation procedures"

## Direct Wiki Creation Workflow

### Step 1: Natural Language Request
Simply tell Claude Desktop what wiki content you need:

**Natural Language Examples:**
```
"Create wiki documentation for agent coordination protocols"
"Document the system architecture overview in the wiki"
"Have vibe-coder create a branch protection guide for the wiki"
"Create comprehensive user guide for new developers"
```

### Step 2: Automated Claude Desktop Response
```
I understand you want wiki documentation for [topic]. 
Should I set up a Claude Code session with:
- Agent: vibe-coder
- Task: Create Wiki Documentation for [topic]
- Context: [details]

Would you like me to proceed? [Yes/No]
```

### Step 3: Automated Claude Code Setup
When confirmed, Claude Desktop automatically:
1. **Creates GitHub Issue** - Documents the wiki task
2. **Sets Up Git Worktree** - Branch: `vibe-coder/wiki/[descriptive-name]`
3. **Launches Claude Code** - Pre-loaded with context
4. **Direct Wiki Creation** - Content created directly in GitHub wiki format

### Wiki Content Structure Template

```markdown
# [Document Title]

**Brief Description**: One-line summary of document purpose

## Overview
- What this document covers
- Who should read this
- Prerequisites or related reading

## [Main Content Sections]
- Use clear, descriptive headings
- Include code examples where appropriate
- Provide step-by-step instructions
- Add relevant diagrams or flowcharts

## Examples
- Concrete examples of concepts or procedures
- Code snippets with explanations
- Real-world scenarios and use cases

## Related Documentation
- Links to related wiki pages
- References to relevant GitHub files
- Cross-links to agent documentation

## Troubleshooting
- Common issues and solutions
- Error messages and fixes
- Where to get additional help

---
**Last Updated**: [Date]  
**Author**: [Agent Name]  
**Version**: [Version Number]
```

### Content Quality Standards

#### Technical Writing Requirements
- **Clear Structure**: Logical organization with descriptive headings
- **Professional Tone**: Formal but accessible technical writing
- **Complete Information**: Self-contained with necessary context
- **Accurate References**: Valid links and file path references
- **Current Content**: Up-to-date with latest system changes

#### Formatting Standards
- **Markdown Consistency**: Proper heading hierarchy (H1 > H2 > H3)
- **Code Formatting**: Proper syntax highlighting and indentation
- **Link Validation**: Working internal and external references
- **Table Structure**: Well-formatted tables with clear headers
- **List Organization**: Consistent bullet points and numbering

#### Content Validation
- **Technical Accuracy**: Verified procedures and accurate information
- **Completeness**: All necessary information for target audience
- **Clarity**: Understandable by intended readers
- **Usefulness**: Practical value for documentation consumers
- **Maintenance**: Clear ownership and update procedures

## Mobile Content Creation

### Creating Wiki Content on Mobile
When using Claude app on phone:
1. **Draft content** using natural language conversation
2. **Use desktop Claude Desktop** to convert drafts to wiki format
3. **Say**: *"Convert this mobile draft to wiki documentation for [topic]"*
4. **Automatic processing** through the standard Claude Code workflow

## Automated Publication Workflow

### Direct Wiki Publication
Once Claude Code session is launched:
1. **Content Creation** - Wiki content created directly in GitHub wiki format
2. **Quality Validation** - Automated quality checks during creation
3. **Direct Publication** - Content published immediately to GitHub wiki
4. **Navigation Updates** - Wiki organization and navigation updated automatically
5. **Pull Request** - Minimal changes to main repository for tracking

## Quality Assurance Process

### Built-in Validation
The direct workflow includes:
1. **Real-time Quality Checks** - Validation during content creation
2. **Template Compliance** - Automatic formatting standards application
3. **Link Verification** - Automatic validation of references
4. **Category Organization** - Proper wiki navigation structure
5. **Publication Confirmation** - Immediate feedback on successful publication

## Error Handling and Recovery

### Common Issues
- **Invalid Category**: Content placed in wrong staging directory
- **Missing Information**: Incomplete documentation requiring additional details
- **Format Problems**: Inconsistent formatting or broken links
- **Duplicate Content**: Content that overlaps with existing wiki pages

### Recovery Procedures
1. **Address Feedback**: Make requested changes based on vibe coder review
2. **Update PR**: Push corrections to same branch and PR
3. **Re-validate**: Ensure all quality standards met
4. **Confirm Ready**: Re-add `wiki-ready` label after corrections

### Emergency Procedures
- **Content Removal**: Process for removing inappropriate or outdated content
- **Rollback Process**: Steps for undoing problematic wiki changes
- **Quality Escalation**: When to involve additional agents or manual review
- **Branch Recovery**: Handling corrupted branches or failed syncs

## Best Practices

### Content Development
- **Start with Outline**: Plan document structure before writing
- **Write for Audience**: Consider who will read and use the documentation
- **Include Examples**: Provide concrete examples and use cases
- **Link Strategically**: Reference related documentation and resources
- **Plan for Maintenance**: Consider how content will be updated over time

### Workflow Efficiency  
- **Batch Related Content**: Create multiple related documents in single PR
- **Reuse Templates**: Leverage established formatting and structure patterns
- **Validate Early**: Check links and formatting before PR creation
- **Clear Communication**: Provide detailed PR descriptions and context
- **Follow Conventions**: Adhere to established naming and organizational patterns

### Quality Assurance
- **Technical Review**: Have content reviewed by subject matter experts
- **User Testing**: Validate documentation with intended users
- **Regular Updates**: Keep content current with system changes
- **Link Maintenance**: Regularly check and update reference links
- **Feedback Integration**: Incorporate user feedback and suggestions

## Success Validation

### Content Quality Metrics
✅ **Completeness**: All necessary information included  
✅ **Accuracy**: Technical information verified and current  
✅ **Clarity**: Understandable by target audience  
✅ **Usefulness**: Practical value for readers  
✅ **Maintainability**: Clear ownership and update procedures  

### Workflow Efficiency Metrics  
✅ **Fast Creation**: Direct wiki creation without intermediate steps  
✅ **Quality Review**: Real-time validation during content creation  
✅ **Clean Repository**: Minimal impact on main repository  
✅ **Easy Navigation**: Automatic wiki organization and structure  
✅ **Mobile Support**: Seamless mobile-to-desktop workflow integration  

---

**Last Updated**: 2025-08-22  
**Maintained By**: Vibe Coder Agent  
**Version**: 2.0 - Direct Claude Code workflow integration  

*These instructions enable streamlined wiki content creation through Claude Desktop natural language interface with direct GitHub wiki publication.*