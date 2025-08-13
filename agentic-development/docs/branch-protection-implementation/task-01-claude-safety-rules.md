# Task 1: Adapt CLAUDE.md Safety Rules

## Task Overview

**Agent**: docs-orchestrator  
**Worktree**: `docs-orchestrator/task-01-claude-safety-rules`  
**Branch**: `docs/task-01-claude-safety-rules`  
**Estimated Time**: 1 focused session  

## Objective

Adapt the comprehensive Claude Code safety rules from event-harvester's CLAUDE.md to create tuvens-docs specific safety infrastructure that enforces proper branching workflows and prevents breaking changes.

## Current State Analysis

### Event-Harvester CLAUDE.md Has:
- 🚨 CRITICAL: Claude Code Safety Rules section
- Branching safety with protected branch enforcement
- 5-branch strategy documentation (main ← staging ← test ← develop ← feature/*)
- Mandatory branch naming conventions
- Pull request target branch rules
- Emergency branch recovery procedures
- Testing protocols with mandatory requirements
- Custom commands (/resolve-issue)
- Required reading order for agents

### tuvens-docs Current State:
- Basic CLAUDE.md exists but minimal safety rules
- No branch protection enforcement
- No mandatory testing protocols
- No custom commands
- No emergency recovery procedures

## Deliverables

### Primary Deliverable:
Enhanced CLAUDE.md with comprehensive safety rules adapted for tuvens-docs

### Specific Sections to Add:

1. **🚨 CRITICAL: Claude Code Safety Rules**
   - Protected branches (main, dev, test, stage)
   - Mandatory branch creation before changes
   - Pull request target branch rules

2. **5-Branch Strategy Documentation**
   - Adapted for tuvens-docs branch structure
   - Clear merge flow: main ← stage ← test ← dev ← feature/*
   - Integration with existing agent workflows

3. **Mandatory Branch Naming Conventions**
   - vibe-coder/* (for documentation work)
   - docs-orchestrator/* (for structural changes)
   - integration-specialist/* (for cross-repo work)
   - mobile-dev/* (for mobile documentation)
   - devops/* (for infrastructure)

4. **Testing Protocol Requirements**
   - Documentation validation requirements
   - Link checking for internal references
   - Agent workflow validation

5. **Custom Commands Integration**
   - Integration with existing /start-session command
   - Potential /resolve-issue adaptation

6. **Required Reading Order**
   - Integration with existing agent documentation
   - Priority order for safety documents

## Success Criteria

- [ ] CLAUDE.md contains comprehensive safety rules
- [ ] Branch protection rules clearly documented
- [ ] Testing protocols defined and mandatory
- [ ] Custom commands documented
- [ ] Emergency recovery procedures included
- [ ] Integration with existing agent workflows maintained
- [ ] No breaking changes to current documentation structure

## Implementation Notes

### Key Adaptations Needed:

1. **Branch Structure**: 
   - event-harvester uses main/staging/test/develop
   - tuvens-docs uses main/stage/test/dev
   - Need to adapt documentation accordingly

2. **Agent Integration**:
   - Must work with existing agent-specific workflows
   - Should not conflict with worktree organization patterns

3. **Repository-Specific Rules**:
   - Documentation repository vs. code repository
   - Different testing requirements (docs vs. code)
   - Integration with notify-repositories.yml workflow

### Files to Reference:
- `/Users/ciarancarroll/Code/Tuvens/event-harvester/CLAUDE.md` (source)
- Current tuvens-docs CLAUDE.md (to preserve existing structure)
- `agentic-development/workflows/branching-strategy.md` (for consistency)
- `.claude/commands/start-session.md` (for command integration)

### Validation Requirements:
- Must not conflict with existing workflows
- Should enhance rather than replace current documentation
- Must maintain backward compatibility with existing agent sessions

## Risks and Mitigation

### Risks:
1. **Breaking Existing Workflows**: Could interfere with current agent operations
2. **Over-Complexity**: Making safety rules too restrictive for documentation work
3. **Inconsistency**: Creating conflicts with existing branching documentation

### Mitigation:
1. **Careful Integration**: Build on existing patterns rather than replacing
2. **Documentation-Appropriate**: Adapt rules for documentation repository context
3. **Consistency Checks**: Cross-reference with all existing workflow documentation

## Next Steps After Completion

1. Validate CLAUDE.md changes don't break existing patterns
2. Test with a simple agent workflow
3. Get user approval before committing changes
4. Move to Task 2: Branch Protection Workflow implementation

## Session Startup Command

```bash
cd /Users/ciarancarroll/Code/Tuvens/tuvens-docs
/start-session docs-orchestrator
```

**Task Description for Session**: "Adapt comprehensive Claude Code safety rules from event-harvester repository to tuvens-docs, creating enhanced CLAUDE.md with branch protection enforcement and testing protocols while maintaining compatibility with existing agent workflows."