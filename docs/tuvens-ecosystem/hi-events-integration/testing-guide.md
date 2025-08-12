# Hi.Events Integration Testing Guide

This guide provides comprehensive testing procedures for the Hi.Events ticketing integration with Tuvens applications.

## 🧪 Integration Testing Checklist

### Hi.Events Route Testing
- [x] Route accessibility (`/auth/cross-app` returns HTTP 200)
- [x] Component compilation successful  
- [x] Service integration ready
- [ ] End-to-end flow with real Tuvens data
- [ ] Session token validation with Tuvens backend
- [ ] Event creation and callback handling

### Backend API Testing
- [ ] `POST /api/cross-app/generate-session` endpoint functional
- [ ] `POST /api/cross-app/validate-session` endpoint functional
- [ ] `GET /api/cross-app/user-accounts` endpoint functional
- [ ] `POST /api/cross-app/validate-permission` endpoint functional
- [ ] JWT authentication working correctly
- [ ] Shared secret validation implemented
- [ ] CORS configuration allowing Hi.Events domain

### Frontend Integration Testing
- [ ] "Add Ticketing" button displays correctly
- [ ] Cross-app authentication service functional
- [ ] Hi.Events redirect flow working
- [ ] Callback handler processing responses
- [ ] Ticket widget component rendering
- [ ] Error handling for authentication failures
- [ ] Loading states during ticketing operations

### Security Testing
- [ ] Session tokens expire after 15 minutes
- [ ] Invalid tokens rejected properly
- [ ] User permission validation working
- [ ] Cross-app requests authenticated
- [ ] Audit logging capturing all operations

### Error Scenario Testing
- [ ] Expired session token handling
- [ ] Invalid user permissions
- [ ] Network connectivity issues
- [ ] Hi.Events service unavailable
- [ ] Malformed callback responses

## 🔧 Testing Environment Setup

### Prerequisites
- Tuvens backend running with cross-app endpoints
- Hi.Events development environment
- Test user accounts in both systems
- Valid environment variables configured

### Environment Variables for Testing
```bash
# Backend Testing
CROSS_APP_SHARED_SECRET=test-secret-key
CROSS_APP_TOKEN_EXPIRY=900
HI_EVENTS_DOMAIN=localhost:3001

# Frontend Testing
VITE_TUVENS_API_URL=http://localhost:3000
VITE_TUVENS_SHARED_SECRET=test-secret-key
VITE_HI_EVENTS_URL=http://localhost:3001
```

### Test Data Setup
```sql
-- Create test user
INSERT INTO users (email, name, password_hash) 
VALUES ('test@tuvens.com', 'Test User', 'hashed_password');

-- Create test event
INSERT INTO events (title, description, start_date, end_date, location, user_id)
VALUES ('Test Event', 'Integration testing event', '2025-08-01', '2025-08-01', 'Test Venue', 1);
```

## 🧪 Manual Testing Procedures

### Test 1: Complete Integration Flow
1. **Login to Tuvens** with test user account
2. **Create or edit an event** 
3. **Click "Add Ticketing"** button
4. **Verify redirect** to Hi.Events with correct parameters
5. **Confirm authentication** in Hi.Events
6. **Verify event creation** in Hi.Events
7. **Test callback handling** when returning to Tuvens
8. **Confirm widget display** on public event page

### Test 2: Session Token Validation
1. **Generate session token** via API
2. **Verify token format** (JWT structure)
3. **Test token validation** endpoint
4. **Confirm token expiry** after 15 minutes
5. **Test invalid token rejection**

### Test 3: Error Handling
1. **Test with expired token**
2. **Test with invalid user permissions**
3. **Test with Hi.Events service down**
4. **Test with network connectivity issues**
5. **Verify error messages** displayed to user

## 🤖 Automated Testing

### API Integration Tests
```typescript
// Example test structure
describe('Cross-App Authentication API', () => {
  test('generates valid session tokens', async () => {
    const response = await request(app)
      .post('/api/cross-app/generate-session')
      .set('Authorization', `Bearer ${validJWT}`)
      .send({ eventId: 1 });
    
    expect(response.status).toBe(200);
    expect(response.body.sessionToken).toBeDefined();
    expect(response.body.expiresAt).toBeDefined();
  });
  
  test('validates session tokens correctly', async () => {
    const sessionToken = await generateTestToken();
    
    const response = await request(app)
      .post('/api/cross-app/validate-session')
      .send({ 
        sessionToken,
        sharedSecret: process.env.CROSS_APP_SHARED_SECRET 
      });
    
    expect(response.status).toBe(200);
    expect(response.body.user).toBeDefined();
  });
});
```

### Frontend Component Tests
```typescript
// Example component test
describe('TicketingButton Component', () => {
  test('displays correctly for events without ticketing', () => {
    render(<TicketingButton event={eventWithoutTicketing} />);
    expect(screen.getByText('Add Ticketing')).toBeInTheDocument();
  });
  
  test('shows widget for events with ticketing', () => {
    render(<TicketingButton event={eventWithTicketing} />);
    expect(screen.getByTestId('hi-events-widget')).toBeInTheDocument();
  });
});
```

### End-to-End Tests
```typescript
// Example E2E test with Playwright
test('complete ticketing integration flow', async ({ page }) => {
  // Login to Tuvens
  await page.goto('/login');
  await page.fill('[data-testid="email"]', 'test@tuvens.com');
  await page.fill('[data-testid="password"]', 'password');
  await page.click('[data-testid="login-button"]');
  
  // Navigate to event
  await page.goto('/events/1/edit');
  
  // Click Add Ticketing
  await page.click('[data-testid="add-ticketing-button"]');
  
  // Verify redirect to Hi.Events
  await page.waitForURL(/hi\.events/);
  
  // Verify authentication successful
  await expect(page.locator('[data-testid="authenticated"]')).toBeVisible();
});
```

## 📊 Performance Testing

### Load Testing Scenarios
1. **Concurrent session generation** - Test multiple users generating tokens simultaneously
2. **Token validation load** - Test Hi.Events making multiple validation requests
3. **Widget loading performance** - Test widget rendering under load
4. **Database connection limits** - Test cross-app table performance

### Performance Benchmarks
- **Session token generation**: < 200ms response time
- **Token validation**: < 100ms response time
- **Widget loading**: < 2s initial load
- **Cross-app authentication flow**: < 5s total time

## 🔍 Debugging and Troubleshooting

### Common Issues and Solutions

#### Authentication Failures
- **Check JWT token validity** in Tuvens requests
- **Verify shared secret** configuration matches both systems
- **Confirm user permissions** in Tuvens system
- **Check token expiry** timestamps

#### Widget Display Issues
- **Verify event has ticketing enabled** in database
- **Check Hi.Events event ID** is properly stored
- **Confirm widget URL** is accessible
- **Test CORS configuration** for widget requests

#### Network and Connectivity
- **Check environment variables** are properly set
- **Verify Hi.Events service** is running and accessible
- **Test API endpoints** individually
- **Check firewall and proxy** configurations

### Debug Logging
```typescript
// Enable debug logging for testing
process.env.DEBUG = 'cross-app:*';

// Log key events
logger.debug('Session token generated', { userId, tokenId, expiresAt });
logger.debug('Hi.Events authentication initiated', { eventId, userId });
logger.debug('Widget rendering started', { eventId, hiEventsEventId });
```

## ✅ Test Completion Criteria

### Ready for Production Checklist
- [ ] All automated tests passing
- [ ] Manual integration flow tested successfully
- [ ] Error scenarios handled gracefully
- [ ] Performance benchmarks met
- [ ] Security requirements validated
- [ ] User acceptance testing completed
- [ ] Documentation updated with test results

### Sign-off Requirements
- [ ] **Backend Developer**: API endpoints tested and functional
- [ ] **Frontend Developer**: UI integration tested and working
- [ ] **QA Engineer**: Comprehensive testing completed
- [ ] **Product Owner**: User experience validated
- [ ] **Security Review**: Security requirements met

---

**Testing Status**: Ready to begin comprehensive integration testing  
**Last Updated**: 2025-07-25  
**Next Review**: After implementation completion