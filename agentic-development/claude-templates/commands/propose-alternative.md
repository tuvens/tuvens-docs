# Propose Alternative Approach

## Purpose
Suggest alternative architectural or implementation approaches for cross-repository integration when current approaches have limitations or challenges.

## Usage
```
/propose-alternative <repository> <alternative_approach_description>
```

## Process

1. Document the current challenge:
   - What's not working well
   - Technical or architectural constraints
   - Integration pain points

2. Research the current implementation:
   ```bash
   # Review related issues and PRs
   gh issue list --repo <OWNER/REPO> --search "<current approach keywords>"
   gh pr list --repo <OWNER/REPO> --search "<related keywords>"
   ```

3. Create the alternative proposal:

```bash
gh issue create --repo <OWNER/REPO> --title "[ALTERNATIVE] <Brief Description>" --body "$(cat <<'EOF'
## Issue Type
[X] Alternative Approach

## Requesting Repository
**Repo:** {CURRENT_REPOSITORY}
**Branch/Commit:** $(git rev-parse --abbrev-ref HEAD) / $(git rev-parse --short HEAD)

## Current Approach
<Description of how things currently work>

### Current Challenges
- <Challenge 1>
- <Challenge 2>
- <Challenge 3>

## Proposed Alternative
<Detailed description of the alternative approach>

### How It Works
1. <Step 1>
2. <Step 2>
3. <Step 3>

### Architecture Diagram
```
<ASCII diagram or description of architecture>
```

## Comparison

| Aspect | Current Approach | Alternative Approach |
|--------|-----------------|---------------------|
| Performance | <comparison> | <comparison> |
| Complexity | <comparison> | <comparison> |
| Maintainability | <comparison> | <comparison> |
| Scalability | <comparison> | <comparison> |
| Integration Effort | <comparison> | <comparison> |

## Benefits
- <Benefit 1>
- <Benefit 2>
- <Benefit 3>

## Trade-offs
- <Trade-off 1>
- <Trade-off 2>
- <Trade-off 3>

## Implementation Strategy
### Phase 1: <Initial steps>
### Phase 2: <Migration steps>
### Phase 3: <Completion steps>

## Proof of Concept
```
<Code example or prototype if available>
```

## Risk Assessment
- **Technical Risks**: <risks and mitigations>
- **Timeline Impact**: <estimated impact>
- **Resource Requirements**: <what's needed>

## Priority
[X] High - Current approach has significant issues
[ ] Medium - Would improve system notably
[ ] Low - Long-term consideration

## Open Questions
- <Question 1>
- <Question 2>

---
*Created by Claude Code session in {CURRENT_REPOSITORY}*
EOF
)"
```

4. After creating the proposal:
   - Be prepared to discuss trade-offs
   - Provide additional details if requested
   - Consider creating a proof of concept

5. Facilitate discussion:
   ```bash
   # Add clarifications
   gh issue comment <ISSUE_NUMBER> --repo <OWNER/REPO> --body "Additional thoughts on implementation..."
   
   # Share prototype/POC
   gh issue comment <ISSUE_NUMBER> --repo <OWNER/REPO> --body "I've created a small POC: <link or code>"
   ```

## Example
```
/propose-alternative backend-api "Replace REST polling with WebSocket connections for real-time event updates to reduce latency and server load"
```

## Strong Proposals Include
- Clear problem definition
- Comprehensive alternative solution
- Honest trade-off analysis
- Migration strategy
- Risk assessment
- Potential proof of concept

## Guidelines
- Be objective about pros and cons
- Consider all stakeholders
- Propose realistic timelines
- Be flexible and open to hybrid approaches
- Focus on solving real problems