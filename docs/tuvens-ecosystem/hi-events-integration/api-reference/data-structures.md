# 🏗️ Data Structures

### Enhanced Event Type

```typescript
interface EventWithHiEvents {
    // Core event fields
    id: string;
    title: string;
    description: string;
    startDate: string;
    endDate: string;
    
    // Legacy ticketing fields (backward compatibility)
    hasTicketing?: boolean;
    hiEventsEventId?: number; 
    
    // New ticketing fields
    ticketing_enabled: boolean;
    ticketing_status: 'setup' | 'active' | 'inactive';
    hi_events_event_id: number;
    hi_events_event_url: string;
    
    // Enhanced contactData JSON
    contactData: {
        // Hi.Events metadata
        hiEventsEventId?: number;
        hiEventsStatus?: string;
        hiEventsLastUpdated?: string;
        
        // Other contact data
        email?: string;
        phone?: string;
        website?: string;
    };
}
```

### Cross-App Session Structure

```typescript
interface CrossAppSession {
    id: number;
    sessionToken: string;
    userId: number;
    accountId: number;
    appId: string;
    expiresAt: Date;
    createdAt: Date;
    lastUsed?: Date;
    sysCreated: Date;
    sysModified: Date;
}
```