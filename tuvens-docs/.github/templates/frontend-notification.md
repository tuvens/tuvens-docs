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

#### Step 1: Update Your Local tuvens-docs
```bash
# Navigate to YOUR repository's tuvens-docs directory
cd client/tuvens-docs/tuvens-docs
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
ls -la shared-protocols/
ls -la integration-examples/

# Confirm specific frontend files exist
ls -la shared-protocols/general-frontend-integration.md
ls -la integration-examples/frontend-integration/README.md
ls -la integration-guides/hi-events/frontend-integration.md
```

#### Step 3: Frontend-Specific Actions ⚡
- [ ] **Review Frontend Standards**: Check `shared-protocols/general-frontend-integration.md`
- [ ] **Check Component Examples**: Review `integration-examples/frontend-integration/README.md`
- [ ] **Verify Design System Compliance**: 
  - Colors: Tuvens Blue (#5C69E6), Coral (#FF5A6D), Yellow (#FFD669), Navy (#071551)
  - Typography: Montserrat font family
  - Component patterns and responsive design
- [ ] **Update Non-Compliant Components**: Fix any components not following new standards
- [ ] **Review Hi.Events Integration**: If applicable, check `integration-guides/hi-events/frontend-integration.md`

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
- **Within 24 hours**: Complete compliance verification
- **Within 48 hours**: Update any non-compliant components
- **Within 1 week**: Full integration testing complete

### 🆘 Need Help?
- **Troubleshooting**: Check `shared-protocols/automated-change-notification.md`
- **Frontend Standards**: Review `shared-protocols/general-frontend-integration.md`
- **Design System**: Check `integration-examples/frontend-integration/README.md`
- **Questions**: Comment on this issue for assistance

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