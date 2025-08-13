# Database Schema

### Cross-App Sessions Table

```sql
-- Create the cross_app_sessions table
CREATE TABLE cross_app_sessions (
    id SERIAL PRIMARY KEY,
    token_hash VARCHAR(255) NOT NULL UNIQUE,
    user_id INTEGER NOT NULL,
    account_id INTEGER,
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    used_at TIMESTAMP,
    revoked_at TIMESTAMP,
    source_app VARCHAR(50) DEFAULT 'tuvens',
    target_app VARCHAR(50) DEFAULT 'hi-events',
    user_agent TEXT,
    ip_address INET,
    
    -- Foreign key constraints (adjust based on your user table)
    CONSTRAINT fk_cross_app_sessions_user_id 
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_cross_app_sessions_account_id 
        FOREIGN KEY (account_id) REFERENCES accounts(id) ON DELETE CASCADE
);

-- Create indexes for performance
CREATE INDEX idx_cross_app_sessions_token_hash 
    ON cross_app_sessions(token_hash);

CREATE INDEX idx_cross_app_sessions_expires_at 
    ON cross_app_sessions(expires_at);

CREATE INDEX idx_cross_app_sessions_user_id 
    ON cross_app_sessions(user_id);

CREATE INDEX idx_cross_app_sessions_created_at 
    ON cross_app_sessions(created_at);

-- Composite index for cleanup queries
CREATE INDEX idx_cross_app_sessions_cleanup 
    ON cross_app_sessions(expires_at, revoked_at) 
    WHERE revoked_at IS NULL;
```

### Table Field Descriptions

| Field | Type | Description |
|-------|------|-------------|
| `id` | SERIAL | Primary key for the session record |
| `token_hash` | VARCHAR(255) | SHA-256 hash of the session token (never store plaintext) |
| `user_id` | INTEGER | Reference to the authenticated user |
| `account_id` | INTEGER | Optional reference to specific account (for multi-tenant scenarios) |
| `expires_at` | TIMESTAMP | When the session token expires (UTC) |
| `created_at` | TIMESTAMP | When the session was created (UTC) |
| `used_at` | TIMESTAMP | When the session was last validated (for tracking) |
| `revoked_at` | TIMESTAMP | When the session was revoked (NULL if active) |
| `source_app` | VARCHAR(50) | Application that generated the session ('tuvens') |
| `target_app` | VARCHAR(50) | Target application for the session ('hi-events') |
| `user_agent` | TEXT | User agent string for security tracking |
| `ip_address` | INET | IP address of the request for security tracking |