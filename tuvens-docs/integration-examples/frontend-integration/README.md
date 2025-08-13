# Tuvens Frontend Integration Examples

This directory contains practical examples and code samples for integrating various Tuvens frontend applications and components.

## 📚 Available Examples

### Framework-Specific Examples
- **[Svelte Integration Examples](./svelte-examples.md)** - Complete Svelte integration patterns and code samples

### 🚧 Coming Soon
The following integration examples are planned for future releases:
- Cross-App Authentication patterns
- JWT Integration examples  
- Session Management samples
- Shared Components library
- Widget Embedding patterns
- API Integration examples (REST, GraphQL, WebSocket)
- Build and Deployment integration guides
- Testing and Monitoring patterns

## 🎯 Quick Start Examples

### Basic Hi.Events Integration
```typescript
// Simple Hi.Events ticketing integration
import { HiEventsService } from '@tuvens/hi-events-integration';

const hiEvents = new HiEventsService({
  baseUrl: 'https://tickets.tuvens.com',
  apiKey: process.env.HI_EVENTS_API_KEY
});

// Enable ticketing for an event
await hiEvents.enableTicketing({
  eventId: 'tuvens-event-123',
  eventData: {
    title: 'Sample Event',
    startDate: '2025-08-01T19:00:00Z',
    endDate: '2025-08-01T23:00:00Z'
  }
});
```

### Cross-App Authentication
```typescript
// Cross-app authentication flow
import { CrossAppAuth } from '@tuvens/cross-app-auth';

const auth = new CrossAppAuth({
  baseUrl: process.env.REACT_APP_API_URL,
  tokenStorage: 'localStorage'
});

// Generate session for Hi.Events
const session = await auth.generateSession({
  targetApp: 'hi-events',
  accountId: user.accountId
});

// Redirect to Hi.Events with session
window.open(`https://tickets.tuvens.com/auth/cross-app?token=${session.token}`);
```

### Shared Component Usage
```typescript
// Using shared Tuvens components
import { Button, Card, Navigation } from '@tuvens/ui-components';
import { TuvensTheme } from '@tuvens/design-system';

function EventPage({ event }) {
  return (
    <TuvensTheme>
      <Navigation user={currentUser} />
      <Card>
        <h1>{event.title}</h1>
        <Button
          variant="primary"
          onClick={() => enableTicketing(event)}
        >
          Add Ticketing
        </Button>
      </Card>
    </TuvensTheme>
  );
}
```

## 🔧 Development Setup

### Prerequisites
```bash
# Install Tuvens integration packages
npm install @tuvens/ui-components
npm install @tuvens/cross-app-auth
npm install @tuvens/hi-events-integration
npm install @tuvens/design-system
```

### Environment Configuration
```bash
# .env.local
REACT_APP_API_URL=https://api.tuvens.com
REACT_APP_HI_EVENTS_URL=https://tickets.tuvens.com
REACT_APP_AUTH_DOMAIN=auth.tuvens.com
REACT_APP_ANALYTICS_ID=your-analytics-id
```

### Build Configuration
```json
// package.json
{
  "dependencies": {
    "@tuvens/ui-components": "^2.1.0",
    "@tuvens/cross-app-auth": "^1.0.0",
    "@tuvens/design-system": "^3.0.0"
  },
  "scripts": {
    "build:tuvens": "npm run build && npm run test:integration",
    "test:cross-app": "jest --testPathPattern=cross-app",
    "dev:with-mocks": "npm run start -- --mock-api"
  }
}
```

## 📁 Current Structure

```
integration-examples/frontend-integration/
├── README.md              - This comprehensive integration guide
└── svelte-examples.md     - Detailed Svelte-specific examples
```

_Additional example directories and files will be added as integration patterns are developed._

## 🎨 Design System Integration

### Theme Configuration
```typescript
// Configure Tuvens theme
import { createTuvensTheme } from '@tuvens/design-system';

const theme = createTuvensTheme({
  colors: {
    primary: '#5C69E6',    // Tuvens Blue
    secondary: '#FF5A6D',  // Coral
    accent: '#FFD669',     // Yellow
    neutral: '#071551'     // Tuvens Navy
  },
  typography: {
    fontFamily: 'Montserrat, sans-serif',
    headingSizes: {
      h1: '2.5rem',
      h2: '2rem',
      h3: '1.5rem'
    }
  },
  spacing: {
    unit: 8, // 8px base unit
    sizes: {
      xs: '0.5rem',
      sm: '1rem',
      md: '1.5rem',
      lg: '2rem',
      xl: '3rem'
    }
  }
});
```

### Component Styling
```typescript
// Styled components with Tuvens theme
import styled from 'styled-components';
import { TuvensButton } from '@tuvens/ui-components';

const EventCard = styled.div`
  background: ${props => props.theme.colors.white};
  border-radius: ${props => props.theme.borderRadius.md};
  padding: ${props => props.theme.spacing.lg};
  box-shadow: ${props => props.theme.shadows.card};
  
  &:hover {
    transform: translateY(-2px);
    box-shadow: ${props => props.theme.shadows.elevated};
  }
`;

const TicketingButton = styled(TuvensButton)`
  background: ${props => props.theme.colors.primary};
  color: white;
  
  &:hover {
    background: ${props => props.theme.colors.primaryDark};
  }
`;
```

## 🔌 API Integration Patterns

### REST API Service
```typescript
// Generic API service for Tuvens applications
import { ApiClient } from '@tuvens/api-client';

class TuvensApiService {
  private client: ApiClient;

  constructor(baseUrl: string) {
    this.client = new ApiClient({
      baseUrl,
      interceptors: {
        request: this.addAuthHeader,
        response: this.handleErrors
      }
    });
  }

  private addAuthHeader = (config) => {
    const token = localStorage.getItem('tuvens_auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  };

  private handleErrors = (error) => {
    if (error.status === 401) {
      // Redirect to login
      window.location.href = '/login';
    }
    return Promise.reject(error);
  };

  // Event management endpoints
  async getEvents() {
    return this.client.get('/api/events');
  }

  async createEvent(eventData) {
    return this.client.post('/api/events', eventData);
  }

  async enableTicketing(eventId, ticketingData) {
    return this.client.post(`/api/events/${eventId}/ticketing`, ticketingData);
  }

  // Cross-app authentication
  async generateCrossAppSession(accountId?) {
    return this.client.post('/api/cross-app/generate-session', { account_id: accountId });
  }
}
```

### Error Handling Pattern
```typescript
// Standardized error handling for Tuvens applications
import { TuvensError, ErrorBoundary } from '@tuvens/error-handling';

class TuvensErrorHandler {
  static handleApiError(error: any): TuvensError {
    return new TuvensError({
      code: error.code || 'UNKNOWN_ERROR',
      message: error.message || 'An unexpected error occurred',
      details: error.details,
      timestamp: new Date().toISOString(),
      context: {
        url: window.location.href,
        userAgent: navigator.userAgent
      }
    });
  }

  static logError(error: TuvensError) {
    // Send to error tracking service
    console.error('Tuvens Error:', error);
    
    // Optional: Send to analytics
    if (window.gtag) {
      window.gtag('event', 'exception', {
        description: error.message,
        fatal: false
      });
    }
  }
}

// React Error Boundary
function TuvensErrorBoundary({ children }) {
  return (
    <ErrorBoundary
      onError={TuvensErrorHandler.logError}
      fallback={({ error }) => (
        <div className="error-fallback">
          <h2>Something went wrong</h2>
          <p>{error.message}</p>
          <button onClick={() => window.location.reload()}>
            Reload Page
          </button>
        </div>
      )}
    >
      {children}
    </ErrorBoundary>
  );
}
```

## 🧪 Testing Integration

### Test Setup
```typescript
// Jest configuration for Tuvens integration testing
import { setupTuvensTests } from '@tuvens/testing-utils';

// Global test setup
beforeAll(async () => {
  await setupTuvensTests({
    mockApi: true,
    mockAuth: true,
    mockWidgets: true
  });
});

// Example integration test
describe('Hi.Events Integration', () => {
  it('should enable ticketing for an event', async () => {
    const mockEvent = {
      id: 'test-event-123',
      title: 'Test Event',
      startDate: '2025-08-01T19:00:00Z'
    };

    const result = await hiEventsService.enableTicketing(mockEvent);
    
    expect(result.success).toBe(true);
    expect(result.hiEventsEventId).toBeDefined();
  });

  it('should handle authentication errors gracefully', async () => {
    // Mock expired token
    localStorage.setItem('tuvens_auth_token', 'expired-token');

    const result = await hiEventsService.enableTicketing(mockEvent);
    
    expect(result.error).toBe('AUTHENTICATION_FAILED');
    expect(window.location.href).toContain('/login');
  });
});
```

## 📊 Analytics Integration

### Event Tracking
```typescript
// Analytics integration for Tuvens applications
import { TuvensAnalytics } from '@tuvens/analytics';

const analytics = new TuvensAnalytics({
  trackingId: process.env.REACT_APP_ANALYTICS_ID,
  userId: currentUser?.id,
  appName: 'eventdigest-ai'
});

// Track cross-app events
analytics.track('ticketing_enabled', {
  eventId: 'event-123',
  platform: 'hi-events',
  timestamp: new Date().toISOString()
});

// Track user interactions
analytics.track('button_clicked', {
  buttonText: 'Add Ticketing',
  location: 'event-edit-page',
  userId: currentUser.id
});

// Track performance metrics
analytics.track('page_load_time', {
  page: 'event-details',
  loadTime: performance.now(),
  route: '/events/123'
});
```

## 🚀 Deployment Examples

### Build Process
```bash
#!/bin/bash
# Tuvens frontend build script

# Install dependencies
npm ci

# Run tests
npm run test:unit
npm run test:integration

# Build application
npm run build

# Optimize assets
npm run optimize:images
npm run optimize:bundle

# Deploy to Vercel
vercel deploy --prod
```

### Environment Management
```typescript
// Environment configuration management
export const config = {
  api: {
    baseUrl: process.env.REACT_APP_API_URL || 'http://localhost:3000',
    timeout: 10000
  },
  hiEvents: {
    baseUrl: process.env.REACT_APP_HI_EVENTS_URL || 'https://tickets.tuvens.com',
    widgetUrl: process.env.REACT_APP_HI_EVENTS_WIDGET_URL || 'https://tickets.tuvens.com/widget'
  },
  auth: {
    domain: process.env.REACT_APP_AUTH_DOMAIN || 'auth.tuvens.com',
    clientId: process.env.REACT_APP_AUTH_CLIENT_ID,
    redirectUri: process.env.REACT_APP_AUTH_REDIRECT_URI
  },
  features: {
    enableTicketing: process.env.REACT_APP_ENABLE_TICKETING === 'true',
    enableAnalytics: process.env.REACT_APP_ENABLE_ANALYTICS === 'true',
    debugMode: process.env.NODE_ENV === 'development'
  }
};
```

---

**Ready to integrate?** Choose the appropriate example directory for your specific integration needs and follow the detailed implementation guides.