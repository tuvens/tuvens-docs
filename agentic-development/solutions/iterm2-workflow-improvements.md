# iTerm2 Workflow Improvements: Agent Visibility & Status Tracking

## 🎯 Problems Identified

1. **Window Identification**: All iTerm2 windows show "Vibe Coder #1" instead of proper agent names and issue numbers
2. **Status Visibility**: No way to see current status of issues/PRs and whether agents are waiting for instructions

## 💡 Solutions

### 1. Enhanced Window Titles with Status

**Current Issue**: `setup-agent-task.sh` sets window titles correctly, but they may not be displaying properly.

**Enhanced Window Title Format**:
```
[Agent] #[Issue] - [Status] | [Files Changed] | [Last Update]
```

**Examples**:
- `devops #145 - ACTIVE | 3 files | 2h ago`
- `qa #123 - WAITING | review pending | 1d ago` 
- `react-dev #167 - BLOCKED | merge conflict | 5h ago`

### 2. iTerm2 Badge Integration 

iTerm2 supports badges that can display real-time information. We can use this for:

**Status Badge Format**:
```
🟢 ACTIVE    - Agent is working
🟡 WAITING   - Agent needs instructions  
🔴 BLOCKED   - Agent has impediments
⚫ REVIEWING - PR submitted for review
✅ COMPLETE  - Work finished
```

### 3. GitHub Labels → iTerm2 Status Mapping

**GitHub Label System**:
```
Status Labels:
- status/active     → 🟢 ACTIVE
- status/waiting    → 🟡 WAITING  
- status/blocked    → 🔴 BLOCKED
- status/reviewing  → ⚫ REVIEWING
- status/complete   → ✅ COMPLETE

Agent Labels:
- agent/vibe-coder
- agent/devops  
- agent/qa
- agent/react-dev
- (etc.)

Priority Labels:  
- priority/high
- priority/medium
- priority/low
```

### 4. Automatic Status Updates

**Trigger Points**:
- Issue creation → `status/active`
- Agent comment with "BLOCKED:" → `status/blocked`  
- Agent comment with "WAITING:" → `status/waiting`
- PR creation → `status/reviewing`
- PR merge → `status/complete`
- Issue close → remove status labels

## 🔧 Implementation Plan

### Phase 1: Fix Basic Window Titles

**Script Enhancement**: `setup-agent-task.sh`
```bash
# Enhanced AppleScript with status checking
APPLESCRIPT_CONTENT="
tell application \"iTerm\"
    create window with default profile
    tell current session of current window
        # Dynamic title with status
        set name to \"$AGENT_NAME #$GITHUB_ISSUE - ACTIVE\"
        
        # Set badge with GitHub status
        write text \"printf '\\e]1337;SetBadgeFormat=%s\\a' \\\"🟢 ACTIVE\\\"\"
        
        write text \"cd \\\"$WORKTREE_PATH\\\"\"
        write text \"cat \\\"$PROMPT_FILE\\\"\"
        write text \"$CLAUDE_COMMAND\"
    end tell
end tell"
```

### Phase 2: Real-time Status Sync

**Status Sync Script**: `sync-window-status.sh`
```bash
#!/bin/bash
# Poll GitHub for issue/PR status and update iTerm2 windows

while true; do
    # Get all active iTerm2 windows with agent pattern
    # Query GitHub for issue status
    # Update window titles and badges
    # Sleep for 60 seconds
done
```

**Usage**:
```bash
# Run in background to keep windows synced
nohup ./agentic-development/scripts/sync-window-status.sh &
```

### Phase 3: Enhanced Badge System

**Badge Information Display**:
- Current status icon
- Files changed count
- Time since last update
- PR status if exists

**Badge Update Commands**:
```bash
# Set active status
printf '\e]1337;SetBadgeFormat=%s\a' "🟢 ACTIVE"

# Set waiting status with context
printf '\e]1337;SetBadgeFormat=%s\a' "🟡 WAITING\nNeeds review"

# Set blocked status 
printf '\e]1337;SetBadgeFormat=%s\a' "🔴 BLOCKED\nMerge conflict"
```

## 🚀 Quick Implementation

### 1. Immediate Fix for Window Titles

**Check iTerm2 Title Behavior**:
```bash
# Test if AppleScript is working
osascript -e 'tell application "iTerm2"
    tell current session of current window
        set name to "TEST WINDOW - vibe-coder #999"
    end tell
end tell'
```

**Manual Title Update**:
```bash
# In any terminal, update the title
echo -e "\033]0;devops #145 - ACTIVE\007"
```

### 2. GitHub Label Automation

**Label Creation Script**:
```bash
# Create status labels
gh label create "status/active" --color "28a745" --description "Agent actively working"
gh label create "status/waiting" --color "ffc107" --description "Agent waiting for input" 
gh label create "status/blocked" --color "dc3545" --description "Agent blocked by impediments"
gh label create "status/reviewing" --color "6f42c1" --description "PR submitted for review"
gh label create "status/complete" --color "28a745" --description "Work completed"
```

**Auto-Label on Issue Creation**:
```bash
# In setup-agent-task.sh, add labels to issue creation
gh issue create \
  --title "$TASK_TITLE" \
  --body "$issue_body" \
  --label "agent-task,agent/$AGENT_NAME,status/active,priority/medium"
```

### 3. Status Checking Command

**Quick Status Check**:
```bash
# Check status of all active agent issues
gh issue list --label "agent-task" --json number,title,labels,assignees,updatedAt \
  --jq '.[] | "\(.number): \(.title) [\(.labels[].name | select(startswith("status/")))]"'
```

## 🔍 Troubleshooting Current Issues

### Why "Vibe Coder #1" Appears

**Possible Causes**:
1. **Script not reaching AppleScript section**: Check if `SKIP_ITERM_AUTOMATION` is set
2. **iTerm2 preferences override**: iTerm2 might reset titles automatically
3. **Multiple sessions interference**: Old sessions might be reusing window numbers

**Debug Steps**:
```bash
# Check if AppleScript is executing
echo "SKIP_ITERM_AUTOMATION: ${SKIP_ITERM_AUTOMATION:-not_set}"

# Test AppleScript directly
osascript -e 'tell application "iTerm2" to get name of current session of current window'
```

### iTerm2 Configuration

**Check iTerm2 Settings**:
1. `Preferences > Profiles > [Profile] > Terminal`
2. Uncheck "Show mark indicators" if interfering
3. Check "Terminal may set tab/window title" is enabled

## 📊 Expected Outcomes

### Before Implementation
```
iTerm2 Windows:
- Vibe Coder #1
- Vibe Coder #1  
- Vibe Coder #1
- Vibe Coder #1
```

### After Implementation  
```
iTerm2 Windows:
- devops #145 - 🟢 ACTIVE | 3 files | 2h ago
- qa #123 - 🟡 WAITING | review pending | 1d ago
- react-dev #167 - 🔴 BLOCKED | merge conflict | 5h ago  
- vibe-coder #384 - ⚫ REVIEWING | PR #892 | 30m ago
```

## 🎯 Next Steps

1. **Fix immediate window title issue** with enhanced AppleScript
2. **Implement GitHub label system** for status tracking
3. **Create status sync background process** for real-time updates
4. **Test badge system** for additional visual indicators
5. **Document workflow** for agent status management

This solution provides both immediate fixes and long-term workflow improvements for better agent coordination visibility.