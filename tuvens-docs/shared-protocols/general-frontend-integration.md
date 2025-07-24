# General Frontend Integration Guide

## 🎯 Overview

This guide provides comprehensive standards and patterns for frontend integration across the Tuvens ecosystem, ensuring consistency, performance, and maintainability across all frontend applications.

## 🏗️ Architecture Standards

### Technology Stack Requirements

#### Core Technologies
- **Framework**: React 18+ or Svelte 5+ (preferred)
- **TypeScript**: Strict mode enabled
- **Build Tool**: Vite 5+ or Next.js 14+
- **Styling**: TailwindCSS 4+ with Tuvens design system
- **State Management**: Zustand, Redux Toolkit, or SvelteKit stores
- **Testing**: Vitest + Testing Library + Playwright

#### Package Management
- **Node.js**: v18+ (LTS recommended)
- **Package Manager**: npm (with package-lock.json) or pnpm
- **Dependency Updates**: Automated via Dependabot or Renovate

### Project Structure Standards

```
src/
├── components/                 # Reusable UI components
│   ├── ui/                    # Base design system components
│   ├── forms/                 # Form-specific components
│   ├── layout/                # Layout components
│   └── features/              # Feature-specific components
├── hooks/                     # Custom React hooks / Svelte actions
├── services/                  # API services and external integrations
├── stores/                    # State management
├── utils/                     # Utility functions and helpers
├── types/                     # TypeScript type definitions
├── styles/                    # Global styles and Tailwind config
├── assets/                    # Static assets (images, icons, fonts)
├── tests/                     # Test utilities and setup
└── app/                       # Application routes and pages
    ├── (auth)/               # Authentication-related pages
    ├── (dashboard)/          # Dashboard and management pages
    ├── (public)/            # Public-facing pages
    └── api/                 # API routes (if using Next.js)
```

### Component Architecture

#### Component Hierarchy
```typescript
// Base Component Pattern
interface ComponentProps {
  className?: string;
  children?: React.ReactNode;
  // Feature-specific props
}

const Component = ({ className, children, ...props }: ComponentProps) => {
  return (
    <div className={cn('base-styles', className)} {...props}>
      {children}
    </div>
  );
};

// Compound Component Pattern
const Card = {
  Root: CardRoot,
  Header: CardHeader,
  Body: CardBody,
  Footer: CardFooter,
};

// Usage
<Card.Root>
  <Card.Header>Title</Card.Header>
  <Card.Body>Content</Card.Body>
  <Card.Footer>Actions</Card.Footer>
</Card.Root>
```

#### Component Categories
1. **Base Components**: Button, Input, Card, Modal (from design system)
2. **Composite Components**: DataTable, Form, SearchFilter
3. **Feature Components**: EventCard, TicketWidget, UserProfile
4. **Layout Components**: Header, Sidebar, Footer, PageLayout
5. **Page Components**: EventsPage, DashboardPage, SettingsPage

## 🎨 Design System Integration

### Tuvens Design System

#### Color Palette
```typescript
// tailwind.config.js
const colors = {
  primary: {
    50: '#EEF0FF',
    100: '#E0E4FF',
    500: '#5C69E6',  // Tuvens Blue
    600: '#4D5AD4',
    900: '#071551',  // Tuvens Navy
  },
  secondary: {
    500: '#FF5A6D',  // Coral
  },
  accent: {
    500: '#FFD669',  // Yellow
  },
  neutral: {
    50: '#F9FAFB',
    100: '#F3F4F6',
    500: '#6B7280',
    900: '#111827',
  },
};
```

#### Typography System
```typescript
// Typography configuration
const typography = {
  fontFamily: {
    sans: ['Montserrat', 'system-ui', 'sans-serif'],
    mono: ['JetBrains Mono', 'monospace'],
  },
  fontSize: {
    xs: ['0.75rem', '1rem'],
    sm: ['0.875rem', '1.25rem'],
    base: ['1rem', '1.5rem'],
    lg: ['1.125rem', '1.75rem'],
    xl: ['1.25rem', '1.75rem'],
    '2xl': ['1.5rem', '2rem'],
    '3xl': ['1.875rem', '2.25rem'],
    '4xl': ['2.25rem', '2.5rem'],
  },
  fontWeight: {
    normal: '400',
    medium: '500',
    semibold: '600',
    bold: '700',
  },
};
```

#### Component Styling Standards
```typescript
// Button component example
const buttonVariants = {
  primary: 'bg-primary-500 hover:bg-primary-600 text-white',
  secondary: 'bg-secondary-500 hover:bg-secondary-600 text-white',
  outline: 'border-2 border-primary-500 text-primary-500 hover:bg-primary-50',
  ghost: 'text-primary-500 hover:bg-primary-50',
};

const buttonSizes = {
  sm: 'px-3 py-1.5 text-sm',
  md: 'px-4 py-2 text-base',
  lg: 'px-6 py-3 text-lg',
};

// Usage with className utility
const Button = ({ variant = 'primary', size = 'md', className, ...props }) => {
  return (
    <button
      className={cn(
        'inline-flex items-center justify-center rounded-md font-medium transition-colors',
        'focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-primary-500',
        'disabled:pointer-events-none disabled:opacity-50',
        buttonVariants[variant],
        buttonSizes[size],
        className
      )}
      {...props}
    />
  );
};
```

### Responsive Design Standards

#### Breakpoint System
```typescript
// tailwind.config.js
const screens = {
  'xs': '475px',
  'sm': '640px',
  'md': '768px',
  'lg': '1024px',
  'xl': '1280px',
  '2xl': '1536px',
};

// Mobile-first responsive classes
<div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3">
  {/* Content */}
</div>
```

#### Mobile-First Approach
```typescript
// Component responsive design
const EventCard = ({ event }) => {
  return (
    <div className={cn(
      // Mobile styles (default)
      'p-4 rounded-lg shadow-sm',
      // Tablet styles
      'md:p-6 md:shadow-md',
      // Desktop styles
      'lg:p-8 lg:shadow-lg'
    )}>
      <h2 className="text-lg md:text-xl lg:text-2xl font-semibold">
        {event.title}
      </h2>
      {/* Responsive content */}
    </div>
  );
};
```

## 🔌 API Integration Patterns

### HTTP Client Configuration

#### Base API Client
```typescript
// services/api.ts
import axios from 'axios';

const apiClient = axios.create({
  baseURL: process.env.NEXT_PUBLIC_API_URL || 'http://localhost:3000',
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Request interceptor for authentication
apiClient.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('tuvens_auth_token');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// Response interceptor for error handling
apiClient.interceptors.response.use(
  (response) => response.data,
  (error) => {
    if (error.response?.status === 401) {
      // Redirect to login
      window.location.href = '/auth/login';
    }
    return Promise.reject(error.response?.data || error);
  }
);

export { apiClient };
```

#### Service Layer Pattern
```typescript
// services/events.ts
export class EventsService {
  private static readonly BASE_PATH = '/api/events';

  static async getEvents(params?: EventsQueryParams): Promise<Event[]> {
    const response = await apiClient.get(this.BASE_PATH, { params });
    return response.data;
  }

  static async getEvent(id: string): Promise<Event> {
    const response = await apiClient.get(`${this.BASE_PATH}/${id}`);
    return response.data;
  }

  static async createEvent(eventData: CreateEventData): Promise<Event> {
    const response = await apiClient.post(this.BASE_PATH, eventData);
    return response.data;
  }

  static async updateEvent(id: string, eventData: UpdateEventData): Promise<Event> {
    const response = await apiClient.patch(`${this.BASE_PATH}/${id}`, eventData);
    return response.data;
  }

  static async deleteEvent(id: string): Promise<void> {
    await apiClient.delete(`${this.BASE_PATH}/${id}`);
  }

  // Cross-app integration methods
  static async enableTicketing(eventId: string, ticketingData: TicketingData): Promise<TicketingResult> {
    const response = await apiClient.post(`${this.BASE_PATH}/${eventId}/ticketing`, ticketingData);
    return response.data;
  }
}
```

### State Management Integration

#### React Query Integration
```typescript
// hooks/useEvents.ts
import { useQuery, useMutation, useQueryClient } from '@tanstack/react-query';
import { EventsService } from '../services/events';

export const useEvents = (params?: EventsQueryParams) => {
  return useQuery({
    queryKey: ['events', params],
    queryFn: () => EventsService.getEvents(params),
    staleTime: 5 * 60 * 1000, // 5 minutes
  });
};

export const useEvent = (id: string) => {
  return useQuery({
    queryKey: ['events', id],
    queryFn: () => EventsService.getEvent(id),
    enabled: !!id,
  });
};

export const useCreateEvent = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: EventsService.createEvent,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['events'] });
    },
  });
};

export const useEnableTicketing = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: ({ eventId, ticketingData }: { eventId: string; ticketingData: TicketingData }) =>
      EventsService.enableTicketing(eventId, ticketingData),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ['events', variables.eventId] });
    },
  });
};
```

#### Zustand Store Pattern
```typescript
// stores/authStore.ts
import { create } from 'zustand';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  login: (credentials: LoginCredentials) => Promise<void>;
  logout: () => void;
  refreshToken: () => Promise<void>;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isAuthenticated: false,
  isLoading: false,

  login: async (credentials) => {
    set({ isLoading: true });
    try {
      const response = await AuthService.login(credentials);
      const { user, token } = response;
      
      localStorage.setItem('tuvens_auth_token', token);
      set({ user, isAuthenticated: true, isLoading: false });
    } catch (error) {
      set({ isLoading: false });
      throw error;
    }
  },

  logout: () => {
    localStorage.removeItem('tuvens_auth_token');
    set({ user: null, isAuthenticated: false });
  },

  refreshToken: async () => {
    try {
      const response = await AuthService.refreshToken();
      const { user, token } = response;
      
      localStorage.setItem('tuvens_auth_token', token);
      set({ user, isAuthenticated: true });
    } catch (error) {
      get().logout();
      throw error;
    }
  },
}));
```

## 🧪 Testing Standards

### Testing Strategy

#### Testing Pyramid
1. **Unit Tests (70%)**: Components, hooks, utilities
2. **Integration Tests (20%)**: API integration, user workflows
3. **E2E Tests (10%)**: Critical user paths

#### Test File Organization
```
src/
├── components/
│   ├── Button/
│   │   ├── Button.tsx
│   │   ├── Button.test.tsx
│   │   └── Button.stories.tsx
├── hooks/
│   ├── useEvents.ts
│   └── useEvents.test.ts
└── tests/
    ├── setup.ts
    ├── utils.tsx
    ├── mocks/
    └── e2e/
        ├── auth.spec.ts
        └── events.spec.ts
```

### Component Testing

#### React Testing Library
```typescript
// components/Button/Button.test.tsx
import { render, screen, fireEvent } from '@testing-library/react';
import { Button } from './Button';

describe('Button', () => {
  it('renders with correct text', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByRole('button', { name: 'Click me' })).toBeInTheDocument();
  });

  it('calls onClick handler when clicked', () => {
    const handleClick = vi.fn();
    render(<Button onClick={handleClick}>Click me</Button>);
    
    fireEvent.click(screen.getByRole('button'));
    expect(handleClick).toHaveBeenCalledTimes(1);
  });

  it('applies correct variant styles', () => {
    render(<Button variant="secondary">Button</Button>);
    const button = screen.getByRole('button');
    expect(button).toHaveClass('bg-secondary-500');
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Button</Button>);
    const button = screen.getByRole('button');
    expect(button).toBeDisabled();
    expect(button).toHaveClass('opacity-50');
  });
});
```

#### Hook Testing
```typescript
// hooks/useEvents.test.ts
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useEvents } from './useEvents';
import { EventsService } from '../services/events';

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: { queries: { retry: false } },
  });
  
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>
      {children}
    </QueryClientProvider>
  );
};

describe('useEvents', () => {
  it('fetches events successfully', async () => {
    const mockEvents = [{ id: '1', title: 'Test Event' }];
    vi.spyOn(EventsService, 'getEvents').mockResolvedValue(mockEvents);

    const { result } = renderHook(() => useEvents(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(result.current.isSuccess).toBe(true);
    });

    expect(result.current.data).toEqual(mockEvents);
  });

  it('handles errors correctly', async () => {
    const error = new Error('Failed to fetch events');
    vi.spyOn(EventsService, 'getEvents').mockRejectedValue(error);

    const { result } = renderHook(() => useEvents(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => {
      expect(result.current.isError).toBe(true);
    });

    expect(result.current.error).toEqual(error);
  });
});
```

### E2E Testing with Playwright

```typescript
// tests/e2e/events.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Events Management', () => {
  test.beforeEach(async ({ page }) => {
    // Login
    await page.goto('/auth/login');
    await page.fill('[data-testid="email"]', 'test@tuvens.com');
    await page.fill('[data-testid="password"]', 'password123');
    await page.click('[data-testid="login-button"]');
    
    await expect(page).toHaveURL('/dashboard');
  });

  test('creates a new event', async ({ page }) => {
    await page.goto('/events');
    await page.click('[data-testid="create-event-button"]');
    
    await page.fill('[data-testid="event-title"]', 'Test Event');
    await page.fill('[data-testid="event-description"]', 'This is a test event');
    await page.fill('[data-testid="event-date"]', '2025-12-25');
    await page.fill('[data-testid="event-location"]', 'Test Venue');
    
    await page.click('[data-testid="save-event-button"]');
    
    await expect(page.locator('[data-testid="success-message"]')).toBeVisible();
    await expect(page.locator('text=Test Event')).toBeVisible();
  });

  test('enables ticketing for an event', async ({ page }) => {
    await page.goto('/events/test-event-id');
    await page.click('[data-testid="enable-ticketing-button"]');
    
    // Wait for Hi.Events integration
    await expect(page.locator('[data-testid="ticketing-enabled"]')).toBeVisible();
    await expect(page.locator('text=Ticketing powered by Hi.Events')).toBeVisible();
  });
});
```

## 🚀 Performance Optimization

### Bundle Optimization

#### Code Splitting
```typescript
// Lazy loading routes
import { lazy, Suspense } from 'react';

const EventsPage = lazy(() => import('../pages/EventsPage'));
const DashboardPage = lazy(() => import('../pages/DashboardPage'));

// Router configuration
const router = createBrowserRouter([
  {
    path: '/events',
    element: (
      <Suspense fallback={<PageLoading />}>
        <EventsPage />
      </Suspense>
    ),
  },
  {
    path: '/dashboard',
    element: (
      <Suspense fallback={<PageLoading />}>
        <DashboardPage />
      </Suspense>
    ),
  },
]);
```

#### Tree Shaking
```typescript
// Optimize imports
// ❌ Import entire library
import * as lodash from 'lodash';

// ✅ Import specific functions
import { debounce, throttle } from 'lodash';

// ✅ Use tree-shakable libraries
import { format } from 'date-fns';
```

### Runtime Performance

#### Memoization
```typescript
// React.memo for components
const EventCard = React.memo(({ event }: { event: Event }) => {
  return (
    <div className="event-card">
      <h3>{event.title}</h3>
      <p>{event.description}</p>
    </div>
  );
});

// useMemo for expensive calculations
const ExpensiveComponent = ({ events }: { events: Event[] }) => {
  const sortedEvents = useMemo(() => {
    return events.sort((a, b) => new Date(a.date).getTime() - new Date(b.date).getTime());
  }, [events]);

  return (
    <div>
      {sortedEvents.map(event => (
        <EventCard key={event.id} event={event} />
      ))}
    </div>
  );
};

// useCallback for event handlers
const EventsList = ({ events }: { events: Event[] }) => {
  const handleEventClick = useCallback((eventId: string) => {
    navigate(`/events/${eventId}`);
  }, [navigate]);

  return (
    <div>
      {events.map(event => (
        <EventCard 
          key={event.id} 
          event={event} 
          onClick={() => handleEventClick(event.id)}
        />
      ))}
    </div>
  );
};
```

#### Virtual Scrolling
```typescript
// Large list optimization
import { FixedSizeList as List } from 'react-window';

const EventsList = ({ events }: { events: Event[] }) => {
  const Row = ({ index, style }: { index: number; style: React.CSSProperties }) => (
    <div style={style}>
      <EventCard event={events[index]} />
    </div>
  );

  return (
    <List
      height={600}
      itemCount={events.length}
      itemSize={120}
      width="100%"
    >
      {Row}
    </List>
  );
};
```

## ♿ Accessibility Standards

### WCAG Compliance

#### Semantic HTML
```typescript
// Use proper semantic elements
const EventPage = ({ event }: { event: Event }) => {
  return (
    <main>
      <header>
        <h1>{event.title}</h1>
        <nav aria-label="Event navigation">
          <ul>
            <li><a href="#details">Details</a></li>
            <li><a href="#tickets">Tickets</a></li>
            <li><a href="#location">Location</a></li>
          </ul>
        </nav>
      </header>
      
      <section id="details" aria-labelledby="details-heading">
        <h2 id="details-heading">Event Details</h2>
        <p>{event.description}</p>
      </section>
      
      <section id="tickets" aria-labelledby="tickets-heading">
        <h2 id="tickets-heading">Tickets</h2>
        {/* Ticket widget */}
      </section>
    </main>
  );
};
```

#### ARIA Labels and Roles
```typescript
// Proper ARIA usage
const SearchForm = ({ onSearch }: { onSearch: (query: string) => void }) => {
  const [query, setQuery] = useState('');

  return (
    <form role="search" onSubmit={(e) => { e.preventDefault(); onSearch(query); }}>
      <label htmlFor="search-input" className="sr-only">
        Search events
      </label>
      <input
        id="search-input"
        type="text"
        value={query}
        onChange={(e) => setQuery(e.target.value)}
        aria-describedby="search-help"
        placeholder="Search events..."
      />
      <div id="search-help" className="sr-only">
        Enter keywords to search for events
      </div>
      <button type="submit" aria-label="Search">
        <SearchIcon aria-hidden="true" />
      </button>
    </form>
  );
};
```

#### Keyboard Navigation
```typescript
// Keyboard accessible components
const Modal = ({ isOpen, onClose, children }: ModalProps) => {
  const dialogRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    if (isOpen) {
      // Focus trap
      const focusableElements = dialogRef.current?.querySelectorAll(
        'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
      );
      const firstElement = focusableElements?.[0] as HTMLElement;
      firstElement?.focus();
    }
  }, [isOpen]);

  const handleKeyDown = (e: KeyboardEvent) => {
    if (e.key === 'Escape') {
      onClose();
    }
  };

  if (!isOpen) return null;

  return (
    <div
      role="dialog"
      aria-modal="true"
      ref={dialogRef}
      onKeyDown={handleKeyDown}
      className="fixed inset-0 z-50 flex items-center justify-center bg-black bg-opacity-50"
    >
      <div className="bg-white rounded-lg p-6 max-w-md w-full mx-4">
        {children}
        <button
          onClick={onClose}
          className="absolute top-4 right-4"
          aria-label="Close dialog"
        >
          <CloseIcon />
        </button>
      </div>
    </div>
  );
};
```

## 🔒 Security Best Practices

### Authentication Security

#### JWT Token Handling
```typescript
// Secure token storage
class TokenManager {
  private static readonly TOKEN_KEY = 'tuvens_auth_token';
  private static readonly REFRESH_TOKEN_KEY = 'tuvens_refresh_token';

  static setTokens(accessToken: string, refreshToken: string) {
    // Use httpOnly cookies in production
    if (process.env.NODE_ENV === 'production') {
      // Set via API call to set httpOnly cookies
      AuthService.setSecureCookies(accessToken, refreshToken);
    } else {
      localStorage.setItem(this.TOKEN_KEY, accessToken);
      localStorage.setItem(this.REFRESH_TOKEN_KEY, refreshToken);
    }
  }

  static getAccessToken(): string | null {
    return localStorage.getItem(this.TOKEN_KEY);
  }

  static clearTokens() {
    localStorage.removeItem(this.TOKEN_KEY);
    localStorage.removeItem(this.REFRESH_TOKEN_KEY);
  }

  static isTokenExpired(token: string): boolean {
    try {
      const payload = JSON.parse(atob(token.split('.')[1]));
      return payload.exp * 1000 < Date.now();
    } catch {
      return true;
    }
  }
}
```

#### Input Validation
```typescript
// Client-side validation with server-side verification
import { z } from 'zod';

const eventSchema = z.object({
  title: z.string().min(1, 'Title is required').max(100, 'Title too long'),
  description: z.string().min(10, 'Description must be at least 10 characters'),
  date: z.string().datetime('Invalid date format'),
  location: z.string().min(1, 'Location is required'),
  ticketPrice: z.number().min(0, 'Price cannot be negative'),
});

type EventFormData = z.infer<typeof eventSchema>;

const EventForm = ({ onSubmit }: { onSubmit: (data: EventFormData) => void }) => {
  const { register, handleSubmit, formState: { errors } } = useForm<EventFormData>({
    resolver: zodResolver(eventSchema),
  });

  return (
    <form onSubmit={handleSubmit(onSubmit)}>
      <input
        {...register('title')}
        placeholder="Event Title"
        aria-invalid={!!errors.title}
        aria-describedby={errors.title ? 'title-error' : undefined}
      />
      {errors.title && (
        <p id="title-error" role="alert" className="text-red-500">
          {errors.title.message}
        </p>
      )}
      {/* Other form fields */}
    </form>
  );
};
```

### XSS Protection

#### Content Sanitization
```typescript
// Sanitize user-generated content
import DOMPurify from 'dompurify';

const SafeHTML = ({ content }: { content: string }) => {
  const sanitizedHTML = DOMPurify.sanitize(content, {
    ALLOWED_TAGS: ['p', 'br', 'strong', 'em', 'ul', 'ol', 'li'],
    ALLOWED_ATTR: [],
  });

  return <div dangerouslySetInnerHTML={{ __html: sanitizedHTML }} />;
};

// URL validation
const isValidURL = (url: string): boolean => {
  try {
    const parsedURL = new URL(url);
    return ['http:', 'https:'].includes(parsedURL.protocol);
  } catch {
    return false;
  }
};
```

## 📊 Analytics and Monitoring

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

## 🚀 Deployment and CI/CD

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