# Hi.Events API Reference

## 📚 Complete API Specification

This directory contains the complete API documentation for Hi.Events integration with the Tuvens ecosystem. The API enables seamless event management, ticketing, and cross-application authentication.

## 📚 API Documentation Index

### Authentication & Security
- [🔐 Authentication](./authentication.md) - JWT tokens, API keys, authentication flow
- [🛡️ Security Considerations](./security-considerations.md) - Security headers, CORS, rate limiting details

### Core API Endpoints
- [🛠️ Cross-App Authentication Endpoints](./cross-app-auth-endpoints.md) - Session generation, validation, user account endpoints
- [🔗 Webhook Endpoints](./webhook-endpoints.md) - Event notifications, ticket updates, payment confirmations
- [📡 Frontend Integration Endpoints](./frontend-integration-endpoints.md) - Widget embedding, UI components

### Reference Materials
- [🏗️ Data Structures](./data-structures.md) - Request/response schemas, data models
- [🚨 Error Response Format](./error-response-format.md) - Error codes, response structure
- [🎯 HTTP Status Codes](./http-status-codes.md) - Status code reference
- [🔄 Rate Limiting](./rate-limiting.md) - Rate limits, throttling, retry strategies

### Implementation Help
- [📝 Integration Examples](./integration-examples.md) - Code samples, implementation patterns

## Quick Start for Claude Code Sessions

Load only the API sections relevant to your current task:

```markdown
# Working on authentication integration
Load: hi-events-integration/api-reference/authentication.md
Load: hi-events-integration/api-reference/cross-app-auth-endpoints.md

# Implementing webhook handling
Load: hi-events-integration/api-reference/webhook-endpoints.md
Load: hi-events-integration/api-reference/data-structures.md

# Building frontend integration
Load: hi-events-integration/api-reference/frontend-integration-endpoints.md
Load: hi-events-integration/api-reference/authentication.md

# Debugging API issues
Load: hi-events-integration/api-reference/error-response-format.md
Load: hi-events-integration/api-reference/http-status-codes.md

# Security implementation
Load: hi-events-integration/api-reference/security-considerations.md
Load: hi-events-integration/api-reference/rate-limiting.md

# Implementation examples
Load: hi-events-integration/api-reference/integration-examples.md
```

## API Overview

The Hi.Events API provides:
- ✅ **Cross-app authentication** for seamless user experience
- ✅ **Webhook notifications** for real-time event updates
- ✅ **Frontend integration endpoints** for widget embedding
- ✅ **Comprehensive error handling** with detailed error responses
- ✅ **Rate limiting and security** features for production use

## Base URL

```
Production: https://tickets.tuvens.com/api/v1
Staging: https://staging-tickets.tuvens.com/api/v1
```

## Authentication Required

All API endpoints require authentication via:
- **JWT Bearer Token** (recommended for frontend)
- **API Key** (recommended for server-to-server)

See the authentication documentation for detailed implementation.

---

*This API reference supports both `laravel-dev` and `react-dev` agents working on hi.events integration features.*