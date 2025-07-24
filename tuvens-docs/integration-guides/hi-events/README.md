# Hi.Events Integration Documentation

This directory contains comprehensive documentation for integrating Hi.Events ticketing functionality with Tuvens applications.

## 📚 Documentation Overview

### Core Integration Guides
- **[Frontend Integration](./frontend-integration.md)** - Complete frontend implementation guide with React/TypeScript examples
- **[API Requirements](./api-requirements.md)** - Required backend API endpoints and specifications
- **[Authentication Flow](./authentication-flow.md)** - Cross-app authentication flow documentation with security details

### Additional Resources
- **[Widget Integration](./widget-integration.md)** - Hi.Events ticket widget embedding guide
- **[Testing Guide](./testing-guide.md)** - Testing procedures for the integration
- **[Troubleshooting](./troubleshooting.md)** - Common issues and solutions

## 🎯 Integration Overview

### What This Integration Provides
1. **Seamless Authentication** - Users authenticate once in Tuvens, access ticketing in Hi.Events
2. **Automatic Event Creation** - Tuvens events automatically create corresponding Hi.Events events
3. **Widget Embedding** - Display ticket purchasing interface directly in Tuvens
4. **Cross-Platform Management** - Manage tickets on Hi.Events, display on Tuvens

### Architecture Summary
```
┌─────────────┐    Cross-App Auth    ┌─────────────┐    Widget Display    ┌─────────────┐
│   Tuvens    │ ────────────────────► │ Hi.Events   │ ────────────────────► │   Public    │
│ Event Mgmt  │                      │ Ticketing   │                      │ Event Page  │
└─────────────┘                      └─────────────┘                      └─────────────┘
```

## 🚀 Quick Start

### For Frontend Developers
1. **Start Here**: [Frontend Integration Guide](./frontend-integration.md)
2. **Backend Requirements**: [API Requirements](./api-requirements.md)
3. **Authentication Details**: [Authentication Flow](./authentication-flow.md)

### For Backend Developers
1. **API Specifications**: [API Requirements](./api-requirements.md)
2. **Authentication Implementation**: [Authentication Flow](./authentication-flow.md)
3. **Cross-App Security**: Review security sections in both documents

### For Full-Stack Implementation
1. **Backend**: Implement required API endpoints per [API Requirements](./api-requirements.md)
2. **Frontend**: Follow [Frontend Integration Guide](./frontend-integration.md)
3. **Testing**: Use [Testing Guide](./testing-guide.md) to validate implementation
4. **Deployment**: Reference [Troubleshooting](./troubleshooting.md) for common deployment issues

## 🔧 Implementation Checklist

### Backend Requirements
- [ ] `POST /api/cross-app/generate-session` endpoint implemented
- [ ] `POST /api/cross-app/validate-session` endpoint implemented  
- [ ] `GET /api/cross-app/user-accounts` endpoint implemented
- [ ] `POST /api/cross-app/validate-permission` endpoint implemented
- [ ] Cross-app session database table created
- [ ] JWT authentication integrated
- [ ] Shared secret configuration completed
- [ ] CORS configured for Hi.Events domain

### Frontend Requirements
- [ ] "Add Ticketing" button implemented in event management
- [ ] Cross-app authentication service created
- [ ] Hi.Events redirect flow implemented
- [ ] Callback handler for Hi.Events responses
- [ ] Ticket widget component for public event pages
- [ ] Error handling for authentication failures
- [ ] Loading states for ticketing operations

### Integration Testing
- [ ] Session token generation tested
- [ ] Cross-app authentication flow tested end-to-end
- [ ] Widget embedding tested on public pages
- [ ] Error scenarios tested (expired tokens, permissions, etc.)
- [ ] Performance testing completed
- [ ] Security testing completed

## 🛠️ Development Environment Setup

### Prerequisites
- Tuvens backend with JWT authentication
- PostgreSQL database
- Hi.Events development environment (or mock)
- Node.js frontend application

### Environment Variables
```bash
# Backend Environment Variables
CROSS_APP_SHARED_SECRET=your-development-secret
CROSS_APP_TOKEN_EXPIRY=900
HI_EVENTS_DOMAIN=tickets.tuvens.com

# Frontend Environment Variables
REACT_APP_HI_EVENTS_URL=https://tickets.tuvens.com
REACT_APP_API_BASE_URL=http://localhost:3000
```

### Local Development
```bash
# Backend setup
npm install
npm run migration:run
npm run start:dev

# Frontend setup
npm install
npm run start

# Test Hi.Events integration
npm run test:integration
```

## 🔍 Key Integration Points

### 1. Event Creation Flow
```typescript
User creates event → Clicks "Add Ticketing" → Authenticates → Hi.Events event created → Widget available
```

### 2. Authentication Security
- 15-minute session token expiry
- Cryptographically secure token generation
- Backend-to-backend shared secret validation
- Comprehensive audit logging

### 3. Data Synchronization
- Tuvens event data mapped to Hi.Events format
- Bi-directional updates for event modifications
- Ticket sales data available in both systems

## 📊 Monitoring and Analytics

### Key Metrics to Track
- **Authentication Success Rate** - Track successful cross-app authentications
- **Session Token Usage** - Monitor token generation and validation rates
- **Widget Performance** - Track widget loading times and errors
- **Conversion Rates** - Track from "Add Ticketing" to completed setup

### Logging Requirements
```typescript
// Example logging events
logger.info('Cross-app session generated', { userId, tokenId, expiresAt });
logger.info('Hi.Events authentication successful', { userId, hiEventsEventId });
logger.error('Widget loading failed', { eventId, error, userAgent });
```

## 🔒 Security Considerations

### Data Protection
- **User Data Minimization** - Only share necessary user information
- **Token Security** - Secure token generation, transmission, and storage
- **HTTPS Only** - All communication encrypted in transit
- **Input Validation** - Validate all data sent between systems

### Access Control
- **Permission Validation** - Verify user permissions before enabling ticketing
- **Account Boundaries** - Ensure users can only access their own events
- **Rate Limiting** - Prevent abuse of authentication endpoints
- **Audit Trail** - Complete logging of all cross-app operations

## 📞 Support and Troubleshooting

### Common Issues
1. **Token Generation Failures** - Check JWT validation and database connectivity
2. **Cross-App Authentication Errors** - Verify shared secret configuration
3. **Widget Loading Issues** - Check CORS configuration and CSP headers
4. **Permission Errors** - Validate user permissions and account access

### Debug Resources
- **[Troubleshooting Guide](./troubleshooting.md)** - Detailed problem-solving guide
- **[Testing Guide](./testing-guide.md)** - Validation procedures
- **API Documentation** - Complete endpoint specifications
- **Error Code Reference** - Comprehensive error code documentation

### Getting Help
1. Check the troubleshooting guide for your specific issue
2. Verify all environment variables are correctly configured
3. Test each component in isolation before full integration
4. Review audit logs for authentication and permission errors

---

**Ready to start?** Begin with the [Frontend Integration Guide](./frontend-integration.md) for a complete implementation walkthrough.