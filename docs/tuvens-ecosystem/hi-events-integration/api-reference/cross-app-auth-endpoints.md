# 🛠️ Cross-App Authentication Endpoints

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