# 🧪 Testing Standards

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