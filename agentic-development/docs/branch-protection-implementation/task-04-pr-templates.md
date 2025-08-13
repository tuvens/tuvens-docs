# Task 4: Pull Request Templates and CODEOWNERS

## Task Overview

**Agent**: docs-orchestrator  
**Worktree**: `docs-orchestrator/task-04-pr-templates`  
**Branch**: `docs/task-04-pr-templates`  
**Estimated Time**: 1 focused session  

## Objective

Create standardized pull request templates and CODEOWNERS file to ensure consistent code review processes and automatic reviewer assignment for tuvens-docs collaborative development.

## Current State Analysis

### Event-Harvester Missing Components:
- No PR templates found (opportunity to improve on the model)
- No CODEOWNERS file (opportunity to enhance)
- Relies on manual reviewer assignment

### tuvens-docs Current State:
- No PR templates
- No CODEOWNERS file
- No standardized review processes
- No automatic reviewer assignment

### Industry Best Practices:
Research needed for documentation repository PR template patterns

## Deliverables

### Primary Deliverables:

1. **`.github/pull_request_template.md`**
   - Standardized PR format for documentation changes
   - Agent-specific sections and checklists
   - Documentation consistency validation
   - Integration with safety workflows

2. **`.github/CODEOWNERS`**
   - Automatic reviewer assignment based on file paths
   - Agent expertise area mapping
   - Documentation ownership patterns

3. **Agent-Specific PR Templates (Optional)**
   - `.github/PULL_REQUEST_TEMPLATE/agent-workflow.md`
   - `.github/PULL_REQUEST_TEMPLATE/documentation-update.md`
   - `.github/PULL_REQUEST_TEMPLATE/infrastructure-change.md`

## Implementation Specifications

### Pull Request Template Structure:

#### Standard Template Sections:
```markdown
## Change Description
Brief description of what this PR changes and why

## Agent Information
- **Agent**: [agent-name]
- **Worktree**: [worktree-path] 
- **Branch**: [branch-name]
- **Related Issue**: #[issue-number]

## Documentation Impact
- [ ] Updates existing documentation
- [ ] Adds new documentation
- [ ] Changes agent workflows
- [ ] Affects cross-repository processes

## Safety Checklist
- [ ] Ran pre-merge safety validation
- [ ] No breaking changes to existing workflows  
- [ ] Documentation consistency maintained
- [ ] Internal links validated
- [ ] Agent workflow references updated

## Review Requirements
- [ ] Documentation review completed
- [ ] Agent workflow impact assessed
- [ ] Cross-repository impact evaluated
- [ ] Safety validation passed

## Testing Completed
- [ ] Documentation builds without errors
- [ ] Internal links verified working
- [ ] Agent workflow tested if applicable
- [ ] No conflicts with existing patterns
```

### CODEOWNERS Structure:

#### File Pattern Ownership:
```
# Global owners
* @[repository-admin]

# Agent-specific documentation  
/.claude/agents/ @[docs-orchestrator] @[agent-experts]
/agentic-development/agents/ @[docs-orchestrator]

# Workflow documentation
/agentic-development/workflows/ @[docs-orchestrator] @[devops-expert]
/.claude/commands/ @[docs-orchestrator]

# Infrastructure 
/.github/ @[devops-expert] @[repository-admin]
/scripts/ @[devops-expert]

# Cross-repository automation
/agentic-development/cross-repo-sync-automation/ @[integration-specialist]

# Branch protection implementation
/agentic-development/branch-protection-implementation/ @[docs-orchestrator] @[devops-expert]
```

## Success Criteria

- [ ] Standardized PR format for all documentation changes
- [ ] Automatic reviewer assignment based on expertise
- [ ] Integration with safety validation workflows
- [ ] Clear guidance for PR authors and reviewers
- [ ] No disruption to existing workflows
- [ ] Agent-specific considerations included

## Key Design Considerations

### Documentation Repository Context:
- Focus on documentation quality vs. code quality
- Agent workflow impact assessment
- Cross-repository notification compatibility
- Internal link validation requirements

### Agent Workflow Integration:
- Templates must work with agent session patterns
- Support for agent-specific branch naming
- Integration with worktree organization
- Compatibility with `/start-session` workflow

### Review Process Optimization:
- Assign reviewers based on expertise areas
- Ensure documentation changes get proper review
- Infrastructure changes require additional oversight
- Agent workflow changes need specialized review

## Implementation Notes

### GitHub Features to Leverage:
1. **Auto-assignment**: CODEOWNERS for automatic reviewer assignment
2. **Template Selection**: Multiple templates for different change types
3. **Required Reviews**: Integration with branch protection rules
4. **Status Checks**: Integration with validation workflows

### Template Customization:
- Standard template for most documentation changes
- Specialized templates for infrastructure/workflow changes
- Agent-specific guidance and checklists
- Integration with safety validation requirements

### Owner Assignment Strategy:
- File path-based ownership for automatic assignment
- Expertise area mapping (docs, infrastructure, agents)
- Fallback to repository administrators
- Integration with user permissions and access

## Files to Research and Reference:
- Industry best practices for documentation PR templates
- GitHub CODEOWNERS documentation
- Existing tuvens repository patterns (if any)
- Event-harvester workflow integration points

## Risks and Mitigation

### Risks:
1. **Over-bureaucracy**: Making PR process too complex
2. **Wrong Reviewers**: Assigning inappropriate reviewers
3. **Template Confusion**: Too many template options

### Mitigation:
1. **Streamlined Process**: Focus on essential validation only
2. **Expertise Mapping**: Careful assignment based on actual expertise
3. **Clear Guidance**: Simple template selection guidance

## Testing Plan

### Template Testing:
1. Test with different types of documentation changes
2. Validate template sections are relevant and useful
3. Ensure integration with safety workflows works
4. Test reviewer assignment accuracy

### Integration Testing:
1. Test with branch protection workflow
2. Validate safety validation integration
3. Test with agent workflow patterns
4. Ensure no conflicts with existing processes

## Research Requirements

Before implementation, research needed on:
1. GitHub PR template best practices for documentation repositories
2. CODEOWNERS patterns for collaborative documentation
3. Integration options with branch protection workflows
4. Agent-specific review requirements

## Session Startup Command

```bash
cd /Users/ciarancarroll/Code/Tuvens/tuvens-docs
/start-session docs-orchestrator
```

**Task Description for Session**: "Create standardized pull request templates and CODEOWNERS file for tuvens-docs to ensure consistent code review processes, automatic reviewer assignment, and integration with safety validation workflows."

## Dependencies
- Task 1: Enhanced CLAUDE.md with safety requirements
- Task 2: Branch protection workflow understanding
- Task 3: Safety validation integration requirements
- Research on GitHub PR template best practices
- User approval for review process changes