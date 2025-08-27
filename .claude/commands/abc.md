---
allowed-tools: Bash, Write, Read, Edit, Grep, LS, Task
description: ABC (Always Be Closing) multi-agent worktree workflow completion system
argument-hint: [optional-task-context]
---

# ABC: Always Be Closing - Multi-Agent Workflow Completion

The ABC command applies structured pressure to drive tasks toward **merge-ready state** in our multi-agent worktree development workflow. ABC ensures proper GitHub issue tracking, agent assignment, and AI review integration while maintaining quality standards.

## Arguments Provided
`$ARGUMENTS`

## Workflow Context Detection

I'll analyze your current development context to provide accurate guidance:

### Worktree Environment Analysis
- Repository: !`git remote get-url origin 2>/dev/null | sed 's/.*\///' | sed 's/\.git//' || echo "Unknown"`
- Current location: !`pwd | sed "s|$HOME|~|"`
- Branch pattern: !`git branch --show-current 2>/dev/null || echo "No branch"`
- Worktree status: !`[[ "$(pwd)" == *"/worktrees/"* ]] && echo "✅ Agent worktree" || echo "⚠️ Main repository"`

### Agent Context Detection
- Agent identification: !`echo "$PWD" | grep -o 'worktrees/[^/]*/[^/]*' | cut -d'/' -f2-3 || echo "Not in agent worktree"`
- Expected branch format: `agent-name/task-type/description`

## ABC Multi-Agent Workflow Compliance

### 🔍 Phase 1: Workflow Foundation Validation
**Critical Requirements for Multi-Agent Development**

#### GitHub Issue Integration ✅
- [ ] **Issue Created**: Task has dedicated GitHub issue (via `gh issue create` or `/start-session`)
- [ ] **Issue Assignment**: Issue assigned to correct agent
- [ ] **Issue Labels**: Proper labels applied (agent-task, priority level)
- [ ] **Issue Status**: Issue status reflects current work state
- [ ] **Context Comments**: Issue has agent communication following GitHub Comment Standards

#### Agent Worktree Setup ✅  
- [ ] **Proper Worktree**: Working in isolated agent worktree (not main repo)
- [ ] **Branch Naming**: Follows `agent/type/description` pattern exactly
- [ ] **Setup Script Used**: Worktree created via `setup-agent-task.sh` 
- [ ] **Remote Tracking**: Branch properly tracks remote origin
- [ ] **Clean Workspace**: No uncommitted changes blocking progress

#### Agent Assignment Validation ✅
- [ ] **Correct Agent**: Work matches agent specialization and scope
- [ ] **Authority Granted**: Vibe-coder authorization obtained if required
- [ ] **Scope Compliance**: All file modifications within agent scope
- [ ] **Coordination Protocol**: Following agent communication standards

### 🔄 Phase 2: Development Quality Gates
**Quality Standards for Multi-Agent Coordination**

#### Code Quality & Testing ✅
- [ ] **TDD Compliance**: Tests written before implementation (MANDATORY)
- [ ] **Test Coverage**: All new code has corresponding test files
- [ ] **Tests Passing**: `npm test` or equivalent passes completely
- [ ] **Linting Clean**: `npm run lint` passes without errors
- [ ] **DRY Principle**: No code duplication without justification

#### Multi-Agent Integration ✅
- [ ] **Cross-Agent Dependencies**: Dependencies on other agents documented
- [ ] **API Compatibility**: Changes maintain compatibility with other components
- [ ] **Configuration Updates**: Environment configurations updated if needed
- [ ] **Documentation Sync**: Changes reflected in relevant documentation
- [ ] **Breaking Changes**: Breaking changes properly communicated

### 🚀 Phase 3: AI-Reviewed Merge Preparation
**AI Reviewer Integration for Quality Assurance**

#### AI Review Integration ✅
- [ ] **Gemini Code Assist**: Invoked with `@gemini-code-assist` for technical review
- [ ] **Greptile Analysis**: Code analysis completed (if applicable)
- [ ] **Review Feedback**: AI reviewer feedback addressed completely
- [ ] **Security Validation**: AI security analysis passed
- [ ] **Performance Review**: AI performance impact assessment completed

#### PR & Merge Readiness ✅
- [ ] **PR Created**: Pull request created targeting **dev branch** (never main)
- [ ] **PR Description**: Comprehensive description with test plan
- [ ] **Issue Linking**: PR properly linked to originating GitHub issue
- [ ] **Conventional Commits**: Commit messages follow conventional format
- [ ] **Review Complete**: All AI reviewer suggestions addressed
- [ ] **Merge Conflicts**: No conflicts with target branch (dev)

## ABC Workflow-Specific Analysis

### Multi-Agent Context Assessment
I'll analyze your specific situation within our workflow:

1. **Worktree Validation**: Ensure you're in proper agent worktree, not main repo
2. **Issue Tracking**: Verify GitHub issue exists and is properly linked
3. **Branch Compliance**: Check `agent/type/description` naming pattern
4. **Agent Scope**: Confirm work is within authorized agent boundaries
5. **AI Review Status**: Check AI reviewer integration and feedback status

### Workflow-Specific Action Items

Based on our multi-agent worktree workflow, here are your next steps:

#### If Missing GitHub Issue:
```bash
# Create issue for task tracking
gh issue create --title "[AGENT-TASK] Your Task Title" --body "Task description"
# Link to current work
gh issue comment [issue-number] --body "Working in branch: $(git branch --show-current)"
```

#### If Not in Agent Worktree:
```bash
# Navigate to or create proper worktree
cd ~/Code/Tuvens/tuvens-docs/worktrees/[agent]/[agent]/[task-type]/[description]
# Or use setup script
./agentic-development/scripts/setup-agent-task.sh [agent] "[task]" "[description]"
```

#### If AI Review Missing:
```bash
# Invoke Gemini Code Assist
gh pr comment [pr-number] --body "@gemini-code-assist review this implementation"
# Check for Greptile integration
gh pr comment [pr-number] --body "@greptileai"
```

## Next Step Identification

I'll identify your exact next step based on our actual workflow:

### Workflow Decision Tree
1. **No GitHub Issue** → Create issue with `/create-issue` or `gh issue create`
2. **Wrong Location** → Move to proper agent worktree
3. **Branch Name Wrong** → Rename branch to `agent/type/description` format
4. **Code Not Ready** → Complete TDD cycle and quality gates
5. **No AI Review** → Invoke AI reviewers before merge
6. **Ready to Merge** → Target dev branch and complete merge

### AI-Specific Pressure Levels

- 🔴 **HIGH PRESSURE**: Issue blocking other agents or overdue
- 🟡 **MEDIUM PRESSURE**: On track but needs AI review completion  
- 🟢 **LOW PRESSURE**: Ahead of schedule, focus on quality

## Tuvens-Specific Safety & Quality Gates

### Workflow Compliance Validation
- **CLAUDE.md Safety Rules**: All agent safety protocols followed
- **Branch Strategy**: Proper `agent/type/description` → dev → test → stage → main flow
- **Agent Scope Protection**: File modifications within declared agent scope
- **Multi-Agent Coordination**: Proper handoff and communication protocols
- **AI Review Integration**: Gemini/Greptile feedback incorporated

### Success Criteria for Completion
1. ✅ GitHub issue created and properly assigned
2. ✅ Work completed in isolated agent worktree
3. ✅ Branch follows naming convention exactly
4. ✅ All code quality gates passed (TDD, linting, testing)  
5. ✅ AI reviewers invoked and feedback addressed
6. ✅ PR created targeting dev branch with proper description
7. ✅ Issue linked and ready for vibe-coder validation

Let me analyze your current situation and provide the exact next step to move your task toward merge-ready state in our multi-agent workflow.