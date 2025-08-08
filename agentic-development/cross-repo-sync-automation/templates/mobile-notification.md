## 📢 URGENT: Documentation Updates Available

⚠️ **ACTION REQUIRED**: Your mobile repository needs to integrate new tuvens-docs changes.

### 📊 Update Details
- **Commit**: [COMMIT_SHA]
- **Message**: [COMMIT_MESSAGE]
- **Changed Files**: [CHANGED_FILES]
- **Repository**: [REPO_NAME]

### 🚨 Critical Changes (Review Immediately)
This update may include:
- 📱 New mobile development patterns and standards
- 🗺️ Updated Mapbox integration guidelines
- 🎨 Updated Tuvens design system for mobile
- 🔧 Enhanced Flutter component architecture
- 🚀 Performance optimization guidelines
- 📍 Location services and permissions updates
- 🔐 Cross-app authentication patterns
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
ls -la tuvens-docs/tuvens-docs/shared-protocols/mobile-development/
ls -la tuvens-docs/tuvens-docs/integration-guides/mapbox/
ls -la tuvens-docs/.claude/agents/mobile-dev.md

# Confirm mobile-specific files exist
ls -la tuvens-docs/tuvens-docs/shared-protocols/mobile-development/README.md
ls -la tuvens-docs/tuvens-docs/shared-protocols/mobile-development/README.md
```

#### Step 3: Mobile-Specific Actions ⚡
- [ ] **Review Mobile Standards**: Check `tuvens-docs/tuvens-docs/shared-protocols/mobile-development/README.md`
- [ ] **Flutter Architecture**: Review Flutter app structure and patterns
- [ ] **Mapbox Integration**: Verify map functionality follows guidelines
- [ ] **Performance Standards**: Ensure 60fps target and efficient memory usage
- [ ] **Platform Compliance**: Check iOS 13+ and Android API 26+ requirements
- [ ] **API Integration**: Verify Tuvens API usage follows mobile patterns

#### Step 4: Development Environment Verification
```bash
# Verify Flutter environment
flutter doctor

# Check dependencies
flutter pub get

# Run tests with coverage
flutter test --coverage
lcov --summary coverage/lcov.info

# Platform-specific builds
flutter build ios --debug
flutter build android --debug
```

#### Step 5: Mobile Testing Requirements
```bash
# Unit tests for core logic
flutter test test/unit/

# Widget tests for UI components
flutter test test/widget/

# Integration tests for user flows
flutter test integration_test/

# Platform-specific testing
# iOS: Test on simulator and physical device
# Android: Test on emulator and physical device
```
### 🔄 MANDATORY: Confirm Completion

When you've completed all steps, **comment on this issue** with:

```
✅ **Mobile Updates Integrated Successfully**

**Repository**: [REPO_NAME]
**Updated By**: @[your-github-username]
**Completed Actions**:
- [x] ✅ Pulled latest tuvens-docs changes (commit: [COMMIT_SHA])
- [x] ✅ Verified new mobile documentation access
- [x] ✅ Reviewed mobile development standards
- [x] ✅ Updated Flutter app following new guidelines
- [x] ✅ Verified Mapbox integration compliance
- [x] ✅ Achieved 70%+ test coverage maintained
- [x] ✅ All platform builds successful

**Testing Results**:
```bash
flutter test --coverage     # ✅ 75% coverage achieved
flutter build ios          # ✅ iOS build successful
flutter build android      # ✅ Android build successful
flutter doctor             # ✅ No issues found
```

**Performance Verification**:
- [x] App startup time: < 3 seconds
- [x] 60fps maintained during scrolling
- [x] Memory usage optimized
- [x] Battery usage minimal

**Platform Testing**:
- [x] iOS 13+ compatibility verified
- [x] Android API 26+ compatibility verified
- [x] Mapbox functionality tested on both platforms
- [x] Location permissions working correctly

**Updated Components** (if any): [List any Flutter widgets or services updated]
**Performance Improvements** (if any): [List any optimizations made]
**Next Steps**: [Any follow-up mobile development tasks needed]
```

### ⏰ Timeline Requirements
- **Immediate** (within 4 hours): Pull changes and verify access
- **Within 24 hours**: Complete mobile standards compliance verification
- **Within 48 hours**: Update any non-compliant Flutter components
- **Within 1 week**: Full platform testing and performance optimization complete

### 🆘 Need Help?
- **Mobile Standards**: Review `tuvens-docs/tuvens-docs/shared-protocols/mobile-development/README.md`
- **Flutter Patterns**: Check Flutter-specific documentation
- **Mapbox Integration**: See `tuvens-docs/tuvens-docs/integration-guides/mapbox/README.md`
- **Agent Context**: Load `tuvens-docs/.claude/agents/mobile-dev.md`
- **Questions**: Comment on this issue for assistance

### 📈 Mobile Quality Standards
Your Flutter app must maintain:
- ✅ **Test Coverage**: ≥70% (mobile-optimized requirement)
- ✅ **Performance**: 60fps target, <3s startup time
- ✅ **Platform Support**: iOS 13+, Android API 26+
- ✅ **Memory Usage**: <100MB typical usage
- ✅ **Battery Efficiency**: Minimal background activity
- ✅ **User Experience**: Smooth animations and responsive UI

### 📱 Mobile Development Checklist
- [ ] Flutter version compatibility verified
- [ ] Mapbox SDK properly configured
- [ ] Location permissions implemented correctly
- [ ] Push notifications working (if applicable)
- [ ] Offline functionality tested
- [ ] API integration following mobile patterns
- [ ] UI responsive across different screen sizes
- [ ] Accessibility features implemented
---
**This issue will remain open until confirmation is received and verification passes**

*🤖 This notification was automatically generated when tuvens-docs was updated. Claude Code will detect this issue and help integrate the changes during normal development workflows.*