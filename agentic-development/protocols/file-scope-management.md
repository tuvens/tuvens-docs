# File Scope Management Protocol

**Protocol**: Resource Conflict Prevention and Coordination System  
**Version**: 1.0  
**Created**: 2025-08-14  
**Phase**: 2 Implementation  

## Overview

The File Scope Management Protocol establishes a comprehensive system for preventing resource conflicts and coordinating file access across multiple agents. This protocol transforms theoretical resource management concepts into practical, testable procedures with conflict detection, resolution mechanisms, and performance metrics.

## Core Principles

### Resource Conflict Prevention
- **Proactive Declaration**: Agents declare file scope before beginning work
- **Conflict Detection**: Automated detection of overlapping file access
- **Resolution Framework**: Structured procedures for conflict resolution
- **Performance Optimization**: Minimize delays through effective coordination

### Coordination Framework
- **Reservation System**: File and directory reservation tracking
- **Session Management**: Time-bounded resource access
- **Priority Handling**: Critical task prioritization and escalation
- **Timeline Coordination**: Sequential and parallel work planning

## File Scope Declaration Requirements

### Mandatory Scope Declaration

All agents must declare their file scope during check-in using this format:

```markdown
**File Scope**: Working on files: [specific-file-list-or-pattern]
```

### Scope Declaration Types

#### 1. Specific File Lists
```markdown
**File Scope**: Working on files: src/components/UserAuth.tsx, src/hooks/useAuth.ts, tests/auth.test.ts
```

#### 2. Directory Patterns
```markdown
**File Scope**: Working on files: src/components/* (excluding src/components/shared/)
```

#### 3. File Type Patterns
```markdown
**File Scope**: Working on files: **/*.md in docs/ directory
```

#### 4. Combined Scope
```markdown
**File Scope**: Working on files: 
- API: app/Http/Controllers/AuthController.php, routes/api.php
- Tests: tests/Feature/AuthTest.php, tests/Unit/UserTest.php  
- Docs: docs/authentication.md
```

### Scope Validation Rules

#### Specificity Requirements
- **Minimum Specificity**: Must identify specific files or bounded patterns
- **Pattern Limits**: Wildcard patterns must include directory boundaries
- **Exclusion Support**: Can exclude specific files from broader patterns
- **Documentation Required**: Complex patterns must include explanation

**Valid Examples**:
- ✅ `src/components/UserProfile.tsx`
- ✅ `database/migrations/2025_08_*.php`
- ✅ `docs/**/*.md (user documentation only)`
- ✅ `app/Models/* (excluding shared traits)`

**Invalid Examples**:
- ❌ `various` (too vague)
- ❌ `**/*` (too broad)
- ❌ `some files` (not specific)
- ❌ `working on stuff` (not actionable)

## Conflict Detection System

### Conflict Types

#### 1. Direct File Conflicts
**Definition**: Multiple agents requesting access to identical file paths

**Example**:
- Agent A: `src/components/UserAuth.tsx`
- Agent B: `src/components/UserAuth.tsx`
- **Result**: Direct conflict detected

#### 2. Directory Overlap Conflicts  
**Definition**: Overlapping directory patterns that could affect same files

**Example**:
- Agent A: `src/components/*`
- Agent B: `src/components/auth/*`
- **Result**: Overlap conflict detected

#### 3. Pattern Intersection Conflicts
**Definition**: Different patterns that resolve to overlapping file sets

**Example**:
- Agent A: `**/*.test.ts`
- Agent B: `src/components/UserAuth.test.ts`
- **Result**: Pattern intersection detected

#### 4. Timeline Conflicts
**Definition**: Sequential work dependencies creating scheduling conflicts

**Example**:
- Agent A: Database migration (must complete before Agent B)
- Agent B: Model updates depending on migration
- **Result**: Timeline dependency conflict

### Automated Conflict Detection

#### Detection Algorithm
```python
def detect_conflicts(new_scope, active_sessions):
    conflicts = []
    
    for session in active_sessions:
        # Direct file conflicts
        direct_conflicts = set(new_scope.files) & set(session.files)
        if direct_conflicts:
            conflicts.append(DirectConflict(session, direct_conflicts))
        
        # Directory overlap conflicts
        for new_pattern in new_scope.patterns:
            for existing_pattern in session.patterns:
                if patterns_overlap(new_pattern, existing_pattern):
                    conflicts.append(OverlapConflict(session, new_pattern, existing_pattern))
        
        # Timeline conflicts
        if has_dependency(new_scope, session.scope):
            conflicts.append(TimelineConflict(session, dependency_type))
    
    return conflicts
```

#### Real-time Monitoring
- **Session Tracking**: Active agent sessions and their file reservations
- **Pattern Matching**: Real-time evaluation of scope overlap
- **Dependency Analysis**: Timeline and task dependency detection
- **Performance Metrics**: Conflict detection latency and accuracy

## Conflict Resolution Procedures

### Resolution Priority Matrix

| Conflict Type | Resolution Time | Priority Level | Escalation |
|---------------|----------------|----------------|------------|
| Direct File | Immediate | Critical | Auto-escalate |
| Directory Overlap | 5 minutes | High | Manual review |
| Pattern Intersection | 10 minutes | Medium | Coordination |
| Timeline | 15 minutes | Low | Planning |

### Resolution Strategies

#### 1. Sequential Coordination
**Used For**: Direct file conflicts  
**Process**: Agents work in sequence on same files

```markdown
**Resolution**: Sequential Coordination
**Agent Order**: laravel-dev → react-dev → docs-orchestrator
**Estimated Completion**: 
- laravel-dev: 2 hours (API implementation)
- react-dev: 1.5 hours (component integration)  
- docs-orchestrator: 30 minutes (documentation update)
**Total Timeline**: 4 hours
```

#### 2. Scope Adjustment
**Used For**: Directory overlap conflicts  
**Process**: Modify scope boundaries to eliminate overlap

```markdown
**Resolution**: Scope Adjustment
**Original Scopes**:
- Agent A: src/components/*
- Agent B: src/components/auth/*

**Adjusted Scopes**:
- Agent A: src/components/* (excluding auth/)
- Agent B: src/components/auth/*
**Timeline**: Work can proceed immediately in parallel
```

#### 3. File Subdivision
**Used For**: Large file conflicts  
**Process**: Split large files into smaller, manageable pieces

```markdown
**Resolution**: File Subdivision
**Conflict**: Both agents need to modify large config file
**Solution**: 
1. Split config.js into:
   - config/database.js (Agent A)
   - config/authentication.js (Agent B)
   - config/core.js (shared, Agent A handles)
2. Update imports across codebase
3. Proceed with parallel development
```

#### 4. Feature Branching
**Used For**: Complex multi-agent features  
**Process**: Create separate feature branches with planned merge strategy

```markdown
**Resolution**: Feature Branching
**Main Feature**: User authentication system
**Branch Strategy**:
- laravel-dev/feature/auth-backend (API implementation)
- react-dev/feature/auth-frontend (UI components)
- docs-orchestrator/feature/auth-docs (documentation)
**Merge Order**: backend → frontend → docs → dev branch
**Coordination**: Daily sync meetings at 9 AM UTC
```

### Resolution Templates

#### Direct File Conflict Resolution
```markdown
👤 **Identity**: vibe-coder
🎯 **Addressing**: [agent-1], [agent-2]

## File Conflict Resolution Required

**Conflict Detected**: Direct file access conflict
**Affected File(s)**: [file-list]
**Agents Involved**: [agent-list]

### Resolution Strategy: [strategy-name]

**Implementation Plan**:
1. [Step 1 with responsible agent]
2. [Step 2 with responsible agent]
3. [Step 3 with responsible agent]

**Timeline**:
- [Agent 1]: [estimated-time]
- [Agent 2]: [estimated-time]
- **Total**: [total-time]

### Coordination Requirements
- **Communication**: [sync-requirements]
- **Dependencies**: [dependency-list]
- **Checkpoints**: [milestone-list]

**Status**: Pending Agent Acknowledgment
**Next Action**: Both agents confirm resolution plan within 15 minutes
**Escalation**: Auto-escalate if no response in 15 minutes

---
*Conflict ID: CFT-2025-0814-001 | Auto-generated conflict resolution*
```

#### Scope Adjustment Template
```markdown
👤 **Identity**: vibe-coder
🎯 **Addressing**: [affected-agents]

## Scope Adjustment Required

**Conflict Type**: Directory/Pattern Overlap
**Original Scopes**:
- [Agent 1]: [original-scope-1]
- [Agent 2]: [original-scope-2]

### Proposed Adjustment

**New Scopes**:
- [Agent 1]: [adjusted-scope-1]
- [Agent 2]: [adjusted-scope-2]

**Benefits**:
- Eliminates overlap conflicts
- Allows parallel work
- Maintains task boundaries
- No timeline impact

### Implementation
1. **[Agent 1]**: Update file scope declaration to reflect new boundaries
2. **[Agent 2]**: Confirm scope adjustment and proceed with work
3. **System**: Update conflict tracking with resolved status

**Status**: Proposed Resolution
**Next Action**: Agent confirmation required within 10 minutes
**Timeline**: No delay - work can proceed immediately upon confirmation

---
*Conflict ID: CFT-2025-0814-002 | Scope adjustment resolution*
```

## Session Management

### Session Lifecycle

#### 1. Session Initiation
```markdown
**Session Start**: [timestamp]
**Agent**: [agent-name]
**Reserved Files**: [file-list]
**Estimated Duration**: [time-estimate]
**Session ID**: [unique-identifier]
```

#### 2. Active Session Tracking
- **Heartbeat Monitoring**: Regular status updates every 30 minutes
- **Scope Validation**: Continuous verification of file access patterns
- **Conflict Monitoring**: Real-time detection of scope violations
- **Performance Tracking**: Session duration and file modification rates

#### 3. Session Extension
```markdown
**Session Extension Request**:
**Session ID**: [session-id]
**Current Duration**: [elapsed-time]
**Extension Requested**: [additional-time]
**Justification**: [reason-for-extension]
**Impact Assessment**: [effect-on-other-sessions]
```

#### 4. Session Completion
```markdown
**Session Complete**: [timestamp]
**Duration**: [total-time]
**Files Modified**: [modified-file-list]
**Next Session**: [follow-up-session-info]
**Handoff Notes**: [notes-for-next-agent]
```

### Session Performance Metrics

#### Duration Targets
- **Simple Changes**: <1 hour
- **Feature Implementation**: 2-4 hours
- **Complex Integration**: 4-8 hours
- **Major Refactoring**: 8-24 hours

#### File Scope Efficiency
- **Scope Accuracy**: 90% of declared files actually modified
- **Scope Completeness**: 95% of modified files were declared
- **Conflict Rate**: <5% of sessions experience conflicts
- **Resolution Time**: Conflicts resolved within 15 minutes

## Common Conflict Patterns and Solutions

### Pattern 1: Database-First Development

**Scenario**: Backend needs database migrations before frontend can proceed

**Agents Involved**: laravel-dev, react-dev  
**Conflict Type**: Timeline dependency  

**Solution Template**:
```markdown
**Resolution**: Sequential Development with Staging
1. **laravel-dev**: Create database migrations and models (2 hours)
2. **laravel-dev**: Deploy to development environment (30 minutes)
3. **react-dev**: Begin frontend integration with dev API (3 hours)
4. **Both**: Integration testing and refinement (1 hour)
**Total Timeline**: 6.5 hours
```

### Pattern 2: Shared Configuration Files

**Scenario**: Multiple agents need to modify configuration files

**Agents Involved**: devops, laravel-dev, react-dev  
**Conflict Type**: Direct file conflicts  

**Solution Template**:
```markdown
**Resolution**: Configuration Ownership Matrix
- **devops**: Infrastructure and deployment config
- **laravel-dev**: Backend application config  
- **react-dev**: Frontend build and runtime config
- **Shared**: Environment variables (devops coordinates)

**Implementation**: Split config files by ownership, shared configs use PR review process
```

### Pattern 3: Documentation Synchronization

**Scenario**: Code changes require documentation updates across multiple files

**Agents Involved**: [dev-agent], docs-orchestrator  
**Conflict Type**: Sequential dependency  

**Solution Template**:
```markdown
**Resolution**: Documentation Follow-up Protocol
1. **Development Agent**: Complete code implementation
2. **Development Agent**: Update inline code documentation
3. **docs-orchestrator**: Review and update external documentation
4. **docs-orchestrator**: Validate documentation consistency
**Coordination**: Automatic documentation review trigger on code completion
```

### Pattern 4: Test-Driven Development Coordination

**Scenario**: Tests need updating before, during, and after implementation

**Agents Involved**: [dev-agent], test-automation  
**Conflict Type**: Parallel coordination  

**Solution Template**:
```markdown
**Resolution**: TDD Coordination Protocol
1. **test-automation**: Create failing tests for new requirements
2. **Development Agent**: Implement code to pass tests  
3. **Both**: Refactor and optimize (parallel work)
4. **test-automation**: Add edge case and integration tests
**Coordination**: Shared test file ownership with merge request review
```

## Integration with Other Protocols

### Agent Check-in Validation
- File scope declared during check-in process
- Vibe-coder validates scope for conflicts before authorization
- Scope conflicts prevent session authorization

### GitHub Comment Standards
- All conflict resolution communications use standard comment format
- Scope adjustment requests follow addressing protocols
- Status updates maintain consistent formatting

### Emergency Response Procedures
- Critical conflicts trigger emergency response levels
- Scope violations escalate according to severity
- Resolution failures activate emergency coordination

## Troubleshooting

### Common Issues

#### Scope Declaration Problems
**Issue**: Vague or overly broad scope declarations  
**Solution**: Provide specific file lists or bounded patterns  
**Prevention**: Scope declaration templates and examples  

#### Conflict Detection Delays
**Issue**: Conflicts not detected until work begins  
**Solution**: Improve pattern matching algorithms  
**Prevention**: Pre-work scope validation  

#### Resolution Coordination Failures
**Issue**: Agents don't follow resolution procedures  
**Solution**: Automated tracking and escalation  
**Prevention**: Clear resolution protocols and training  

#### Session Overruns
**Issue**: Sessions exceed estimated duration significantly  
**Solution**: Better estimation and progress tracking  
**Prevention**: Regular check-ins and scope adjustment  

### Resolution Escalation

#### Level 1: Automated Resolution (0-5 minutes)
- Simple scope adjustments
- Sequential coordination for minor conflicts
- Pattern refinement

#### Level 2: Vibe-coder Mediation (5-15 minutes)
- Complex scope negotiations
- Multi-agent coordination
- Timeline adjustments

#### Level 3: Manual Intervention (15+ minutes)
- Architectural conflicts requiring design changes
- Resource capacity limitations
- Emergency priority conflicts

#### Level 4: Emergency Response (Immediate)
- Critical system conflicts
- Security or data integrity risks
- Production system impacts

## Performance Monitoring

### Key Metrics

#### Conflict Rates
- **Target**: <5% of sessions experience conflicts
- **Measurement**: Conflicts per 100 session starts
- **Trending**: Weekly analysis for pattern identification

#### Resolution Speed
- **Target**: 90% of conflicts resolved within 15 minutes
- **Measurement**: Time from detection to resolution
- **Escalation**: Automatic escalation for delays >15 minutes

#### Scope Accuracy
- **Target**: 90% scope accuracy (declared vs. actual files modified)
- **Measurement**: File declaration accuracy per session
- **Improvement**: Feedback loop for scope estimation

#### Agent Productivity
- **Target**: Minimize productivity loss due to conflicts
- **Measurement**: Session delays attributed to conflicts
- **Optimization**: Continuous improvement of resolution procedures

### Success Indicators

#### System Efficiency
- **Parallel Work**: 80% of sessions run without conflicts
- **Fast Resolution**: Average conflict resolution time <10 minutes
- **High Accuracy**: Scope declarations 90% accurate
- **Low Escalation**: <10% of conflicts require manual intervention

#### Agent Satisfaction
- **Clear Procedures**: Agents understand resolution processes
- **Fair Coordination**: Resolution procedures seen as equitable
- **Minimal Disruption**: Conflicts don't significantly impact productivity
- **Effective Communication**: Resolution communications are clear and actionable

---

*This protocol ensures efficient resource coordination and conflict prevention across all agents in the Vibe Coder Agent Orchestration System. Proper scope management is essential for system scalability and agent productivity.*