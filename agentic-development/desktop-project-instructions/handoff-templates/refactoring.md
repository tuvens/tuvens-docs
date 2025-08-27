# Refactoring Handoff Template

## When to Use
- Code organization improvements
- Performance optimizations
- Technical debt reduction
- Pattern standardization
- Dependency updates

## Claude Desktop Analysis

### 1. Refactoring Scope
```markdown
Target: [files/modules/components]
Current issues:
- [ ] Code duplication
- [ ] Complex functions
- [ ] Poor naming
- [ ] Missing abstractions
- [ ] Performance problems
- [ ] Outdated patterns

Refactoring goals:
- [ ] Improve maintainability
- [ ] Enhance performance
- [ ] Standardize patterns
- [ ] Reduce complexity
- [ ] Update dependencies
```

### 2. Risk Assessment
- **Breaking changes**: [yes/no]
- **Test coverage**: [adequate/needs improvement]
- **Dependencies**: [what might be affected]
- **Rollback plan**: [how to revert if needed]

### 3. Agent Selection
- Code-heavy refactor → Domain specialist
- Architecture refactor → vibe-coder
- Cross-service refactor → Multiple agents coordinated

## Handoff Methods

### Natural Language (Recommended)
Use natural language to request refactoring:

**Pattern**: "Get [appropriate-agent] to refactor [target-path/description]"
**Example**: "Get node-dev to refactor the user authentication logic in tuvens-api"

**Result**:
- Creates GitHub issue with refactoring context
- Sets up agent session with current code analysis
- Routes to appropriate domain specialist

### Manual Refactoring Session
```markdown
Load: .claude/agents/[appropriate-agent].md

Refactoring task: [specific improvement needed]
Target: [files/directories]
Repository: [affected repo]

## Current Problems
1. [Issue 1]
2. [Issue 2]
3. [Issue 3]

## Desired Outcome
- [Goal 1]
- [Goal 2]
- [Goal 3]

## Constraints
- Maintain backward compatibility
- Keep all tests passing
- No functional changes
- Preserve existing APIs

Begin by analyzing the current code structure and creating a refactoring plan.
```

## Refactoring Patterns

### Extract Method/Component
```markdown
Identify code doing too much:
- Long functions (>50 lines)
- Multiple responsibilities
- Repeated patterns

Extract into:
- Named functions with single purpose
- Reusable components
- Shared utilities
```

### Simplify Conditionals
```markdown
Look for:
- Nested if/else chains
- Complex boolean expressions
- Switch statements with many cases

Refactor to:
- Early returns
- Guard clauses
- Strategy pattern
- Lookup tables
```

### Remove Duplication
```markdown
Find:
- Copy-pasted code
- Similar implementations
- Repeated patterns

Replace with:
- Shared functions
- Base classes/interfaces
- Configuration-driven behavior
```

## Safety Checklist

### Before Starting
- [ ] All tests passing
- [ ] Code committed/pushed
- [ ] Metrics baseline captured
- [ ] Dependencies documented

### During Refactoring
- [ ] Make incremental changes
- [ ] Run tests frequently
- [ ] Commit working states
- [ ] Document decisions

### After Completion
- [ ] All tests still passing
- [ ] Performance verified
- [ ] No functionality lost
- [ ] Code review completed

## Common Refactoring Tasks

### Frontend
```markdown
- Extract reusable components
- Consolidate state management
- Optimize re-renders
- Standardize styling approach
- Remove deprecated patterns
```

### Backend
```markdown
- Extract service layers
- Consolidate database queries
- Optimize N+1 queries
- Standardize error handling
- Improve logging/monitoring
```

### Cross-Cutting
```markdown
- Standardize naming conventions
- Update to modern syntax
- Improve type safety
- Enhance error messages
- Add missing documentation
```

## Success Metrics

### Code Quality
- Reduced complexity scores
- Higher test coverage
- Fewer linting warnings
- Better performance metrics

### Developer Experience
- Easier to understand
- Faster to modify
- More predictable behavior
- Better error messages

## Red Flags

Stop and reassess if:
- Tests start failing unexpectedly
- Performance degrades
- Behavior changes unintentionally
- Scope creeps beyond plan
- Dependencies break

## Example Refactoring Session

```markdown
Load: .claude/agents/node-dev.md

Refactoring task: Consolidate user authentication logic
Target: src/auth/*, src/middleware/auth.js, src/routes/users.js
Repository: tuvens-api

## Current Problems
1. Auth logic scattered across multiple files
2. Inconsistent error handling
3. Repeated JWT verification code

## Desired Outcome
- Single AuthService with clear interface
- Consistent error responses
- Reusable auth middleware

## Constraints
- Maintain existing API contracts
- Keep all auth tests passing
- No breaking changes for clients

Begin by analyzing the current auth implementation and identifying all touchpoints.
```