# Tuvens Ecosystem Repository Reference

This repository reference index provides comprehensive navigation and overview of all Tuvens ecosystem repositories, organized by technology stack and development responsibilities.

## 📋 Repository Overview

The Tuvens ecosystem consists of **5 repositories** spanning documentation, core platform services, specialized applications, and integration management.

| Repository | Status | Primary Tech Stack | Agents | Purpose |
|------------|--------|-------------------|---------|---------|
| [tuvens-docs](./tuvens-docs.md) | ✅ Active | Markdown, GitHub Actions | vibe-coder, devops | Central documentation and agent coordination |
| [tuvens-api](./tuvens-api.md) | ✅ Active | Node.js, TypeScript, Express | node-dev, devops | Core Tuvens platform backend services |
| [tuvens-client](./tuvens-client.md) | ✅ Active | SvelteKit, TypeScript, Skeleton.dev | svelte-dev, devops | Main Tuvens platform frontend interface |
| [eventsdigest-ai](./eventsdigest-ai.md) | ✅ Active | SvelteKit + CodeHooks, AI Services | svelte-dev, codehooks-dev, devops | AI-powered event digest platform |
| [hi.events](./hi-events.md) | ✅ Active | Laravel + React, MySQL/PostgreSQL | laravel-dev, react-dev, devops | Event management and ticketing platform |

## 🔧 Technology Stack Organization

### Frontend Technologies

#### SvelteKit Applications
- **[tuvens-client](./tuvens-client.md)** - Main platform frontend
  - **Agent**: svelte-dev
  - **Stack**: SvelteKit, TypeScript, Skeleton.dev UI
  - **Role**: Primary user interface for Tuvens platform
  - **Integration**: Connects to tuvens-api backend

- **[eventsdigest-ai](./eventsdigest-ai.md)** - AI event digest frontend
  - **Agent**: svelte-dev (frontend coordination)
  - **Stack**: SvelteKit, TypeScript
  - **Role**: AI-powered event analysis and recommendations
  - **Integration**: Connects to CodeHooks backend services

#### React Applications
- **[hi.events](./hi-events.md)** - Event management frontend
  - **Agent**: react-dev
  - **Stack**: React, TypeScript/JavaScript
  - **Role**: Event ticketing and management interface
  - **Integration**: Connects to Laravel backend API

### Backend Technologies

#### Node.js Services
- **[tuvens-api](./tuvens-api.md)** - Core platform backend
  - **Agent**: node-dev
  - **Stack**: Node.js, Express.js, TypeScript, MongoDB/PostgreSQL
  - **Role**: Main API services for Tuvens platform
  - **Integration**: Serves tuvens-client frontend

#### Specialized Backends
- **[eventsdigest-ai](./eventsdigest-ai.md)** - AI processing backend
  - **Agent**: codehooks-dev
  - **Stack**: CodeHooks.js serverless, AI Services (OpenAI/Claude)
  - **Role**: AI event processing and recommendation engine
  - **Integration**: Serves eventsdigest-ai frontend

- **[hi.events](./hi-events.md)** - Event management backend
  - **Agent**: laravel-dev
  - **Stack**: Laravel (PHP), MySQL/PostgreSQL
  - **Role**: Event management API and business logic
  - **Integration**: Serves hi.events React frontend

### Infrastructure & Documentation
- **[tuvens-docs](./tuvens-docs.md)** - Ecosystem coordination
  - **Agent**: vibe-coder (primary), devops (automation)
  - **Stack**: Markdown, GitHub Actions, Multi-agent coordination system
  - **Role**: Central documentation hub and agent system management
  - **Integration**: Coordinates all other repositories

## 🤖 Agent-Specific Loading Guidance

### By Agent Type

#### Frontend Specialists
- **svelte-dev**
  - Primary: [tuvens-client](./tuvens-client.md), [eventsdigest-ai](./eventsdigest-ai.md) (frontend)
  - Context: SvelteKit applications, TypeScript, UI frameworks
  - Coordination: Works with backend agents for API integration

- **react-dev**
  - Primary: [hi.events](./hi-events.md) (frontend)
  - Context: React components, TypeScript/JavaScript, Laravel integration
  - Coordination: Works with laravel-dev for full-stack development

#### Backend Specialists
- **node-dev**
  - Primary: [tuvens-api](./tuvens-api.md)
  - Context: Node.js services, Express.js, database integration
  - Coordination: Works with svelte-dev for API specification

- **laravel-dev**
  - Primary: [hi.events](./hi-events.md) (backend)
  - Context: Laravel PHP framework, database design, API development
  - Coordination: Works with react-dev for full-stack coordination

- **codehooks-dev**
  - Primary: [eventsdigest-ai](./eventsdigest-ai.md) (backend)
  - Context: CodeHooks serverless, AI service integration
  - Coordination: Works with svelte-dev for AI frontend integration

#### System Specialists
- **vibe-coder**
  - Primary: [tuvens-docs](./tuvens-docs.md)
  - Context: Documentation systems, agent coordination, architecture
  - Coordination: Cross-repository documentation and system design

- **devops**
  - Secondary: All repositories
  - Context: GitHub Actions, CI/CD, deployment automation
  - Coordination: Infrastructure support for all development teams

## 🔗 Repository Relationships & Integration Map

### Core Platform Integration
```
tuvens-client (SvelteKit) ←→ tuvens-api (Node.js)
    ↕                              ↕
svelte-dev                    node-dev
```
**Purpose**: Main Tuvens platform with real-time event management  
**Integration**: REST API with WebSocket support  
**Agents**: svelte-dev ↔ node-dev coordination

### Event Management Integration
```
hi.events React Frontend ←→ hi.events Laravel Backend
         ↕                              ↕
    react-dev                    laravel-dev
```
**Purpose**: Full-stack event ticketing and management platform  
**Integration**: Laravel API with React components  
**Agents**: react-dev ↔ laravel-dev coordination

### AI Processing Integration
```
eventsdigest-ai SvelteKit ←→ eventsdigest-ai CodeHooks
           ↕                              ↕
      svelte-dev                  codehooks-dev
```
**Purpose**: AI-powered event analysis and recommendations  
**Integration**: CodeHooks serverless with SvelteKit frontend  
**Agents**: svelte-dev ↔ codehooks-dev coordination

### Documentation & Coordination Hub
```
                    tuvens-docs
                        ↕
                   vibe-coder
                   ↕       ↕
            All Repositories ←→ devops (CI/CD)
```
**Purpose**: Central documentation and agent coordination system  
**Integration**: Documentation hub for all repositories  
**Agents**: vibe-coder coordinates with all agents, devops provides infrastructure

## 📚 Repository Access Patterns

### For New Agents
1. **Start with**: [tuvens-docs](./tuvens-docs.md) for ecosystem overview
2. **Load technology context**: Reference your technology-specific repository
3. **Review integrations**: Check [integration-registry.md](./integration-registry.md) for cross-repository dependencies
4. **Check agent coordination**: Review `.claude/agents/` for agent-specific instructions

### For Cross-Repository Work
1. **Primary repository**: Load your main technology repository context
2. **Integration points**: Review related repositories in this index
3. **Agent handoffs**: Use GitHub issues for coordinating with other agents
4. **Documentation updates**: Update both repositories and this index

### For System Architecture
1. **Full ecosystem view**: Review all repository contexts
2. **Integration patterns**: Study [integration-registry.md](./integration-registry.md)
3. **Agent coordination**: Review agent-specific contexts in `.claude/agents/`
4. **Documentation coordination**: Maintain consistency across all repositories

## 🔍 Quick Navigation

### By Development Focus
- **Frontend Development**: [tuvens-client](./tuvens-client.md), [eventsdigest-ai](./eventsdigest-ai.md) (frontend), [hi.events](./hi-events.md) (frontend)
- **Backend Development**: [tuvens-api](./tuvens-api.md), [eventsdigest-ai](./eventsdigest-ai.md) (backend), [hi.events](./hi-events.md) (backend)
- **Full-Stack Applications**: [eventsdigest-ai](./eventsdigest-ai.md), [hi.events](./hi-events.md)
- **Documentation & Coordination**: [tuvens-docs](./tuvens-docs.md)

### By Technology Preference
- **SvelteKit**: [tuvens-client](./tuvens-client.md), [eventsdigest-ai](./eventsdigest-ai.md)
- **React**: [hi.events](./hi-events.md)
- **Node.js**: [tuvens-api](./tuvens-api.md)
- **Laravel/PHP**: [hi.events](./hi-events.md)
- **CodeHooks Serverless**: [eventsdigest-ai](./eventsdigest-ai.md)

### By Agent Responsibility
- **svelte-dev**: [tuvens-client](./tuvens-client.md), [eventsdigest-ai](./eventsdigest-ai.md) (frontend)
- **react-dev**: [hi.events](./hi-events.md) (frontend)
- **node-dev**: [tuvens-api](./tuvens-api.md)
- **laravel-dev**: [hi.events](./hi-events.md) (backend)
- **codehooks-dev**: [eventsdigest-ai](./eventsdigest-ai.md) (backend)
- **vibe-coder**: [tuvens-docs](./tuvens-docs.md)
- **devops**: All repositories (secondary)

## 📖 Additional Documentation

### Repository-Specific Context
Each repository maintains detailed technical context in its own `.claude/repository-context.md` file (when available). The files in this directory serve as navigation aids and agent loading guidance.

### Integration Documentation
- **[integration-registry.md](./integration-registry.md)** - Comprehensive integration patterns, API contracts, and cross-repository coordination
- **[index.md](./index.md)** - Minimal navigation index for quick repository access

### Agent Coordination
- **Agent Instructions**: `.claude/agents/` directory contains technology-specific agent instructions
- **Command Templates**: `.claude/commands/` directory contains cross-repository communication templates
- **Workflow Patterns**: `agentic-development/workflows/` directory contains coordination patterns

---

**Repository Count**: 5 active repositories  
**Technology Stacks**: SvelteKit, React, Node.js, Laravel, CodeHooks, Documentation Systems  
**Agent Specializations**: 7 agents across frontend, backend, and system coordination  
**Last Updated**: 2025-08-19  
**Maintained By**: devops agent