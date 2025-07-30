# Worktree Organization Strategy

## Overview

This document defines the organizational strategy for git worktrees in the Tuvens multi-agent development system, enabling efficient parallel development across multiple agents and repositories.

## Directory Structure

### Implemented Organization
```
/Users/ciarancarroll/code/tuvens/
├── tuvens-docs/                     # Main repository checkout
├── tuvens-client/                   # Main repository checkout  
├── tuvens-api/                      # Main repository checkout
├── hi.events/                       # Main repository checkout
└── worktrees/
    ├── tuvens-docs/
    │   ├── vibe-coder/
    │   │   ├── feature-agent-workflow-instructions/
    │   │   └── {other-vibe-coder-branches}/
    │   ├── documentation-orchestrator/
    │   │   ├── {orchestrator-branches}/
    │   │   └── {coordination-branches}/
    │   └── integration-specialist/
    │       └── {integration-doc-branches}/
    ├── tuvens-client/
    │   ├── frontend-specialist/
    │   │   ├── {frontend-feature-branches}/
    │   │   └── {ui-component-branches}/
    │   └── integration-specialist/
    │       └── {frontend-integration-branches}/
    ├── tuvens-api/
    │   ├── backend-specialist/
    │   │   ├── {backend-feature-branches}/
    │   │   └── {api-endpoint-branches}/
    │   └── integration-specialist/
    │       └── {backend-integration-branches}/
    └── hi.events/
        └── integration-specialist/
            └── {external-integration-branches}/
```

## Organizational Principles

### Agent-Centric Structure
- **Agent Isolation**: Each agent type gets dedicated directories
- **Repository Separation**: Agent worktrees organized by target repository
- **Feature Grouping**: Related features grouped under agent directories
- **Clean Separation**: No cross-contamination between agent workspaces

### Branch Management
- **Feature Branches**: All agent work happens on feature branches
- **Descriptive Naming**: Branch names clearly indicate agent and purpose
- **Consistent Patterns**: Following established naming conventions
- **Lifecycle Management**: Clear creation and cleanup processes

## Agent Worktree Patterns

### Documentation Orchestrator
**Repository:** tuvens-docs
**Directory:** `/worktrees/tuvens-docs/documentation-orchestrator/`

**Typical Branches:**
```
docs-orchestrator/update-agent-identities
docs-orchestrator/create-workflow-templates
docs-orchestrator/sync-cross-repo-docs
```

**Usage Pattern:**
```bash
# Create orchestrator worktree
git worktree add /Users/ciarancarroll/code/tuvens/worktrees/tuvens-docs/documentation-orchestrator/update-agent-identities docs-orchestrator/update-agent-identities

# Work in isolated environment
cd /Users/ciarancarroll/code/tuvens/worktrees/tuvens-docs/documentation-orchestrator/update-agent-identities
```

### Vibe Coder (Experimental Agent)
**Repository:** tuvens-docs
**Directory:** `/worktrees/tuvens-docs/vibe-coder/`

**Typical Branches:**
```
vibe-coder/feature-agent-workflow-instructions
vibe-coder/experiment-new-patterns
vibe-coder/test-coordination-protocols
```

**Current Implementation:**
- ✅ `feature-agent-workflow-instructions` - Created and ready for use
- Directory: `/Users/ciarancarroll/code/tuvens/worktrees/tuvens-docs/vibe-coder/feature-agent-workflow-instructions/`

### Frontend Specialist
**Repository:** tuvens-client
**Directory:** `/worktrees/tuvens-client/frontend-specialist/`

**Typical Branches:**
```
frontend-dev/implement-auth-components
frontend-dev/create-dashboard-widgets
frontend-dev/responsive-layout-updates
```

### Backend Specialist  
**Repository:** tuvens-api
**Directory:** `/worktrees/tuvens-api/backend-specialist/`

**Typical Branches:**
```
backend-dev/implement-oauth-endpoints
backend-dev/create-session-middleware
backend-dev/add-user-management-api
```

### Integration Specialist
**Repositories:** All (cross-repository work)
**Directories:** 
- `/worktrees/tuvens-docs/integration-specialist/`
- `/worktrees/tuvens-client/integration-specialist/`  
- `/worktrees/tuvens-api/integration-specialist/`

**Typical Branches:**
```
integration-specialist/oauth-flow-implementation
integration-specialist/hi-events-webhook-setup
integration-specialist/cross-app-session-sync
```

## Worktree Lifecycle Management

### Creation Process
1. **Create Feature Branch**
   ```bash
   git checkout develop
   git checkout -b {agent-type}/{feature-name}
   ```

2. **Create Agent Worktree**
   ```bash
   git worktree add /Users/ciarancarroll/code/tuvens/worktrees/{repo}/{agent-type}/{feature-name} {agent-type}/{feature-name}
   ```

3. **Set Up Agent Environment**
   ```bash
   cd /Users/ciarancarroll/code/tuvens/worktrees/{repo}/{agent-type}/{feature-name}
   # Load agent context and begin work
   ```

### Active Development
- **Isolated Work**: Each agent works in their dedicated worktree
- **Regular Commits**: Frequent commits to track progress
- **Status Updates**: Regular updates to pending-commits/
- **Cross-Agent Coordination**: Through documentation and workflows

### Completion Process
1. **Final Commit and Push**
   ```bash
   cd /Users/ciarancarroll/code/tuvens/worktrees/{repo}/{agent-type}/{feature-name}
   git add .
   git commit -m "feat({agent}): complete {feature-name}"
   git push origin {agent-type}/{feature-name}
   ```

2. **Create Pull Request**
   ```bash
   gh pr create --base develop --title "feat({agent}): {description}"
   ```

3. **Clean Up Worktree**
   ```bash
   git worktree remove /Users/ciarancarroll/code/tuvens/worktrees/{repo}/{agent-type}/{feature-name}
   ```

## Benefits of This Organization

### Agent Efficiency
- **Context Isolation**: Each agent has dedicated, isolated workspace
- **No Interference**: Agents don't interfere with each other's work
- **Clear Ownership**: Obvious agent responsibility for each worktree
- **Parallel Development**: Multiple agents can work simultaneously

### Repository Management
- **Clean Main Repos**: Main repositories stay clean and focused
- **Branch Organization**: Clear branch organization by agent type
- **Easy Navigation**: Predictable directory structure
- **Conflict Reduction**: Reduced merge conflicts through isolation

### Coordination Benefits
- **Visible Progress**: Easy to see what each agent is working on
- **Status Tracking**: Clear status through directory presence
- **Handoff Support**: Clean handoffs between agents
- **Documentation Integration**: Worktrees align with documentation structure

## Best Practices

### Directory Naming
- Use consistent, descriptive names
- Include agent type and feature/branch name
- Avoid spaces and special characters
- Keep names reasonably short but clear

### Worktree Hygiene
- **Regular Cleanup**: Remove completed worktrees promptly
- **Status Monitoring**: Track active worktrees and their purposes
- **Documentation**: Document special or long-running worktrees
- **Resource Management**: Monitor disk space usage

### Agent Coordination
- **Communication**: Use pending-commits/ for status updates
- **Dependencies**: Document cross-worktree dependencies
- **Timing**: Coordinate timing of related worktrees
- **Integration**: Plan integration points carefully

## Monitoring and Maintenance

### Regular Reviews
- **Weekly**: Review active worktrees and clean up completed ones
- **Monthly**: Assess organization effectiveness and make improvements
- **Quarterly**: Review and update organizational patterns

### Health Checks
```bash
# List all active worktrees
git worktree list

# Check worktree directory sizes
du -sh /Users/ciarancarroll/code/tuvens/worktrees/*

# Identify stale worktrees (older than 30 days)
find /Users/ciarancarroll/code/tuvens/worktrees -type d -mtime +30
```

### Optimization Strategies
- **Performance**: Monitor performance impact of multiple worktrees
- **Storage**: Implement cleanup strategies for disk space management
- **Workflow**: Continuously improve worktree workflows based on usage
- **Automation**: Automate routine worktree management tasks

This organization strategy provides a solid foundation for efficient multi-agent development while maintaining clear separation of concerns and enabling effective coordination across the entire Tuvens ecosystem.