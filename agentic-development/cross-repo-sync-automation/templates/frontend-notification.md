## 📢 URGENT: Documentation Updates Available

⚠️ **ACTION REQUIRED**: Your frontend repository needs to integrate new tuvens-docs changes.

### 📊 Update Details
- **Commit**: [COMMIT_SHA]
- **Message**: [COMMIT_MESSAGE]
- **Changed Files**: [CHANGED_FILES]
- **Repository**: [REPO_NAME]
### 🚨 Critical Changes (Review Immediately)
This update may include:
- ✨ New frontend integration patterns and standards
- 🎨 Updated Tuvens design system guidelines  
- 🔧 Enhanced component architecture standards
- 📱 Responsive design improvements
- ♿ Accessibility compliance updates
### 📋 REQUIRED ACTIONS

#### Step 1: Update tuvens-docs Documentation
```bash
# Navigate to your worktree's tuvens-docs directory
cd tuvens-docs

# Pull latest changes
git pull origin main

# Verify you have the latest version (should include [COMMIT_SHA])
git log --oneline -5

# Return to worktree root
cd ..
```
#### Step 2: Verify New Documentation Access
```bash
# Check that new documentation is available
ls -la tuvens-docs/tuvens-docs/integration-guides/
ls -la tuvens-docs/tuvens-docs/shared-protocols/
ls -la tuvens-docs/tuvens-docs/integration-examples/

# Confirm specific frontend files exist
ls -la tuvens-docs/tuvens-docs/shared-protocols/frontend-integration/README.md
ls -la tuvens-docs/tuvens-docs/integration-examples/frontend-integration/README.md
ls -la tuvens-docs/tuvens-docs/integration-guides/hi-events/frontend-integration/README.md
```
#### Step 3: Frontend-Specific Actions ⚡
- [ ] **Review Frontend Standards**: Check `shared-protocols/frontend-integration/README.md`
- [ ] **Check Component Examples**: Review `integration-examples/frontend-integration/README.md`
- [ ] **Verify Design System Compliance**: 
  - Colors: Tuvens Blue (#5C69E6), Coral (#FF5A6D), Yellow (#FFD669), Navy (#071551)
  - Typography: Montserrat font family
  - Component patterns and responsive design
- [ ] **Update Non-Compliant Components**: Fix any components not following new standards
- [ ] **Review Hi.Events Integration**: If applicable, check `integration-guides/hi-events/frontend-integration/README.md`

#### Step 4: Compliance Verification
```bash
# Run frontend compliance checks
npm ci
npm run lint
npm run typecheck
npm test -- --coverage

# Verify coverage meets 80% requirement
echo "Coverage should be ≥80%"

# Check for Tuvens design system usage
grep -r "primary-500\|secondary-500\|accent-500" src/ || echo "Design system colors in use"
```

#### Step 5: Integration Testing (If Hi.Events Integration Present)
```bash
# Test Hi.Events widget integration (if applicable)
npm run test:integration
npm run test:e2e

# Verify cross-app authentication works
# Test widget embedding functionality
```
### 🔄 MANDATORY: Confirm Completion

When you've completed all steps, **comment on this issue** with:

```
✅ **Frontend Updates Integrated Successfully**

**Repository**: [REPO_NAME]
**Updated By**: @[your-github-username]
**Completed Actions**:
- [x] ✅ Pulled latest tuvens-docs changes (commit: [COMMIT_SHA])
- [x] ✅ Verified new documentation access
- [x] ✅ Reviewed frontend standards and examples
- [x] ✅ Updated components for design system compliance
- [x] ✅ Verified 80%+ test coverage maintained
- [x] ✅ All linting and type checking passed

**Verification Commands Run**:
```bash
npm run lint    # ✅ Passed
npm run typecheck # ✅ Passed  
npm test -- --coverage # ✅ 85% coverage achieved
```

**Updated Components** (if any): [List any components updated for compliance]
**Next Steps**: [Any follow-up actions needed]
```
### ⏰ Timeline Requirements
- **Immediate** (within 4 hours): Pull changes and verify access
- **Within 24 hours**: Complete compliance verification and review requirements  
- **Within 48 hours**: Update any non-compliant components or implement missing features
- **Within 1 week**: Full integration testing and verification complete
### 🆘 Need Help?
- **Troubleshooting**: Check `tuvens-docs/tuvens-docs/shared-protocols/automated-change-notification.md`
- **Questions**: Comment on this issue for assistance- **Frontend Standards**: Review `shared-protocols/frontend-integration/README.md`
- **Design System**: Check `integration-examples/frontend-integration/README.md`
### 🤖 Optional: Enable Automated Verification
For automatic verification when you comment with completion status, install our workflow:
```bash
# One-time setup (only if not already installed)
mkdir -p .github/workflows
curl -o .github/workflows/verify-tuvens-docs.yml \
  https://raw.githubusercontent.com/tuvens/tuvens-docs/main/agentic-development/cross-repo-sync-automation/templates/repository-verification-workflow.yml
git add .github/workflows/verify-tuvens-docs.yml
git commit -m "Add automated tuvens-docs verification workflow"
```
This workflow will automatically verify your integration and close this issue when you comment with completion confirmation.
### 📈 Quality Standards
Your repository must maintain:
- ✅ **Test Coverage**: ≥80% (required)
- ✅ **TypeScript**: Strict mode compliance
- ✅ **Linting**: Zero ESLint errors
- ✅ **Design System**: Tuvens color palette and typography
- ✅ **Accessibility**: WCAG 2.1 AA compliance
- ✅ **Performance**: Lighthouse score >90
---
**This issue will remain open until confirmation is received and verification passes**

*🤖 This notification was automatically generated when tuvens-docs was updated. Claude Code will detect this issue and help integrate the changes during normal development workflows.*