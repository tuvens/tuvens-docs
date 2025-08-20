# Analytics and Deployment Guide

This guide covers analytics integration, performance monitoring, and deployment strategies for Tuvens frontend applications.

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

### Advanced Analytics Patterns
```typescript
// Enhanced analytics with user journey tracking
import { AnalyticsContext, UserJourneyTracker } from '@tuvens/analytics';

class TuvensAnalyticsService {
  private analytics: TuvensAnalytics;
  private journeyTracker: UserJourneyTracker;
  
  constructor(config: AnalyticsConfig) {
    this.analytics = new TuvensAnalytics(config);
    this.journeyTracker = new UserJourneyTracker({
      sessionTimeout: 30 * 60 * 1000, // 30 minutes
      trackPageViews: true,
      trackUserInteractions: true
    });
  }

  // Track cross-app user journeys
  trackCrossAppNavigation(fromApp: string, toApp: string, context?: any) {
    this.analytics.track('cross_app_navigation', {
      from_app: fromApp,
      to_app: toApp,
      timestamp: new Date().toISOString(),
      session_id: this.journeyTracker.getSessionId(),
      journey_step: this.journeyTracker.getCurrentStep(),
      context
    });
    
    this.journeyTracker.addStep({
      type: 'navigation',
      app: toApp,
      timestamp: new Date().toISOString()
    });
  }

  // Track feature usage with cohort analysis
  trackFeatureUsage(feature: string, metadata?: Record<string, any>) {
    this.analytics.track('feature_used', {
      feature_name: feature,
      user_id: this.analytics.getUserId(),
      session_id: this.journeyTracker.getSessionId(),
      user_cohort: this.analytics.getUserCohort(),
      ...metadata
    });
  }

  // Track business metrics
  trackBusinessEvent(event: BusinessEvent) {
    this.analytics.track('business_event', {
      event_type: event.type,
      event_value: event.value,
      currency: event.currency || 'USD',
      user_id: this.analytics.getUserId(),
      timestamp: new Date().toISOString(),
      properties: event.properties
    });
  }

  // Track errors with context
  trackError(error: Error, context: ErrorContext) {
    this.analytics.track('error_occurred', {
      error_message: error.message,
      error_stack: error.stack,
      error_code: context.code,
      page_url: window.location.href,
      user_agent: navigator.userAgent,
      user_id: this.analytics.getUserId(),
      session_id: this.journeyTracker.getSessionId(),
      timestamp: new Date().toISOString()
    });
  }
}
```

### Performance Monitoring
```typescript
// Performance monitoring and optimization tracking
import { PerformanceMonitor, WebVitals } from '@tuvens/performance';

class TuvensPerformanceMonitor {
  private monitor: PerformanceMonitor;
  
  constructor(analytics: TuvensAnalyticsService) {
    this.monitor = new PerformanceMonitor({
      analytics,
      sampleRate: 0.1, // Monitor 10% of sessions
      trackWebVitals: true,
      trackResourceTiming: true
    });
  }

  // Track Core Web Vitals
  trackWebVitals() {
    WebVitals.getFCP(this.reportMetric('FCP'));
    WebVitals.getLCP(this.reportMetric('LCP'));
    WebVitals.getFID(this.reportMetric('FID'));
    WebVitals.getCLS(this.reportMetric('CLS'));
    WebVitals.getTTFB(this.reportMetric('TTFB'));
  }

  private reportMetric = (metricName: string) => (metric: any) => {
    this.monitor.track('web_vital', {
      metric_name: metricName,
      metric_value: metric.value,
      metric_id: metric.id,
      page_url: window.location.href,
      timestamp: new Date().toISOString()
    });
  };

  // Track API performance
  trackApiPerformance(endpoint: string, duration: number, success: boolean) {
    this.monitor.track('api_performance', {
      endpoint,
      duration,
      success,
      timestamp: new Date().toISOString()
    });
  }

  // Track render performance
  trackRenderPerformance(componentName: string, renderTime: number) {
    this.monitor.track('component_render', {
      component_name: componentName,
      render_time: renderTime,
      timestamp: new Date().toISOString()
    });
  }
}
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

### Advanced Deployment Configuration

#### Docker Deployment
```dockerfile
# Multi-stage Docker build for Tuvens frontend
FROM node:18-alpine as builder

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

# Production image
FROM nginx:alpine

# Copy custom nginx configuration
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built application
COPY --from=builder /app/build /usr/share/nginx/html

# Add health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:80/health || exit 1

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

#### Kubernetes Deployment
```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tuvens-frontend
  namespace: production
spec:
  replicas: 3
  selector:
    matchLabels:
      app: tuvens-frontend
  template:
    metadata:
      labels:
        app: tuvens-frontend
    spec:
      containers:
      - name: frontend
        image: tuvens/frontend:v1.0.0
        ports:
        - containerPort: 80
        env:
        - name: REACT_APP_API_URL
          valueFrom:
            configMapKeyRef:
              name: tuvens-config
              key: api-url
        - name: REACT_APP_HI_EVENTS_URL
          valueFrom:
            configMapKeyRef:
              name: tuvens-config
              key: hi-events-url
        resources:
          requests:
            memory: "128Mi"
            cpu: "100m"
          limits:
            memory: "256Mi"
            cpu: "200m"
        livenessProbe:
          httpGet:
            path: /health
            port: 80
          initialDelaySeconds: 30
          periodSeconds: 10
        readinessProbe:
          httpGet:
            path: /ready
            port: 80
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: tuvens-frontend-service
spec:
  selector:
    app: tuvens-frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  type: LoadBalancer
```

### CI/CD Pipeline Configuration
```yaml
# .github/workflows/deploy.yml
name: Deploy Tuvens Frontend

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

env:
  NODE_VERSION: '18'
  
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Run tests
      run: |
        npm run test:unit -- --coverage
        npm run test:integration
        npm run test:e2e
        
    - name: Upload coverage reports
      uses: codecov/codecov-action@v3
      
  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'
    
    steps:
    - uses: actions/checkout@v3
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: ${{ env.NODE_VERSION }}
        cache: 'npm'
        
    - name: Install dependencies
      run: npm ci
      
    - name: Build application
      run: npm run build
      env:
        REACT_APP_API_URL: ${{ secrets.PROD_API_URL }}
        REACT_APP_HI_EVENTS_URL: ${{ secrets.PROD_HI_EVENTS_URL }}
        REACT_APP_ANALYTICS_ID: ${{ secrets.ANALYTICS_ID }}
        
    - name: Deploy to Vercel
      uses: amondnet/vercel-action@v25
      with:
        vercel-token: ${{ secrets.VERCEL_TOKEN }}
        vercel-org-id: ${{ secrets.ORG_ID }}
        vercel-project-id: ${{ secrets.PROJECT_ID }}
        vercel-args: '--prod'
```

### Monitoring and Observability
```typescript
// Application monitoring setup
import { TuvensMonitoring } from '@tuvens/monitoring';

class MonitoringSetup {
  private monitoring: TuvensMonitoring;
  
  constructor() {
    this.monitoring = new TuvensMonitoring({
      service: 'tuvens-frontend',
      version: process.env.REACT_APP_VERSION,
      environment: process.env.NODE_ENV,
      tracingEnabled: true,
      metricsEnabled: true,
      loggingEnabled: true
    });
  }

  setupErrorTracking() {
    // Sentry integration
    this.monitoring.setupErrorTracking({
      dsn: process.env.REACT_APP_SENTRY_DSN,
      sampleRate: 1.0,
      tracesSampleRate: 0.1
    });
  }

  setupPerformanceMonitoring() {
    // New Relic integration
    this.monitoring.setupPerformanceMonitoring({
      licenseKey: process.env.REACT_APP_NEWRELIC_LICENSE_KEY,
      applicationId: process.env.REACT_APP_NEWRELIC_APP_ID,
      trackUserActions: true,
      trackAjaxRequests: true
    });
  }

  setupCustomMetrics() {
    // Custom business metrics
    this.monitoring.createMetric('ticketing_enabled_total', {
      type: 'counter',
      description: 'Total number of events with ticketing enabled'
    });
    
    this.monitoring.createMetric('cross_app_sessions_duration', {
      type: 'histogram',
      description: 'Duration of cross-app user sessions'
    });
  }
}
```

### Security and Compliance
```typescript
// Security headers and CSP configuration
export const securityConfig = {
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      scriptSrc: [
        "'self'",
        "'unsafe-inline'",
        "https://www.googletagmanager.com",
        "https://www.google-analytics.com"
      ],
      styleSrc: ["'self'", "'unsafe-inline'", "https://fonts.googleapis.com"],
      fontSrc: ["'self'", "https://fonts.gstatic.com"],
      imgSrc: ["'self'", "data:", "https:"],
      connectSrc: [
        "'self'",
        "https://api.tuvens.com",
        "https://tickets.tuvens.com",
        "wss://ws.tuvens.com"
      ]
    }
  },
  
  // HTTPS and secure headers
  forceHTTPS: true,
  hsts: {
    maxAge: 31536000,
    includeSubdomains: true,
    preload: true
  }
};
```

---

**Related Guides:**
- [Testing and Error Handling](./04-testing-error-handling.md) - Learn about testing patterns and error handling
- [API Integration Patterns](./03-api-integration-patterns.md) - Explore API integration strategies
- [Back to Main Guide](./README.md) - Return to navigation overview