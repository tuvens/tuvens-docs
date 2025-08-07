## 📢 URGENT: Documentation Updates Available

⚠️ **ACTION REQUIRED**: Your mobile repository needs to integrate new tuvens-docs changes.

### 📊 Update Details
- **Commit**: [COMMIT_SHA]
- **Message**: [COMMIT_MESSAGE]
- **Changed Files**: [CHANGED_FILES]
- **Repository**: [REPO_NAME]

### 🚨 Critical Changes (Review Immediately)
This update may include:
- 📱 New mobile integration patterns and standards
- 🎨 Updated Tuvens design system for mobile
- 🔧 Enhanced mobile component architecture
- 🚀 Performance optimization guidelines
- 📍 Location services and geo-fencing updates
- 🔐 Cross-app authentication patterns

### 📋 REQUIRED ACTIONS

#### Step 1: Update Your Local tuvens-docs
```bash
# Navigate to YOUR repository's tuvens-docs directory
cd mobile/tuvens-docs/tuvens-docs
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

# Confirm specific mobile-relevant files exist
ls -la shared-protocols/frontend-integration/README.md
ls -la integration-examples/frontend-integration/README.md
ls -la implementation-guides/cross-app-authentication/README.md
```

#### Step 3: Mobile-Specific Actions ⚡
- [ ] **Review Mobile Standards**: Check mobile-relevant sections in `shared-protocols/`
- [ ] **Check Authentication Updates**: Review `implementation-guides/cross-app-authentication/README.md`
- [ ] **Verify Design System Compliance**: 
  - Colors: Tuvens Blue (#5C69E6), Coral (#FF5A6D), Yellow (#FFD669), Navy (#071551)
  - Typography: System fonts for mobile (SF Pro, Roboto)
  - Mobile-responsive patterns and touch interfaces
- [ ] **Update Non-Compliant Components**: Fix any components not following new standards
- [ ] **Review Location Services**: Check any geo-fencing and location-based feature updates

#### Step 4: Compliance Verification
```bash
# Run mobile development checks
npm ci
npm run lint
npm run typecheck
npm test -- --coverage

# Verify coverage meets 70% requirement (mobile-adjusted)
echo "Coverage should be ≥70%"

# Check for Tuvens design system usage in mobile
grep -r "primary\|secondary\|accent" src/styles/ || echo "Design system in use"

# Test mobile-specific functionality
npm run test:ios     # If iOS tests available
npm run test:android # If Android tests available
```

#### Step 5: Platform Testing (If Applicable)
```bash
# Test React Native functionality (if applicable)
npx react-native doctor
npx react-native run-ios --simulator="iPhone 14"
npx react-native run-android

# Test Flutter functionality (if applicable) 
flutter doctor
flutter test
flutter build apk --debug

# Verify cross-app authentication works
# Test location-based features
```

### 🔄 MANDATORY: Confirm Completion

When you've completed all steps, **comment on this issue** with:

```
✅ **Mobile Updates Integrated Successfully**

**Repository**: [REPO_NAME]
**Updated By**: @[your-github-username]
**Completed Actions**:
- [x] ✅ Pulled latest tuvens-docs changes (commit: [COMMIT_SHA])
- [x] ✅ Verified new documentation access
- [x] ✅ Reviewed mobile standards and patterns
- [x] ✅ Updated components for design system compliance
- [x] ✅ Verified 70%+ test coverage maintained
- [x] ✅ All linting and type checking passed

**Verification Commands Run**:
```bash
npm run lint         # ✅ Passed
npm run typecheck    # ✅ Passed  
npm test -- --coverage # ✅ 75% coverage achieved
```

**Updated Components** (if any): [List any components updated for compliance]
**Platform Testing**: [iOS/Android/Flutter testing results]
**Next Steps**: [Any follow-up actions needed]
```

### ⏰ Timeline Requirements
- **Immediate** (within 4 hours): Pull changes and verify access
- **Within 24 hours**: Complete compliance verification
- **Within 48 hours**: Update any non-compliant components
- **Within 1 week**: Full platform testing complete

### 🆘 Need Help?
- **Troubleshooting**: Check `shared-protocols/automated-change-notification.md`
- **Mobile Standards**: Review mobile-relevant sections in `shared-protocols/`
- **Authentication**: Check `implementation-guides/cross-app-authentication/README.md`
- **Questions**: Comment on this issue for assistance

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
This workflow will automatically verify your integration and close this issue when you comment with "✅ Mobile Updates Integrated Successfully".

### 📈 Quality Standards
Your mobile repository must maintain:
- ✅ **Test Coverage**: ≥70% (mobile-adjusted)
- ✅ **TypeScript**: Strict mode compliance (if applicable)
- ✅ **Linting**: Zero ESLint/Flutter analyzer errors
- ✅ **Design System**: Tuvens mobile color palette and typography
- ✅ **Performance**: Smooth 60fps animations
- ✅ **Platform Compliance**: iOS App Store & Google Play guidelines

---
**This issue will remain open until confirmation is received and verification passes**

*🤖 This notification was automatically generated when tuvens-docs was updated. Claude Code will detect this issue and help integrate the changes during mobile development workflows.*