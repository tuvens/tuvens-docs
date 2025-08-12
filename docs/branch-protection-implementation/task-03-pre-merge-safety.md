# Task 3: Pre-Merge Safety Scripts

## Task Overview

**Agent**: devops  
**Worktree**: `devops/task-03-pre-merge-safety`  
**Branch**: `devops/task-03-pre-merge-safety`  
**Estimated Time**: 1-2 focused sessions  

## Objective

Create pre-merge safety validation scripts adapted from event-harvester's `check-before-merge-to-develop.sh` to prevent conflicts and ensure safe merging in tuvens-docs collaborative development.

## Current State Analysis

### Event-Harvester Pre-Merge Safety:
- `check-before-merge-to-develop.sh` with mandatory checklist
- Forces pull of latest develop before merge
- Checks for conflicts and file overlaps
- Reviews recent commits to prevent overwrites
- Interactive confirmation required
- Clear error messages and guidance

### tuvens-docs Current State:
- No pre-merge safety validation
- Relies on developer discipline
- No automated conflict detection
- No recent commits review process

## Deliverables

### Primary Deliverables:

1. **`scripts/check-before-merge-to-dev.sh`**
   - Adapted safety checklist for tuvens-docs
   - Branch-specific validation (dev branch focus)
   - Documentation-specific conflict checking

2. **`scripts/validate-documentation-changes.sh`**
   - Check for documentation consistency
   - Validate internal links still work
   - Ensure no broken references

3. **Agent Workflow Integration**
   - Instructions for agents on using safety scripts
   - Integration with existing worktree patterns

## Implementation Specifications

### Core Safety Script Features:

#### 1. Pre-Merge Validation (`check-before-merge-to-dev.sh`)
```bash
# Mandatory steps before merging to dev:
1. Pull latest dev into feature branch
2. Check for conflicts and resolve in feature branch  
3. Validate documentation consistency
4. Review recent commits for overlaps
5. Confirm no overwriting of others' work
6. Interactive confirmation required
```

#### 2. Documentation Validation (`validate-documentation-changes.sh`)
```bash
# Documentation-specific checks:
1. Internal link validation
2. Agent reference consistency
3. Workflow documentation accuracy
4. No broken cross-references
5. Worktree organization consistency
```

#### 3. Agent Integration
- Clear instructions in enhanced CLAUDE.md
- Integration with `/push` command workflow
- Works with agent-specific branches

### Key Adaptations for tuvens-docs:

#### Branch Focus:
- event-harvester focuses on `develop` branch
- tuvens-docs focuses on `dev` branch
- Support for multiple agent branch patterns

#### Documentation Context:
- Check for documentation consistency vs. code conflicts
- Validate agent workflow references
- Ensure cross-repository notification compatibility

#### Agent Workflow Integration:
- Must work with established agent/worktree patterns
- Integration with existing `/start-session` workflow
- Support for documentation-focused development

## Script Specifications

### check-before-merge-to-dev.sh Structure:
```bash
#!/bin/bash
echo "🚨🚨🚨 STOP - CRITICAL PRE-MERGE CHECKLIST 🚨🚨🚨"

# 1. Branch validation
# 2. Pull latest dev
# 3. Check for conflicts  
# 4. Documentation validation
# 5. Recent commits review
# 6. File overlap detection
# 7. Interactive confirmation
```

### validate-documentation-changes.sh Structure:
```bash
#!/bin/bash
echo "📚 DOCUMENTATION VALIDATION CHECKLIST"

# 1. Internal link checking
# 2. Agent reference validation
# 3. Workflow consistency checks
# 4. Cross-reference validation
# 5. Worktree organization alignment
```

## Success Criteria

- [ ] Scripts prevent accidental overwrites of others' work
- [ ] Documentation consistency validated before merge
- [ ] Clear guidance provided for conflict resolution
- [ ] Integration with agent workflows maintained
- [ ] No breaking changes to existing patterns
- [ ] Interactive confirmation prevents rushed merges
- [ ] Error messages are clear and actionable

## Integration Points

### With Enhanced CLAUDE.md:
- Reference safety scripts in required procedures
- Include in mandatory pre-merge steps
- Integration with emergency recovery procedures

### With Branch Protection Workflow:
- Safety scripts become part of validation pipeline
- Workflow can reference script requirements
- Enforcement through GitHub Actions if needed

### With Agent Workflows:
- Clear instructions for agents using scripts
- Integration with worktree cleanup procedures
- Works with established agent session patterns

## Implementation Notes

### Must Preserve:
1. **Existing Workflows**: No interference with current agent operations
2. **Worktree Patterns**: Maintain established organization
3. **Cross-Repo Notifications**: Don't break notify-repositories.yml

### Must Enhance:
1. **Collaboration Safety**: Prevent conflicts between agents
2. **Documentation Quality**: Ensure consistency and accuracy
3. **Merge Confidence**: Provide clear validation before merge

### Documentation Context Adaptations:
- Focus on documentation conflicts vs. code conflicts
- Agent workflow validation vs. API testing
- Cross-repository notification impact assessment

## Files to Reference:
- `/Users/ciarancarroll/Code/Tuvens/event-harvester/scripts/check-before-merge-to-develop.sh` (source)
- Enhanced CLAUDE.md (Task 1)
- Existing agent documentation
- Worktree organization documentation

## Risks and Mitigation

### Risks:
1. **Script Complexity**: Too complex for documentation repository context
2. **Agent Disruption**: Interfering with established agent workflows
3. **False Positives**: Blocking valid documentation changes

### Mitigation:
1. **Documentation Focus**: Adapt checks for documentation context
2. **Agent Integration**: Work with existing agent patterns
3. **Clear Guidance**: Provide helpful error messages and solutions

## Testing Plan

### Script Testing:
1. Test with different agent branch patterns
2. Validate documentation checking logic
3. Test conflict detection accuracy
4. Verify interactive confirmation works

### Integration Testing:
1. Test with existing agent workflows
2. Validate no disruption to worktree patterns
3. Test integration with `/push` command
4. Verify enhanced CLAUDE.md integration

### User Acceptance:
1. Clear documentation on script usage
2. Training for agents on safety procedures
3. Rollback plan if scripts cause issues

## Session Startup Command

```bash
cd /Users/ciarancarroll/Code/Tuvens/tuvens-docs
/start-session devops
```

**Task Description for Session**: "Create pre-merge safety validation scripts adapted from event-harvester to prevent conflicts and ensure safe collaborative development in tuvens-docs, with focus on documentation consistency and agent workflow integration."

## Dependencies
- Task 1: Enhanced CLAUDE.md completed
- Task 2: Branch protection workflow understanding
- Current agent workflow patterns documented
- User approval for safety script integration