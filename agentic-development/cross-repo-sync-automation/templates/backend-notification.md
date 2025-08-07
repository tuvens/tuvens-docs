## 📢 URGENT: Documentation Updates Available

⚠️ **ACTION REQUIRED**: Your backend repository needs to integrate new tuvens-docs changes.

### 📊 Update Details
- **Commit**: [COMMIT_SHA]
- **Message**: [COMMIT_MESSAGE]
- **Changed Files**: [CHANGED_FILES]
- **Repository**: [REPO_NAME]
### 🚨 Critical Changes (Review Immediately)
This update may include:
- 🔐 Cross-app authentication implementation updates
- 📡 New API endpoint specifications
- 🛡️ Security protocol enhancements
- 🏗️ Database schema changes
- 📋 Backend integration patterns
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
ls -la tuvens-docs/tuvens-docs/implementation-guides/
ls -la tuvens-docs/tuvens-docs/integration-guides/
ls -la tuvens-docs/tuvens-docs/shared-protocols/

# Confirm specific backend files exist
ls -la tuvens-docs/tuvens-docs/implementation-guides/cross-app-authentication/README.md
ls -la tuvens-docs/tuvens-docs/integration-guides/hi-events/api-requirements.md
ls -la tuvens-docs/agentic-development/workflows/cross-repository-development/README.md
```
#### Step 3: Backend-Specific Actions ⚡
- [ ] **Review Cross-App Authentication**: Study `implementation-guides/cross-app-authentication/README.md`
- [ ] **Check API Requirements**: Review `integration-guides/hi-events/api-requirements.md`
- [ ] **Verify Required Endpoints**: Ensure these endpoints exist and match specifications:
  - `POST /api/cross-app/generate-session`
  - `POST /api/cross-app/validate-session`
  - `GET /api/cross-app/user-accounts`
  - `POST /api/cross-app/validate-permission`
- [ ] **Database Schema Review**: Check `implementation-guides/cross-app-authentication/database-implementation/README.md`
- [ ] **Security Protocols**: Review authentication security requirements

#### Step 4: Implementation Verification
```bash
# Check if cross-app endpoints exist
npm run dev &
sleep 5

# Test endpoint availability (should return 404 or proper error, not 500)
curl -X POST http://localhost:3000/api/cross-app/generate-session \
  -H "Content-Type: application/json" \
  -d '{"test": true}'

curl -X POST http://localhost:3000/api/cross-app/validate-session \
  -H "Content-Type: application/json" \
  -d '{"test": true}'

# Stop development server
pkill -f "npm run dev"
```

#### Step 5: Database and Security Compliance
```bash
# Run backend compliance checks
npm ci
npm run lint
npm run typecheck
npm test

# Check database migrations (if applicable)
npm run migration:show # or your migration command

# Verify security scanning
npm audit --audit-level high
```

#### Step 6: Integration Testing
```bash
# Test cross-app authentication flow (if implemented)
npm run test:integration

# Test API endpoints with proper authentication
npm run test:api

# Verify security requirements
npm run test:security
```
### 🔄 MANDATORY: Confirm Completion

When you've completed all steps, **comment on this issue** with:

```
✅ **Backend Updates Integrated Successfully**

**Repository**: [REPO_NAME]
**Updated By**: @[your-github-username]
**Completed Actions**:
- [x] ✅ Pulled latest tuvens-docs changes (commit: [COMMIT_SHA])
- [x] ✅ Verified new documentation access
- [x] ✅ Reviewed cross-app authentication implementation
- [x] ✅ Verified API endpoint specifications
- [x] ✅ Checked database schema requirements
- [x] ✅ All tests passing with security compliance

**API Endpoint Status**:
- [x] `POST /api/cross-app/generate-session` - ✅ Implemented / ❌ Missing
- [x] `POST /api/cross-app/validate-session` - ✅ Implemented / ❌ Missing  
- [x] `GET /api/cross-app/user-accounts` - ✅ Implemented / ❌ Missing
- [x] `POST /api/cross-app/validate-permission` - ✅ Implemented / ❌ Missing

**Verification Commands Run**:
```bash
npm run lint         # ✅ Passed
npm run typecheck    # ✅ Passed
npm test             # ✅ All tests passing
npm audit            # ✅ No high/critical vulnerabilities
```

**Database Changes** (if any): [List any schema updates made]
**Security Updates** (if any): [List any security enhancements]
**Next Steps**: [Any follow-up actions needed]
```
### ⏰ Timeline Requirements
- **Immediate** (within 4 hours): Pull changes and verify access
- **Within 24 hours**: Complete compliance verification and review requirements  
- **Within 48 hours**: Update any non-compliant components or implement missing features
- **Within 1 week**: Full integration testing and verification complete
### 🆘 Need Help?
- **Troubleshooting**: Check `tuvens-docs/tuvens-docs/shared-protocols/automated-change-notification.md`
- **Questions**: Comment on this issue for assistance- **Implementation Guide**: Follow `implementation-guides/cross-app-authentication/README.md`
- **API Specifications**: Review `integration-guides/hi-events/api-requirements.md`
- **Development Standards**: Check `agentic-development/workflows/cross-repository-development/README.md`
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
Your backend must maintain:
- ✅ **Security**: All authentication endpoints properly secured
- ✅ **Testing**: 80%+ test coverage including integration tests
- ✅ **TypeScript**: Strict mode compliance with proper typing
- ✅ **API Standards**: RESTful design with consistent error handling
- ✅ **Performance**: Response times <200ms for auth endpoints
- ✅ **Documentation**: All endpoints documented with examples

### 🔐 Security Checklist
- [ ] JWT validation on all protected endpoints
- [ ] Input validation and sanitization
- [ ] Rate limiting on authentication endpoints
- [ ] Secure session token generation
- [ ] Proper CORS configuration
- [ ] Audit logging for authentication events
---
**This issue will remain open until confirmation is received and verification passes**

*🤖 This notification was automatically generated when tuvens-docs was updated. Claude Code will detect this issue and help integrate the changes during normal development workflows.*