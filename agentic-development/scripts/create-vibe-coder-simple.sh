#!/bin/bash

# Simple Vibe Coder Window Creation

osascript <<'END'
tell application "iTerm2"
    create window with default profile
    tell current session of current window
        set name to "🎨 Vibe Coder - Agent Workflows"
        write text "cd /Users/ciarancarroll/code/tuvens/worktrees/tuvens-docs/vibe-coder/feature-agent-workflow-instructions"
        write text "clear"
        write text "cat /Users/ciarancarroll/code/tuvens/tuvens-docs/agentic-development/scripts/vibe-coder-prompt.txt"
    end tell
end tell
END