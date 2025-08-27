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

### Enhanced Core Functionality (Updated)

The `/start-session` command now supports enhanced context generation through `setup-agent-task.sh`:

```bash
#!/bin/bash
# /start-session [agent-name] [task-title] [task-description] [options...]

# Enhanced usage patterns:
# Basic: /start-session svelte-dev "Fix UI Bug" "Button not responsive"
# With context: /start-session svelte-dev "Complex Task" "Description" /tmp/context.md
# With files: /start-session svelte-dev "Fix Files" "Update components" --files="comp1.svelte,comp2.svelte"
# Full enhanced: /start-session svelte-dev "Task" "Desc" context.md --files="a.md,b.md" --success-criteria="All tests pass"

# Implementation calls enhanced setup-agent-task.sh:
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
"$SCRIPT_DIR/../scripts/setup-agent-task.sh" "$@"
```

### Enhanced Features Added

#### 1. Context File Support
```bash
# Create detailed context file
cat > /tmp/task-context.md << EOF
## Problem Analysis
[Detailed analysis with specific examples]

## Current State Analysis  
[What was discovered about current state]

## Specific Files to Examine
[Exact file paths and what to look for]

## Success Criteria
[Measurable outcomes and validation]
EOF

# Use context in session creation
/start-session vibe-coder "Complex Task" "Description" /tmp/task-context.md
```

#### 2. File Reference Validation
```bash
# Specify files to examine with validation
/start-session svelte-dev "Fix Components" "Update broken components" \
  --files="src/components/Button.svelte,src/components/Modal.svelte"

# Script validates file existence and warns about missing files
# GitHub issue includes validated file references
```

#### 3. Success Criteria Definition
```bash
# Define measurable outcomes
/start-session node-dev "API Enhancement" "Add new endpoints" \
  --success-criteria="All tests pass, API documentation updated, endpoints return correct status codes"
```

#### 4. Structured GitHub Issue Templates
Generated issues now include comprehensive sections:

```markdown
# [Task Title]

**Agent**: [agent-name]  
**Generated**: [timestamp]

## Task Description
[Detailed task description]

## Context Analysis
[Content from context file if provided]

## Files to Examine
- `validated/file/path1.js`
- `validated/file/path2.js`

## Success Criteria
[Specific measurable outcomes]

## Implementation Notes
- Review the task requirements carefully
- Follow the 6-step agent workflow pattern
- Update this issue with progress and findings
- Reference specific files and line numbers in comments

## Validation Checklist
- [ ] Task requirements understood
- [ ] Relevant files identified and examined
- [ ] Solution implemented according to requirements
- [ ] Testing completed (if applicable)
- [ ] Documentation updated (if applicable)
- [ ] Issue updated with final results
```

### Enhanced Context Preservation

The enhanced script now creates comprehensive context through:

#### Enhanced Agent Prompt Generation
```bash
# Generated prompt now includes:
CLAUDE PROMPT:

I am the [Agent Name] agent.

Context Loading:
- Load: .claude/agents/[agent-name].md
- Load: Implementation reports and workflow documentation
- Load: Context from [context-file] (if provided)

GitHub Issue: #[issue-number]
Task: [task-title]

Working Directory: [worktree-path]
Branch: [branch-name]

Priority Files to Examine: (if provided)
- file1.ext
- file2.ext

Success Criteria: (if provided)
[detailed success criteria]

Start your work by:
1. Reading the comprehensive GitHub issue #[issue] for full context
2. Examining the specified files (if any) to understand current state
3. Following the 6-step agent workflow pattern
4. Updating the GitHub issue with your progress and findings
```

#### Backward Compatibility Maintained
All existing usage patterns continue to work:
```bash
# Simple usage still works
/start-session vibe-coder "Simple Task" "Basic description"

# Creates GitHub issue with standard template sections
# No breaking changes to existing workflows
```

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