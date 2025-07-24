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

#### Step 1: Update Your Local tuvens-docs
```bash
# Navigate to YOUR repository's tuvens-docs directory
cd docs/shared-templates
# OR: cd path/to/tuvens-docs (if using copy method)

# Pull latest changes
git pull origin main

# Verify you have the latest version
git log --oneline -5
```

#### Step 2: Verify New Documentation Access
```bash
# Check that new documentation is available
ls -la implementation-guides/
ls -la integration-guides/
ls -la shared-protocols/

# Confirm specific backend files exist
ls -la implementation-guides/cross-app-authentication/README.md
ls -la integration-guides/hi-events/api-requirements.md
ls -la shared-protocols/cross-repository-development.md
```

#### Step 3: Backend-Specific Actions ⚡
- [ ] **Review Cross-App Authentication**: Study `implementation-guides/cross-app-authentication/README.md`
- [ ] **Check API Requirements**: Review `integration-guides/hi-events/api-requirements.md`
- [ ] **Verify Required Endpoints**: Ensure these endpoints exist and match specifications:
  - `POST /api/cross-app/generate-session`
  - `POST /api/cross-app/validate-session`
  - `GET /api/cross-app/user-accounts`
  - `POST /api/cross-app/validate-permission`
- [ ] **Database Schema Review**: Check `implementation-guides/cross-app-authentication/02-database-implementation.md`
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
- **Within 24 hours**: Review implementation requirements
- **Within 48 hours**: Implement missing endpoints (if any)
- **Within 1 week**: Full integration testing and security compliance

### 🆘 Need Help?
- **Implementation Guide**: Follow `implementation-guides/cross-app-authentication/README.md`
- **API Specifications**: Review `integration-guides/hi-events/api-requirements.md`
- **Development Standards**: Check `shared-protocols/cross-repository-development.md`
- **Troubleshooting**: See `shared-protocols/automated-change-notification.md`
- **Questions**: Comment on this issue for assistance

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