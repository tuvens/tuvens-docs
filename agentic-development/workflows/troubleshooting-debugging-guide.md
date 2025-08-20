# Troubleshooting & Debugging Guide

## Overview

This comprehensive guide provides solutions for common workflow issues, debugging approaches, and troubleshooting strategies for the Tuvens agentic development infrastructure.

## Common Issues and Solutions

### Workflow Not Triggering
**Symptoms**: Expected automation not happening, no workflow runs visible
**Causes**: 
- Repository dispatch event not sent correctly
- Workflow file syntax errors
- Token permission issues

**Solutions**:
```bash
# Check recent workflow runs
gh run list --limit 10

# View specific workflow runs  
gh run view [run-id] --log

# Test repository dispatch
gh api repos/tuvens/tuvens-docs/dispatches \
  --field event_type='test' \
  --field 'client_payload={}'
```

### Branch Tracking Out of Sync
**Symptoms**: Branch tracking shows incorrect status, missing branches
**Causes**:
- Workflow execution failures
- Network issues during execution
- Concurrent updates causing conflicts

**Solutions**:
```bash
# Manually trigger branch tracking update
node agentic-development/scripts/update-branch-tracking.js --help

# Check branch tracking file consistency
cat agentic-development/branch-tracking/active-branches.json | jq .

# Reset branch tracking (if necessary)
git checkout HEAD -- agentic-development/branch-tracking/
```

### Agent Session Not Triggered
**Symptoms**: Critical feedback doesn't trigger agent assignment
**Causes**:
- Feedback priority not meeting thresholds
- Agent assignment rules not matching file patterns
- Session triggering script failures

**Solutions**:
```bash
# Test feedback processing manually
node agentic-development/scripts/process-gemini-feedback.js \
  --payload='{"title":"test","description":"critical security issue"}'

# Check agent session logs
cat agentic-development/branch-tracking/agent-sessions.json | jq .

# Verify agent assignment rules in process-gemini-feedback.js
```

### Safety Workflow Failures
**Symptoms**: PRs blocked, branch protection failures
**Causes**:
- Branch naming convention violations
- CLAUDE.md missing or invalid
- Attempts to commit to protected branches

**Solutions**:
```bash
# Check branch naming
./scripts/hooks/check-branch-naming.sh

# Validate CLAUDE.md
./scripts/hooks/validate-claude-md.sh

# Review safety rules
cat CLAUDE.md | grep -A 5 "Safety Rules"
```

## Debugging Workflow Execution

### GitHub Actions Logs
```bash
# View recent workflow runs
gh run list --workflow=branch-tracking.yml

# Get detailed logs for specific run
gh run view [run-id] --log

# Download logs for offline analysis
gh run download [run-id]
```

### Local Testing
```bash
# Test individual scripts locally
cd agentic-development/scripts/
node update-branch-tracking.js --help
node process-gemini-feedback.js --help

# Validate JSON files
cat ../branch-tracking/*.json | jq . > /dev/null && echo "Valid JSON"

# Check file permissions
ls -la ../branch-tracking/
```

### Network and API Issues
```bash
# Test GitHub API connectivity
gh api user

# Check repository dispatch permissions
gh api repos/tuvens/tuvens-docs --jq .permissions

# Verify token scopes
gh auth status
```

## Specialized Troubleshooting

### Context Generation Issues
**Symptoms**: Agents lack recent development context, outdated information
**Causes**:
- Context generation workflow failures
- Git history access issues
- API rate limits exceeded

**Solutions**:
```bash
# Manually trigger context generation
gh workflow run auto-documentation.yml

# Check context files
ls -la agentic-development/context/

# Validate context file integrity
cat agentic-development/context/agent-session-memory.json | jq .
```

### Infrastructure Health Issues
**Symptoms**: System performance degradation, tool failures
**Causes**:
- Resource constraints
- Dependency failures
- Configuration drift

**Solutions**:
```bash
# Check system resource usage
df -h && free -h

# Validate critical tools
node --version && npm --version && git --version

# Run infrastructure validation
gh workflow run infrastructure-validation.yml
```

### Cross-Repository Synchronization
**Symptoms**: Repositories out of sync, missing notifications
**Causes**:
- Event delivery failures
- Network connectivity issues
- API rate limiting

**Solutions**:
```bash
# Check recent cross-repo workflows
gh run list --workflow=notify-repositories.yml --limit 10

# Test repository connectivity
for repo in repo-a repo-b; do
  gh repo view tuvens/$repo
done

# Force synchronization
gh workflow run notify-repositories.yml --ref main
```

### Safety and Governance Issues
**Symptoms**: Safety validations failing, compliance violations
**Causes**:
- CLAUDE.md violations
- Branch protection rule violations
- Pre-commit hook failures

**Solutions**:
```bash
# Run safety validation
agentic-development/scripts/branch-check

# Check pre-commit hooks
pre-commit run --all-files

# Validate branch protection
gh api repos/tuvens/tuvens-docs/branches/main/protection
```

## Systematic Debugging Approach

### Step 1: Identify the Problem
1. **Gather Symptoms**: Document what's not working as expected
2. **Check Recent Changes**: Review recent commits and workflow changes
3. **Review Logs**: Examine GitHub Actions logs and system logs
4. **Isolate Scope**: Determine if issue is local or system-wide

### Step 2: Analyze the System State
```bash
# Check overall system health
gh run list --limit 20 --json status,conclusion,name

# Review branch tracking state
cat agentic-development/branch-tracking/active-branches.json | jq .

# Validate configurations
yq eval . .github/workflows/*.yml
```

### Step 3: Test Components Individually
```bash
# Test individual workflow components
gh workflow run infrastructure-validation.yml
gh workflow run branch-protection.yml

# Test scripts locally
node agentic-development/scripts/update-branch-tracking.js --help

# Validate external integrations
gh api rate_limit
gh api user
```

### Step 4: Apply Targeted Fixes
1. **Address Root Cause**: Fix the underlying issue, not just symptoms
2. **Test Thoroughly**: Verify fix works in isolation and integration
3. **Monitor Results**: Watch for successful workflow executions
4. **Document Solution**: Update documentation for future reference

### Step 5: Prevent Recurrence
1. **Improve Monitoring**: Add alerts for detected issue patterns
2. **Update Documentation**: Include new troubleshooting information
3. **Enhance Validation**: Add checks to prevent similar issues
4. **Review Processes**: Improve development processes if needed

## Advanced Debugging Techniques

### Workflow Log Analysis
```bash
# Extract error patterns from logs
gh run view [run-id] --log | grep -i error

# Analyze workflow timing
gh run view [run-id] --log | grep -E "^[0-9]{4}-[0-9]{2}-[0-9]{2}"

# Compare successful vs failed runs
gh run list --workflow=workflow-name --status=success --limit 5
gh run list --workflow=workflow-name --status=failure --limit 5
```

### System State Validation
```bash
# Comprehensive system validation
agentic-development/scripts/branch-check

# Check file integrity
find agentic-development/ -name "*.json" -exec jq . {} \; > /dev/null

# Validate workflow syntax
for file in .github/workflows/*.yml; do
  echo "Validating $file"
  yq eval . "$file" > /dev/null && echo "✓ Valid" || echo "✗ Invalid"
done
```

### Performance Analysis
```bash
# Analyze workflow performance
gh api repos/tuvens/tuvens-docs/actions/runs \
  --jq '.workflow_runs[0:10] | .[] | {name: .name, duration: (.updated_at | fromdateiso8601) - (.created_at | fromdateiso8601)}'

# Monitor resource usage patterns
# Check system resources during workflow execution
```

### Integration Testing
```bash
# Test end-to-end workflow integration
gh workflow run infrastructure-validation.yml

# Validate cross-repository coordination  
gh workflow run notify-repositories.yml

# Test agent coordination workflows
gh workflow run branch-tracking.yml
```

## Emergency Procedures

### System-Wide Failures
1. **Assess Impact**: Determine which systems are affected
2. **Isolate Issues**: Prevent cascade failures by isolating problems
3. **Emergency Rollback**: Roll back to last known good state if necessary
4. **Coordinate Response**: Notify relevant agents and maintainers
5. **Document Incident**: Create detailed incident report for analysis

### Data Integrity Issues
1. **Stop Operations**: Halt any operations that might worsen data issues
2. **Backup Current State**: Create backups before attempting fixes
3. **Validate Backups**: Ensure backups are complete and accessible
4. **Careful Recovery**: Restore data using validated procedures
5. **Verify Integrity**: Confirm data integrity after recovery

### Security Incidents
1. **Immediate Containment**: Isolate affected systems immediately
2. **Assess Breach Scope**: Determine what data or systems were compromised
3. **Revoke Credentials**: Rotate all potentially compromised credentials
4. **Document Evidence**: Preserve evidence for security analysis
5. **Follow Security Procedures**: Execute established security incident response

## Monitoring and Prevention

### Proactive Monitoring
- Set up automated alerts for common failure patterns
- Monitor system performance and resource utilization
- Track workflow success rates and execution times
- Monitor API usage and rate limits

### Preventive Measures
- Regular infrastructure health checks
- Automated testing of critical workflow paths
- Periodic review of system configurations
- Documentation maintenance and updates

### Continuous Improvement
- Analyze incident patterns for systemic issues
- Improve monitoring and alerting based on lessons learned
- Update troubleshooting documentation with new solutions
- Enhance system reliability through architecture improvements

---

**Last Updated**: 2025-08-19  
**Version**: 2.0 - Extracted from main workflow guide  
**Maintained By**: DevOps Agent  

*This document is part of the Tuvens workflow infrastructure. For persistent troubleshooting issues, create a GitHub issue with the `workflow-troubleshooting` label.*