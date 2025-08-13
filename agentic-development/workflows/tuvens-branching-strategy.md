# Tuvens Branching Strategy (Based on event-harvester)

## Overview

This standardized branching strategy is based on the sophisticated implementation in event-harvester and should be replicated across all Tuvens repositories for consistent development workflows and automated branch tracking.

## Branch Structure

### Primary Branches
```
main (production)
├── stage (pre-production)
├── test (deployment testing)
├── dev (integration/development)
└── feature/task branches
```

### Branch Flow
```
feature/[type]/[description] → dev → test → stage → main
```

### Change Types (From event-harvester)
- **`feature/`** - New functionality
  - `feature/backend/[description]` - Backend features
  - `feature/frontend/[description]` - Frontend features
  - `feature/[description]` - General features
- **`fix/`** - Bug fixes (`fix/login-validation`)
- **`docs/`** - Documentation changes (`docs/api-endpoints`)

## Environment Mapping

### Backend/Infrastructure Projects
| Branch Pattern | Environment | Backend/Config | Purpose |
|---------------|-------------|----------------|---------|
| `feature/*` | `development` | dev backend | Feature development |
| `dev` | `development` | dev backend | Integration testing |
| `test` | `development` | dev backend | Deployment testing |
| `stage` | `production` | production backend | Pre-production testing |
| `main` | `production` | production backend | Live production |

### Frontend Projects  
| Branch Pattern | VERCEL_ENV | Backend Target | Purpose |
|---------------|------------|----------------|---------|
| `feature/*` | `preview` | dev API | Feature development |
| `dev` | `preview` | dev API | Integration testing |
| `test` | `preview` | dev API | Deployment testing |
| `stage` | `production` | production API | Pre-production testing |
| `main` | `production` | production API | Live production |

## Branch Protection Rules

### main Branch
- ✅ **Require PR reviews** (1+ approvals)
- ✅ **Require status checks** (all CI must pass)
- ✅ **Require up-to-date branches** (must pull latest before merge)
- ✅ **No direct pushes** (enforce PR workflow)
- ✅ **Require signed commits**
- ✅ **Dismiss stale reviews** when new commits pushed

### stage Branch  
- ✅ **Require PR reviews** (1+ approvals)
- ✅ **Require status checks**
- ✅ **Require up-to-date branches**
- ✅ **No direct pushes**

### test Branch
- ✅ **Require PR reviews** (1+ approvals)
- ✅ **Require status checks** (CI must pass)
- ✅ **Require up-to-date branches**
- ✅ **No direct pushes**
- ✅ **Deployment testing required**

### dev Branch
- ✅ **Require status checks** (CI must pass)
- ✅ **Require up-to-date branches**
- ⚠️ **Allow direct pushes** (for quick development iterations)

### Feature Branches
- ✅ **Allow all operations** (full development freedom)
- ✅ **Automatic deletion** after PR merge

## GitHub Actions Integration

### Required Workflows (All Repositories)

#### 1. Branch Lifecycle Tracking
```yaml
# .github/workflows/branch-lifecycle.yml
name: Branch Lifecycle Tracking
on:
  create:
  delete:
  pull_request:
    types: [opened, closed, merged]
```

#### 2. Environment Configuration
```yaml  
# .github/workflows/environment-config.yml
name: Environment Configuration
on:
  push:
    branches: [stage, main]
```

#### 3. Documentation Auto-Generation
```yaml
# .github/workflows/auto-documentation.yml
name: Auto-Generate Documentation
on:
  push:
    branches: [dev, test, stage, main]
  schedule:
    - cron: '0 0 * * 0'  # Weekly
```

#### 4. Central Branch Tracking Integration
```yaml
# .github/workflows/central-tracking.yml
name: Update Central Branch Tracking
on:
  create:
  delete:
  pull_request:
    types: [opened, closed, merged]
```

## Automated Features (From event-harvester)

### Environment-Based Backend Selection
Repositories automatically detect their environment and configure appropriate backends:

```javascript
// Environment detection logic
const branch = process.env.VERCEL_GIT_COMMIT_REF || 'dev';
const backendUrl = (() => {
  switch(branch) {
    case 'main':
      return process.env.VITE_API_BASE_URL_PRODUCTION;
    case 'stage':
      return process.env.VITE_API_BASE_URL_PRODUCTION; // Uses production backend  
    case 'test':
      return process.env.VITE_API_BASE_URL_DEV; // Uses dev backend
    case 'dev':
    default:
      return process.env.VITE_API_BASE_URL_DEV;
  }
})();
```

### Auto-Generated Documentation
Every repository maintains these auto-generated files:

```
agentic-development/docs/auto-generated/
├── recent-commits.md      # Last 25 commits with context
├── current-state.md       # System status and deployment info
├── api-endpoints.md       # Available API endpoints
├── env-vars.md           # Environment variable status
├── doc-tree.md           # Documentation structure
└── schemas.md            # Data schema documentation
```

### Configuration Management
Config files are automatically updated based on branch:

**For main branch (production):**
```json
// .codehooks (or equivalent config)
{
  "project": "production-project-id",
  "space": "prod",
  "apikey": "${{ secrets.PRODUCTION_API_KEY }}"
}
```

**For stage branch (pre-production):**
```json
{
  "project": "stage-project-id",
  "space": "stage", 
  "apikey": "${{ secrets.STAGING_API_KEY }}"
}
```

**For test branch (UAT):**
```json
{
  "project": "test-project-id",
  "space": "test",
  "apikey": "${{ secrets.TEST_API_KEY }}"
}
```

**For dev/feature branches:**
```json
{
  "project": "development-project-id", 
  "space": "dev",
  "apikey": "${{ secrets.DEVELOPMENT_API_KEY }}"
}
```

## Central Tracking Integration

### Branch Creation Event
When any branch is created in any repository:
```yaml
- name: Notify Central Tracking
  uses: peter-evans/repository-dispatch@v2
  with:
    repository: tuvens/tuvens-docs
    event-type: branch-created
    client-payload: |
      {
        "repository": "${{ github.repository.name }}",
        "branch": "${{ github.ref_name }}",
        "changeType": "${{ steps.extract-type.outputs.type }}",
        "author": "${{ github.actor }}",
        "environment": "${{ steps.detect-env.outputs.env }}"
      }
```

### Branch Merge Event
When branches are merged:
```yaml
- name: Notify Merge Complete
  if: github.event.pull_request.merged == true
  uses: peter-evans/repository-dispatch@v2
  with:
    repository: tuvens/tuvens-docs
    event-type: branch-merged
    client-payload: |
      {
        "repository": "${{ github.repository.name }}",
        "branch": "${{ github.event.pull_request.head.ref }}",
        "targetBranch": "${{ github.event.pull_request.base.ref }}",
        "author": "${{ github.event.pull_request.user.login }}",
        "mergedBy": "${{ github.event.pull_request.merged_by.login }}"
      }
```

## Naming Conventions

### Branch Names
```bash
# Good examples (event-harvester pattern)
feature/backend/cross-app-authentication
feature/frontend/dashboard-improvements  
feature/user-settings-panel
fix/login-form-validation
fix/security-patch-csrf
docs/api-endpoint-documentation

# Bad examples
feature/fix-stuff
bug-fix/issue
hotfix/urgent
auth-feature
```

### Commit Messages
Follow conventional commits:
```bash
# Format: type(scope): description
feat(auth): add cross-app authentication flow
fix(ui): resolve login form validation errors
hotfix(security): patch CSRF vulnerability
docs(api): update endpoint documentation
test(e2e): add authentication flow tests
config(env): update stage environment variables
```

## Worktree Integration

### Worktree Naming
Map branch names directly to worktree directories:
```bash
# Branch: feature/frontend/cross-app-authentication-ui
# Worktree: ~/Code/Tuvens/tuvens-client/worktrees/feature-frontend-cross-app-authentication-ui

# Branch: fix/login-form-validation
# Worktree: ~/Code/Tuvens/tuvens-api/worktrees/fix-login-form-validation
```

### Cleanup Automation
Worktrees are automatically queued for cleanup when branches are merged:
```bash
# After branch merge, worktree path added to cleanup queue
{
  "repository": "tuvens-client",
  "branch": "feature/frontend/cross-app-authentication-ui", 
  "worktreePath": "~/Code/Tuvens/tuvens-client/worktrees/feature-frontend-cross-app-authentication-ui",
  "mergedAt": "2024-12-20T10:30:00Z",
  "cleanupEligible": true,
  "priority": "high",
  "mergeTarget": "dev"
}
```

## Implementation Checklist

### For Each Repository
- [ ] **Branch Protection Rules**: Configure main, stage, test, dev protection
- [ ] **GitHub Actions**: Deploy all 4 required workflow templates  
- [ ] **Environment Variables**: Set up dev/test/stage/production environment configs
- [ ] **Documentation Structure**: Create agentic-development/docs/auto-generated/ directory
- [ ] **Config Files**: Set up environment-specific configuration files
- [ ] **Central Tracking**: Enable webhook events to tuvens-docs
- [ ] **TUVENS_DOCS_TOKEN**: Configure secret for central tracking webhooks

### For tuvens-docs (Central Hub)
- [ ] **Branch Tracking**: Implement central branch tracking system
- [ ] **Webhook Handlers**: Process branch lifecycle events from all repos
- [ ] **Cleanup Automation**: Automated worktree cleanup scripts
- [ ] **Documentation**: Cross-repository documentation generation

## Benefits

### Development Experience
- **Consistent Environments**: Automatic backend/environment detection
- **Rich Context**: Auto-generated documentation maintains development context
- **Easy Cleanup**: Automated cleanup of merged branches and worktrees
- **Cross-Repository Awareness**: Know what's happening across all repositories

### Collaboration
- **Clear Branch Purpose**: Standardized naming makes intent obvious
- **Proper Reviews**: Branch protection enforces code review process
- **Environment Isolation**: Safe testing in dedicated environments
- **Automated Documentation**: Always up-to-date project context

### Operations
- **Deployment Safety**: Protected production branches
- **Environment Consistency**: Automated configuration management
- **Audit Trail**: Complete history of all branch lifecycle events
- **Cleanup Automation**: No manual worktree/branch maintenance

## Migration Path

### Phase 1: Standardize Branch Structure
1. Align all repositories to dev → test → stage → main flow (event-harvester pattern)
2. Update branch protection rules for all 4 protected branches
3. Establish naming conventions: feature/[type]/, fix/, docs/

### Phase 2: Implement GitHub Actions
1. Deploy workflow templates to all repositories
2. Configure environment variables
3. Test automated documentation generation

### Phase 3: Enable Central Tracking
1. Implement webhook handlers in tuvens-docs
2. Enable branch lifecycle tracking
3. Deploy cleanup automation

### Phase 4: Enhanced Automation
1. Advanced task group coordination
2. Cross-repository dependency tracking
3. Intelligent branch recommendations

---

**This branching strategy transforms chaotic multi-repository development into an orchestrated, automated system that maintains context, enforces quality, and enables seamless collaboration.**