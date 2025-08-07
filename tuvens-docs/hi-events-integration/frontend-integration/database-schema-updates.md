# Database Schema Updates

Update your event model to include Hi.Events integration:

```sql
-- Add columns to your events table
ALTER TABLE events ADD COLUMN has_ticketing BOOLEAN DEFAULT FALSE;
ALTER TABLE events ADD COLUMN hi_events_event_id VARCHAR(255);
ALTER TABLE events ADD COLUMN ticketing_enabled_at TIMESTAMP;
```