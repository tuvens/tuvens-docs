# 🚀 Deployment and CI/CD

### Build Configuration

#### Vite Configuration
```typescript
// vite.config.ts
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';
import { resolve } from 'path';

export default defineConfig({
  plugins: [react()],
  resolve: {
    alias: {
      '@': resolve(__dirname, 'src'),
    },
  },
  build: {
    rollupOptions: {
      output: {
        manualChunks: {
          vendor: ['react', 'react-dom'],
          ui: ['@radix-ui/react-dialog', '@radix-ui/react-dropdown-menu'],
        },
      },
    },
  },
  define: {
    __APP_VERSION__: JSON.stringify(process.env.npm_package_version),
  },
});
```

### Environment Configuration

#### Environment Variables
```bash
# .env.example
VITE_API_URL=https://api.tuvens.com
VITE_HI_EVENTS_URL=https://tickets.tuvens.com
VITE_ANALYTICS_ID=G-XXXXXXXXXX
VITE_SENTRY_DSN=https://xxx@sentry.io/xxx
VITE_ENVIRONMENT=production
```

#### Configuration Management
```typescript
// config/index.ts
const config = {
  api: {
    baseUrl: import.meta.env.VITE_API_URL || 'http://localhost:3000',
    timeout: 10000,
  },
  hiEvents: {
    baseUrl: import.meta.env.VITE_HI_EVENTS_URL || 'https://tickets.tuvens.com',
    widgetUrl: import.meta.env.VITE_HI_EVENTS_WIDGET_URL || 'https://tickets.tuvens.com/widget',
  },
  analytics: {
    googleAnalyticsId: import.meta.env.VITE_ANALYTICS_ID,
    sentryDsn: import.meta.env.VITE_SENTRY_DSN,
  },
  features: {
    enableTicketing: import.meta.env.VITE_ENABLE_TICKETING === 'true',
    enableAnalytics: import.meta.env.VITE_ENABLE_ANALYTICS === 'true',
    debugMode: import.meta.env.DEV,
  },
} as const;

export default config;
```

---

**Maintained By**: Tuvens Frontend Team  
**Last Updated**: 2025-07-24  
**Version**: 1.0  
**Next Review**: 2025-10-24