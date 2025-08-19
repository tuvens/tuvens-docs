# AI Agent Safety & Governance

## Overview

The AI agent safety and governance system enforces critical safety rules and quality standards across all agent operations. This system prevents destructive actions, ensures compliance with CLAUDE.md safety protocols, and maintains consistent agent behaviors.

## System Components (1 workflow)

**Workflows**: `branch-protection.yml`

## Core Functions

### CLAUDE.md Safety Rule Enforcement
- Validates agents follow naming conventions and safety protocols
- Ensures CLAUDE.md safety files exist and are properly maintained
- Prevents agents from bypassing established safety boundaries
- Validates safety rule completeness and accuracy

### Branch Protection
- Prevents agents from directly committing to protected branches (main, stage, test)
- Enforces proper branch targeting in pull requests  
- Validates branch naming follows `{agent}/{type}/{description}` convention
- Blocks unsafe operations that could affect production systems

### Quality Gates
- Ensures infrastructure requirements are met before merges
- Validates workflow configurations and dependencies
- Performs automated safety checks on agent modifications
- Maintains code quality standards across all agent work

## Value to Agentic Development

- ✅ **Safety first** - Prevents agents from making destructive changes
- ✅ **Consistent patterns** - Enforces standard agent behaviors across all repositories
- ✅ **Quality control** - Automated validation of agent work
- ✅ **Governance compliance** - Ensures all agents follow established protocols

## Safety Integration Points

### CLAUDE.md Safety Integration
- **Validation**: `branch-protection.yml` enforces CLAUDE.md compliance
- **Safety Rules**: All workflows respect safety boundaries defined in CLAUDE.md
- **Agent Behavior**: Agents must follow CLAUDE.md rules; workflows will enforce them
- **Compliance Checking**: Automated validation ensures safety file completeness

### Branch Protection Rules
- **Protected Branches**: main, stage, test branches cannot receive direct commits
- **PR Targeting**: Feature branches must target `dev` branch, not protected branches
- **Naming Validation**: All branches must follow proper agent naming conventions
- **Emergency Procedures**: Special handling for emergency hotfixes to stage branch

### Quality Validation
- **Pre-commit Hooks**: Static safety validation hooks prevent common violations
- **Workflow Validation**: GitHub Actions validate safety compliance automatically  
- **Enhanced Error Messages**: Detailed guidance when validation fails
- **Interactive Tools**: Command-line validation tools for immediate feedback

## Detailed Workflow Functions

### branch-protection.yml
- **Purpose**: Enforces safety rules and naming conventions
- **Triggers**: Pull request events, push events to protected branches
- **Actions**: Validates branch names, CLAUDE.md compliance, safety rules
- **Agent Impact**: Validates agent work against safety standards
- **Blocking Behavior**: Prevents unsafe operations from completing

## Safety Tools and Commands

### Pre-commit Hooks
Static safety validation hooks are available to prevent common violations:
- **Branch naming validation** - Ensures proper {agent}/{type}/{description} format
- **Protected branch checks** - Prevents direct commits to main/stage/test
- **CLAUDE.md validation** - Verifies safety file completeness
- **Safety rules check** - Scans for secrets and policy violations

Setup: `pip install pre-commit && pre-commit install`

### Interactive Validation
- **`./scripts/branch-check`** - Command-line validation of current repository state
- **Enhanced workflow error messages** - Detailed guidance when validation fails
- **Branch tracking integration** - Automatic validation status recording

### Safety Validation Scripts
Individual validation components available in `scripts/hooks/`:
- `check-branch-naming.sh` - Validates branch naming conventions
- `validate-claude-md.sh` - Ensures CLAUDE.md completeness and accuracy
- `check-protected-branches.sh` - Prevents direct commits to protected branches
- `scan-secrets.sh` - Detects potential secrets or sensitive information

## Best Practices for Agents

### Working Within Safety Boundaries
1. **Follow Naming Conventions**: Always use `{agent}/{type}/{description}` format
2. **Target Correct Branches**: Feature branches → dev, hotfixes → stage only
3. **Maintain CLAUDE.md**: Keep safety files current and complete
4. **Respect Protections**: Never attempt to bypass safety validations
5. **Use Pre-commit Hooks**: Set up local validation before committing

### Quality Assurance
1. **Validate Before Committing**: Run local checks before pushing changes
2. **Read Error Messages**: Safety workflows provide detailed guidance
3. **Fix Issues Promptly**: Address safety violations immediately
4. **Document Exceptions**: Rare exceptions require proper documentation and approval

### Emergency Procedures
1. **Stop Immediately**: If safety violations are detected, stop all work
2. **Create Recovery Branch**: Use `{agent}/recovery/{original-branch-name}` pattern  
3. **Document Issues**: Create GitHub issue with `emergency` label
4. **Request Manual Intervention**: Safety violations may require human oversight

## Troubleshooting Safety Issues

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

### Pre-commit Hook Issues
**Symptoms**: Commits blocked by pre-commit hooks
**Causes**:
- Missing or outdated pre-commit installation
- Hook configuration errors
- Files failing safety validation

**Solutions**:
```bash
# Install or update pre-commit
pip install pre-commit && pre-commit install

# Run hooks manually to identify issues
pre-commit run --all-files
```

### Protected Branch Violations  
**Symptoms**: Push rejected, protection rule violations
**Causes**:
- Direct commits to main/stage/test branches
- Incorrect PR target branches
- Missing required status checks

**Solutions**:
```bash
# Check current branch
git branch --show-current

# Move commits to proper feature branch
git checkout -b {agent}/feature/{description}
git cherry-pick {commit-hash}

# Update PR target branch
gh pr edit {pr-number} --base dev
```

## Compliance Validation

The safety and governance system works in conjunction with:
- `.github/workflows/branch-protection.yml` - Automated validation with enhanced error messages
- `.pre-commit-config.yaml` - Local pre-commit safety hooks
- `scripts/hooks/` - Individual safety validation scripts  
- `scripts/branch-check` - Interactive validation command
- `CLAUDE.md` - Central safety rule definitions
- Agent-specific configuration files in `.claude/agents/`

## Emergency Protocols

### Safety Escalation
- **If unsure about safety implications, ask for explicit confirmation**
- **Stop and request guidance if encountering unfamiliar patterns**
- **Never proceed with operations that could affect production systems**
- **Always verify changes in development environment first**

### Incident Response
- **Immediately report any safety rule violations**
- **Document any unexpected behavior or system changes**
- **Preserve evidence of issues for debugging**
- **Follow established escalation procedures**

---

**Last Updated**: 2025-08-19  
**Version**: 2.0 - Extracted from main workflow guide  
**Maintained By**: DevOps Agent  

*This document is part of the Tuvens workflow infrastructure. For safety issues, create a GitHub issue with the `agent-safety` label.*