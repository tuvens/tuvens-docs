# /start-session Pattern Recognition Testing Guide

**Enhanced Pattern Matching Test Cases for Claude Desktop**

## 🧪 Test Categories

### Category 1: Direct /start-session Commands

**Test Case 1.1: Exact Format**
```
Input: /start-session vibe-coder "Fix Documentation" "Update API reference docs"
Expected: ✅ Immediate trigger, exact parameters
Agent: vibe-coder
Task: Fix Documentation  
Description: Update API reference docs
```

**Test Case 1.2: Casual Format**
```
Input: /start-session react-dev fix the mobile menu bug
Expected: ✅ Trigger with task extraction
Agent: react-dev
Task: fix the mobile menu bug
Description: fix the mobile menu bug
```

**Test Case 1.3: Agent Only**
```
Input: /start-session devops
Expected: ✅ Trigger with context from conversation
Agent: devops
Task: [Extract from recent messages]
Description: [Extract from recent messages]
```

**Test Case 1.4: Fuzzy Agent Names**
```
Input: /start-session vibe
Expected: ✅ Fuzzy match to vibe-coder
Agent: vibe-coder
Task: [Extract from context]
```

### Category 2: Natural Language Session Patterns

**Test Case 2.1: Start Session Phrase**
```
Input: "start session with devops for deployment"
Expected: ✅ Natural language bridge pattern
Agent: devops
Task: deployment
```

**Test Case 2.2: Begin Session**
```
Input: "begin react-dev session to fix the UI"
Expected: ✅ Begin session pattern
Agent: react-dev
Task: fix the UI
```

**Test Case 2.3: Start Working**
```
Input: "start working with laravel-dev on API endpoints"
Expected: ✅ Start working pattern
Agent: laravel-dev
Task: API endpoints
```

**Test Case 2.4: Get Agent Started**
```
Input: "get vibe-coder started on documentation"
Expected: ✅ Get started pattern
Agent: vibe-coder
Task: documentation
```

### Category 3: Traditional Handoff Patterns

**Test Case 3.1: Get Agent To Work**
```
Input: "Get vibe-coder to work on this documentation issue in Claude Code"
Expected: ✅ Traditional handoff pattern
Agent: vibe-coder
Task: documentation issue
```

**Test Case 3.2: Have Agent Handle**
```
Input: "Have the devops agent handle this deployment issue"
Expected: ✅ Have agent handle pattern
Agent: devops
Task: deployment issue
```

**Test Case 3.3: Use Claude Code With**
```
Input: "Let's use Claude Code with laravel-dev for this database task"
Expected: ✅ Claude Code specific pattern
Agent: laravel-dev
Task: database task
```

### Category 4: Technology-Based Agent Matching

**Test Case 4.1: Technology Name**
```
Input: "start working with laravel on the authentication system"
Expected: ✅ Technology-based match
Agent: laravel-dev (matched from "laravel")
Task: authentication system
```

**Test Case 4.2: Role Description**
```
Input: "get the react developer to fix this component"
Expected: ✅ Role-based match
Agent: react-dev (matched from "react developer")
Task: fix this component
```

**Test Case 4.3: Partial Name**
```
Input: "have devops handle the CI pipeline"
Expected: ✅ Exact agent name match
Agent: devops
Task: CI pipeline
```

### Category 5: Context Extraction Tests

**Test Case 5.1: Conversation Context**
```
Previous Message: "The authentication system is broken on mobile"
Input: "/start-session laravel-dev"
Expected: ✅ Extract context from previous message
Agent: laravel-dev
Task: authentication system broken on mobile
```

**Test Case 5.2: Reference Resolution**
```
Previous Message: "There's a bug in the mobile menu component"
Input: "get react-dev to work on this"
Expected: ✅ Resolve "this" to mobile menu component bug
Agent: react-dev
Task: mobile menu component bug
```

### Category 6: Edge Cases and Clarification

**Test Case 6.1: Unclear Agent**
```
Input: "Have someone fix this in Claude Code"
Expected: ❓ Request agent clarification
Action: Show available agents, ask user to specify
```

**Test Case 6.2: No Context Available**
```
Input: "/start-session vibe-coder"
(No previous conversation)
Expected: ❓ Request task clarification
Action: Ask user to specify what vibe-coder should work on
```

**Test Case 6.3: Ambiguous Agent**
```
Input: "get the developer to work on this"
Expected: ❓ Request agent clarification
Action: Show available agents (react-dev, laravel-dev, etc.)
```

## 🎯 Success Criteria

For each test case, Claude Desktop should:

1. **Pattern Recognition**: ✅ Identify the pattern type correctly
2. **Agent Extraction**: ✅ Extract or fuzzy-match the correct agent
3. **Task Extraction**: ✅ Extract task from explicit text or conversation context
4. **Confirmation**: ✅ Show structured confirmation before triggering
5. **MCP Automation**: ✅ Execute correct iTerm2 MCP commands
6. **Error Handling**: ✅ Request clarification when needed

## 🔄 Fallback Behavior

**If pattern recognition fails:**
1. ❌ **Don't trigger automation**
2. ✅ **Continue normal conversation**
3. ✅ **Let user use explicit `/start-session` if needed**

**Goal**: Be helpful without being intrusive - only trigger when confidence is high.

## 📋 Quick Testing Checklist

- [ ] Direct /start-session commands work
- [ ] Casual /start-session formats work  
- [ ] Natural language session patterns work
- [ ] Fuzzy agent matching works
- [ ] Context extraction from conversation works
- [ ] Traditional handoff patterns still work
- [ ] Technology-based agent matching works
- [ ] Clarification requests work for unclear inputs
- [ ] MCP automation triggers correctly
- [ ] Fallback behavior works for unrecognized patterns

---

*This testing guide validates the enhanced pattern recognition implemented in issue #274*