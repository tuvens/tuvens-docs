# Multi-Agent Branching Strategy

**[CODE] - Essential git workflow guide for Claude Code agents**

## Overview

This document defines the branching strategy for the Tuvens multi-agent development system, supporting parallel agent work across multiple repositories with git worktrees and coordinated workflows.

## Branch Naming Conventions

### Core Repository Branches

#### Main Branches
- `main` - Production-ready code, protected branch
- `develop` - Integration branch for all agent work

#### Agent Feature Branches
Format: `{agent-type}/{feature-description}`

**Agent Types:**
- `docs-orchestrator` - Documentation Orchestrator agent
- `integration-specialist` - Integration Specialist agent
- `backend-dev` - Backend Developer agent
- `frontend-dev` - Frontend Developer agent
- `vibe-coder` - Experimental Vibe Coder agent

#### Examples
```
docs-orchestrator/update-agent-identities
integration-specialist/implement-oauth-flow
backend-dev/add-session-middleware
frontend-dev/create-auth-components
vibe-coder/test-workflow-patterns
```

### Cross-Repository Coordination Branches
For work spanning multiple repositories, use consistent naming:

**tuvens-docs:**
```
integration-specialist/cross-app-auth-docs
docs-orchestrator/sync-api-documentation
```

**tuvens-client:**
```
frontend-dev/cross-app-auth-ui
integration-specialist/oauth-callback-handlers
```

**tuvens-api:**
```
backend-dev/cross-app-auth-endpoints
integration-specialist/oauth-provider-setup
```

## Git Worktree Workflow

### Worktree Organization Structure
```
/Users/ciarancarroll/Code/Tuvens/
├── {repo-name}/                     # Main repository checkouts
├── worktrees/
│   ├── {repo-name}/
│   │   ├── {agent-type}/
│   │   │   ├── {branch-name}/       # Agent-specific worktrees
│   │   │   └── {another-branch}/
│   │   └── {other-agent}/
│   │       └── {their-branches}/
└── shared/                          # Shared resources (if needed)
```

### Worktree Creation Commands

#### For Documentation Work
```bash
# Create docs orchestrator worktree
git worktree add /Users/ciarancarroll/Code/Tuvens/[repo]/[agent]/tuvens-docs/docs-orchestrator/feature-name develop

# Create vibe coder worktree  
git worktree add /Users/ciarancarroll/Code/Tuvens/[repo]/[agent]/tuvens-docs/vibe-coder/experiment-name develop
```

#### For Integration Work
```bash
# Create integration specialist worktree (docs)
git worktree add /Users/ciarancarroll/Code/Tuvens/[repo]/[agent]/tuvens-docs/integration-specialist/oauth-docs develop

# Create integration specialist worktree (client)
git worktree add /Users/ciarancarroll/Code/Tuvens/[repo]/[agent]/tuvens-client/integration-specialist/oauth-ui develop

# Create integration specialist worktree (api)
git worktree add /Users/ciarancarroll/Code/Tuvens/[repo]/[agent]/tuvens-api/integration-specialist/oauth-endpoints develop
```

### Agent Worktree Workflow

#### 1. Create Feature Branch and Worktree
```bash
# From main repository
git checkout develop
git pull origin develop

# Create and checkout feature branch
git checkout -b {agent-type}/{feature-name}

# Create worktree for the agent
git worktree add /Users/ciarancarroll/Code/Tuvens/[repo]/[agent]/{repo}//{agent-type}/{feature-name} {agent-type}/{feature-name}
```

#### 2. Work in Agent-Specific Directory
```bash
# Navigate to agent worktree
cd /Users/ciarancarroll/Code/Tuvens/[repo]/[agent]/{repo}/{agent-type}/{feature-name}

# Start Claude Code session with agent context
claude
```

#### 3. Coordinate Through Documentation
- Update `pending-commits/{branch}/` with progress
- Document cross-agent dependencies
- Update workflow status in relevant workflow files

#### 4. Integration and Merge
```bash
# When work is complete, push feature branch
git push origin {agent-type}/{feature-name}

# Create PR targeting develop
gh pr create --base develop --title "feat({agent}): {description}"

# Clean up worktree after merge
git worktree remove /Users/ciarancarroll/Code/Tuvens/[repo]/[agent]/{repo}/{agent-type}/{feature-name}
```

## Merge Strategies

### CRITICAL: Forward-Only Merge Policy (NO EXCEPTIONS)
**⚠️ STRICT RULE**: Merges flow in ONE DIRECTION ONLY:
```
feature/* → dev/develop → test → stage → main
```

**NEVER** merge backwards (e.g., test → dev, main → stage). This is a STRICT policy with NO exceptions.

### Feature Branch Integration
1. **Agent Work**: All agent work happens on feature branches in worktrees
2. **Feature to Dev**: ALWAYS create feature branches off dev, merge ONLY to dev
3. **Review Process**: PRs reviewed before merging to dev
4. **Forward Promotion**: 
   - dev → test (for testing)
   - test → stage (for staging)
   - stage → main (for production)
5. **No Backward Merges**: NEVER merge from test back to dev, or main back to stage

### Cross-Repository Coordination
1. **Sync Points**: Use pending-commits/ to coordinate timing
2. **Dependencies**: Document in workflow files which PRs depend on others
3. **Integration Testing**: Test cross-repo features before merging to main
4. **Rollback Plan**: Maintain ability to rollback coordinated changes

## Conflict Resolution

### Code Conflicts
1. **Prevention**: Use pending-commits/ to communicate changes early
2. **Detection**: Regular `git fetch` in worktrees to stay updated
3. **Resolution**: Agent responsible for feature resolves conflicts
4. **Escalation**: Documentation Orchestrator mediates complex conflicts

### Cross-Agent Conflicts
1. **Document Conflict**: Create entry in pending-commits/ describing the conflict
2. **Agent Discussion**: Use workflow files for async discussion
3. **Resolution Decision**: Documentation Orchestrator or senior agent decides
4. **Implementation**: Affected agents implement the resolution

### Workflow Conflicts
1. **Priority Assignment**: Use workflow priority levels (high/medium/low)
2. **Resource Conflicts**: Documentation Orchestrator assigns agent priorities  
3. **Timeline Conflicts**: Adjust workflow phases to accommodate dependencies
4. **Scope Conflicts**: Break down features to reduce overlap

## Branch Protection Rules

### Main Branch
- Require PR reviews
- Require status checks to pass
- Require branches to be up to date
- Restrict pushes to administrators only

### Develop Branch
- Require PR reviews (can be from any senior agent)
- Require status checks to pass
- Allow squash merging for clean history

### Feature Branches
- No restrictions (agents work freely)
- Encourage frequent commits for transparency
- Push regularly to backup work

## Worktree Best Practices

### Organization
1. **Consistent Structure**: Always use the defined directory structure
2. **Clear Naming**: Use descriptive worktree directory names
3. **Agent Isolation**: Keep agent worktrees separate to avoid conflicts
4. **Regular Cleanup**: Remove completed worktrees promptly

### Development
1. **Single Focus**: One worktree per feature/task
2. **Context Loading**: Load appropriate agent context in each worktree
3. **Status Updates**: Regular updates to pending-commits/
4. **Cross-Reference**: Link related work across repositories

### Maintenance
1. **Regular Sync**: `git fetch` regularly in all worktrees
2. **Cleanup Schedule**: Weekly cleanup of completed worktrees
3. **Documentation**: Keep worktree documentation updated
4. **Monitoring**: Watch for orphaned or stale worktrees

## Integration with GitHub Issues

### Issue Creation
- Create issues for significant features requiring multiple agents
- Use issue templates for different types of agent work
- Assign appropriate labels (agent-type, priority, repository)

### Cross-Repository Issues
- Use issue templates that reference related issues in other repos
- Maintain issue links in workflow documentation
- Update issues with PR links from each repository

### Agent Coordination
- Use issue comments for cross-agent communication
- Reference issues in commit messages and PR descriptions
- Close issues only when all related work is complete

This branching strategy enables sophisticated multi-agent development while maintaining code quality and coordination across the entire Tuvens ecosystem.