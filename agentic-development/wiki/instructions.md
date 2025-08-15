# Wiki Content Creation Instructions for Claude Desktop Agents

**Comprehensive guide for creating wiki-destined content using the Claude Desktop + Claude Code workflow**

## Overview

This document provides Claude Desktop agents with complete instructions for creating content that will be published to the GitHub wiki through the vibe coder agent coordination system.

## When to Create Wiki Content

### ✅ Appropriate Wiki Content
- **System Architecture**: Design patterns, technical specifications, and system overviews
- **Agent Documentation**: Role definitions, capabilities, and interaction protocols
- **Development Workflows**: Branching strategies, coordination patterns, and best practices
- **User Guides**: Getting started documentation, tutorials, and how-to guides
- **Reference Documentation**: API references, configuration guides, and technical specifications
- **Protocol Standards**: Safety rules, quality standards, and compliance procedures

### ❌ Not Appropriate for Wiki
- **Temporary Work Notes**: Implementation-specific notes and debugging information
- **PR-Specific Content**: Pull request descriptions and code review comments
- **Private Information**: Sensitive configuration, credentials, or internal-only content
- **Draft Ideas**: Incomplete thoughts or preliminary concepts
- **Implementation Logs**: Detailed implementation tracking and progress reports

## Phase 1: Content Creation Workflow

### Step 1: Identify Wiki Content Need
```
Triggers:
- User requests comprehensive documentation
- New system feature needs explanation
- Agent protocols require documentation
- Development workflow needs standardization
- User guide or tutorial requested
```

### Step 2: Create Feature Branch
```bash
# Branch naming convention: {agent-name}/wiki/{descriptive-name}
git checkout dev
git pull origin dev
git checkout -b vibe-coder/wiki/agent-coordination-protocols
```

**Branch Naming Examples:**
- `vibe-coder/wiki/system-architecture-overview`
- `docs-orchestrator/wiki/cross-repo-sync-guide`
- `devops/wiki/branch-protection-protocols`
- `react-dev/wiki/component-development-guide`

### Step 3: Create Staged Content
Place content in the appropriate staging category:

```
agentic-development/wiki/staging/
├── architecture/     # System design and technical architecture
├── agents/          # Agent roles, capabilities, and protocols  
├── workflows/       # Development processes and coordination
├── protocols/       # Standards, safety rules, and compliance
└── guides/          # User documentation and tutorials
```

**File Naming Convention:**
- Use descriptive, hyphenated names: `multi-agent-coordination-protocols.md`
- Include agent identifier prefix: `vibe-coder-orchestration-overview.md`
- Use consistent terminology: `branch-protection-implementation-guide.md`

### Step 4: Content Structure Template

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

### Step 5: Content Quality Standards

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

## Phase 2: Mobile Artifact Processing

### Mobile Content Creation
When creating content on mobile Claude app:

1. **Save Content Locally**: Create markdown files in project directory
2. **Use Special Markers**: Identify mobile-created content with tags
3. **Transfer to Desktop**: Process content through desktop Claude workflow
4. **Apply Standard Formatting**: Convert to proper staging format

#### Mobile Content Markers
```markdown
<!-- MOBILE_ARTIFACT: Created on [Date] via phone Claude app -->
<!-- WIKI_CATEGORY: [architecture/agents/workflows/protocols/guides] -->
<!-- PROCESSING_REQUIRED: Desktop formatting and validation needed -->

# [Content Title]
[Content here...]

<!-- END_MOBILE_ARTIFACT -->
```

### Desktop Processing Workflow
1. **Identify Mobile Artifacts**: Search for mobile markers in project files
2. **Validate Content**: Review for completeness and accuracy  
3. **Format Properly**: Apply standard template and formatting
4. **Categorize Correctly**: Place in appropriate staging directory
5. **Remove Mobile Markers**: Clean up temporary processing tags
6. **Follow Standard PR Process**: Create wiki-ready PR as normal

## Phase 3: Pull Request Creation

### PR Creation Requirements
```bash
# Commit with descriptive message
git add agentic-development/wiki/staging/[category]/[content-file].md
git commit -m "docs: add [descriptive title] to wiki staging

- Comprehensive documentation for [topic]
- Includes examples, troubleshooting, and references
- Ready for wiki publication via vibe coder sync"

# Push and create PR
git push origin [branch-name]
gh pr create --title "Wiki Content: [Descriptive Title]" \
  --body "$(cat <<'EOF'
## Summary
Add comprehensive [topic] documentation to wiki staging.

## Content Overview
- **Category**: [architecture/agents/workflows/protocols/guides]
- **Target Audience**: [developers/agents/users]
- **Scope**: [brief description]

## Quality Checklist
- [ ] Content follows template structure
- [ ] Technical accuracy verified
- [ ] Links and references validated
- [ ] Formatting standards applied
- [ ] Mobile artifacts properly processed (if applicable)

## Wiki Publication
Ready for vibe coder agent review and GitHub wiki synchronization.

🤖 Generated with [Claude Code](https://claude.ai/code)
EOF
)" \
  --label "wiki-ready" \
  --base dev
```

### Required PR Labels
- **`wiki-ready`**: Indicates content ready for wiki synchronization
- **`documentation`**: Standard documentation label
- **`[agent-name]`**: Agent responsible for content creation

### PR Review Process
1. **Self Review**: Validate content completeness and quality
2. **Wiki Category Check**: Confirm appropriate staging directory
3. **Link Validation**: Test all internal and external references
4. **Format Verification**: Ensure consistent formatting and structure
5. **Ready for Sync**: Add `wiki-ready` label when complete

## Phase 4: Coordination with Vibe Coder Agent

### Handoff Process
Once PR is created with `wiki-ready` label:

1. **Automatic Detection**: Vibe coder agent monitors for wiki-ready PRs
2. **Content Review**: Vibe coder validates quality and completeness  
3. **Wiki Synchronization**: Content synced to GitHub wiki repository
4. **Index Update**: Wiki index and organization updated
5. **Staging Cleanup**: Temporary staging files removed from main repo
6. **PR Completion**: PR merged with minimal permanent changes

### Communication Protocol
- **PR Comments**: All coordination via PR comment threads
- **Status Updates**: Vibe coder provides sync status and any issues
- **Quality Issues**: Feedback provided for content improvements
- **Success Confirmation**: Notification when wiki publication complete

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
✅ **Fast Creation**: Streamlined content development process  
✅ **Quality Review**: Effective validation before wiki publication  
✅ **Clean Repository**: Minimal permanent files in main repo  
✅ **Easy Navigation**: Clear organization and findable content  
✅ **Mobile Support**: Effective processing of mobile-created content  

---

**Last Updated**: 2025-08-15  
**Maintained By**: DevOps Agent  
**Version**: 1.0 - Initial wiki workflow implementation  

*These instructions enable Claude Desktop agents to create high-quality wiki content through the established branching and coordination workflow.*