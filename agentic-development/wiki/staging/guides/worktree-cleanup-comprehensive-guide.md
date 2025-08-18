# Comprehensive Worktree Cleanup Guide

**Purpose**: Complete guide for cleaning up orphaned worktrees and maintaining worktree hygiene across the Tuvens ecosystem  
**Target Audience**: DevOps agents, system maintainers, development team  
**Author**: Vibe Coder Agent  
**Date**: 2025-08-18  
**Version**: 1.0  

## Overview

The Tuvens multi-agent development system uses git worktrees extensively to enable parallel development across multiple agents and repositories. Over time, completed branches accumulate orphaned worktrees that consume disk space and create organizational clutter. This guide provides comprehensive procedures for safe, systematic cleanup of these resources.

### Current Situation Analysis

**Scale of Cleanup Needed:**
- **65+ worktree subdirectories** discovered across tuvens-docs repository alone
- **22+ completed branches** identified as requiring cleanup across ecosystem
- **Multiple repository worktree patterns** in use across:
  - `tuvens-docs` (documentation and coordination)
  - `tuvens-client` (frontend development)
  - `tuvens-api` (backend development)
  - `tuvens-mobile` (mobile applications)
  - `eventdigest-ai` (specialized AI workflows)

## Worktree Cleanup Categories

### 1. Merged and Completed Branches
**Definition**: Feature branches that have been successfully merged to `dev`, `stage`, or `main` branches  
**Risk Level**: Low - Safe for cleanup  
**Typical Examples**:
- `vibe-coder/feature/agent-workflow-instructions` (merged to dev)
- `devops/feature/fix-critical-wiki-document-issues` (completed PR)
- `frontend-dev/feature/auth-components` (merged and tested)

### 2. Abandoned or Stale Branches
**Definition**: Branches with no activity for 30+ days and no associated pull requests  
**Risk Level**: Medium - Requires verification before cleanup  
**Verification Required**:
- Check for uncommitted work
- Verify no active development references
- Confirm agent is not planning to resume work

### 3. Experimental or Test Branches
**Definition**: Temporary branches created for testing, prototyping, or experimentation  
**Risk Level**: Low-Medium - Usually safe but may contain valuable research  
**Examples**:
- `experiment/new-coordination-pattern`
- `test/integration-workflow`
- `prototype/mobile-sync-mechanism`

### 4. Emergency or Recovery Branches
**Definition**: Branches created during emergency procedures or system recovery  
**Risk Level**: High - Requires manual review  
**Special Handling**: Document findings before cleanup, preserve logs

## Safety Procedures

### Pre-Cleanup Safety Checklist

**CRITICAL: Complete ALL steps before proceeding with any cleanup**

#### 1. Backup and Documentation Review
```bash
# Create comprehensive backup of current state
mkdir -p ~/worktree-cleanup-$(date +%Y%m%d)
cd ~/worktree-cleanup-$(date +%Y%m%d)

# Document current worktree state
find /Users/ciarancarroll/Code/Tuvens -name "worktrees" -type d -exec find {} -maxdepth 3 -type d \; > worktree-inventory.txt

# Document git worktree status for each repository
for repo in tuvens-docs tuvens-client tuvens-api tuvens-mobile eventdigest-ai; do
    if [ -d "/Users/ciarancarroll/Code/Tuvens/$repo" ]; then
        echo "=== $repo ===" >> git-worktree-status.txt
        cd "/Users/ciarancarroll/Code/Tuvens/$repo"
        git worktree list >> ~/worktree-cleanup-$(date +%Y%m%d)/git-worktree-status.txt
        echo "" >> ~/worktree-cleanup-$(date +%Y%m%d)/git-worktree-status.txt
    fi
done
```

#### 2. Uncommitted Work Scan
```bash
# Scan for uncommitted changes in all worktrees
find /Users/ciarancarroll/Code/Tuvens -name "worktrees" -type d -exec find {} -name ".git" -type f \; | while read gitfile; do
    workdir=$(dirname "$gitfile")
    echo "Checking: $workdir"
    cd "$workdir"
    if ! git diff --quiet HEAD; then
        echo "UNCOMMITTED CHANGES: $workdir" >> ~/worktree-cleanup-$(date +%Y%m%d)/uncommitted-changes.txt
    fi
    if ! git diff --quiet --cached; then
        echo "STAGED CHANGES: $workdir" >> ~/worktree-cleanup-$(date +%Y%m%d)/staged-changes.txt
    fi
done
```

#### 3. Branch Status Verification
```bash
# Verify merge status of all branches
for repo in tuvens-docs tuvens-client tuvens-api tuvens-mobile eventdigest-ai; do
    if [ -d "/Users/ciarancarroll/Code/Tuvens/$repo" ]; then
        cd "/Users/ciarancarroll/Code/Tuvens/$repo"
        echo "=== $repo Branch Status ===" >> ~/worktree-cleanup-$(date +%Y%m%d)/branch-status.txt
        git branch -r --merged dev >> ~/worktree-cleanup-$(date +%Y%m%d)/branch-status.txt 2>/dev/null
        git branch -r --no-merged dev >> ~/worktree-cleanup-$(date +%Y%m%d)/branch-status.txt 2>/dev/null
        echo "" >> ~/worktree-cleanup-$(date +%Y%m%d)/branch-status.txt
    fi
done
```

### Automated Safety Tools

#### Central Branch Tracking Integration
The existing central branch tracking system provides automated safety features:

**Location**: `agentic-development/branch-tracking/`
**Script**: `../scripts/cleanup-merged-branches.sh`

**Features**:
- Automated detection of merged branches
- Queue-based cleanup system
- Safety confirmation prompts
- Rollback capabilities
- Comprehensive logging

**Usage**:
```bash
# Check cleanup queue status
cd /path/to/tuvens-docs
cat agentic-development/branch-tracking/cleanup-queue.json

# Run automated cleanup (with safety prompts)
./agentic-development/scripts/cleanup-merged-branches.sh
```

#### Manual Safety Verification Tools
```bash
# Verify worktree is properly linked to git
git worktree list | grep -F "$(pwd)"

# Check for untracked files that might be important
find . -name "*.log" -o -name "*.md" -o -name "*.json" | head -20

# Verify branch merge status
git log --oneline --graph --decorate $(git branch --show-current) ^dev | head -10
```

## Step-by-Step Cleanup Procedures

### Phase 1: Safe Merged Branch Cleanup

**Target**: Branches confirmed merged to dev/stage/main  
**Risk Level**: Low  
**Estimated Impact**: 15-20 worktrees  

#### Step 1.1: Identify Merged Branches
```bash
cd /Users/ciarancarroll/Code/Tuvens/tuvens-docs
git branch -r --merged dev | grep -E "(vibe-coder|devops|feature)" > ~/merged-branches.txt
```

#### Step 1.2: Process Each Merged Branch
```bash
while read branch; do
    branch_name=$(echo "$branch" | sed 's/origin\///')
    echo "Processing: $branch_name"
    
    # Check if worktree exists
    worktree_path="worktrees/$(echo $branch_name | tr '/' '/')"
    if [ -d "$worktree_path" ]; then
        echo "Found worktree: $worktree_path"
        # Add to cleanup queue for automated processing
        echo "$branch_name" >> ~/cleanup-queue-phase1.txt
    fi
done < ~/merged-branches.txt
```

#### Step 1.3: Execute Cleanup Using Existing Tools
```bash
# Use the existing automated cleanup system
./agentic-development/scripts/cleanup-merged-branches.sh
```

### Phase 2: Stale Branch Analysis and Cleanup

**Target**: Branches with no activity for 30+ days  
**Risk Level**: Medium  
**Estimated Impact**: 5-10 worktrees  

#### Step 2.1: Identify Stale Branches
```bash
# Find branches with no commits in last 30 days
find /Users/ciarancarroll/Code/Tuvens/tuvens-docs/worktrees -type d -mtime +30 -maxdepth 3 | while read dir; do
    if [ -f "$dir/.git" ]; then
        cd "$dir"
        last_commit=$(git log -1 --format="%cd" --date=short 2>/dev/null)
        echo "$dir: $last_commit" >> ~/stale-worktrees.txt
    fi
done
```

#### Step 2.2: Manual Review Process
```bash
# For each stale worktree, perform manual review
while read line; do
    worktree_path=$(echo "$line" | cut -d':' -f1)
    echo "Reviewing: $worktree_path"
    
    cd "$worktree_path"
    
    # Check for uncommitted work
    if ! git diff --quiet HEAD || ! git diff --quiet --cached; then
        echo "HAS UNCOMMITTED WORK: $worktree_path" >> ~/manual-review-required.txt
        continue
    fi
    
    # Check if branch has open PRs
    branch_name=$(git branch --show-current)
    echo "Check PR status for: $branch_name" >> ~/pr-check-needed.txt
    
done < ~/stale-worktrees.txt
```

#### Step 2.3: Safe Cleanup of Verified Stale Branches
```bash
# Only cleanup branches confirmed safe through manual review
while read branch_path; do
    echo "Cleaning up verified stale branch: $branch_path"
    
    cd "$(dirname "$branch_path")"
    worktree_name=$(basename "$branch_path")
    
    # Final safety check
    cd "$branch_path"
    if git diff --quiet HEAD && git diff --quiet --cached; then
        echo "Safe to cleanup: $branch_path"
        cd ..
        git worktree remove "$worktree_name" --force
        echo "Cleaned: $branch_path" >> ~/cleanup-log-phase2.txt
    fi
done < ~/verified-safe-for-cleanup.txt
```

### Phase 3: Experimental and Test Branch Cleanup

**Target**: Temporary experimental branches  
**Risk Level**: Low-Medium  
**Estimated Impact**: 3-5 worktrees  

#### Step 3.1: Identify Experimental Branches
```bash
# Find branches with experimental naming patterns
find /Users/ciarancarroll/Code/Tuvens -name "worktrees" -type d -exec find {} -type d -name "*experiment*" -o -name "*test*" -o -name "*prototype*" \; > ~/experimental-worktrees.txt
```

#### Step 3.2: Document Experimental Work
```bash
# Create documentation backup of experimental findings
mkdir -p ~/experimental-branch-backup/$(date +%Y%m%d)

while read exp_path; do
    if [ -f "$exp_path/.git" ]; then
        branch_name=$(cd "$exp_path" && git branch --show-current)
        
        # Create documentation of experimental work
        echo "# Experimental Branch: $branch_name" > ~/experimental-branch-backup/$(date +%Y%m%d)/${branch_name//\//_}.md
        echo "**Path**: $exp_path" >> ~/experimental-branch-backup/$(date +%Y%m%d)/${branch_name//\//_}.md
        echo "**Date**: $(date)" >> ~/experimental-branch-backup/$(date +%Y%m%d)/${branch_name//\//_}.md
        echo "" >> ~/experimental-branch-backup/$(date +%Y%m%d)/${branch_name//\//_}.md
        
        cd "$exp_path"
        echo "## Commit History" >> ~/experimental-branch-backup/$(date +%Y%m%d)/${branch_name//\//_}.md
        git log --oneline >> ~/experimental-branch-backup/$(date +%Y%m%d)/${branch_name//\//_}.md
        
        echo "## File Changes" >> ~/experimental-branch-backup/$(date +%Y%m%d)/${branch_name//\//_}.md
        git diff --name-only HEAD~5 2>/dev/null >> ~/experimental-branch-backup/$(date +%Y%m%d)/${branch_name//\//_}.md
    fi
done < ~/experimental-worktrees.txt
```

#### Step 3.3: Cleanup Experimental Branches
```bash
# Cleanup experimental branches after documentation
while read exp_path; do
    if [ -d "$exp_path" ] && [ -f "$exp_path/.git" ]; then
        cd "$exp_path"
        branch_name=$(git branch --show-current)
        
        # Final backup of any unique files
        mkdir -p ~/experimental-branch-backup/$(date +%Y%m%d)/files/$branch_name
        find . -name "*.md" -newer $(git log -1 --format="%ct" HEAD~1 | xargs -I {} date -d @{} +%Y%m%d) -exec cp {} ~/experimental-branch-backup/$(date +%Y%m%d)/files/$branch_name/ \; 2>/dev/null
        
        # Remove worktree
        cd ..
        git worktree remove "$(basename "$exp_path")" --force
        echo "Experimental cleanup: $exp_path" >> ~/cleanup-log-phase3.txt
    fi
done < ~/experimental-worktrees.txt
```

## Recovery Procedures

### Emergency Recovery Plan

If cleanup causes issues, follow these recovery steps:

#### 1. Immediate Rollback
```bash
# Restore from backup (if available)
cd ~/worktree-cleanup-$(date +%Y%m%d)

# Recreate accidentally removed worktrees
while read branch_info; do
    repo=$(echo "$branch_info" | cut -d':' -f1)
    branch=$(echo "$branch_info" | cut -d':' -f2)
    path=$(echo "$branch_info" | cut -d':' -f3)
    
    cd "/Users/ciarancarroll/Code/Tuvens/$repo"
    git worktree add "$path" "$branch" 2>/dev/null || echo "Could not restore: $branch"
done < ~/accidentally-removed.txt
```

#### 2. Branch Recovery
```bash
# Recover lost branches from remote
git fetch --all
git branch -r | grep -E "(vibe-coder|devops|feature)" | while read remote_branch; do
    local_branch=$(echo "$remote_branch" | sed 's/origin\///')
    git branch "$local_branch" "$remote_branch" 2>/dev/null || echo "Branch exists: $local_branch"
done
```

#### 3. Worktree Recreation
```bash
# Recreate worktrees for recovered branches
git branch --list | grep -E "(vibe-coder|devops|feature)" | while read branch; do
    if [ ! -d "worktrees/$branch" ]; then
        git worktree add "worktrees/$branch" "$branch"
        echo "Recreated worktree: worktrees/$branch"
    fi
done
```

## Maintenance and Prevention

### Automated Maintenance Schedule

#### Daily Maintenance (Automated)
- **Branch tracking updates** via GitHub Actions
- **Merge detection** through webhook integration
- **Cleanup queue population** for merged branches

#### Weekly Maintenance (Manual Review)
- Review cleanup queue and execute automated cleanup
- Identify stale branches (>7 days no activity)
- Update documentation for any new worktree patterns

#### Monthly Maintenance (Comprehensive)
- Full worktree inventory and health check
- Review and update cleanup procedures
- Analyze disk space usage trends
- Update safety procedures based on learnings

### Prevention Strategies

#### 1. Improved Agent Workflow Discipline
```bash
# Template for agents completing work
echo "Agent completion checklist:" > ~/agent-completion-template.txt
echo "- [ ] All changes committed and pushed" >> ~/agent-completion-template.txt
echo "- [ ] Pull request created and merged" >> ~/agent-completion-template.txt
echo "- [ ] Worktree marked for cleanup in tracking system" >> ~/agent-completion-template.txt
echo "- [ ] Local cleanup executed" >> ~/agent-completion-template.txt
```

#### 2. Enhanced Central Tracking
- **Automatic worktree registration** when created
- **Lifecycle status tracking** (active, completed, stale)
- **Cleanup eligibility scoring** based on multiple factors
- **Agent notification system** for cleanup recommendations

#### 3. Disk Space Monitoring
```bash
# Weekly disk space monitoring script
create_monitoring_script() {
cat > ~/worktree-disk-monitor.sh << 'EOF'
#!/bin/bash
echo "Worktree Disk Usage Report - $(date)"
echo "=================================="

total_size=0
for repo in tuvens-docs tuvens-client tuvens-api tuvens-mobile eventdigest-ai; do
    if [ -d "/Users/ciarancarroll/Code/Tuvens/$repo/worktrees" ]; then
        size=$(du -sh "/Users/ciarancarroll/Code/Tuvens/$repo/worktrees" | cut -f1)
        echo "$repo worktrees: $size"
        
        # Count worktrees
        count=$(find "/Users/ciarancarroll/Code/Tuvens/$repo/worktrees" -maxdepth 2 -type d | wc -l)
        echo "  Worktree count: $count"
    fi
done

echo ""
echo "Cleanup recommendations:"
echo "- Run cleanup if total size > 2GB"
echo "- Review stale branches if count > 20 per repo"
EOF

chmod +x ~/worktree-disk-monitor.sh
}
```

## Success Metrics and Validation

### Cleanup Success Criteria

#### Quantitative Metrics
- **Disk space recovered**: Target 1-2GB reduction
- **Worktree count reduction**: From 65+ to <20 active worktrees
- **Cleanup time**: Complete process in <2 hours
- **Zero data loss**: All important work preserved

#### Qualitative Metrics
- **Organization improvement**: Clear, logical worktree structure
- **Agent efficiency**: Faster workspace navigation
- **Maintenance burden**: Reduced ongoing maintenance effort
- **Safety confidence**: No accidental loss of work

### Post-Cleanup Validation

#### 1. System Health Check
```bash
# Verify all repositories are healthy
for repo in tuvens-docs tuvens-client tuvens-api tuvens-mobile eventdigest-ai; do
    echo "=== Checking $repo ==="
    cd "/Users/ciarancarroll/Code/Tuvens/$repo"
    
    # Check git status
    git status --porcelain | wc -l
    
    # Check worktree consistency
    git worktree list | grep -c "worktrees"
    
    # Check branch health
    git branch -v | grep -c "gone"
    
    echo "Health check complete for $repo"
done
```

#### 2. Agent Workflow Validation
```bash
# Test agent workflow still functions
cd "/Users/ciarancarroll/Code/Tuvens/tuvens-docs"

# Test worktree creation
test_branch="test/cleanup-validation-$(date +%s)"
git checkout dev
git checkout -b "$test_branch"
git worktree add "worktrees/test/cleanup-validation" "$test_branch"

# Test agent environment
cd "worktrees/test/cleanup-validation"
echo "# Test" > test-file.md
git add test-file.md
git commit -m "test: validation after cleanup"

# Cleanup test
cd ../..
git worktree remove "worktrees/test/cleanup-validation"
git branch -D "$test_branch"
```

#### 3. Documentation Update
```bash
# Update tracking system to reflect cleanup
cd "/path/to/tuvens-docs/agentic-development/branch-tracking"

# Record cleanup completion
cat > last-major-cleanup.md << EOF
# Major Worktree Cleanup Completion

**Date**: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
**Agent**: Vibe Coder
**Issue**: tuvens-docs#161

## Results
- Worktrees cleaned: [count]
- Disk space recovered: [amount]
- Branches processed: [count]
- Safety procedures followed: ✅

## Next Scheduled Cleanup
- Date: $(date -d "+1 month" +"%Y-%m-%d")
- Type: Regular maintenance
- Expected scope: 5-10 worktrees

EOF
```

## Troubleshooting Common Issues

### Issue 1: Worktree Removal Fails
**Symptoms**: `git worktree remove` fails with permission errors  
**Solution**:
```bash
# Force removal with manual cleanup
git worktree remove --force path/to/worktree
# If that fails, manual filesystem cleanup:
rm -rf path/to/worktree
git worktree prune
```

### Issue 2: Lost Work Detection
**Symptoms**: Cleanup accidentally removes important uncommitted work  
**Solution**:
```bash
# Check git reflog for recovery opportunities
git reflog --all | grep "branch-name"
# Recreate worktree and recover from reflog
git worktree add path/to/recovered branch-name@{reflog-entry}
```

### Issue 3: Branch Tracking Inconsistencies
**Symptoms**: Central tracking system shows incorrect branch status  
**Solution**:
```bash
# Rebuild tracking from current state
cd agentic-development/scripts
node update-branch-tracking.js --action=rebuild --force
```

## Related Documentation

- [Worktree Organization Strategy](../workflows/worktree-organization.md)
- [Central Branch Tracking System](../branch-tracking/README.md)
- [Agent Workflow Documentation](../workflows/agent-terminal-prompts.md)
- [Safety and Security Protocols](../protocols/emergency-response-procedures.md)

---

**Next Review Date**: 2025-09-18  
**Maintenance Schedule**: Monthly comprehensive review, weekly automated cleanup  
**Responsible**: DevOps Agent (primary), Vibe Coder Agent (backup)  

*This guide represents the culmination of lessons learned from managing 65+ worktrees across the Tuvens multi-agent development ecosystem. Regular updates ensure procedures remain current and effective.*