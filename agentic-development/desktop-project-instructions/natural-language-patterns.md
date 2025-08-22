# Natural Language Agent Handoff Recognition

**Pattern Recognition Guide for Claude Desktop**

## 🎯 Enhanced Intent Recognition Patterns

### Primary Trigger Phrases
Look for these patterns in user messages:

**Direct /start-session Patterns:**
- `"/start-session [agent]"` (with any format variation)
- `"start session with [agent]"`
- `"begin [agent] session"`
- `"start [agent] work on [task]"`
- `"initiate [agent] session"`
- `"get [agent] started"`

**Natural Language Handoff Requests:**
- `"get [agent] to work on this"`
- `"have [agent] handle this"`  
- `"ask [agent] to do this"`
- `"let [agent] work on this"`
- `"start working with [agent]"`
- `"begin work with [agent]"`

**Claude Code Specific:**
- `"use Claude Code with [agent]"`
- `"get Claude Code working on this with [agent]"`
- `"set up Claude Code with [agent]"`
- `"launch Claude Code with [agent]"`
- `"open Claude Code with [agent]"`
- `"start Claude Code session with [agent]"`

**Task Assignment:**
- `"give this to [agent]"`
- `"assign this to [agent]"`
- `"[agent] should handle this"`
- `"let's have [agent] take care of this"`
- `"hand this off to [agent]"`
- `"transfer this to [agent]"`

**Casual Session Patterns:**
- `"/start-session [agent] [brief description]"`
- `"start [agent] on [task]"`
- `"get [agent] going on [task]"`
- `"kick off [agent] session"`
- `"fire up [agent] for [task]"`

## 👥 Agent Name Recognition

### Canonical Names → Variations
**vibe-coder:**
- "vibe-coder", "vibe coder", "vibecoder"
- "vibe", "system architect", "documentation expert"

**react-dev:**
- "react-dev", "react dev", "react developer"
- "react", "frontend dev", "UI developer"

**laravel-dev:**  
- "laravel-dev", "laravel dev", "laravel developer"
- "laravel", "backend dev", "API developer"

**svelte-dev:**
- "svelte-dev", "svelte dev", "svelte developer"
- "svelte", "frontend", "UI dev"

**node-dev:**
- "node-dev", "node dev", "node developer"  
- "node", "nodejs", "backend", "API dev"

**devops:**
- "devops", "dev ops", "infrastructure"
- "deployment", "CI/CD", "ops"

## 🚀 Flexible /start-session Recognition

### Enhanced Pattern Matching Rules

**Rule 1: Detect ANY /start-session mention**
- Match `/start-session` regardless of what follows
- Extract agent name from the text (first recognized agent name)
- Use conversation context for task description if not explicit

**Rule 2: Context-aware parsing**
- `/start-session [agent]` → Use recent conversation as task context
- `/start-session [agent] [brief-desc]` → Use brief-desc as task title
- `/start-session [agent] "[full-title]" "[description]"` → Use exact format

**Rule 3: Natural language bridge patterns**
- "start session" → Look for agent name in same sentence
- "begin session" → Look for agent name in same sentence  
- "start working" + agent name → Trigger session automation

**Rule 4: Fuzzy agent matching**
- Match partial agent names: "vibe" → "vibe-coder"
- Match role descriptions: "react developer" → "react-dev"
- Match technology names: "laravel" → "laravel-dev"

### Pattern Matching Examples

**Input:** `/start-session vibe-coder`
**Match:** ✅ Direct pattern, use conversation context
**Action:** Trigger with context from recent messages

**Input:** `/start-session react-dev fix button styling`
**Match:** ✅ Brief description format
**Action:** Trigger with task="fix button styling"

**Input:** `"start session with devops for deployment"`
**Match:** ✅ Natural language bridge pattern
**Action:** Trigger with agent="devops", task="deployment"

**Input:** `"let's start working with the laravel developer"`
**Match:** ✅ Natural language + role description
**Action:** Trigger with agent="laravel-dev", extract context

**Input:** `/start-session vibe`
**Match:** ✅ Fuzzy agent matching
**Action:** Trigger with agent="vibe-coder", use context

## 🔍 Context Extraction

### Reference Resolution
When users say "this" or "that", look for:

**Recent Context (last 3-5 messages):**
- Specific issues mentioned
- Code problems discussed
- Features being planned
- Bugs being analyzed

**Current Topic Indicators:**
- File names mentioned
- Error messages shared
- Feature descriptions
- Technical requirements

## 💬 Confirmation Templates

### Standard Confirmation Format
```
I understand you want [AGENT] to work on [TASK].
Should I set up a Claude Code session with:

• Agent: [agent-name]
• Task: [task-title]
• Context: [extracted-context]

Would you like me to proceed? Type 'yes' to continue or 'no' to cancel.
```

### Clarification Templates
**When agent is unclear:**
```
I see you want to use Claude Code, but which agent should I use?
Available agents: vibe-coder, react-dev, laravel-dev, svelte-dev, node-dev, devops
```

**When context is unclear:**
```
I understand you want [AGENT] to work in Claude Code.
Could you clarify what specific task or issue they should focus on?
```

## 🎭 Enhanced Recognition Flow Examples

### Example 1: Direct /start-session Command
**User:** `/start-session vibe-coder "Fix Documentation" "Update API reference docs"`

**Recognition:**
- Pattern: ✅ Exact /start-session format
- Agent: ✅ vibe-coder  
- Task Title: ✅ "Fix Documentation"
- Description: ✅ "Update API reference docs"
- Action: ✅ Trigger automation immediately

### Example 2: Casual /start-session
**User:** `/start-session react-dev fix the mobile menu bug`

**Recognition:**
- Pattern: ✅ Casual /start-session format
- Agent: ✅ react-dev
- Task: ✅ "fix the mobile menu bug" (extracted as both title and description)
- Action: ✅ Trigger automation with task="fix the mobile menu bug"

### Example 3: Natural Language Session Start
**User:** "start session with devops for deployment"

**Recognition:**
- Pattern: ✅ Natural language bridge pattern
- Agent: ✅ devops
- Context: ✅ "deployment"
- Action: ✅ Trigger automation with task="deployment"

### Example 4: Fuzzy Agent Matching
**User:** `/start-session vibe`

**Recognition:**
- Pattern: ✅ /start-session with fuzzy agent name
- Agent: ✅ vibe-coder (fuzzy match from "vibe")
- Context: ❓ Extract from recent conversation
- Action: ✅ Trigger with conversation context

### Example 5: Natural Language Handoff
**User:** "Get vibe-coder to work on this documentation issue in Claude Code"

**Recognition:**
- Pattern: ✅ Natural language handoff request
- Agent: ✅ vibe-coder  
- Context: ✅ "documentation issue"
- Action: ✅ Trigger automation

### Example 6: Needs Clarification
**User:** "Have someone fix this in Claude Code"

**Recognition:**
- Pattern: ✅ Agent handoff request
- Agent: ❓ Unclear
- Context: ✅ "fix this" (needs context extraction)
- Action: ✅ Ask for agent clarification

### Example 7: Context Reference
**User:** "Let's get the react dev to handle that UI bug we were discussing"

**Recognition:**
- Pattern: ✅ Natural language handoff
- Agent: ✅ react-dev
- Context: ✅ "UI bug" + reference to previous discussion
- Action: ✅ Extract context from recent messages

### Example 8: Technology-based Agent Match
**User:** "start working with laravel on the API endpoints"

**Recognition:**
- Pattern: ✅ "start working with" + technology name
- Agent: ✅ laravel-dev (matched from "laravel")
- Context: ✅ "API endpoints"
- Action: ✅ Trigger automation

## 🚀 Automation Trigger

Once intent is confirmed, trigger the automation:
```bash
open_terminal name="[agent]-session"
execute_command terminal="[agent]-session" command="cd ~/Code/Tuvens/tuvens-docs && ./start-session [agent] \"[task-title]\" \"[context-description]\""
```

## 🔄 Fallback Behavior

If pattern recognition fails:
1. **Don't trigger automation**
2. **Continue normal conversation**
3. **Let user use explicit `/start-session` if needed**

The goal is to be helpful without being intrusive - only trigger when confidence is high.