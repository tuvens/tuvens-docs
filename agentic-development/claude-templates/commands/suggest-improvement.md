# Suggest Cross-Repository Improvement

## Purpose
Propose improvements, optimizations, or enhancements to another repository that would benefit integration or overall system quality.

## Usage
```
/suggest-improvement <repository> <improvement_description>
```

## Process

1. Validate the suggestion:
   - Ensure it's genuinely beneficial
   - Consider if it aligns with the other project's goals
   - Check if similar suggestions already exist

2. Research existing discussions:
   ```bash
   gh issue list --repo <OWNER/REPO> --label "enhancement" --search "<keywords>"
   ```

3. Create the improvement suggestion:

```bash
gh issue create --repo <OWNER/REPO> --title "[SUGGESTION] <Brief Description>" --body "$(cat <<'EOF'
## Issue Type
[X] Suggestion/Improvement

## Requesting Repository
**Repo:** {CURRENT_REPOSITORY}
**Branch/Commit:** $(git rev-parse --abbrev-ref HEAD) / $(git rev-parse --short HEAD)

## Description
<Clear description of the suggested improvement>

## Current Situation
<How things work now and any pain points>

## Proposed Improvement
<Detailed description of the suggested change>

## Benefits
- **Performance**: <Performance improvements if any>
- **Usability**: <Developer experience improvements>
- **Maintainability**: <Code quality improvements>
- **Integration**: <How it improves cross-repo work>

## Implementation Approach
<High-level implementation suggestions if you have ideas>

## Example
```
// Current approach
<current code/API example>

// Suggested approach
<improved code/API example>
```

## Impact Analysis
- **Breaking Changes**: <Yes/No and details>
- **Migration Path**: <How to transition if needed>
- **Effort Estimate**: <Rough estimate if possible>

## Priority
[ ] High - Significant benefit
[X] Medium - Notable improvement
[ ] Low - Nice to have

## Alternatives Considered
<Other approaches that might work>

## Additional Context
<Any other relevant information, benchmarks, references>

---
*Created by Claude Code session in {CURRENT_REPOSITORY}*
EOF
)"
```

4. After creating the suggestion:
   - Be open to feedback and discussion
   - Offer to help with implementation if appropriate
   - Respect if the suggestion is declined

5. Engage in discussion:
   ```bash
   # Respond to questions
   gh issue comment <ISSUE_NUMBER> --repo <OWNER/REPO> --body "To clarify..."
   
   # Offer assistance
   gh issue comment <ISSUE_NUMBER> --repo <OWNER/REPO> --body "I'd be happy to help implement this if you're interested"
   ```

## Example
```
/suggest-improvement backend-api "Add response caching for frequently accessed event data to reduce database load and improve response times"
```

## Good Suggestions Include
- Clear problem statement
- Specific benefits
- Implementation ideas (but not prescriptive)
- Impact on existing functionality
- Consideration of trade-offs

## Etiquette
- Be respectful and constructive
- Focus on mutual benefits
- Acknowledge the other team's expertise
- Don't be pushy if declined
- Offer help if suggestion is accepted