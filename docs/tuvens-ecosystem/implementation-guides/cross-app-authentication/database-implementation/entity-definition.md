# Entity Definition

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