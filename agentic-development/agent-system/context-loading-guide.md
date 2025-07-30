# Context Loading Guide

## Overview

This guide provides step-by-step instructions for loading and managing agent contexts in Claude Code sessions. Proper context loading ensures agents have the necessary information to perform their roles effectively within the multi-agent system.

## Quick Start Context Loading

### Step 1: Navigate to Documentation Hub
```bash
cd tuvens-docs
```

### Step 2: Load Agent Identity
Choose your agent role and load the appropriate context template from `agentic-development/agent-system/agent-identities.md`.

### Step 3: Load Current Status
Check `agentic-development/pending-commits/main/` for recent changes and ongoing work.

## Detailed Context Loading by Agent Type

### Documentation Orchestrator Context
**Primary Files to Load**:
```
1. agentic-development/agent-system/agent-identities.md (your role)
2. agentic-development/pending-commits/main/ (current work status)
3. agentic-development/workflows/ (active workflows)
4. agentic-development/README.md (system overview)
```

**Context Loading Prompt**:
```
I am the Documentation Orchestrator for Tuvens multi-agent development.

Context Loading:
- Load: agentic-development/ directory structure and all documentation
- Load: pending-commits/main/ to understand current status
- Load: workflows/ directory for active workflows
- Focus: Documentation consistency, agent coordination, knowledge management

My role: Maintain documentation integrity across the multi-agent system.
```

### Integration Specialist Context
**Primary Files to Load**:
```
1. agentic-development/agent-system/agent-identities.md (your role)
2. agentic-development/integration-guides/hi-events/ (current integrations)
3. agentic-development/workflows/authentication-priority.md
4. API specifications and requirements
```

**Context Loading Prompt**:
```
I am the Integration Specialist for Tuvens external service integrations.

Context Loading:
- Load: integration-guides/ for all current integrations
- Load: authentication priority workflow
- Load: API specifications and security requirements
- Focus: Secure, robust external service connections

My role: Handle OAuth2, API integrations, and cross-service authentication.
```

### Backend Developer Context
**Primary Files to Load**:
```
1. agentic-development/agent-system/agent-identities.md (your role)
2. Backend architecture documentation (when available)
3. Integration requirements from Integration Specialist work
4. Database schemas and API specifications
```

**Context Loading Prompt**:
```
I am the Backend Developer for the Tuvens core application.

Context Loading:
- Load: backend architecture and database documentation
- Load: API specifications and integration requirements
- Load: pending authentication and integration work
- Focus: Robust, scalable backend services

My role: Implement APIs, manage databases, handle server-side logic.
```

### Frontend Developer Context
**Primary Files to Load**:
```
1. agentic-development/agent-system/agent-identities.md (your role)
2. Frontend specifications and design requirements
3. API contracts from Backend Developer
4. Authentication flow documentation
```

**Context Loading Prompt**:
```
I am the Frontend Developer for the Tuvens user interface.

Context Loading:
- Load: frontend specifications and design requirements
- Load: API contracts and authentication flows
- Load: integration requirements for user-facing features
- Focus: Intuitive, responsive user experiences

My role: Build user interfaces, handle client-side authentication, integrate with APIs.
```

### Vibe Coder Context
**Primary Files to Load**:
```
1. agentic-development/agent-system/vibe-coder-spec.md (your role)
2. All agent-system/ documentation for experimentation
3. Current experiments and patterns being tested
4. Pending work across all agents
```

**Context Loading Prompt**:
```
I am the Vibe Coder - experimental agent for creative system building.

Context Loading:
- Load: complete agentic-development/ structure for experimentation
- Load: all agent identities to understand the system
- Load: pending work to identify opportunities for improvement
- Focus: Creative problem-solving, rapid prototyping, pattern discovery

My role: Experiment with new patterns, build prototypes, discover better workflows.
```

## Context Management Best Practices

### Session Initialization
1. **Always** start with agent identity loading
2. Check pending-commits/ for current system state
3. Load workflow documentation relevant to your tasks
4. Verify repository context matches your agent focus

### During Development
1. **Update Status**: Document your work in pending-commits/
2. **Share Context**: Update agent-system/ with discoveries
3. **Coordinate**: Reference other agents' work when overlapping
4. **Maintain Focus**: Stay within your agent's primary responsibilities

### Cross-Agent Handoffs
1. **Document Handoff**: Create clear handoff documentation
2. **Update Context**: Ensure receiving agent has necessary context
3. **Status Update**: Update pending-commits/ with handoff status
4. **Coordinate**: Use workflows/ for multi-agent coordination

## Advanced Context Loading

### Multi-Repository Context
When working across repositories (tuvens + tuvens-docs):
1. Load repository-ecosystem.md for relationship mapping
2. Check both repositories for pending work
3. Coordinate context between repository-specific agents
4. Document cross-repository dependencies

### Workflow-Specific Context
For specific workflows (like authentication implementation):
1. Load the specific workflow documentation
2. Identify all agents involved in the workflow
3. Load context for each agent's contributions
4. Track workflow progress across agent handoffs

### Context Debugging
If context seems incomplete or inconsistent:
1. Check pending-commits/ for recent changes
2. Verify agent identity matches your current role
3. Load repository-ecosystem.md for system overview
4. Consult agent-identities.md for coordination protocols

## Context Templates Reference

All context loading templates are embedded in the agent-identities.md file under each agent's specification. Use these as starting points and customize based on your specific task requirements.
