# 🔧 Technical Standards

### Code Quality Requirements

#### All Repositories Must Have:
- **Linting Configuration** (ESLint, Prettier, Black, etc.)
- **Type Checking** (TypeScript, mypy, etc.)
- **Test Coverage** minimum 80%
- **Security Scanning** (CodeQL, Snyk, etc.)
- **Documentation Generation** (JSDoc, Sphinx, etc.)

#### Commit Message Format
```
type(scope): description

[optional body]

[optional footer]
```

**Types**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`
**Scopes**: `api`, `ui`, `auth`, `integration`, `docs`, `ci`

**Examples**:
```
feat(auth): add cross-app session token generation
fix(ui): resolve ticket widget loading issue
docs(integration): update Hi.Events authentication flow
```

### API Design Standards

#### REST API Guidelines
1. **Consistent Base URLs**
   ```
   https://api.tuvens.com/v1/
   https://tickets.tuvens.com/api/v1/
   ```

2. **Standard HTTP Methods**
   - `GET` - Retrieve resources
   - `POST` - Create resources
   - `PUT` - Update entire resources
   - `PATCH` - Partial resource updates
   - `DELETE` - Remove resources

3. **Response Format**
   ```json
   {
     "data": {},
     "meta": {
       "timestamp": "2025-07-24T14:30:00Z",
       "version": "1.0"
     },
     "errors": []
   }
   ```

4. **Error Response Format**
   ```json
   {
     "error": {
       "code": "AUTHENTICATION_FAILED",
       "message": "Invalid JWT token",
       "details": {},
       "timestamp": "2025-07-24T14:30:00Z"
     }
   }
   ```

#### GraphQL Guidelines (where applicable)
1. **Schema Versioning** through field deprecation
2. **Query Complexity** limits and depth analysis
3. **Subscription** patterns for real-time updates
4. **Error Handling** with proper error codes

### Database Standards

#### Schema Management
1. **Migration Scripts** for all schema changes
2. **Rollback Procedures** for failed migrations
3. **Cross-Database** foreign key documentation
4. **Data Validation** at application and database levels

#### Naming Conventions
- **Tables**: `snake_case` (e.g., `user_accounts`, `cross_app_sessions`)
- **Columns**: `snake_case` (e.g., `created_at`, `user_id`)
- **Indexes**: `idx_table_column` (e.g., `idx_users_email`)
- **Foreign Keys**: `fk_table_referenced_table` (e.g., `fk_sessions_users`)