# Agent Check-in Validation Protocol

**Protocol**: Agent Identity Declaration and Authorization Process  
**Version**: 1.0  
**Created**: 2025-08-14  
**Phase**: 2 Implementation  

## Overview

The Agent Check-in Validation Protocol establishes the mandatory identity declaration and authorization process that all agents must complete before beginning work. This protocol transforms the theoretical framework from Phase 1 into practical, testable procedures with validation scenarios and success metrics.

## Core Requirements

### Mandatory Agent Check-in Process

Before ANY agent begins work, they MUST complete this identity declaration:

```markdown
## Agent Identity Declaration (REQUIRED)

**Agent Identity**: I am [agent-name] 
**Target Task**: [specific-task-description]
**Repository**: [repo-name]
**Current Location**: [output of `pwd`]
**Current Branch**: [output of `git branch --show-current`]
**File Scope**: Working on files: [specific-file-list]

**BRANCH SAFETY CHECK**:
```bash
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == "dev" ]] || [[ "$BRANCH" == "main" ]] || [[ "$BRANCH" == "stage" ]] || [[ "$BRANCH" == "test" ]]; then
    echo "❌ CRITICAL ERROR: Cannot work on protected branch: $BRANCH"
    echo "SOLUTION: Create feature branch: git checkout -b {agent}/{type}/{description}"
    exit 1
fi
echo "✅ Safe to proceed on branch: $BRANCH"
```

**Awaiting Vibe Coder Approval**: [REQUIRED RESPONSE]
```

### Required Fields Validation

#### Agent Identity
- **Format**: "I am [agent-name]"
- **Valid Agents**: vibe-coder, docs-orchestrator, devops, laravel-dev, react-dev, python-dev
- **Validation**: Must match registered agent names in `.claude/agents/` directory

#### Target Task
- **Format**: Clear, specific task description
- **Requirements**: Must be actionable and measurable
- **Examples**: 
  - ✅ "Implement user authentication system for Laravel API"
  - ✅ "Fix CSS styling issues in product catalog component"
  - ❌ "Work on stuff" (too vague)
  - ❌ "General improvements" (not specific)

#### Repository
- **Format**: Repository name (e.g., "tuvens-docs", "frontend-app")
- **Validation**: Must match actual repository structure
- **Verification**: Cross-reference with git remote origin

#### Current Location
- **Format**: Full output of `pwd` command
- **Validation**: Must be within project boundaries
- **Security**: Prevents work outside authorized directories

#### Current Branch
- **Format**: Output of `git branch --show-current`
- **Validation**: Must follow branch naming convention: `{agent}/{type}/{description}`
- **Safety**: Automatic rejection if on protected branches (main, stage, test, dev)

#### File Scope
- **Format**: "Working on files: [specific-file-list]"
- **Requirements**: Specific file paths or pattern descriptions
- **Conflict Prevention**: Used for resource conflict detection

### Branch Safety Validation

The branch safety check is a critical security component:

```bash
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == "dev" ]] || [[ "$BRANCH" == "main" ]] || [[ "$BRANCH" == "stage" ]] || [[ "$BRANCH" == "test" ]]; then
    echo "❌ CRITICAL ERROR: Cannot work on protected branch: $BRANCH"
    echo "SOLUTION: Create feature branch: git checkout -b {agent}/{type}/{description}"
    exit 1
fi
echo "✅ Safe to proceed on branch: $BRANCH"
```

#### Protected Branches
- `main` - Production release branch
- `stage` - Staging/pre-production branch  
- `test` - Testing integration branch
- `dev` - Development integration branch

#### Valid Branch Patterns
- `vibe-coder/feature/protocol-implementation`
- `docs-orchestrator/docs/api-reference-update`
- `devops/workflow/ci-pipeline-fix`
- `laravel-dev/feature/authentication-system`
- `react-dev/bugfix/component-rendering`

## Vibe Coder Response Protocol

When agents check in, the Vibe Coder (System Orchestrator) responds with:

```markdown
👤 **Identity**: vibe-coder
🎯 **Addressing**: [agent-name]

## Vibe Coder Validation Response

**Agent**: [agent-name] - Identity Verified ✅
**Workspace**: [location] - Location Validated ✅  
**Branch Safety**: [branch-name] - Safe Branch Confirmed ✅
**File Scope**: [file-list] - No Conflicts Detected ✅

**AUTHORIZATION**: Proceed with [specific-task-scope]

**SESSION ACTIVE**: [timestamp] - Agent authorized to begin work
```

### Response Field Validation

#### Identity Verification
- Cross-reference agent name with registered agents
- Verify agent has appropriate permissions for task type
- Check for suspended or restricted agent status

#### Location Validation
- Confirm working directory is within project boundaries
- Verify access permissions to specified location
- Check for required dependencies and tools

#### Branch Safety Confirmation
- Validate branch naming convention compliance
- Confirm branch is not protected
- Verify branch creation follows git flow standards

#### File Scope Conflict Detection
- Check for overlapping file reservations
- Identify potential resource conflicts with other active sessions
- Validate file access permissions

## Testing Scenarios

### Valid Check-in Examples

#### Example 1: Feature Development
```markdown
## Agent Identity Declaration (REQUIRED)

**Agent Identity**: I am laravel-dev
**Target Task**: Implement user authentication system with JWT tokens
**Repository**: backend-api
**Current Location**: /home/user/projects/backend-api
**Current Branch**: laravel-dev/feature/jwt-authentication
**File Scope**: Working on files: app/Http/Controllers/AuthController.php, routes/api.php, tests/Feature/AuthTest.php

**BRANCH SAFETY CHECK**:
✅ Safe to proceed on branch: laravel-dev/feature/jwt-authentication

**Awaiting Vibe Coder Approval**: [REQUIRED RESPONSE]
```

#### Example 2: Bug Fix
```markdown
## Agent Identity Declaration (REQUIRED)

**Agent Identity**: I am react-dev
**Target Task**: Fix product catalog pagination component rendering issue
**Repository**: frontend-app
**Current Location**: /home/user/projects/frontend-app
**Current Branch**: react-dev/bugfix/pagination-rendering
**File Scope**: Working on files: src/components/ProductCatalog.tsx, src/hooks/usePagination.ts

**BRANCH SAFETY CHECK**:
✅ Safe to proceed on branch: react-dev/bugfix/pagination-rendering

**Awaiting Vibe Coder Approval**: [REQUIRED RESPONSE]
```

### Violation Detection Examples

#### Example 1: Protected Branch Violation
```markdown
## Agent Identity Declaration (REQUIRED)

**Agent Identity**: I am docs-orchestrator
**Target Task**: Update API documentation
**Repository**: tuvens-docs
**Current Location**: /home/user/projects/tuvens-docs
**Current Branch**: main
**File Scope**: Working on files: api/README.md

**BRANCH SAFETY CHECK**:
❌ CRITICAL ERROR: Cannot work on protected branch: main
SOLUTION: Create feature branch: git checkout -b docs-orchestrator/docs/api-update
```

**Vibe Coder Response**:
```markdown
👤 **Identity**: vibe-coder
🎯 **Addressing**: docs-orchestrator

## Vibe Coder Validation Response

**AUTHORIZATION DENIED**: Protected branch violation detected

**REQUIRED ACTION**: 
1. Create proper feature branch: `git checkout -b docs-orchestrator/docs/api-update`
2. Re-submit check-in with valid branch
3. Ensure all future work follows branch naming conventions

**SESSION STATUS**: Suspended pending compliance
```

#### Example 2: Invalid Agent Name
```markdown
## Agent Identity Declaration (REQUIRED)

**Agent Identity**: I am unknown-agent
**Target Task**: Fix database issues
**Repository**: backend-api
**Current Location**: /home/user/projects/backend-api
**Current Branch**: unknown-agent/bugfix/database-fix
**File Scope**: Working on files: database/migrations/

**BRANCH SAFETY CHECK**:
✅ Safe to proceed on branch: unknown-agent/bugfix/database-fix

**Awaiting Vibe Coder Approval**: [REQUIRED RESPONSE]
```

**Vibe Coder Response**:
```markdown
👤 **Identity**: vibe-coder
🎯 **Addressing**: unknown-agent

## Vibe Coder Validation Response

**AUTHORIZATION DENIED**: Unregistered agent identity

**REGISTERED AGENTS**: vibe-coder, docs-orchestrator, devops, laravel-dev, react-dev, python-dev

**REQUIRED ACTION**: 
1. Use valid agent identity from registered list
2. If new agent needed, register in `.claude/agents/` directory first
3. Re-submit check-in with valid agent name

**SESSION STATUS**: Suspended pending compliance
```

#### Example 3: Vague Task Description
```markdown
## Agent Identity Declaration (REQUIRED)

**Agent Identity**: I am python-dev
**Target Task**: General improvements
**Repository**: ml-pipeline
**Current Location**: /home/user/projects/ml-pipeline
**Current Branch**: python-dev/feature/improvements
**File Scope**: Working on files: various

**BRANCH SAFETY CHECK**:
✅ Safe to proceed on branch: python-dev/feature/improvements

**Awaiting Vibe Coder Approval**: [REQUIRED RESPONSE]
```

**Vibe Coder Response**:
```markdown
👤 **Identity**: vibe-coder
🎯 **Addressing**: python-dev

## Vibe Coder Validation Response

**AUTHORIZATION DENIED**: Insufficient task specification

**ISSUES IDENTIFIED**:
- Task description too vague: "General improvements"
- File scope unclear: "various"

**REQUIRED ACTION**: 
1. Provide specific, actionable task description
2. Define clear file scope with specific file paths
3. Re-submit check-in with detailed information

**SESSION STATUS**: Suspended pending compliance
```

## Violation Response Procedures

### Level 1: Minor Violations (Immediate Correction)
- Missing required field
- Formatting inconsistencies
- Minor task description clarity issues

**Response Time**: Immediate  
**Action**: Request correction and re-submission  
**Escalation**: None required  

### Level 2: Moderate Violations (Work Suspension)
- Invalid agent identity
- Protected branch usage
- Unauthorized directory access

**Response Time**: Within 1 minute  
**Action**: Suspend session, require compliance  
**Escalation**: Log violation, monitor for patterns  

### Level 3: Severe Violations (System Lockdown)
- Security boundary violations
- Malicious file access attempts
- Repeated non-compliance after corrections

**Response Time**: Immediate  
**Action**: Lock agent access, require manual review  
**Escalation**: Emergency response team notification  

### Level 4: Critical Violations (Emergency Response)
- Attempted system compromise
- Unauthorized remote access
- Critical infrastructure threats

**Response Time**: Immediate  
**Action**: Full system lockdown, emergency protocols  
**Escalation**: Immediate security team alert  

## Success Metrics

### Compliance Targets
- **Check-in Completion Rate**: 95% of agents complete valid check-in
- **First-time Validation Rate**: 85% pass validation on first attempt
- **Response Time**: Vibe Coder responds within 30 seconds
- **Violation Detection**: 100% of violations caught and flagged

### Quality Indicators
- **Clear Task Definitions**: 90% of tasks are specific and actionable
- **Proper Branch Usage**: 95% compliance with branch naming conventions
- **File Scope Accuracy**: 90% of file scope declarations are precise
- **Security Compliance**: 100% prevention of protected branch work

## Integration Requirements

### Phase 1 Foundation
This protocol implements the agent coordination framework established in Phase 1:
- Enhanced vibe-coder identity with System Orchestrator role
- Mandatory agent identity declaration process
- Work validation authority and delegation framework

### Phase 3 Automation Preparation
Manual procedures validated and ready for automation:
- Script-based agent authorization systems
- Automated branch safety validation
- Real-time compliance monitoring
- Emergency alert and response automation

### Cross-Protocol Dependencies
- **GitHub Comment Standards**: All responses use universal comment format
- **File Scope Management**: Check-in file scope used for conflict detection
- **Emergency Response**: Violation levels trigger appropriate emergency procedures

## Implementation Checklist

### For Agents
- [ ] Understand mandatory check-in format
- [ ] Know all required fields and validation rules
- [ ] Have branch safety check script ready
- [ ] Understand violation response procedures

### For Vibe Coder (System Orchestrator)
- [ ] Master response template format
- [ ] Know validation criteria for each field
- [ ] Understand violation levels and response procedures
- [ ] Have emergency escalation procedures ready

### For System Integration
- [ ] Agent registry maintained in `.claude/agents/`
- [ ] Branch naming conventions documented
- [ ] Protected branch list maintained
- [ ] Violation logging system active

## Troubleshooting

### Common Check-in Problems

#### Missing Required Fields
**Issue**: Agent submits incomplete check-in  
**Solution**: Request completion of all mandatory fields  
**Prevention**: Provide check-in template to all agents  

#### Invalid Branch Names
**Issue**: Branch doesn't follow naming convention  
**Solution**: Guide agent to create proper branch name  
**Prevention**: Automated branch name validation  

#### Unclear Task Descriptions
**Issue**: Task description too vague or broad  
**Solution**: Request specific, actionable task definition  
**Prevention**: Provide task description examples  

#### File Scope Conflicts
**Issue**: Multiple agents working on same files  
**Solution**: Coordinate with File Scope Management protocol  
**Prevention**: Real-time conflict detection system  

### Response Template Issues

#### Delayed Responses
**Issue**: Vibe Coder response takes too long  
**Target**: <30 seconds response time  
**Solution**: Streamline validation process  

#### Inconsistent Formatting
**Issue**: Response format varies between sessions  
**Solution**: Use standard response template  
**Prevention**: Template validation system  

#### Missing Validation Steps
**Issue**: Some checks skipped in validation  
**Solution**: Complete validation checklist for each response  
**Prevention**: Automated validation workflow  

---

*This protocol provides the foundation for agent coordination and system security in the Vibe Coder Agent Orchestration System. All agents must comply with this check-in process before beginning work.*