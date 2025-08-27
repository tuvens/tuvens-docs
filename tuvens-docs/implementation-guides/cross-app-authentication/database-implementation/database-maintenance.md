# Database Maintenance

### Cleanup Procedures

```sql
-- Clean up expired sessions (run via scheduled job)
DELETE FROM cross_app_sessions 
WHERE expires_at < CURRENT_TIMESTAMP 
   OR revoked_at IS NOT NULL;

-- Archive old sessions (optional, for audit purposes)
INSERT INTO cross_app_sessions_archive 
SELECT * FROM cross_app_sessions 
WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '30 days';

-- Get session statistics
SELECT 
    DATE(created_at) as date,
    COUNT(*) as sessions_created,
    COUNT(CASE WHEN used_at IS NOT NULL THEN 1 END) as sessions_used,
    COUNT(CASE WHEN revoked_at IS NOT NULL THEN 1 END) as sessions_revoked,
    COUNT(CASE WHEN expires_at < CURRENT_TIMESTAMP THEN 1 END) as sessions_expired
FROM cross_app_sessions 
WHERE created_at >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### Performance Monitoring

```sql
-- Monitor table size and performance
SELECT 
    schemaname,
    tablename,
    n_tup_ins as inserts,
    n_tup_upd as updates,
    n_tup_del as deletes,
    n_live_tup as live_tuples,
    n_dead_tup as dead_tuples,
    last_vacuum,
    last_autovacuum,
    last_analyze,
    last_autoanalyze
FROM pg_stat_user_tables 
WHERE tablename = 'cross_app_sessions';

-- Check index usage
SELECT 
    indexrelname as index_name,
    idx_tup_read as index_reads,
    idx_tup_fetch as index_fetches,
    idx_scan as index_scans
FROM pg_stat_user_indexes 
WHERE relname = 'cross_app_sessions';
```