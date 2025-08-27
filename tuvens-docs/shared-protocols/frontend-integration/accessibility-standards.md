# ♿ Accessibility Standards

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