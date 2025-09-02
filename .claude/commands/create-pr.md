---
allowed-tools: Bash, Read
description: Create pull request with proper branch targeting using deterministic validation script
argument-hint: [pr-title] [target-branch-optional]
---

# Create Pull Request with Deterministic Branch Strategy Compliance

Create a GitHub pull request with comprehensive validation and proper branch targeting using the deterministic `create-pr.sh` script.

## Arguments Provided
`$ARGUMENTS`

## Current Context
Repository: !`git remote get-url origin | sed 's/.*\///' | sed 's/\.git//'`
Current branch: !`git branch --show-current`
Working directory: !`pwd`

## 🚨 CRITICAL: Use Deterministic Script

**This command now uses a deterministic shell script that handles ALL validation and PR creation logic.**

The script ensures:
- ✅ **100% Consistent Results** - Same logic every time, no interpretation variance
- ✅ **Comprehensive Validation** - All safety checks in one reliable place  
- ✅ **5-Branch Strategy Enforcement** - Deterministic branch targeting rules
- ✅ **Emergency Procedures** - Built-in hotfix approval workflow
- ✅ **Automated Labeling** - Consistent PR metadata and organization

## Script Execution

I'll run the deterministic script with your provided arguments:

```bash
# Execute the comprehensive PR creation script
./agentic-development/scripts/create-pr.sh "$@"
```

**Script Location**: `agentic-development/scripts/create-pr.sh`
**Script Version**: 1.0 (Comprehensive validation and creation)

## What the Script Does Automatically

### 🔍 **Validation Phase**
1. **Branch Naming**: Validates `{agent}/{type}/{description}` format
2. **Protected Branch Check**: Prevents PRs from main/stage/test branches
3. **Working Directory**: Ensures all changes are committed
4. **Remote Sync**: Verifies branch exists and is up-to-date on remote
5. **5-Branch Strategy**: Enforces proper target branch selection

### 🎯 **Target Branch Logic**
- **Default**: `dev` (standard workflow for features, bugs, docs)
- **Emergency**: `stage` (hotfixes only, requires approval and justification)
- **Blocked**: `main`, `test` (violates 5-branch strategy)
- **Custom**: Warns and requests confirmation for non-standard targets

### 📝 **PR Generation**
- **Smart Titles**: Auto-generates from branch name if not provided
- **Comprehensive Body**: Includes compliance info, checklists, and templates
- **Automatic Labels**: Adds labels based on branch type, agent, and target
- **Issue Linking**: Automatically detects and links related GitHub issues

### 🚨 **Emergency Hotfix Workflow**
When targeting `stage` branch:
- Requires explicit emergency confirmation
- Requests justification for audit trail
- Adds high-priority hotfix labels
- Reminds to create corresponding dev PR

### ✅ **Post-Creation Validation**
- Verifies PR targets correct branch
- Confirms 5-branch strategy compliance
- Adds appropriate labels and metadata
- Provides next steps and guidance

## Usage Examples

### Standard Feature PR
```bash
# Auto-generates title, targets dev branch
./agentic-development/scripts/create-pr.sh

# Custom title, targets dev branch  
./agentic-development/scripts/create-pr.sh "Add user authentication system"
```

### Documentation Update
```bash
# Auto-targets dev branch for docs
./agentic-development/scripts/create-pr.sh "Update API documentation"
```

### Emergency Hotfix
```bash
# Requires emergency approval and justification
./agentic-development/scripts/create-pr.sh "Fix critical security vulnerability" stage
```

### Get Help
```bash
# Show comprehensive help and examples
./agentic-development/scripts/create-pr.sh --help
```

## Script Output Example

```
ℹ️  Starting PR creation process...
Repository: tuvens-docs
Current branch: devops/feature/add-create-pr-command
Target branch: dev

ℹ️  Running comprehensive validation checks...
✅ Branch naming is valid
✅ Not on a protected branch  
✅ Working directory is clean
✅ Branch is synced with remote
✅ Targeting dev branch - standard workflow ✅
✅ All validation checks passed!

ℹ️  Creating pull request...
Title: Feature: Add Create PR Command
Source: devops/feature/add-create-pr-command
Target: dev

✅ Pull request created successfully!
🔗 PR URL: https://github.com/tuvens/tuvens-docs/pull/123
📋 PR #123

✅ Labels added successfully
✅ PR follows 5-branch strategy correctly
✅ Found issue references in commits - GitHub will auto-link

🎉 PR Creation Complete!
```

## Error Handling

The script provides clear error messages and stops execution on any validation failure:

**Branch Naming Issues:**
```
❌ Branch name 'invalid-name' doesn't follow {agent}/{type}/{description} format
```

**Uncommitted Changes:**
```  
❌ Working directory not clean. Commit all changes first:
M  file1.txt
?? file2.txt
```

**Protected Branch Violation:**
```
❌ Cannot create PR from protected branch: main. Create a feature branch from dev instead.
```

**Missing Remote Branch:**
```
❌ Branch 'feature-branch' not pushed to remote. Push first with: git push -u origin feature-branch
```

## Safety Features

### 🛡️ **5-Branch Strategy Enforcement**
- **Prevents** direct PRs to main/stage from feature branches
- **Enforces** proper workflow: `main ← stage ← test ← dev ← feature/*`
- **Validates** emergency hotfix justification for stage targeting
- **Blocks** PRs from protected branches (main/stage/test)

### 🔒 **Comprehensive Validation**
- **Branch naming** must follow agent conventions
- **Working directory** must be clean (no uncommitted changes)
- **Remote sync** ensures branch exists and is current
- **GitHub CLI** authentication and permissions verified

### 📋 **Audit Trail**
- **Emergency justifications** recorded in PR for hotfixes
- **Agent identification** tracked in PR metadata
- **Branch strategy compliance** documented and labeled
- **Creation timestamp** and script version logged

## Integration with Agent Workflows

### Agent Identity Recognition
The script automatically extracts agent information from branch names:
- `devops/feature/add-monitoring` → Agent: devops, Type: feature
- `react-dev/bugfix/component-render` → Agent: react-dev, Type: bugfix
- `vibe-coder/docs/update-readme` → Agent: vibe-coder, Type: docs

### Automatic Labeling
Based on branch analysis, adds relevant labels:
- **Task Type**: `enhancement`, `bug`, `documentation`, `ci/cd`
- **Agent**: `agent/devops`, `agent/react-dev`, etc.
- **Compliance**: `branch-strategy:compliant`
- **Target**: `target:dev`, `target:stage`

### Cross-Repository Compatibility
The script works across all Tuvens repositories:
- `tuvens-docs`, `tuvens-client`, `tuvens-api`
- `hi.events`, `eventsdigest-ai`
- Any future repositories following the same conventions

## Troubleshooting

### Common Issues

**GitHub CLI Not Found:**
```bash
# Install GitHub CLI
brew install gh
# Or: sudo apt install gh (Linux)
# Or: winget install --id GitHub.cli (Windows)
```

**Not Authenticated:**
```bash
# Login to GitHub CLI
gh auth login
```

**Permission Denied:**
```bash
# Make script executable
chmod +x agentic-development/scripts/create-pr.sh
```

**Script Not Found:**
```bash
# Verify you're in the right directory
ls agentic-development/scripts/create-pr.sh
```

### Debug Mode
For troubleshooting, you can add debug output:
```bash
# Run with verbose output
bash -x ./agentic-development/scripts/create-pr.sh
```

## Benefits of Deterministic Approach

### ✅ **Reliability**
- Same logic executes every time
- No human interpretation of validation rules
- Consistent error messages and handling
- Predictable outcomes across all agents

### ✅ **Maintainability**  
- Single script to update for changes
- Centralized validation logic
- Easy to add new features or fixes
- Version controlled with clear change history

### ✅ **Compliance**
- 100% enforcement of 5-branch strategy
- No possibility of bypassing safety checks
- Audit trail for all emergency procedures
- Consistent labeling and metadata

### ✅ **Agent Independence**
- All agents use identical PR creation process
- No agent-specific interpretation differences
- Consistent experience across the ecosystem
- Reduced training and documentation needs

## Reference Documentation

- **Script Source**: `agentic-development/scripts/create-pr.sh`
- **Branch Strategy**: `CLAUDE.md` - Pull Request Target Branch Rules
- **Agent Guidelines**: `.claude/agents/` - Agent-specific instructions
- **Safety Rules**: `CLAUDE.md` - Complete safety framework
- **Command Help**: Run script with `--help` flag for detailed usage

---

**Deterministic Excellence**: This command now provides 100% consistent, reliable PR creation with comprehensive validation and perfect 5-branch strategy compliance through automated script execution.