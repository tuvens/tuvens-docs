# Implement Hi.Events Cross-App Authentication Frontend Integration

## Overview
Implement the frontend integration for Hi.Events cross-app authentication in the tuvens-client repository. This integration will allow Tuvens users to seamlessly connect their accounts with Hi.Events for ticketing functionality.

## Background
The backend API already implements the cross-app authentication endpoints at `/api/cross-app/*`. The frontend needs to integrate with these endpoints and handle the complete authentication flow with Hi.Events.

## Technical Requirements

### 1. Frontend Integration Requirements

#### Authentication Flow Components
- **Add Ticketing Button**: Create a button/UI component in the event management interface
- **Session Token Generation**: Call the backend API to generate a temporary session token
- **Redirect Handler**: Implement the redirect logic to Hi.Events with proper parameters
- **Callback Handler**: Handle the return flow from Hi.Events after authentication
- **Success/Error States**: Display appropriate UI states during and after authentication

### 2. UI Components Needed

#### A. Add Ticketing Button Component
```typescript
interface AddTicketingButtonProps {
  eventId: string;
  accountId: number;
  onSuccess?: (data: any) => void;
  onError?: (error: Error) => void;
}
```

#### B. Authentication Modal/Dialog
- Loading state while generating session token
- Error state display
- Success state before redirect
- Information about the process for users

#### C. Callback Page Component
- Handle return from Hi.Events
- Parse query parameters
- Display success/error messages
- Redirect to appropriate page

### 3. JWT Token Handling and Session Token Generation

#### API Integration
```typescript
interface CrossAppSessionResponse {
  session_token: string;
  expires_at: string;
}

// POST /api/cross-app/generate-session
async function generateSessionToken(accountId: number): Promise<CrossAppSessionResponse> {
  const response = await fetch('/api/cross-app/generate-session', {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${getAuthToken()}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({ account_id: accountId })
  });
  
  if (!response.ok) {
    throw new Error('Failed to generate session token');
  }
  
  return response.json();
}
```

### 4. Redirect Flow to Hi.Events

#### Redirect Parameters
```typescript
interface HiEventsRedirectParams {
  session_token: string;
  return_url: string;
  app_id: string;
  account_id: number;
  event_id?: string;
  timestamp: number;
}

function redirectToHiEvents(params: HiEventsRedirectParams) {
  const hiEventsUrl = process.env.NEXT_PUBLIC_HI_EVENTS_URL || 'https://app.hi.events';
  const queryParams = new URLSearchParams({
    session_token: params.session_token,
    return_url: params.return_url,
    app_id: 'tuvens',
    account_id: params.account_id.toString(),
    event_id: params.event_id || '',
    timestamp: params.timestamp.toString()
  });
  
  window.location.href = `${hiEventsUrl}/auth/cross-app?${queryParams.toString()}`;
}
```

### 5. Callback Handling from Hi.Events

#### Callback URL Structure
The callback URL should be: `https://app.tuvens.com/events/hi-events/callback`

#### Query Parameters to Handle
```typescript
interface HiEventsCallbackParams {
  status: 'success' | 'error' | 'cancelled';
  event_id?: string;
  hi_events_event_id?: string;
  error_code?: string;
  error_message?: string;
  account_id?: string;
}
```

#### Callback Handler Implementation
```typescript
function handleHiEventsCallback() {
  const params = new URLSearchParams(window.location.search);
  const status = params.get('status');
  
  switch (status) {
    case 'success':
      // Handle successful integration
      const eventId = params.get('event_id');
      const hiEventsEventId = params.get('hi_events_event_id');
      // Update local state, show success message, redirect
      break;
      
    case 'error':
      // Handle error cases
      const errorCode = params.get('error_code');
      const errorMessage = params.get('error_message');
      // Display error to user
      break;
      
    case 'cancelled':
      // Handle user cancellation
      // Redirect back to event management
      break;
  }
}
```

### 6. Error Handling for Various Auth Flow Scenarios

#### Error Scenarios to Handle
1. **Session Token Generation Failure**
   - Network errors
   - Authentication errors (401)
   - Server errors (500)

2. **Redirect Failures**
   - Invalid Hi.Events URL
   - Browser blocking redirects

3. **Callback Errors**
   - Invalid session token
   - Expired session token
   - Account permission errors
   - Hi.Events service unavailable

#### Error Handling Implementation
```typescript
enum CrossAppErrorCode {
  SESSION_GENERATION_FAILED = 'SESSION_GENERATION_FAILED',
  INVALID_SESSION = 'INVALID_SESSION',
  EXPIRED_SESSION = 'EXPIRED_SESSION',
  INSUFFICIENT_PERMISSIONS = 'INSUFFICIENT_PERMISSIONS',
  NETWORK_ERROR = 'NETWORK_ERROR',
  UNKNOWN_ERROR = 'UNKNOWN_ERROR'
}

class CrossAppError extends Error {
  constructor(public code: CrossAppErrorCode, message: string) {
    super(message);
  }
}

// Error handler component
function CrossAppErrorDisplay({ error }: { error: CrossAppError }) {
  const errorMessages = {
    [CrossAppErrorCode.SESSION_GENERATION_FAILED]: 'Failed to connect with Hi.Events. Please try again.',
    [CrossAppErrorCode.INVALID_SESSION]: 'Your session is invalid. Please try again.',
    [CrossAppErrorCode.EXPIRED_SESSION]: 'Your session has expired. Please try again.',
    [CrossAppErrorCode.INSUFFICIENT_PERMISSIONS]: 'You don\'t have permission to perform this action.',
    [CrossAppErrorCode.NETWORK_ERROR]: 'Network error. Please check your connection.',
    [CrossAppErrorCode.UNKNOWN_ERROR]: 'An unexpected error occurred. Please try again.'
  };
  
  return (
    <Alert variant="error">
      {errorMessages[error.code] || errorMessages[CrossAppErrorCode.UNKNOWN_ERROR]}
    </Alert>
  );
}
```

### 7. Testing Requirements

#### Unit Tests
1. **Component Tests**
   - Add Ticketing button renders correctly
   - Loading states display properly
   - Error states handle all error codes
   - Success states redirect appropriately

2. **API Integration Tests**
   - Mock session token generation
   - Handle various API responses
   - Test retry logic

3. **Redirect Logic Tests**
   - Correct URL construction
   - Parameter encoding
   - Browser compatibility

#### Integration Tests
1. **Full Flow Test**
   - Click Add Ticketing → Generate token → Redirect → Handle callback
   - Test with different user permissions
   - Test with expired sessions

2. **Error Flow Tests**
   - Network failures at each step
   - Invalid responses
   - Timeout scenarios

#### E2E Tests
1. **Happy Path**
   - Complete integration flow with mock Hi.Events
   - Verify data persistence
   - Check UI updates

2. **Error Scenarios**
   - User cancellation
   - Session expiry during flow
   - Network interruptions

## Implementation Steps

1. **Create UI Components**
   - [ ] Add Ticketing button component
   - [ ] Authentication modal/loading component
   - [ ] Callback page component
   - [ ] Error display components

2. **Implement API Integration**
   - [ ] Session token generation service
   - [ ] Error handling utilities
   - [ ] Response type definitions

3. **Build Authentication Flow**
   - [ ] Session token generation logic
   - [ ] Redirect handler
   - [ ] Callback handler
   - [ ] State management integration

4. **Add Error Handling**
   - [ ] Define error types and codes
   - [ ] Implement error boundaries
   - [ ] Add user-friendly error messages
   - [ ] Implement retry logic where appropriate

5. **Testing**
   - [ ] Write unit tests for components
   - [ ] Write integration tests for API calls
   - [ ] Write E2E tests for complete flow
   - [ ] Test error scenarios

6. **Documentation**
   - [ ] Add JSDoc comments to all functions
   - [ ] Create user documentation
   - [ ] Document error codes and handling

## Environment Variables Required
```env
NEXT_PUBLIC_HI_EVENTS_URL=https://app.hi.events
NEXT_PUBLIC_HI_EVENTS_APP_ID=tuvens
```

## Security Considerations
1. Session tokens expire after 15 minutes (backend configured)
2. All API calls must include valid JWT authentication
3. Validate all callback parameters
4. Sanitize all user inputs
5. Use HTTPS for all communications

## Dependencies
- React/Next.js (existing)
- TypeScript (existing)
- Fetch API or Axios for HTTP requests
- React Router for navigation
- State management (Redux/Context API)

## Acceptance Criteria
1. Users can click "Add Ticketing" from event management page
2. Authentication flow completes successfully
3. Proper error messages displayed for all failure scenarios
4. Session tokens expire correctly
5. All tests pass with >80% coverage
6. No security vulnerabilities introduced
7. Accessible UI components (WCAG 2.1 AA compliant)

## Related Backend Endpoints
- `POST /api/cross-app/generate-session` - Generate session token
- `POST /api/cross-app/validate-session` - Validate session (backend-to-backend)
- `GET /api/cross-app/user-accounts` - Get user accounts (backend-to-backend)
- `POST /api/cross-app/validate-permission` - Check permissions (backend-to-backend)

## Notes
- The backend uses a shared secret for backend-to-backend authentication
- Session tokens are stored in the database with expiry times
- The integration is designed for single sign-on (SSO) experience
- Hi.Events will make backend calls to validate sessions

## References
- Backend implementation: `/api-nest/src/services/cross-app/`
- Hi.Events documentation: [To be provided]
- Cross-app authentication RFC: [To be provided]