# Hi.Events Cross-App Authentication Flow

## Overview

This document describes the authentication flow between Tuvens applications and Hi.Events, enabling seamless user experience across both platforms while maintaining security.

## Flow Diagram

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Tuvens    │    │   Tuvens    │    │ Hi.Events   │
│  Frontend   │    │   Backend   │    │   Backend   │
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       │ 1. User clicks    │                   │
       │ "Add Ticketing"   │                   │
       │                   │                   │
       │ 2. POST /api/     │                   │
       │    cross-app/     │                   │
       │    generate-      │                   │
       │    session        │                   │
       ├──────────────────►│                   │
       │                   │                   │
       │ 3. Generate       │                   │
       │    secure token   │                   │
       │                   │                   │
       │ 4. Return token   │                   │
       │    + expiry       │                   │
       │◄──────────────────┤                   │
       │                   │                   │
       │ 5. Redirect to    │                   │
       │    Hi.Events with │                   │
       │    token + data   │                   │
       │                   │                   │
       │ 6. Hi.Events      │                   │
       │    receives       │                   │
       │    request        │                   │
       ├──────────────────────────────────────►│
       │                   │                   │
       │                   │ 7. POST /api/     │
       │                   │    cross-app/     │
       │                   │    validate-      │
       │                   │    session        │
       │                   │◄──────────────────┤
       │                   │                   │
       │                   │ 8. Return user    │
       │                   │    data if valid  │
       │                   ├──────────────────►│
       │                   │                   │
       │                   │                   │ 9. Create/auth
       │                   │                   │    user in
       │                   │                   │    Hi.Events
       │                   │                   │
       │ 10. Hi.Events     │                   │
       │     processing    │                   │
       │     complete      │                   │
       │◄──────────────────────────────────────┤
       │                   │                   │
       │ 11. Callback to   │                   │
       │     Tuvens with   │                   │
       │     results       │                   │
```

## Step-by-Step Process

### Step 1: User Initiates Ticketing
- User is already authenticated in Tuvens (has valid JWT)
- User clicks "Add Ticketing" button on event page
- Frontend validates user has permission to enable ticketing

### Step 2: Session Token Generation Request
**Frontend → Tuvens Backend**

```typescript
POST /api/cross-app/generate-session
Headers: {
  Authorization: "Bearer <JWT_TOKEN>",
  Content-Type: "application/json"
}
Body: {
  account_id: 123 // optional - user's account ID
}
```

### Step 3: Backend Validates and Generates Token
**Tuvens Backend Processing:**

1. **JWT Validation**: Verify the JWT token is valid and not expired
2. **User Authorization**: Confirm user has permission to create sessions
3. **Account Validation**: If account_id provided, verify user has access
4. **Token Generation**: Create secure session token with user data
5. **Database Storage**: Optionally store token hash for tracking/revocation

```typescript
// Token payload example
{
  user_id: 456,
  account_id: 123,
  email: "user@example.com",
  name: "John Doe",
  permissions: ["create_events", "manage_ticketing"],
  iat: 1642681200, // issued at
  exp: 1642682100  // expires in 15 minutes
}
```

### Step 4: Return Session Token
**Tuvens Backend → Frontend**

```json
{
  "session_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expires_at": "2025-07-24T15:15:00.000Z",
  "account_id": 123
}
```

### Step 5: Redirect to Hi.Events
**Frontend Processing:**

```typescript
// Build redirect URL with session token and event data
const redirectUrl = `https://tickets.tuvens.com/auth/cross-app?${new URLSearchParams({
  session_token: sessionToken,
  action: 'create_event',
  source: 'tuvens',
  event_data: JSON.stringify({
    title: "Sample Event",
    description: "Event description",
    start_date: "2025-08-01T19:00:00Z",
    end_date: "2025-08-01T23:00:00Z",
    location_details: {
      venue_name: "Event Venue"
    }
  }),
  callback_url: `${window.location.origin}/hi-events/callback`
})}`;

// Open in new window/tab
window.open(redirectUrl, '_blank');
```

### Step 6: Hi.Events Receives Request
**Hi.Events Frontend Processing:**

1. **Parse URL Parameters**: Extract session_token, event_data, etc.
2. **Display Loading State**: Show user that authentication is in progress
3. **Validate Session**: Call Tuvens backend to validate the session token

### Step 7: Hi.Events Validates Session Token
**Hi.Events Backend → Tuvens Backend**

```typescript
POST /api/cross-app/validate-session
Headers: {
  Content-Type: "application/json",
  X-Shared-Secret: "<SHARED_SECRET>" // For backend-to-backend auth
}
Body: {
  session_token: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Step 8: Tuvens Returns User Data
**Tuvens Backend → Hi.Events Backend**

```json
{
  "valid": true,
  "user_data": {
    "account_id": 123,
    "email": "user@example.com",
    "name": "John Doe",
    "permissions": ["create_events", "manage_ticketing"]
  },
  "expires_at": "2025-07-24T15:15:00.000Z"
}
```

### Step 9: Hi.Events User Authentication
**Hi.Events Backend Processing:**

1. **User Lookup**: Check if user exists in Hi.Events database
2. **User Creation**: If new user, create account with Tuvens data
3. **User Authentication**: Generate Hi.Events session for the user
4. **Event Processing**: Process the event data from Tuvens

### Step 10: Hi.Events Event Creation
**Hi.Events Processing:**

1. **Event Validation**: Validate event data structure
2. **Event Creation**: Create event in Hi.Events database
3. **Link Establishment**: Link Hi.Events event to Tuvens event
4. **Response Preparation**: Prepare success/failure response

### Step 11: Callback to Tuvens
**Hi.Events → Tuvens Frontend**

```typescript
// Redirect to Tuvens callback URL
const callbackUrl = `${tuvensCallbackUrl}?${new URLSearchParams({
  success: 'true',
  tuvens_event_id: '789',
  hi_events_event_id: 'he_123456',
  message: 'Event created successfully'
})}`;

window.location.href = callbackUrl;
```

## Security Measures

### Token Security
- **Short Expiry**: 15-minute token lifetime limits exposure
- **Cryptographic Signing**: Tokens signed with secure shared secret
- **Single Use**: Tokens can be marked as used to prevent replay
- **Secure Generation**: Use cryptographically secure random generation

### Authentication Validation
- **JWT Verification**: All requests validate JWT signatures
- **Permission Checks**: Verify user has required permissions
- **Rate Limiting**: Prevent token generation abuse
- **Audit Logging**: Log all authentication attempts

### Transport Security
- **HTTPS Only**: All communication over encrypted connections
- **CORS Configuration**: Strict CORS policies for cross-origin requests
- **Header Validation**: Validate all required headers present

## Error Handling

### Frontend Error States
```typescript
enum AuthFlowError {
  TOKEN_GENERATION_FAILED = 'token_generation_failed',
  TOKEN_EXPIRED = 'token_expired',
  PERMISSION_DENIED = 'permission_denied',
  NETWORK_ERROR = 'network_error',
  HI_EVENTS_ERROR = 'hi_events_error',
  CALLBACK_ERROR = 'callback_error'
}

// Error handling in frontend
const handleAuthError = (error: AuthFlowError, details?: string) => {
  switch (error) {
    case AuthFlowError.TOKEN_GENERATION_FAILED:
      showError('Failed to generate authentication token. Please try again.');
      break;
    case AuthFlowError.PERMISSION_DENIED:
      showError('You do not have permission to enable ticketing for this event.');
      break;
    case AuthFlowError.TOKEN_EXPIRED:
      showError('Authentication session expired. Please try again.');
      break;
    // ... handle other error cases
  }
};
```

### Backend Error Responses
```typescript
// Consistent error response format
interface ErrorResponse {
  error: string;
  message: string;
  code?: string;
  timestamp: string;
  details?: any;
}

// Example error responses
{
  "error": "Unauthorized",
  "message": "Valid JWT token required",
  "code": "JWT_REQUIRED",
  "timestamp": "2025-07-24T14:30:00.000Z"
}

{
  "error": "Forbidden",
  "message": "Insufficient permissions for account",
  "code": "INSUFFICIENT_PERMISSIONS",
  "timestamp": "2025-07-24T14:30:00.000Z"
}
```

## Monitoring and Analytics

### Key Metrics to Track
- Session token generation rate
- Token validation success/failure rate
- Authentication flow completion rate
- Average time for complete flow
- Error rates by type

### Logging Requirements
```typescript
// Log authentication events
logger.info('Cross-app session generated', {
  user_id: userId,
  account_id: accountId,
  token_id: tokenId,
  expires_at: expiresAt,
  source_app: 'tuvens',
  target_app: 'hi-events'
});

logger.info('Session token validated', {
  token_id: tokenId,
  user_id: userId,
  valid: true,
  requesting_app: 'hi-events'
});
```

## Testing the Flow

### Manual Testing Checklist
- [ ] User can initiate ticketing flow from Tuvens
- [ ] Session token is generated successfully
- [ ] Redirect to Hi.Events works with correct parameters
- [ ] Hi.Events can validate session token
- [ ] User is authenticated in Hi.Events
- [ ] Event is created in Hi.Events
- [ ] Callback returns to Tuvens successfully
- [ ] Tuvens event is updated with Hi.Events data

### Automated Testing
```typescript
describe('Cross-App Authentication Flow', () => {
  it('should complete full authentication flow', async () => {
    // 1. Generate session token
    const tokenResponse = await generateSessionToken(userJWT);
    expect(tokenResponse.session_token).toBeDefined();
    
    // 2. Validate token
    const validationResponse = await validateSessionToken(tokenResponse.session_token);
    expect(validationResponse.valid).toBe(true);
    
    // 3. Check user data
    expect(validationResponse.user_data.email).toBe('user@example.com');
  });
});
```