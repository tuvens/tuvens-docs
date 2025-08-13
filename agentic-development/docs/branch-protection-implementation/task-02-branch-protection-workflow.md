# Task 2: Create Branch Protection Workflow

## Task Overview

**Agent**: devops  
**Worktree**: `devops/task-02-branch-protection-workflow`  
**Branch**: `devops/task-02-branch-protection-workflow`  
**Estimated Time**: 1-2 focused sessions  

## Objective

Create a GitHub Actions workflow that validates branch protection rules, enforces safety infrastructure, and prevents breaking changes to tuvens-docs, adapted from the proven event-harvester branch-protection.yml workflow.

## Current State Analysis

### Event-Harvester branch-protection.yml Features:
- Validates Claude Code safety infrastructure
- Checks for essential files (.claude/workflow.md, CLAUDE.md safety sections)
- Enforces branch naming compliance
- Validates 5-branch strategy documentation
- Checks environment detection comments
- Provides clear error messages and failure notifications

### tuvens-docs Current Workflows:
- `notify-repositories.yml` - cross-repo notifications (DO NOT MODIFY)
- `vibe-coder-maintenance.yml` - maintenance checks (DO NOT MODIFY)
- No branch protection validation currently

## Deliverables

### Primary Deliverable:
`.github/workflows/branch-protection.yml` adapted for tuvens-docs

### Key Components to Adapt:

1. **Safety Infrastructure Validation**
   - Check for enhanced CLAUDE.md (from Task 1)
   - Validate agent documentation exists
   - Ensure branching strategy documentation is current

2. **Branch Naming Compliance**
   - Adapted naming patterns for tuvens-docs:
     - `vibe-coder/[description]`
     - `docs-orchestrator/[description]`
     - `integration-specialist/[description]`
     - `mobile-dev/[description]`
     - `devops/[description]`
     - `docs/[description]`

3. **Documentation Validation**
   - Check for required safety sections in key files
   - Validate worktree organization documentation
   - Ensure agent workflow documentation exists

4. **Repository-Specific Checks**
   - Validate agentic-development structure
   - Check for documentation consistency
   - Ensure no breaking changes to existing workflows

## Implementation Specifications

### Trigger Events:
```yaml
on:
  push:
    branches:
      - dev
      - test
      - stage
      - main
  pull_request:
    branches:
      - dev
      - test
      - stage
      - main
```

### Jobs to Include:

#### 1. validate-safety-infrastructure
- Check CLAUDE.md has safety sections
- Validate agent documentation exists
- Ensure branching strategy docs are current
- Check for worktree organization documentation

#### 2. validate-branch-naming
- Protected branches allowed (main, stage, test, dev)
- Agent-specific branches follow patterns
- Generic docs/ branches allowed

#### 3. validate-documentation-consistency
- Cross-reference branching documentation
- Check agent workflow consistency
- Validate no contradictory instructions

#### 4. notify-on-failure
- Clear error messages for safety violations
- Guidance on fixing issues
- Reference to documentation for help

### Files to Validate:
- CLAUDE.md (enhanced version from Task 1)
- agentic-development/workflows/branching-strategy.md
- agentic-development/workflows/worktree-organization.md
- .claude/agents/*.md files
- .claude/commands/*.md files

## Success Criteria

- [ ] Workflow prevents pushes to protected branches without safety compliance
- [ ] Branch naming is enforced for all agent patterns
- [ ] Documentation consistency is validated
- [ ] Clear error messages guide users to fix issues
- [ ] No interference with existing workflows (notify-repositories.yml, vibe-coder-maintenance.yml)
- [ ] Works with existing agent/worktree patterns

## Key Adaptations from Event-Harvester

### Repository Context Changes:
1. **Documentation Focus**: Adapt checks for documentation repository vs. code repository
2. **Agent Integration**: Include agent-specific branch naming patterns
3. **Workflow Compatibility**: Ensure no conflicts with existing workflows

### Branch Strategy Adaptation:
- event-harvester: `main ← staging ← test ← develop ← feature/*`
- tuvens-docs: `main ← stage ← test ← dev ← agent/*`

### Validation Differences:
- Focus on documentation quality vs. code quality
- Agent workflow validation vs. API validation
- Cross-repository notification compatibility

## Implementation Notes

### Must Not Break:
1. **Existing Workflows**: notify-repositories.yml and vibe-coder-maintenance.yml
2. **Agent Workflows**: Current agent session patterns
3. **Worktree Organization**: Established worktree patterns

### Should Enhance:
1. **Safety**: Prevent accidental changes to protected branches
2. **Consistency**: Ensure documentation consistency
3. **Agent Support**: Work seamlessly with agent workflows

### Files to Reference:
- `/Users/ciarancarroll/Code/Tuvens/event-harvester/.github/workflows/branch-protection.yml` (source)
- Current tuvens-docs workflows (for compatibility)
- Enhanced CLAUDE.md (from Task 1)
- Agent documentation files

## Risks and Mitigation

### High Risk:
1. **Breaking Existing Workflows**: Could interfere with notify-repositories or vibe-coder workflows
2. **Agent Session Disruption**: Could prevent agents from working properly
3. **False Positives**: Too strict validation causing valid work to fail

### Mitigation:
1. **Careful Testing**: Test workflow in isolation before enabling
2. **Documentation First**: Ensure all safety documents exist before enforcing
3. **Gradual Rollout**: Start with warnings, then enforce blocking

## Testing Plan

### Pre-Implementation:
1. Validate current repository state meets all requirements
2. Ensure enhanced CLAUDE.md exists (Task 1 complete)
3. Check all agent documentation is current

### During Implementation:
1. Test workflow on feature branch first
2. Validate no interference with existing workflows
3. Test with different branch naming patterns

### Post-Implementation:
1. Test agent session creation still works
2. Validate protection rules block inappropriate changes
3. Ensure error messages are clear and helpful

## Session Startup Command

```bash
cd /Users/ciarancarroll/Code/Tuvens/tuvens-docs
/start-session devops
```

**Task Description for Session**: "Create GitHub Actions branch protection workflow adapted from event-harvester to validate safety infrastructure, enforce branch naming, and prevent breaking changes to tuvens-docs while maintaining compatibility with existing workflows and agent patterns."

## Dependencies
- Task 1: Enhanced CLAUDE.md must be completed first
- Current repository documentation must be validated
- User approval required before enabling workflow enforcement