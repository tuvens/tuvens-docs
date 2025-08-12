# Security Considerations

1. **Session Token Security**: Session tokens expire in 15 minutes and are single-use
2. **CORS Configuration**: Ensure your backend allows requests from Hi.Events domain
3. **Shared Secret**: Keep the shared secret secure and rotate it regularly
4. **Input Validation**: Validate all data sent to Hi.Events
5. **CSP Headers**: Update Content Security Policy to allow Hi.Events widget scripts