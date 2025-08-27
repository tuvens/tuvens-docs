# Quick Start and Basic Setup Guide

This guide provides quick examples and basic setup instructions for integrating Tuvens frontend applications and components.

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
├── README.md                           - Main navigation guide
├── 01-quick-start-setup.md             - This quick start guide
├── 02-design-system-integration.md     - Design system and theming
├── 03-api-integration-patterns.md      - API services and patterns
├── 04-testing-error-handling.md        - Testing and error handling
├── 05-analytics-deployment.md          - Analytics and deployment
└── svelte-examples.md                  - Detailed Svelte-specific examples
```

## 🚧 Coming Soon
The following integration examples are planned for future releases:
- Cross-App Authentication patterns
- JWT Integration examples  
- Session Management samples
- Shared Components library
- Widget Embedding patterns
- API Integration examples (REST, GraphQL, WebSocket)
- Build and Deployment integration guides
- Testing and Monitoring patterns

---

**Next Steps:**
- [Design System Integration](./02-design-system-integration.md) - Learn about theming and component styling
- [API Integration Patterns](./03-api-integration-patterns.md) - Explore API services and error handling
- [Back to Main Guide](./README.md) - Return to the navigation overview