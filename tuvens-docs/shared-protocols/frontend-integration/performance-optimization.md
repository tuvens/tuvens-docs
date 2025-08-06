# 🚀 Performance Optimization

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