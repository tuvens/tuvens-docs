# Starting Vibe Coder Sessions

**[DESKTOP] - Loaded by Claude Desktop when starting vibe-coder sessions**

## When to Use Vibe Coder
- System architecture improvements
- Agent instruction refinement
- Documentation organization
- Workflow automation development
- Multi-agent coordination failures

## Starting a Claude Code Session

### For System Improvement Tasks

```bash
/start-session vibe-coder
```

The command will analyze the current conversation and create:
1. GitHub issue with task details
2. Isolated worktree: `tuvens-docs/vibe-coder/[branch-name]`
3. Prompt file with complete context

### Manual Session Start

If starting Claude Code manually, use this prompt structure:

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

## Handoff Checklist

Before starting Claude Code session:
- [ ] Clear task description identified
- [ ] Appropriate worktree branch name determined
- [ ] Relevant context files identified
- [ ] Success criteria defined
- [ ] GitHub issue number (if using /start-session)