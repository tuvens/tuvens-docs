---
allowed-tools: Bash, Write, Read, LS, Grep, Task
description: Create fully automated Claude Code session with context-aware task detection
argument-hint: [agent-name]
---

# Start New Claude Code Session

I'll analyze the current conversation context and create a fully automated Claude Code session setup.

## Agent Assignment
Agent: `$ARGUMENTS`

## Context Analysis

Let me analyze our current conversation to understand what task needs to be implemented.

First, I'll check the current repository context:
- Repository: !`git remote get-url origin | sed 's/.*\///' | sed 's/\.git//'`
- Working directory: !`pwd`
- Current branch: !`git branch --show-current`

## Automated Session Creation Process

Based on our conversation, I will:

1. **Analyze Recent Context**: Review our discussion to understand the specific task
2. **Identify Task Details**: Determine the task title and description from context
3. **Create GitHub Issue**: Use the `/create-issue` command if needed
4. **Setup Worktree**: Create proper worktree following `agentic-development/workflows/worktree-organization.md`
5. **Generate Prompt**: Create agent-specific prompt with all context
6. **Open iTerm2**: Display the prompt in a new terminal window

## Dynamic Task Detection

I'll now analyze our conversation to determine:
- What specific task or feature we've been discussing
- The most appropriate task title
- A clear task description
- Which repository this belongs to

Then I'll execute the agent task setup with these context-aware parameters.

## Execution

After analyzing the conversation context, I'll execute the setup automation with the appropriate task details.

The script will handle:
- GitHub issue creation with proper labels
- Worktree setup following `[repo]/[agent]/[branch]` pattern
- Agent prompt generation
- iTerm2 window automation