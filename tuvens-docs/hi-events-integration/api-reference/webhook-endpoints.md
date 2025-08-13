# 🔗 Webhook Endpoints

### Hi.Events Status Change Webhook

**Endpoint**: `POST /api/webhooks/hi-events/event-status-changed`

**Description**: Receives Hi.Events status change notifications and updates Tuvens event records.

**Authentication**: HMAC-SHA256 Signature Required

**Request Headers**:
```http
Content-Type: application/json
x-hi-events-signature: sha256=<hmac_signature>
```

**Request Payload**:
```typescript
interface HiEventsWebhookPayload {
    event_type: "event.status_changed";
    event_sent_at: string; // ISO 8601 timestamp
    payload: {
        id: number; // Hi.Events event ID
        title: string;
        status: "LIVE" | "DRAFT" | "CANCELLED" | "ENDED";
        tuvens_event_id: string;
    };
}
```

**Example Request**:
```bash
curl -X POST https://api.tuvens.com/api/webhooks/hi-events/event-status-changed \
  -H "Content-Type: application/json" \
  -H "x-hi-events-signature: sha256=abc123def456..." \
  -d '{
    "event_type": "event.status_changed",
    "event_sent_at": "2025-07-25T14:30:00.000Z",
    "payload": {
        "id": 2,
        "title": "Event Title",
        "status": "LIVE",
        "tuvens_event_id": "11"
    }
  }'
```

**Response**:
```typescript
interface WebhookResponse {
    success: boolean;
    message: string;
}
```

**Example Response**:
```json
{
    "success": true,
    "message": "Webhook processed successfully"
}
```

**Status Mapping**:
| Hi.Events Status | Tuvens ticketStatus | Description |
|-----------------|-------------------|-------------|
| `LIVE` | `active` | Event is live and ticketing is active |
| `DRAFT` | `setup` | Event is in draft/setup mode |
| `CANCELLED` | `inactive` | Event cancelled, ticketing disabled |
| `ENDED` | `inactive` | Event ended, ticketing disabled |
| Other | `setup` | Default fallback status |

**Error Responses**:
- `401 Unauthorized`: Invalid or missing HMAC signature
- `400 Bad Request`: Invalid webhook payload structure
- `404 Not Found`: Tuvens event not found
- `500 Internal Server Error`: Webhook processing failed

**Signature Calculation**:
```javascript
const crypto = require('crypto');
const payload = JSON.stringify(webhookPayload);
const signature = crypto
    .createHmac('sha256', process.env.HI_EVENTS_SHARED_SECRET)
    .update(payload, 'utf8')
    .digest('hex');
const header = `sha256=${signature}`;
```