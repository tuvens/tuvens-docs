# Design System Integration Guide

This guide covers how to integrate Tuvens design system and theme components into your frontend applications.

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

## 🧩 Component Usage Patterns

### Basic Component Import
```typescript
import { 
  Button, 
  Card, 
  Navigation, 
  Modal,
  Form,
  Input
} from '@tuvens/ui-components';
import { TuvensTheme } from '@tuvens/design-system';
```

### Theme Provider Setup
```typescript
// App.tsx - Root level theme provider
import { TuvensTheme } from '@tuvens/design-system';
import { theme } from './config/theme';

function App() {
  return (
    <TuvensTheme theme={theme}>
      <Router>
        <Routes>
          <Route path="/" element={<HomePage />} />
          <Route path="/events" element={<EventsPage />} />
        </Routes>
      </Router>
    </TuvensTheme>
  );
}
```

### Responsive Design Integration
```typescript
// Responsive utilities from design system
import { useBreakpoint, MediaQuery } from '@tuvens/design-system';

function ResponsiveEventCard({ event }) {
  const { isMobile, isTablet, isDesktop } = useBreakpoint();
  
  return (
    <EventCard>
      <MediaQuery minWidth="tablet">
        <div className="event-details-expanded">
          {/* Tablet and desktop layout */}
        </div>
      </MediaQuery>
      
      <MediaQuery maxWidth="mobile">
        <div className="event-details-compact">
          {/* Mobile layout */}
        </div>
      </MediaQuery>
    </EventCard>
  );
}
```

## 🎯 Advanced Theming

### Custom Theme Extensions
```typescript
// Extending the base Tuvens theme
import { createTuvensTheme, TuvensThemeConfig } from '@tuvens/design-system';

const customTheme: TuvensThemeConfig = {
  ...createTuvensTheme(),
  // Custom color palette
  colors: {
    primary: '#5C69E6',
    secondary: '#FF5A6D',
    accent: '#FFD669',
    neutral: '#071551',
    // Custom additions
    success: '#28A745',
    warning: '#FFC107',
    error: '#DC3545',
    // Context-specific colors
    ticketing: '#FF6B35',
    analytics: '#4ECDC4'
  },
  // Custom component variants
  components: {
    Button: {
      variants: {
        ticketing: {
          backgroundColor: 'ticketing',
          color: 'white',
          '&:hover': {
            backgroundColor: 'ticketingDark'
          }
        }
      }
    }
  }
};
```

### Dark Mode Support
```typescript
// Dark mode theme configuration
import { createDarkTheme } from '@tuvens/design-system';

const darkTheme = createDarkTheme({
  colors: {
    background: '#1a1a1a',
    surface: '#2d2d2d',
    primary: '#6366F1',
    secondary: '#EC4899',
    text: '#ffffff',
    textSecondary: '#a3a3a3'
  }
});

// Theme switching context
import { createContext, useContext, useState } from 'react';

const ThemeContext = createContext();

export function ThemeProvider({ children }) {
  const [isDark, setIsDark] = useState(false);
  const currentTheme = isDark ? darkTheme : lightTheme;
  
  return (
    <ThemeContext.Provider value={{ isDark, setIsDark, theme: currentTheme }}>
      <TuvensTheme theme={currentTheme}>
        {children}
      </TuvensTheme>
    </ThemeContext.Provider>
  );
}
```

## 🎨 Component Customization

### Creating Custom Components
```typescript
// Custom event card component following Tuvens patterns
import { Card, Button } from '@tuvens/ui-components';
import { useTheme } from '@tuvens/design-system';

export function EventTicketingCard({ event, onEnableTicketing }) {
  const theme = useTheme();
  
  return (
    <Card
      variant="elevated"
      sx={{
        padding: theme.spacing.lg,
        borderRadius: theme.borderRadius.md,
        transition: 'all 0.2s ease-in-out',
        '&:hover': {
          transform: 'translateY(-4px)',
          boxShadow: theme.shadows.elevated
        }
      }}
    >
      <div className="event-header">
        <h3>{event.title}</h3>
        <span className="event-date">
          {new Date(event.startDate).toLocaleDateString()}
        </span>
      </div>
      
      <div className="event-actions">
        <Button
          variant="ticketing"
          size="medium"
          onClick={() => onEnableTicketing(event.id)}
          startIcon={<TicketIcon />}
        >
          Enable Ticketing
        </Button>
      </div>
    </Card>
  );
}
```

### Style System Integration
```typescript
// Using Tuvens style system utilities
import { sx, css } from '@tuvens/design-system';

const eventCardStyles = css`
  ${sx({
    display: 'flex',
    flexDirection: 'column',
    gap: 'md',
    padding: 'lg',
    borderRadius: 'md',
    backgroundColor: 'surface',
    border: '1px solid',
    borderColor: 'border',
    transition: 'all 0.2s ease',
    
    '&:hover': {
      borderColor: 'primary',
      boxShadow: 'card'
    }
  })}
`;
```

---

**Related Guides:**
- [Quick Start and Basic Setup](./01-quick-start-setup.md) - Get started with basic integration
- [API Integration Patterns](./03-api-integration-patterns.md) - Learn about API services
- [Back to Main Guide](./README.md) - Return to navigation overview