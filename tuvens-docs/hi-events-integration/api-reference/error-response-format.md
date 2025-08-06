# 🚨 Error Response Format

All API endpoints return errors in the following standardized format:

```typescript
interface ErrorResponse {
    statusCode: number;
    timestamp: string; // ISO 8601
    path: string;
    message: string;
    origin?: {
        message: string;
        code?: string;
        details?: any;
    };
}
```

**Example Error Response**:
```json
{
    "statusCode": 400,
    "timestamp": "2025-07-25T14:30:00.000Z",
    "path": "/api/cross-app/generate-session",
    "message": "Invalid request payload",
    "origin": {
        "message": "Missing required field: account_id",
        "code": "VALIDATION_ERROR"
    }
}
```