# Hi.Events Integration Troubleshooting Guide

This guide provides solutions to common issues encountered during Hi.Events integration with Tuvens applications.

## 🚨 Common Issues and Solutions

### 1. Authentication Failures

#### Issue: "Invalid session token" error
**Symptoms:**
- Hi.Events shows authentication error
- User redirected back to Tuvens with error
- Console shows 401 unauthorized errors

**Solutions:**
```bash
# Check token generation
curl -X POST http://localhost:3000/api/cross-app/generate-session \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"eventId": 1}'

# Verify shared secret configuration
echo $CROSS_APP_SHARED_SECRET
echo $VITE_TUVENS_SHARED_SECRET
```

**Root Causes:**
- Mismatched shared secrets between systems
- JWT token expired or invalid
- Database connection issues
- Clock synchronization problems

#### Issue: "User not found" during cross-app authentication
**Symptoms:**
- Token validates but user lookup fails
- Hi.Events cannot retrieve user information
- Authentication flow stops at user validation

**Solutions:**
- Verify user exists in Tuvens database
- Check user permissions for the event
- Confirm user account is active
- Test user-accounts endpoint directly

### 2. Widget Display Issues

#### Issue: Widget not loading on event pages
**Symptoms:**
- Empty space where widget should appear
- Console errors about iframe or script loading
- Widget shows "Event not found" message

**Solutions:**
```typescript
// Debug widget loading
console.log('Widget data:', {
  hiEventsEventId,
  widgetUrl,
  eventData
});

// Check if event has ticketing enabled
SELECT * FROM events WHERE id = ? AND hi_events_event_id IS NOT NULL;
```

**Root Causes:**
- Event doesn't have Hi.Events integration enabled
- Invalid Hi.Events event ID stored
- CORS issues blocking widget resources
- CSP headers blocking iframe content

#### Issue: Widget loads but shows wrong event data
**Symptoms:**
- Widget displays but for different event
- Pricing or details don't match Tuvens event
- Purchase flow leads to wrong event

**Solutions:**
- Verify Hi.Events event ID mapping
- Check event data synchronization
- Test Hi.Events API directly
- Validate widget URL parameters

### 3. Cross-App Route Issues

#### Issue: Hi.Events `/auth/cross-app` route returns 404
**Symptoms:**
- Direct navigation to route shows "Page not found"
- Redirect from Tuvens fails
- Route not accessible via browser

**Solutions:**
```bash
# Test route accessibility
curl -I http://localhost:3001/auth/cross-app

# Check Hi.Events routing configuration
# Verify route is properly registered
# Check for typos in route path
```

**Root Causes:**
- Route not properly implemented in Hi.Events
- Server routing configuration issues
- Base URL or path mismatches
- Development server not running

#### Issue: Route loads but authentication parameters missing
**Symptoms:**
- Route loads but shows generic error
- Missing sessionToken in URL parameters
- Authentication cannot proceed

**Solutions:**
- Check URL parameter generation in Tuvens
- Verify redirect URL construction
- Test parameter parsing in Hi.Events
- Validate URL encoding/decoding

### 4. Environment Configuration Issues

#### Issue: Environment variables not loading correctly
**Symptoms:**
- Undefined values in configuration
- Default values being used instead of custom ones
- Configuration mismatches between environments

**Solutions:**
```bash
# Check environment variables
printenv | grep TUVENS
printenv | grep HI_EVENTS
printenv | grep CROSS_APP

# Verify .env file loading
node -e "console.log(require('dotenv').config())"
```

**Common Misconfigurations:**
```bash
# Wrong - missing protocol
VITE_TUVENS_API_URL=localhost:3000

# Correct - with protocol
VITE_TUVENS_API_URL=http://localhost:3000

# Wrong - trailing slash
VITE_HI_EVENTS_URL=https://tickets.tuvens.com/

# Correct - no trailing slash
VITE_HI_EVENTS_URL=https://tickets.tuvens.com
```

### 5. Database and Session Issues

#### Issue: "Cross-app session not found" error
**Symptoms:**
- Valid-looking token but validation fails
- Database lookup returns no results
- Session appears expired immediately

**Solutions:**
```sql
-- Check session storage
SELECT * FROM cross_app_sessions 
WHERE token = 'YOUR_TOKEN_HERE';

-- Check token expiry
SELECT *, 
       expires_at > NOW() AS is_valid 
FROM cross_app_sessions 
WHERE token = 'YOUR_TOKEN_HERE';

-- Clean up expired sessions
DELETE FROM cross_app_sessions 
WHERE expires_at < NOW();
```

**Root Causes:**
- Database table not created
- Token not properly stored during generation
- Premature cleanup of sessions
- Database connection issues

### 6. CORS and Security Issues

#### Issue: CORS errors when Hi.Events calls Tuvens API
**Symptoms:**
- Browser console shows CORS errors
- Preflight requests failing
- API calls blocked by browser

**Solutions:**
```javascript
// Backend CORS configuration
app.use(cors({
  origin: [
    'http://localhost:3001',
    'https://tickets.tuvens.com',
    process.env.HI_EVENTS_DOMAIN
  ],
  credentials: true,
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization', 'X-Shared-Secret']
}));
```

#### Issue: CSP blocking widget or authentication flow
**Symptoms:**
- Widget iframe blocked
- Redirect to Hi.Events blocked
- Script loading errors

**Solutions:**
```html
<!-- Update CSP headers -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; 
               frame-src 'self' https://tickets.tuvens.com; 
               script-src 'self' 'unsafe-inline' https://tickets.tuvens.com;">
```

## 🔧 Debugging Tools and Techniques

### API Testing Commands
```bash
# Test session generation
curl -X POST http://localhost:3000/api/cross-app/generate-session \
  -H "Authorization: Bearer $(cat jwt-token.txt)" \
  -H "Content-Type: application/json" \
  -d '{"eventId": 1}' | jq

# Test session validation
curl -X POST http://localhost:3000/api/cross-app/validate-session \
  -H "Content-Type: application/json" \
  -d '{
    "sessionToken": "YOUR_TOKEN_HERE",
    "sharedSecret": "YOUR_SHARED_SECRET"
  }' | jq

# Test user accounts endpoint
curl -X GET "http://localhost:3000/api/cross-app/user-accounts/1" \
  -H "Content-Type: application/json" \
  -d '{
    "sharedSecret": "YOUR_SHARED_SECRET"
  }' | jq
```

### Browser Developer Tools
1. **Network Tab**: Monitor API calls and responses
2. **Console Tab**: Check for JavaScript errors
3. **Application Tab**: Inspect localStorage and sessionStorage
4. **Security Tab**: Verify HTTPS and certificate issues

### Database Debugging Queries
```sql
-- Check cross-app sessions
SELECT 
  id,
  user_id,
  event_id,
  token,
  expires_at,
  created_at,
  expires_at > NOW() as is_valid
FROM cross_app_sessions 
ORDER BY created_at DESC 
LIMIT 10;

-- Check events with Hi.Events integration
SELECT 
  id,
  title,
  hi_events_event_id,
  has_ticketing
FROM events 
WHERE hi_events_event_id IS NOT NULL;

-- Check user permissions
SELECT 
  u.id,
  u.email,
  e.id as event_id,
  e.title,
  e.user_id = u.id as is_owner
FROM users u
JOIN events e ON e.user_id = u.id
WHERE u.id = ?;
```

## 📊 Monitoring and Logging

### Enable Debug Logging
```bash
# Backend debug logging
DEBUG=cross-app:* npm start

# Frontend debug logging
VITE_DEBUG=true npm run dev
```

### Key Metrics to Monitor
- **Session Generation Rate**: Tokens created per minute
- **Validation Success Rate**: Successful token validations
- **Authentication Flow Completion**: End-to-end success rate
- **Widget Load Time**: Time to render Hi.Events widget
- **Error Rate**: Failed requests per endpoint

### Log Analysis Commands
```bash
# Find authentication errors
grep "authentication failed" logs/app.log

# Check token generation patterns
grep "session generated" logs/app.log | tail -20

# Monitor widget loading issues
grep "widget.*error" logs/frontend.log
```

## 🚀 Performance Troubleshooting

### Slow Authentication Flow
**Symptoms:**
- Long delays during Hi.Events redirect
- Timeout errors in authentication
- Poor user experience

**Solutions:**
- Check database query performance
- Optimize JWT token generation
- Implement connection pooling
- Add request caching where appropriate

### Widget Loading Performance
**Symptoms:**
- Slow widget rendering
- Blank spaces before widget appears
- User interface delays

**Solutions:**
- Implement lazy loading for widgets
- Add loading placeholders
- Optimize widget iframe loading
- Consider widget preloading

## 📞 Getting Additional Help

### Before Requesting Support
1. **Check this troubleshooting guide** for your specific issue
2. **Verify environment configuration** matches requirements
3. **Test each component independently** to isolate the problem
4. **Gather relevant logs and error messages**
5. **Document steps to reproduce** the issue

### Support Information to Provide
- **Environment details** (development, staging, production)
- **Error messages** with full stack traces
- **API request/response examples** showing the issue
- **Browser and version** if frontend-related
- **Database logs** if data-related
- **Steps to reproduce** the problem

### Emergency Contacts
- **Frontend Issues**: Frontend team lead
- **Backend API Issues**: Backend team lead  
- **Database Issues**: DevOps team
- **Hi.Events Platform Issues**: Hi.Events support team

---

**Troubleshooting Status**: Comprehensive guide for Hi.Events integration  
**Last Updated**: 2025-07-25  
**Next Review**: After production deployment