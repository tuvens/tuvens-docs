# Component Patterns

> ⚠️ **IMPORTANT**: This file contains generic component patterns based on common frontend best practices. These patterns may NOT accurately reflect the actual implementation in tuvens-client or eventsdigest-ai repositories.
> 
> **ACTION REQUIRED**: Before using these patterns, load the actual codebase and verify:
> 1. The specific Svelte version (tuvens-client uses Svelte 4.x, eventsdigest-ai uses Svelte 5)
> 2. The Skeleton UI version and configuration
> 3. The TailwindCSS version and custom configuration
> 4. Existing component patterns in the codebase
>
> **Recommended**: Start a new Claude session with `/start-session svelte-dev` to review and update this file with accurate patterns from the actual codebase.

## Component Organization

### Directory Structure
```
src/lib/components/
├── common/           # Shared across features
│   ├── Button.svelte
│   ├── Modal.svelte
│   └── LoadingSpinner.svelte
├── layout/          # Layout components
│   ├── Header.svelte
│   ├── Footer.svelte
│   └── Sidebar.svelte
├── features/        # Feature-specific components
│   ├── auth/
│   ├── events/
│   └── ticketing/
└── index.ts         # Component exports
```

## Naming Conventions

### Component Files
- **PascalCase** for component files: `EventCard.svelte`, `UserProfile.svelte`
- **Descriptive names**: Prefer `EventCreationForm.svelte` over `Form.svelte`
- **Feature prefixes** for clarity: `TicketingWidget.svelte`, `AuthLoginForm.svelte`

### Props and Events
```svelte
<script lang="ts">
  // Props use camelCase with explicit types
  export let eventData: EventType;
  export let isLoading: boolean = false;
  export let onSave: ((data: EventType) => void) | undefined = undefined;
  
  // Events use dispatch pattern
  import { createEventDispatcher } from 'svelte';
  const dispatch = createEventDispatcher<{
    save: EventType;
    cancel: void;
  }>();
</script>
```

## State Management Patterns

### Local State 

#### Svelte 4 (tuvens-client)
```svelte
<script lang="ts">
  // Traditional Svelte 4 reactivity
  let count = 0;
  $: doubled = count * 2;
  
  $: {
    console.log(`Count is now ${count}`);
  }
</script>
```

#### Svelte 5 (eventsdigest-ai)
```svelte
<script lang="ts">
  // Svelte 5 runes syntax
  let count = $state(0);
  let doubled = $derived(count * 2);
  
  $effect(() => {
    console.log(`Count is now ${count}`);
  });
</script>
```

### Store Patterns
```typescript
// stores/eventStore.ts
import { writable, derived } from 'svelte/store';

// Simple writable store
export const events = writable<Event[]>([]);

// Derived store for filtering
export const activeEvents = derived(
  events,
  $events => $events.filter(e => e.status === 'active')
);

// Custom store with methods
function createEventStore() {
  const { subscribe, set, update } = writable<Event[]>([]);
  
  return {
    subscribe,
    addEvent: (event: Event) => update(events => [...events, event]),
    removeEvent: (id: string) => update(events => 
      events.filter(e => e.id !== id)
    ),
    reset: () => set([])
  };
}

export const eventStore = createEventStore();
```

## Component Composition

### Slots and Composition
```svelte
<!-- Card.svelte -->
<div class="card variant-ghost-surface p-4">
  {#if $$slots.header}
    <header class="card-header">
      <slot name="header" />
    </header>
  {/if}
  
  <div class="card-content">
    <slot />
  </div>
  
  {#if $$slots.footer}
    <footer class="card-footer">
      <slot name="footer" />
    </footer>
  {/if}
</div>
```

### Skeleton UI Integration
```svelte
<!-- Using Skeleton UI components -->
<script lang="ts">
  import { Avatar, popup } from '@skeletonlabs/skeleton';
  import type { PopupSettings } from '@skeletonlabs/skeleton';
  
  const popupHover: PopupSettings = {
    event: 'hover',
    target: 'popupHover',
    placement: 'top'
  };
</script>

<button class="btn variant-filled-primary" use:popup={popupHover}>
  Hover me
</button>
```

## Error Handling

### Error Boundaries
```svelte
<!-- ErrorBoundary.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  
  export let fallback: string = 'Something went wrong';
  let hasError = false;
  let error: Error | null = null;
  
  onMount(() => {
    const handleError = (event: ErrorEvent) => {
      hasError = true;
      error = event.error;
      event.preventDefault();
    };
    
    window.addEventListener('error', handleError);
    return () => window.removeEventListener('error', handleError);
  });
</script>

{#if hasError}
  <div class="alert variant-filled-error">
    <p>{fallback}</p>
    {#if error}
      <details>
        <summary>Error details</summary>
        <pre>{error.stack}</pre>
      </details>
    {/if}
  </div>
{:else}
  <slot />
{/if}
```

## Loading States

### Consistent Loading Pattern
```svelte
<script lang="ts">
  export let isLoading = false;
  export let error: Error | null = null;
  export let data: any = null;
</script>

{#if isLoading}
  <div class="flex justify-center p-8">
    <ProgressRadial width="w-8" />
  </div>
{:else if error}
  <Alert variant="error">
    {error.message}
  </Alert>
{:else if data}
  <!-- Render data -->
{:else}
  <p class="text-surface-600">No data available</p>
{/if}
```

## Form Patterns

### Form Handling with Validation
```svelte
<script lang="ts">
  import { createForm } from 'felte';
  import { validator } from '@felte/validator-zod';
  import { z } from 'zod';
  
  const schema = z.object({
    title: z.string().min(3).max(100),
    description: z.string().optional(),
    date: z.string().datetime()
  });
  
  const { form, errors, isSubmitting } = createForm({
    extend: validator({ schema }),
    onSubmit: async (values) => {
      // Handle submission
    }
  });
</script>

<form use:form>
  <label class="label">
    <span>Title</span>
    <input 
      class="input" 
      class:input-error={$errors.title}
      type="text" 
      name="title" 
    />
    {#if $errors.title}
      <span class="text-error-500 text-sm">{$errors.title}</span>
    {/if}
  </label>
  
  <button 
    type="submit" 
    class="btn variant-filled-primary"
    disabled={$isSubmitting}
  >
    {$isSubmitting ? 'Saving...' : 'Save'}
  </button>
</form>
```

## Accessibility Patterns

### ARIA Labels and Keyboard Navigation
```svelte
<script lang="ts">
  export let label: string;
  export let items: Item[];
  let selectedIndex = 0;
  
  function handleKeydown(event: KeyboardEvent) {
    switch (event.key) {
      case 'ArrowDown':
        selectedIndex = Math.min(selectedIndex + 1, items.length - 1);
        event.preventDefault();
        break;
      case 'ArrowUp':
        selectedIndex = Math.max(selectedIndex - 1, 0);
        event.preventDefault();
        break;
    }
  }
</script>

<div 
  role="listbox"
  aria-label={label}
  on:keydown={handleKeydown}
  tabindex="0"
>
  {#each items as item, i}
    <div
      role="option"
      aria-selected={i === selectedIndex}
      class:bg-primary-500={i === selectedIndex}
    >
      {item.name}
    </div>
  {/each}
</div>
```

## Performance Patterns

### Lazy Loading
```svelte
<script lang="ts">
  import { onMount } from 'svelte';
  
  let Component: any;
  
  onMount(async () => {
    const module = await import('./HeavyComponent.svelte');
    Component = module.default;
  });
</script>

{#if Component}
  <svelte:component this={Component} />
{:else}
  <div class="placeholder animate-pulse" />
{/if}
```

## Testing Patterns

### Component Testing Structure
```typescript
// EventCard.test.ts
import { render, screen } from '@testing-library/svelte';
import userEvent from '@testing-library/user-event';
import EventCard from './EventCard.svelte';

describe('EventCard', () => {
  it('renders event title', () => {
    render(EventCard, {
      props: {
        event: { title: 'Test Event', date: '2024-01-01' }
      }
    });
    
    expect(screen.getByText('Test Event')).toBeInTheDocument();
  });
  
  it('emits click event', async () => {
    const { component } = render(EventCard, {
      props: { event: mockEvent }
    });
    
    const handler = vi.fn();
    component.$on('click', handler);
    
    await userEvent.click(screen.getByRole('button'));
    expect(handler).toHaveBeenCalled();
  });
});
```

## Version Considerations

### Skeleton UI Versions
- **v1.x**: Uses different component APIs and styling classes
- **v2.x**: Current stable version with improved TypeScript support
- Check `package.json` for exact version and consult Skeleton docs

### Svelte Version Differences
- **Svelte 4**: Uses traditional reactivity (`$:` labels)
- **Svelte 5**: Uses runes (`$state`, `$derived`, `$effect`)
- Components may need adaptation based on project version

### TailwindCSS Configuration
- Custom color schemes may override these examples
- Check `tailwind.config.js` for project-specific utilities
- Skeleton UI theme customizations affect component styling

---

**Remember**: Always verify these patterns against the actual codebase before implementing. Use `/start-session svelte-dev` to review with full repository context.