# Claude Desktop iTerm Workflow Documentation

## Overview

This document describes the adapted workflow for using Claude Desktop with the iTerm MCP server to replicate the Claude Code `/start-session` functionality.

## Key Differences from Claude Code

### Claude Code Workflow
- **Command**: `/start-session [agent-name]`
- **Automation**: Fully automated with AppleScript
- **Process**: Script opens iTerm window → Creates worktree → Starts Claude
- **Integration**: Seamless, single-command execution

### Claude Desktop Workflow
- **Command**: Run `desktop-agent-task.sh` manually
- **Automation**: Two-step process using iTerm MCP
- **Process**: 
  1. Claude Desktop uses iTerm MCP to open terminal
  2. Run setup script inside MCP-opened terminal
- **Integration**: Requires manual MCP tool invocation

## Architecture

```
Claude Desktop
      ↓
[iTerm MCP Tool] → Opens Terminal Window
      ↓
Terminal Window
      ↓
[Setup Script] → Creates Worktree & Prompt
      ↓
Claude Code → Agent Session
```

## Components

### 1. `desktop-agent-task.sh`
The main adapter script that:
- Creates GitHub issues for task tracking
- Generates setup scripts for iTerm execution
- Prepares Claude prompts
- Provides MCP command instructions

### 2. Generated Setup Script
A temporary script that runs inside the iTerm window:
- Creates Git worktrees
- Sets up the development environment
- Generates Claude prompt files
- Provides session instructions

### 3. iTerm MCP Integration
Uses the iTerm MCP server to:
- Open new terminal windows
- Execute commands in terminals
- Maintain session persistence

## Usage

### Step 1: Prepare the Task

```bash
# Basic usage
./agentic-development/scripts/desktop-agent-task.sh vibe-coder "Fix authentication" "Debug OAuth flow issues"

# With context file
./agentic-development/scripts/desktop-agent-task.sh backend-dev "Add API endpoint" "Create /users endpoint" context.md

# With file validation
./agentic-development/scripts/desktop-agent-task.sh frontend-dev "Update UI" "Redesign dashboard" --files="App.svelte,Dashboard.svelte"

# Skip GitHub issue creation
./agentic-development/scripts/desktop-agent-task.sh devops "Deploy feature" "Deploy to staging" --skip-issue
```

### Step 2: Use iTerm MCP in Claude Desktop

1. In Claude Desktop, use the iTerm MCP tool to open a new terminal window
2. The tool will create a new iTerm session

### Step 3: Run Setup Script

In the newly opened iTerm window, run the generated setup script:

```bash
bash "/path/to/generated/desktop-setup-[agent]-[timestamp].sh"
```

### Step 4: Start Claude Code

After the setup completes:

```bash
claude
```

### Step 5: Load the Prompt

Copy and paste the content from the generated `claude-prompt.txt` file.

## File Structure

```
agentic-development/
├── scripts/
│   ├── setup-agent-task.sh         # Original Claude Code script
│   └── desktop-agent-task.sh       # Claude Desktop adapter
├── prompts/
│   ├── desktop-setup-*.sh          # Generated setup scripts
│   ├── desktop-iterm-command-*.txt # MCP command references
│   └── claude-prompt.txt           # Generated prompts
└── docs/
    └── desktop-iterm-workflow.md   # This documentation
```

## Workflow Comparison

| Feature | Claude Code | Claude Desktop |
|---------|------------|----------------|
| **Initiation** | `/start-session` command | Run `desktop-agent-task.sh` |
| **Terminal Opening** | AppleScript automation | iTerm MCP tool |
| **Worktree Creation** | Automatic | Semi-automatic (run script) |
| **Claude Launch** | Automatic | Manual |
| **Prompt Loading** | Automatic display | Manual copy/paste |
| **GitHub Integration** | Full | Full |
| **Branch Tracking** | Automatic | Automatic |

## Agent Support

The following agents are supported:
- `vibe-coder` - System orchestration
- `backend-dev` - Backend development
- `frontend-dev` - Frontend development
- `svelte-dev` - Svelte framework
- `react-dev` - React framework
- `laravel-dev` - Laravel framework
- `node-dev` - Node.js development
- `devops` - Infrastructure and deployment
- `mobile-dev` - Mobile development
- `docs-orchestrator` - Documentation
- `integration-specialist` - Cross-system integration

## Repository Mapping

Agents are automatically mapped to their primary repositories:
- **tuvens-docs**: vibe-coder, docs-orchestrator
- **tuvens-client**: svelte-dev, frontend-dev
- **tuvens-api**: node-dev, backend-dev
- **hi.events**: laravel-dev
- **tuvens-mobile**: mobile-dev

## Advanced Features

### Custom Branch Names

```bash
./desktop-agent-task.sh vibe-coder "Task" "Description" --branch-name="custom-branch-name"
```

### Success Criteria

```bash
./desktop-agent-task.sh backend-dev "Task" "Description" --success-criteria="All tests pass, API documented"
```

### Multiple File Validation

```bash
./desktop-agent-task.sh frontend-dev "Task" "Description" --files="src/App.js,src/components/Header.js,tests/App.test.js"
```

## Troubleshooting

### iTerm MCP Not Working
- Ensure iTerm MCP server is installed and configured
- Check Claude Desktop MCP settings
- Verify iTerm2 is installed and accessible

### Script Execution Fails
- Check file permissions: `chmod +x desktop-agent-task.sh`
- Verify Git repository access
- Ensure GitHub CLI (`gh`) is authenticated

### Worktree Issues
- Remove existing worktrees: `git worktree prune`
- Check disk space for worktree creation
- Verify branch doesn't already exist

## Future Enhancements

1. **Automated MCP Integration**: Direct MCP API calls from script
2. **Session Persistence**: Save and restore agent sessions
3. **Multi-Agent Coordination**: Support for parallel agent tasks
4. **Cloud Sync**: Synchronize worktrees across devices
5. **Voice Commands**: Integration with voice assistants

## Security Considerations

- Scripts are generated with restricted permissions
- GitHub tokens are not stored in scripts
- Temporary files are cleaned up after use
- Branch protection rules are respected

## Conclusion

The Claude Desktop iTerm workflow provides a functional adaptation of the Claude Code `/start-session` command, maintaining the core functionality while working within the constraints of the Claude Desktop environment. While it requires an additional manual step compared to the fully automated Claude Code workflow, it preserves all the essential features including GitHub integration, worktree isolation, and agent-specific setups.
