# Claude Desktop Instructions for Tuvens Multi-Agent System

**[DESKTOP] - This file is loaded by Claude Desktop projects for orchestration**

## Quick Start

You are orchestrating a multi-agent development system. Each agent has its own specialized responsibilities.

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

### Method 1: Claude Code (Fully Automated)

**When using Claude Code**, use the automatic workflow:

```bash
/start-session [agent-name]
```

This command:
- Analyzes current conversation context
- Creates GitHub issue with task details
- Sets up isolated worktree with branch mapping
- Opens iTerm2 with ready-to-paste prompt (via AppleScript)
- Maintains awareness of repository locations

**Full Implementation Details**: See [start-session integration guide](../workflows/start-session-integration.md)

### Method 2: Claude Desktop with iTerm MCP (Semi-Automated)

**When using Claude Desktop**, you'll coordinate the workflow:

#### Step 1: User Request
When a user says something like:
```
"Start a vibe-coder session to fix authentication issues"
```

#### Step 2: Claude Desktop Response
```
I'll set up a vibe-coder session for fixing authentication issues.

1. First, let me prepare the task setup
2. Then I'll open an iTerm window using the MCP tool
3. Finally, I'll guide you through starting Claude Code
```

#### Step 3: Claude Desktop Actions
1. **Prepare the task** (internally run or reference):
   ```bash
   ./agentic-development/scripts/desktop-agent-task.sh vibe-coder "Fix authentication" "Debug and fix OAuth flow issues"
   ```

2. **Use iTerm MCP** to open a terminal window

3. **In the opened terminal**, instruct to run:
   ```bash
   bash "/path/to/generated/desktop-setup-vibe-coder-[timestamp].sh"
   ```

4. **Guide the user**:
   ```
   Now in the terminal:
   1. Type: claude
   2. Copy and paste the prompt from claude-prompt.txt
   3. Begin your agent work
   ```

**Desktop Workflow Details**: See [desktop-iterm-workflow.md](../docs/desktop-iterm-workflow.md)

### Method 3: Manual Control

For specific control over the task:
```bash
/create-issue [your-agent] [target-agent] "[Task Title]" [repository]
```

Then start Claude Code in the appropriate repository.

## Workflow Comparison

| Aspect | Claude Code | Claude Desktop |
|--------|-------------|----------------|
| **Command** | `/start-session agent-name` | Natural language request |
| **Automation** | Fully automated | Semi-automated with MCP |
| **Terminal** | AppleScript opens iTerm | iTerm MCP opens terminal |
| **Setup** | Automatic worktree + prompt | Run setup script manually |
| **User Effort** | Single command | Follow guided steps |
| **GitHub Issue** | Automatic | Automatic |
| **Worktree** | Automatic | Created by setup script |

## Worktree Structure

Both workflows create dedicated worktrees matching branch names:
```
~/Code/Tuvens/tuvens-client/worktrees/svelte-dev-feature-auth-ui/
~/Code/Tuvens/tuvens-api/worktrees/node-dev-fix-validation/
~/Code/Tuvens/hi.events/worktrees/laravel-dev-update-cors/
```

This enables parallel work and easy cleanup when branches are merged.

## Supporting Documentation

- **Branching Strategy**: See [Tuvens branching strategy](../workflows/tuvens-branching-strategy.md)
- **Central Tracking**: See [central branch tracking system](../workflows/central-branch-tracking.md)
- **Claude Code Workflow**: See [start-session integration](../workflows/start-session-integration.md)
- **Claude Desktop Workflow**: See [desktop iTerm workflow](../docs/desktop-iterm-workflow.md)

## Wiki Content Workflow

### For Claude Desktop

#### Writing Wiki Content
Claude Desktop can create and refine wiki content directly:

1. **Create high-quality content** in conversation
2. **Stage content locally** in appropriate category:
   ```
   agentic-development/wiki/staging/[category]/[content-name].md
   ```
3. **Follow wiki workflow** for review and publication

#### Mobile Artifact Collection
When using mobile Claude app:

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
- ✅ Use appropriate method based on your environment (Claude Code vs Desktop)
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

## Quick Commands Reference

### Claude Code Commands
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

### Claude Desktop Workflow
```bash
# Step 1: Run adapter script (Claude Desktop runs this)
./agentic-development/scripts/desktop-agent-task.sh [agent] "[title]" "[description]"

# Step 2: Use iTerm MCP to open terminal
# (Claude Desktop uses MCP tool)

# Step 3: In terminal, run setup script
bash /path/to/desktop-setup-[agent]-[timestamp].sh

# Step 4: Start Claude
claude
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
- **System architecture**: Start vibe-coder session for analysis
- **Custom prompts**: Load agent-terminal-prompts.md for task-specific templates
- **Claude Code vs Desktop**: Choose workflow based on your environment
