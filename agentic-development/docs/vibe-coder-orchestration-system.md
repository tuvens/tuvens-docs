# Vibe Coder Orchestration System

## Overview

The Vibe Coder has been transformed from a passive coordinator to an active **System Orchestrator and Agent Police**. This system enforces strict protocols, validates all agent work, and ensures multi-agent coordination operates safely and efficiently.

## Key Improvements

### 🚨 Agent Protocol Enforcement
- **Mandatory identity declarations** for every GitHub issue comment
- **Branch safety validation** preventing direct work on protected branches  
- **File scope management** preventing conflicts in parallel work
- **Work validation requirements** with independent testing

### 🔧 Claude Desktop Branch Safety
- **Automatic feature branch creation** for GitHub MCP operations
- **Protected branch detection** and prevention
- **Mandatory PR workflow** with code review requirements
- **Integration with existing Git workflows**

### 📊 Real-time Coordination
- **Session tracking** for all active agent work
- **File reservation system** for parallel development
- **Live dashboard** showing agent status and conflicts
- **Automated cleanup** of expired reservations

## Installation and Setup

### 1. Make Orchestration Script Executable

```bash
cd ~/Code/Tuvens/tuvens-docs
chmod +x agentic-development/scripts/vibe-coder-orchestration.sh

# Initialize tracking systems
./agentic-development/scripts/vibe-coder-orchestration.sh init
```

### 2. Update Agent Configurations

The updated `.claude/agents/vibe-coder.md` file now includes:
- Protocol enforcement capabilities
- Branch safety protocols
- Universal comment identity requirements
- Work validation frameworks

### 3. Integration with Existing Workflows

The system integrates with existing Tuvens workflows:
- `/start-session` commands now include validation
- GitHub issues become coordination points
- Branch tracking system enhanced with real-time monitoring

## Usage Guide

### For the Vibe Coder Agent

#### 1. Starting Agent Sessions

**Always delegate work - never do it yourself:**

```bash
# Create GitHub issue and assign to specialist
/create-issue vibe-coder react-dev "Implement auth UI components" tuvens-client

# Monitor agent check-in via GitHub issue comments
# Validate agent identity and workspace before approving
```

#### 2. Agent Identity Validation

**Before approving any agent work:**

```bash
# Validate agent workspace and identity
./agentic-development/scripts/vibe-coder-orchestration.sh validate-identity \
  "react-dev" "tuvens-client" "react-dev/feature/auth-ui" "/path/to/worktree"
```

#### 3. Independent Work Validation

**After agent reports completion:**

```bash
# Run independent validation
./agentic-development/scripts/vibe-coder-orchestration.sh validate-work \
  "react-dev" "tuvens-client" "react-dev/feature/auth-ui" "123"

# Only approve if validation passes
```

#### 4. Real-time Dashboard

**Monitor all active work:**

```bash
# View active sessions and file reservations
./agentic-development/scripts/vibe-coder-orchestration.sh dashboard
```

### For Other Agents

#### 1. Mandatory Check-in Protocol

**Every agent MUST comment on GitHub issue before starting work:**

```markdown
👤 **Identity**: react-dev
🎯 **Addressing**: vibe-coder

## Agent Check-In
I am react-dev working on auth UI implementation  
Current location: tuvens-client/worktrees/react-dev-feature-auth-ui
Current branch: react-dev/feature/auth-ui
Confirming branch != 'dev' ✅
Working on files: src/auth/LoginForm.svelte, src/auth/SignupForm.svelte
No file conflicts detected ✅
Awaiting approval to proceed.
```

#### 2. Universal Comment Identity

**EVERY comment must start with identity declaration:**

```markdown
👤 **Identity**: [your-agent-name] 
🎯 **Addressing**: [target-agent-name]

[Your message content here]
```

#### 3. Pre-work Validation

**Before starting work, validate your workspace:**

```bash
# Check branch safety
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == "dev" ]] || [[ "$BRANCH" == "main" ]]; then
    echo "❌ CRITICAL ERROR: Cannot work on protected branch: $BRANCH"
    exit 1
fi
echo "✅ Safe to proceed on branch: $BRANCH"
```

## Protocol Reference

### Branch Safety Requirements

**Protected Branches**: `dev`, `main`, `master`
**Required Pattern**: `[agent]/[type]/[description]`
**Valid Types**: `feature`, `fix`, `update`, `experiment`

**Examples:**
- ✅ `react-dev/feature/auth-components`
- ✅ `node-dev/fix/validation-error`
- ✅ `vibe-coder/update/orchestration-system`
- ❌ `dev` (protected)
- ❌ `feature-auth` (missing agent prefix)

### File Reservation System

**For Parallel Work:**

```bash
# Reserve files before starting work
./agentic-development/scripts/vibe-coder-orchestration.sh reserve-files \
  "react-dev" "tuvens-client" "4" "src/auth/LoginForm.svelte" "src/auth/SignupForm.svelte"

# Check for conflicts
./agentic-development/scripts/vibe-coder-orchestration.sh check-conflicts \
  "node-dev" "tuvens-api" "src/middleware/auth.js"

# Release when done
./agentic-development/scripts/vibe-coder-orchestration.sh release-files \
  "react-dev" "tuvens-client"
```

### GitHub Issue Communication Flow

1. **Vibe Coder** creates issue and assigns to specialist agent
2. **Specialist Agent** comments with identity declaration and check-in
3. **Vibe Coder** validates workspace and approves/rejects
4. **Specialist Agent** completes work and reports with implementation details
5. **Vibe Coder** runs independent validation and closes issue

## Command Reference

### Orchestration Script Commands

```bash
# System initialization
./vibe-coder-orchestration.sh init

# Agent validation
./vibe-coder-orchestration.sh validate-identity <agent> <repo> <branch> <path>

# File management
./vibe-coder-orchestration.sh check-conflicts <agent> <repo> <file1> [file2...]
./vibe-coder-orchestration.sh reserve-files <agent> <repo> <hours> <file1> [file2...]
./vibe-coder-orchestration.sh release-files <agent> <repo>

# Session management
./vibe-coder-orchestration.sh start-session <agent> <repo> <branch> <task>
./vibe-coder-orchestration.sh end-session <agent> <repo>

# Work validation
./vibe-coder-orchestration.sh validate-work <agent> <repo> <branch> [issue#]

# Monitoring
./vibe-coder-orchestration.sh dashboard
./vibe-coder-orchestration.sh cleanup

# Help
./vibe-coder-orchestration.sh help
```

## Emergency Protocols

### Protocol Violations

**Detected automatically by validation scripts:**

- **Protected Branch Work**: Agent working directly on `dev`/`main`
- **File Conflicts**: Multiple agents claiming same files
- **Missing Check-in**: Agent starts work without proper declaration
- **Invalid Workspace**: Agent in wrong location or missing safety files

### Recovery Procedures

**If agent goes rogue:**
1. Revoke file reservations immediately
2. Check branch protection status
3. Reset to last known good state
4. Update protocols to prevent recurrence

**If system fails:**
1. Switch to manual coordination mode
2. Direct GitHub issue management
3. Restore tracking systems
4. Validate all work integrity

## Success Metrics

### System Health Indicators
- **Protocol Compliance Rate**: Target 100%
- **Work Validation Success**: Target 95%+
- **Agent Response Time**: Target <2 hours
- **System Recovery Time**: Target <30 minutes

### Monitoring and Improvement
- Weekly protocol compliance analysis
- Monthly agent performance review  
- Quarterly system optimization
- Annual framework evolution

## Integration with Existing Tools

### GitHub Actions Integration
The orchestration system works with existing workflows:
- Branch tracking updates include validation status
- Workflow triggers incorporate protocol checks
- Automated cleanup respects orchestration state

### Claude Code Integration
Seamless integration with Claude Code agents:
- Same branch safety protocols apply
- Worktree management remains consistent
- Session tracking works across both systems

### Multi-Repository Coordination
Cross-repository work coordination:
- File reservations work across repositories
- Session tracking spans multiple codebases
- Consistent protocols regardless of repository

---

**The Vibe Coder is now a true System Orchestrator and Agent Police, ensuring every agent follows procedures and delivers quality work.**
