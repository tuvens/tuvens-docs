# Debugging Handoff Template

## When to Use
- Production issues investigation
- Intermittent bugs
- Performance problems
- Integration failures
- Unexpected behavior

## Claude Desktop Analysis

### 1. Issue Identification
```markdown
Problem: [what's not working]
Environment: [dev/staging/prod]
Frequency: [always/sometimes/rarely]
First noticed: [when]
User impact: [who/how many affected]
```

### 2. Initial Investigation
Gather available information:
- [ ] Error messages/stack traces
- [ ] Log entries
- [ ] User reports
- [ ] Monitoring alerts
- [ ] Recent changes

### 3. Reproduction Steps
```markdown
1. [Step 1]
2. [Step 2]
3. [Step 3]
Expected: [what should happen]
Actual: [what happens instead]
```

## Handoff Methods

### For Active Issues
```bash
/resolve-issue [issue-number]
```

This will:
- Load issue details
- Determine complexity
- Route to appropriate agent/workflow

### Manual Debug Session
```markdown
Load: .claude/agents/[appropriate-agent].md

Debug task: [specific issue]
Repository: [affected repo]
Severity: [critical/high/medium/low]

## Issue Details
- Error: [message/behavior]
- Location: [where it occurs]
- Frequency: [how often]
- Impact: [what breaks]

## Available Information
- Logs: [relevant excerpts]
- Stack trace: [if available]
- User reports: [descriptions]
- Monitoring: [metrics/alerts]

## Investigation Plan
1. Reproduce the issue
2. Add debugging output
3. Isolate the problem
4. Test potential fixes
5. Verify resolution

Begin by attempting to reproduce the issue locally.
```

## Debugging Strategies

### Systematic Approach
```markdown
1. **Reproduce**
   - Set up exact conditions
   - Verify you see same error
   - Document steps clearly

2. **Isolate**
   - Binary search problem area
   - Comment out sections
   - Add logging/breakpoints

3. **Hypothesize**
   - Form theories about cause
   - Test each systematically
   - Rule out possibilities

4. **Fix**
   - Implement minimal fix
   - Test thoroughly
   - Check for side effects
```

### Common Debugging Tools

#### Frontend Debugging
```markdown
- Browser DevTools
- React/Vue/Svelte devtools
- Network inspector
- Console logging
- Source maps
```

#### Backend Debugging
```markdown
- Application logs
- Database query logs
- APM tools (if available)
- Debugger/breakpoints
- Request tracing
```

#### Integration Debugging
```markdown
- API testing tools (Postman/Insomnia)
- Network monitoring
- Service logs
- Correlation IDs
```

## Issue Categories

### Race Conditions
```markdown
Symptoms:
- Works sometimes
- Timing-dependent
- Hard to reproduce

Investigation:
- Add detailed timing logs
- Check async operations
- Review concurrent access
- Test with delays
```

### Memory/Performance
```markdown
Symptoms:
- Gradual degradation
- Crashes after time
- Slow operations

Investigation:
- Memory profiling
- Query analysis
- CPU profiling
- Resource monitoring
```

### Integration Failures
```markdown
Symptoms:
- External service errors
- Data sync issues
- Authentication failures

Investigation:
- Check service status
- Verify credentials
- Test in isolation
- Review recent changes
```

## Debug Information Collection

### What to Gather
```markdown
Essential:
- [ ] Full error message
- [ ] Stack trace
- [ ] Request/response data
- [ ] User actions before error

Helpful:
- [ ] Browser/OS info
- [ ] Time of occurrence
- [ ] Related log entries
- [ ] Database state
```

### What to Document
```markdown
During investigation:
- What you tried
- What worked/didn't work
- Patterns noticed
- Theories tested

For the fix:
- Root cause
- Solution implemented
- Tests added
- Prevention measures
```

## Resolution Template

Once issue is found:

```markdown
## Root Cause
[Clear explanation of why it happened]

## Fix Applied
[What was changed and why]

## Testing
- [ ] Issue no longer reproduces
- [ ] No regressions introduced
- [ ] Edge cases handled
- [ ] Tests added to prevent recurrence

## Prevention
[How to avoid similar issues in future]
```

## Example Debug Session

```markdown
Load: .claude/agents/node-dev.md

Debug task: Users getting 500 error on profile update
Repository: tuvens-api
Severity: high

## Issue Details
- Error: "Internal Server Error" on PUT /api/users/profile
- Location: Profile settings page
- Frequency: ~30% of attempts
- Impact: Users cannot update profiles

## Available Information
- Logs: "TypeError: Cannot read property 'id' of undefined"
- Stack trace: Points to src/services/UserService.js:147
- User reports: "Happens when updating email"
- Monitoring: Spike in 500 errors starting 2 hours ago

## Investigation Plan
1. Check recent deployments/changes
2. Examine UserService.js around line 147
3. Test profile update with various inputs
4. Add detailed logging to trace issue
5. Identify pattern in failing requests

Begin by checking what changed in the last 2 hours and examining the error location.
```

## Red Flags

Escalate if:
- Data corruption risk
- Security implications
- Widespread user impact
- Cannot reproduce locally
- Root cause unclear after investigation