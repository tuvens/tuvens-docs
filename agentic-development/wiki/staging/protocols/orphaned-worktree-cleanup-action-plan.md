# Orphaned Worktree Cleanup Action Plan

**Purpose**: Specific action plan for cleaning up 22+ orphaned worktrees identified in the Tuvens ecosystem  
**Target Audience**: DevOps agents, system administrators, project maintainers  
**Risk Level**: Medium - Requires careful safety procedures  
**Author**: Vibe Coder Agent  
**Date**: 2025-08-18  
**Issue Reference**: tuvens-docs#161  

## Executive Summary

This document provides a specific, actionable plan for cleaning up the **22+ orphaned worktrees** that have accumulated from completed development work across the Tuvens ecosystem. These worktrees represent approximately **1-2GB of disk space** and create organizational overhead that impacts development efficiency.

### Immediate Impact Assessment
- **Current Worktree Count**: 65+ total worktree subdirectories
- **Estimated Orphaned**: 22-30 worktrees from completed work
- **Disk Space Impact**: 1-2GB storage consumption
- **Repositories Affected**: `tuvens-docs`, `tuvens-client`, `tuvens-api`, `tuvens-mobile`, `eventdigest-ai`
- **Agent Efficiency Impact**: Medium - affects workspace navigation and clarity

## Critical Safety Requirements

### BEFORE ANY CLEANUP - MANDATORY STEPS

#### 1. Complete System Backup
```bash
# Create comprehensive backup directory
mkdir -p ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)
cd ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)

# Document current state
echo "# Tuvens Worktree Cleanup - $(date)" > cleanup-log.md
echo "## Pre-cleanup State" >> cleanup-log.md

# Generate complete inventory
for repo in tuvens-docs tuvens-client tuvens-api tuvens-mobile eventdigest-ai; do
    if [ -d "/Users/ciarancarroll/Code/Tuvens/$repo" ]; then
        echo "### $repo Repository" >> cleanup-log.md
        cd "/Users/ciarancarroll/Code/Tuvens/$repo"
        git worktree list >> ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)/cleanup-log.md
        echo "" >> ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)/cleanup-log.md
    fi
done
```

#### 2. Verify No Active Work
```bash
# Scan for uncommitted changes across all worktrees
echo "## Uncommitted Work Scan" >> cleanup-log.md
find /Users/ciarancarroll/Code/Tuvens -name ".git" -type f | while read gitfile; do
    workdir=$(dirname "$gitfile")
    if [[ "$gitfile" == *"worktree"* ]]; then
        cd "$workdir"
        if ! git diff --quiet HEAD 2>/dev/null || ! git diff --quiet --cached 2>/dev/null; then
            echo "⚠️  UNCOMMITTED WORK: $workdir" | tee -a ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)/cleanup-log.md
        fi
    fi
done
```

#### 3. Validate Central Tracking System
```bash
# Ensure tracking system is current
cd /Users/ciarancarroll/Code/Tuvens/tuvens-docs
echo "## Central Tracking Status" >> ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)/cleanup-log.md
cat agentic-development/branch-tracking/cleanup-queue.json >> ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)/cleanup-log.md
cat agentic-development/branch-tracking/active-branches.json | jq '.branches | keys' >> ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)/cleanup-log.md
```

## Identified Orphaned Worktree Categories

### Category A: Confirmed Merged Branches (High Priority)
**Risk Level**: Low  
**Estimated Count**: 15-20 worktrees  
**Safety Level**: Safe for automated cleanup  

**Identification Criteria**:
- Branch successfully merged to `dev`, `stage`, or `main`
- Pull request marked as completed/closed
- No uncommitted changes
- Listed in central tracking cleanup queue

**Examples from Current State**:
- Completed vibe-coder feature branches
- Merged devops workflow improvements  
- Closed frontend component branches

### Category B: Stale Development Branches (Medium Priority)
**Risk Level**: Medium  
**Estimated Count**: 5-7 worktrees  
**Safety Level**: Requires manual verification  

**Identification Criteria**:
- No commits in last 30+ days
- No associated open pull requests
- No active agent session references
- No recent file modifications

**Verification Required**:
- Check with agent owners for planned resumption
- Verify no experimental work of value
- Confirm no cross-branch dependencies

### Category C: Test/Experimental Branches (Low Priority)
**Risk Level**: Low-Medium  
**Estimated Count**: 2-3 worktrees  
**Safety Level**: Document before cleanup  

**Identification Criteria**:
- Named with patterns: `test/`, `experiment/`, `prototype/`
- Short-lived exploratory work
- No production dependencies

**Special Handling**:
- Extract and document any valuable findings
- Preserve commit history in documentation
- Archive experimental results before cleanup

## Phased Cleanup Execution Plan

### Phase 1: Automated Safe Cleanup (Week 1)
**Target**: Category A - Confirmed merged branches  
**Method**: Use existing automated cleanup system  
**Timeline**: 1-2 hours  

#### Phase 1 Steps:
```bash
# 1. Navigate to tracking system
cd /Users/ciarancarroll/Code/Tuvens/tuvens-docs/agentic-development

# 2. Review cleanup queue
cat branch-tracking/cleanup-queue.json

# 3. Execute automated cleanup
./scripts/cleanup-merged-branches.sh

# 4. Verify results
echo "Phase 1 Results:" >> ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)/cleanup-log.md
cat branch-tracking/last-cleanup.md >> ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)/cleanup-log.md
```

#### Expected Phase 1 Results:
- 15-20 worktrees removed
- 800MB-1.2GB disk space recovered
- Zero risk of data loss
- Improved repository organization

### Phase 2: Manual Verification and Cleanup (Week 2)
**Target**: Category B - Stale development branches  
**Method**: Manual review with safety checks  
**Timeline**: 2-3 hours  

#### Phase 2 Steps:
```bash
# 1. Identify stale worktrees
find /Users/ciarancarroll/Code/Tuvens -path "*/worktrees/*" -type d -mtime +30 | while read dir; do
    if [ -f "$dir/.git" ]; then
        cd "$dir"
        branch=$(git branch --show-current 2>/dev/null)
        last_commit=$(git log -1 --format="%cd" --date=short 2>/dev/null)
        echo "$dir|$branch|$last_commit" >> ~/stale-worktrees-analysis.csv
    fi
done

# 2. For each stale worktree, perform safety verification
while IFS='|' read -r workdir branch last_commit; do
    echo "Analyzing: $workdir ($branch, last: $last_commit)"
    
    cd "$workdir"
    
    # Check for uncommitted work
    if ! git diff --quiet HEAD 2>/dev/null || ! git diff --quiet --cached 2>/dev/null; then
        echo "SKIP - Has uncommitted work: $workdir" >> ~/phase2-review.txt
        continue
    fi
    
    # Check for merge status
    cd "$(git rev-parse --show-toplevel)"
    if git merge-base --is-ancestor "$branch" dev 2>/dev/null; then
        echo "SAFE - Merged to dev: $workdir" >> ~/phase2-safe-cleanup.txt
    else
        echo "REVIEW - Not merged: $workdir" >> ~/phase2-manual-review.txt
    fi
done < ~/stale-worktrees-analysis.csv

# 3. Clean up verified safe stale branches
while read safe_line; do
    workdir=$(echo "$safe_line" | sed 's/SAFE - Merged to dev: //')
    echo "Cleaning up: $workdir"
    
    # Navigate to repository root
    cd "$workdir"
    repo_root=$(git rev-parse --show-toplevel)
    cd "$repo_root"
    
    # Remove worktree safely
    relative_path=$(realpath --relative-to="$repo_root" "$workdir")
    git worktree remove "$relative_path" --force
    echo "Cleaned: $workdir" >> ~/phase2-cleanup-log.txt
done < ~/phase2-safe-cleanup.txt
```

#### Expected Phase 2 Results:
- 5-7 additional worktrees removed
- 200-400MB additional disk space recovered
- Manual verification ensures safety
- Documentation of any skipped branches

### Phase 3: Experimental Branch Documentation and Cleanup (Week 3)
**Target**: Category C - Test/experimental branches  
**Method**: Document findings, then clean up  
**Timeline**: 1 hour  

#### Phase 3 Steps:
```bash
# 1. Identify experimental worktrees
find /Users/ciarancarroll/Code/Tuvens -path "*/worktrees/*" -type d -name "*test*" -o -name "*experiment*" -o -name "*prototype*" | while read exp_dir; do
    if [ -f "$exp_dir/.git" ]; then
        echo "$exp_dir" >> ~/experimental-worktrees.txt
    fi
done

# 2. Document experimental findings
mkdir -p ~/experimental-branch-archive/$(date +%Y%m%d)
while read exp_dir; do
    cd "$exp_dir"
    branch=$(git branch --show-current 2>/dev/null)
    
    # Create documentation
    cat > ~/experimental-branch-archive/$(date +%Y%m%d)/${branch//\//_}.md << EOF
# Experimental Branch: $branch
**Path**: $exp_dir  
**Archived**: $(date)  
**Purpose**: Experimental/testing work  

## Commit History
$(git log --oneline -10)

## Key Files
$(find . -name "*.md" -o -name "*.json" | head -10)

## Notable Changes
$(git diff --name-only HEAD~3 2>/dev/null | head -10)
EOF

    echo "Documented: $branch" >> ~/phase3-documentation-log.txt
done < ~/experimental-worktrees.txt

# 3. Clean up experimental branches
while read exp_dir; do
    cd "$exp_dir"
    repo_root=$(git rev-parse --show-toplevel)
    cd "$repo_root"
    
    relative_path=$(realpath --relative-to="$repo_root" "$exp_dir")
    git worktree remove "$relative_path" --force
    echo "Cleaned experimental: $exp_dir" >> ~/phase3-cleanup-log.txt
done < ~/experimental-worktrees.txt
```

#### Expected Phase 3 Results:
- 2-3 experimental worktrees removed
- 50-100MB disk space recovered
- Complete documentation of experimental findings
- Archive preservation for future reference

## Risk Mitigation and Recovery Procedures

### Emergency Recovery Plan

#### Immediate Rollback Procedure
```bash
# If issues detected during cleanup, immediate rollback steps:

# 1. Stop all cleanup operations
pkill -f "git worktree remove"

# 2. Restore from backup if needed
cd ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)

# 3. Recreate accidentally removed worktrees
# (Use backup documentation to guide recreation)
```

#### Branch Recovery Procedure
```bash
# Recover accidentally removed branches:

# 1. Check if branch still exists on remote
git ls-remote origin | grep branch-name

# 2. Recreate local branch
git branch branch-name origin/branch-name

# 3. Recreate worktree
git worktree add path/to/worktree branch-name
```

#### Data Recovery Verification
```bash
# Verify no important data lost:

# 1. Compare pre/post cleanup inventories
diff ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)/cleanup-log.md <(git worktree list)

# 2. Check for any missing active branches
git branch -a | grep -v "(HEAD\|master\|main\|dev\|stage)"

# 3. Verify all active agent sessions have valid worktrees
cat agentic-development/branch-tracking/active-branches.json | jq -r '.branches[].tuvens-docs[].worktree' | while read path; do
    if [ ! -d "$path" ]; then
        echo "Missing worktree: $path"
    fi
done
```

### Rollback Triggers

**Immediate rollback required if**:
- Any agent reports missing active work
- Uncommitted changes discovered after cleanup
- Central tracking system shows inconsistencies
- Build/test systems fail due to missing branches

## Success Validation and Metrics

### Success Criteria
- **Disk Space Recovery**: 1-2GB storage freed
- **Worktree Count Reduction**: From 65+ to <30 active worktrees
- **Zero Data Loss**: All important work preserved and accessible
- **System Stability**: All development workflows continue functioning
- **Agent Efficiency**: Improved workspace navigation and clarity

### Validation Checklist

#### Post-Cleanup System Health Check
```bash
# 1. Verify git repository health
for repo in tuvens-docs tuvens-client tuvens-api tuvens-mobile eventdigest-ai; do
    cd "/Users/ciarancarroll/Code/Tuvens/$repo"
    git fsck --full
    git worktree list | wc -l
done

# 2. Verify central tracking accuracy
cd /Users/ciarancarroll/Code/Tuvens/tuvens-docs
node agentic-development/scripts/update-branch-tracking.js --action=validate

# 3. Test agent workflow functionality
# Create test worktree to ensure system still works
test_branch="test/post-cleanup-validation"
git checkout dev
git checkout -b "$test_branch"
git worktree add "worktrees/test/validation" "$test_branch"
cd "worktrees/test/validation"
echo "# Test" > test.md
git add test.md && git commit -m "test: post-cleanup validation"
cd ../..
git worktree remove "worktrees/test/validation"
git branch -D "$test_branch"
```

#### Completion Documentation
```bash
# Generate completion report
cat > ~/tuvens-worktree-cleanup-$(date +%Y%m%d-%H%M)/completion-report.md << EOF
# Orphaned Worktree Cleanup Completion Report

**Date**: $(date)  
**Issue**: tuvens-docs#161  
**Agent**: Vibe Coder  

## Results Summary
- **Phase 1 (Merged)**: [count] worktrees cleaned, [size] recovered
- **Phase 2 (Stale)**: [count] worktrees cleaned, [size] recovered  
- **Phase 3 (Experimental)**: [count] worktrees cleaned, [size] recovered
- **Total Impact**: [total count] worktrees removed, [total size] recovered

## Safety Verification
- ✅ Pre-cleanup backup completed
- ✅ No uncommitted work lost
- ✅ All active branches preserved
- ✅ Central tracking system updated
- ✅ Agent workflows validated

## Next Steps
- Regular maintenance schedule implemented
- Automated cleanup system enhanced
- Agent workflow discipline improvements
- Monitoring and prevention measures active

EOF
```

## Maintenance and Prevention

### Ongoing Maintenance Schedule

#### Weekly (Automated)
- Central branch tracking system updates
- Cleanup queue population from merged branches
- Automated cleanup execution for safe branches

#### Monthly (Manual Review)
- Stale branch analysis and cleanup
- Disk space usage monitoring
- Safety procedure review and updates

#### Quarterly (Comprehensive)
- Full ecosystem worktree health check
- Cleanup procedure optimization
- Agent workflow efficiency analysis

### Prevention Strategies

#### Enhanced Agent Workflow
```bash
# Template for agent completion workflow
cat > ~/.tuvens-agent-completion-checklist << EOF
# Agent Task Completion Checklist

When completing any development task:

1. **Commit and Push**
   - [ ] All changes committed with clear messages
   - [ ] Branch pushed to origin
   - [ ] No uncommitted work remaining

2. **Pull Request**
   - [ ] PR created with clear description
   - [ ] All checks passing
   - [ ] Review requested if required

3. **Central Tracking**
   - [ ] Branch status updated in tracking system
   - [ ] Cleanup eligibility marked if merged
   - [ ] Related branches noted

4. **Local Cleanup**
   - [ ] Worktree removed after successful merge
   - [ ] Local branch cleaned up
   - [ ] Workspace organized

EOF
```

#### Automated Prevention
- **Worktree lifecycle tracking** in central system
- **Cleanup reminders** for agents after merge
- **Disk space monitoring** with automated alerts
- **Workflow integration** with completion procedures

---

**Approval Required**: DevOps Agent approval before Phase 2 execution  
**Emergency Contact**: Repository maintainer for any data loss concerns  
**Next Review**: 2025-09-18 (30 days post-completion)  

*This action plan ensures safe, systematic cleanup of orphaned worktrees while maintaining development workflow integrity and preventing future accumulation.*