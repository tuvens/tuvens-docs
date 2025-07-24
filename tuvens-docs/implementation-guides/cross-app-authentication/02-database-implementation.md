# Database Implementation

## Overview
This document provides the complete database schema and implementation for cross-app authentication session management.

## Database Schema

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

## Migration Script

### NestJS TypeORM Migration

```typescript
// src/migrations/1642700000000-CreateCrossAppSessions.ts
import { MigrationInterface, QueryRunner, Table, Index } from 'typeorm';

export class CreateCrossAppSessions1642700000000 implements MigrationInterface {
    name = 'CreateCrossAppSessions1642700000000';

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.createTable(
            new Table({
                name: 'cross_app_sessions',
                columns: [
                    {
                        name: 'id',
                        type: 'serial',
                        isPrimary: true,
                    },
                    {
                        name: 'token_hash',
                        type: 'varchar',
                        length: '255',
                        isUnique: true,
                        isNullable: false,
                    },
                    {
                        name: 'user_id',
                        type: 'integer',
                        isNullable: false,
                    },
                    {
                        name: 'account_id',
                        type: 'integer',
                        isNullable: true,
                    },
                    {
                        name: 'expires_at',
                        type: 'timestamp',
                        isNullable: false,
                    },
                    {
                        name: 'created_at',
                        type: 'timestamp',
                        default: 'CURRENT_TIMESTAMP',
                    },
                    {
                        name: 'used_at',
                        type: 'timestamp',
                        isNullable: true,
                    },
                    {
                        name: 'revoked_at',
                        type: 'timestamp',
                        isNullable: true,
                    },
                    {
                        name: 'source_app',
                        type: 'varchar',
                        length: '50',
                        default: "'tuvens'",
                    },
                    {
                        name: 'target_app',
                        type: 'varchar',
                        length: '50',
                        default: "'hi-events'",
                    },
                    {
                        name: 'user_agent',
                        type: 'text',
                        isNullable: true,
                    },
                    {
                        name: 'ip_address',
                        type: 'inet',
                        isNullable: true,
                    },
                ],
                foreignKeys: [
                    {
                        columnNames: ['user_id'],
                        referencedTableName: 'users',
                        referencedColumnNames: ['id'],
                        onDelete: 'CASCADE',
                    },
                    {
                        columnNames: ['account_id'],
                        referencedTableName: 'accounts',
                        referencedColumnNames: ['id'],
                        onDelete: 'CASCADE',
                    },
                ],
            }),
            true,
        );

        // Create indexes
        await queryRunner.createIndex(
            'cross_app_sessions',
            new Index({
                name: 'IDX_CROSS_APP_SESSIONS_TOKEN_HASH',
                columnNames: ['token_hash'],
            }),
        );

        await queryRunner.createIndex(
            'cross_app_sessions',
            new Index({
                name: 'IDX_CROSS_APP_SESSIONS_EXPIRES_AT',
                columnNames: ['expires_at'],
            }),
        );

        await queryRunner.createIndex(
            'cross_app_sessions',
            new Index({
                name: 'IDX_CROSS_APP_SESSIONS_USER_ID',
                columnNames: ['user_id'],
            }),
        );

        await queryRunner.createIndex(
            'cross_app_sessions',
            new Index({
                name: 'IDX_CROSS_APP_SESSIONS_CREATED_AT',
                columnNames: ['created_at'],
            }),
        );
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.dropTable('cross_app_sessions');
    }
}
```

## Entity Definition

### TypeORM Entity

```typescript
// src/entities/cross-app-session.entity.ts
import {
    Entity,
    PrimaryGeneratedColumn,
    Column,
    CreateDateColumn,
    ManyToOne,
    JoinColumn,
    Index,
} from 'typeorm';
import { User } from './user.entity';
import { Account } from './account.entity';

@Entity('cross_app_sessions')
@Index('IDX_CROSS_APP_SESSIONS_TOKEN_HASH', ['tokenHash'], { unique: true })
@Index('IDX_CROSS_APP_SESSIONS_EXPIRES_AT', ['expiresAt'])
@Index('IDX_CROSS_APP_SESSIONS_USER_ID', ['userId'])
export class CrossAppSession {
    @PrimaryGeneratedColumn()
    id: number;

    @Column({ name: 'token_hash', type: 'varchar', length: 255, unique: true })
    tokenHash: string;

    @Column({ name: 'user_id', type: 'integer' })
    userId: number;

    @Column({ name: 'account_id', type: 'integer', nullable: true })
    accountId?: number;

    @Column({ name: 'expires_at', type: 'timestamp' })
    expiresAt: Date;

    @CreateDateColumn({ name: 'created_at' })
    createdAt: Date;

    @Column({ name: 'used_at', type: 'timestamp', nullable: true })
    usedAt?: Date;

    @Column({ name: 'revoked_at', type: 'timestamp', nullable: true })
    revokedAt?: Date;

    @Column({ name: 'source_app', type: 'varchar', length: 50, default: 'tuvens' })
    sourceApp: string;

    @Column({ name: 'target_app', type: 'varchar', length: 50, default: 'hi-events' })
    targetApp: string;

    @Column({ name: 'user_agent', type: 'text', nullable: true })
    userAgent?: string;

    @Column({ name: 'ip_address', type: 'inet', nullable: true })
    ipAddress?: string;

    // Relations
    @ManyToOne(() => User, user => user.crossAppSessions, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'user_id' })
    user: User;

    @ManyToOne(() => Account, account => account.crossAppSessions, { onDelete: 'CASCADE' })
    @JoinColumn({ name: 'account_id' })
    account?: Account;

    // Computed properties
    get isExpired(): boolean {
        return new Date() > this.expiresAt;
    }

    get isRevoked(): boolean {
        return this.revokedAt !== null;
    }

    get isActive(): boolean {
        return !this.isExpired && !this.isRevoked;
    }
}
```

## Database Seeding (Optional)

### Development Seed Data

```typescript
// src/database/seeds/cross-app-sessions.seed.ts
import { DataSource } from 'typeorm';
import { CrossAppSession } from '../entities/cross-app-session.entity';
import { User } from '../entities/user.entity';

export async function seedCrossAppSessions(dataSource: DataSource) {
    const sessionRepo = dataSource.getRepository(CrossAppSession);
    const userRepo = dataSource.getRepository(User);

    // Clean existing test sessions
    await sessionRepo.delete({ sourceApp: 'test' });

    // Create test user if not exists
    let testUser = await userRepo.findOne({ where: { email: 'test@example.com' } });
    if (!testUser) {
        testUser = await userRepo.save({
            email: 'test@example.com',
            name: 'Test User',
        });
    }

    // Create test sessions for development
    const testSessions = [
        {
            tokenHash: 'test_hash_1',
            userId: testUser.id,
            expiresAt: new Date(Date.now() + 15 * 60 * 1000), // 15 minutes from now
            sourceApp: 'test',
            targetApp: 'hi-events',
        },
        {
            tokenHash: 'test_hash_2',
            userId: testUser.id,
            expiresAt: new Date(Date.now() - 5 * 60 * 1000), // 5 minutes ago (expired)
            sourceApp: 'test',
            targetApp: 'hi-events',
        },
    ];

    await sessionRepo.save(testSessions);
    console.log('Cross-app sessions seeded successfully');
}
```

## Database Maintenance

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

## Backup and Recovery

### Backup Strategy

```bash
# Backup cross-app sessions table
pg_dump -h localhost -U postgres -t cross_app_sessions tuvens_db > cross_app_sessions_backup.sql

# Restore cross-app sessions table
psql -h localhost -U postgres tuvens_db < cross_app_sessions_backup.sql
```

### Data Retention Policy

```sql
-- Create archive table for long-term storage
CREATE TABLE cross_app_sessions_archive (
    LIKE cross_app_sessions INCLUDING ALL
);

-- Partition by date (PostgreSQL 10+)
CREATE TABLE cross_app_sessions_2025_01 PARTITION OF cross_app_sessions
    FOR VALUES FROM ('2025-01-01') TO ('2025-02-01');

CREATE TABLE cross_app_sessions_2025_02 PARTITION OF cross_app_sessions
    FOR VALUES FROM ('2025-02-01') TO ('2025-03-01');
```

---

**Next**: Continue with [Service Layer Implementation](./03-service-layer.md) to implement the business logic for session management.