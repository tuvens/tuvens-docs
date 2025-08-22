# Qodo Code Review Automation

## Overview

This workflow automatically triggers Qodo (formerly CodiumAI) code reviews on pull requests in the Tuvens ecosystem. It ensures consistent code quality by automatically requesting reviews without manual intervention.

## How It Works

### Automatic Triggering
The workflow triggers Qodo reviews by:
1. **Detecting new PRs**: When a PR is opened, reopened, or updated with new commits
2. **Checking for existing reviews**: Prevents duplicate review requests
3. **Posting the trigger comment**: Adds `@CodiumAI-Agent /review` to the PR
4. **Adding status updates**: Provides feedback about the review status

### Workflow Features

#### Smart Detection
- Checks if Qodo has already been triggered or has reviewed the PR
- Prevents duplicate review requests
- Cleans up old trigger comments on PR updates

#### Manual Triggering
- Can be manually triggered via workflow dispatch
- Useful for retriggering reviews or testing

#### Status Tracking
- Adds `qodo-review-requested` label to PRs
- Posts status comments explaining what's being reviewed
- Logs all actions for debugging

## Configuration

### GitHub Workflow File
Location: `.github/workflows/qodo-review-automation.yml`

### Trigger Events
- `pull_request`: opened, synchronize, reopened
- `pull_request_target`: for external contributor PRs
- `workflow_dispatch`: manual triggering with PR number

### Required Permissions
```yaml
permissions:
  contents: read
  pull-requests: write
  issues: write
```

## Usage

### Automatic Usage
Simply create a pull request. The workflow will:
1. Automatically detect the new PR
2. Check if review is needed
3. Trigger Qodo review if not already done
4. Post status updates

### Manual Usage
To manually trigger a review:
1. Go to Actions tab in GitHub
2. Select "Qodo Code Review Automation"
3. Click "Run workflow"
4. Enter the PR number
5. Click "Run workflow"

### Monitoring Reviews
After triggering, Qodo will:
- Analyze the code changes
- Post review comments on specific lines
- Provide suggestions for improvements
- Flag potential issues

## What Qodo Reviews

### Code Quality
- Best practices adherence
- Code style consistency
- Naming conventions
- Code organization

### Bug Detection
- Logic errors
- Edge cases
- Null pointer issues
- Type mismatches

### Security
- Vulnerability detection
- Input validation
- Authentication issues
- Data exposure risks

### Performance
- Inefficient algorithms
- Memory leaks
- Database query optimization
- Caching opportunities

### Documentation
- Missing comments
- Unclear function purposes
- API documentation gaps
- README updates needed

## Customization

### Excluding PRs
To exclude specific PRs from automatic review:
- Add `skip-qodo` label to the PR
- Or modify the workflow conditions

### Review Configuration
Qodo behavior can be customized by:
- Adding `.qodo.yml` configuration file
- Specifying review rules and preferences
- Setting severity thresholds

## Troubleshooting

### Review Not Triggering
If Qodo review doesn't trigger:
1. Check workflow runs in Actions tab
2. Verify PR is not from protected branches
3. Ensure Qodo integration is active
4. Check for existing review comments

### Duplicate Reviews
If multiple reviews appear:
1. The cleanup job should remove duplicates
2. Manually delete old trigger comments
3. Check workflow execution logs

### Review Taking Too Long
Qodo reviews typically complete within 2-5 minutes:
- Large PRs may take longer
- Check Qodo service status
- Consider splitting large PRs

## Integration with Other Workflows

### PR Merge Requirements
- Can be configured as required check
- Blocks merge until review passes
- Integrates with branch protection rules

### Multi-Agent Coordination
- Works alongside agent-generated PRs
- Supports agent workflow automation
- Compatible with `/start-session` system

## Best Practices

### For Developers
1. **Wait for review**: Let Qodo complete before addressing feedback
2. **Respond to comments**: Mark resolved issues as resolved
3. **Re-review on changes**: New commits trigger fresh reviews

### For Agents
1. **Include in PRs**: All agent PRs get automatic review
2. **Address feedback**: Incorporate Qodo suggestions
3. **Document changes**: Explain fixes in commit messages

## Maintenance

### Workflow Updates
To update the automation:
1. Modify `.github/workflows/qodo-review-automation.yml`
2. Test with manual trigger
3. Monitor automatic executions

### Label Management
Create these labels in your repository:
- `qodo-review-requested`: Auto-applied when review triggered
- `qodo-approved`: Can be manually added after review passes
- `skip-qodo`: Prevents automatic review triggering

## Related Documentation

- [GitHub Actions Workflow Infrastructure](../../agentic-development/workflows/README.md)
- [CI/CD Standards](../../agentic-development/workflows/cross-repository-development/cicd-standards.md)
- [DevOps Agent Guide](../../.claude/agents/devops.md)
- [Branch Protection Implementation](../../agentic-development/docs/branch-protection-implementation/)

## Support

For issues or questions:
1. Check workflow execution logs
2. Review Qodo documentation
3. Contact DevOps team
4. Open issue with `devops` label
