---
allowed-tools: Bash, Write, Read, Edit, Grep, LS, Task
description: ABC (Always Be Closing) task completion pressure system with structured checklist for merging PRs
argument-hint: [optional-task-context]
---

# ABC: Always Be Closing - Task Completion Pressure System

The ABC command applies structured pressure to close out tasks and merge PRs by providing an exact checklist of what needs to happen next. ABC maintains all development principles (TDD, DRY, KISS, D/E) while encouraging forward momentum.

## Arguments Provided
`$ARGUMENTS`

## Current Repository State
- Repository: !`git remote get-url origin | sed 's/.*\///' | sed 's/\.git//'`
- Current branch: !`git branch --show-current`
- Working directory: !`pwd`

## ABC Core Principle

**A**lways **B**e **C**losing: Every task should have a clear path to completion and merge. This command identifies exactly what step you need to take next rather than letting tasks sit idle.

## ABC Completion Checklist

I will analyze your current work state and provide a structured checklist with ABC pressure:

### Phase 1: Code Quality Validation ✅
- [ ] **Code Review Complete**: All code follows DRY, KISS, TDD principles
- [ ] **Tests Written**: Every function has corresponding test coverage
- [ ] **Tests Passing**: All existing and new tests pass
- [ ] **Type Safety**: No TypeScript/type errors (if applicable)
- [ ] **Linting Clean**: Code passes all style and quality checks
- [ ] **Documentation Updated**: Changes are documented appropriately

### Phase 2: Integration Validation 🔄
- [ ] **Branch Up-to-Date**: Current branch is rebased/merged with target branch
- [ ] **Conflicts Resolved**: No merge conflicts exist
- [ ] **Dependencies Updated**: Package versions are compatible
- [ ] **Environment Tested**: Changes work in appropriate environments
- [ ] **Performance Check**: No significant performance regressions
- [ ] **Security Scan**: No new security vulnerabilities introduced

### Phase 3: Delivery Preparation 🚀
- [ ] **Commit Message Quality**: Clear, conventional commit format
- [ ] **PR Description Complete**: Comprehensive PR description written
- [ ] **Reviewers Assigned**: Appropriate reviewers tagged
- [ ] **Issue Linked**: Related GitHub issues are linked
- [ ] **Change Log Updated**: Breaking changes documented
- [ ] **Deployment Ready**: Changes are ready for production

## ABC Pressure Assessment

I will analyze your current state and identify the EXACT NEXT STEP you need to take:

### Current Work Analysis

Let me assess what's blocking your completion:

1. **Examine Git Status**: Check for uncommitted changes
2. **Review Test Coverage**: Verify all code is tested
3. **Check CI/CD Status**: Ensure build pipelines are green
4. **Validate Branch Strategy**: Confirm compliance with branching rules
5. **Assess PR Readiness**: Determine if ready for review/merge

### ABC Action Items

Based on my analysis, here are your immediate action items with ABC pressure:

## Next Step Identification

I'll identify the specific blocker preventing your task completion and provide the exact command or action needed to move forward.

### Safety and Quality Gates

Before applying ABC pressure, I ensure compliance with:
- **CLAUDE.md Safety Rules**: All safety protocols followed
- **TDD Requirements**: Tests exist and pass
- **Branch Protection**: No protected branch violations
- **Documentation Standards**: Changes properly documented
- **Code Review Standards**: Quality gates maintained

### ABC Execution Plan

1. **Immediate Actions**: What you can do RIGHT NOW to move forward
2. **Dependency Resolution**: What's blocking you and how to resolve it
3. **Timeline Pressure**: Realistic timeline for completion
4. **Escalation Path**: When to seek help or delegate

## ABC Motivation System

The ABC system applies appropriate pressure while maintaining quality:

- 🔴 **HIGH PRESSURE**: Task is overdue or blocking others
- 🟡 **MEDIUM PRESSURE**: Task is on schedule but needs momentum
- 🟢 **LOW PRESSURE**: Task is ahead of schedule, maintain quality

Let me analyze your current situation and apply the appropriate level of ABC pressure to get your task completed and merged.