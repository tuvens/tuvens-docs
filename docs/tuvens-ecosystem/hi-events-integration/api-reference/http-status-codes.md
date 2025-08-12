# 🎯 HTTP Status Codes

### Success Codes
- `200 OK`: Request successful
- `201 Created`: Resource created successfully

### Client Error Codes  
- `400 Bad Request`: Invalid request payload or parameters
- `401 Unauthorized`: Missing or invalid authentication
- `403 Forbidden`: Valid authentication but insufficient permissions
- `404 Not Found`: Resource not found
- `409 Conflict`: Resource conflict (e.g., duplicate session)
- `422 Unprocessable Entity`: Valid request but business logic error

### Server Error Codes
- `500 Internal Server Error`: Unexpected server error
- `502 Bad Gateway`: Upstream service error
- `503 Service Unavailable`: Service temporarily unavailable
- `504 Gateway Timeout`: Upstream service timeout