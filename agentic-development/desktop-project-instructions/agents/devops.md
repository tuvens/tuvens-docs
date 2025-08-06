# Starting DevOps Sessions

## When to Use DevOps Agent
- Docker configuration and optimization
- Kubernetes deployments
- CI/CD pipeline setup
- Infrastructure as Code (Terraform)
- Monitoring and logging setup
- Security and compliance

## Starting a Claude Code Session

### For DevOps Tasks

```bash
/start-session devops
```

The command will analyze the current conversation and create:
1. GitHub issue with task details
2. Isolated worktree in appropriate repository
3. Prompt file with DevOps-specific context

### Manual Session Start

If starting Claude Code manually, use this prompt structure:

```markdown
Load: .claude/agents/devops.md

Task: [Infrastructure or deployment need]
Repository: [affected repository]
Component: [service/infrastructure piece]
Worktree: [repo]/devops/[descriptive-branch-name]

Start by reviewing the existing infrastructure configuration and deployment patterns.
```

## Task Types and Context Loading

### Docker Configuration
```markdown
Load: .claude/agents/devops.md
Load: [repo]/Dockerfile

Optimize Docker setup for [service]:
- Base image: [current/desired]
- Build optimization: [multi-stage, caching]
- Security: [non-root user, secrets]
- Size reduction: [techniques to apply]
```

### Kubernetes Deployment
```markdown
Load: .claude/agents/devops.md
Load: k8s/deployments/

Create Kubernetes resources for [service]:
- Deployment: [replicas, resources]
- Service: [type, ports]
- Ingress: [routing rules]
- ConfigMaps/Secrets: [configuration]
```

### CI/CD Pipeline
```markdown
Load: .claude/agents/devops.md
Load: .github/workflows/

Implement CI/CD for [workflow]:
- Triggers: [push, PR, schedule]
- Jobs: [build, test, deploy]
- Environments: [dev, staging, prod]
- Secrets: [what's needed]
```

### Monitoring Setup
```markdown
Load: .claude/agents/devops.md

Configure monitoring for [service]:
- Metrics: [what to track]
- Logs: [aggregation strategy]
- Alerts: [thresholds, notifications]
- Dashboards: [visualizations needed]
```

## Key Context Files

Always available in devops sessions:
- `.claude/agents/devops.md` - Agent identity and DevOps expertise
- Infrastructure configuration files
- Deployment documentation
- Security policies and compliance requirements

## Common Patterns

### Repository Locations
- `.github/workflows/` - GitHub Actions
- `k8s/` or `kubernetes/` - K8s manifests
- `terraform/` - Infrastructure as Code
- `docker/` - Docker configurations
- `scripts/` - Deployment scripts

### Best Practices
- Infrastructure as Code for everything
- Implement least privilege access
- Use secrets management properly
- Automate repetitive tasks
- Document runbooks and procedures

## Integration Considerations

### With Development Teams
- Coordinate deployment windows
- Ensure smooth rollback procedures
- Plan for zero-downtime deployments

### With Security
- Implement security scanning
- Manage secrets properly
- Follow compliance requirements

## DevOps Tools

### Local Testing
```bash
docker-compose up
kubectl apply --dry-run=client
terraform plan
```

### Validation
```bash
dockerfile lint
kubeval manifests/
tflint
```

## Handoff Checklist

Before starting Claude Code session:
- [ ] Infrastructure requirements clear
- [ ] Security constraints identified
- [ ] Performance targets defined
- [ ] Rollback strategy planned
- [ ] GitHub issue number (if using /start-session)