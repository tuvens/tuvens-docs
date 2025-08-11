# Tuvens-Docs Documentation Tree

*Generated on: 2025-08-08*

## Project Statistics

**Files**: 304 files, 59 directories

### File Type Distribution
- .md: 266
- .sh: 18
- .yml: 8
- .json: 5
- .txt: 3
- .js: 2
- .yaml: 1
- (no extension): 1

### File Categories
- **Agent Configuration Files**: 0
- **GitHub Workflow Files**: 0  
- **Documentation Files**: 269
- **Script Files**: 20

## Agent Overview

**Total Agents**: 8

- **codehooks-dev**: `.claude/agents/codehooks-dev.md`
- **devops**: `.claude/agents/devops.md`
- **laravel-dev**: `.claude/agents/laravel-dev.md`
- **mobile-dev**: `.claude/agents/mobile-dev.md`
- **node-dev**: `.claude/agents/node-dev.md`
- **react-dev**: `.claude/agents/react-dev.md`
- **svelte-dev**: `.claude/agents/svelte-dev.md`
- **vibe-coder**: `.claude/agents/vibe-coder.md`

## GitHub Actions Workflows

**Total Workflows**: 7

- **branch-created**: `.github/workflows/branch-created.yml`
- **branch-deleted**: `.github/workflows/branch-deleted.yml`
- **branch-merged**: `.github/workflows/branch-merged.yml`
- **branch-protection**: `.github/workflows/branch-protection.yml`
- **branch-tracking**: `.github/workflows/branch-tracking.yml`
- **notify-repositories**: `.github/workflows/notify-repositories.yml`
- **vibe-coder-maintenance**: `.github/workflows/vibe-coder-maintenance.yml`

## Directory Structure

```
tuvens-docs/
agentic-development/
├── auto-generated/
├── branch-tracking/
│   ├── active-branches.json
│   ├── cleanup-queue.json
│   ├── merge-log.json
│   ├── README.md
│   └── task-groups.json
├── cross-repo-sync-automation/
│   ├── templates/
│   │   ├── _common/
│   │   │   ├── automated-verification-setup.md
│   │   │   ├── footer.md
│   │   │   ├── header-template.md
│   │   │   ├── help-section.md
│   │   │   ├── submodule-update-step.md
│   │   │   └── timeline-requirements.md
│   │   ├── _repo-specific/
│   │   │   ├── backend-completion.md
│   │   │   ├── backend-critical-changes.md
│   │   │   ├── backend-help-additions.md
│   │   │   ├── backend-quality-standards.md
│   │   │   ├── backend-specific-actions.md
│   │   │   ├── backend-verification.md
│   │   │   ├── frontend-completion.md
│   │   │   ├── frontend-critical-changes.md
│   │   │   ├── frontend-help-additions.md
│   │   │   ├── frontend-quality-standards.md
│   │   │   ├── frontend-specific-actions.md
│   │   │   ├── frontend-verification.md
│   │   │   ├── integration-completion.md
│   │   │   ├── integration-critical-changes.md
│   │   │   ├── integration-help-additions.md
│   │   │   ├── integration-quality-standards.md
│   │   │   ├── integration-specific-actions.md
│   │   │   ├── integration-verification.md
│   │   │   ├── mobile-completion.md
│   │   │   ├── mobile-critical-changes.md
│   │   │   ├── mobile-help-additions.md
│   │   │   ├── mobile-quality-standards.md
│   │   │   ├── mobile-specific-actions.md
│   │   │   ├── mobile-verification.md
│   │   │   └── README.md
│   │   ├── github-actions/
│   │   │   ├── auto-documentation.yml
│   │   │   ├── branch-lifecycle.yml
│   │   │   └── central-tracking-handler.yml
│   │   ├── backend-notification.md
│   │   ├── frontend-notification.md
│   │   ├── integration-notification.md
│   │   ├── mobile-notification.md
│   │   └── repository-verification-workflow.yml
│   ├── build-templates.sh
│   └── README.md
├── desktop-project-instructions/
│   ├── agents/
│   │   ├── devops.md
│   │   ├── laravel-dev.md
│   │   ├── node-dev.md
│   │   ├── react-dev.md
│   │   ├── svelte-dev.md
│   │   └── vibe-coder.md
│   ├── handoff-templates/
│   │   ├── complex-feature.md
│   │   ├── debugging.md
│   │   ├── refactoring.md
│   │   └── simple-task.md
│   ├── workflows/
│   │   ├── inter-agent-communication.md
│   │   └── system-improvement.md
│   └── README.md
├── scripts/
│   ├── agent-status.sh
│   ├── cleanup-merged-branches.sh
│   ├── maintenance-check.sh
│   ├── mobile-dev-prompt.txt
│   ├── setup-agent-task.sh
│   ├── system-status.sh
│   ├── update-branch-tracking.js
│   ├── validate-environment.sh
│   └── vibe-coder-prompt.txt
├── workflows/
│   ├── cross-repository-development/
│   │   ├── cicd-standards.md
│   │   ├── code-review-standards.md
│   │   ├── collaboration-protocols.md
│   │   ├── development-workflow.md
│   │   ├── monitoring-observability.md
│   │   ├── quality-gates.md
│   │   ├── README.md
│   │   ├── repository-structure.md
│   │   └── technical-standards.md
│   ├── agent-terminal-prompts.md
│   ├── branching-strategy.md
│   ├── central-branch-tracking.md
│   ├── start-session-integration.md
│   ├── tuvens-branching-strategy.md
│   └── worktree-organization.md
└── README.md
docs-orchestrator/
└── docs-branch-protection-implementation/
    ├── agentic-development/
    │   ├── branch-protection-implementation/
    │   │   ├── README.md
    │   │   ├── task-01-claude-safety-rules.md
    │   │   ├── task-02-branch-protection-workflow.md
    │   │   ├── task-03-pre-merge-safety.md
    │   │   ├── task-04-pr-templates.md
    │   │   ├── task-05-testing-validation.md
    │   │   └── task-06-mobile-adaptation.md
    │   ├── cross-repo-sync-automation/
    │   │   ├── templates/
    │   │   │   ├── _common/
    │   │   │   │   ├── automated-verification-setup.md
    │   │   │   │   ├── footer.md
    │   │   │   │   ├── header-template.md
    │   │   │   │   ├── help-section.md
    │   │   │   │   ├── submodule-update-step.md
    │   │   │   │   └── timeline-requirements.md
    │   │   │   ├── _repo-specific/
    │   │   │   │   ├── backend-completion.md
    │   │   │   │   ├── backend-critical-changes.md
    │   │   │   │   ├── backend-help-additions.md
    │   │   │   │   ├── backend-quality-standards.md
    │   │   │   │   ├── backend-specific-actions.md
    │   │   │   │   ├── backend-verification.md
    │   │   │   │   ├── frontend-completion.md
    │   │   │   │   ├── frontend-critical-changes.md
    │   │   │   │   ├── frontend-help-additions.md
    │   │   │   │   ├── frontend-quality-standards.md
    │   │   │   │   ├── frontend-specific-actions.md
    │   │   │   │   ├── frontend-verification.md
    │   │   │   │   ├── integration-completion.md
    │   │   │   │   ├── integration-critical-changes.md
    │   │   │   │   ├── integration-help-additions.md
    │   │   │   │   ├── integration-quality-standards.md
    │   │   │   │   ├── integration-specific-actions.md
    │   │   │   │   ├── integration-verification.md
    │   │   │   │   ├── mobile-completion.md
    │   │   │   │   ├── mobile-critical-changes.md
    │   │   │   │   ├── mobile-help-additions.md
    │   │   │   │   ├── mobile-quality-standards.md
    │   │   │   │   ├── mobile-specific-actions.md
    │   │   │   │   ├── mobile-verification.md
    │   │   │   │   └── README.md
    │   │   │   ├── github-actions/
    │   │   │   │   ├── auto-documentation.yml
    │   │   │   │   ├── branch-lifecycle.yml
    │   │   │   │   └── central-tracking-handler.yml
    │   │   │   ├── backend-notification.md
    │   │   │   ├── frontend-notification.md
    │   │   │   ├── integration-notification.md
    │   │   │   ├── mobile-notification.md
    │   │   │   └── repository-verification-workflow.yml
    │   │   ├── build-templates.sh
    │   │   └── README.md
    │   ├── desktop-project-instructions/
    │   │   ├── agents/
    │   │   │   ├── devops.md
    │   │   │   ├── laravel-dev.md
    │   │   │   ├── node-dev.md
    │   │   │   ├── react-dev.md
    │   │   │   ├── svelte-dev.md
    │   │   │   └── vibe-coder.md
    │   │   ├── handoff-templates/
    │   │   │   ├── complex-feature.md
    │   │   │   ├── debugging.md
    │   │   │   ├── refactoring.md
    │   │   │   └── simple-task.md
    │   │   ├── workflows/
    │   │   │   ├── inter-agent-communication.md
    │   │   │   └── system-improvement.md
    │   │   └── README.md
    │   ├── scripts/
    │   │   ├── cleanup-merged-branches.sh
    │   │   ├── maintenance-check.sh
    │   │   ├── mobile-dev-prompt.txt
    │   │   ├── setup-agent-task.sh
    │   │   └── validate-environment.sh
    │   ├── workflows/
    │   │   ├── cross-repository-development/
    │   │   │   ├── cicd-standards.md
    │   │   │   ├── code-review-standards.md
    │   │   │   ├── collaboration-protocols.md
    │   │   │   ├── development-workflow.md
    │   │   │   ├── monitoring-observability.md
    │   │   │   ├── quality-gates.md
    │   │   │   ├── README.md
    │   │   │   ├── repository-structure.md
    │   │   │   └── technical-standards.md
    │   │   ├── agent-terminal-prompts.md
    │   │   ├── branching-strategy.md
    │   │   ├── central-branch-tracking.md
    │   │   ├── start-session-integration.md
    │   │   ├── tuvens-branching-strategy.md
    │   │   └── worktree-organization.md
    │   └── README.md
    ├── tuvens-docs/
    │   ├── hi-events-integration/
    │   │   ├── api-reference/
    │   │   │   ├── authentication.md
    │   │   │   ├── cross-app-auth-endpoints.md
    │   │   │   ├── data-structures.md
    │   │   │   ├── error-response-format.md
    │   │   │   ├── frontend-integration-endpoints.md
    │   │   │   ├── http-status-codes.md
    │   │   │   ├── integration-examples.md
    │   │   │   ├── rate-limiting.md
    │   │   │   ├── README.md
    │   │   │   ├── security-considerations.md
    │   │   │   └── webhook-endpoints.md
    │   │   ├── frontend-integration/
    │   │   │   ├── analytics-tracking.md
    │   │   │   ├── backend-endpoints.md
    │   │   │   ├── database-schema-updates.md
    │   │   │   ├── environment-configuration.md
    │   │   │   ├── frontend-implementation-steps.md
    │   │   │   ├── implementation-status.md
    │   │   │   ├── README.md
    │   │   │   ├── security-considerations.md
    │   │   │   └── testing-integration.md
    │   │   ├── api-requirements.md
    │   │   ├── architecture.md
    │   │   ├── authentication-flow.md
    │   │   ├── backend-testing-guide.md
    │   │   ├── frontend-integration-spec.md
    │   │   ├── implementation-status.md
    │   │   ├── README.md
    │   │   ├── testing-guide.md
    │   │   ├── troubleshooting.md
    │   │   └── webhook-implementation.md
    │   ├── implementation-guides/
    │   │   └── cross-app-authentication/
    │   │       ├── database-implementation/
    │   │       │   ├── backup-recovery.md
    │   │       │   ├── database-maintenance.md
    │   │       │   ├── database-schema.md
    │   │       │   ├── database-seeding.md
    │   │       │   ├── entity-definition.md
    │   │       │   ├── migration-script.md
    │   │       │   └── README.md
    │   │       ├── 01-requirements-architecture.md
    │   │       └── README.md
    │   ├── integration-examples/
    │   │   └── frontend-integration/
    │   │       ├── README.md
    │   │       └── svelte-examples.md
    │   ├── repositories/
    │   │   ├── eventsdigest-ai.md
    │   │   ├── hi-events.md
    │   │   ├── index.md
    │   │   ├── integration-registry.md
    │   │   ├── tuvens-api.md
    │   │   ├── tuvens-client.md
    │   │   └── tuvens-docs.md
    │   ├── shared-protocols/
    │   │   ├── frontend-integration/
    │   │   │   ├── accessibility-standards.md
    │   │   │   ├── analytics-monitoring.md
    │   │   │   ├── api-integration-patterns.md
    │   │   │   ├── architecture-standards.md
    │   │   │   ├── component-patterns.md
    │   │   │   ├── deployment-cicd.md
    │   │   │   ├── design-system-integration.md
    │   │   │   ├── performance-optimization.md
    │   │   │   ├── README.md
    │   │   │   ├── security-best-practices.md
    │   │   │   └── testing-standards.md
    │   │   └── mobile-development/
    │   │       └── README.md
    │   └── authentication-priority.md
    ├── .git
    └── README.md
scripts/
├── hooks/
│   ├── check-branch-naming.sh
│   ├── check-protected-branches.sh
│   ├── check-safety-rules.sh
│   └── validate-claude-md.sh
├── branch-check
├── check-before-merge.sh
├── generate-doc-tree.js
└── test.sh
tuvens-docs/
├── hi-events-integration/
│   ├── api-reference/
│   │   ├── authentication.md
│   │   ├── cross-app-auth-endpoints.md
│   │   ├── data-structures.md
│   │   ├── error-response-format.md
│   │   ├── frontend-integration-endpoints.md
│   │   ├── http-status-codes.md
│   │   ├── integration-examples.md
│   │   ├── rate-limiting.md
│   │   ├── README.md
│   │   ├── security-considerations.md
│   │   └── webhook-endpoints.md
│   ├── frontend-integration/
│   │   ├── analytics-tracking.md
│   │   ├── backend-endpoints.md
│   │   ├── database-schema-updates.md
│   │   ├── environment-configuration.md
│   │   ├── frontend-implementation-steps.md
│   │   ├── implementation-status.md
│   │   ├── README.md
│   │   ├── security-considerations.md
│   │   └── testing-integration.md
│   ├── api-requirements.md
│   ├── architecture.md
│   ├── authentication-flow.md
│   ├── backend-testing-guide.md
│   ├── frontend-integration-spec.md
│   ├── implementation-status.md
│   ├── README.md
│   ├── testing-guide.md
│   ├── troubleshooting.md
│   └── webhook-implementation.md
├── implementation-guides/
│   └── cross-app-authentication/
│       ├── database-implementation/
│       │   ├── backup-recovery.md
│       │   ├── database-maintenance.md
│       │   ├── database-schema.md
│       │   ├── database-seeding.md
│       │   ├── entity-definition.md
│       │   ├── migration-script.md
│       │   └── README.md
│       ├── 01-requirements-architecture.md
│       └── README.md
├── integration-examples/
│   └── frontend-integration/
│       ├── README.md
│       └── svelte-examples.md
├── repositories/
│   ├── eventsdigest-ai.md
│   ├── hi-events.md
│   ├── index.md
│   ├── integration-registry.md
│   ├── tuvens-api.md
│   ├── tuvens-client.md
│   └── tuvens-docs.md
├── shared-protocols/
│   ├── frontend-integration/
│   │   ├── accessibility-standards.md
│   │   ├── analytics-monitoring.md
│   │   ├── api-integration-patterns.md
│   │   ├── architecture-standards.md
│   │   ├── component-patterns.md
│   │   ├── deployment-cicd.md
│   │   ├── design-system-integration.md
│   │   ├── performance-optimization.md
│   │   ├── README.md
│   │   ├── security-best-practices.md
│   │   └── testing-standards.md
│   └── mobile-development/
│       └── README.md
└── authentication-priority.md
.pre-commit-config.yaml
CLAUDE.md
ENHANCEMENT_DOCUMENTATION.md
IMPLEMENTATION_NOTES.md
IMPLEMENTATION_REPORT.md
package.json
README.md
```

## Key Components

### Agentic Development System
- **Branch Tracking**: `agentic-development/branch-tracking/`
- **Agent Scripts**: `agentic-development/scripts/`
- **Agent Configurations**: `.claude/agents/`

### Safety and Validation
- **CLAUDE.md**: Repository safety rules and guidelines
- **Pre-commit Hooks**: `scripts/hooks/` and `.pre-commit-config.yaml`
- **Branch Protection**: `.github/workflows/branch-protection.yml`

### Documentation Structure
- **Auto-generated**: `agentic-development/auto-generated/`
- **Implementation Notes**: Root-level documentation files
- **Agent Instructions**: Agent-specific guidance and templates

---

*This documentation tree is automatically generated by `scripts/generate-doc-tree.js`*
*Run `npm run generate-docs` to update this file*
