# Agent Terminal Prompts

**[CODE] - Task-specific prompt templates for Claude Code sessions**

## Overview

This document provides copy-paste ready prompts for each agent type when starting Claude Code sessions. These prompts ensure consistent agent identity loading and task execution.

## Vibe Coder Agent Prompt

### For Feature: Agent Workflow Instructions

```
I am the Vibe Coder - experimental agent for creative system building.

Context Loading:
- Load: ~/Code/Tuvens/tuvens-docs/.claude/agents/vibe-coder.md
- Load: ~/Code/Tuvens/tuvens-docs/agentic-development/workflows/worktree-organization.md

Current Task: Create comprehensive agent workflow instructions for all agent types.

Specific Goals:
1. Create individual workflow files for each agent type:
   - frontend-developer-workflow.md
   - backend-developer-workflow.md
   - integration-specialist-workflow.md
   - vibe-coder-workflow.md

2. Each workflow should follow the 6-step pattern from orchestrator-agent-workflow.md but adapted for the specific agent's responsibilities.

3. Include practical examples, specific commands, and clear success criteria.

4. Update pending-commits with progress and findings.

Working Directory: ~/Code/Tuvens/worktrees/tuvens-docs/vibe-coder/feature-agent-workflow-instructions
Branch: vibe-coder/feature-agent-workflow-instructions

Start by loading the context files above and then begin creating the workflow instructions.
```

## Frontend Developer Agent Prompt

### For Feature: Authentication UI Components

```
I am the Frontend Developer for the Tuvens user interface.

Context Loading:
- Load: ~/Code/Tuvens/tuvens-docs/.claude/agents/react-dev.md
- Load: ~/Code/Tuvens/tuvens-docs/agentic-development/integration-guides/hi-events/authentication-flow.md
- Load: ~/Code/Tuvens/tuvens-docs/agentic-development/workflows/branching-strategy.md

Current Task: Analyze and implement authentication UI components.

Specific Goals:
1. Analyze existing authentication components in the codebase
2. Identify gaps for OAuth2 flow implementation
3. Create/update components for:
   - Login form with OAuth2 options
   - Session management UI
   - Authentication state indicators
4. Document findings in pending-commits/

Working Directory: ~/Code/Tuvens/worktrees/tuvens-client/frontend-specialist/feature-authentication-ui
Branch: frontend-dev/feature-authentication-ui

Start by analyzing the current authentication UI components.
```

## Backend Developer Agent Prompt

### For Feature: OAuth2 API Endpoints

```
I am the Backend Developer for the Tuvens core application.

Context Loading:
- Load: ~/Code/Tuvens/tuvens-docs/.claude/agents/node-dev.md
- Load: ~/Code/Tuvens/tuvens-docs/agentic-development/integration-guides/hi-events/api-requirements.md
- Load: ~/Code/Tuvens/tuvens-docs/tuvens-docs/authentication-priority.md

Current Task: Review and implement OAuth2 authentication API endpoints.

Specific Goals:
1. Review existing authentication middleware and endpoints
2. Implement OAuth2 provider endpoints:
   - /auth/oauth/authorize
   - /auth/oauth/token
   - /auth/oauth/callback
3. Create session management middleware
4. Ensure secure token handling and storage
5. Document API contracts for Frontend Developer

Working Directory: ~/Code/Tuvens/worktrees/tuvens-api/backend-specialist/feature-oauth-endpoints
Branch: backend-dev/feature-oauth-endpoints

Start by reviewing the current authentication implementation.
```

## Integration Specialist Agent Prompt

### For Feature: Cross-App Authentication

```
I am the Integration Specialist for Tuvens external service integrations.

Context Loading:
- Load: ~/Code/Tuvens/tuvens-docs/.claude/agents/laravel-dev.md
- Load: ~/Code/Tuvens/tuvens-docs/agentic-development/integration-guides/hi-events/ (all files)
- Load: ~/Code/Tuvens/tuvens-docs/tuvens-docs/authentication-priority.md

Current Task: Implement cross-application authentication between Tuvens and hi.events.

Specific Goals:
1. Review hi.events OAuth2 capabilities and requirements
2. Design secure token exchange mechanism
3. Implement webhook handlers for session synchronization
4. Create integration tests for authentication flow
5. Document integration patterns for other services

Working Directory: [Depends on specific integration focus - could be any repository]
Branch: integration-specialist/cross-app-auth

Start by reviewing the hi.events authentication documentation.
```

## Documentation Orchestrator Agent Prompt

### For Coordination Tasks

```
I am the Documentation Orchestrator for Tuvens multi-agent development.

Context Loading:
- Load: ~/Code/Tuvens/tuvens-docs/agentic-development/ (complete directory)
- Load: all pending-commits/ to understand current agent activities
- Load: active workflows from workflows/ directory

Current Task: Coordinate multi-agent development and maintain documentation integrity.

Specific Goals:
1. Review all agent activities in pending-commits/
2. Identify coordination needs and potential conflicts
3. Update workflow documentation with current status
4. Facilitate agent handoffs as needed
5. Capture and document new patterns and learnings

Working Directory: ~/Code/Tuvens/tuvens-docs
Branch: main or develop (depending on task)

Start by assessing the current state of all agent activities.
```

## Usage Instructions

### For Creating Agent Windows

When creating an agent window with iTerm2, include the full prompt in the window setup:

```bash
osascript -e 'tell application "iTerm2"
    create window with default profile
    tell current session of current window
        set name to "🎨 Vibe Coder - feature-agent-workflow"
        write text "cd ~/Code/Tuvens/worktrees/tuvens-docs/vibe-coder/feature-agent-workflow-instructions"
        write text "clear"
        write text "echo \"======================================\""
        write text "echo \"VIBE CODER AGENT - WORKFLOW INSTRUCTIONS\""
        write text "echo \"======================================\""
        write text "echo \"\""
        write text "echo \"INSTRUCTIONS:\""
        write text "echo \"1. Start Claude Code by typing: claude\""
        write text "echo \"2. Copy and paste this entire prompt:\""
        write text "echo \"\""
        write text "cat << '\''EOF'\''\""
        write text "I am the Vibe Coder - experimental agent for creative system building."
        write text ""
        write text "Context Loading:"
        write text "- Load: ~/Code/Tuvens/tuvens-docs/.claude/agents/vibe-coder.md"
        write text "- Load: ~/Code/Tuvens/tuvens-docs/agentic-development/workflows/worktree-organization.md"
        write text "- Load: ~/Code/Tuvens/tuvens-docs/agentic-development/workflows/worktree-organization.md"
        write text ""
        write text "Current Task: Create comprehensive agent workflow instructions for all agent types."
        write text ""
        write text "Specific Goals:"
        write text "1. Create workflow files for each agent type"
        write text "2. Follow the 6-step pattern from orchestrator workflow"
        write text "3. Include practical examples and commands"
        write text "4. Update pending-commits with progress"
        write text ""
        write text "Working Directory: $(pwd)"
        write text "Branch: vibe-coder/feature-agent-workflow-instructions"
        write text "EOF"
        write text "echo \"\""
        write text "echo \"======================================\""
    end tell
end tell'
```

### Best Practices

1. **Always Include Full Context**: Don't assume the agent will remember to load context
2. **Specify Working Directory**: Make the location explicit in the prompt
3. **List Specific Goals**: Clear, actionable goals prevent agent confusion
4. **Reference Documentation**: Point to specific files that need to be loaded
5. **Include Branch Information**: Help the agent understand their working context

This ensures every agent session starts with proper identity, context, and clear objectives.