# System Improvement Workflow

## When to Trigger

- Agent fails to complete task
- Workflow automation needed
- Documentation gaps identified
- Cross-agent coordination issues
- Performance bottlenecks

## Analysis Phase

### 1. Identify Failure Point
```markdown
What failed:
- [ ] Agent misunderstood task
- [ ] Insufficient context
- [ ] Missing workflow
- [ ] Tool limitation
- [ ] Coordination breakdown
```

### 2. Document Evidence
- Copy error messages
- Note missing information
- Identify confusion points
- Track repeated issues

### 3. Determine Solution Type
- **Agent instruction update** → Modify `.claude/agents/`
- **Workflow creation** → New automation script
- **Documentation fix** → Update guides
- **Tool integration** → Add new capabilities

## Implementation Methods

### Method 1: Claude Code (Automated)

For Claude Code users:
```bash
/start-session vibe-coder
```

This will:
- Create improvement issue
- Set up vibe-coder worktree
- Load relevant context
- Start improvement session

### Method 2: Claude Desktop (Semi-Automated)

For Claude Desktop users:

1. **Request improvement session**:
   ```
   "Start vibe-coder session to fix [specific issue]"
   ```

2. **Claude Desktop will**:
   - Prepare task with `desktop-agent-task.sh`
   - Open iTerm via MCP
   - Guide through setup
   - Start improvement workflow

### Method 3: Manual Improvement

```markdown
Load: .claude/agents/vibe-coder.md
Load: [relevant failure context]

Improvement needed: [specific issue]
Evidence: [what went wrong]
Proposed solution: [your hypothesis]

Create a fix that prevents this issue from recurring.
```

## Improvement Templates

### Agent Instruction Fix
```markdown
## Problem
Agent [name] failed to [task] because [reason]

## Root Cause
- Missing context about [topic]
- Unclear responsibility for [area]
- Ambiguous workflow step

## Solution
Update `.claude/agents/[agent].md` to:
1. Clarify [specific section]
2. Add example for [scenario]
3. Define boundary with [other agent]
```

### Workflow Automation
```markdown
## Manual Process to Automate
1. [Current step 1]
2. [Current step 2]
3. [Current step 3]

## Automation Design
- Script name: [descriptive-name.sh]
- Input: [what it needs]
- Output: [what it produces]
- Integration: [how it fits]
```

### Documentation Enhancement
```markdown
## Gap Identified
- Topic: [what's missing]
- Users affected: [who needs this]
- Current confusion: [what happens now]

## Documentation Plan
- Location: [where to add]
- Format: [guide/reference/tutorial]
- Examples needed: [specific scenarios]
```

## Testing Improvements

### Validation Checklist
- [ ] Problem scenario now works
- [ ] No regression in other areas
- [ ] Documentation updated
- [ ] Other agents aware of change
- [ ] Improvement logged

### Rollout Process
1. Test in isolated worktree
2. Document the change
3. Create PR with evidence
4. Notify affected agents
5. Monitor for issues

## Common Improvements

### Cross-Agent Coordination
- Add clear handoff points
- Define communication protocol
- Create shared context files
- Establish ownership boundaries

### Context Preservation
- Enhance GitHub issue templates
- Improve session handoff structure
- Add context validation checks
- Create knowledge artifacts

### Automation Opportunities
- Repetitive setup tasks
- Multi-step workflows
- Cross-repository operations
- Validation processes

## Success Metrics

- Issue doesn't recur
- Workflow time reduced
- Fewer clarification requests
- Improved task completion rate
- Better agent autonomy

## References

- Agent identities: `.claude/agents/`
- Workflows: `agentic-development/workflows/`
- Scripts: `agentic-development/scripts/`
- Branch tracking: `agentic-development/branch-tracking/`
- Claude Code workflow: [start-session integration](../workflows/start-session-integration.md)
- Claude Desktop workflow: [desktop iTerm workflow](../docs/desktop-iterm-workflow.md)