# GitHub Comment Standards Protocol

> **📍 Navigation**: [agentic-development](../README.md) → [protocols](./README.md) → [github-comment-standards.md](./github-comment-standards.md)

**Protocol**: Universal Comment Identity System for GitHub Interactions  
**Version**: 1.0  
**Created**: 2025-08-14  
**Phase**: 2 Implementation  

## 📚 When to Load This Document

### Primary Context Loading Scenarios
- **Agent Communication**: Before making ANY GitHub issue comment (mandatory for all agents)
- **Issue Creation**: When creating GitHub issues that involve agent assignment or coordination
- **Protocol Violations**: When comment format violations are detected and need correction
- **Agent Onboarding**: Essential for all new agent sessions - this protocol is universal
- **Multi-Agent Projects**: Before any collaborative work requiring clear communication

### Dependency Mapping
**Load Before:**
- Any GitHub issue interaction by any agent
- [agent-checkin-validation.md](./agent-checkin-validation.md) - Session start procedures

**Load With:**
- [Complete Protocol Framework Context](./README.md) - Complete protocol framework context
- Active GitHub issues requiring agent communication

**Load After:**
- [file-scope-management.md](./file-scope-management.md) - Resource coordination protocols
- [emergency-response-procedures.md](./emergency-response-procedures.md) - Crisis communication protocols

### Context Integration
This protocol is mandatory for ALL agents. Every GitHub comment by any agent must follow these standards. Load this immediately when working with GitHub issues or agent coordination.

## Overview

The GitHub Comment Standards Protocol establishes the universal comment identity system that ensures clear communication and accountability in all agent interactions. This protocol transforms the theoretical framework from Phase 1 into practical, testable procedures with validation scenarios and success metrics.

## Core Requirements

### Universal Comment Format (MANDATORY)

**EVERY GitHub issue comment by ANY agent MUST start with:**

```markdown
👤 **Identity**: [my-agent-name] 
🎯 **Addressing**: [target-agent-name or @all]
```

This format ensures clear communication and accountability in all agent interactions across the entire multi-agent system.

### Required Header Components

#### Identity Declaration
- **Format**: `👤 **Identity**: [agent-name]`
- **Purpose**: Clear identification of the commenting agent
- **Validation**: Must match registered agent name in `.claude/agents/` directory
- **Examples**:
  - ✅ `👤 **Identity**: vibe-coder`
  - ✅ `👤 **Identity**: laravel-dev`
  - ❌ `👤 **Identity**: unknown-agent` (unregistered)
  - ❌ `Identity: vibe-coder` (missing emoji and formatting)

#### Addressing Declaration
- **Format**: `🎯 **Addressing**: [target-agent or @all]`
- **Purpose**: Clear targeting of communication recipient
- **Options**:
  - Specific agent: `🎯 **Addressing**: docs-orchestrator`
  - Multiple agents: `🎯 **Addressing**: laravel-dev, react-dev`
  - All agents: `🎯 **Addressing**: @all`
  - User/maintainer: `🎯 **Addressing**: @maintainer`

## Registered Agent Directory

### Valid Agent Names
The following agent names are registered and valid for use:

#### Primary System Agents
- **vibe-coder** - System Orchestrator and coordination authority
- **docs-orchestrator** - Documentation management and organization
- **devops** - Infrastructure, deployment, and CI/CD workflows

#### Development Agents
- **laravel-dev** - Laravel/PHP backend development
- **react-dev** - React/TypeScript frontend development  
- **python-dev** - Python applications and data science

#### Specialized Agents
- **security-audit** - Security analysis and vulnerability assessment
- **performance-dev** - Performance optimization and monitoring
- **test-automation** - Testing framework and automation

### Agent Registration Process

#### Adding New Agents
1. Create agent identity file: `.claude/agents/[agent-name].md`
2. Update this protocol's valid agent registry
3. Add to system documentation and training materials
4. Test comment format compliance

#### Agent Deactivation
1. Mark agent as inactive in registry
2. Update validation rules to reject comments
3. Archive agent identity file
4. Document deactivation reason and date

## Comment Structure Standards

### Complete Comment Template

```markdown
👤 **Identity**: [agent-name]
🎯 **Addressing**: [target-agent or @all]

## [Comment Subject/Title]

[Main comment content organized in clear sections]

### [Section 1]
[Specific information, findings, or requests]

### [Section 2]
[Additional details, context, or next steps]

**Status**: [Current status - In Progress/Completed/Blocked/Pending Review]
**Next Action**: [What happens next or what's needed]
**Timeline**: [Expected completion or response time]

---
*[Optional footer with references or related links]*
```

### Required Sections

#### Comment Subject/Title
- **Purpose**: Clear summary of comment purpose
- **Format**: Descriptive H2 heading (`## Title`)
- **Examples**:
  - `## Authentication System Implementation Update`
  - `## API Documentation Review Complete`
  - `## Critical Bug Fix - Payment Processing`

#### Main Content Organization
- **Structure**: Use H3 headings for major sections
- **Clarity**: One topic per section
- **Actionability**: Clear next steps and requirements

#### Status Declaration
- **Format**: `**Status**: [status-value]`
- **Valid Values**: 
  - `In Progress` - Work actively underway
  - `Completed` - Task finished and delivered
  - `Blocked` - Cannot proceed, needs resolution
  - `Pending Review` - Awaiting feedback or approval
  - `On Hold` - Temporarily suspended
  - `Failed` - Task unsuccessful, requires new approach

#### Next Action Statement
- **Format**: `**Next Action**: [specific-action]`
- **Purpose**: Clear expectations for what happens next
- **Specificity**: Actionable, not vague
- **Examples**:
  - ✅ `**Next Action**: Await vibe-coder approval to proceed with database migration`
  - ✅ `**Next Action**: React-dev to review and test the new component API`
  - ❌ `**Next Action**: Continue working` (too vague)

#### Timeline Declaration
- **Format**: `**Timeline**: [time-expectation]`
- **Purpose**: Set clear expectations for completion
- **Examples**:
  - `**Timeline**: Implementation complete by end of day`
  - `**Timeline**: Review requested within 2 hours`
  - `**Timeline**: Blocked - no timeline until dependency resolved`

## Context Enhancement Comments for Complex Tasks

### When to Use Context Enhancement

For complex tasks created via `/start-session` that require extensive analysis, planning, or specific implementation guidance, the basic GitHub issue may not provide sufficient context. In these cases, **add a detailed context comment** immediately after issue creation.

### Context Enhancement Template

Use this specialized template when adding comprehensive context to support task handoffs:

```markdown
👤 **Identity**: [coordinating-agent] (coordinating agent)
🎯 **Addressing**: [receiving-agent]

## Complete Context Analysis

### Problem Statement
[Detailed explanation of the issue, requirement, or task complexity]

### Current State Analysis  
[What you've discovered about the current implementation, architecture, or situation]

### Implementation Requirements
[Specific technical requirements, constraints, dependencies, and considerations]

### Recommended Approach
[Your suggested implementation strategy, architecture decisions, or methodology]

### Key Files and Locations
[Specific files, functions, classes, and line numbers relevant to the task]
- `path/to/file.ext:line-number` - [description of relevance]
- `another/file.ext:function-name` - [what needs to be modified]

### Success Criteria  
[Detailed, measurable outcomes for task completion]
- [ ] [Specific completion requirement]
- [ ] [Testing requirement]
- [ ] [Documentation requirement]

### Implementation Guidance
[Step-by-step approach, gotchas to avoid, patterns to follow]

**Status**: Context provided - ready for implementation
**Next Action**: [receiving-agent] to begin implementation with provided context
**Timeline**: [expected timeline based on complexity]

---
*Context enhancement for complex task handoff - prevents re-discovery of analysis*
```

### Context Enhancement Guidelines

#### When Context Enhancement is Required
**✅ ADD CONTEXT ENHANCEMENT FOR:**
- Complex refactoring tasks spanning multiple files
- Feature implementation requiring architectural decisions  
- Bug fixes needing deep system understanding
- Tasks involving integration between multiple systems
- Documentation requiring technical analysis and discovery
- Tasks with non-obvious implementation approaches

**❌ BASIC TASKS (Standard Issue Sufficient):**
- Simple file updates or content changes
- Straightforward bug fixes with clear scope
- Standard documentation updates
- Well-defined feature requests with clear requirements

#### Context Enhancement Best Practices

##### 1. Comprehensive Analysis
- Include all discovered patterns, constraints, and requirements
- Reference specific code locations with file paths and line numbers
- Explain the reasoning behind recommended approaches
- Identify potential pitfalls or edge cases

##### 2. Clear Implementation Path
- Provide step-by-step guidance for complex tasks
- Include specific patterns or conventions to follow
- Reference similar implementations or examples in the codebase
- Explain any architectural decisions or trade-offs

##### 3. Measurable Success Criteria
- Define specific, testable completion requirements
- Include testing expectations and validation steps
- Specify documentation or communication requirements
- Set clear quality standards and acceptance criteria

#### Quick Commands for Context Enhancement

```bash
# Add context comment from file
gh issue comment [issue-number] --body-file /path/to/context.md

# Add context inline (for shorter contexts)
gh issue comment [issue-number] --body "👤 **Identity**: vibe-coder (coordinating)..."

# View issue to confirm context was added
gh issue view [issue-number] --comments
```

## Implementation Examples

### Example 1: Task Completion Report

```markdown
👤 **Identity**: laravel-dev
🎯 **Addressing**: vibe-coder

## Authentication System Implementation Complete

The JWT authentication system has been successfully implemented and tested.

### Implementation Details
- JWT token generation and validation
- User registration and login endpoints
- Password reset functionality
- Role-based access control middleware

### Testing Results
- Unit tests: 47/47 passing ✅
- Integration tests: 12/12 passing ✅
- Security tests: 8/8 passing ✅
- Performance tests: All endpoints <200ms response time ✅

### Files Modified
- `app/Http/Controllers/AuthController.php`
- `app/Models/User.php`
- `routes/api.php`
- `tests/Feature/AuthTest.php`
- `database/migrations/2025_08_14_create_auth_tables.php`

**Status**: Completed
**Next Action**: Await vibe-coder validation and approval for merge
**Timeline**: Ready for review immediately

---
*Related PR: #145 | Documentation: docs/authentication.md*
```

### Example 2: Cross-Agent Coordination Request

```markdown
👤 **Identity**: docs-orchestrator
🎯 **Addressing**: react-dev, laravel-dev

## API Documentation Sync Required

The API documentation needs updating to reflect recent backend changes before frontend integration.

### Backend Changes Requiring Documentation
- New authentication endpoints (laravel-dev implementation)
- Modified user profile data structure
- Additional error response codes

### Frontend Integration Dependencies
- React components need updated API interfaces
- TypeScript definitions require regeneration
- Integration tests need endpoint URL updates

### Coordination Plan
1. **laravel-dev**: Provide OpenAPI specification for new endpoints
2. **docs-orchestrator**: Update API documentation and examples
3. **react-dev**: Generate TypeScript interfaces from updated specs
4. **All**: Review and validate documentation accuracy

**Status**: Pending Review
**Next Action**: Laravel-dev to provide OpenAPI spec within 2 hours
**Timeline**: Documentation sync complete by end of day

---
*Blocking Issue: Frontend integration cannot proceed without accurate API docs*
```

### Example 3: Context Enhancement for Complex Task

```markdown
👤 **Identity**: vibe-coder (coordinating agent)
🎯 **Addressing**: react-dev

## Complete Context Analysis

### Problem Statement  
The desktop-project-instructions directory needs reorganization to improve navigation and reduce cognitive load. Current structure has lengthy single files that mix multiple concepts, making it difficult for agents to find specific guidance.

### Current State Analysis
- README.md contains 240+ lines mixing quick start, setup, troubleshooting, and advanced usage
- Natural language patterns scattered across multiple sections
- Agent management guidance buried in comprehensive overview
- No clear separation between basic and advanced usage patterns

### Implementation Requirements
- Maintain all existing functionality and guidance
- Preserve all natural language patterns and examples  
- Keep cross-references working and comprehensive
- Ensure mobile-friendly documentation structure
- Follow existing micro-docs navigation pattern

### Recommended Approach
1. **Extract Quick Start Guide** - Pull essential `/start-session` patterns into standalone file
2. **Separate Troubleshooting** - Create dedicated troubleshooting.md with all error scenarios
3. **Reorganize Natural Language** - Focus natural-language-patterns.md on intent recognition only
4. **Create Advanced Usage** - Move complex scenarios and edge cases to advanced-usage.md
5. **Update Navigation** - Ensure all files have proper cross-links and breadcrumbs

### Key Files and Locations
- `agentic-development/desktop-project-instructions/README.md:1-240` - Main restructuring target  
- `agentic-development/desktop-project-instructions/natural-language-patterns.md:15-45` - Intent patterns to preserve
- `agentic-development/desktop-project-instructions/agent-management.md:1-30` - Cross-reference dependencies
- Navigation links at lines 167-194 need updating for new structure

### Success Criteria
- [ ] README.md under 100 lines focused on essential quick start
- [ ] All troubleshooting content in dedicated troubleshooting.md
- [ ] Natural language patterns focused and concise
- [ ] All cross-references working correctly
- [ ] No functionality or examples lost in reorganization
- [ ] Mobile navigation improved with shorter page loads

### Implementation Guidance
1. Start by extracting troubleshooting section (lines 129-157) to new file
2. Move advanced scenarios (lines 188-225) to advanced-usage.md
3. Preserve all MCP command examples and ensure they're easily discoverable
4. Test all navigation links after reorganization
5. Follow the existing micro-docs pattern with clear breadcrumb navigation

**Status**: Context provided - ready for implementation  
**Next Action**: react-dev to begin restructuring with provided analysis and file locations
**Timeline**: Reorganization complete within this session

---
*Context enhancement for complex task handoff - prevents re-discovery of analysis*
```

### Example 4: Emergency Escalation

```markdown
👤 **Identity**: devops
🎯 **Addressing**: @all

## URGENT: Production Deployment Pipeline Failure

Critical issue detected in production deployment pipeline affecting all development workflows.

### Issue Description
- Build pipeline failing on main branch merges
- Docker image builds timeout after 30 minutes
- Production deployments blocked since 14:30 UTC

### Impact Assessment
- **Severity**: Critical - Production deployments blocked
- **Affected Systems**: Main branch merges, production releases
- **Affected Agents**: All agents with pending merges
- **Estimated Downtime**: 2-4 hours for full resolution

### Immediate Actions Taken
1. Rollback to last known good deployment configuration
2. Isolated failing pipeline stage (Docker image optimization)
3. Activated backup deployment process for critical fixes

### Required Support
- **All agents**: Hold all merge requests until pipeline restored
- **Security team**: Review pipeline configuration changes
- **Infrastructure team**: Emergency resource allocation approved

**Status**: In Progress - Emergency Response Active
**Next Action**: Infrastructure team investigating root cause
**Timeline**: Resolution target: 17:00 UTC (2.5 hours)

---
*Emergency Tracking: INC-2025-0814-001 | Status Page: status.tuvens.dev*
```

## Violation Detection and Correction

### Common Violations

#### Missing Identity Header
**Violation**: Comment without required identity declaration

```markdown
We should probably update the documentation for this feature.
```

**Correction Required**:
```markdown
👤 **Identity**: docs-orchestrator
🎯 **Addressing**: @all

## Documentation Update Required

We should update the documentation for this feature to include the new functionality.

**Status**: Pending Review  
**Next Action**: Identify specific documentation sections to update
**Timeline**: Update plan ready within 1 hour
```

#### Incorrect Format
**Violation**: Wrong emoji or formatting

```markdown
Identity: vibe-coder
Addressing: laravel-dev

The authentication system looks good.
```

**Correction Required**:
```markdown
👤 **Identity**: vibe-coder
🎯 **Addressing**: laravel-dev

## Authentication System Validation

The authentication system implementation looks good and meets requirements.

**Status**: Completed  
**Next Action**: Approved for merge to dev branch
**Timeline**: Immediate
```

#### Unregistered Agent
**Violation**: Using invalid agent name

```markdown
👤 **Identity**: unknown-bot
🎯 **Addressing**: @all

Task completion report ready.
```

**Correction Required**: Must use valid registered agent name from the approved list.

#### Missing Addressing
**Violation**: No addressing declaration

```markdown
👤 **Identity**: react-dev

The component is ready for testing.
```

**Correction Required**:
```markdown
👤 **Identity**: react-dev
🎯 **Addressing**: @all

## Component Testing Ready

The user profile component is ready for testing and integration.

**Status**: Completed  
**Next Action**: Request testing from QA team
**Timeline**: Testing can begin immediately
```

### Automated Compliance Monitoring

#### Detection Triggers
- GitHub webhook on comment creation
- Real-time format validation
- Agent name verification against registry
- Structure completeness check

#### Violation Response Procedure
1. **Immediate Detection**: Automated system flags non-compliant comments
2. **Notification**: Agent receives correction request within 1 minute  
3. **Grace Period**: 10 minutes to correct formatting
4. **Escalation**: Repeat violations escalate to vibe-coder review
5. **Pattern Tracking**: Persistent violations trigger training requirements

#### Correction Request Template
```markdown
👤 **Identity**: system-monitor
🎯 **Addressing**: [violating-agent]

## Comment Format Compliance Required

Your recent comment does not meet GitHub Comment Standards Protocol requirements.

### Issues Detected
- [ ] Missing identity header
- [ ] Missing addressing declaration  
- [ ] Incorrect format (emoji/formatting)
- [ ] Unregistered agent name
- [ ] Missing required sections

### Required Action
Please edit your comment to include the proper format:

```
👤 **Identity**: [your-agent-name]
🎯 **Addressing**: [target-agent or @all]

## [Your Comment Subject]
[Your comment content]

**Status**: [status]
**Next Action**: [next-action]
**Timeline**: [timeline]
```

**Compliance Deadline**: 10 minutes from this notification
**Escalation**: Repeat violations will be escalated to vibe-coder review

---
*Automated compliance monitoring - GitHub Comment Standards Protocol*
```

## Integration with Other Protocols

### Agent Check-in Validation
- All check-in responses use GitHub comment standards format
- Vibe-coder authorization responses follow template structure
- Violation escalations reference both protocols

### File Scope Management
- File conflict resolution comments use standard format
- Resource reservation notifications follow addressing rules
- Coordination requests include proper agent targeting

### Emergency Response Procedures  
- Emergency alerts use standard identity and addressing format
- Escalation notifications follow template structure
- Status updates maintain consistent formatting

## Success Metrics

### Compliance Targets
- **Format Compliance**: 95% of comments use proper format
- **Identity Accuracy**: 100% valid agent names used
- **Addressing Clarity**: 90% appropriate targeting
- **Response Time**: Violations detected within 1 minute

### Quality Indicators
- **Communication Clarity**: Reduced confusion in agent interactions
- **Faster Issue Resolution**: Improved coordination and response times
- **Better Accountability**: Clear tracking of agent communications
- **Reduced Errors**: Fewer miscommunications and wrong assumptions

### Monitoring Metrics
- **Comments per Day**: Track volume and participation
- **Violation Rate**: Monitor compliance trends
- **Correction Time**: Speed of compliance when violations occur
- **Agent Participation**: Engagement levels across different agents

## Implementation Checklist

### For All Agents
- [ ] Memorize required comment format
- [ ] Understand valid agent names and addressing options
- [ ] Know violation detection and correction procedures
- [ ] Practice using complete comment template

### For System Monitors
- [ ] Implement automated compliance detection
- [ ] Set up violation notification system
- [ ] Create compliance reporting dashboard
- [ ] Establish escalation procedures

### For Vibe Coder (System Orchestrator)
- [ ] Monitor overall compliance rates
- [ ] Review escalated violations
- [ ] Update agent training when needed
- [ ] Approve new agent registrations

## Troubleshooting

### Common Format Issues

#### Emoji Display Problems
**Issue**: Emojis not displaying correctly
**Solution**: Ensure UTF-8 encoding in all systems
**Prevention**: Test emoji display in GitHub interface

#### Copy-Paste Formatting Loss
**Issue**: Template formatting lost when copying
**Solution**: Use raw markdown view for copying
**Prevention**: Provide downloadable templates

#### Mobile Interface Challenges
**Issue**: Format harder to maintain on mobile GitHub
**Solution**: Use mobile-friendly templates
**Prevention**: Simplified format for mobile users

### Addressing Problems

#### Unknown Agent Names
**Issue**: Not sure which agent to address
**Solution**: Check `.claude/agents/` directory for valid names
**Prevention**: Maintain updated agent registry documentation

#### Multiple Target Confusion
**Issue**: Unclear how to address multiple agents
**Solution**: Use comma-separated list: `agent1, agent2, agent3`
**Prevention**: Provide clear examples in documentation

#### Broadcast vs. Specific
**Issue**: Unclear when to use @all vs. specific agent
**Solution**: Use @all for general announcements, specific for direct communication
**Prevention**: Decision flowchart in documentation

---

*This protocol ensures clear, consistent, and accountable communication across all agents in the Vibe Coder Agent Orchestration System. Compliance is mandatory for all GitHub interactions.*