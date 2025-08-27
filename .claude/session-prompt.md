# DEVOPS AGENT - SAFETY CHECK CLARITY IMPROVEMENTS

## 🎯 IMMEDIATE CONTEXT
You are the **devops agent** tasked with improving the safety check system to provide clearer feedback and proper escalation protocols when legitimate documentation is blocked.

## 🔍 PROBLEM DETAILS
**Current Issue**: Safety checks block commits containing words like 'key', 'api', 'token' even in documentation
**Impact**: Agents waste time investigating and bypassing legitimate blocks
**Example**: Phase 2 and Phase 3 PRs were blocked due to example API keys in documentation

## 📋 IMMEDIATE ACTIONS REQUIRED

### 1. Analyze Current Safety Check Implementation
- [ ] Review `scripts/hooks/check-safety-rules.sh`
- [ ] Identify current detection patterns
- [ ] Document false positive scenarios

### 2. Enhance Error Messages
Create clear, actionable error messages that include:
- [ ] Specific file and line number of flagged content
- [ ] Type of potential security issue detected
- [ ] Suggested resolution steps
- [ ] Escalation options

### 3. Implement Context-Aware Detection
- [ ] Differentiate between documentation and code files
- [ ] Recognize common documentation patterns (examples, placeholders)
- [ ] Allow markdown code blocks with obvious example content

### 4. Create Escalation Protocol
- [ ] Automated orchestrator notification system
- [ ] Secure temporary bypass with logging
- [ ] Review request workflow

### 5. Test and Document
- [ ] Test with common false positive scenarios
- [ ] Create agent guidance documentation
- [ ] Update safety protocols

## 🎯 EXAMPLE IMPROVEMENTS

**Current Error**:
```
❌ SAFETY RULE VIOLATIONS DETECTED
Potential secrets detected in: file.md
```

**Improved Error**:
```
❌ SAFETY CHECK: Potential Secret Detected

FILE: agentic-development/protocols/emergency-response-procedures.md
LINE: 247 - Contains "API_KEY" 
TYPE: Documentation Example (markdown code block)

ASSESSMENT: Likely documentation example, not actual secret

RESOLUTION OPTIONS:
1. If this is documentation/example: Run with --verify-docs flag
2. Request orchestrator review: git commit --orchestrator-review
3. Emergency bypass (logged): git commit --safety-override="reason"

HELP: See .claude/safety-resolution-guide.md for details
```

## 🚀 START HERE
1. **Review current safety hook**: `cat scripts/hooks/check-safety-rules.sh`
2. **Identify improvement areas**: Focus on clarity and context awareness
3. **Implement enhancements**: Better detection, clearer messages, escalation paths
4. **Test thoroughly**: Ensure security isn't compromised

**Remember**: The goal is to make safety checks helpful, not frustrating, while maintaining security.
