# 🚀 CI/CD Standards

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