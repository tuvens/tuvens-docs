# Ask Cross-Repository Question

## Purpose
Ask questions about another repository's implementation, API, behavior, or architecture when clarification is needed for integration work.

## Usage
```
/ask-question <repository> <question>
```

## Process

1. Before asking:
   - Check the repository's documentation
   - Search existing issues for similar questions
   - Try to be specific about what you need to know

2. Search for existing answers:
   ```bash
   gh issue list --repo <OWNER/REPO> --search "<keywords>" --state all
   ```

3. Create the question issue:

```bash
gh issue create --repo <OWNER/REPO> --title "[QUESTION] <Brief Question>" --body "$(cat <<'EOF'
## Issue Type
[X] Question

## Requesting Repository
**Repo:** {CURRENT_REPOSITORY}
**Branch/Commit:** $(git rev-parse --abbrev-ref HEAD) / $(git rev-parse --short HEAD)

## Question
<Clear, specific question>

## Context
<Why you need this information and what you're trying to achieve>

## What I've Tried
- <Documentation checked>
- <Code examined>
- <Assumptions made>

## Specific Information Needed
- <Specific detail 1>
- <Specific detail 2>
- <Specific detail 3>

## Code Reference
```
<Any relevant code snippets or examples>
```

## Expected Answer Format
<What kind of answer would be most helpful - examples, documentation links, code samples, etc.>

## Priority
[ ] Blocking - Cannot continue without answer
[X] High - Needed to make design decisions
[ ] Medium - Would improve implementation
[ ] Low - General curiosity

## Additional Notes
<Any other context that might help answer the question>

---
*Created by Claude Code session in {CURRENT_REPOSITORY}*
EOF
)"
```

4. After creating the question:
   - Continue with other work if not blocking
   - Document assumptions if proceeding without answer
   - Check back for responses periodically

5. When answered:
   ```bash
   # Thank the responder
   gh issue comment <ISSUE_NUMBER> --repo <OWNER/REPO> --body "Thank you! This clarifies..."
   
   # Close if answered
   gh issue close <ISSUE_NUMBER> --repo <OWNER/REPO> --comment "Question answered. <Summary of answer for future reference>"
   ```

## Example
```
/ask-question backend-api "How does the event filtering API handle date ranges across different timezones?"
```

## Good Questions Include
- Specific technical details
- Context about why you need to know
- What you've already tried/researched
- How the answer will be used
- Examples of the confusion/uncertainty

## Tips
- One question per issue (avoid question lists)
- Include code examples when relevant
- Be respectful of the other team's time
- Close the issue once answered
- Document the answer in your code/comments