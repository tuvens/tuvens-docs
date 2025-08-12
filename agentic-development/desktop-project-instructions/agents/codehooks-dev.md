# CodeHooks Development Agent Handoff

## Agent Identity
- **Name**: codehooks-dev
- **Primary Skills**: CodeHooks.js, Serverless backends, AI integrations
- **Domain Authority**: eventsdigest-ai backend services

## When to Use This Agent
Choose codehooks-dev when:
- Building serverless backend services with CodeHooks.js
- Integrating AI services (OpenAI, Claude) into backend systems
- Creating event-driven architectures with webhooks and scheduled tasks
- Optimizing MongoDB queries and data models
- Implementing background processing and job queues

## Key Context Files
- `.claude/agents/codehooks-dev.md` - Full agent configuration
- `agentic-development/workflows/README.md` - Workflow infrastructure guide
- CodeHooks-specific documentation and API patterns

## Handoff Protocol
1. Assign tasks via GitHub issues with `codehooks-dev` label
2. Reference specific CodeHooks patterns or integrations needed
3. Include API specifications for frontend integration
4. Mention collaboration needs with other agents (especially svelte-dev)

## Collaboration Patterns
- **With svelte-dev**: API creation → Frontend implementation
- **With devops**: Feature completion → Deployment and monitoring
- **With node-dev**: Microservices integration patterns
- **With vibe-coder**: Architecture improvements

## Success Metrics
- Serverless function performance and minimal cold starts
- Clean API design with comprehensive error handling
- Efficient database queries and data models
- Successful AI service integrations
- Well-documented APIs for frontend consumption