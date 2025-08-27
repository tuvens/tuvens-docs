# 📝 Integration Examples

### Complete Integration Flow

```typescript
// 1. Generate session token
const sessionResponse = await fetch('/api/cross-app/generate-session', {
    method: 'POST',
    headers: {
        'Authorization': `Bearer ${userToken}`,
        'Content-Type': 'application/json'
    },
    body: JSON.stringify({ account_id: 123 })
});

const { session_token, expires_at } = await sessionResponse.json();

// 2. Redirect to Hi.Events
const hiEventsUrl = new URL('https://tickets.tuvens.com/auth/cross-app');
hiEventsUrl.searchParams.set('session_token', session_token);
hiEventsUrl.searchParams.set('return_url', window.location.href);
hiEventsUrl.searchParams.set('app_id', 'tuvens');

window.location.href = hiEventsUrl.toString();

// 3. Handle callback (Hi.Events validates session behind the scenes)
const urlParams = new URLSearchParams(window.location.search);
const status = urlParams.get('status');

if (status === 'success') {
    // Update UI to show ticketing widget
    updateTicketingStatus('active');
}
```

### Webhook Handler Example

```typescript
// Webhook signature verification
function verifyWebhookSignature(payload: string, signature: string): boolean {
    const expectedSignature = crypto
        .createHmac('sha256', process.env.HI_EVENTS_SHARED_SECRET)
        .update(payload, 'utf8')
        .digest('hex');
    
    const expectedHeader = `sha256=${expectedSignature}`;
    return crypto.timingSafeEqual(
        Buffer.from(signature),
        Buffer.from(expectedHeader)
    );
}

// Webhook processing
export async function POST({ request }: RequestEvent) {
    const signature = request.headers.get('x-hi-events-signature');
    const payload = await request.text();
    
    if (!verifyWebhookSignature(payload, signature)) {
        return new Response('Unauthorized', { status: 401 });
    }
    
    const webhookData = JSON.parse(payload);
    await processStatusChange(webhookData.payload);
    
    return Response.json({ success: true });
}
```

This API reference provides complete documentation for integrating with the Hi.Events ticketing system, including all endpoints, data structures, error handling, and security considerations.