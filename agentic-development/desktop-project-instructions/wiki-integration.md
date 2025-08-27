# Wiki Integration Guide

← [Back to Main](./README.md)

> **💡 Start Wiki Work**: *"Create wiki documentation for [topic]" or "Have vibe-coder work on [topic] wiki documentation"*

## GitHub Wiki Integration

The Tuvens system includes comprehensive wiki integration for publishing documentation to the GitHub wiki while keeping the main repository clean and minimal.

**Wiki Access**: https://github.com/tuvens/tuvens-docs/wiki  
**Workflow Documentation**: `agentic-development/wiki/`

## Special Wiki Workflow

⚠️ **Important**: The GitHub MCP cannot directly access wiki repositories because the GitHub API doesn't have endpoints for wiki-type repos. Therefore, wiki documentation requires a special 3-step workflow:

### Step 1: Standard Agent Session Setup
Use natural language to start a wiki documentation session:

**Natural Language Examples:**
```
"Create wiki documentation for API endpoints"  
"Have vibe-coder document the branching strategy"
"Create comprehensive wiki guide for new developers"
"Document the authentication system in the wiki"
```

**What Happens:**
1. Claude Desktop uses MCP to run `setup-agent-task-desktop.sh`
2. Creates GitHub issue with wiki task details
3. Sets up git worktree with proper branch naming: `vibe-coder/wiki/[descriptive-name]`
4. Launches Claude Code in new iTerm2 window with wiki task prompt

### Step 2: Content Delivery via GitHub MCP
**Claude Desktop's Role:**
1. **Identify the branch** created by the setup script
2. **Use GitHub MCP** to add wiki content files to the branch
3. **Place files** in the `agentic-development/wiki/staging/` directory
4. **Commit files** to the branch so Claude Code can access them

**File Structure:**
```
agentic-development/wiki/staging/
├── [topic]-content.md          # Main wiki content
├── [topic]-metadata.json       # Wiki metadata (category, title, etc.)
└── assets/                     # Any images or files
    └── [topic]-*.png
```

### Step 3: Claude Code Wiki Publication
**Claude Code's Role:**
1. **Check for files** in the staging directory (may need to wait 1-2 minutes)
2. **Read content** from the staging files
3. **Access GitHub wiki** directly (Claude Code can access wikis)
4. **Publish content** to appropriate wiki location
5. **Clean up** staging files from the branch
6. **Update issue** with completion status

**Important**: The Claude Code prompt includes instructions to wait and check again if files aren't immediately present.

## When to Create Wiki Content

✅ **System Architecture**: Design patterns, technical specifications, system overviews  
✅ **Agent Documentation**: Role definitions, capabilities, interaction protocols  
✅ **Development Workflows**: Branching strategies, coordination patterns, best practices  
✅ **User Guides**: Getting started documentation, tutorials, how-to guides  
✅ **Reference Documentation**: API references, configuration guides, technical specs  
✅ **Protocol Standards**: Safety rules, quality standards, compliance procedures  

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
4. **Automatic processing** through the standard 3-step workflow above

## Quality Standards

### Content Requirements
- **Professional Writing**: Clear, concise, well-structured documentation
- **Technical Accuracy**: Validated information with proper references
- **Consistent Formatting**: Following established templates and style guides
- **Complete Information**: Self-contained with necessary context
- **Maintenance Info**: Clear ownership and update procedures

### Review Process
- **Staging Validation**: Content reviewed in staging before publication
- **Claude Code Publication**: Content published to GitHub wiki
- **Category Organization**: Automatic wiki navigation structure updates
- **Link Validation**: Working references and cross-wiki navigation

## Workflow Summary

```
Natural Language Request (Claude Desktop)
    ↓
Agent Session Setup (MCP Script)
    ↓  
Content Delivery (GitHub MCP → Branch)
    ↓
Wiki Publication (Claude Code → GitHub Wiki)
```

## Quick Access

### Wiki Resources
- **Wiki Home**: https://github.com/tuvens/tuvens-docs/wiki
- **Start Wiki Work**: Use natural language in Claude Desktop
- **Agent for Wiki Tasks**: vibe-coder (specialized in documentation)

### Example Complete Workflow
```
1. "Document the API authentication system" → Claude Desktop
2. Claude Desktop: Sets up vibe-coder session + adds content to branch
3. Claude Code: Finds content in staging, publishes to wiki
4. Result: Published wiki documentation
```