# Automatic Issue Creation for Test Failures

## Overview

The TDD testing framework includes an automatic issue creation system that creates GitHub issues when tests fail, ensuring agents are notified of failures and can take corrective action.

## How It Works

### 1. **Test Failure Detection**

When the TDD testing framework runs and detects failures:
- Monitors both `tdd-tests` and `comprehensive-validation` jobs
- Triggers only on actual test failures (not infrastructure issues)
- Extracts agent information from branch names (e.g., `vibe-coder/feature/xyz` → `vibe-coder`)

### 2. **Automatic Issue Creation**

**Issue Title Format:**
```
TDD Test Failure: PR #123 - vibe-coder
TDD Test Failure: vibe-coder/feature/branch-name - vibe-coder
```

**Issue Labels:**
- `test-failure` - Identifies this as a test failure issue
- `urgent` - Indicates immediate attention needed  
- `{agent-name}` - Agent responsible (e.g., `vibe-coder`)
- `auto-created` - Indicates automatic creation

**Issue Assignment:**
- Automatically assigns to the responsible agent
- Falls back to repository maintainers if agent not found

### 3. **Duplicate Prevention**

The system prevents duplicate issues by:
- Searching for existing open `test-failure` issues for the same branch/PR
- Updating existing issues instead of creating new ones
- Using branch names and PR numbers for precise matching

### 4. **Automatic Resolution**

When tests start passing:
- Automatically closes related failure issues
- Adds resolution comment with timestamp
- Provides success confirmation

## Issue Content Structure

Each auto-created issue includes:

### **Header Information**
- Agent mention (`@vibe-coder`)
- Branch name and failure type
- Timestamp and PR link (if applicable)

### **Failure Details**
- Specific test suites that failed
- Link to GitHub Actions run with detailed logs
- Status of each test category

### **Reproduction Instructions**
```bash
# Pull your branch
git checkout vibe-coder/feature/branch-name

# Run the same tests that failed
npm run test-pr

# Or run specific test suites
npm run test:tdd:unit
npm run test:tdd:integration
npm run test:tdd:syntax
```

### **Common Fix Patterns**
- Unit test failures → Check function implementations
- Integration failures → Verify workflow configurations  
- Syntax errors → Run syntax validation
- Linting issues → Fix code style problems

### **Resources and Next Steps**
- Links to TDD documentation
- Local development commands
- Step-by-step resolution guide

## Workflow Integration

### **PR Creation Workflow**
1. Agent creates PR with branch like `vibe-coder/feature/new-feature`
2. TDD tests run automatically
3. **If tests fail:**
   - Issue auto-created: "TDD Test Failure: PR #123 - vibe-coder"
   - Agent gets GitHub notification
   - You manually tell agent: "Check issues, fix test failures"
4. **If tests pass:**
   - PR proceeds normally
   - No issues created

### **Direct Push Workflow**
1. Agent pushes to protected branch
2. TDD tests run on merge
3. **If tests fail:**
   - Issue auto-created: "TDD Test Failure: branch-name - agent"
   - Merge may be blocked depending on branch protection
4. **If tests pass:**
   - Merge completes successfully

## Agent Response Process

### **When You See a Test Failure Issue:**

1. **Read the Issue Details**
   - Check which tests failed and why
   - Review the GitHub Actions logs link
   - Note the specific branch/PR affected

2. **Reproduce Locally**
   ```bash
   git checkout your-branch-name
   npm run test-pr
   ```

3. **Fix the Issues**
   - Address failing unit tests
   - Fix syntax or linting problems
   - Update integration test configurations

4. **Verify and Commit**
   ```bash
   # Verify tests pass locally
   npm run test-pr
   
   # Commit your fixes
   git add .
   git commit -m "fix: resolve TDD test failures"
   git push
   ```

5. **Automatic Resolution**
   - Tests will re-run automatically on push
   - Issue will auto-close when tests pass
   - You'll get a success notification

## Example Issue

```markdown
# 🚨 TDD Test Failure - Immediate Action Required

**Agent**: @vibe-coder  
**Branch**: `vibe-coder/feature/implement-new-feature`  
**Failure Type**: TDD Tests Failed
**Timestamp**: 2025-08-25T15:30:00.000Z

**PR**: https://github.com/tuvens/tuvens-docs/pull/123

## 🔍 Failure Details

The TDD testing framework detected failures in your code changes:

- **TDD Tests Status**: failure
- **Comprehensive Validation**: success
- **GitHub Actions Run**: [View Details](https://github.com/tuvens/tuvens-docs/actions/runs/12345)

## 🛠️ How to Reproduce and Fix

### 1. Reproduce Locally
```bash
# Pull your branch
git checkout vibe-coder/feature/implement-new-feature

# Run the same tests that failed
npm run test-pr

# Or run specific test suites
npm run test:tdd:unit
npm run test:tdd:integration
npm run test:tdd:syntax
```

[... rest of template ...]
```

## Benefits

### **For Repository Maintainers**
- **Guaranteed Notification**: No failed tests go unnoticed
- **Manual Control**: You decide when to direct agents to check issues
- **Clear Audit Trail**: All failures documented and tracked
- **Automatic Cleanup**: Issues auto-close when resolved

### **For Agents**
- **Clear Instructions**: Detailed steps for reproduction and fixing
- **Specific Context**: Know exactly which tests failed and why
- **Local Testing**: Commands provided to reproduce issues locally
- **Automatic Updates**: No need to manually close resolved issues

### **For Development Workflow**
- **Quality Assurance**: Prevents broken code from being merged
- **Fast Feedback**: Issues created immediately when tests fail
- **Documentation**: Complete history of failures and resolutions
- **Integration**: Works seamlessly with existing TDD framework

## Configuration

The auto-issue system is configured in:
- `.github/workflows/tdd-testing.yml` - Main workflow with failure handling
- Branch name patterns determine agent assignment
- Issue templates embedded in workflow configuration
- Labels and assignees automatically managed

## Troubleshooting

### **Issue Not Created After Test Failure**
- Check GitHub Actions logs for workflow errors
- Verify repository permissions for issue creation
- Confirm branch naming follows agent patterns

### **Duplicate Issues Created**
- Check for existing test-failure issues
- Verify branch/PR matching logic
- Review issue search query accuracy

### **Issue Not Auto-Closing**
- Confirm tests are actually passing
- Check branch/PR matching in resolution workflow
- Verify issue labels and search criteria

---

**Summary**: The automatic issue creation system ensures test failures are immediately documented and assigned to responsible agents, providing a simple but effective way to maintain code quality without complex notification infrastructure.