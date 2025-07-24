# Claude Code Integration & Collaboration Protocols

## 🎯 Overview

This document establishes standardized protocols for Claude Code integration across the Tuvens ecosystem, ensuring consistent AI-assisted development practices and optimal collaboration between human developers and Claude.

## 🏗️ Claude Code Setup Standards

### Repository Structure for Claude Integration

Every Tuvens repository must include:

```
repository-name/
├── CLAUDE.md                           # Primary Claude instructions
├── docs/
│   ├── .claude/
│   │   ├── commands/                   # Custom Claude commands
│   │   │   ├── commands.json          # Command registry
│   │   │   ├── ask-question.md        # Question assistance
│   │   │   ├── commit-helper.md       # Git commit assistance
│   │   │   ├── frontend-dev.md        # Frontend development
│   │   │   ├── report-bug.md          # Bug reporting
│   │   │   ├── resolve-issue.md       # Issue resolution
│   │   │   ├── suggest-improvement.md # Improvement suggestions
│   │   │   ├── test-tdd.md           # TDD assistance
│   │   │   └── update-current-state.md # Status updates
│   │   ├── INTEGRATION_REGISTRY.md    # Cross-repo integrations
│   │   ├── project-instructions.md    # Detailed project context
│   │   ├── task-routing.md            # File discovery routing
│   │   └── workflow.md                # Development workflows
│   └── .temp/                         # Temporary documentation
└── .claudeignore                      # Files to exclude from Claude
```

### CLAUDE.md Template

```markdown
# Claude Code Instructions for {PROJECT_NAME}

## 🚨 MANDATORY FIRST STEP - READ THIS EVERY SESSION

**ALWAYS load this file at the start of every Claude Code session:**

```
docs/.claude/project-instructions.md
```

This file contains:
- ✅ Complete project context and structure
- ✅ Safety rules and branch protection guidelines  
- ✅ Branding guidelines (correct name: "{PROJECT_NAME}")
- ✅ Task routing for efficient file discovery
- ✅ TDD workflow requirements (80% coverage)
- ✅ Quality gates and development standards
- ✅ Enterprise CI/CD protocols and security requirements
- ✅ Collaboration tools and worktree management

## 🚨 Critical Workflow Rules

### /resolve-issue Command Protocol
When using `/resolve-issue`, you MUST:
1. Resolve all specified issues completely
2. **ALWAYS close issues with `gh issue close` before completing the task**
3. Include descriptive comments explaining the resolution
4. Never leave issues open after resolution

This is MANDATORY - no exceptions!

## 🏗️ CI/CD & Security Protocols

### MANDATORY CI/CD Compliance
When working on code changes, you MUST:
1. **Security First**: All code changes trigger security scanning
2. **Quality Gates**: 80% test coverage REQUIRED
3. **Branch Protection**: Never commit directly to `main` or `develop`
4. **Collaboration Validation**: Use validation commands before major changes
5. **Testing Protocol**: Follow TDD - Write tests first, then implementation

---

**Remember: Load `docs/.claude/project-instructions.md` FIRST in every session!**
```

### .claudeignore Template

```
# Claude Code ignore patterns

# Dependencies
node_modules/
__pycache__/
venv/
env/

# Build outputs
build/
dist/
.next/
out/
target/

# Logs and temporary files
*.log
.temp/
tmp/

# IDE and OS files
.vscode/
.idea/
.DS_Store

# Environment variables
.env*

# Large generated files
*.min.js
*.min.css
*.bundle.js

# Test artifacts
test-results/
coverage/

# Certificates and keys
*.pem
*.key
*.crt
```

## 🔒 Dependency Management Protocol

### Lock File Strategy
1. **Lock files are SACRED** - never edit manually
2. **All worktrees use identical lock versions**
3. **Project-specific lock files**: 
   - Node.js: `package-lock.json`
   - Python: `requirements.lock` or `Pipfile.lock`
   - Ruby: `Gemfile.lock`
   - Other: Follow your ecosystem's conventions

### Dependency Update Workflow
```bash
# Only update dependencies in main branch
git checkout develop

# Update dependencies (project-specific commands)
# npm update                    # Node.js
# pip-compile requirements.in   # Python
# bundle update                 # Ruby

# Test the updates
# npm test && npm run build     # Node.js
# pytest && python -m build    # Python
# bundle exec rspec && rake build  # Ruby

# Commit lock file changes
git add [lock-files]
git commit -m "deps: update dependencies with security fixes"

# All new worktrees will inherit these versions
```

## 🏗️ Architectural Consistency Protocol

### File Structure Standards
Customize this structure for your project:
```
src/
├── components/        # Reusable components
├── services/          # Business logic
├── utils/            # Utility functions
├── types/            # Type definitions
└── tests/            # Test files mirror src structure
```

### Import Patterns
Use consistent import patterns for your project:
```
// Use absolute imports with project aliases
import { Component } from '@/components/Component';
import { Service } from '@/services/Service';
import type { Type } from '@/types/Type';

// Avoid deep relative imports
// ❌ import '../../../utils/helper';
// ✅ import '@/utils/helper';
```

## 🛠️ Compatibility Validation Protocol

### Pre-commit Validation
All commits must pass:
```bash
# Type checking (if applicable)
# npm run check        # TypeScript
# mypy .               # Python
# rubocop              # Ruby

# Linting
# npm run lint         # JavaScript/TypeScript
# flake8 .             # Python
# rubocop              # Ruby

# Unit tests
# npm run test         # Node.js
# pytest               # Python
# bundle exec rspec    # Ruby

# Build verification
# npm run build        # Node.js/frontend
# python -m build      # Python
# rake build           # Ruby
```

### Library Compatibility Matrix
Customize this table for your project dependencies:
| Library | Version | Compatibility Notes |
|---------|---------|-------------------|
| [Framework] | [Version] | [Notes] |
| [Library 1] | [Version] | [Notes] |
| [Library 2] | [Version] | [Notes] |

## 🤝 Conflict Resolution Protocol

### Code Conflicts
1. **Automatic resolution** for:
   - Lock file changes (use develop branch version)
   - Generated files (regenerate)
   - Documentation timestamps

2. **Manual resolution required** for:
   - Source code logic
   - Configuration changes
   - Dependency versions

3. **Resolution workflow**:
   ```bash
   # Abort merge and start clean
   git merge --abort
   
   # Get latest changes
   git fetch origin develop
   git rebase origin/develop
   
   # Resolve conflicts iteratively
   git add .
   git rebase --continue
   
   # Verify everything works
   # Run your project's test suite
   ```

## 📋 Daily Workflow Checklist

### Starting Work
- [ ] Create worktree from latest develop
- [ ] Install dependencies with locked versions
- [ ] Verify tests pass
- [ ] Check code quality tools

### During Development
- [ ] Follow established patterns
- [ ] Write tests for new features
- [ ] Maintain test coverage requirements
- [ ] Use consistent coding style

### Before Merging
- [ ] Run pre-merge validation
- [ ] Resolve any conflicts properly
- [ ] Verify build succeeds
- [ ] Update documentation if needed
- [ ] Close related GitHub issues

## 🚨 Emergency Protocols

### Broken Main Branch
1. **Identify the breaking commit**
2. **Create hotfix worktree**: `git worktree add worktrees/hotfix-urgent -b hotfix/urgent`
3. **Fix the issue with minimal changes**
4. **Fast-track through review process**
5. **Deploy and verify**

### Dependency Issues
1. **Clean dependencies**: Remove all dependency directories
2. **Reset to known good state**: `git checkout develop`
3. **Fresh install**: Reinstall all dependencies from lock files
4. **Verify everything works**: Run full test suite and build

This protocol ensures safe, predictable collaboration while maintaining code quality and preventing conflicts.