# API Integration Patterns Guide

This guide covers REST API services, error handling patterns, and authentication integration for Tuvens applications.

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

## 🔐 Authentication Integration

### Cross-App Authentication Service
```typescript
// Enhanced cross-app authentication
import { CrossAppAuth, AuthConfig } from '@tuvens/cross-app-auth';

class TuvensAuthService {
  private auth: CrossAppAuth;
  
  constructor(config: AuthConfig) {
    this.auth = new CrossAppAuth({
      baseUrl: config.baseUrl,
      clientId: config.clientId,
      redirectUri: config.redirectUri,
      tokenStorage: 'localStorage',
      refreshTokens: true
    });
  }

  // Generate session for cross-app navigation
  async generateSession(targetApp: string, accountId?: string) {
    try {
      const session = await this.auth.generateSession({
        targetApp,
        accountId,
        expiresIn: 3600 // 1 hour
      });
      
      return {
        success: true,
        token: session.token,
        redirectUrl: `https://${targetApp}.tuvens.com/auth/cross-app?token=${session.token}`
      };
    } catch (error) {
      return {
        success: false,
        error: this.handleAuthError(error)
      };
    }
  }

  // Handle authentication errors
  private handleAuthError(error: any) {
    switch (error.code) {
      case 'INVALID_TOKEN':
        return 'Authentication session expired. Please login again.';
      case 'INSUFFICIENT_PERMISSIONS':
        return 'You do not have permission to access this application.';
      case 'ACCOUNT_NOT_FOUND':
        return 'Account not found or inactive.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  // Token management
  async refreshToken() {
    return this.auth.refreshToken();
  }

  async logout() {
    return this.auth.logout();
  }

  isAuthenticated(): boolean {
    return this.auth.isAuthenticated();
  }
}
```

## 📡 Advanced API Patterns

### Request/Response Interceptors
```typescript
// Advanced request interceptors for cross-app integration
import { ApiInterceptor } from '@tuvens/api-client';

class TuvensApiInterceptors {
  static requestInterceptor: ApiInterceptor = {
    onRequest: (config) => {
      // Add authentication headers
      const token = localStorage.getItem('tuvens_auth_token');
      if (token) {
        config.headers['Authorization'] = `Bearer ${token}`;
      }

      // Add correlation ID for cross-app tracing
      config.headers['X-Correlation-ID'] = generateCorrelationId();

      // Add app context
      config.headers['X-Source-App'] = process.env.REACT_APP_NAME;
      
      return config;
    },
    
    onRequestError: (error) => {
      console.error('Request failed:', error);
      return Promise.reject(error);
    }
  };

  static responseInterceptor: ApiInterceptor = {
    onResponse: (response) => {
      // Log successful responses for debugging
      if (process.env.NODE_ENV === 'development') {
        console.log('API Response:', response.config.url, response.status);
      }
      
      return response;
    },
    
    onResponseError: (error) => {
      // Handle specific error codes
      switch (error.response?.status) {
        case 401:
          // Token expired, redirect to login
          window.location.href = '/login';
          break;
        case 403:
          // Insufficient permissions
          throw new TuvensError({
            code: 'INSUFFICIENT_PERMISSIONS',
            message: 'You do not have permission to perform this action'
          });
        case 429:
          // Rate limited
          throw new TuvensError({
            code: 'RATE_LIMITED',
            message: 'Too many requests. Please try again later.',
            retryAfter: error.response.headers['retry-after']
          });
      }
      
      return Promise.reject(error);
    }
  };
}
```

### Data Fetching Hooks
```typescript
// React hooks for API integration
import { useState, useEffect, useCallback } from 'react';
import { TuvensApiService } from './TuvensApiService';

// Generic API hook
export function useApi<T>(endpoint: string, options: ApiOptions = {}) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<TuvensError | null>(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);
      
      const response = await TuvensApiService.get(endpoint, options);
      setData(response.data);
    } catch (err) {
      setError(TuvensErrorHandler.handleApiError(err));
    } finally {
      setLoading(false);
    }
  }, [endpoint, options]);

  useEffect(() => {
    fetchData();
  }, [fetchData]);

  return { data, loading, error, refetch: fetchData };
}

// Specific hooks for common operations
export function useEvents() {
  return useApi<Event[]>('/api/events');
}

export function useEvent(eventId: string) {
  return useApi<Event>(`/api/events/${eventId}`);
}

export function useCrossAppAuth() {
  const [authService] = useState(() => new TuvensAuthService({
    baseUrl: process.env.REACT_APP_API_URL!,
    clientId: process.env.REACT_APP_AUTH_CLIENT_ID!,
    redirectUri: `${window.location.origin}/auth/callback`
  }));

  const generateSession = useCallback((targetApp: string, accountId?: string) => {
    return authService.generateSession(targetApp, accountId);
  }, [authService]);

  return {
    generateSession,
    isAuthenticated: authService.isAuthenticated(),
    logout: () => authService.logout()
  };
}
```

## 🔄 Real-time Integration

### WebSocket Integration
```typescript
// WebSocket service for real-time updates
import { WebSocketService } from '@tuvens/websocket-client';

class TuvensWebSocketService {
  private ws: WebSocketService;
  
  constructor() {
    this.ws = new WebSocketService({
      url: process.env.REACT_APP_WEBSOCKET_URL!,
      reconnectAttempts: 5,
      reconnectInterval: 3000
    });
  }

  // Subscribe to event updates
  subscribeToEventUpdates(eventId: string, callback: (update: EventUpdate) => void) {
    this.ws.subscribe(`event:${eventId}:updates`, callback);
  }

  // Subscribe to ticketing updates
  subscribeToTicketingUpdates(eventId: string, callback: (update: TicketingUpdate) => void) {
    this.ws.subscribe(`event:${eventId}:ticketing`, callback);
  }

  // Cross-app notifications
  subscribeToNotifications(userId: string, callback: (notification: Notification) => void) {
    this.ws.subscribe(`user:${userId}:notifications`, callback);
  }

  disconnect() {
    this.ws.disconnect();
  }
}
```

---

**Related Guides:**
- [Design System Integration](./02-design-system-integration.md) - Learn about theming and components
- [Testing and Error Handling](./04-testing-error-handling.md) - Explore testing patterns
- [Back to Main Guide](./README.md) - Return to navigation overview