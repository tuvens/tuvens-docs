# 📊 Analytics and Monitoring

### User Analytics

#### Event Tracking
```typescript
// Analytics service
class AnalyticsService {
  private static isProduction = process.env.NODE_ENV === 'production';

  static track(event: string, properties?: Record<string, any>) {
    if (!this.isProduction) {
      console.log('Analytics:', event, properties);
      return;
    }

    // Google Analytics 4
    if (typeof gtag !== 'undefined') {
      gtag('event', event, properties);
    }

    // Custom analytics
    fetch('/api/analytics/track', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ event, properties, timestamp: Date.now() }),
    }).catch(console.error);
  }

  static identify(userId: string, traits?: Record<string, any>) {
    if (!this.isProduction) return;

    gtag('config', 'GA_MEASUREMENT_ID', {
      user_id: userId,
      custom_map: traits,
    });
  }

  static page(pageName: string, properties?: Record<string, any>) {
    if (!this.isProduction) return;

    gtag('event', 'page_view', {
      page_title: pageName,
      ...properties,
    });
  }
}

// Usage in components
const EventCard = ({ event }: { event: Event }) => {
  const handleTicketingClick = () => {
    AnalyticsService.track('ticketing_button_clicked', {
      event_id: event.id,
      event_title: event.title,
      source: 'event_card',
    });
  };

  return (
    <div>
      <h3>{event.title}</h3>
      <button onClick={handleTicketingClick}>
        Add Ticketing
      </button>
    </div>
  );
};
```

### Error Monitoring

#### Error Boundary with Reporting
```typescript
// Error boundary with Sentry integration
import * as Sentry from '@sentry/react';

class ErrorBoundary extends Component<ErrorBoundaryProps, ErrorBoundaryState> {
  constructor(props: ErrorBoundaryProps) {
    super(props);
    this.state = { hasError: false, error: null };
  }

  static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { hasError: true, error };
  }

  componentDidCatch(error: Error, errorInfo: ErrorInfo) {
    // Log to Sentry
    Sentry.captureException(error, {
      contexts: {
        react: {
          componentStack: errorInfo.componentStack,
        },
      },
    });

    // Log to custom service
    fetch('/api/errors', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        error: error.message,
        stack: error.stack,
        componentStack: errorInfo.componentStack,
        timestamp: Date.now(),
        userAgent: navigator.userAgent,
        url: window.location.href,
      }),
    }).catch(console.error);
  }

  render() {
    if (this.state.hasError) {
      return (
        <div className="error-fallback">
          <h2>Something went wrong</h2>
          <p>We've been notified of this error and are working to fix it.</p>
          <button onClick={() => window.location.reload()}>
            Reload Page
          </button>
        </div>
      );
    }

    return this.props.children;
  }
}
```