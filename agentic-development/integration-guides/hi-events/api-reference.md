# Hi.Events Integration API Reference

## 📚 Complete API Specification

This document provides comprehensive API documentation for all Hi.Events integration endpoints, including request/response formats, authentication requirements, and error handling.

## 🔐 Authentication

### Authentication Types

#### 1. JWT Authentication (User-facing endpoints)
```http
Authorization: Bearer <jwt_token>
```

#### 2. Shared Secret (Backend-to-backend)
```http
x-shared-secret: <HI_EVENTS_SHARED_SECRET>
```

#### 3. HMAC Webhook Signature
```http
x-hi-events-signature: sha256=<hmac_signature>
```

## 🛠️ Cross-App Authentication Endpoints

### 1. Generate Session Token

**Endpoint**: `POST /api/cross-app/generate-session`

**Description**: Generates a secure session token for cross-app authentication.

**Authentication**: JWT Required

**Request**:
```typescript
interface GenerateSessionRequest {
    account_id: number;
}
```

**Example Request**:
```bash
curl -X POST https://api.tuvens.com/api/cross-app/generate-session \
  -H "Authorization: Bearer <jwt_token>" \
  -H "Content-Type: application/json" \
  -d '{"account_id": 123}'
```

**Response**:
```typescript
interface GenerateSessionResponse {
    session_token: string;
    expires_at: string; // ISO 8601 timestamp
}
```

**Example Response**:
```json
{
    "session_token": "abc123def456ghi789jkl012mno345pqr678",
    "expires_at": "2025-07-25T15:45:00.000Z"
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid or expired JWT token
- `400 Bad Request`: Missing or invalid account_id
- `403 Forbidden`: User lacks permission for specified account
- `500 Internal Server Error`: Token generation failed

---

### 2. Validate Session Token

**Endpoint**: `POST /api/cross-app/validate-session`

**Description**: Validates session token and returns user data for Hi.Events.

**Authentication**: Shared Secret Required

**Request**:
```typescript
interface ValidateSessionRequest {
    session_token: string;
}
```

**Example Request**:
```bash
curl -X POST https://api.tuvens.com/api/cross-app/validate-session \
  -H "x-shared-secret: <HI_EVENTS_SHARED_SECRET>" \
  -H "Content-Type: application/json" \
  -d '{"session_token": "abc123def456ghi789jkl012mno345pqr678"}'
```

**Response**:
```typescript
interface ValidateSessionResponse {
    user_id: string;    // User ID converted to string
    email: string;      // User's email
    name: string;       // User's display name or email if no display name
    account_id: number; // The account ID from the session
}
```

**Example Response**:
```json
{
    "user_id": "456",
    "email": "user@example.com",
    "name": "John Doe",
    "account_id": 123
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid shared secret
- `400 Bad Request`: Missing session_token
- `404 Not Found`: Session token not found or expired
- `500 Internal Server Error`: Validation failed

---

### 3. Get User Accounts

**Endpoint**: `GET /api/cross-app/user-accounts`

**Description**: Retrieves user account information for valid session.

**Authentication**: Shared Secret Required

**Query Parameters**:
```typescript
interface UserAccountsQuery {
    session_token: string;
}
```

**Example Request**:
```bash
curl -X GET "https://api.tuvens.com/api/cross-app/user-accounts?session_token=abc123def456ghi789jkl012mno345pqr678" \
  -H "x-shared-secret: <HI_EVENTS_SHARED_SECRET>"
```

**Response**:
```typescript
interface UserAccountsResponse {
    accounts: Array<{
        id: number;
        name: string;
        slug: string;
    }>;
}
```

**Example Response**:
```json
{
    "accounts": [
        {
            "id": 123,
            "name": "Acme Events",
            "slug": "acme-events"
        }
    ]
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid shared secret or session token
- `404 Not Found`: Session not found or expired
- `500 Internal Server Error`: Account retrieval failed

---

### 4. Validate User Permission

**Endpoint**: `POST /api/cross-app/validate-permission`

**Description**: Validates user permissions for specific actions.

**Authentication**: Shared Secret Required

**Request**:
```typescript
interface ValidatePermissionRequest {
    session_token: string;
    permission: string;
    resource_id?: number;
}
```

**Example Request**:
```bash
curl -X POST https://api.tuvens.com/api/cross-app/validate-permission \
  -H "x-shared-secret: <HI_EVENTS_SHARED_SECRET>" \
  -H "Content-Type: application/json" \
  -d '{
    "session_token": "abc123def456ghi789jkl012mno345pqr678",
    "permission": "manage_ticketing",
    "resource_id": 789
  }'
```

**Response**:
```typescript
interface ValidatePermissionResponse {
    has_permission: boolean;
}
```

**Example Response**:
```json
{
    "has_permission": true
}
```

**Error Responses**:
- `401 Unauthorized`: Invalid shared secret or session token
- `400 Bad Request`: Missing required fields
- `404 Not Found`: Session not found or expired

## 🔗 Webhook Endpoints

### Hi.Events Status Change Webhook

**Endpoint**: `POST /api/webhooks/hi-events/event-status-changed`

**Description**: Receives Hi.Events status change notifications and updates Tuvens event records.

**Authentication**: HMAC-SHA256 Signature Required

**Request Headers**:
```http
Content-Type: application/json
x-hi-events-signature: sha256=<hmac_signature>
```

**Request Payload**:
```typescript
interface HiEventsWebhookPayload {
    event_type: "event.status_changed";
    event_sent_at: string; // ISO 8601 timestamp
    payload: {
        id: number; // Hi.Events event ID
        title: string;
        status: "LIVE" | "DRAFT" | "CANCELLED" | "ENDED";
        tuvens_event_id: string;
    };
}
```

**Example Request**:
```bash
curl -X POST https://api.tuvens.com/api/webhooks/hi-events/event-status-changed \
  -H "Content-Type: application/json" \
  -H "x-hi-events-signature: sha256=abc123def456..." \
  -d '{
    "event_type": "event.status_changed",
    "event_sent_at": "2025-07-25T14:30:00.000Z",
    "payload": {
        "id": 2,
        "title": "Event Title",
        "status": "LIVE",
        "tuvens_event_id": "11"
    }
  }'
```

**Response**:
```typescript
interface WebhookResponse {
    success: boolean;
    message: string;
}
```

**Example Response**:
```json
{
    "success": true,
    "message": "Webhook processed successfully"
}
```

**Status Mapping**:
| Hi.Events Status | Tuvens ticketStatus | Description |
|-----------------|-------------------|-------------|
| `LIVE` | `active` | Event is live and ticketing is active |
| `DRAFT` | `setup` | Event is in draft/setup mode |
| `CANCELLED` | `inactive` | Event cancelled, ticketing disabled |
| `ENDED` | `inactive` | Event ended, ticketing disabled |
| Other | `setup` | Default fallback status |

**Error Responses**:
- `401 Unauthorized`: Invalid or missing HMAC signature
- `400 Bad Request`: Invalid webhook payload structure
- `404 Not Found`: Tuvens event not found
- `500 Internal Server Error`: Webhook processing failed

**Signature Calculation**:
```javascript
const crypto = require('crypto');
const payload = JSON.stringify(webhookPayload);
const signature = crypto
    .createHmac('sha256', process.env.HI_EVENTS_SHARED_SECRET)
    .update(payload, 'utf8')
    .digest('hex');
const header = `sha256=${signature}`;
```

## 📡 Frontend Integration Endpoints

### Generate Session (Frontend)

**Endpoint**: `POST /api/cross-app/generate-session` (Frontend route)

**Description**: Frontend wrapper for session token generation.

**File Location**: `/src/routes/api/cross-app/generate-session/+server.ts`

**Request/Response**: Same as backend endpoint above

## 🏗️ Data Structures

### Enhanced Event Type

```typescript
interface EventWithHiEvents {
    // Core event fields
    id: string;
    title: string;
    description: string;
    startDate: string;
    endDate: string;
    
    // Legacy ticketing fields (backward compatibility)
    hasTicketing?: boolean;
    hiEventsEventId?: number; 
    
    // New ticketing fields
    ticketing_enabled: boolean;
    ticketing_status: 'setup' | 'active' | 'inactive';
    hi_events_event_id: number;
    hi_events_event_url: string;
    
    // Enhanced contactData JSON
    contactData: {
        // Hi.Events metadata
        hiEventsEventId?: number;
        hiEventsStatus?: string;
        hiEventsLastUpdated?: string;
        
        // Other contact data
        email?: string;
        phone?: string;
        website?: string;
    };
}
```

### Cross-App Session Structure

```typescript
interface CrossAppSession {
    id: number;
    sessionToken: string;
    userId: number;
    accountId: number;
    appId: string;
    expiresAt: Date;
    createdAt: Date;
    lastUsed?: Date;
    sysCreated: Date;
    sysModified: Date;
}
```

## 🚨 Error Response Format

All API endpoints return errors in the following standardized format:

```typescript
interface ErrorResponse {
    statusCode: number;
    timestamp: string; // ISO 8601
    path: string;
    message: string;
    origin?: {
        message: string;
        code?: string;
        details?: any;
    };
}
```

**Example Error Response**:
```json
{
    "statusCode": 400,
    "timestamp": "2025-07-25T14:30:00.000Z",
    "path": "/api/cross-app/generate-session",
    "message": "Invalid request payload",
    "origin": {
        "message": "Missing required field: account_id",
        "code": "VALIDATION_ERROR"
    }
}
```

## 🎯 HTTP Status Codes

### Success Codes
- `200 OK`: Request successful
- `201 Created`: Resource created successfully

### Client Error Codes  
- `400 Bad Request`: Invalid request payload or parameters
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Valid authentication but insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource conflict (e.g., duplicate session)
- `422 Unprocessable Entity`: Valid request but business logic error

### Server Error Codes
- `500 Internal Server Error`: Unexpected server error
- `502 Bad Gateway`: Upstream service error
- `503 Service Unavailable`: Service temporarily unavailable
- `504 Gateway Timeout`: Upstream service timeout

## 🔄 Rate Limiting

### Authentication Endpoints
- **Generate Session**: 10 requests per minute per user
- **Validate Session**: 100 requests per minute per shared secret
- **User Accounts**: 50 requests per minute per session token
- **Validate Permission**: 100 requests per minute per session token

### Webhook Endpoints
- **Status Change**: 1000 requests per minute per Hi.Events instance

### Rate Limit Headers
```http
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 7
X-RateLimit-Reset: 1690387200
```

## 🛡️ Security Considerations

### Input Validation
- All JSON payloads validated against schemas
- SQL injection prevention through parameterized queries
- XSS prevention through output encoding
- CSRF protection on state-changing operations

### Token Security
- Session tokens are cryptographically secure (32 random bytes)
- Tokens expire after 15 minutes
- Timing-safe comparisons for all token validation
- Automatic cleanup of expired sessions

### Webhook Security
- HMAC-SHA256 signature verification required
- Replay attack prevention through timestamp validation
- IP allowlisting for Hi.Events webhook sources
- Payload size limits to prevent DoS attacks

## 📝 Integration Examples

### Complete Integration Flow

```typescript
// 1. Generate session token
const sessionResponse = await fetch('/api/cross-app/generate-session', {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${userToken}`,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({ account_id: 123 })
});

const { session_token, expires_at } = await sessionResponse.json();

// 2. Redirect to Hi.Events
const hiEventsUrl = new URL('https://tickets.tuvens.com/auth/cross-app');
hiEventsUrl.searchParams.set('session_token', session_token);
hiEventsUrl.searchParams.set('return_url', window.location.href);
hiEventsUrl.searchParams.set('app_id', 'tuvens');

window.location.href = hiEventsUrl.toString();

// 3. Handle callback (Hi.Events validates session behind the scenes)
const urlParams = new URLSearchParams(window.location.search);
const status = urlParams.get('status');

if (status === 'success') {
    // Update UI to show ticketing widget
    updateTicketingStatus('active');
}
```

### Webhook Handler Example

```typescript
// Webhook signature verification
function verifyWebhookSignature(payload: string, signature: string): boolean {
    const expectedSignature = crypto
        .createHmac('sha256', process.env.HI_EVENTS_SHARED_SECRET)
        .update(payload, 'utf8')
        .digest('hex');
    
    const expectedHeader = `sha256=${expectedSignature}`;
    return crypto.timingSafeEqual(
        Buffer.from(signature),
        Buffer.from(expectedHeader)
    );
}

// Webhook processing
export async function POST({ request }: RequestEvent) {
    const signature = request.headers.get('x-hi-events-signature');
    const payload = await request.text();
    
    if (!verifyWebhookSignature(payload, signature)) {
        return new Response('Unauthorized', { status: 401 });
    }
    
    const webhookData = JSON.parse(payload);
    await processStatusChange(webhookData.payload);
    
    return Response.json({ success: true });
}
```

This API reference provides complete documentation for integrating with the Hi.Events ticketing system, including all endpoints, data structures, error handling, and security considerations.