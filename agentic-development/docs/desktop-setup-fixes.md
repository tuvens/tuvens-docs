# Fix Desktop Agent Setup Issues

**GitHub Issue**: #395  
**Branch**: `vibe-coder/feature/fix-desktop-agent-setup-issues`  
**Status**: In Progress

## Problem Summary

The `setup-agent-task-desktop-temp.sh` script works but has 4 critical issues that need systematic fixing before replacing the original broken script.

## Issues to Fix

### 1. ❌ Unbound Variable Error
**Problem**: `temp_body_file: unbound variable` at line ~100  
**Root Cause**: Variable referenced but never declared  
**Impact**: Error message in terminal output  

### 2. ❌ Garbled GitHub Issue Numbers  
**Problem**: Issue numbers display as `#   Creating issue: Title\n395` instead of `#395`  
**Root Cause**: Complex grep parsing fails with multiline output  
**Impact**: Confusing prompts and terminal display  

### 3. ❌ Excessive Verbosity
**Problem**: Desktop script outputs ~100 lines vs Claude Code's clean ~10 lines  
**Root Cause**: Shows full core script output instead of filtering  
**Impact**: Poor user experience, token waste  

### 4. ❌ Nested Worktree Paths
**Problem**: Worktrees created inside other worktrees  
**Root Cause**: Path resolution issues  
**Impact**: Confusing directory structures  

## Files

### Primary Files
- `agentic-development/scripts/setup-agent-task-desktop-temp.sh` - Working but flawed script
- `agentic-development/scripts/setup-agent-task-desktop.sh` - Original broken script (target to replace)

### Debugging Resources  
- `debug/terminal-output-examples.md` - Detailed output examples and root cause analysis
- `tests/test-desktop-setup.sh` - TDD test framework for validation

### Dependencies
- `agentic-development/scripts/shared-functions.sh` - Shared functions used by both scripts

## Implementation Strategy

### 1. Analysis Phase
- [x] Identify all 4 issues with root causes
- [x] Create debugging examples and test framework
- [ ] Line-by-line analysis of temp script

### 2. Fix Phase  
- [ ] Fix unbound variables
- [ ] Implement clean issue number parsing
- [ ] Reduce output verbosity  
- [ ] Investigate worktree path resolution

### 3. Testing Phase
- [ ] Run TDD tests: `chmod +x tests/test-desktop-setup.sh && ./tests/test-desktop-setup.sh`
- [ ] Test end-to-end workflow from Claude Desktop
- [ ] Test end-to-end workflow from Claude Code  
- [ ] Validate no regression in functionality

### 4. Integration Phase
- [ ] Replace original script with fixed version
- [ ] Create PR to merge into dev branch
- [ ] Update documentation if needed

## Testing

```bash
# Make test script executable
chmod +x tests/test-desktop-setup.sh

# Run tests
./tests/test-desktop-setup.sh

# Test actual workflow (careful - creates real GitHub issues)
./agentic-development/scripts/setup-agent-task-desktop.sh test-agent "Test Task" "Test Description"
```

## Success Criteria

- [ ] No unbound variable errors
- [ ] Clean GitHub issue number formatting in all outputs
- [ ] Concise, professional terminal output (similar to Claude Code output)
- [ ] Proper worktree directory structure without nesting
- [ ] End-to-end workflow test passes from both Claude Desktop and Claude Code
- [ ] Original script replaced with fixed version
- [ ] PR created and merged to dev branch

## Context

This task was created because the working temp script successfully launches Claude Code sessions but has user experience issues that need systematic fixing. The goal is to create a production-ready version that maintains functionality while providing a clean, professional user experience.

**Original Terminal Output**: See `debug/terminal-output-examples.md` for detailed examples  
**GitHub Issue**: https://github.com/tuvens/tuvens-docs/issues/395
