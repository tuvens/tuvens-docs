# Wiki Integration Guide

← [Back to Main](./README.md)

> **💡 Start Wiki Work**: *"Create wiki documentation for [topic]" or "Have vibe-coder work on [topic] wiki documentation"*

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

## Direct Wiki Creation Process

### Using Claude Desktop Natural Language
Simply tell Claude Desktop what wiki content you need:

**Natural Language Examples:**
```
"Create wiki documentation for API endpoints"
"Have vibe-coder document the branching strategy"
"Create comprehensive wiki guide for new developers"
"Document the authentication system in the wiki"
```

**Claude Desktop Response:**
```
I understand you want wiki documentation for [topic]. 
Should I set up a Claude Code session with:
- Agent: vibe-coder
- Task: Create Wiki Documentation for [topic]
- Context: [details]

Would you like me to proceed? [Yes/No]
```

### Automated Claude Code Workflow
When you confirm, Claude Desktop automatically:

1. **Creates GitHub Issue** - Documents the wiki task with proper labels
2. **Sets Up Git Worktree** - Isolated branch with proper naming: `vibe-coder/wiki/[descriptive-name]`
3. **Launches Claude Code** - Pre-loaded with context and ready to create content
4. **Direct Wiki Publication** - Content is created directly in GitHub wiki format
5. **Pull Request Creation** - Minimal changes to main repository, wiki content published directly

## Wiki Content Categories

Wiki content is organized into these main categories:

### 📖 Guides
- Getting started for new developers
- User documentation and tutorials
- How-to guides for human users
- Troubleshooting and error recovery guides

### 🏗️ Architecture
- High-level system design (WHY decisions were made)
- Architectural decision rationale
- System design philosophy
- Cross-repository integration reasoning

### 📋 Protocols
- Deep protocol philosophy and design rationale
- Protocol decision reasoning (not daily procedures)
- Standards background and justification
- Compliance philosophy and principles

### 📚 Reference
- API documentation and technical specifications
- Configuration guides and command references
- Agent capabilities and interaction protocols
- Historical implementation records

## Mobile Content Creation

### Creating Wiki Content on Mobile
When using Claude app on phone:
1. **Draft content** using natural language conversation
2. **Use desktop Claude Desktop** to convert drafts to wiki format
3. **Say**: *"Convert this mobile draft to wiki documentation for [topic]"*
4. **Automatic processing** through the standard Claude Code workflow

## Quality Standards

### Content Requirements
- **Professional Writing**: Clear, concise, well-structured documentation
- **Technical Accuracy**: Validated information with proper references
- **Consistent Formatting**: Following established templates and style guides
- **Complete Information**: Self-contained with necessary context
- **Maintenance Info**: Clear ownership and update procedures

### Review Process
- **Automated Quality Check**: Built-in validation during Claude Code session
- **Direct Publication**: Content published immediately to GitHub wiki
- **Category Organization**: Automatic wiki navigation structure updates
- **Link Validation**: Working references and cross-wiki navigation

## Quick Access

### Wiki Resources
- **Wiki Home**: https://github.com/tuvens/tuvens-docs/wiki
- **Start Wiki Work**: Use natural language in Claude Desktop
- **Agent for Wiki Tasks**: vibe-coder (specialized in documentation)

### Example Requests
```
Natural Language → Claude Desktop → Claude Code → Published Wiki

"Document the API authentication system" → Automatic wiki creation
"Create troubleshooting guide for deployment" → Direct wiki publication  
"Explain the agent coordination patterns" → Comprehensive wiki documentation
```