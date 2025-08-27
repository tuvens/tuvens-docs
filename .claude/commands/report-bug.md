---
allowed-tools: Bash, Read
description: Report a bug in another repository that affects integration or functionality
argument-hint: [repository] [bug_description]
---

# Report Cross-Repository Bug

## Purpose
Report a bug in another repository that affects the current project's integration or functionality.

## Usage
```
/report-bug <repository> <bug_description>
```

## Process

1. First, identify the target repository from our project registry:
   - Check `docs/.claude/INTEGRATION_REGISTRY.md` for the complete list of ecosystem repositories
   - Ensure the bug is actually in the external repository, not local code

2. Gather bug information:
   - Error messages or unexpected behavior
   - Steps to reproduce
   - Expected vs actual behavior
   - Any relevant code snippets or logs

3. Create the bug report issue:

```bash
gh issue create --repo <OWNER/REPO> --title "[BUG] <Brief Description>" --body "$(cat <<'EOF'
## Issue Type
[X] Bug Report

## Requesting Repository
**Repo:** {CURRENT_REPOSITORY}
**Branch/Commit:** $(git rev-parse --abbrev-ref HEAD) / $(git rev-parse --short HEAD)

## Description
<Clear description of the bug>

## Steps to Reproduce
1. <Step 1>
2. <Step 2>
3. <Step 3>

## Expected Behavior
<What should happen>

## Actual Behavior
<What actually happens>

## Error Messages/Logs
```
<Any error messages or relevant logs>
```

## Context
<How this bug affects our integration/work>

## Technical Details
- Environment: <relevant environment details>
- Version: <version information if applicable>
- Related code: <code snippets if helpful>

## Priority
[ ] Blocking - Cannot continue without fix
[X] High - Significantly impacts functionality
[ ] Medium - Workaround available
[ ] Low - Minor issue

## Possible Solution
<If you have ideas about the cause or fix>

---
*Created by Claude Code session in {CURRENT_REPOSITORY}*
EOF
)"
```

4. After creating the issue:
   - Note the issue URL
   - Add a reference in any related local issues/PRs
   - Inform the user about the created issue

5. Track the issue:
   ```bash
   # Check status
   gh issue view <ISSUE_NUMBER> --repo <OWNER/REPO>
   
   # Add updates if needed
   gh issue comment <ISSUE_NUMBER> --repo <OWNER/REPO> --body "Additional information..."
   ```

## Example
```
/report-bug backend-api "Authentication endpoint returns 500 error when using valid JWT tokens"
```

## Notes
- Always verify the bug is in the external system before reporting
- Include enough detail for the other team to reproduce the issue
- Follow up if you discover additional information
- Be responsive to questions from the other repository's maintainers