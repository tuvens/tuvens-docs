# Hi.Events Frontend Integration Guide

This guide provides comprehensive instructions for integrating Hi.Events ticketing functionality into your Tuvens frontend application.

## Overview

The integration allows users to:
1. Create events in Tuvens
2. Click "Add Ticketing" to seamlessly authenticate on Hi.Events
3. Automatically create a corresponding event in Hi.Events with imported data
4. Edit ticketing details on tickets.tuvens.com
5. Display Hi.Events ticket purchasing widget on Tuvens event pages

## Architecture Flow

```
Tuvens Event → "Add Ticketing" → Cross-App Auth → Hi.Events Event Creation → Widget Display
```

## ✅ Hi.Events Implementation Status

The Hi.Events cross-app authentication route is now **fully implemented**:

### Available Route
- `GET /auth/cross-app` - Handles cross-app authentication
- Supports all required URL parameters
- Validates session tokens with Tuvens backend
- Pre-populates event creation forms
- Handles success/error callbacks

### Environment Variables Required
```bash
VITE_TUVENS_API_URL=https://your-tuvens-api-url
VITE_TUVENS_SHARED_SECRET=your-shared-secret
```

## Backend Endpoints Available

Your backend now provides these cross-app authentication endpoints:

- `POST /api/cross-app/generate-session` - Generate session token (requires JWT)
- `POST /api/cross-app/validate-session` - Validate session token (Hi.Events calls this)
- `GET /api/cross-app/user-accounts` - Get user accounts (Hi.Events calls this)
- `POST /api/cross-app/validate-permission` - Validate permissions (Hi.Events calls this)

## Frontend Implementation Steps

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

## Database Schema Updates

Update your event model to include Hi.Events integration:

```sql
-- Add columns to your events table
ALTER TABLE events ADD COLUMN has_ticketing BOOLEAN DEFAULT FALSE;
ALTER TABLE events ADD COLUMN hi_events_event_id VARCHAR(255);
ALTER TABLE events ADD COLUMN ticketing_enabled_at TIMESTAMP;
```

## Environment Configuration

Ensure your frontend has access to the Hi.Events URL:

```typescript
// config/environment.ts
export const config = {
  hiEventsUrl: process.env.REACT_APP_HI_EVENTS_URL || 'https://tickets.tuvens.com',
  apiBaseUrl: process.env.REACT_APP_API_BASE_URL || 'http://localhost:3000',
};
```

## Testing the Integration

### 1. Test Session Generation
```bash
curl -X POST http://localhost:3000/api/cross-app/generate-session \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{"account_id": 1}'
```

### 2. Test Full Flow
1. Create an event in Tuvens
2. Click "Add Ticketing"
3. Verify redirect to Hi.Events with correct parameters
4. Complete setup in Hi.Events
5. Verify callback updates Tuvens event
6. Check widget displays on event page

## Security Considerations

1. **Session Token Security**: Session tokens expire in 15 minutes and are single-use
2. **CORS Configuration**: Ensure your backend allows requests from Hi.Events domain
3. **Shared Secret**: Keep the shared secret secure and rotate it regularly
4. **Input Validation**: Validate all data sent to Hi.Events
5. **CSP Headers**: Update Content Security Policy to allow Hi.Events widget scripts

## Analytics and Tracking

Consider adding analytics to track the ticketing integration:

```typescript
// Track ticketing events
const trackTicketingEnabled = (eventId: string) => {
  // Your analytics service (Google Analytics, Mixpanel, etc.)
  analytics.track('Ticketing Enabled', {
    eventId,
    timestamp: new Date().toISOString(),
  });
};

const trackTicketPurchase = (eventId: string, ticketData: any) => {
  analytics.track('Ticket Purchased', {
    eventId,
    ticketType: ticketData.type,
    quantity: ticketData.quantity,
    amount: ticketData.amount,
  });
};
```