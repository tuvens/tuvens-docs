# Migration Script

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