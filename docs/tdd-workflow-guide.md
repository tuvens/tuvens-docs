# TDD Workflow Guide for Agentic Development

## Overview

This guide establishes Test-Driven Development (TDD) practices for the Tuvens ecosystem, ensuring code quality, reliability, and maintainability across all scripts and automation tools.

## TDD Principles Applied

### DRY (Don't Repeat Yourself)
- Shared functions in `agentic-development/scripts/shared-functions.sh`
- Centralized test utilities in `tests/unit/setup.sh`
- Reusable mock functions and test patterns

### KISS (Keep It Simple, Stupid)
- Simple, focused test functions with clear assertions
- Straightforward test runner with minimal complexity
- Clear separation between unit and integration tests

### Test-First Development
- Write tests before implementing functionality
- Red-Green-Refactor cycle for all new features
- Comprehensive test coverage for all script functions

## Testing Framework Structure

```
tests/
├── run-tests.sh                 # Main test runner
├── unit/                       # Unit tests
│   ├── setup.sh                # Test setup utilities
│   ├── shared-functions.bats   # Tests for shared functions
│   ├── test-runner.bats        # Tests for main test runner
│   └── setup-agent-task.bats   # Tests for agent setup script
├── integration/                # Integration tests
│   └── workflow-integration.bats
└── temp/                       # Temporary test artifacts
```

## Running Tests

### NPM Scripts (Recommended)
```bash
# Run all TDD tests
npm run test:tdd

# Run specific test types
npm run test:tdd:unit         # Unit tests only
npm run test:tdd:integration  # Integration tests only
npm run test:tdd:syntax       # Syntax validation only
npm run test:tdd:lint         # ShellCheck linting only
```

### Direct Test Runner
```bash
# Run all tests
./tests/run-tests.sh

# Run specific test types
./tests/run-tests.sh unit
./tests/run-tests.sh integration
./tests/run-tests.sh syntax
./tests/run-tests.sh lint
```

### Existing Infrastructure Tests
```bash
# Legacy test commands (still supported)
npm run test              # Run infrastructure tests
npm run test:full         # Full test suite
npm run test:safety       # Safety-focused tests
```

## TDD Development Workflow

### 1. Red Phase - Write Failing Test
```bash
# Create a new test file
touch tests/unit/new-feature.bats

# Write test for functionality that doesn't exist yet
@test "new_function: should process input correctly" {
    result=$(new_function "test input")
    [ "$result" = "expected output" ]
}
```

### 2. Green Phase - Make Test Pass
```bash
# Implement minimal functionality to make test pass
new_function() {
    local input="$1"
    echo "expected output"
}
```

### 3. Refactor Phase - Improve Code
```bash
# Refactor while keeping tests passing
new_function() {
    local input="$1"
    # Add proper logic, error handling, etc.
    if [ -z "$input" ]; then
        echo "ERROR: Input required" >&2
        return 1
    fi
    echo "expected output"
}
```

## Writing Effective Tests

### Test Structure (AAA Pattern)
```bash
@test "function_name: should describe expected behavior" {
    # Arrange - Set up test conditions
    local input="test data"
    export TEST_ENV="test_value"
    
    # Act - Execute the function
    result=$(function_under_test "$input")
    
    # Assert - Verify the outcome
    [ "$result" = "expected output" ]
    [ "$status" -eq 0 ]
}
```

### Test Naming Convention
- Format: `function_name: should describe behavior`
- Examples:
  - `calculate_branch_name: generates correct branch name from agent and title`
  - `validate_environment_setup: fails when CLAUDE.md missing`
  - `create_github_issue: creates issue with proper format`

### Test Categories

#### Unit Tests (`tests/unit/`)
- Test individual functions in isolation
- Use mocks for external dependencies (git, gh, etc.)
- Focus on function logic and edge cases
- Fast execution (< 1 second per test)

#### Integration Tests (`tests/integration/`)
- Test component interactions
- Validate workflow integration
- Test CI/CD pipeline compatibility
- May take longer (< 30 seconds per test)

#### Syntax Tests (automated)
- Bash syntax validation (`bash -n`)
- ShellCheck linting
- YAML syntax validation
- JSON structure validation

## Test Environment Setup

### Test Isolation
- Each test runs in temporary directory (`$TEST_TEMP_DIR`)
- Git repositories created per test with `setup_test_git_repo()`
- Environment variables scoped to individual tests

### Mock Functions
```bash
# Mock external commands
gh() { mock_gh_command "$@"; }
export -f gh

# Mock git operations
git() {
    case "$1 $2" in
        "rev-parse --show-toplevel") echo "/mock/repo/path" ;;
        *) command git "$@" ;;
    esac
}
export -f git
```

### Test Fixtures
- Common test data in `tests/fixtures/`
- Reusable mock responses
- Sample configuration files

## CI/CD Integration

### GitHub Actions Workflow
The TDD framework integrates with existing CI/CD pipelines:

```yaml
- name: 🧪 Run Infrastructure Tests
  run: |
    # Run TDD tests first
    if [ -f tests/run-tests.sh ]; then
      ./tests/run-tests.sh all
    fi
    
    # Run existing infrastructure tests
    ./agentic-development/scripts/test.sh --$test_level
```

### Test Execution Order
1. **TDD Unit Tests** - Fast, isolated function tests
2. **TDD Integration Tests** - Component interaction tests
3. **Syntax Validation** - Shell script and YAML validation
4. **Infrastructure Tests** - Existing safety and validation tests
5. **Pre-commit Hooks** - Final validation before merge

## Code Coverage and Quality Gates

### Coverage Requirements
- **Minimum Coverage**: 80% for all shell functions
- **Critical Functions**: 100% coverage required
- **New Functions**: Must have tests before merge

### Quality Gates
- All tests must pass before PR merge
- No syntax errors allowed
- ShellCheck warnings must be addressed
- Pre-commit hooks must pass

## Best Practices

### Test Design
1. **One Assertion Per Test** - Keep tests focused
2. **Independent Tests** - No test dependencies
3. **Descriptive Names** - Clear test intent
4. **Fast Execution** - Unit tests < 1 second
5. **Reliable Results** - No flaky tests

### Error Handling
```bash
@test "function: handles invalid input gracefully" {
    run function_under_test ""
    [ "$status" -ne 0 ]
    [[ "$output" =~ "ERROR:" ]]
}
```

### Edge Cases
- Empty input handling
- Invalid parameter types
- File permission issues
- Network connectivity problems
- Git repository edge cases

### Test Maintenance
1. **Update tests with code changes**
2. **Remove obsolete tests**
3. **Refactor test utilities**
4. **Keep test documentation current**

## Troubleshooting

### Common Issues

#### Bats Not Installed
```bash
# macOS
brew install bats-core

# Ubuntu/Debian
sudo apt install bats

# Manual installation
git clone https://github.com/bats-core/bats-core.git
cd bats-core && sudo ./install.sh /usr/local
```

#### Test Failures in CI
1. Check bats installation in workflow
2. Verify test file permissions
3. Review environment variable setup
4. Check path resolution issues

#### Mock Function Issues
```bash
# Ensure functions are exported
export -f mock_function

# Verify function scope
declare -f mock_function

# Check function overrides
type mock_function
```

## Contributing to Tests

### Adding New Tests
1. Follow TDD workflow (Red-Green-Refactor)
2. Use existing test patterns
3. Add appropriate setup/teardown
4. Update documentation

### Test Review Process
1. Code review includes test review
2. Verify test coverage
3. Check test reliability
4. Validate performance impact

## Future Enhancements

### Planned Improvements
- [ ] Parallel test execution
- [ ] Code coverage reporting
- [ ] Performance benchmarking
- [ ] Test result visualization
- [ ] Automated test generation

### Integration Targets
- [ ] SonarQube integration
- [ ] Codecov reporting
- [ ] Performance regression detection
- [ ] Security vulnerability scanning

## References

- [Bats-core Documentation](https://bats-core.readthedocs.io/)
- [TDD Best Practices](https://martinfowler.com/bliki/TestDrivenDevelopment.html)
- [CLAUDE.md Safety Rules](../CLAUDE.md)
- [Agentic Development Workflows](../agentic-development/workflows/)

---

**Last Updated**: 2025-08-25  
**Version**: 1.0  
**Maintained By**: Vibe Coder Agent

*This document is part of the comprehensive TDD implementation for the Tuvens ecosystem.*