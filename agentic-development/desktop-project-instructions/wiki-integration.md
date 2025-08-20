# Wiki Integration Guide

← [Back to Main](./README.md)

## GitHub Wiki Integration

The Tuvens system includes comprehensive wiki integration for publishing documentation to the GitHub wiki while keeping the main repository clean and minimal.

**Wiki Access**: https://github.com/tuvens/tuvens-docs/wiki  
**Workflow Documentation**: `agentic-development/wiki/`

## When to Create Wiki Content

✅ **System Architecture**: Design patterns, technical specifications, system overviews  
✅ **Agent Documentation**: Role definitions, capabilities, interaction protocols  
✅ **Development Workflows**: Branching strategies, coordination patterns, best practices  
✅ **User Guides**: Getting started documentation, tutorials, how-to guides  
✅ **Reference Documentation**: API references, configuration guides, technical specs  
✅ **Protocol Standards**: Safety rules, quality standards, compliance procedures  

## Wiki Content Creation Process

### Phase 1: Branch and Stage (Claude Desktop)
```bash
# Create wiki content branch
git checkout dev
git checkout -b [agent-name]/wiki/[descriptive-name]

# Create content in staging directory
# Structure: agentic-development/wiki/staging/[category]/[content-name].md
# Categories: guides, drafts, archives, architecture, protocols
```

### Phase 2: Pull Request with wiki-ready Label
```bash
# Create PR targeting dev branch
gh pr create --title "Wiki Content: [Descriptive Title]" \
  --body "Comprehensive [topic] documentation ready for wiki publication" \
  --label "wiki-ready,documentation,[agent-name]" \
  --base dev
```

### Phase 3: Vibe Coder Sync (Automatic)
The vibe coder agent automatically:
- Detects `wiki-ready` PRs and validates content quality
- Syncs approved content to GitHub wiki repository
- Updates wiki navigation and organization  
- Cleans up staging files from main repository
- Merges PR with minimal permanent changes

## Content Categories

### 📖 Guides (`staging/guides/`)
- Getting started for new developers
- User documentation and tutorials
- How-to guides for human users
- Troubleshooting and error recovery guides

### 💡 Drafts (`staging/drafts/`)
- Brainstorming and preliminary concepts
- Ideas that evolve into permanent documentation
- Initial concept formulation
- Collaborative development content

### 📚 Archives (`staging/archives/`)
- Historical implementation logs
- Project evolution records
- Completed project documentation
- Content no longer actively needed by agents

### 🏗️ Architecture (`staging/architecture/`)
- High-level system design (WHY decisions were made)
- Architectural decision rationale
- System design philosophy
- Cross-repository integration reasoning

### 📋 Protocols (`staging/protocols/`)
- Deep protocol philosophy and design rationale
- Protocol decision reasoning (not daily procedures)
- Standards background and justification
- Compliance philosophy and principles

## Mobile Artifact Support

### Creating Content on Mobile
When using Claude app on phone:
1. **Save content locally** in project with mobile markers
2. **Transfer to desktop** for proper staging and formatting
3. **Process through standard workflow** with appropriate categorization

### Mobile Content Markers
```markdown
<!-- MOBILE_ARTIFACT: Created on [Date] via phone Claude app -->
<!-- WIKI_CATEGORY: [architecture/agents/workflows/protocols/guides] -->
<!-- PROCESSING_REQUIRED: Desktop formatting and validation needed -->
```

## Quality Standards

### Content Requirements
- **Professional Writing**: Clear, concise, well-structured documentation
- **Technical Accuracy**: Validated information with proper references
- **Consistent Formatting**: Following established templates and style guides
- **Complete Information**: Self-contained with necessary context
- **Maintenance Info**: Clear ownership and update procedures

### Review Process
- **Agent Review**: Initial quality check by creating agent
- **Vibe Coder Validation**: Final review before wiki publication
- **Category Verification**: Proper organization and categorization
- **Link Validation**: Working references and navigation paths

## Quick Commands for Wiki Content

```bash
# Check wiki workflow status
ls -la agentic-development/wiki/staging/

# Review wiki instructions
cat agentic-development/wiki/instructions.md

# Check current wiki content
open https://github.com/tuvens/tuvens-docs/wiki

# Monitor wiki-ready PRs
gh pr list --label "wiki-ready"
```