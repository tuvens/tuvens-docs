# Testing and Error Handling Guide

This guide covers comprehensive testing strategies and error handling patterns for Tuvens frontend integrations.

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

## 🛡️ Advanced Error Handling

### Error Boundary Implementation
```typescript
// Advanced error boundary with recovery options
import React, { Component, ErrorInfo } from 'react';
import { TuvensErrorHandler, ErrorReport } from '@tuvens/error-handling';

interface ErrorBoundaryState {
  hasError: boolean;
  error: Error | null;
  errorId: string | null;
  retryCount: number;
}

class TuvensErrorBoundary extends Component<
  React.PropsWithChildren<{}>,
  ErrorBoundaryState
> {
  private maxRetries = 3;

  constructor(props: React.PropsWithChildren<{}>) {
    super(props);
    this.state = {
      hasError: false,
      error: null,
      errorId: null,
      retryCount: 0
    };
  }

  static getDerivedStateFromError(error: Error): Partial<ErrorBoundaryState> {
    return {
      hasError: true,
      error,
      errorId: generateErrorId()
    };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // Log error with context
    const errorReport: ErrorReport = {
      error,
      errorInfo,
      timestamp: new Date().toISOString(),
      url: window.location.href,
      userAgent: navigator.userAgent,
      userId: getCurrentUserId(),
      sessionId: getSessionId()
    };

    TuvensErrorHandler.logError(errorReport);
    
    // Send to error tracking service
    this.reportErrorToService(errorReport);
  }

  private reportErrorToService = async (errorReport: ErrorReport) => {
    try {
      await fetch('/api/errors', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(errorReport)
      });
    } catch (reportingError) {
      console.error('Failed to report error:', reportingError);
    }
  };

  private handleRetry = () => {
    if (this.state.retryCount < this.maxRetries) {
      this.setState(prevState => ({
        hasError: false,
        error: null,
        errorId: null,
        retryCount: prevState.retryCount + 1
      }));
    }
  };

  private handleReset = () => {
    this.setState({
      hasError: false,
      error: null,
      errorId: null,
      retryCount: 0
    });
  };

  render() {
    if (this.state.hasError) {
      const canRetry = this.state.retryCount < this.maxRetries;
      
      return (
        <div className="error-boundary-fallback">
          <h2>Something went wrong</h2>
          <p>{this.state.error?.message}</p>
          <p className="error-id">Error ID: {this.state.errorId}</p>
          
          <div className="error-actions">
            {canRetry && (
              <button onClick={this.handleRetry}>
                Try Again ({this.maxRetries - this.state.retryCount} attempts left)
              </button>
            )}
            <button onClick={this.handleReset}>Reset</button>
            <button onClick={() => window.location.reload()}>
              Reload Page
            </button>
          </div>
        </div>
      );
    }

    return this.props.children;
  }
}
```

### API Error Handling Strategies
```typescript
// Comprehensive API error handling with retry logic
import { RetryConfig, BackoffStrategy } from '@tuvens/api-client';

class TuvensApiErrorHandler {
  private retryConfig: RetryConfig = {
    maxAttempts: 3,
    backoffStrategy: BackoffStrategy.EXPONENTIAL,
    retryDelay: 1000,
    retryCondition: (error) => this.isRetryableError(error)
  };

  private isRetryableError(error: any): boolean {
    // Retry on network errors and 5xx server errors
    return !error.response || 
           error.response.status >= 500 ||
           error.code === 'NETWORK_ERROR';
  }

  async executeWithRetry<T>(
    operation: () => Promise<T>,
    context: string = 'API Operation'
  ): Promise<T> {
    let lastError: Error;
    
    for (let attempt = 1; attempt <= this.retryConfig.maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (error) {
        lastError = error as Error;
        
        if (!this.isRetryableError(error) || attempt === this.retryConfig.maxAttempts) {
          throw this.enhanceError(error, context, attempt);
        }
        
        // Calculate backoff delay
        const delay = this.calculateBackoffDelay(attempt);
        await this.sleep(delay);
        
        console.warn(`${context} failed (attempt ${attempt}/${this.retryConfig.maxAttempts}). Retrying in ${delay}ms...`);
      }
    }
    
    throw this.enhanceError(lastError!, context, this.retryConfig.maxAttempts);
  }

  private enhanceError(error: any, context: string, attempts: number): TuvensError {
    return new TuvensError({
      code: error.code || 'API_ERROR',
      message: `${context} failed after ${attempts} attempts: ${error.message}`,
      originalError: error,
      context: {
        operation: context,
        attempts,
        timestamp: new Date().toISOString()
      }
    });
  }

  private calculateBackoffDelay(attempt: number): number {
    const baseDelay = this.retryConfig.retryDelay;
    
    switch (this.retryConfig.backoffStrategy) {
      case BackoffStrategy.EXPONENTIAL:
        return baseDelay * Math.pow(2, attempt - 1);
      case BackoffStrategy.LINEAR:
        return baseDelay * attempt;
      case BackoffStrategy.FIXED:
      default:
        return baseDelay;
    }
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
```

## 🧪 Comprehensive Testing Patterns

### Unit Testing Components
```typescript
// Testing Tuvens components with proper mocking
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { TuvensTestProvider } from '@tuvens/testing-utils';
import { EventTicketingCard } from '../components/EventTicketingCard';

describe('EventTicketingCard', () => {
  const mockEvent = {
    id: 'event-123',
    title: 'Test Event',
    startDate: '2025-08-01T19:00:00Z',
    ticketingEnabled: false
  };

  const renderWithProviders = (component: React.ReactElement) => {
    return render(
      <TuvensTestProvider
        theme="light"
        apiMocks={{
          '/api/events/event-123/ticketing': {
            method: 'POST',
            response: { success: true, hiEventsEventId: 'hi-123' }
          }
        }}
      >
        {component}
      </TuvensTestProvider>
    );
  };

  it('should render event details correctly', () => {
    renderWithProviders(
      <EventTicketingCard 
        event={mockEvent} 
        onEnableTicketing={jest.fn()} 
      />
    );

    expect(screen.getByText('Test Event')).toBeInTheDocument();
    expect(screen.getByText('Aug 1, 2025')).toBeInTheDocument();
  });

  it('should call onEnableTicketing when button is clicked', async () => {
    const mockOnEnableTicketing = jest.fn();
    
    renderWithProviders(
      <EventTicketingCard 
        event={mockEvent} 
        onEnableTicketing={mockOnEnableTicketing} 
      />
    );

    fireEvent.click(screen.getByText('Enable Ticketing'));
    
    await waitFor(() => {
      expect(mockOnEnableTicketing).toHaveBeenCalledWith('event-123');
    });
  });

  it('should handle enabling ticketing errors gracefully', async () => {
    const mockOnEnableTicketing = jest.fn().mockRejectedValue(
      new Error('API Error')
    );

    renderWithProviders(
      <EventTicketingCard 
        event={mockEvent} 
        onEnableTicketing={mockOnEnableTicketing} 
      />
    );

    fireEvent.click(screen.getByText('Enable Ticketing'));
    
    await waitFor(() => {
      expect(screen.getByText(/error enabling ticketing/i)).toBeInTheDocument();
    });
  });
});
```

### Integration Testing Patterns
```typescript
// End-to-end integration testing
import { setupTuvensE2ETests, TuvensE2ETestUtils } from '@tuvens/e2e-testing';

describe('Cross-App Integration E2E', () => {
  let testUtils: TuvensE2ETestUtils;

  beforeAll(async () => {
    testUtils = await setupTuvensE2ETests({
      baseUrl: 'http://localhost:3000',
      hiEventsUrl: 'http://localhost:3001',
      mockApis: true
    });
  });

  afterAll(async () => {
    await testUtils.cleanup();
  });

  it('should complete full cross-app ticketing flow', async () => {
    // 1. Create event in main app
    await testUtils.navigateTo('/events/new');
    await testUtils.fillForm({
      title: 'E2E Test Event',
      date: '2025-08-01',
      time: '19:00'
    });
    await testUtils.click('[data-testid="create-event"]');

    // 2. Enable ticketing
    await testUtils.waitForElement('[data-testid="enable-ticketing"]');
    await testUtils.click('[data-testid="enable-ticketing"]');

    // 3. Verify cross-app session generation
    await testUtils.waitForElement('[data-testid="ticketing-enabled"]');
    const ticketingUrl = await testUtils.getAttribute(
      '[data-testid="view-tickets-link"]', 
      'href'
    );
    
    expect(ticketingUrl).toContain('tickets.tuvens.com');
    expect(ticketingUrl).toContain('token=');

    // 4. Test cross-app navigation
    await testUtils.click('[data-testid="view-tickets-link"]');
    await testUtils.switchToTab(1);
    
    await testUtils.waitForUrl(/tickets\.tuvens\.com/);
    await testUtils.waitForElement('[data-testid="event-tickets"]');
    
    // Verify event data was transferred correctly
    expect(await testUtils.getText('[data-testid="event-title"]'))
      .toBe('E2E Test Event');
  });
});
```

### Error Recovery Testing
```typescript
// Testing error recovery scenarios
describe('Error Recovery', () => {
  it('should recover from temporary API failures', async () => {
    // Simulate API failure followed by recovery
    const apiMock = jest.fn()
      .mockRejectedValueOnce(new Error('Network Error'))
      .mockRejectedValueOnce(new Error('Server Error'))  
      .mockResolvedValueOnce({ success: true });

    const { result } = renderHook(() => useApiWithRetry('/api/events', apiMock));

    // Should eventually succeed after retries
    await waitFor(() => {
      expect(result.current.data).toEqual({ success: true });
      expect(result.current.error).toBeNull();
    });

    // Should have made 3 attempts
    expect(apiMock).toHaveBeenCalledTimes(3);
  });

  it('should show user-friendly error messages', async () => {
    const { result } = renderHook(() => useApiWithRetry('/api/events'));
    
    // Simulate different error types
    const testCases = [
      {
        error: { response: { status: 401 } },
        expectedMessage: 'Authentication expired. Please login again.'
      },
      {
        error: { response: { status: 403 } },
        expectedMessage: 'You do not have permission to access this resource.'
      },
      {
        error: { response: { status: 429 } },
        expectedMessage: 'Too many requests. Please try again later.'
      },
      {
        error: { code: 'NETWORK_ERROR' },
        expectedMessage: 'Network connection failed. Please check your connection.'
      }
    ];

    for (const testCase of testCases) {
      // Test each error scenario
      const errorHandler = new TuvensErrorHandler();
      const friendlyError = errorHandler.getFriendlyMessage(testCase.error);
      
      expect(friendlyError).toBe(testCase.expectedMessage);
    }
  });
});
```

---

**Related Guides:**
- [API Integration Patterns](./03-api-integration-patterns.md) - Learn about API services and patterns
- [Analytics and Deployment](./05-analytics-deployment.md) - Explore deployment and monitoring
- [Back to Main Guide](./README.md) - Return to navigation overview