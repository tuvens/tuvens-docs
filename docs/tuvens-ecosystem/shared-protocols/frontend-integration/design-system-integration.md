# 🎨 Design System Integration

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