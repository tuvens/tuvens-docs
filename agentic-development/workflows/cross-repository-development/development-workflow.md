# 🔄 Development Workflow

### Branch Strategy

#### Primary Branches
- **`main`** - Production-ready code, protected branch
- **`develop`** - Integration branch for features, auto-deploys to staging
- **`feature/*`** - Feature development branches
- **`hotfix/*`** - Critical production fixes
- **`release/*`** - Release preparation branches

#### Branch Protection Rules
```yaml
# .github/branch-protection.yml
main:
  required_status_checks:
    - continuous-integration
    - security-scan
    - code-quality
  enforce_admins: true
  required_pull_request_reviews:
    required_approving_review_count: 2
    dismiss_stale_reviews: true
    require_code_owner_reviews: true

develop:
  required_status_checks:
    - continuous-integration
    - integration-tests
  required_pull_request_reviews:
    required_approving_review_count: 1
```

### Cross-Repository Feature Development

#### Step 1: Planning Phase
1. **Create Epic Issue** in primary repository
2. **Cross-Repository Impact Assessment**
   - Identify all affected repositories
   - Document integration points
   - Plan deployment sequence
3. **Update Integration Registry** in tuvens-docs

#### Step 2: Implementation Phase
1. **Create Feature Branches** in all affected repositories
   ```bash
   # Consistent naming across repositories
   git checkout -b feature/cross-app-authentication
   ```

2. **Implement Changes** following dependency order
   - Backend APIs first
   - Frontend integrations second
   - Documentation updates third

3. **Update Documentation** continuously
   - API documentation
   - Integration guides
   - Claude Code instructions

#### Step 3: Testing Phase
1. **Unit Tests** in individual repositories
2. **Integration Tests** across repository boundaries
3. **End-to-End Tests** for complete user workflows
4. **Security Testing** for cross-app communication

#### Step 4: Review Phase
1. **Individual Repository PRs** with detailed descriptions
2. **Cross-Repository Review** by architecture team
3. **Integration Validation** through staging deployment
4. **Documentation Review** for completeness and accuracy

#### Step 5: Deployment Phase
1. **Coordinated Deployment** following dependency order
2. **Monitoring and Rollback** procedures
3. **Post-Deployment Validation**
4. **Issue Closure** with proper documentation