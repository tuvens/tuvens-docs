# 🏗️ Architecture Standards

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