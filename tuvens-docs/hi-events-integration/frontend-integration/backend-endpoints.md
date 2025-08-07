# Backend Endpoints Available

Your backend now provides these cross-app authentication endpoints:

- `POST /api/cross-app/generate-session` - Generate session token (requires JWT)
- `POST /api/cross-app/validate-session` - Validate session token (Hi.Events calls this)
- `GET /api/cross-app/user-accounts` - Get user accounts (Hi.Events calls this)
- `POST /api/cross-app/validate-permission` - Validate permissions (Hi.Events calls this)