# Pending Commits

## Overview

This directory tracks commit messages and changes that are ready for git commit but haven't been committed yet. This allows Claude Code sessions to understand what local changes have been made.

## Directory Structure

Organized by branch to track branch-specific pending commits:
```
pending-commits/
├── main/
├── feature-branch-name/
└── another-branch/
```

## File Naming Convention

Use the format: `YYYY-MM-DD-{branch}-descriptive-name.md`

Examples:
- `2025-07-30-main-initialize-agentic-development-structure.md`
- `2025-07-30-feature-oauth-implement-oauth-flow.md`
- `2025-07-31-main-add-user-synchronization.md`

## Usage

1. When changes are ready for commit but not yet committed, create a file here
2. Include the complete commit message and summary of changes
3. When the commit is made, DELETE the corresponding file (completed work moves to reports/)
4. Future Claude Code sessions can check this directory to understand pending work

## Important: Lifecycle Management

- **Active work**: Create files here while working
- **Ready to commit**: Keep files here until committed
- **After commit**: DELETE files here (don't move to reports/)
- **Completed implementations**: Create separate reports in ../reports/

## Status Tracking

Each file should indicate:
- Current status (ready for commit, needs review, etc.)
- Summary of changes made
- Any dependencies or prerequisites
- Proposed commit message