# Starting Vibe Coder Sessions

**[DESKTOP] - Loaded by Claude Desktop when starting vibe-coder sessions**

## When to Use Vibe Coder
- System architecture improvements
- Agent instruction refinement
- Documentation organization
- Workflow automation development
- Multi-agent coordination failures

## Starting a Session

### Method 1: From Claude Code

```bash
/start-session vibe-coder
```

This command will:
1. Analyze the current conversation
2. Create GitHub issue with task details
3. Set up isolated worktree: `tuvens-docs/vibe-coder/[branch-name]`
4. Generate prompt file with complete context

### Method 2: From Claude Desktop

When you request a vibe-coder session, Claude Desktop will:

1. **Prepare the task** using the desktop adapter script
2. **Open iTerm** via MCP tool
3. **Guide you** through running the setup script
4. **Start Claude Code** with the prepared context

Example request:
```
"Start a vibe-coder session to improve agent coordination"
```

### Method 3: Manual Session Start

For direct Claude Code startup:

```markdown
Load: .claude/agents/vibe-coder.md

Task: [Specific improvement needed]
Context: [What failed or needs improvement]
Repository: tuvens-docs
Worktree: tuvens-docs/vibe-coder/[descriptive-branch-name]

Start by analyzing the current state and creating an improvement plan.
```

## Task Types and Context Loading

### Agent Improvement Task
```markdown
Load: .claude/agents/vibe-coder.md
Load: .claude/agents/[agent-to-improve].md

Analyze why [agent-name] failed at [specific task] and improve its instructions.
```

### Workflow Automation Task
```markdown
Load: .claude/agents/vibe-coder.md
Load: agentic-development/workflows/worktree-organization.md

Create automation script for [specific workflow].
```

### Documentation Organization Task
```markdown
Load: .claude/agents/vibe-coder.md
Load: agentic-development/README.md

Reorganize [specific documentation area] for better clarity.
```

## Key Context Files

Always available in vibe-coder sessions:
- `.claude/agents/vibe-coder.md` - Agent identity and capabilities
- `.claude/agents/` - All agent identity files
- `agentic-development/workflows/` - Coordination patterns
- `agentic-development/docs/desktop-iterm-workflow.md` - Claude Desktop workflow

## Handoff Checklist

Before starting any session:
- [ ] Clear task description identified
- [ ] Appropriate worktree branch name determined
- [ ] Relevant context files identified
- [ ] Success criteria defined
- [ ] GitHub issue number (if automated)

## Workflow References

- **Claude Code**: See [start-session integration](../../workflows/start-session-integration.md)
- **Claude Desktop**: See [desktop iTerm workflow](../../docs/desktop-iterm-workflow.md)