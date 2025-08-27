# Natural Language Agent Handoff Recognition

**Pattern Recognition Guide for Claude Desktop**

## 📋 Important Context

**Claude Desktop vs Claude Code Workflows:**
- **Claude Code**: Has a built-in `/start-session` slash command
- **Claude Desktop**: Uses iTerm2 MCP to execute `./agentic-development/scripts/setup-agent-task-desktop.sh`

This guide helps Claude Desktop recognize when users want to trigger agent automation via natural language.

## 🎯 Intent Recognition Patterns

### Primary Trigger Phrases
Look for these patterns in user messages:

**Direct Handoff Requests:**
- `"get [agent] to work on this"`
- `"have [agent] handle this"`  
- `"ask [agent] to do this"`
- `"let [agent] work on this"`

**Claude Code Specific:**
- `"use Claude Code with [agent]"`
- `"get Claude Code working on this with [agent]"`
- `"set up Claude Code with [agent]"`
- `"launch Claude Code with [agent]"`

**Task Assignment:**
- `"give this to [agent]"`
- `"assign this to [agent]"`
- `"[agent] should handle this"`
- `"let's have [agent] take care of this"`

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

**qa:**
- "qa", "QA", "quality assurance"
- "code review", "testing", "quality control"

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

## 🎭 Example Recognition Flows

### Example 1: Clear Intent
**User:** "Get vibe-coder to work on this documentation issue in Claude Code"

**Recognition:**
- Intent: ✅ Agent handoff request
- Agent: ✅ vibe-coder  
- Context: ✅ "documentation issue"
- Action: ✅ Trigger automation

### Example 2: Needs Clarification
**User:** "Have someone fix this in Claude Code"

**Recognition:**
- Intent: ✅ Agent handoff request
- Agent: ❓ Unclear
- Context: ✅ "fix this" (needs context extraction)
- Action: ✅ Ask for agent clarification

### Example 3: Context Reference
**User:** "Let's get the react dev to handle that UI bug we were discussing"

**Recognition:**
- Intent: ✅ Agent handoff request
- Agent: ✅ react-dev
- Context: ✅ "UI bug" + reference to previous discussion
- Action: ✅ Extract context from recent messages

## 🚀 Automation Trigger

Once intent is confirmed, trigger the automation:
```bash
open_terminal name="[agent]-session"
execute_command terminal="[agent]-session" command="cd ~/Code/Tuvens/tuvens-docs && ./agentic-development/scripts/setup-agent-task-desktop.sh [agent] \"[task-title]\" \"[context-description]\""
```

**Note**: This uses the Claude Desktop setup script, not Claude Code's built-in `/start-session` command.

## 🔄 Fallback Behavior

If pattern recognition fails:
1. **Don't trigger automation**
2. **Continue normal conversation**
3. **Let user use explicit `/start-session` if needed**

The goal is to be helpful without being intrusive - only trigger when confidence is high.