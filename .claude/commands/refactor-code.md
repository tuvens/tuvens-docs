---
allowed-tools: Bash, Read, Write, Edit, MultiEdit, Glob, Grep, LS, Task
description: Optimize and refactor code from first principles for maintainability and scalability
argument-hint: [target-path] [optional: --dry-run]
---

# Refactor Code from First Principles

Comprehensively optimize and refactor code to improve maintainability, scalability, and clarity while preserving all functionality.

## Arguments Provided
`$ARGUMENTS`

## Current Context
Repository: !`git remote get-url origin | sed 's/.*\///' | sed 's/\.git//'`
Current branch: !`git branch --show-current`
Working directory: !`pwd`

## Project Context
Package info: !`find . -name "package.json" -o -name "composer.json" -o -name "Cargo.toml" -o -name "pyproject.toml" -o -name "go.mod" | head -5`

## Agent Workflow Integration

**IMPORTANT**: For comprehensive refactoring work, this should be handled through the multi-agent workflow system.

### Step 1: Initiate Agent Session
I'll create a dedicated agent session for this refactoring task using the `/start-session` command:

Based on the target path and refactoring scope, I will:
1. **Determine appropriate agent** - Usually `vibe-coder` for architecture and code organization tasks
2. **Create focused task** - Generate specific refactoring objectives from the arguments provided
3. **Setup isolated environment** - Use `/start-session [agent-name]` to create proper worktree and issue tracking

### Step 2: Task Handoff
The dedicated agent session will:
- Load complete refactoring context and target analysis
- Follow the systematic refactoring approach outlined below
- Maintain proper git workflow with isolated branch
- Create comprehensive documentation of changes
- Ensure all tests pass and no functionality is lost

**If this is a small, localized refactoring** (single file or function), I can proceed directly. **For comprehensive refactoring** (multiple files, architectural changes), I will initiate the agent workflow.

## Refactoring Principles

### Code Quality Improvements
1. **Simplify and Clean**
   - Remove dead code and unused imports
   - Eliminate code duplication through abstraction
   - Simplify complex conditional logic
   - Extract reusable functions and components

2. **Configuration Management**
   - Replace hardcoded values with environment variables
   - Create centralized configuration files
   - Implement configuration validation
   - Add development/staging/production configs

3. **Structure and Organization**
   - Organize files by feature/domain rather than file type
   - Create clear module boundaries and interfaces
   - Implement consistent naming conventions
   - Establish proper dependency hierarchies

4. **Scalability Enhancements**
   - Design for horizontal scaling patterns
   - Implement proper error handling and logging
   - Add performance monitoring hooks
   - Create extensible architecture patterns

## Analysis Process

### 1. Code Discovery and Mapping
- Identify all source files and their relationships
- Map dependencies and identify circular references
- Locate configuration files and hardcoded values
- Find duplicate code patterns and logic

### 2. Quality Assessment
- Check for unused files, functions, and dependencies
- Identify complex functions that need decomposition
- Locate configuration that should be externalized
- Find opportunities for abstraction and reuse

### 3. Refactoring Strategy
- Plan refactoring steps to minimize breaking changes
- Design new structure for better organization
- Create configuration management strategy
- Plan testing approach to verify functionality preservation

## Implementation Approach

### Phase 1: Analysis and Planning
1. **Codebase Analysis**: Map current structure and identify issues
2. **Dependency Audit**: Find unused dependencies and optimization opportunities
3. **Configuration Audit**: Locate hardcoded values and configuration needs
4. **Refactoring Plan**: Create step-by-step improvement strategy

### Phase 2: Structural Improvements  
1. **File Organization**: Restructure for better logical grouping
2. **Dependency Cleanup**: Remove unused imports and dependencies
3. **Code Deduplication**: Extract common patterns into reusable components
4. **Interface Design**: Create clear boundaries between modules

### Phase 3: Configuration Management
1. **Environment Variables**: Replace hardcoded values with configs
2. **Configuration Files**: Create structured config management
3. **Validation**: Add configuration validation and error handling
4. **Documentation**: Document all configuration options

### Phase 4: Code Quality
1. **Function Decomposition**: Break down complex functions
2. **Error Handling**: Improve error handling and logging
3. **Performance**: Optimize performance bottlenecks
4. **Testing**: Ensure all tests pass and add missing coverage

## Safety Measures

### Preserve Functionality
- **Incremental Changes**: Small, testable improvements
- **Test Coverage**: Run tests after each change
- **Feature Preservation**: Verify all existing features work
- **Rollback Plan**: Maintain ability to revert changes

### Change Validation
- **Automated Testing**: Run full test suite continuously
- **Manual Testing**: Verify critical user journeys
- **Performance Testing**: Ensure no performance regressions
- **Security Review**: Verify no security vulnerabilities introduced

## Output Structure

The refactoring will produce:

1. **Improved Code Structure**
   - Logical file organization
   - Clear module boundaries
   - Consistent naming conventions
   - Reduced complexity metrics

2. **Configuration Management**
   - Environment-specific configs
   - Centralized configuration files
   - Configuration validation
   - Clear documentation

3. **Quality Improvements**
   - Eliminated code duplication
   - Improved error handling
   - Better logging and monitoring
   - Enhanced maintainability

4. **Documentation Updates**
   - Updated README with new structure
   - Configuration documentation
   - Architecture decision records
   - Refactoring summary report

Let me analyze the specified target path and create a comprehensive refactoring plan...