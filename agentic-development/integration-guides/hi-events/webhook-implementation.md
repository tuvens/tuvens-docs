# Hi.Events Webhook Implementation - Issue #24

## Implementation Summary

The Hi.Events status change webhook endpoint has been successfully implemented in the Tuvens API. This endpoint receives notifications when Hi.Events event status changes and automatically updates the corresponding Tuvens event records.

## API Endpoint Details

### Endpoint
```
POST /api/webhooks/hi-events/event-status-changed
```

### Headers Required
- `Content-Type: application/json`
- `x-hi-events-signature: sha256=<hmac_signature>` (HMAC-SHA256 of request body using shared secret)

### Expected Payload Format
```json
{
  "event_type": "event.status_changed",
  "event_sent_at": "2025-07-25T10:30:00.000Z",
  "payload": {
    "id": 2,
    "title": "Event Title",
    "status": "LIVE",
    "tuvens_event_id": "11"
  }
}
```

### Response Format
```json
{
  "success": true,
  "message": "Webhook processed successfully"
}
```

## Security Implementation

### Signature Verification
- Uses HMAC-SHA256 with shared secret from `HI_EVENTS_SHARED_SECRET` environment variable
- Signature format: `sha256=<hex_digest>`
- Implements timing-safe comparison to prevent timing attacks
- Returns 401 Unauthorized for invalid signatures

### Input Validation
- Validates required payload structure
- Checks data types for all required fields
- Returns 400 Bad Request for malformed payloads

## Status Mapping

The webhook maps Hi.Events status values to Tuvens ticketing status:

| Hi.Events Status | Tuvens ticketStatus | Description |
|-----------------|-------------------|-------------|
| `LIVE` | `active` | Event is live and ticketing is active |
| `DRAFT` | `setup` | Event is in draft/setup mode |
| `CANCELLED` | `inactive` | Event cancelled, ticketing disabled |
| `ENDED` | `inactive` | Event ended, ticketing disabled |
| Other | `setup` | Default fallback status |

## Database Updates

When a webhook is received, the following fields are updated in the Tuvens event record:

1. **ticketStatus**: Updated based on status mapping above
2. **contactData**: Enhanced with Hi.Events metadata:
   ```json
   {
     "hiEventsEventId": 2,
     "hiEventsStatus": "LIVE",
     "hiEventsLastUpdated": "2025-07-25T14:30:00.000Z"
   }
   ```

## Error Handling

### HTTP Status Codes
- `200`: Webhook processed successfully
- `400`: Invalid webhook payload structure
- `401`: Invalid or missing webhook signature
- `404`: Tuvens event not found
- `500`: Internal server error during processing

### Error Response Format
```json
{
  "statusCode": 400,
  "timestamp": "2025-07-25T14:30:00.000Z",
  "path": "/api/webhooks/hi-events/event-status-changed",
  "message": "Invalid webhook payload",
  "origin": {
    "message": "Missing required field: tuvens_event_id"
  }
}
```

## Logging

All webhook operations are comprehensively logged:
- Incoming webhook requests
- Signature verification results
- Event update operations
- Error conditions and failures

## Configuration Requirements

### Environment Variables
```bash
HI_EVENTS_SHARED_SECRET=your_shared_secret_here
```

### Hi.Events Configuration
Hi.Events needs to be configured to send webhooks to:
```
https://your-tuvens-api-domain.com/api/webhooks/hi-events/event-status-changed
```

## Integration Notes

### For Hi.Events Team
1. **Webhook URL**: Point to the Tuvens API endpoint above
2. **Signature**: Generate HMAC-SHA256 signature using shared secret
3. **Payload**: Must include `tuvens_event_id` field to identify the corresponding Tuvens event
4. **Retry Logic**: Implement retry logic for 5xx errors
5. **Timeout**: Set reasonable timeout (recommended: 30 seconds)

### For Tuvens-Client Team
1. **Event Status**: Check `ticketStatus` field on events to determine ticketing availability
2. **Widget Display**: Show ticketing widget when `ticketStatus === 'active'`
3. **Hi.Events Data**: Access Hi.Events metadata via `event.contactData.hiEventsEventId`
4. **Real-time Updates**: Consider implementing WebSocket/SSE for real-time status updates
5. **Error Handling**: Handle cases where Hi.Events integration is not available

## Testing

### Test Webhook Payload
```bash
curl -X POST https://localhost:3001/api/webhooks/hi-events/event-status-changed \
  -H "Content-Type: application/json" \
  -H "x-hi-events-signature: sha256=<calculated_signature>" \
  -d '{
    "event_type": "event.status_changed",
    "event_sent_at": "2025-07-25T14:30:00Z",
    "payload": {
      "id": 123,
      "title": "Test Event",
      "status": "LIVE",
      "tuvens_event_id": "456"
    }
  }'
```

### Signature Calculation (Node.js example)
```javascript
const crypto = require('crypto');
const payload = JSON.stringify(webhookPayload);
const signature = crypto
  .createHmac('sha256', process.env.HI_EVENTS_SHARED_SECRET)
  .update(payload, 'utf8')
  .digest('hex');
const header = `sha256=${signature}`;
```

## Files Created/Modified

### New Files
- `src/controllers/api/webhooks/hi-events/hi-events-webhook.controller.ts`
- `src/services/webhooks/hi-events/hi-events-webhook.service.ts`
- `src/controllers/api/webhooks/hi-events/hi-events-webhook.module.ts`

### Modified Files
- `src/app.module.ts` (added HiEventsWebhookModule import)

## Next Steps

1. **Hi.Events Team**: Configure webhook URL and implement signature generation
2. **Tuvens-Client Team**: Update UI to display ticketing widgets based on `ticketStatus`
3. **DevOps**: Ensure `HI_EVENTS_SHARED_SECRET` environment variable is configured
4. **Testing**: Coordinate end-to-end testing between all teams

## Support

For questions or issues with this implementation:
- Review server logs for webhook processing details
- Check environment variable configuration
- Verify Hi.Events payload format matches expected structure
- Test signature generation independently