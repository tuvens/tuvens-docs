# CLAUDE.md - Safety Rules and Agent Guidelines for Tuvens-Docs

## Critical Claude Code Safety Rules

This repository contains the central documentation and coordination system for the Tuvens ecosystem. All agents working in this repository must follow these safety rules to maintain system integrity and prevent disruption of multi-repository workflows.

### Core Safety Principles

#### File Protection
- **NEVER delete files without explicit backup confirmation**
- **Always create backups before making destructive changes**
- **Never remove code comments unless they are provably false**
- **Only work within the project directory boundaries**
- **Preserve all existing agentic development workflow patterns**

#### Git Safety and Branch Protection
- **NEVER use --no-verify when committing code**
- **Always follow pre-commit hook protocols**
- **Never bypass quality checks or git hooks**
- **MUST follow the 5-branch strategy: main ← stage ← test ← dev ← feature/***
- **Never commit directly to main, stage, or test branches**
- **Never commit sensitive information (API keys, passwords, tokens)**

### Mandatory Branch Naming Conventions

All agents must follow these branch naming patterns:

```
Format: {agent-name}/{task-type}/{descriptive-name}

Examples:
- vibe-coder/feature/enhance-documentation
- docs-orchestrator/docs/api-reference-update
- devops/workflow/ci-pipeline-fix
- laravel-dev/feature/authentication-system
- react-dev/bugfix/component-rendering
```

#### Pull Request Target Branch Rules

**CRITICAL**: Always target the correct branch for pull requests:
- Feature branches → `dev` branch
- Bug fixes → `dev` branch  
- Documentation → `dev` branch
- Hotfixes → `stage` branch (emergency only)
- **NEVER target `main` or `stage` directly from feature branches**

#### Emergency Branch Recovery Procedures

If a branch becomes corrupted or needs recovery:
1. **STOP all work immediately**
2. Create recovery branch: `{agent}/recovery/{original-branch-name}`
3. Document the issue in GitHub issue with `emergency` label
4. Request manual intervention from repository maintainer
5. **Do not attempt automated fixes for branch corruption**

### Development Standards

#### Testing Protocol Requirements
- **Practice Test-Driven Development (TDD) - write tests before implementation**
- **Ensure comprehensive test coverage with NO EXCEPTIONS**
- **Run all existing tests before committing changes**
- **Create new tests for any new functionality**
- **Document test scenarios and edge cases**

#### Code Quality Standards
- **Prioritize simple, readable, and maintainable code**
- **Match existing code style within files**
- **Maintain existing project architecture and patterns**
- **Add meaningful commit messages following conventional commit format**
- **Document all significant changes and decisions**

### Repository-Specific Safety Rules

#### Agentic Development Integration
- **Preserve existing agent coordination patterns**
- **Maintain compatibility with `/start-session` integration**
- **Update branch tracking when creating new branches**
- **Follow established worktree organization patterns**
- **Respect agent role boundaries and responsibilities**

#### Cross-Repository Coordination
- **Ensure changes align with cross-repo sync automation**
- **Maintain documentation consistency across all markdown files**
- **Preserve GitHub Actions workflow integrity**
- **Coordinate with central branch tracking system**
- **Update related repositories through proper channels**

#### Documentation Integrity
- **Maintain README.md files in all directories**
- **Keep implementation reports current and accurate**
- **Preserve existing documentation structure**
- **Update status indicators when completing tasks**
- **Link related documentation and issues appropriately**

### Permission and Access Controls

#### Repository Boundaries
- **Only modify files within the current project directory**
- **Never access parent directories or system files**
- **Request explicit permission before executing destructive commands**
- **Treat tool failures as learning opportunities, not obstacles to bypass**

#### Sensitive Operations
- **Request confirmation before modifying GitHub Actions workflows**
- **Ask before changing agent configuration files**
- **Verify before updating central tracking system files**
- **Confirm before modifying cross-repository templates**

### Agent Interaction Guidelines

#### Collaboration Protocols
- **Be transparent about capabilities and limitations**
- **Admit when uncertain about implementation details**
- **Provide evidence when disagreeing with existing patterns**
- **Collaborate rather than simply execute commands**
- **Seek clarification before making assumptions about requirements**

#### Communication Standards
- **Update GitHub issues with progress and findings**
- **Use structured reporting in implementation documents**
- **Maintain clear commit messages and PR descriptions**
- **Document decisions and reasoning for future agents**
- **Report discoveries and recommendations clearly**

### Emergency Protocols

#### Safety Escalation
- **If unsure about safety implications, ask for explicit confirmation**
- **Stop and request guidance if encountering unfamiliar patterns**
- **Never proceed with operations that could affect production systems**
- **Always verify changes in development environment first**

#### Incident Response
- **Immediately report any safety rule violations**
- **Document any unexpected behavior or system changes**  
- **Preserve evidence of issues for debugging**
- **Follow established escalation procedures**

### Safety Tools and Commands

This repository includes safety tools for agents:

#### Pre-commit Hooks
Static safety validation hooks are available to prevent common violations:
- **Branch naming validation** - Ensures proper {agent}/{type}/{description} format
- **Protected branch checks** - Prevents direct commits to main/stage/test
- **CLAUDE.md validation** - Verifies safety file completeness
- **Safety rules check** - Scans for secrets and policy violations
- **Scope protection check** - Validates agents only modify files within their declared scope, includes DRY principle validation

Setup: `pip install pre-commit && pre-commit install`

#### Interactive Validation
- **`./scripts/branch-check`** - Command-line validation of current repository state
- **Enhanced workflow error messages** - Detailed guidance when validation fails
- **Branch tracking integration** - Automatic validation status recording

### Compliance Validation

This CLAUDE.md file works in conjunction with:
- `.github/workflows/branch-protection.yml` - Automated validation with enhanced error messages
- `.pre-commit-config.yaml` - Local pre-commit safety hooks
- `scripts/hooks/` - Individual safety validation scripts
- `scripts/branch-check` - Interactive validation command
- `agentic-development/branch-tracking/` - Central coordination system
- Agent-specific configuration files in `.claude/agents/`
- Cross-repository sync automation templates

**Last Updated**: 2025-08-08  
**Version**: 1.1 - Enhanced with pre-commit hooks and interactive validation  
**Maintained By**: Vibe Coder Agent

---

*This file is automatically validated by branch protection workflows and pre-commit hooks. Any modifications must pass safety checks before being merged.*