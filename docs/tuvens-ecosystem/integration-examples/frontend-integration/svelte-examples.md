# Svelte Integration Examples

> ⚠️ **CRITICAL WARNING**: These examples are GENERIC and may NOT match the actual implementation patterns in:
> - **tuvens-client** (Svelte 4.x with SvelteKit 2.x)
> - **eventsdigest-ai** (Svelte 5)
> 
> **BEFORE USING**: 
> 1. Run `/start-session svelte-dev` to analyze the actual codebase
> 2. Check `package.json` for exact versions of Svelte, Skeleton, and TailwindCSS
> 3. Review existing components for established patterns
> 4. Update this file with accurate, project-specific examples
>
> **Version Conflicts**: The two projects use different Svelte versions with incompatible syntax:
> - **tuvens-client**: Svelte 4.x (verified: ^4.2.16) - Uses `$:` reactive statements
> - **eventsdigest-ai**: Svelte 5 - Uses runes (`$state`, `$derived`, `$effect`)
> 
> Ensure examples match the target repository's version.

## Authentication Integration Examples

### Cross-App Authentication Component
```svelte
<!-- ⚠️ UNVERIFIED EXAMPLE - Check actual implementation -->
<!-- ⚠️ This example uses Svelte 4 syntax (for tuvens-client) -->
<!-- For eventsdigest-ai (Svelte 5), convert reactive statements to runes -->
<!-- components/auth/CrossAppAuth.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { goto } from '$app/navigation';
  import { page } from '$app/stores';
  import { authStore } from '$lib/stores/auth';
  import { Alert, ProgressRadial } from '@skeletonlabs/skeleton';
  
  let isLoading = true;
  let error: string | null = null;
  
  onMount(async () => {
    const sessionToken = $page.url.searchParams.get('session_token');
    
    if (!sessionToken) {
      error = 'No session token provided';
      isLoading = false;
      return;
    }
    
    try {
      const response = await fetch('/api/auth/cross-app/validate', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ sessionToken })
      });
      
      if (!response.ok) {
        throw new Error('Authentication failed');
      }
      
      const userData = await response.json();
      authStore.setUser(userData);
      
      // Redirect to intended destination or dashboard
      const returnUrl = $page.url.searchParams.get('return_url') || '/dashboard';
      goto(returnUrl);
    } catch (err) {
      error = err instanceof Error ? err.message : 'Authentication failed';
    } finally {
      isLoading = false;
    }
  });
</script>

<div class="container mx-auto p-4">
  {#if isLoading}
    <div class="flex flex-col items-center justify-center min-h-[400px]">
      <ProgressRadial width="w-16" />
      <p class="mt-4 text-surface-600">Authenticating with Hi.Events...</p>
    </div>
  {:else if error}
    <Alert variant="error">
      <svelte:fragment slot="title">Authentication Failed</svelte:fragment>
      <p>{error}</p>
      <div class="mt-4">
        <a href="/login" class="btn variant-filled-primary">Return to Login</a>
      </div>
    </Alert>
  {/if}
</div>
```

### Session Management Store
```typescript
// ⚠️ UNVERIFIED EXAMPLE - Verify store patterns in actual codebase
// stores/auth.ts
import { writable, derived } from 'svelte/store';
import { browser } from '$app/environment';

interface User {
  id: string;
  email: string;
  name: string;
  accounts?: Account[];
}

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
}

function createAuthStore() {
  const { subscribe, set, update } = writable<AuthState>({
    user: null,
    isAuthenticated: false,
    isLoading: true
  });
  
  return {
    subscribe,
    setUser: (user: User) => update(state => ({
      ...state,
      user,
      isAuthenticated: true,
      isLoading: false
    })),
    logout: () => {
      if (browser) {
        // Clear any stored tokens
        localStorage.removeItem('auth_token');
      }
      set({ user: null, isAuthenticated: false, isLoading: false });
    },
    checkAuth: async () => {
      // Implementation depends on your auth strategy
      update(state => ({ ...state, isLoading: true }));
      try {
        const response = await fetch('/api/auth/me');
        if (response.ok) {
          const user = await response.json();
          update(state => ({
            ...state,
            user,
            isAuthenticated: true,
            isLoading: false
          }));
        } else {
          throw new Error('Not authenticated');
        }
      } catch {
        update(state => ({
          ...state,
          user: null,
          isAuthenticated: false,
          isLoading: false
        }));
      }
    }
  };
}

export const authStore = createAuthStore();

// Derived store for easy access to user
export const user = derived(
  authStore,
  $authStore => $authStore.user
);

export const isAuthenticated = derived(
  authStore,
  $authStore => $authStore.isAuthenticated
);
```

## Event Management Examples

### Event List Component
```svelte
<!-- ⚠️ UNVERIFIED - Check actual event structure and API -->
<!-- components/events/EventList.svelte -->
<script lang="ts">
  import { onMount } from 'svelte';
  import { fade, slide } from 'svelte/transition';
  import EventCard from './EventCard.svelte';
  import EventFilters from './EventFilters.svelte';
  import { eventStore } from '$lib/stores/events';
  import { ProgressRadial, Paginator } from '@skeletonlabs/skeleton';
  
  export let accountId: string | undefined = undefined;
  
  let isLoading = true;
  let error: Error | null = null;
  let filters = {
    status: 'all',
    search: '',
    dateRange: null
  };
  let paginationSettings = {
    page: 0,
    limit: 10,
    size: 0,
    amounts: [10, 20, 50]
  };
  
  $: filteredEvents = $eventStore.filter(event => {
    if (filters.status !== 'all' && event.status !== filters.status) return false;
    if (filters.search && !event.title.toLowerCase().includes(filters.search.toLowerCase())) return false;
    // Add more filter logic
    return true;
  });
  
  $: paginatedEvents = filteredEvents.slice(
    paginationSettings.page * paginationSettings.limit,
    (paginationSettings.page + 1) * paginationSettings.limit
  );
  
  onMount(async () => {
    try {
      await eventStore.loadEvents(accountId);
    } catch (err) {
      error = err instanceof Error ? err : new Error('Failed to load events');
    } finally {
      isLoading = false;
    }
  });
  
  function handleFilterChange(newFilters: typeof filters) {
    filters = newFilters;
    paginationSettings.page = 0; // Reset to first page
  }
</script>

<div class="space-y-4">
  <EventFilters 
    {filters} 
    on:change={(e) => handleFilterChange(e.detail)}
  />
  
  {#if isLoading}
    <div class="flex justify-center p-8">
      <ProgressRadial width="w-12" />
    </div>
  {:else if error}
    <div class="alert variant-filled-error">
      <p>{error.message}</p>
    </div>
  {:else if paginatedEvents.length === 0}
    <div class="card p-8 text-center text-surface-600">
      <p>No events found</p>
    </div>
  {:else}
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
      {#each paginatedEvents as event (event.id)}
        <div transition:fade={{ duration: 200 }}>
          <EventCard {event} />
        </div>
      {/each}
    </div>
    
    {#if filteredEvents.length > paginationSettings.limit}
      <Paginator
        bind:settings={paginationSettings}
        showFirstLastButtons={true}
        showPreviousNextButtons={true}
        maxNumerals={5}
        on:page={(e) => {
          paginationSettings.page = e.detail;
          window.scrollTo({ top: 0, behavior: 'smooth' });
        }}
      />
    {/if}
  {/if}
</div>
```

## Ticketing Widget Integration

### Dynamic Ticketing Widget
```svelte
<!-- ⚠️ UNVERIFIED - Based on implementation-status.md but needs verification -->
<!-- components/ticketing/TicketingWidget.svelte -->
<script lang="ts">
  export let event: Event;
  export let accountId: string;
  
  import { Alert, ProgressRadial } from '@skeletonlabs/skeleton';
  import { crossAppAuth } from '$lib/services/crossAppAuth';
  
  $: ticketingStatus = event.ticketing_status || 'none';
  $: hiEventsUrl = event.hi_events_url;
  
  let isEnabling = false;
  let error: string | null = null;
  
  async function enableTicketing() {
    isEnabling = true;
    error = null;
    
    try {
      const { sessionUrl } = await crossAppAuth.generateSession(accountId, event.id);
      window.location.href = sessionUrl;
    } catch (err) {
      error = err instanceof Error ? err.message : 'Failed to enable ticketing';
      isEnabling = false;
    }
  }
</script>

<div class="card variant-ghost-surface">
  <header class="card-header">
    <h3 class="h3">Event Ticketing</h3>
  </header>
  
  <section class="p-4">
    {#if ticketingStatus === 'active' && hiEventsUrl}
      <!-- Active ticketing - show iframe -->
      <div class="aspect-video bg-surface-500/10 rounded-container-token overflow-hidden">
        <iframe
          src={hiEventsUrl}
          title="Event ticketing"
          class="w-full h-full"
          frameborder="0"
          allowfullscreen
        />
      </div>
      <div class="mt-4 text-center">
        <a 
          href={hiEventsUrl} 
          target="_blank" 
          rel="noopener noreferrer"
          class="btn variant-ghost-primary"
        >
          Open in Hi.Events →
        </a>
      </div>
      
    {:else if ticketingStatus === 'setup'}
      <!-- Setup in progress -->
      <div class="flex flex-col items-center justify-center p-8 space-y-4">
        <ProgressRadial width="w-16" />
        <p class="text-surface-600">Setting up your ticketing...</p>
        <p class="text-sm text-surface-500">This may take a few moments</p>
      </div>
      
    {:else if ticketingStatus === 'inactive'}
      <!-- Ticketing paused -->
      <Alert variant="warning">
        <svelte:fragment slot="title">Ticketing Paused</svelte:fragment>
        <p>Ticket sales are currently paused for this event.</p>
      </Alert>
      
    {:else}
      <!-- No ticketing enabled -->
      <div class="text-center p-8 space-y-4">
        <p class="text-surface-600">Enable ticketing to sell tickets for your event</p>
        
        {#if error}
          <Alert variant="error">{error}</Alert>
        {/if}
        
        <button
          class="btn variant-filled-primary"
          on:click={enableTicketing}
          disabled={isEnabling}
        >
          {#if isEnabling}
            <ProgressRadial width="w-4" class="mr-2" />
            Enabling...
          {:else}
            Enable Ticketing
          {/if}
        </button>
      </div>
    {/if}
  </section>
</div>
```

## Real-time Updates (SSE)

### Server-Sent Events Store
```typescript
// ⚠️ UNVERIFIED - SSE implementation pattern example
// stores/eventUpdates.ts
import { writable } from 'svelte/store';
import { browser } from '$app/environment';

interface EventUpdate {
  eventId: string;
  field: string;
  value: any;
  timestamp: number;
}

function createEventUpdatesStore() {
  const { subscribe, update } = writable<{
    updates: EventUpdate[];
    isConnected: boolean;
  }>({
    updates: [],
    isConnected: false
  });
  
  let eventSource: EventSource | null = null;
  
  return {
    subscribe,
    connect: (accountId: string) => {
      if (!browser || eventSource) return;
      
      eventSource = new EventSource(`/api/events/updates?accountId=${accountId}`);
      
      eventSource.onopen = () => {
        update(state => ({ ...state, isConnected: true }));
      };
      
      eventSource.onmessage = (event) => {
        try {
          const update = JSON.parse(event.data);
          update(state => ({
            ...state,
            updates: [...state.updates, update]
          }));
          
          // Trigger event-specific updates
          if (update.field === 'ticketing_status') {
            // Update the specific event in eventStore
            eventStore.updateEvent(update.eventId, {
              ticketing_status: update.value
            });
          }
        } catch (err) {
          console.error('Failed to parse SSE update:', err);
        }
      };
      
      eventSource.onerror = () => {
        update(state => ({ ...state, isConnected: false }));
        // Implement reconnection logic
      };
    },
    disconnect: () => {
      if (eventSource) {
        eventSource.close();
        eventSource = null;
        update(state => ({ ...state, isConnected: false }));
      }
    }
  };
}

export const eventUpdatesStore = createEventUpdatesStore();
```

## Form Handling Examples

### Event Creation Form
```svelte
<!-- ⚠️ UNVERIFIED - Form validation approach may differ -->
<!-- components/events/EventForm.svelte -->
<script lang="ts">
  import { createForm } from 'felte';
  import { validator } from '@felte/validator-zod';
  import { z } from 'zod';
  import { goto } from '$app/navigation';
  import { 
    SlideToggle, 
    InputChip,
    FileDropzone,
    Alert 
  } from '@skeletonlabs/skeleton';
  
  const schema = z.object({
    title: z.string().min(3, 'Title must be at least 3 characters'),
    description: z.string().optional(),
    date: z.string().min(1, 'Date is required'),
    time: z.string().min(1, 'Time is required'),
    location: z.string().min(1, 'Location is required'),
    isPublic: z.boolean(),
    tags: z.array(z.string()),
    imageUrl: z.string().url().optional()
  });
  
  let isSubmitting = false;
  let submitError: string | null = null;
  let tagList: string[] = [];
  
  const { form, errors, data, setFields } = createForm({
    extend: validator({ schema }),
    initialValues: {
      title: '',
      description: '',
      date: '',
      time: '',
      location: '',
      isPublic: true,
      tags: [],
      imageUrl: ''
    },
    onSubmit: async (values) => {
      isSubmitting = true;
      submitError = null;
      
      try {
        const response = await fetch('/api/events', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            ...values,
            tags: tagList
          })
        });
        
        if (!response.ok) {
          throw new Error('Failed to create event');
        }
        
        const event = await response.json();
        goto(`/events/${event.id}`);
      } catch (err) {
        submitError = err instanceof Error ? err.message : 'An error occurred';
      } finally {
        isSubmitting = false;
      }
    }
  });
  
  function handleFileSelect(e: CustomEvent<File[]>) {
    const file = e.detail[0];
    if (file) {
      // Handle file upload - this is a simplified example
      // In reality, you'd upload to a service and get a URL
      setFields('imageUrl', URL.createObjectURL(file));
    }
  }
</script>

<form use:form class="space-y-6">
  {#if submitError}
    <Alert variant="error">{submitError}</Alert>
  {/if}
  
  <label class="label">
    <span>Event Title *</span>
    <input
      name="title"
      type="text"
      class="input"
      class:input-error={$errors.title}
      placeholder="Summer Music Festival"
    />
    {#if $errors.title}
      <span class="text-error-500 text-sm">{$errors.title}</span>
    {/if}
  </label>
  
  <label class="label">
    <span>Description</span>
    <textarea
      name="description"
      class="textarea"
      rows="4"
      placeholder="Describe your event..."
    />
  </label>
  
  <div class="grid grid-cols-1 md:grid-cols-2 gap-4">
    <label class="label">
      <span>Date *</span>
      <input
        name="date"
        type="date"
        class="input"
        class:input-error={$errors.date}
      />
      {#if $errors.date}
        <span class="text-error-500 text-sm">{$errors.date}</span>
      {/if}
    </label>
    
    <label class="label">
      <span>Time *</span>
      <input
        name="time"
        type="time"
        class="input"
        class:input-error={$errors.time}
      />
      {#if $errors.time}
        <span class="text-error-500 text-sm">{$errors.time}</span>
      {/if}
    </label>
  </div>
  
  <label class="label">
    <span>Location *</span>
    <input
      name="location"
      type="text"
      class="input"
      class:input-error={$errors.location}
      placeholder="123 Main St, City, State"
    />
    {#if $errors.location}
      <span class="text-error-500 text-sm">{$errors.location}</span>
    {/if}
  </label>
  
  <div class="space-y-2">
    <span class="label">Event Tags</span>
    <InputChip
      bind:value={tagList}
      name="tags"
      placeholder="Add tags..."
      chips="variant-filled-primary"
    />
  </div>
  
  <div class="space-y-2">
    <span class="label">Event Image</span>
    <FileDropzone
      name="image"
      accept="image/*"
      on:change={handleFileSelect}
    >
      <svelte:fragment slot="lead">
        <i class="fa-solid fa-image text-3xl" />
      </svelte:fragment>
      <svelte:fragment slot="message">
        Drop an image or click to browse
      </svelte:fragment>
    </FileDropzone>
  </div>
  
  <label class="flex items-center space-x-2">
    <SlideToggle name="isPublic" checked />
    <span>Make this event public</span>
  </label>
  
  <div class="flex justify-end gap-4">
    <button
      type="button"
      class="btn variant-ghost"
      on:click={() => goto('/events')}
    >
      Cancel
    </button>
    <button
      type="submit"
      class="btn variant-filled-primary"
      disabled={isSubmitting}
    >
      {isSubmitting ? 'Creating...' : 'Create Event'}
    </button>
  </div>
</form>
```

## Modal and Dialog Patterns

### Confirmation Modal
```svelte
<!-- ⚠️ UNVERIFIED - Modal API may differ between Skeleton versions -->
<!-- components/common/ConfirmModal.svelte -->
<script lang="ts">
  import { getModalStore } from '@skeletonlabs/skeleton';
  import type { ModalSettings, ModalComponent } from '@skeletonlabs/skeleton';
  
  export let parent: any;
  
  const modalStore = getModalStore();
  
  export function triggerConfirm(
    title: string,
    message: string,
    onConfirm: () => void,
    confirmText = 'Confirm',
    confirmVariant = 'variant-filled-error'
  ) {
    const modal: ModalSettings = {
      type: 'confirm',
      title,
      body: message,
      response: (r: boolean) => {
        if (r) onConfirm();
      },
      buttonTextCancel: 'Cancel',
      buttonTextConfirm: confirmText,
      buttonPositive: confirmVariant
    };
    modalStore.trigger(modal);
  }
  
  // Component-based modal example
  export function triggerCustomModal(component: ModalComponent) {
    const modal: ModalSettings = {
      type: 'component',
      component
    };
    modalStore.trigger(modal);
  }
</script>

<!-- Usage in parent component -->
<script>
  import { modalStore } from '@skeletonlabs/skeleton';
  
  function handleDelete() {
    modalStore.trigger({
      type: 'confirm',
      title: 'Delete Event?',
      body: 'This action cannot be undone.',
      response: (r) => {
        if (r) {
          // Perform deletion
        }
      }
    });
  }
</script>
```

## Toast/Notification Patterns

### Toast Notifications
```typescript
// ⚠️ UNVERIFIED - Toast API varies by Skeleton version
// utils/toast.ts
import { toastStore } from '@skeletonlabs/skeleton';
import type { ToastSettings } from '@skeletonlabs/skeleton';

export const toast = {
  success: (message: string, autohide = true) => {
    const t: ToastSettings = {
      message,
      preset: 'success',
      autohide,
      timeout: 5000
    };
    toastStore.trigger(t);
  },
  
  error: (message: string, autohide = true) => {
    const t: ToastSettings = {
      message,
      preset: 'error',
      autohide,
      timeout: 8000
    };
    toastStore.trigger(t);
  },
  
  warning: (message: string, autohide = true) => {
    const t: ToastSettings = {
      message,
      preset: 'warning',
      autohide,
      timeout: 6000
    };
    toastStore.trigger(t);
  },
  
  custom: (settings: ToastSettings) => {
    toastStore.trigger(settings);
  }
};

// Usage
import { toast } from '$lib/utils/toast';

// In component
toast.success('Event created successfully!');
toast.error('Failed to save changes');
```

## Data Fetching Patterns

### TanStack Query Integration
```typescript
// ⚠️ UNVERIFIED - May use different data fetching approach
// hooks/useEvents.ts
import { createQuery } from '@tanstack/svelte-query';
import type { Event } from '$lib/types';

export function useEvents(accountId?: string) {
  return createQuery({
    queryKey: ['events', accountId],
    queryFn: async () => {
      const params = accountId ? `?accountId=${accountId}` : '';
      const response = await fetch(`/api/events${params}`);
      
      if (!response.ok) {
        throw new Error('Failed to fetch events');
      }
      
      return response.json() as Promise<Event[]>;
    },
    staleTime: 5 * 60 * 1000, // 5 minutes
    cacheTime: 10 * 60 * 1000 // 10 minutes
  });
}

// Usage in component
<script lang="ts">
  import { useEvents } from '$lib/hooks/useEvents';
  
  const query = useEvents(accountId);
  
  $: ({ data: events, isLoading, error } = $query);
</script>
```

---

## ⚠️ IMPORTANT REMINDERS

1. **Version Differences**: tuvens-client and eventsdigest-ai may use different versions of:
   - Svelte (4 vs 5)
   - Skeleton UI (v1 vs v2)
   - TailwindCSS configurations
   - State management approaches

2. **Before Implementation**:
   - Check `package.json` for exact versions
   - Review existing components for patterns
   - Verify API endpoints and data structures
   - Test component integration

3. **Update This File**: After reviewing actual codebases, update these examples with verified patterns

4. **Start New Session**: Use `/start-session svelte-dev` to get accurate, project-specific guidance

These examples are starting points only. The actual implementation in your repositories should be the authoritative source.