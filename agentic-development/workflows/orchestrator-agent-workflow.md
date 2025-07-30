# Documentation Orchestrator Agent Workflow

## Overview

This document defines the 6-step workflow process for the Documentation Orchestrator agent to coordinate multi-agent development across the Tuvens ecosystem.

## Agent Identity Reminder

**I am the Documentation Orchestrator for Tuvens multi-agent development.**

**Context Loading:**
- Load: agentic-development/ directory structure and all documentation
- Load: pending-commits/main/ to understand current status
- Load: workflows/ directory for active workflows
- Focus: Documentation consistency, agent coordination, knowledge management

**My role:** Maintain documentation integrity across the multi-agent system.

## 6-Step Orchestrator Workflow

### Step 1: Context Assessment and Planning
**Objective:** Understand current system state and plan coordination activities

#### Actions:
1. **Load System Context**
   ```bash
   cd /Code/tuvens/tuvens-docs
   # Review current system state
   ls agentic-development/pending-commits/main/
   cat agentic-development/workflows/*.md
   ```

2. **Assess Agent Status**
   - Review pending-commits/ for all active agents
   - Check workflow documentation for current phases
   - Identify coordination needs and dependencies

3. **Create Coordination Plan**
   - Document current multi-agent activities
   - Identify required documentation updates
   - Plan agent handoffs and communication needs

#### Outputs:
- Updated understanding of system state
- Coordination plan documented in pending-commits/
- Clear next actions for orchestration work

### Step 2: Agent Coordination Setup
**Objective:** Establish infrastructure for multi-agent collaboration

#### Actions:
1. **Create Coordination Worktrees**
   ```bash
   # Create orchestrator worktree for coordination work
   git checkout develop
   git checkout -b docs-orchestrator/multi-agent-coordination
   git worktree add /Code/tuvens/worktrees/tuvens-docs/docs-orchestrator/multi-agent-coordination docs-orchestrator/multi-agent-coordination
   ```

2. **Set Up Agent Communication Channels**
   - Create workflow documentation for specific projects
   - Set up pending-commits structure for new initiatives
   - Establish GitHub issues for cross-repository coordination

3. **Update Agent Documentation**
   - Ensure all agent identities are current
   - Update context loading guides with new patterns
   - Document any new coordination protocols

#### Outputs:
- Working worktree for orchestration activities
- Updated agent communication infrastructure
- Current agent documentation and protocols

### Step 3: Multi-Agent Workflow Initiation
**Objective:** Start coordinated multi-agent development activities

#### Actions:
1. **Create Agent Windows**
   ```bash
   # Create specialized agent windows based on current needs
   # Frontend Agent
   osascript -e 'tell application "iTerm2"
       create window with default profile
       tell current session of current window
           set name to "🎨 Frontend Dev - {feature-name}"
           write text "cd /Code/tuvens/worktrees/tuvens-client/frontend-dev/{feature-name}"
           write text "echo \"Context: Load Frontend Developer identity\""
       end tell
   end tell'
   
   # Backend Agent (similar setup)
   # Integration Agent (similar setup)
   ```

2. **Distribute Coordination Documentation**
   - Create workflow files for each active project
   - Assign specific agents to appropriate tasks
   - Set up coordination checkpoints and status updates

3. **Initialize Agent Contexts**
   - Ensure each agent has proper context loading instructions
   - Verify agent-specific documentation is accessible
   - Set up communication protocols for the project

#### Outputs:
- Active agent windows with proper context
- Distributed workflow documentation
- Established communication and coordination protocols

### Step 4: Active Coordination and Monitoring
**Objective:** Monitor agent progress and facilitate coordination

#### Actions:
1. **Monitor Agent Progress**
   ```bash
   # Regular checks of agent status
   find agentic-development/pending-commits/ -name "*.md" -mtime -1
   # Review recent agent updates
   ```

2. **Facilitate Agent Handoffs**
   - Monitor for workflow phase completions
   - Create handoff documentation between agents
   - Resolve conflicts and dependencies

3. **Update System Documentation**
   - Document new patterns discovered during coordination
   - Update agent workflows based on learnings
   - Maintain system-wide consistency

4. **Coordinate Cross-Repository Work**
   - Sync timing of related changes across repositories
   - Ensure API contracts between frontend/backend are maintained
   - Manage integration testing coordination

#### Outputs:
- Real-time coordination of agent activities
- Updated system documentation reflecting current patterns
- Smooth agent handoffs and conflict resolution

### Step 5: Integration and Quality Assurance
**Objective:** Ensure agent work integrates properly and maintains quality

#### Actions:
1. **Review Agent Deliverables**
   ```bash
   # Review all agent pending commits
   for agent_dir in agentic-development/pending-commits/*/; do
       echo "=== Agent: $(basename "$agent_dir") ==="
       ls -la "$agent_dir"
   done
   ```

2. **Coordinate Integration Testing**
   - Plan testing sequences for cross-agent work
   - Coordinate timing of integration tests
   - Document integration test results

3. **Quality Assurance Review**
   - Ensure documentation standards are maintained
   - Verify agent communication protocols were followed
   - Check that all coordination checkpoints were met

4. **Prepare for Production Integration**
   - Coordinate PR creation timing across repositories
   - Ensure all agents have completed their workflow phases
   - Document the complete integration process

#### Outputs:
- Quality-assured agent deliverables
- Coordinated integration testing results
- Ready-for-production integrated features

### Step 6: Workflow Completion and Knowledge Capture
**Objective:** Complete the multi-agent workflow and capture learnings

#### Actions:
1. **Finalize Agent Coordination**
   ```bash
   # Ensure all agent work is committed and pushed
   cd /Code/tuvens/worktrees/tuvens-docs/docs-orchestrator/multi-agent-coordination
   git add .
   git commit -m "docs: complete multi-agent coordination for {project-name}"
   git push origin docs-orchestrator/multi-agent-coordination
   ```

2. **Create Final Coordination Summary**
   - Document the complete multi-agent workflow
   - Capture lessons learned and process improvements
   - Update standard workflows based on experience

3. **Clean Up and Archive**
   - Clean up completed worktrees
   - Archive coordination documentation appropriately
   - Update agent workflows with improvements

4. **Prepare for Next Cycle**
   - Update orchestrator workflows based on learnings
   - Prepare improved coordination templates
   - Document recommendations for future multi-agent projects

#### Outputs:
- Complete workflow documentation
- Captured knowledge and process improvements
- Clean system ready for next multi-agent coordination cycle

## Orchestrator Decision Framework

### When to Initiate Multi-Agent Workflows
- Features requiring multiple repositories
- Complex integrations affecting multiple system components
- Authentication/authorization implementations
- Major system architecture changes
- Cross-cutting concerns affecting multiple agents

### Agent Priority Guidelines
1. **High Priority:** Security, authentication, core functionality
2. **Medium Priority:** Feature enhancements, performance improvements
3. **Low Priority:** Documentation updates, experimental features

### Conflict Resolution Authority
1. **Technical Conflicts:** Senior agents or subject matter experts
2. **Process Conflicts:** Documentation Orchestrator mediates
3. **Resource Conflicts:** Documentation Orchestrator assigns priorities
4. **Timeline Conflicts:** Documentation Orchestrator adjusts schedules

## Success Metrics

### Workflow Efficiency
- Time from initiation to completion
- Number of agent handoffs required
- Coordination overhead vs. development time

### Quality Metrics  
- Integration test success rate
- Post-deployment issues
- Documentation completeness and accuracy

### Agent Coordination
- Communication effectiveness
- Conflict resolution time
- Agent satisfaction with coordination process

## Continuous Improvement

### Regular Review Points
- After each major multi-agent project
- Monthly orchestrator workflow reviews
- Quarterly agent feedback sessions

### Process Evolution
- Update workflows based on learnings
- Incorporate new tools and techniques
- Adapt to changing team and project needs

This workflow ensures systematic, efficient coordination of multi-agent development while maintaining high quality standards and effective communication across the entire Tuvens ecosystem.