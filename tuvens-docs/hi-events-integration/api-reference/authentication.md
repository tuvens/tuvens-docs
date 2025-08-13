# 🔐 Authentication

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