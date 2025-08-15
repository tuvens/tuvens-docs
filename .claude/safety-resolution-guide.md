# 🛡️ Safety Check Resolution Guide

## Quick Resolution for Blocked Commits

When the safety check blocks your commit, follow these steps:

### 1. Understand the Detection

The safety system flagged content containing words like:
- `password`, `secret`, `token`, `key`, `api_key`

**Check the detailed findings** for exact file and line numbers.

### 2. Determine if it's a False Positive

#### ✅ Likely Safe (Documentation Examples):
- Markdown files with code examples
- Lines containing `localStorage.getItem`, `placeholder`, `example`
- API documentation with sample tokens
- TypeScript interfaces or type definitions

#### ⚠️ Potentially Dangerous:
- Long random strings (>20 characters)
- Environment variable assignments with real values
- Configuration files with actual credentials
- Any string that looks like a real API key/password

### 3. Resolution Options

#### Option 1: Verify and Proceed (Documentation)
```bash
# Review the flagged content first
git diff --cached

# If it's legitimate documentation/examples:
git commit --allow-empty -m "docs: verified examples only"
git reset --soft HEAD~1
git commit -m "your actual commit message"
```

#### Option 2: Request Review
```bash
# For uncertain cases, request orchestrator review:
git commit -m "review-requested: added API integration examples"
```

#### Option 3: Emergency Bypass (Use Sparingly)
```bash
# Only for urgent legitimate changes:
git commit --no-verify -m "[SAFETY-OVERRIDE: documentation examples] your message"
```

### 4. Best Practices Moving Forward

#### For Documentation:
- Use obvious placeholders: `YOUR_API_KEY`, `example_token`
- Mark code blocks clearly with triple backticks
- Include "example" or "placeholder" in variable names

#### For Real Secrets:
- Use environment variables: `process.env.API_KEY`
- Use placeholder comments: `// Set via environment variable`
- Never commit actual credentials

### 5. Need Help?

- **Immediate questions**: Create GitHub issue with `safety-check` label
- **System improvements**: Contact devops agent
- **Emergency escalation**: Use `--no-verify` with detailed reasoning

### 6. Common Patterns That Trigger Checks

#### Safe Examples:
```typescript
// ✅ These won't trigger false positives:
const token = localStorage.getItem('auth_token');
const API_KEY = 'your_api_key_here';  // placeholder
process.env.SECRET_KEY  // environment reference
```

#### Problematic Examples:
```typescript
// ❌ These will be flagged:
const secret = "sk-1234567890abcdef1234567890abcdef";
export const API_KEY = "prod_abc123xyz789";
```

---

**Last Updated**: 2025-01-15  
**Maintained By**: DevOps Agent