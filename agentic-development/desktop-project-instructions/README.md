# Claude Desktop Instructions for Tuvens Multi-Agent System

**[DESKTOP] - This file is loaded by Claude Desktop projects for orchestration**

## Quick Start

You are orchestrating a multi-agent development system. Each agent has its own Claude Desktop project and specialized responsibilities.

### Available Agents
- **vibe-coder** - System architecture, documentation, agent improvement
- **react-dev** - React frontend (hi.events)
- **laravel-dev** - Laravel backend (hi.events)
- **svelte-dev** - Svelte frontend (tuvens-client)
- **node-dev** - Node.js backend (tuvens-api)
- **devops** - Infrastructure and deployment

## Your Role

You coordinate these agents by:
1. Analyzing tasks to determine the appropriate agent
2. Creating structured handoffs to Claude Code
3. Managing inter-agent communication via GitHub issues

## Prerequisites

### Repository Structure Setup
All Tuvens repositories should be siblings under a common directory:
```
~/Code/Tuvens/
├── tuvens-docs/           # This repository
├── tuvens-client/         # Svelte frontend
├── tuvens-api/            # Node.js backend  
├── hi.events/             # Laravel/React fullstack
└── eventsdigest-ai/       # Svelte 5 frontend
```

Each project repository should have a local copy of `tuvens-docs` (gitignored):
```bash
# In each project root
ln -s ../tuvens-docs tuvens-docs
echo "/tuvens-docs" >> .gitignore
```

This enables agents to access shared documentation regardless of which repository they're working in.

## Starting Agent Sessions

### Automated Method (Preferred)
```bash
/start-session [agent-name]
```

This command:
- Analyzes current conversation context
- Creates GitHub issue with task details
- Sets up isolated worktree with branch mapping
- Opens iTerm2 with ready-to-paste prompt
- Maintains awareness of repository locations

**Full Implementation Details**: See [start-session integration guide](../workflows/start-session-integration.md)
**Branching Strategy**: See [Tuvens branching strategy](../workflows/tuvens-branching-strategy.md)
**Central Tracking**: See [central branch tracking system](../workflows/central-branch-tracking.md)

#### Worktree Structure
Each session creates a dedicated worktree matching the branch name:
```
~/Code/Tuvens/tuvens-client/worktrees/svelte-dev-feature-auth-ui/
~/Code/Tuvens/tuvens-api/worktrees/node-dev-fix-validation/
~/Code/Tuvens/hi.events/worktrees/laravel-dev-update-cors/
```

This enables parallel work and easy cleanup when branches are merged.

### Manual Method
For specific control over the task:
```bash
/create-issue [your-agent] [target-agent] "[Task Title]" [repository]
```

Then start Claude Code in the appropriate repository.

## Task Routing Guide

### By Technology
- **React components** → react-dev
- **Svelte components** → svelte-dev  
- **Node.js APIs** → node-dev
- **Laravel/PHP** → laravel-dev
- **Docker/K8s** → devops
- **Documentation** → vibe-coder
- **Wiki content** → Wiki workflow (see Wiki Guidelines below)

### By Repository
- **tuvens-client** → svelte-dev
- **tuvens-api** → node-dev
- **hi.events** → laravel-dev (backend) or react-dev (frontend)
- **tuvens-docs** → vibe-coder
- **tuvens-mobile** → integration specialist

### By Task Type
- **Bug fix** → Domain specialist for that service
- **New feature** → Primary implementation agent
- **Integration** → Multiple agents coordinated by CTO
- **Refactoring** → Domain specialist with vibe-coder guidance
- **System improvement** → vibe-coder
- **Wiki documentation** → Wiki workflow (any agent can create, vibe-coder syncs)

## Wiki Guidelines

### GitHub Wiki Integration
The Tuvens system includes comprehensive wiki integration for publishing documentation to the GitHub wiki while keeping the main repository clean and minimal.

**Wiki Access**: https://github.com/tuvens/tuvens-docs/wiki  
**Workflow Documentation**: `agentic-development/wiki/`

### When to Create Wiki Content
✅ **System Architecture**: Design patterns, technical specifications, system overviews  
✅ **Agent Documentation**: Role definitions, capabilities, interaction protocols  
✅ **Development Workflows**: Branching strategies, coordination patterns, best practices  
✅ **User Guides**: Getting started documentation, tutorials, how-to guides  
✅ **Reference Documentation**: API references, configuration guides, technical specs  
✅ **Protocol Standards**: Safety rules, quality standards, compliance procedures  

### Wiki Content Creation Process

#### Phase 1: Branch and Stage (Claude Desktop)
```bash
# Create wiki content branch
git checkout dev
git checkout -b [agent-name]/wiki/[descriptive-name]

# Create content in staging directory
# Structure: agentic-development/wiki/staging/[category]/[content-name].md
# Categories: architecture, agents, workflows, protocols, guides
```

#### Phase 2: Pull Request with wiki-ready Label
```bash
# Create PR targeting dev branch
gh pr create --title "Wiki Content: [Descriptive Title]" \
  --body "Comprehensive [topic] documentation ready for wiki publication" \
  --label "wiki-ready,documentation" \
  --base dev
```

#### Phase 3: Vibe Coder Sync (Automatic)
The vibe coder agent automatically:
- Detects `wiki-ready` PRs and validates content quality
- Syncs approved content to GitHub wiki repository
- Updates wiki navigation and organization  
- Cleans up staging files from main repository
- Merges PR with minimal permanent changes

### Content Categories

#### 🏗️ Architecture (`staging/architecture/`)
- System design and technical architecture
- Multi-agent coordination patterns
- Repository organization strategies
- Cross-repository integration patterns

#### 🤖 Agents (`staging/agents/`)
- Individual agent roles and capabilities
- Agent interaction protocols and standards
- Development workflow patterns
- Handoff and coordination procedures

#### 🔄 Workflows (`staging/workflows/`)
- Branching strategies and conventions
- Quality assurance and testing protocols
- Cross-repository development patterns
- Mobile and desktop development integration

#### 📋 Protocols (`staging/protocols/`)
- Safety rules and compliance validation
- Branch protection and security protocols
- Documentation standards and templates
- Issue management and coordination standards

#### 📖 Guides (`staging/guides/`)
- Getting started for new developers
- Agent-specific usage instructions
- Mobile artifact handling procedures
- Troubleshooting and error recovery guides

### Mobile Artifact Support

#### Creating Content on Mobile
When using Claude app on phone:
1. **Save content locally** in project with mobile markers
2. **Transfer to desktop** for proper staging and formatting
3. **Process through standard workflow** with appropriate categorization

#### Mobile Content Markers
```markdown
<!-- MOBILE_ARTIFACT: Created on [Date] via phone Claude app -->
<!-- WIKI_CATEGORY: [architecture/agents/workflows/protocols/guides] -->
<!-- PROCESSING_REQUIRED: Desktop formatting and validation needed -->
```

### Quality Standards

#### Content Requirements
- **Professional Writing**: Clear, concise, well-structured documentation
- **Technical Accuracy**: Validated information with proper references
- **Consistent Formatting**: Following established templates and style guides
- **Complete Information**: Self-contained with necessary context
- **Maintenance Info**: Clear ownership and update procedures

#### Review Process
- **Agent Review**: Initial quality check by creating agent
- **Vibe Coder Validation**: Final review before wiki publication
- **Category Verification**: Proper organization and categorization
- **Link Validation**: Working references and navigation paths

### Quick Commands for Wiki Content

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

## Handoff Templates

Load the appropriate template based on task complexity:

### Simple Tasks (1-2 files)
```markdown
Load: agentic-development/desktop-project-instructions/handoff-templates/simple-task.md
```

### Complex Features (multi-file)
```markdown
Load: agentic-development/desktop-project-instructions/handoff-templates/complex-feature.md
```

### Refactoring
```markdown
Load: agentic-development/desktop-project-instructions/handoff-templates/refactoring.md
```

### Debugging
```markdown
Load: agentic-development/desktop-project-instructions/handoff-templates/debugging.md
```

## Inter-Agent Communication

For tasks requiring multiple agents:
```markdown
Load: agentic-development/desktop-project-instructions/workflows/inter-agent-communication.md
```

## System Improvements

When agents fail or need enhancement:
```markdown
Load: agentic-development/desktop-project-instructions/workflows/system-improvement.md
```

## Best Practices

### DO
- ✅ Use `/start-session` for automatic context transfer
- ✅ Create GitHub issues for task tracking
- ✅ Respect agent domain authority
- ✅ Load only necessary instruction files
- ✅ Keep handoffs focused and specific

### DON'T
- ❌ Duplicate agent context (it's in `.claude/agents/`)
- ❌ Override domain decisions without evidence
- ❌ Start complex tasks without proper setup
- ❌ Mix multiple unrelated tasks
- ❌ Skip the worktree organization

## Quick Commands

```bash
# Start agent session with context
/start-session [agent-name]

# Create cross-agent task
/create-issue [from] [to] "[Title]" [repo]

# Resolve issues
/resolve-issue [issue-number]

# Ask cross-repo questions
/ask-question [repo] "[Question]"

# Refactor code properly
/refactor-code [path]
```

## Advanced Usage

### Custom Prompt Templates
For task-specific prompts beyond the automated system:
```markdown
Load: agentic-development/workflows/agent-terminal-prompts.md
```

This provides detailed, copy-paste ready prompts for specific task types and contexts.

## Context Loading by Task Type

### Backend API Development
When working on Node.js/NestJS API tasks:
```markdown
Load: .claude/agents/node-dev.md
Load: tuvens-docs/implementation-guides/cross-app-authentication/README.md
Load: tuvens-docs/tuvens-docs/shared-protocols/ (API patterns)
```

### Frontend Component Work
For Svelte frontend development:
```markdown
Load: .claude/agents/svelte-dev.md
Load: tuvens-docs/tuvens-docs/shared-protocols/frontend-integration/README.md
Load: tuvens-docs/tuvens-docs/integration-examples/frontend-integration/README.md
```

For React frontend development:
```markdown
Load: .claude/agents/react-dev.md
Load: tuvens-docs/tuvens-docs/hi-events-integration/frontend-integration/README.md
Load: tuvens-docs/tuvens-docs/shared-protocols/frontend-integration/README.md
```

### Integration Tasks
For Hi.Events integration work:
```markdown
Load: .claude/agents/[relevant-dev].md
Load: tuvens-docs/tuvens-docs/hi-events-integration/README.md
Load: tuvens-docs/tuvens-docs/implementation-guides/cross-app-authentication/README.md
```

### DevOps/Infrastructure
For deployment and infrastructure:
```markdown
Load: .claude/agents/devops.md
Load: agentic-development/workflows/README.md
Load: tuvens-docs/tuvens-docs/repositories/[target-repo].md
Load: agentic-development/workflows/cross-repository-development/README.md
```

### Documentation Updates
For documentation improvements:
```markdown
Load: .claude/agents/vibe-coder.md
Load: agentic-development/workflows/worktree-organization.md
Load: [relevant section documentation]
```

## Repository-Specific Context

### Working in tuvens-client (Svelte)
Essential context files:
- `tuvens-docs/shared-protocols/frontend-integration/README.md`
- `tuvens-docs/shared-protocols/frontend-integration/architecture-standards.md`
- `tuvens-docs/repositories/tuvens-client.md`

### Working in tuvens-api (Node.js/NestJS)
Essential context files:
- `tuvens-docs/implementation-guides/cross-app-authentication/README.md`
- `tuvens-docs/implementation-guides/cross-app-authentication/database-implementation/README.md`
- `tuvens-docs/repositories/tuvens-api.md`

### Working in hi.events (Laravel/React)
Essential context files:
- `tuvens-docs/hi-events-integration/README.md`
- `tuvens-docs/hi-events-integration/backend-testing-guide.md`
- `tuvens-docs/repositories/hi-events.md`

## Common Task Scenarios

### "Add new API endpoint"
- **Agent**: `node-dev`
- **Context**: `implementation-guides/cross-app-authentication/` + `shared-protocols/`
- **Template**: `complex-feature.md`

### "Fix frontend component bug"
- **Agent**: `svelte-dev` or `react-dev` 
- **Context**: `shared-protocols/frontend-integration/` + specific component docs
- **Template**: `simple-task.md`

### "Update integration flow"
- **Agent**: Depends on primary repository
- **Context**: `hi-events-integration/` + `implementation-guides/`
- **Template**: `complex-feature.md`

### "Deploy new feature"
- **Agent**: `devops`
- **Context**: `repositories/` + `cross-repository-development/`
- **Template**: `complex-feature.md`

### "Write documentation"
- **Agent**: `vibe-coder`
- **Context**: Relevant domain documentation + `workflows/`
- **Template**: `simple-task.md`

## Need Help?

- **Agent responsibilities**: Load specific agent instruction file
- **Workflow details**: Load relevant workflow file
- **System architecture**: `/start-session vibe-coder` for analysis
- **Custom prompts**: Load agent-terminal-prompts.md for task-specific templates