# Frontend Implementation Steps

### Step 1: Add "Add Ticketing" Button

Add a ticketing button to your event creation/edit interface:

```typescript
// EventEditPage.tsx or similar
interface EventWithTicketing {
  id: number;
  title: string;
  description: string;
  startDate: string;
  endDate: string;
  location: string;
  // ... other event fields
  hasTicketing?: boolean;
  hiEventsEventId?: string;
}

const EventTicketingSection = ({ event }: { event: EventWithTicketing }) => {
  const [isEnablingTicketing, setIsEnablingTicketing] = useState(false);

  const handleAddTicketing = async () => {
    setIsEnablingTicketing(true);
    try {
      await enableTicketingForEvent(event);
    } catch (error) {
      console.error('Failed to enable ticketing:', error);
      // Handle error (show toast, etc.)
    } finally {
      setIsEnablingTicketing(false);
    }
  };

  if (event.hasTicketing) {
    return (
      <div className="ticketing-section">
        <h3>Ticketing Enabled</h3>
        <p>This event has ticketing powered by Hi.Events</p>
        <a 
          href={`https://tickets.tuvens.com/manage/events/${event.hiEventsEventId}`}
          target="_blank"
          rel="noopener noreferrer"
          className="btn btn-primary"
        >
          Manage Tickets on Hi.Events
        </a>
      </div>
    );
  }

  return (
    <div className="ticketing-section">
      <h3>Add Ticketing</h3>
      <p>Enable ticket sales for this event using Hi.Events</p>
      <button 
        onClick={handleAddTicketing}
        disabled={isEnablingTicketing}
        className="btn btn-secondary"
      >
        {isEnablingTicketing ? 'Setting up...' : 'Add Ticketing'}
      </button>
    </div>
  );
};
```

### Step 2: Implement Cross-App Authentication Flow

Create a service to handle the cross-app authentication:

```typescript
// services/hiEventsService.ts
import { apiClient } from './apiClient'; // Your existing API client

interface SessionTokenResponse {
  session_token: string;
  expires_at: string;
}

interface HiEventsEventData {
  title: string;
  description: string;
  start_date: string;
  end_date: string;
  timezone: string;
  location_details: {
    venue_name: string;
    address_line_1?: string;
    city?: string;
    state_region?: string;
    zip_postal_code?: string;
    country?: string;
  };
  settings: {
    pre_registration_message?: string;
    post_registration_message?: string;
    allow_search_engine_indexing: boolean;
  };
}

class HiEventsService {
  private readonly HI_EVENTS_BASE_URL = 'https://tickets.tuvens.com';

  /**
   * Generate a session token for cross-app authentication
   */
  async generateSessionToken(accountId?: number): Promise<SessionTokenResponse> {
    const response = await apiClient.post('/api/cross-app/generate-session', {
      account_id: accountId
    });
    return response.data;
  }

  /**
   * Enable ticketing for a Tuvens event
   */
  async enableTicketingForEvent(event: EventWithTicketing): Promise<void> {
    // Step 1: Generate session token
    const sessionData = await this.generateSessionToken();
    
    // Step 2: Prepare Hi.Events event data
    const hiEventsData = this.mapTuvensEventToHiEvents(event);
    
    // Step 3: Redirect to Hi.Events with session token and event data
    const redirectUrl = this.buildHiEventsRedirectUrl(sessionData.session_token, hiEventsData);
    
    // Open in new tab/window
    window.open(redirectUrl, '_blank');
  }

  /**
   * Map Tuvens event data to Hi.Events format
   */
  private mapTuvensEventToHiEvents(event: EventWithTicketing): HiEventsEventData {
    return {
      title: event.title,
      description: event.description,
      start_date: event.startDate,
      end_date: event.endDate,
      timezone: 'UTC', // or detect user's timezone
      location_details: {
        venue_name: event.location,
        // Parse location if you have structured address data
        // address_line_1: ...,
        // city: ...,
        // etc.
      },
      settings: {
        pre_registration_message: `Welcome to ${event.title}!`,
        post_registration_message: 'Thank you for registering!',
        allow_search_engine_indexing: true,
      },
    };
  }

  /**
   * Build Hi.Events redirect URL with session token and event data
   */
  private buildHiEventsRedirectUrl(sessionToken: string, eventData: HiEventsEventData): string {
    const params = new URLSearchParams({
      session_token: sessionToken,
      action: 'create_event',
      source: 'tuvens',
      event_data: JSON.stringify(eventData),
    });
    
    return `${this.HI_EVENTS_BASE_URL}/auth/cross-app?${params.toString()}`;
  }

  /**
   * Generate Hi.Events widget embed code
   */
  generateWidgetEmbedCode(hiEventsEventId: string): string {
    return `
      <div id="hi-events-widget-${hiEventsEventId}"></div>
      <script>
        (function() {
          var script = document.createElement('script');
          script.src = 'https://tickets.tuvens.com/widget/embed.js';
          script.async = true;
          script.onload = function() {
            HiEventsWidget.init({
              eventId: '${hiEventsEventId}',
              containerId: 'hi-events-widget-${hiEventsEventId}',
              theme: 'light', // or 'dark'
              primaryColor: '#your-brand-color'
            });
          };
          document.head.appendChild(script);
        })();
      </script>
    `;
  }
}

export const hiEventsService = new HiEventsService();
export const enableTicketingForEvent = (event: EventWithTicketing) => 
  hiEventsService.enableTicketingForEvent(event);
```

### Step 3: Handle Hi.Events Callbacks

Set up a callback handler for when users return from Hi.Events:

```typescript
// pages/HiEventsCallback.tsx
import { useEffect, useState } from 'react';
import { useSearchParams, useNavigate } from 'react-router-dom';

const HiEventsCallback = () => {
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const [status, setStatus] = useState<'loading' | 'success' | 'error'>('loading');

  useEffect(() => {
    const handleCallback = async () => {
      try {
        const eventId = searchParams.get('tuvens_event_id');
        const hiEventsEventId = searchParams.get('hi_events_event_id');
        const success = searchParams.get('success') === 'true';

        if (!success || !eventId || !hiEventsEventId) {
          throw new Error('Invalid callback parameters');
        }

        // Update your Tuvens event with Hi.Events data
        await apiClient.patch(`/api/events/${eventId}`, {
          hasTicketing: true,
          hiEventsEventId: hiEventsEventId,
        });

        setStatus('success');
        
        // Redirect back to event edit page after 2 seconds
        setTimeout(() => {
          navigate(`/events/${eventId}/edit`);
        }, 2000);

      } catch (error) {
        console.error('Hi.Events callback error:', error);
        setStatus('error');
      }
    };

    handleCallback();
  }, [searchParams, navigate]);

  return (
    <div className="hi-events-callback">
      {status === 'loading' && (
        <div>Setting up ticketing for your event...</div>
      )}
      {status === 'success' && (
        <div>
          <h2>Ticketing Enabled Successfully!</h2>
          <p>Your event now has ticketing powered by Hi.Events.</p>
          <p>Redirecting you back to your event...</p>
        </div>
      )}
      {status === 'error' && (
        <div>
          <h2>Setup Failed</h2>
          <p>There was an error setting up ticketing. Please try again.</p>
          <button onClick={() => navigate(-1)}>Go Back</button>
        </div>
      )}
    </div>
  );
};

export default HiEventsCallback;
```

### Step 4: Display Ticket Widget on Event Pages

Add the Hi.Events widget to your public event pages:

```typescript
// components/EventTicketWidget.tsx
import { useEffect, useRef } from 'react';

interface EventTicketWidgetProps {
  hiEventsEventId: string;
  theme?: 'light' | 'dark';
  primaryColor?: string;
}

const EventTicketWidget = ({ 
  hiEventsEventId, 
  theme = 'light', 
  primaryColor = '#2563eb' 
}: EventTicketWidgetProps) => {
  const widgetRef = useRef<HTMLDivElement>(null);
  const scriptLoadedRef = useRef(false);

  useEffect(() => {
    if (scriptLoadedRef.current) return;

    const script = document.createElement('script');
    script.src = 'https://tickets.tuvens.com/widget/embed.js';
    script.async = true;
    
    script.onload = () => {
      scriptLoadedRef.current = true;
      // @ts-ignore - Hi.Events widget global
      if (window.HiEventsWidget && widgetRef.current) {
        window.HiEventsWidget.init({
          eventId: hiEventsEventId,
          containerId: widgetRef.current.id,
          theme,
          primaryColor,
          onTicketSelected: (ticketData: any) => {
            // Optional: Track ticket selection analytics
            console.log('Ticket selected:', ticketData);
          },
          onPurchaseComplete: (purchaseData: any) => {
            // Optional: Track successful purchases
            console.log('Purchase completed:', purchaseData);
          }
        });
      }
    };

    script.onerror = () => {
      console.error('Failed to load Hi.Events widget script');
    };

    document.head.appendChild(script);

    return () => {
      if (script.parentNode) {
        script.parentNode.removeChild(script);
      }
    };
  }, [hiEventsEventId, theme, primaryColor]);

  return (
    <div className="event-ticket-widget">
      <h3>Get Your Tickets</h3>
      <div 
        ref={widgetRef}
        id={`hi-events-widget-${hiEventsEventId}`}
        className="hi-events-widget-container"
      />
    </div>
  );
};

export default EventTicketWidget;
```