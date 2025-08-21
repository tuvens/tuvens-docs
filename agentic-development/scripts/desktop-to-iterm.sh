#!/bin/bash
# agentic-development/scripts/desktop-to-iterm.sh
# Bridge script for Claude Desktop to create automated iTerm2 Claude Code sessions

set -e

# Parse arguments
AGENT_NAME="$1"
TASK_DESCRIPTION="${2:-}"
PROJECT_ROOT="$HOME/Code/Tuvens/tuvens-docs"

# Validate agent name
if [[ -z "$AGENT_NAME" ]]; then
    echo "❌ ERROR: Agent name required"
    echo "Usage: $0 <agent-name> [task-description]"
    exit 1
fi

# Validate agent exists
AGENT_FILE="$PROJECT_ROOT/.claude/agents/${AGENT_NAME}.md"
if [[ ! -f "$AGENT_FILE" ]]; then
    echo "❌ ERROR: Agent not found: $AGENT_FILE"
    echo "Available agents:"
    ls -1 "$PROJECT_ROOT/.claude/agents/" | grep -E "\.md$" | sed 's/\.md$//' | sed 's/^/  - /'
    exit 1
fi

echo "🤖 Creating automated iTerm2 session for $AGENT_NAME agent..."
echo "📁 Project: $PROJECT_ROOT"
if [[ -n "$TASK_DESCRIPTION" ]]; then
    echo "📋 Task: $TASK_DESCRIPTION"
fi

# Generate session identifier
SESSION_ID="claude-${AGENT_NAME}-$(date +%s)"
WINDOW_TITLE="🤖 $AGENT_NAME Agent - $(date '+%H:%M')"

# Escape task description for AppleScript
SAFE_TASK=$(echo "$TASK_DESCRIPTION" | sed 's/"/\\"/g' | sed "s/'/\\'/g")

# Create iTerm2 window with enhanced automation
osascript << EOF
tell application "iTerm"
    activate
    create window with default profile
    tell current session of current window
        set name to "$WINDOW_TITLE"
        
        -- Navigate to project directory
        write text "cd \"$PROJECT_ROOT\""
        
        -- Clear and show session info
        write text "clear"
        write text "echo '═══════════════════════════════════════════════════════════'"
        write text "echo '🤖 $AGENT_NAME Agent Session - '\$(date)"
        write text "echo '═══════════════════════════════════════════════════════════'"
        write text "echo 'Project: $PROJECT_ROOT'"
        write text "echo 'Task: $SAFE_TASK'"
        write text "echo ''"
        
        -- Show available options
        write text "echo '🚀 Option 1: Automated Session Creation'"
        write text "echo 'Run: /start-session $AGENT_NAME'"
        write text "echo ''"
        write text "echo '⚡ Option 2: Manual Claude Code with Agent Context'"
        write text "echo 'Run: claude'"
        write text "echo 'Then paste this prompt:'"
        write text "echo ''"
        
        -- Generate and display the manual prompt
        write text "echo '───────────────────────────────────────────────────────────'"
        write text "echo 'Load: .claude/agents/${AGENT_NAME}.md'"
        write text "echo ''"
        write text "echo 'Task: $SAFE_TASK'"
        write text "echo 'Repository: tuvens-docs'"
        write text "echo 'Working Directory: $PROJECT_ROOT'"
        write text "echo ''"
        write text "echo 'Context: Starting agent session from Claude Desktop automation.'"
        write text "echo ''"
        write text "echo 'Start by using /start-session $AGENT_NAME to set up the proper worktree and GitHub issue.'"
        write text "echo '───────────────────────────────────────────────────────────'"
        write text "echo ''"
        
        -- Start Claude Code automatically
        write text "echo '🎯 Starting Claude Code automatically...'"
        write text "echo ''"
        write text "claude"
    end tell
end tell
EOF

echo ""
echo "✅ Created iTerm2 session: $WINDOW_TITLE"
echo "📱 Session ID: $SESSION_ID"
echo ""
echo "Your new iTerm2 window should now be open with:"
echo "  • Claude Code starting automatically"
echo "  • Pre-formatted prompt ready for copy/paste"
echo "  • Option to use /start-session $AGENT_NAME for full automation"
echo ""
echo "Next steps in the new terminal:"
echo "  1. Wait for Claude Code to start"
echo "  2. Use /start-session $AGENT_NAME (recommended)"
echo "  3. Or copy/paste the displayed prompt for manual setup"