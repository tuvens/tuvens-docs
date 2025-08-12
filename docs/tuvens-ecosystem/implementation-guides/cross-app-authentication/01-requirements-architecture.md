# Requirements & Architecture

## Business Requirements

### Core Problem
Enable seamless user authentication between Tuvens applications and Hi.Events ticketing platform, allowing users to:

1. **Create events in Tuvens** with their existing account
2. **Enable ticketing** without creating a separate Hi.Events account
3. **Manage tickets** on Hi.Events using their Tuvens identity
4. **Maintain security** throughout the cross-app experience

### Key User Stories

**As a Tuvens user, I want to:**
- Enable ticketing for my events without creating another account
- Have my Tuvens identity automatically recognized in Hi.Events
- Seamlessly move between Tuvens and Hi.Events interfaces
- Manage my tickets using familiar Tuvens authentication

**As a developer, I want to:**
- Implement secure cross-app authentication
- Maintain existing Tuvens authentication patterns
- Enable Hi.Events to validate Tuvens users
- Track and audit cross-app authentication events

## Technical Architecture

### System Overview
```
                    Cross-App Authentication Flow
                              
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│   Tuvens Web    │         │  Tuvens Backend │         │ Hi.Events Backend│
│   Application   │         │    (NestJS)     │         │   (External)    │
└─────────────────┘         └─────────────────┘         └─────────────────┘
         │                           │                           │
         │ 1. User clicks           │                           │
         │    "Add Ticketing"       │                           │
         │                          │                           │
         │ 2. POST /api/cross-app/  │                           │
         │    generate-session      │                           │
         ├─────────────────────────►│                           │
         │                          │ 3. Validate JWT           │
         │                          │    Generate session       │
         │                          │    Store in database      │
         │                          │                           │
         │ 4. Return session token  │                           │
         │◄─────────────────────────┤                           │
         │                          │                           │
         │ 5. Redirect to Hi.Events │                           │
         │    with session token    │                           │
         │                          │                           │
         │ 6. Hi.Events validates   │                           │
         │    token with Tuvens     │                           │
         │                          │◄──────────────────────────┤
         │                          │ 7. POST /api/cross-app/   │
         │                          │    validate-session       │
         │                          │                           │
         │                          │ 8. Return user data       │
         │                          ├──────────────────────────►│
         │                          │                           │
         │ 9. Hi.Events completes   │                           │ 
         │    user authentication   │                           │
         │◄──────────────────────────────────────────────────────┤
```

### Core Components

#### 1. Session Token Management
- **Purpose**: Generate and validate secure session tokens
- **Technology**: JWT or cryptographically secure random tokens
- **Lifetime**: 15 minutes (configurable)
- **Storage**: PostgreSQL database for tracking and revocation

#### 2. Cross-App Authentication Service
- **Responsibility**: Core business logic for cross-app auth
- **Key Methods**:
  - `generateSession(userId, accountId?)` - Create new session
  - `validateSession(token)` - Validate and return user data
  - `getUserAccounts(sessionToken)` - Get user account information
  - `validatePermission(token, permission)` - Check user permissions

#### 3. API Controller Layer
- **Endpoints**:
  - `POST /api/cross-app/generate-session` - Generate session token
  - `POST /api/cross-app/validate-session` - Validate session token
  - `GET /api/cross-app/user-accounts` - Get user accounts
  - `POST /api/cross-app/validate-permission` - Validate permissions

#### 4. Database Schema
- **Table**: `cross_app_sessions`
- **Purpose**: Track active sessions, enable revocation, audit trail
- **Key Fields**: token_hash, user_id, expires_at, created_at, used_at

## Security Architecture

### Authentication Flow Security

#### Level 1: JWT Validation
- **Purpose**: Ensure only authenticated Tuvens users can generate sessions
- **Implementation**: Validate JWT signature and expiration on session generation
- **Protection**: Prevents unauthorized session creation

#### Level 2: Session Token Security
- **Token Generation**: Cryptographically secure random 64-character strings
- **Token Signing**: Optional JWT signing with shared secret
- **Token Expiry**: 15-minute lifetime limits exposure window
- **Single Use**: Tokens can be marked as used to prevent replay attacks

#### Level 3: Backend-to-Backend Authentication
- **Shared Secret**: Hi.Events includes shared secret in validation requests
- **Request Validation**: Verify shared secret before processing validation requests
- **IP Whitelisting**: Optional IP restriction for Hi.Events requests

#### Level 4: Permission Validation
- **User Permissions**: Check user has required permissions for requested actions
- **Account Access**: Verify user has access to requested account_id
- **Resource Authorization**: Validate user can access specific resources

### Data Protection

#### In Transit
- **HTTPS Only**: All communication encrypted with TLS 1.2+
- **Certificate Validation**: Proper certificate validation on all requests
- **CORS Policy**: Strict CORS configuration for cross-origin requests

#### At Rest
- **Token Hashing**: Store hashed versions of tokens, not plaintext
- **Database Encryption**: PostgreSQL encryption at rest
- **Key Management**: Secure storage of shared secrets and JWT keys

## Scalability Considerations

### Horizontal Scaling
- **Stateless Design**: No in-memory session storage
- **Database Sessions**: All session data stored in PostgreSQL
- **Load Balancer Compatible**: Any instance can validate any session

### Performance Optimization
- **Database Indexing**: Proper indexes on token_hash and expires_at
- **Connection Pooling**: Efficient database connection management
- **Caching Strategy**: Optional Redis caching for high-volume validation

### Monitoring and Observability
- **Metrics Collection**: Track session generation, validation rates
- **Error Monitoring**: Comprehensive error tracking and alerting
- **Audit Logging**: Complete audit trail of authentication events

## Integration Points

### Existing Tuvens Systems
- **JWT Authentication**: Integrates with existing Cognito/JWT system
- **User Management**: Uses existing user and account models
- **Permission System**: Leverages existing RBAC implementation

### Hi.Events Integration
- **Validation Endpoint**: Hi.Events calls Tuvens validation API
- **User Data Format**: Standardized user data exchange format
- **Error Handling**: Consistent error response format

### Frontend Integration
- **React/Angular/Vue**: Compatible with any frontend framework
- **API Client**: Uses existing HTTP client patterns
- **Error Handling**: Integrates with existing error handling systems

## Deployment Architecture

### Development Environment
```yaml
Services:
  - tuvens-backend: localhost:3000
  - postgresql: localhost:5432
  - hi-events-mock: localhost:4000 (for testing)

Environment Variables:
  - CROSS_APP_SHARED_SECRET=dev-secret-key
  - CROSS_APP_TOKEN_EXPIRY=900
  - DATABASE_URL=postgresql://localhost/tuvens_dev
```

### Production Environment
```yaml
Services:
  - tuvens-backend: https://api.tuvens.com
  - postgresql: managed PostgreSQL instance
  - hi-events: https://tickets.tuvens.com

Environment Variables:
  - CROSS_APP_SHARED_SECRET=<secure-production-secret>
  - CROSS_APP_TOKEN_EXPIRY=900
  - DATABASE_URL=<production-db-connection>

Security:
  - TLS 1.2+ encryption
  - IP whitelisting for Hi.Events
  - Rate limiting on authentication endpoints
  - Comprehensive audit logging
```

## Compliance and Governance

### Data Privacy (GDPR/CCPA)
- **User Consent**: Clear consent for cross-app data sharing
- **Data Minimization**: Only share necessary user data with Hi.Events
- **Right to Deletion**: Support user data deletion across both systems
- **Data Portability**: Enable user data export from both systems

### Security Standards
- **OWASP Compliance**: Follow OWASP top 10 security practices
- **Token Security**: Implement secure token generation and validation
- **Authentication Standards**: Follow OAuth 2.0 and JWT best practices
- **Audit Requirements**: Maintain comprehensive audit logs

### Operational Excellence
- **Error Handling**: Graceful error handling with user-friendly messages
- **Monitoring**: Comprehensive monitoring and alerting
- **Documentation**: Complete API documentation for Hi.Events integration
- **Testing**: Comprehensive test coverage including security testing

---

**Next**: Continue with [Database Implementation](./database-implementation/README.md) to set up the required database schema.