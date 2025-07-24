# Collaborative Development Protocol
*Team Collaboration Guide Template*

## 🎯 Overview
This document establishes protocols for safe, conflict-free collaborative development using git worktrees, dependency management, and architectural consistency.

## 🌳 Git Worktree Management Protocol

### Worktree Lifecycle
```bash
# 1. Create worktree from latest develop/main
git worktree add worktrees/feature-name -b feature/type/description develop

# 2. Set up dependencies (CRITICAL)
cd worktrees/feature-name
# Use your project's dependency installation commands
# npm ci --frozen-lockfile  # Node.js projects
# pip install -r requirements.txt  # Python projects
# bundle install  # Ruby projects

# 3. Work in isolation
# ... make changes ...

# 4. Pre-merge validation
# Run your project's validation scripts
# ./scripts/check-before-merge.sh

# 5. Clean merge
git checkout develop
git pull origin develop
git merge feature/type/description --no-ff

# 6. Cleanup worktree
git worktree remove worktrees/feature-name
git branch -d feature/type/description
```

### Worktree Naming Convention
- `worktrees/feature-{ticket-id}` - Feature development
- `worktrees/bugfix-{issue-number}` - Bug fixes
- `worktrees/hotfix-{severity}` - Production hotfixes
- `worktrees/experiment-{name}` - R&D work

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