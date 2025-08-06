# /start-session Command Integration Guide

## Overview

The `/start-session` command orchestrates multi-agent development by:
1. Analyzing the current task context
2. Creating appropriate worktrees
3. Setting up Claude Code sessions with proper context
4. Maintaining awareness of repository locations

## Repository Structure

### Expected Local Structure
```
~/Code/Tuvens/
├── tuvens-docs/           # Main documentation repo
├── tuvens-client/         # Svelte frontend
│   ├── tuvens-docs/       # Local copy (gitignored)
│   └── worktrees/         # Git worktrees
│       └── feature-xyz/   # Maps to branch: feature-xyz
├── tuvens-api/            # Node.js backend
│   ├── tuvens-docs/       # Local copy (gitignored)
│   └── worktrees/
├── hi.events/             # Laravel/React
│   ├── tuvens-docs/       # Local copy (gitignored)
│   └── worktrees/
└── eventsdigest-ai/       # Svelte 5 frontend
    ├── tuvens-docs/       # Local copy (gitignored)
    └── worktrees/
```

### Local tuvens-docs Integration

Each project should have tuvens-docs available locally:

```bash
# In each project root (e.g., tuvens-client/)
# Option 1: Symlink (recommended for development)
ln -s ../tuvens-docs tuvens-docs

# Option 2: Copy (if symlinks problematic)
cp -r ../tuvens-docs ./tuvens-docs
```

Add to `.gitignore`:
```gitignore
# Shared documentation (local only)
/tuvens-docs
```

## Repository Awareness

### Environment Configuration

The `/start-session` command needs to know where repositories are located. This can be handled through:

#### Option 1: Environment Variables (Recommended)
```bash
# In ~/.zshrc or ~/.bashrc
export TUVENS_ROOT="$HOME/Code/Tuvens"
export TUVENS_REPOS="tuvens-client,tuvens-api,hi.events,eventsdigest-ai,tuvens-docs"
```

#### Option 2: Configuration File
Create `~/.tuvens/config.json`:
```json
{
  "root": "/Users/[username]/Code/Tuvens",
  "repositories": {
    "tuvens-client": {
      "path": "tuvens-client",
      "agent": "svelte-dev",
      "type": "frontend"
    },
    "tuvens-api": {
      "path": "tuvens-api",
      "agent": "node-dev",
      "type": "backend"
    },
    "hi.events": {
      "path": "hi.events",
      "agents": ["laravel-dev", "react-dev"],
      "type": "fullstack"
    },
    "eventsdigest-ai": {
      "path": "eventsdigest-ai",
      "agent": "svelte-dev",
      "type": "frontend"
    }
  }
}
```

#### Option 3: Auto-Discovery
The script can discover repositories by looking for siblings:
```bash
# In /start-session script
CURRENT_REPO=$(basename $(pwd))
TUVENS_ROOT=$(dirname $(pwd))

# Find all Tuvens repos
REPOS=$(find $TUVENS_ROOT -maxdepth 1 -type d -name "tuvens-*" -o -name "*.events" -o -name "*digest*")
```

## Worktree Naming Convention

### Branch → Worktree Mapping
Worktrees are named to match their branches for easy tracking:

```bash
# Branch name: feature-authentication-ui
# Worktree path: ~/Code/Tuvens/tuvens-client/worktrees/feature-authentication-ui

# Branch name: fix-api-validation
# Worktree path: ~/Code/Tuvens/tuvens-api/worktrees/fix-api-validation

# Branch name: laravel-dev/update-cors-config
# Worktree path: ~/Code/Tuvens/hi.events/worktrees/laravel-dev-update-cors-config
```

### Worktree Creation Pattern
```bash
# Generic pattern
cd ~/Code/Tuvens/[REPO]
git worktree add worktrees/[BRANCH_NAME] -b [BRANCH_NAME]

# With agent prefix
git worktree add worktrees/[AGENT]-[FEATURE] -b [AGENT]/[FEATURE]
```

### Cleanup Strategy
Since worktree names match branches:
```bash
# List worktrees that can be cleaned up (merged branches)
git worktree list | while read -r worktree; do
  branch=$(git worktree list --porcelain | grep -A1 "$worktree" | grep branch | cut -d' ' -f2)
  if git branch -r --merged | grep -q "$branch"; then
    echo "Can remove: $worktree (branch $branch is merged)"
  fi
done
```

## /start-session Implementation

### Core Functionality
```bash
#!/bin/bash
# /start-session [agent-name]

# 1. Determine current repository
CURRENT_DIR=$(pwd)
CURRENT_REPO=$(basename $CURRENT_DIR)

# 2. Load repository awareness
if [ -f ~/.tuvens/config.json ]; then
  TUVENS_ROOT=$(jq -r '.root' ~/.tuvens/config.json)
else
  TUVENS_ROOT=${TUVENS_ROOT:-"$HOME/Code/Tuvens"}
fi

# 3. Validate agent for repository
VALID_AGENTS=$(jq -r ".repositories[\"$CURRENT_REPO\"].agents[]?" ~/.tuvens/config.json)
if ! echo "$VALID_AGENTS" | grep -q "$1"; then
  echo "Warning: $1 may not be the right agent for $CURRENT_REPO"
fi

# 4. Create GitHub issue
ISSUE_URL=$(create_github_issue "$CURRENT_REPO" "$1" "Task from Claude Desktop")

# 5. Determine branch name
BRANCH_NAME="$1/$(generate_branch_name_from_context)"

# 6. Create worktree
WORKTREE_PATH="$CURRENT_DIR/worktrees/$BRANCH_NAME"
git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"

# 7. Setup context file
cat > "$WORKTREE_PATH/.claude-context.md" << EOF
Current Repository: $CURRENT_REPO
Agent: $1
Branch: $BRANCH_NAME
Issue: $ISSUE_URL
Tuvens Root: $TUVENS_ROOT

Available Repositories:
$(ls -1 $TUVENS_ROOT | grep -E 'tuvens-|events|digest')

Load Context:
- Load: tuvens-docs/.claude/agents/$1.md
- Load: tuvens-docs/agentic-development/workflows/worktree-organization.md
EOF

# 8. Open terminal with context
open_iterm_with_prompt "$WORKTREE_PATH" "$1" "$BRANCH_NAME"
```

### Context Preservation

The script creates a `.claude-context.md` file in each worktree that includes:
- Current repository and branch
- Agent assignment
- Path to other repositories
- GitHub issue reference
- Standard context loading instructions

## Usage Examples

### From tuvens-client
```bash
cd ~/Code/Tuvens/tuvens-client
/start-session svelte-dev

# Creates:
# - GitHub issue for svelte-dev
# - Worktree: ~/Code/Tuvens/tuvens-client/worktrees/svelte-dev-[feature]
# - Context file with repo awareness
```

### From hi.events (choosing agent)
```bash
cd ~/Code/Tuvens/hi.events

# For backend work
/start-session laravel-dev

# For frontend work
/start-session react-dev
```

### Cross-Repository Task
When a task spans repositories, the context file helps navigate:
```markdown
# In .claude-context.md
Related Repositories:
- API Implementation: $TUVENS_ROOT/tuvens-api
- Frontend Updates: $TUVENS_ROOT/tuvens-client
- Integration Docs: $TUVENS_ROOT/tuvens-docs
```

## Best Practices

1. **Always work in worktrees** - Never modify the main branch directly
2. **Match worktree to branch names** - Enables easy cleanup
3. **Include repo context** - Each session should know about other repos
4. **Validate agent selection** - Warn if agent seems wrong for repo
5. **Preserve GitHub issue link** - Maintains task tracking

## Troubleshooting

### Can't find other repositories
- Check `TUVENS_ROOT` environment variable
- Verify all repos are siblings in the same parent directory
- Ensure config file paths are absolute, not relative

### Worktree conflicts
- Use `git worktree list` to see existing worktrees
- Remove old worktrees: `git worktree remove [path]`
- Prune stale entries: `git worktree prune`

### Context not loading
- Verify `tuvens-docs` exists in project root
- Check symlink is valid: `ls -la tuvens-docs`
- Ensure `.gitignore` includes `/tuvens-docs`