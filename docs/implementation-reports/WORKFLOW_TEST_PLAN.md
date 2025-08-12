# Documentation Automation System - Workflow Test Plan

## Overview

This test plan validates the documentation automation system workflows in a real GitHub Actions environment after merge to dev/main branches.

## Pre-Test Requirements

### 1. Deployment Prerequisites
- [ ] Feature branch merged to `dev` branch
- [ ] Workflows visible in GitHub Actions tab
- [ ] Required secrets and permissions configured
- [ ] Test repositories accessible for notifications

### 2. Required Permissions/Secrets
- [ ] `TUVENS_DOCS_TOKEN` secret configured with appropriate repository access
- [ ] Write permissions to target repositories for issue creation
- [ ] Repository dispatch permissions for central tracking

## Test Phase 1: Workflow Deployment Validation

### Test 1.1: Workflow Registration
**Objective**: Verify workflows are registered and visible in GitHub Actions

**Steps**:
```bash
gh workflow list --repo tuvens/tuvens-docs
```

**Expected Results**:
- [ ] `Auto-Generate Documentation` workflow appears in list
- [ ] `Central Branch Tracking Handler` workflow appears in list
- [ ] `Notify Repositories of Documentation Updates` workflow already present

**Validation Commands**:
```bash
# Check workflow files exist in main repo
gh api repos/tuvens/tuvens-docs/contents/.github/workflows/auto-documentation.yml
gh api repos/tuvens/tuvens-docs/contents/.github/workflows/central-tracking-handler.yml
```

### Test 1.2: Workflow Syntax Validation
**Objective**: Ensure workflows have valid YAML syntax and GitHub Actions configuration

**Steps**:
1. Trigger manual workflow dispatch (if available)
2. Check for immediate syntax errors in Actions tab

**Expected Results**:
- [ ] No YAML syntax errors reported
- [ ] Workflows can be manually triggered
- [ ] No immediate configuration errors

## Test Phase 2: Auto-Documentation Workflow Testing

### Test 2.1: Manual Trigger Test
**Objective**: Verify auto-documentation workflow executes successfully

**Test Setup**:
```bash
# Manually trigger the workflow
gh workflow run auto-documentation.yml --repo tuvens/tuvens-docs
```

**Validation Steps**:
1. [ ] Monitor workflow execution in GitHub Actions tab
2. [ ] Check for successful completion (green checkmark)
3. [ ] Verify no step failures or errors

**Expected Outputs**:
- [ ] `docs/auto-generated/recent-commits.md` created
- [ ] `docs/auto-generated/current-state.md` created
- [ ] `docs/auto-generated/doc-tree.md` created
- [ ] Files committed with appropriate commit message
- [ ] Workflow artifacts uploaded successfully

### Test 2.2: Automatic Trigger Test
**Objective**: Verify workflow triggers on push to protected branches

**Test Setup**:
```bash
# Create a test documentation change
echo "Test update $(date)" >> tuvens-docs/test-file.md
git add tuvens-docs/test-file.md
git commit -m "test: trigger auto-documentation workflow"
git push origin dev
```

**Validation Steps**:
1. [ ] Workflow triggers automatically on push
2. [ ] Documentation files are generated and updated
3. [ ] Commit appears with auto-generated documentation

### Test 2.3: Documentation Content Validation
**Objective**: Verify generated documentation contains expected content

**Validation Commands**:
```bash
# Check recent-commits.md content
curl -s https://raw.githubusercontent.com/tuvens/tuvens-docs/dev/docs/auto-generated/recent-commits.md | head -20

# Check current-state.md content  
curl -s https://raw.githubusercontent.com/tuvens/tuvens-docs/dev/docs/auto-generated/current-state.md | head -20

# Check doc-tree.md content
curl -s https://raw.githubusercontent.com/tuvens/tuvens-docs/dev/docs/auto-generated/doc-tree.md | head -20
```

**Expected Results**:
- [ ] Recent commits show actual git history with file changes
- [ ] Current state shows correct branch and environment info
- [ ] Doc tree contains actual documentation structure
- [ ] Timestamps are recent and accurate
- [ ] Repository information is correct

## Test Phase 3: Repository Notification System Testing

### Test 3.1: Notification Trigger Test
**Objective**: Verify notifications are sent to consuming repositories

**Test Setup**:
```bash
# Create a change that should trigger notifications
mkdir -p tuvens-docs/test-integration-update
echo "# Test Integration Update" > tuvens-docs/test-integration-update/README.md
git add tuvens-docs/test-integration-update/
git commit -m "feat: add test integration documentation"
git push origin main  # Must be main branch to trigger notifications
```

**Validation Steps**:
1. [ ] `notify-repositories.yml` workflow triggers automatically
2. [ ] Change analysis step completes successfully
3. [ ] Matrix strategy executes for all target repositories

**Monitor Execution**:
```bash
# Watch workflow progress
gh run list --workflow=notify-repositories.yml --repo tuvens/tuvens-docs
gh run view <run-id> --repo tuvens/tuvens-docs
```

### Test 3.2: Issue Creation Validation  
**Objective**: Verify notification issues are created in target repositories

**Target Repositories to Check**:
- [ ] `tuvens/eventdigest-ai` (frontend)
- [ ] `tuvens/tuvens-client` (frontend)
- [ ] `tuvens/tuvens-api` (backend)
- [ ] `tuvens/hi.events` (integration)
- [ ] `tuvens/tuvens-mobile` (mobile)

**Validation Commands** (for each repository):
```bash
# Check for new notification issues
gh issue list --repo tuvens/eventdigest-ai --search "📢 URGENT: Documentation Updates Available" --state open

# Verify issue content
gh issue view <issue-number> --repo tuvens/eventdigest-ai
```

**Expected Results**:
- [ ] Issues created in appropriate repositories based on change type
- [ ] Issue titles follow expected format with commit SHA
- [ ] Issue bodies contain correct placeholders replaced with actual values
- [ ] Issues contain repository-specific content (frontend/backend/integration/mobile)

### Test 3.3: Template Content Validation
**Objective**: Verify notification templates render correctly with real data

**Validation Checks**:
- [ ] `[COMMIT_SHA]` replaced with actual commit SHA
- [ ] `[COMMIT_MESSAGE]` replaced with actual commit message
- [ ] `[CHANGED_FILES]` replaced with actual changed files list
- [ ] `[REPO_NAME]` replaced with target repository name
- [ ] Repository-specific sections appear correctly
- [ ] All markdown formatting renders properly

## Test Phase 4: Central Branch Tracking Testing

### Test 4.1: Repository Dispatch Setup
**Objective**: Verify other repositories can send tracking events to tuvens-docs

**Test Setup** (to be run from a consuming repository):
```bash
# Send a test repository dispatch event
gh api repos/tuvens/tuvens-docs/dispatches \
  --method POST \
  --field event_type='branch-lifecycle' \
  --field 'client_payload[event]=created' \
  --field 'client_payload[repository]=test-repo' \
  --field 'client_payload[branch]=test-branch' \
  --field 'client_payload[changeType]=feature' \
  --field 'client_payload[author]=test-user'
```

**Expected Results**:
- [ ] `central-tracking-handler.yml` workflow triggers
- [ ] Workflow completes successfully
- [ ] No authentication or permission errors

### Test 4.2: JSON File Updates Validation
**Objective**: Verify tracking files are updated correctly

**Pre-Test State Check**:
```bash
# Check initial state of tracking files
curl -s https://raw.githubusercontent.com/tuvens/tuvens-docs/main/agentic-development/branch-tracking/active-branches.json
```

**Post-Event Validation**:
```bash
# Verify files were updated
curl -s https://raw.githubusercontent.com/tuvens/tuvens-docs/main/agentic-development/branch-tracking/active-branches.json | jq
curl -s https://raw.githubusercontent.com/tuvens/tuvens-docs/main/agentic-development/branch-tracking/merge-log.json | jq
```

**Expected Results**:
- [ ] `active-branches.json` contains new branch entry
- [ ] Branch data includes correct repository, author, change type
- [ ] Agent assignment is correct based on repository type
- [ ] Timestamps are accurate
- [ ] JSON structure is valid

### Test 4.3: Distributed Locking Test
**Objective**: Verify concurrent updates are handled safely

**Test Setup**:
```bash
# Send multiple rapid dispatch events
for i in {1..3}; do
  gh api repos/tuvens/tuvens-docs/dispatches \
    --method POST \
    --field event_type='branch-lifecycle' \
    --field 'client_payload[event]=created' \
    --field "client_payload[repository]=test-repo-$i" \
    --field "client_payload[branch]=test-branch-$i" \
    --field 'client_payload[changeType]=feature' \
    --field 'client_payload[author]=test-user' &
done
wait
```

**Expected Results**:
- [ ] All events processed successfully
- [ ] No data corruption in JSON files
- [ ] Lock branches created and cleaned up properly
- [ ] All branch entries appear in tracking files

## Test Phase 5: Error Handling and Recovery

### Test 5.1: Invalid Data Handling
**Objective**: Verify workflows handle invalid input gracefully

**Test Scenarios**:
```bash
# Send malformed repository dispatch
gh api repos/tuvens/tuvens-docs/dispatches \
  --method POST \
  --field event_type='branch-lifecycle' \
  --field 'client_payload[event]=invalid-event'

# Test with missing required fields
gh api repos/tuvens/tuvens-docs/dispatches \
  --method POST \
  --field event_type='branch-lifecycle' \
  --field 'client_payload[event]=created'
```

**Expected Results**:
- [ ] Workflows handle invalid data without crashing
- [ ] Error messages are logged appropriately
- [ ] System remains stable and operational

### Test 5.2: Permission Failure Handling
**Objective**: Verify graceful handling of permission issues

**Test Setup**:
- Temporarily revoke permissions to a target repository
- Trigger notification workflow

**Expected Results**:  
- [ ] Workflow continues for other repositories even if one fails
- [ ] Permission errors are logged clearly
- [ ] System doesn't crash on individual repository failures

### Test 5.3: Recovery Validation
**Objective**: Verify backup and recovery mechanisms work

**Validation Steps**:
```bash
# Check if backup files are created
ls -la agentic-development/branch-tracking/*.backup.json

# Verify recovery checkpoint mechanism
```

**Expected Results**:
- [ ] Backup files created before modifications
- [ ] Recovery files contain valid previous state
- [ ] System can recover from corruption

## Test Phase 6: Performance and Scale Testing

### Test 6.1: Large Change Set Test
**Objective**: Verify system handles large documentation updates

**Test Setup**:
```bash
# Create large documentation change
for i in {1..50}; do
  echo "# Test Document $i" > tuvens-docs/test-docs/test-$i.md
done
git add tuvens-docs/test-docs/
git commit -m "feat: add 50 test documentation files"
git push origin main
```

**Expected Results**:
- [ ] Auto-documentation workflow completes within reasonable time (<10 minutes)
- [ ] All files are processed and included in documentation tree
- [ ] Notification issues contain manageable file lists

### Test 6.2: High Frequency Event Test
**Objective**: Verify central tracking handles multiple rapid events

**Expected Results**:
- [ ] All events processed successfully
- [ ] No events lost or duplicated
- [ ] System remains responsive

## Test Phase 7: End-to-End Integration Test

### Test 7.1: Complete Workflow Test
**Objective**: Test entire system from documentation change to repository notification

**Test Scenario**:
1. Create documentation change in tuvens-docs
2. Push to main branch
3. Verify auto-documentation generates files
4. Verify notifications sent to repositories
5. Simulate repository team response
6. Verify tracking updates

**Success Criteria**:
- [ ] Complete flow executes without manual intervention
- [ ] All generated content is accurate and useful
- [ ] Repository teams receive actionable notifications
- [ ] System maintains accurate state throughout process

## Post-Test Cleanup

### Cleanup Steps
```bash
# Remove test files
git rm tuvens-docs/test-file.md
git rm -r tuvens-docs/test-integration-update/
git rm -r tuvens-docs/test-docs/
git commit -m "test: cleanup test files after workflow validation"
git push origin main

# Close test issues in consuming repositories
# Clean up test branches and tracking entries
```

## Test Report Template

After completing tests, document results:

```markdown
# Workflow Test Results

## Test Summary
- **Total Tests**: X
- **Passed**: X
- **Failed**: X  
- **Test Date**: YYYY-MM-DD
- **Tester**: [Name]

## Critical Issues Found
- [List any blocking issues]

## Recommendations
- [Actions needed before production use]

## Production Readiness Assessment
- [ ] Ready for production
- [ ] Needs minor fixes
- [ ] Needs major fixes
- [ ] Not ready for production
```

## Success Criteria for Production Release

The system is ready for production when:
- [ ] All Phase 1-3 tests pass (core functionality)
- [ ] No critical errors in Phase 5 (error handling)
- [ ] Performance meets requirements in Phase 6
- [ ] End-to-end test completes successfully in Phase 7
- [ ] All consuming repositories can receive and act on notifications
- [ ] Central tracking maintains accurate state
- [ ] Auto-documentation provides useful agent context

---

*This test plan ensures the documentation automation system works correctly in production before declaring it complete.*