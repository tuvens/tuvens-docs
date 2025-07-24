# Automated Change Notification Protocol

## 🎯 Problem Statement

The current manual notification protocol for tuvens-docs changes has several failure points:
1. **Protocol Awareness Gap** - Contributors may not know about the notification protocol
2. **Unclear Instructions** - Notification issues lack specific, actionable steps
3. **Manual Process Errors** - Prone to human error and missed repositories
4. **No Automation** - No automated detection, notification, or verification
5. **Poor Tracking** - No systematic way to track which repositories have integrated changes

## 🔧 Proposed Automated Solution

### Phase 1: Immediate Improvements (Manual Process Enhancement)

#### 1.1 Enhanced Notification Template
```markdown
## 📢 URGENT: Documentation Template Updates Available

⚠️ **ACTION REQUIRED**: Your repository needs to integrate new tuvens-docs changes.

### 🚨 Breaking Changes (if any)
- [List any breaking changes that require immediate attention]

### ✨ What's New
- [List specific improvements/fixes with impact]

### 📋 REQUIRED ACTIONS

#### Step 1: Update Your Local tuvens-docs
```bash
# Navigate to YOUR repository's tuvens-docs directory
cd path/to/your-repo/client/tuvens-docs/tuvens-docs
# OR: cd docs/shared-templates (if using submodule method)

# Pull latest changes
git pull origin main

# Verify you have the latest version
git log --oneline -5
```

#### Step 2: Verify New Documentation Access
```bash
# Check that new documentation is available
ls -la integration-guides/
ls -la implementation-guides/
ls -la shared-protocols/
ls -la integration-examples/

# Confirm specific files exist
ls -la integration-guides/hi-events/frontend-integration.md
ls -la shared-protocols/general-frontend-integration.md
```

#### Step 3: Repository-Specific Actions
**For Frontend Repositories (eventdigest-ai, tuvens-client):**
- [ ] Review `shared-protocols/general-frontend-integration.md`
- [ ] Check `integration-examples/frontend-integration/README.md`
- [ ] Verify Tuvens design system compliance
- [ ] Update any non-compliant components

**For Backend Repositories (tuvens-api):**
- [ ] Review `implementation-guides/cross-app-authentication/README.md`
- [ ] Check `integration-guides/hi-events/api-requirements.md`
- [ ] Implement any missing API endpoints
- [ ] Update authentication patterns

**For Integration Repositories (hi.events):**
- [ ] Review `integration-guides/hi-events/` documentation
- [ ] Implement required validation endpoints
- [ ] Test cross-app authentication flow

#### Step 4: Compliance Verification
Run these commands to verify compliance:
```bash
# For frontend repos - check if following standards
npm run lint
npm run typecheck
npm test -- --coverage

# For backend repos - check API endpoints
curl -X POST http://localhost:3000/api/cross-app/generate-session
# (Should return endpoint exists or proper error)
```

### 🔄 MANDATORY: Confirm Completion
When you've completed all steps, comment on this issue with:
```
✅ **Updates Integrated Successfully**

**Repository**: [your-repo-name]
**Completed Actions**:
- [ ] ✅ Pulled latest tuvens-docs changes
- [ ] ✅ Verified new documentation access
- [ ] ✅ Completed repository-specific actions
- [ ] ✅ Verified compliance
- [ ] ✅ All tests passing

**Verification Commands Run**:
```bash
# Paste the commands you ran and their output
```

**Next Steps**: [Any follow-up actions needed]
```

### ⏰ Timeline
- **Immediate**: Pull changes and verify access (within 24 hours)
- **Within 1 week**: Complete repository-specific actions
- **Within 2 weeks**: Full compliance verification

### 🆘 Need Help?
- Check troubleshooting guide: `shared-protocols/troubleshooting.md`
- Review workflow documentation: `shared-protocols/cross-repository-development.md`
- Ask questions in this issue's comments

---
**This issue will remain open until confirmation is received**
```

#### 1.2 Prominent Protocol Documentation
Update CLAUDE.md in all repositories to include:

```markdown
## 🚨 Documentation Update Protocol

When you see a "📢 Documentation Template Updates Available" issue:
1. **Act Immediately** - This indicates required updates from tuvens-docs
2. **Follow All Steps** - Don't skip verification steps
3. **Confirm Completion** - Comment when done
4. **Ask for Help** - If confused, comment on the issue

**Location of Protocol**: `docs/.claude/workflow.md` section "Documentation Updates"
```

### Phase 2: Semi-Automated Solution

#### 2.1 GitHub Actions Workflow for tuvens-docs
Create `.github/workflows/notify-repositories.yml`:

```yaml
name: Notify Repositories of Updates

on:
  push:
    branches: [main]
    paths:
      - 'integration-guides/**'
      - 'implementation-guides/**'  
      - 'shared-protocols/**'
      - 'integration-examples/**'
      - 'claude-templates/**'
      - 'setup.sh'

jobs:
  notify-repositories:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 2
      
      - name: Get changed files
        id: changes
        run: |
          echo "files=$(git diff --name-only HEAD~1 HEAD | tr '\n' ' ')" >> $GITHUB_OUTPUT
      
      - name: Create notification issues
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          # Array of repositories to notify
          repos=("tuvens/eventdigest-ai" "tuvens/tuvens-api" "tuvens/tuvens-client" "tuvens/hi.events")
          
          # Generate issue body with specific changes
          issue_body=$(cat .github/templates/notification-template.md)
          issue_body="${issue_body//\[CHANGED_FILES\]/${{ steps.changes.outputs.files }}}"
          issue_body="${issue_body//\[COMMIT_SHA\]/$(git rev-parse HEAD)}"
          issue_body="${issue_body//\[COMMIT_MESSAGE\]/$(git log -1 --pretty=%s)}"
          
          # Create issues in all repositories
          for repo in "${repos[@]}"; do
            gh issue create --repo "$repo" \
              --title "📢 URGENT: Documentation Template Updates Available" \
              --body "$issue_body" \
              --label "documentation,urgent"
          done
```

#### 2.2 Repository Verification Workflow
Add to each consuming repository `.github/workflows/verify-tuvens-docs.yml`:

```yaml
name: Verify tuvens-docs Compliance

on:
  issue_comment:
    types: [created]

jobs:
  verify-compliance:
    if: contains(github.event.comment.body, '✅ Updates Integrated Successfully')
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Check tuvens-docs version
        run: |
          cd client/tuvens-docs/tuvens-docs || cd docs/shared-templates
          latest_commit=$(git log -1 --format="%H")
          echo "Repository has tuvens-docs commit: $latest_commit"
          
          # Verify key files exist
          required_files=(
            "integration-guides/hi-events/README.md"
            "shared-protocols/general-frontend-integration.md"
            "shared-protocols/cross-repository-development.md"
          )
          
          for file in "${required_files[@]}"; do
            if [[ -f "$file" ]]; then
              echo "✅ Found: $file"
            else
              echo "❌ Missing: $file"
              exit 1
            fi
          done
      
      - name: Verify compliance
        run: |
          npm ci
          npm run lint
          npm run typecheck
          npm test -- --coverage
      
      - name: Close notification issue
        if: success()
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          issue_number=$(echo "${{ github.event.issue.number }}")
          gh issue close $issue_number --comment "✅ **Compliance Verified**
          
          Automated verification completed successfully:
          - ✅ tuvens-docs is up to date
          - ✅ Required files are present
          - ✅ All tests passing
          - ✅ Linting and type checking passed
          
          This issue is now closed as the repository has successfully integrated the documentation updates."
```

### Phase 3: Fully Automated Solution

#### 3.1 Automatic Repository Updates
Use GitHub's Repository Dispatch API to trigger updates:

```yaml
# In tuvens-docs repository
name: Auto-Update Consuming Repositories

on:
  push:
    branches: [main]

jobs:
  trigger-updates:
    runs-on: ubuntu-latest
    steps:
      - name: Trigger repository updates
        env:
          GH_TOKEN: ${{ secrets.REPO_DISPATCH_TOKEN }}
        run: |
          repos=("tuvens/eventdigest-ai" "tuvens/tuvens-api" "tuvens/tuvens-client" "tuvens/hi.events")
          
          for repo in "${repos[@]}"; do
            gh api repos/$repo/dispatches \
              --method POST \
              --field event_type="tuvens-docs-updated" \
              --field client_payload='{"commit":"'$(git rev-parse HEAD)'","changes":"'$(git diff --name-only HEAD~1 HEAD | tr '\n' ',')'"}' 
          done
```

#### 3.2 Smart Update Detection
Create a more intelligent system that only notifies relevant repositories:

```yaml
name: Smart Repository Notification

on:
  push:
    branches: [main]

jobs:
  analyze-changes:
    runs-on: ubuntu-latest
    outputs:
      frontend-changes: ${{ steps.changes.outputs.frontend }}
      backend-changes: ${{ steps.changes.outputs.backend }}
      integration-changes: ${{ steps.changes.outputs.integration }}
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 2
      
      - name: Detect change types
        id: changes
        run: |
          frontend_files="shared-protocols/general-frontend-integration.md integration-examples/frontend-integration/"
          backend_files="implementation-guides/cross-app-authentication/ integration-guides/hi-events/api-requirements.md"
          integration_files="integration-guides/hi-events/"
          
          changed_files=$(git diff --name-only HEAD~1 HEAD)
          
          echo "frontend=false" >> $GITHUB_OUTPUT
          echo "backend=false" >> $GITHUB_OUTPUT  
          echo "integration=false" >> $GITHUB_OUTPUT
          
          for file in $changed_files; do
            if echo $frontend_files | grep -q $file; then
              echo "frontend=true" >> $GITHUB_OUTPUT
            fi
            if echo $backend_files | grep -q $file; then
              echo "backend=true" >> $GITHUB_OUTPUT
            fi
            if echo $integration_files | grep -q $file; then
              echo "integration=true" >> $GITHUB_OUTPUT
            fi
          done

  notify-frontend:
    needs: analyze-changes
    if: needs.analyze-changes.outputs.frontend-changes == 'true'
    runs-on: ubuntu-latest
    steps:
      - name: Notify frontend repositories
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          repos=("tuvens/eventdigest-ai" "tuvens/tuvens-client")
          for repo in "${repos[@]}"; do
            gh issue create --repo "$repo" \
              --title "📢 Frontend Documentation Updates Available" \
              --body-file .github/templates/frontend-notification.md
          done

  notify-backend:
    needs: analyze-changes
    if: needs.analyze-changes.outputs.backend-changes == 'true'
    runs-on: ubuntu-latest
    steps:
      - name: Notify backend repositories
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}
        run: |
          gh issue create --repo "tuvens/tuvens-api" \
            --title "📢 Backend Documentation Updates Available" \
            --body-file .github/templates/backend-notification.md
```

## 🎯 Implementation Roadmap

### Week 1: Immediate Fixes
- [ ] Update notification template with clearer instructions
- [ ] Add protocol documentation to all CLAUDE.md files
- [ ] Create troubleshooting guide for common update issues

### Week 2: Semi-Automation
- [ ] Implement GitHub Actions workflow for automatic notification creation
- [ ] Add verification workflows to consuming repositories
- [ ] Create repository-specific notification templates

### Week 3: Full Automation
- [ ] Implement smart change detection
- [ ] Add automatic issue closure on successful verification
- [ ] Create dashboard for tracking update status across repositories

### Week 4: Monitoring & Optimization
- [ ] Add metrics for notification success rate
- [ ] Implement alerting for failed updates
- [ ] Optimize workflows based on usage data

## 📊 Success Metrics

- **Notification Coverage**: 100% of relevant repositories notified within 1 hour
- **Response Time**: Average time from notification to completion < 24 hours
- **Success Rate**: >95% of repositories successfully integrate updates
- **Manual Intervention**: <10% of notifications require manual follow-up

This protocol transforms the manual, error-prone process into a reliable, automated system that ensures all repositories stay current with tuvens-docs changes.

---

**Next Steps**: Begin with Phase 1 improvements while planning Phase 2 automation implementation.