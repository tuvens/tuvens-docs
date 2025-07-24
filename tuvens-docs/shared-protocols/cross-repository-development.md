# Cross-Repository Development Guidelines

## 🎯 Overview

This document establishes standardized guidelines for development workflows that span multiple repositories within the Tuvens ecosystem. These protocols ensure consistency, quality, and seamless integration across all projects.

## 🏗️ Repository Structure Standards

### Standard Directory Layout

All Tuvens repositories should follow this consistent structure:

```
repository-name/
├── .github/
│   ├── workflows/              # CI/CD pipelines
│   ├── ISSUE_TEMPLATE/         # Issue templates
│   └── pull_request_template.md
├── docs/
│   ├── .claude/                # Claude Code integration
│   │   ├── commands/           # Custom commands
│   │   └── INTEGRATION_REGISTRY.md
│   ├── api/                    # API documentation
│   ├── deployment/             # Deployment guides
│   └── development/            # Development setup
├── src/                        # Source code
├── tests/                      # Test files
├── scripts/                    # Build and utility scripts
├── CLAUDE.md                   # Claude Code instructions
├── README.md                   # Project overview
├── CONTRIBUTING.md             # Contribution guidelines
└── package.json / requirements.txt
```

### Claude Code Integration

Every repository must include:

1. **CLAUDE.md** - Claude Code session instructions
2. **docs/.claude/** - Claude integration directory
3. **INTEGRATION_REGISTRY.md** - Cross-repository integration tracking

## 🔄 Development Workflow

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

## 🔧 Technical Standards

### Code Quality Requirements

#### All Repositories Must Have:
- **Linting Configuration** (ESLint, Prettier, Black, etc.)
- **Type Checking** (TypeScript, mypy, etc.)
- **Test Coverage** minimum 80%
- **Security Scanning** (CodeQL, Snyk, etc.)
- **Documentation Generation** (JSDoc, Sphinx, etc.)

#### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
**Scopes**: `api`, `ui`, `auth`, `integration`, `docs`, `ci`

**Examples**:
```
feat(auth): add cross-app session token generation
fix(ui): resolve ticket widget loading issue
docs(integration): update Hi.Events authentication flow
```

### API Design Standards

#### REST API Guidelines
1. **Consistent Base URLs**
   ```
   https://api.tuvens.com/v1/
   https://tickets.tuvens.com/api/v1/
   ```

2. **Standard HTTP Methods**
   - `GET` - Retrieve resources
   - `POST` - Create resources
   - `PUT` - Update entire resources
   - `PATCH` - Partial resource updates
   - `DELETE` - Remove resources

3. **Response Format**
   ```json
   {
     "data": {},
     "meta": {
       "timestamp": "2025-07-24T14:30:00Z",
       "version": "1.0"
     },
     "errors": []
   }
   ```

4. **Error Response Format**
   ```json
   {
     "error": {
       "code": "AUTHENTICATION_FAILED",
       "message": "Invalid JWT token",
       "details": {},
       "timestamp": "2025-07-24T14:30:00Z"
     }
   }
   ```

#### GraphQL Guidelines (where applicable)
1. **Schema Versioning** through field deprecation
2. **Query Complexity** limits and depth analysis
3. **Subscription** patterns for real-time updates
4. **Error Handling** with proper error codes

### Database Standards

#### Schema Management
1. **Migration Scripts** for all schema changes
2. **Rollback Procedures** for failed migrations
3. **Cross-Database** foreign key documentation
4. **Data Validation** at application and database levels

#### Naming Conventions
- **Tables**: `snake_case` (e.g., `user_accounts`, `cross_app_sessions`)
- **Columns**: `snake_case` (e.g., `created_at`, `user_id`)
- **Indexes**: `idx_table_column` (e.g., `idx_users_email`)
- **Foreign Keys**: `fk_table_referenced_table` (e.g., `fk_sessions_users`)

## 🚀 CI/CD Standards

### GitHub Actions Workflow

#### Required Workflows
Every repository must have these workflows:

1. **Continuous Integration** (`.github/workflows/ci.yml`)
   ```yaml
   name: Continuous Integration
   on: [push, pull_request]
   jobs:
     test:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - name: Setup Node.js
           uses: actions/setup-node@v3
           with:
             node-version: '18'
         - run: npm ci
         - run: npm run lint
         - run: npm run typecheck
         - run: npm run test:coverage
         - run: npm run build
   ```

2. **Security Scanning** (`.github/workflows/security.yml`)
   ```yaml
   name: Security Scan
   on: [push, pull_request]
   jobs:
     codeql:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - uses: github/codeql-action/init@v2
         - uses: github/codeql-action/analyze@v2
     
     dependency-scan:
       runs-on: ubuntu-latest
       steps:
         - uses: actions/checkout@v3
         - run: npm audit --audit-level high
   ```

3. **Integration Testing** (`.github/workflows/integration.yml`)
   ```yaml
   name: Integration Tests
   on:
     pull_request:
       branches: [develop, main]
   jobs:
     integration:
       runs-on: ubuntu-latest
       services:
         postgres:
           image: postgres:13
           env:
             POSTGRES_PASSWORD: postgres
           options: >-
             --health-cmd pg_isready
             --health-interval 10s
             --health-timeout 5s
             --health-retries 5
       steps:
         - uses: actions/checkout@v3
         - run: npm ci
         - run: npm run test:integration
   ```

#### Deployment Workflows

**Staging Deployment** (on develop branch):
```yaml
name: Deploy to Staging
on:
  push:
    branches: [develop]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run build
      - name: Deploy to Staging
        run: npm run deploy:staging
        env:
          STAGING_API_KEY: ${{ secrets.STAGING_API_KEY }}
```

**Production Deployment** (on main branch):
```yaml
name: Deploy to Production
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    environment: production
    steps:
      - uses: actions/checkout@v3
      - run: npm ci
      - run: npm run build
      - name: Deploy to Production
        run: npm run deploy:production
        env:
          PRODUCTION_API_KEY: ${{ secrets.PRODUCTION_API_KEY }}
```

## 📋 Code Review Standards

### Pull Request Requirements

#### PR Description Template
```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Cross-Repository Impact
- [ ] No other repositories affected
- [ ] Updates required in: [list repositories]
- [ ] Integration tests updated

## Testing
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Documentation
- [ ] Code comments updated
- [ ] API documentation updated
- [ ] Integration guides updated
- [ ] Claude Code instructions updated

## Security
- [ ] No sensitive data exposed
- [ ] Authentication/authorization properly implemented
- [ ] Input validation added
- [ ] Security tests pass
```

#### Review Checklist

**Code Quality**:
- [ ] Code follows established style guidelines
- [ ] No code duplication
- [ ] Proper error handling
- [ ] Appropriate logging levels
- [ ] Performance considerations addressed

**Security**:
- [ ] Input validation implemented
- [ ] Authentication/authorization checked
- [ ] No sensitive data in logs
- [ ] SQL injection prevention
- [ ] XSS prevention measures

**Integration**:
- [ ] API contracts maintained
- [ ] Backward compatibility preserved
- [ ] Database migrations reviewed
- [ ] Cross-repository dependencies documented

**Documentation**:
- [ ] README updated if needed
- [ ] API documentation current
- [ ] Integration guides accurate
- [ ] Comments explain complex logic

## 🔍 Monitoring and Observability

### Required Monitoring

#### Application Metrics
- **Performance**: Response times, throughput, error rates
- **Business**: User actions, feature usage, conversion rates
- **Infrastructure**: CPU, memory, disk, network usage

#### Cross-Repository Metrics
- **Integration Health**: Cross-app authentication success rates
- **API Performance**: Cross-service API call latencies
- **Error Correlation**: Track errors across repository boundaries

#### Alerting Thresholds
```yaml
# monitoring/alerts.yml
alerts:
  - name: "High Error Rate"
    condition: "error_rate > 5%"
    duration: "5m"
    severity: "critical"
  
  - name: "Slow API Response"
    condition: "api_response_time > 2s"
    duration: "2m"
    severity: "warning"
  
  - name: "Cross-App Auth Failures"
    condition: "auth_failure_rate > 10%"
    duration: "1m"
    severity: "critical"
```

### Logging Standards

#### Log Format
```json
{
  "timestamp": "2025-07-24T14:30:00.000Z",
  "level": "INFO",
  "service": "tuvens-api",
  "correlation_id": "req-123-456",
  "user_id": "user-789",
  "message": "Cross-app session generated",
  "data": {
    "session_id": "sess-abc-def",
    "target_app": "hi-events",
    "expires_at": "2025-07-24T14:45:00.000Z"
  }
}
```

#### Log Levels
- **ERROR**: System errors, exceptions, failures
- **WARN**: Degraded functionality, missing data, performance issues
- **INFO**: Normal operations, user actions, system events
- **DEBUG**: Detailed diagnostic information (development only)

## 🤝 Collaboration Protocols

### Communication Standards

#### Issue Management
1. **Epic Issues** for cross-repository features
2. **Linked Issues** across repositories
3. **Status Updates** in central project board
4. **Resolution Documentation**

#### Team Coordination
1. **Architecture Reviews** for cross-repo changes
2. **Integration Planning** sessions
3. **Deployment Coordination** meetings
4. **Post-Mortem Reviews** for incidents

### Documentation Maintenance

#### Responsibility Matrix
| Documentation Type | Primary Owner | Review Frequency |
|-------------------|---------------|------------------|
| API Documentation | Backend Team | Weekly |
| Integration Guides | Architecture Team | Monthly |
| Development Guidelines | All Teams | Quarterly |
| Claude Code Instructions | Repository Owner | As Needed |

#### Update Process
1. **Pull Request** for documentation changes
2. **Technical Review** by relevant team
3. **Integration Testing** of documented procedures
4. **Publication** to shared documentation repository

## 🎯 Quality Gates

### Definition of Done

A feature is considered complete when:
- [ ] All code is implemented and reviewed
- [ ] Unit tests achieve >80% coverage
- [ ] Integration tests pass
- [ ] Security scan passes
- [ ] Documentation is updated
- [ ] Claude Code instructions are current
- [ ] Performance benchmarks are met
- [ ] Accessibility requirements are satisfied
- [ ] Cross-browser compatibility verified
- [ ] Mobile responsiveness confirmed

### Release Criteria

A release is ready when:
- [ ] All features meet Definition of Done
- [ ] Integration tests pass across all repositories
- [ ] Security scan shows no high/critical issues
- [ ] Performance regression tests pass
- [ ] Documentation is complete and accurate
- [ ] Deployment procedures are tested
- [ ] Rollback procedures are verified
- [ ] Monitoring and alerting are configured

---

**Maintained By**: Tuvens Architecture Team  
**Last Updated**: 2025-07-24  
**Next Review**: 2025-10-24  
**Version**: 1.0