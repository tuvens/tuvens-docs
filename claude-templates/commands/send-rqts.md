# Send Requirements Request

## Purpose
Request features, changes, or capabilities from another repository that are needed for current development work.

## Usage
```
/send-rqts <repository> <requirements_description>
```

## Process

1. Identify the requirements:
   - What specific functionality is needed
   - Why it's needed for current work
   - Any technical specifications or constraints
   - Timeline/urgency

2. Check existing issues first:
   ```bash
   gh issue list --repo <OWNER/REPO> --search "<keywords>"
   ```

3. Create the requirements request:

```bash
gh issue create --repo <OWNER/REPO> --title "[REQUIREMENTS] <Brief Description>" --body "$(cat <<'EOF'
## Issue Type
[X] Requirements Request

## Requesting Repository
**Repo:** {CURRENT_REPOSITORY}
**Branch/Commit:** $(git rev-parse --abbrev-ref HEAD) / $(git rev-parse --short HEAD)

## Description
<Clear description of what is needed>

## Requirements Details

### Functional Requirements
- <Requirement 1>
- <Requirement 2>
- <Requirement 3>

### Technical Specifications
- Input: <Expected inputs>
- Output: <Expected outputs>
- API/Interface: <How it should be accessed>

## Use Case
<Explain how this will be used in the requesting project>

## Context
<Why this is needed and what problem it solves>

## Expected Outcome
<What the implementation should enable>

## Priority
[X] Blocking - Cannot continue without this
[ ] High - Needed soon for current work
[ ] Medium - Needed for upcoming work
[ ] Low - Nice to have

## Acceptance Criteria
- [ ] <Criterion 1>
- [ ] <Criterion 2>
- [ ] <Criterion 3>

## Alternative Solutions Considered
<Any workarounds or alternatives that were considered>

## Additional Notes
<Any other relevant information>

---
*Created by Claude Code session in {CURRENT_REPOSITORY}*
EOF
)"
```

4. After creating the issue:
   - Document the dependency in local code/comments
   - Create a tracking issue locally if needed
   - Consider implementing a temporary workaround

5. Follow up:
   ```bash
   # Check progress
   gh issue view <ISSUE_NUMBER> --repo <OWNER/REPO>
   
   # Add clarifications if requested
   gh issue comment <ISSUE_NUMBER> --repo <OWNER/REPO> --body "Clarification: ..."
   ```

## Example
```
/send-rqts backend-api "Need webhook endpoint to receive real-time event updates with filtering by event type and date range"
```

## Best Practices
- Be specific about technical requirements
- Explain the business/user value
- Provide clear acceptance criteria
- Suggest implementation approaches if helpful
- Be open to alternative solutions