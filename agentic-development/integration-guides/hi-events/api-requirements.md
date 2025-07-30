# Hi.Events Integration - API Requirements

## Overview

This document outlines the required API endpoints that must be implemented in Tuvens backend services to support Hi.Events ticketing integration.

## Problem Context

The Hi.Events ticketing integration requires specific backend API endpoints for cross-app authentication and session management. These endpoints enable secure communication between Tuvens frontend applications and the Hi.Events ticketing system.

## Required API Endpoints

### 1. Generate Session Token Endpoint

**Endpoint:** `POST /api/cross-app/generate-session`

**Purpose:** Generate a secure session token for cross-app authentication between Tuvens and Hi.Events

**Authentication:** Requires valid JWT token in Authorization header

**Request Headers:**
```
Authorization: Bearer <JWT_TOKEN>
Content-Type: application/json
```

**Request Body:**
```json
{
  "account_id": number | null
}
```

**Success Response (200):**
```json
{
  "session_token": "string", // JWT or secure token
  "expires_at": "2025-07-23T21:00:00.000Z", // ISO timestamp
  "account_id": number | null
}
```

**Error Responses:**
```json
// 401 Unauthorized
{
  "error": "Unauthorized",
  "message": "Valid JWT token required"
}

// 403 Forbidden
{
  "error": "Forbidden", 
  "message": "Insufficient permissions for account"
}

// 500 Internal Server Error
{
  "error": "Internal Server Error",
  "message": "Failed to generate session token"
}
```

**Implementation Requirements:**
- Generate a secure, time-limited session token (recommend 15-minute expiration)
- Token should contain authenticated user information
- Token should be verifiable by Hi.Events (if cross-app auth is implemented)
- Validate that the requesting user is authenticated via JWT
- Include user/account information in token payload
- Use cryptographically secure token generation

### 2. Session Token Validation Endpoint

**Endpoint:** `POST /api/cross-app/validate-session`

**Purpose:** Allow Hi.Events to validate session tokens and retrieve user information

**Request Body:**
```json
{
  "session_token": "string"
}
```

**Success Response (200):**
```json
{
  "valid": true,
  "user_data": {
    "account_id": number,
    "email": "string",
    "name": "string",
    "permissions": ["create_events", "manage_ticketing"]
  },
  "expires_at": "2025-07-23T21:00:00.000Z"
}
```

**Invalid Token Response (400):**
```json
{
  "valid": false,
  "error": "Invalid or expired session token"
}
```

### 3. User Accounts Endpoint

**Endpoint:** `GET /api/cross-app/user-accounts`

**Purpose:** Allow Hi.Events to retrieve user account information during authentication

**Authentication:** Requires session token validation

**Request Headers:**
```
X-Session-Token: <SESSION_TOKEN>
```

**Success Response (200):**
```json
{
  "accounts": [
    {
      "account_id": number,
      "name": "string",
      "email": "string",
      "role": "string",
      "permissions": ["create_events", "manage_ticketing"]
    }
  ]
}
```

### 4. Permission Validation Endpoint

**Endpoint:** `POST /api/cross-app/validate-permission`

**Purpose:** Allow Hi.Events to validate specific user permissions

**Request Body:**
```json
{
  "session_token": "string",
  "permission": "string", // e.g., "manage_ticketing"
  "resource_id": "string" // optional - specific event ID
}
```

**Success Response (200):**
```json
{
  "valid": true,
  "permission": "manage_ticketing",
  "granted": true
}
```

## Integration Flow

1. **User Authentication**
   - User must be authenticated in Tuvens with valid JWT token
   - JWT token contains user identity and permissions

2. **Session Token Generation**
   - Frontend calls `POST /api/cross-app/generate-session` with user's account ID
   - Backend validates JWT, generates secure session token
   - Session token contains user information and expires in 15 minutes

3. **Cross-App Redirect**
   - Frontend redirects to Hi.Events with session token and event data
   - Hi.Events receives token and validates it with Tuvens backend

4. **Token Validation**
   - Hi.Events calls `POST /api/cross-app/validate-session` 
   - Tuvens backend validates token and returns user information
   - Hi.Events creates/authenticates user based on Tuvens data

5. **Ongoing Authorization**
   - Hi.Events can validate permissions via `POST /api/cross-app/validate-permission`
   - Hi.Events can retrieve updated account info via `GET /api/cross-app/user-accounts`

## Security Requirements

### Token Security
- Use cryptographically secure random token generation
- Include expiration timestamp in token payload
- Sign tokens with shared secret or use JWT with RS256
- Implement single-use tokens where possible

### Authentication
- Verify JWT tokens on all endpoints
- Validate user permissions for requested account_id
- Implement rate limiting on token generation
- Log all cross-app authentication attempts

### CORS Configuration
```javascript
// Allow Hi.Events domain for cross-app requests
{
  origin: ['https://tickets.tuvens.com', 'https://hi.events'],
  credentials: true,
  methods: ['GET', 'POST'],
  allowedHeaders: ['Authorization', 'Content-Type', 'X-Session-Token']
}
```

## Database Schema

### Session Tokens Table (Optional)
If storing session tokens for tracking/revocation:

```sql
CREATE TABLE cross_app_session_tokens (
  id SERIAL PRIMARY KEY,
  token_hash VARCHAR(255) NOT NULL UNIQUE,
  user_id INTEGER NOT NULL,
  account_id INTEGER,
  expires_at TIMESTAMP NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  used_at TIMESTAMP,
  revoked_at TIMESTAMP,
  source_app VARCHAR(50) DEFAULT 'tuvens',
  target_app VARCHAR(50) DEFAULT 'hi-events'
);

CREATE INDEX idx_session_tokens_hash ON cross_app_session_tokens(token_hash);
CREATE INDEX idx_session_tokens_expires ON cross_app_session_tokens(expires_at);
```

### Event Integration Tracking
```sql
-- Add to existing events table
ALTER TABLE events ADD COLUMN has_ticketing BOOLEAN DEFAULT FALSE;
ALTER TABLE events ADD COLUMN hi_events_event_id VARCHAR(255);
ALTER TABLE events ADD COLUMN ticketing_enabled_at TIMESTAMP;
ALTER TABLE events ADD COLUMN ticketing_enabled_by INTEGER REFERENCES users(id);
```

## Environment Configuration

Required environment variables:

```bash
# Cross-app authentication
CROSS_APP_SHARED_SECRET=your-secure-shared-secret
CROSS_APP_TOKEN_EXPIRY=900 # 15 minutes in seconds
HI_EVENTS_DOMAIN=tickets.tuvens.com

# JWT configuration (if not already configured)
JWT_SECRET=your-jwt-secret
JWT_EXPIRY=86400 # 24 hours
```

## Testing

### Unit Tests
```bash
# Test session token generation
POST /api/cross-app/generate-session
- Valid JWT + valid account_id → 200 with token
- Valid JWT + invalid account_id → 403 Forbidden
- Invalid JWT → 401 Unauthorized
- Missing account_id → 200 with user's default account

# Test session validation
POST /api/cross-app/validate-session
- Valid unexpired token → 200 with user data
- Expired token → 400 Invalid token
- Invalid token → 400 Invalid token
- Missing token → 400 Invalid token
```

### Integration Tests
```bash
# Test full cross-app flow
1. Authenticate user and get JWT
2. Generate session token with JWT
3. Validate session token returns correct user data
4. Verify token expires after configured time
5. Test permission validation for different user roles
```

## Monitoring and Logging

### Metrics to Track
- Session token generation rate
- Token validation success/failure rate
- Cross-app authentication attempts
- Token expiration and cleanup

### Security Logging
- All failed authentication attempts
- Suspicious token generation patterns
- Cross-app permission validation failures
- Token usage outside expected timeframes

## Error Handling

### Client-Side Integration
Frontend should handle these scenarios:
- Token generation failure → Show error, retry option
- Network errors → Graceful degradation, offline message
- Permission errors → Clear user guidance

### Backend Error Responses
All endpoints should return consistent error format:
```json
{
  "error": "string", // Error type
  "message": "string", // Human-readable message
  "code": "string", // Optional error code
  "timestamp": "ISO string"
}
```

## Future Enhancements

### Webhook Support
Consider implementing webhooks for Hi.Events to notify Tuvens of:
- Event creation completion
- Ticket sales updates
- Event modifications
- User account changes

### Enhanced Security
- Implement token rotation
- Add IP validation
- Implement device fingerprinting
- Add audit trail for all cross-app operations