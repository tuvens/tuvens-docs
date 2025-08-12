# Worktree Organization Strategy

**[CODE] - Loaded by Claude Code to understand worktree patterns**

## Overview

This document defines the organizational strategy for git worktrees in the Tuvens multi-agent development system, enabling efficient parallel development across multiple agents and repositories.

## Directory Structure

### Implemented Organization
```
/Users/ciarancarroll/Code/Tuvens/
├── tuvens-docs/                     # Main repository checkout
│   ├── worktrees/                   # Isolated agent worktrees directory
│   │   ├── vibe-coder/              # Agent worktrees (docs organization)
│   │   │   ├── feature/
│   │   │   │   ├── feature-agent-workflow-instructions/
│   │   │   │   ├── feature-cto-technical-improvements/
│   │   │   │   └── {other-vibe-coder-feature-branches}/
│   │   │   └── {other-branch-types}/
│   │   ├── devops/                  # DevOps agent worktrees
│   │   │   └── {devops-branches}/
│   │   ├── mobile-dev/              # Mobile development worktrees
│   │   │   └── {mobile-branches}/
│   │   └── integration-specialist/
│   │       └── {integration-doc-branches}/
├── tuvens-client/                   # Main repository checkout  
│   ├── frontend-developer/          # Agent worktrees
│   │   ├── {frontend-feature-branches}/
│   │   └── {ui-component-branches}/
│   └── integration-specialist/
│       └── {frontend-integration-branches}/
├── tuvens-api/                      # Main repository checkout
│   ├── backend-developer/           # Agent worktrees
│   │   ├── {backend-feature-branches}/
│   │   └── {api-endpoint-branches}/
│   └── integration-specialist/
│       └── {backend-integration-branches}/
├── tuvens-mobile/                   # Main repository checkout
│   └── integration-specialist/      # Agent worktrees
│       └── {mobile-integration-branches}/
└── hi.events/                       # Main repository checkout
    └── integration-specialist/      # Agent worktrees
        └── {external-integration-branches}/
```

## Organizational Principles

### Agent-Centric Structure
- **Agent Isolation**: Each agent type gets dedicated directories within their repository
- **Repository-Local Worktrees**: Agent worktrees live inside each repository following `[repo]/[agent]/[branch]` pattern
- **Feature Grouping**: Related features grouped under agent directories
- **Clean Separation**: No cross-contamination between agent workspaces

### Branch Management
- **Feature Branches**: All agent work happens on feature branches
- **Descriptive Naming**: Branch names clearly indicate agent and purpose
- **Consistent Patterns**: Following established naming conventions
- **Lifecycle Management**: Clear creation and cleanup processes

## Agent Worktree Patterns

### Vibe Coder (Documentation Organization & Experimental Agent)
**Repository:** tuvens-docs
**Directory Pattern:** `tuvens-docs/worktrees/vibe-coder/[branch-name]`

**Typical Branches:**
```
vibe-coder/feature-agent-workflow-instructions
vibe-coder/feature-cto-technical-improvements
vibe-coder/update-agent-identities
vibe-coder/create-workflow-templates
vibe-coder/experiment-new-patterns
vibe-coder/test-coordination-protocols
```

**Current Implementation:**
- ✅ `feature-agent-workflow-instructions` - Completed and merged
- ✅ `feature-cto-technical-improvements` - Completed and merged
- Directory Pattern: `/Users/ciarancarroll/Code/Tuvens/tuvens-docs/worktrees/vibe-coder/[branch-name]/`

**Responsibilities:**
- Documentation organization and structure
- Agent workflow development
- System architecture experimentation
- Technical workflow improvements
- Creative problem-solving for development challenges

### Frontend Developer
**Repository:** tuvens-client
**Directory Pattern:** `tuvens-client/frontend-developer/[branch-name]`

**Typical Branches:**
```
frontend-dev/implement-auth-components
frontend-dev/create-dashboard-widgets
frontend-dev/responsive-layout-updates
```

### Backend Developer  
**Repository:** tuvens-api
**Directory Pattern:** `tuvens-api/backend-developer/[branch-name]`

**Typical Branches:**
```
backend-dev/implement-oauth-endpoints
backend-dev/create-session-middleware
backend-dev/add-user-management-api
```

### Integration Specialist
**Repositories:** All (cross-repository work)
**Directory Patterns:** 
- `tuvens-docs/integration-specialist/[branch-name]`
- `tuvens-client/integration-specialist/[branch-name]`
- `tuvens-api/integration-specialist/[branch-name]`
- `tuvens-mobile/integration-specialist/[branch-name]`
- `hi.events/integration-specialist/[branch-name]`

**Typical Branches:**
```
integration-specialist/oauth-flow-implementation
integration-specialist/hi-events-webhook-setup
integration-specialist/cross-app-session-sync
integration-specialist/mobile-api-integration
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
   cd /Users/ciarancarroll/Code/Tuvens/{repo}
   git worktree add worktrees/{agent-type}/{feature-name} {agent-type}/{feature-name}
   ```

3. **Set Up Agent Environment**
   ```bash
   cd worktrees/{agent-type}/{feature-name}
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
   cd /Users/ciarancarroll/Code/Tuvens/{repo}/worktrees/{agent-type}/{feature-name}
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
   cd /Users/ciarancarroll/Code/Tuvens/{repo}
   git worktree remove worktrees/{agent-type}/{feature-name}
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

# Check worktree directory sizes in each repository
for repo in tuvens-docs tuvens-client tuvens-api tuvens-mobile hi.events; do
    echo "=== $repo ==="
    cd /Users/ciarancarroll/Code/Tuvens/$repo
    du -sh */
    echo ""
done

# Identify stale worktrees (older than 30 days) in each repository
for repo in tuvens-docs tuvens-client tuvens-api tuvens-mobile hi.events; do
    echo "=== $repo ==="
    find /Users/ciarancarroll/Code/Tuvens/$repo -mindepth 2 -maxdepth 2 -type d -mtime +30
done
```

### Optimization Strategies
- **Performance**: Monitor performance impact of multiple worktrees
- **Storage**: Implement cleanup strategies for disk space management
- **Workflow**: Continuously improve worktree workflows based on usage
- **Automation**: Automate routine worktree management tasks

This worktree organization pattern provides a solid foundation for efficient multi-agent development while maintaining clear separation of concerns and enabling effective coordination across the entire Tuvens ecosystem.