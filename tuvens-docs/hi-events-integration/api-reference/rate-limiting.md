# 🔄 Rate Limiting

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