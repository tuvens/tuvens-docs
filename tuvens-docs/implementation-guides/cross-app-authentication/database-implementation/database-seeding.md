# Database Seeding (Optional)

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