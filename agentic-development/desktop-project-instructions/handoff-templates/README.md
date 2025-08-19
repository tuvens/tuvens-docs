# Desktop Project Handoff Templates

This directory contains standardized templates for transitioning development tasks from Claude Desktop analysis to Claude Code implementation, ensuring smooth handoffs between planning and execution phases.

## Template Types

### 📝 Task Complexity Templates
- **`simple-task.md`** - Single file changes, quick fixes, minor updates
- **`complex-feature.md`** - Multi-file features, architectural changes, new systems
- **`refactoring.md`** - Code restructuring, optimization, technical debt reduction
- **`debugging.md`** - Bug investigation, issue diagnosis, problem resolution

## Use Cases

### For Claude Desktop Users
- **Task Analysis**: Understand project structure and requirements before handoff
- **Scope Assessment**: Determine appropriate template based on task complexity
- **Context Preparation**: Gather necessary information for effective handoff
- **Agent Selection**: Choose the right specialist agent for the task

### For Claude Code Sessions
- **Quick Startup**: Get immediate context and direction for implementation
- **Focused Execution**: Clear understanding of what needs to be accomplished
- **Proper Tooling**: Leverage Claude Code's file manipulation and execution capabilities
- **Quality Assurance**: Follow established patterns for testing and verification

### For Project Managers
- **Task Planning**: Standardize how development work is scoped and handed off
- **Resource Allocation**: Match task complexity with appropriate development resources
- **Progress Tracking**: Clear handoff points for monitoring project advancement
- **Quality Control**: Ensure consistent approach to different types of development work

## Agent Selection Guide

### Recommended Agents by Task Type

#### **Simple Tasks** - Quick, focused changes
- **vibe-coder**: Documentation updates, README changes, content modifications
- **devops**: Configuration changes, deployment scripts, infrastructure updates  
- **node-dev**: Backend API fixes, server-side bug fixes, database script updates
- **react-dev**: Frontend component fixes, UI updates, styling changes

#### **Complex Features** - Multi-component development
- **laravel-dev**: Backend feature development, API design, database architecture
- **react-dev**: Frontend application features, component systems, state management
- **node-dev**: Microservice development, API integration, server architecture
- **devops**: Infrastructure features, deployment pipelines, monitoring systems

#### **Refactoring Projects** - Code improvement and optimization
- **Specialist agents** matching the technology stack being refactored
- **vibe-coder**: Documentation and architectural documentation updates
- **devops**: Infrastructure optimization and deployment improvements

#### **Debugging Tasks** - Problem investigation and resolution
- **Specialist agents** familiar with the problematic technology stack
- **Any agent** with strong analytical capabilities for complex debugging
- **devops**: Infrastructure and deployment-related issues

## Template Selection Guide

### Use `simple-task.md` when:
- ✅ Task affects 1-2 files maximum
- ✅ Clear before/after state
- ✅ No complex dependencies
- ✅ Can be tested quickly
- ✅ No architectural changes needed

### Use `complex-feature.md` when:
- ✅ Multiple files and components involved
- ✅ New functionality or significant changes
- ✅ Requires planning and architecture decisions
- ✅ Integration testing needed
- ✅ May affect multiple system parts

### Use `refactoring.md` when:
- ✅ Code structure improvements needed
- ✅ Performance optimization required
- ✅ Technical debt reduction
- ✅ Code organization improvements
- ✅ No new functionality, just improvement

### Use `debugging.md` when:
- ✅ Problem diagnosis needed
- ✅ Bug reproduction required
- ✅ Root cause analysis necessary
- ✅ Multiple potential causes exist
- ✅ Investigation before solution

## Handoff Process

### From Claude Desktop
1. **Analyze the project** using Claude Desktop's analytical capabilities
2. **Assess task complexity** using the selection guide above
3. **Choose appropriate template** based on task characteristics
4. **Gather context** including file paths, current issues, and desired outcomes
5. **Prepare handoff** with specific details for the chosen template

### To Claude Code
1. **Start Claude Code session** in the appropriate repository
2. **Load agent configuration** using the selected specialist agent
3. **Use template format** to provide clear, structured task description
4. **Include all context** from the desktop analysis phase
5. **Specify testing requirements** and success criteria

### Example Handoff Flow
```markdown
# Desktop Analysis (Claude Desktop)
- Identified issue in user authentication
- Problem: Users can't log in with valid credentials
- Affected files: auth.js, user.model.js
- Error: Database connection timeout

# Handoff (Claude Code)
Load: .claude/agents/node-dev.md

Simple task: Fix user authentication timeout issue
File: backend/auth.js, backend/models/user.model.js
Issue: Database queries timing out during login
Fix: Optimize database connection pooling and query timeout settings
```

## Best Practices

### For Effective Handoffs
- **Be specific**: Include exact file paths and line numbers when possible
- **Provide context**: Explain why the change is needed
- **Define success**: Clear criteria for when the task is complete
- **Include testing**: Specify how to verify the solution works
- **Set boundaries**: Clearly scope what should and shouldn't be changed

### For Template Usage
- **Match complexity**: Use the right template for the task size
- **Include examples**: Provide concrete examples when possible
- **Update templates**: Improve templates based on handoff experience
- **Document patterns**: Note successful handoff patterns for reuse

## Quality Assurance

### Pre-Handoff Checklist
- [ ] Task complexity properly assessed
- [ ] Appropriate template selected
- [ ] All necessary context gathered
- [ ] Target agent identified
- [ ] Success criteria defined
- [ ] Testing approach specified

### Post-Handoff Validation
- [ ] Task completed as specified
- [ ] Solution tested and verified
- [ ] Code quality maintained
- [ ] Documentation updated if needed
- [ ] Handoff process effectiveness reviewed