# Environment Configuration

Ensure your frontend has access to the Hi.Events URL:

```typescript
// config/environment.ts
export const config = {
  hiEventsUrl: process.env.REACT_APP_HI_EVENTS_URL || 'https://tickets.tuvens.com',
  apiBaseUrl: process.env.REACT_APP_API_BASE_URL || 'http://localhost:3000',
};
```