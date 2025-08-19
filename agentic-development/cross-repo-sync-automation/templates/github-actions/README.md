# GitHub Actions Workflow Templates

This directory contains reusable GitHub Actions workflow templates for automated documentation synchronization and repository management.

## Workflow Templates

### 📊 Documentation Automation
- **`auto-documentation.yml`** - Automated documentation generation and updates
- **`central-tracking-handler.yml`** - Central branch tracking and coordination workflow

### 🔄 Repository Management
- **`branch-lifecycle.yml`** - Branch creation, management, and cleanup automation
- **`notify-repositories-test.yml`** - Cross-repository notification testing workflow

### ⚠️ Additional Templates
- **`../repository-verification-workflow.yml`** - Repository verification workflow (generated template)

## Use Cases

### For DevOps Engineers
- **CI/CD Pipeline Setup**: Deploy workflows to automate documentation and branch management
- **Cross-Repository Coordination**: Use central tracking to manage multi-repo projects
- **Quality Assurance**: Implement automated verification and testing workflows
- **Infrastructure as Code**: Standardize repository automation across the organization

### For Development Teams
- **Documentation Automation**: Automatically generate and update project documentation
- **Branch Management**: Streamline feature branch creation and cleanup processes
- **Testing Integration**: Automated testing of cross-repository communication
- **Workflow Standardization**: Consistent automation patterns across all repositories

### For Project Managers
- **Progress Tracking**: Monitor branch lifecycle and documentation status
- **Process Automation**: Reduce manual overhead in multi-repository projects
- **Quality Control**: Ensure consistent documentation and branch management
- **Resource Optimization**: Automate repetitive tasks to free up developer time

## Agent Selection Guide

### Recommended Agents by Workflow Type

#### **devops** - Primary workflow maintenance
- Modifying GitHub Actions workflows
- Updating automation logic and triggers
- Managing workflow secrets and environment variables
- Repository workflow deployment and configuration

#### **vibe-coder** - Documentation workflows
- Auto-documentation workflow content
- Notification message templates
- README and workflow documentation updates
- Content generation automation

#### **node-dev** or **laravel-dev** - Backend integration
- API integration workflows
- Server-side automation triggers
- Database and service integration workflows
- Backend-specific testing automation

#### **Any specialist agent** - Technology-specific workflows
- For workflows specific to particular tech stacks
- When integrating with specialized tools or services
- For domain-specific automation requirements

## Workflow Details

### Core Features

#### Auto-Documentation (`auto-documentation.yml`)
- Automatically generates documentation from code comments
- Updates README files and API documentation
- Integrates with documentation generation tools
- Triggers on code changes and scheduled intervals

#### Central Tracking Handler (`central-tracking-handler.yml`)
- Coordinates branch status across multiple repositories
- Manages cross-repository dependencies
- Provides centralized progress tracking
- Handles inter-repository communication

#### Branch Lifecycle (`branch-lifecycle.yml`)
- Automates branch creation with proper naming conventions
- Manages branch cleanup and archival
- Enforces branching policies and protection rules
- Integrates with pull request workflows

#### Repository Notification Testing (`notify-repositories-test.yml`)
- Tests cross-repository notification systems
- Validates communication channels
- Ensures notification templates work correctly
- Provides automated testing for repository coordination

### Deployment Guidelines

1. **Copy to target repository**: Place workflow files in `.github/workflows/` directory
2. **Configure secrets**: Set up required repository secrets and environment variables
3. **Update repository references**: Modify workflow files to match target repository structure
4. **Test workflows**: Use the notification testing workflow to validate setup
5. **Monitor execution**: Check workflow runs and adjust as needed

### Customization

#### Environment Variables
- Configure repository-specific settings through GitHub secrets
- Use environment variables for cross-repository URLs and tokens
- Set up notification targets and communication channels

#### Trigger Conditions
- Modify workflow triggers based on repository needs
- Adjust scheduling for documentation generation
- Configure branch protection and policy enforcement

#### Integration Points
- Customize webhook endpoints for external integrations
- Configure notification services (Slack, email, etc.)
- Set up monitoring and alerting systems

## Security Considerations

- **Secrets Management**: Use GitHub secrets for sensitive configuration
- **Permission Scoping**: Limit workflow permissions to required actions only
- **Cross-Repository Access**: Carefully manage repository access tokens
- **Audit Trail**: Ensure workflow actions are logged and auditable

## Maintenance

### Regular Updates
- Keep workflow actions up to date with latest versions
- Review and update security configurations
- Test workflows after GitHub Actions platform updates
- Update documentation to reflect workflow changes

### Monitoring
- Monitor workflow execution times and success rates
- Set up alerts for workflow failures
- Review workflow logs for optimization opportunities
- Track resource usage and optimize as needed