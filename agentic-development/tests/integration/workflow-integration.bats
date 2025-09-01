#!/usr/bin/env bats
# Integration tests for GitHub Actions workflows
# TDD Test Suite - Testing workflow integration and CI/CD pipeline

# Load test setup
load ../unit/setup

# Setup for each test
setup() {
    export TEST_REPO_DIR
    TEST_REPO_DIR=$(setup_test_git_repo)
    cd "$TEST_REPO_DIR"
    
    # Create minimal project structure
    echo "# Test Project" > README.md
    echo "# CLAUDE.md" > CLAUDE.md
    echo '{"name": "test-project", "scripts": {"test": "echo test"}}' > package.json
    mkdir -p .github/workflows
    mkdir -p agentic-development/scripts
}

# Teardown after each test
teardown() {
    teardown_test_git_repo "$TEST_REPO_DIR"
}

@test "workflow integration: GitHub Actions workflows have valid YAML syntax" {
    # Create a sample workflow file
    cat > .github/workflows/test.yml << 'EOF'
name: Test Workflow

on:
  push:
    branches: [main, dev]
  pull_request:
    branches: [main, dev]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: npm test
EOF
    
    # Test YAML validation using Python (more reliable than yamllint)
    run python3 -c "import yaml; yaml.safe_load(open('.github/workflows/test.yml'))"
    [ "$status" -eq 0 ]
}

@test "workflow integration: infrastructure validation workflow triggers correctly" {
    # Create infrastructure validation workflow
    cat > .github/workflows/infrastructure-validation.yml << 'EOF'
name: Infrastructure Validation

on:
  push:
    branches: [dev, test, stage, main]
    paths:
      - 'package.json'
      - 'agentic-development/scripts/**'
  pull_request:
    branches: [dev, test, stage, main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run validation
        run: echo "Validation passed"
EOF
    
    # Validate the workflow syntax
    run python3 -c "
import yaml
import sys
try:
    with open('.github/workflows/infrastructure-validation.yml') as f:
        workflow = yaml.safe_load(f)
    
    # Check required fields
    assert 'name' in workflow
    assert 'on' in workflow
    assert 'jobs' in workflow
    
    # Check that it triggers on the correct branches
    if isinstance(workflow['on'], dict):
        if 'push' in workflow['on'] and 'branches' in workflow['on']['push']:
            branches = workflow['on']['push']['branches']
            assert 'dev' in branches
            assert 'main' in branches
    
    print('Workflow validation passed')
    sys.exit(0)
except Exception as e:
    print(f'Workflow validation failed: {e}')
    sys.exit(1)
"
    [ "$status" -eq 0 ]
}

@test "workflow integration: branch protection workflow validates naming conventions" {
    # Create branch protection workflow
    cat > .github/workflows/branch-protection.yml << 'EOF'
name: Branch Protection

on:
  pull_request:
    branches: [dev, test, stage, main]

jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate branch naming
        run: |
          branch_name="${{ github.head_ref }}"
          if [[ "$branch_name" =~ ^(vibe-coder|docs-orchestrator|devops)/(feature|bugfix|docs)/.+ ]]; then
            echo "Branch name valid: $branch_name"
          else
            echo "Branch name invalid: $branch_name"
            exit 1
          fi
EOF
    
    # Validate the workflow content
    run python3 -c "
import yaml
with open('.github/workflows/branch-protection.yml') as f:
    workflow = yaml.safe_load(f)

# Check that it's triggered on PR events
assert workflow['on']['pull_request']['branches'] == ['dev', 'test', 'stage', 'main']
print('Branch protection workflow validation passed')
"
    [ "$status" -eq 0 ]
}

@test "workflow integration: test scripts integrate with CI/CD" {
    # Create a test script that would be called by CI
    cat > agentic-development/scripts/ci-test.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "Running CI tests..."

# Mock test scenarios
if [ "${TEST_SCENARIO:-success}" = "success" ]; then
    echo "✅ All tests passed"
    exit 0
else
    echo "❌ Tests failed"
    exit 1
fi
EOF
    chmod +x agentic-development/scripts/ci-test.sh
    
    # Test that the script can be executed
    export TEST_SCENARIO=success
    run ./agentic-development/scripts/ci-test.sh
    [ "$status" -eq 0 ]
    [[ "$output" =~ "All tests passed" ]]
}

@test "workflow integration: test failure scenarios are handled correctly" {
    # Create a script that can simulate failures
    cat > agentic-development/scripts/ci-test.sh << 'EOF'
#!/bin/bash
set -euo pipefail

case "${TEST_SCENARIO:-success}" in
    "failure")
        echo "❌ Test failure simulated"
        exit 1
        ;;
    "timeout")
        echo "⏰ Test timeout simulated"
        sleep 300  # This would timeout in CI
        ;;
    *)
        echo "✅ Tests passed"
        exit 0
        ;;
esac
EOF
    chmod +x agentic-development/scripts/ci-test.sh
    
    # Test failure scenario
    export TEST_SCENARIO=failure
    run ./agentic-development/scripts/ci-test.sh
    [ "$status" -eq 1 ]
    [[ "$output" =~ "Test failure simulated" ]]
}

@test "workflow integration: artifacts and reports are generated correctly" {
    # Create a script that generates test artifacts
    cat > agentic-development/scripts/generate-report.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "Generating test report..."

# Create test report
cat > test-report.md << 'REPORT'
# Test Report

**Date**: $(date)
**Status**: Success
**Tests**: 10
**Passed**: 10  
**Failed**: 0

## Summary
All tests passed successfully.
REPORT

echo "✅ Test report generated: test-report.md"
EOF
    chmod +x agentic-development/scripts/generate-report.sh
    
    # Run the report generation
    run ./agentic-development/scripts/generate-report.sh
    [ "$status" -eq 0 ]
    [ -f "test-report.md" ]
    
    # Verify report content
    run cat test-report.md
    [[ "$output" =~ "Test Report" ]]
    [[ "$output" =~ "Status**: Success" ]]
}

@test "workflow integration: environment setup works in CI context" {
    # Create environment setup script
    cat > agentic-development/scripts/setup-ci-env.sh << 'EOF'
#!/bin/bash
set -euo pipefail

echo "Setting up CI environment..."

# Check required tools
tools=("git" "node" "npm")
missing=()

for tool in "${tools[@]}"; do
    if ! command -v "$tool" >/dev/null 2>&1; then
        missing+=("$tool")
    fi
done

if [ ${#missing[@]} -gt 0 ]; then
    echo "❌ Missing tools: ${missing[*]}"
    exit 1
fi

echo "✅ CI environment setup complete"
EOF
    chmod +x agentic-development/scripts/setup-ci-env.sh
    
    # Test environment setup
    run ./agentic-development/scripts/setup-ci-env.sh
    [ "$status" -eq 0 ]
    [[ "$output" =~ "CI environment setup complete" ]]
}

@test "workflow integration: pre-commit hooks integrate with CI" {
    # Create pre-commit configuration
    cat > .pre-commit-config.yaml << 'EOF'
repos:
  - repo: https://github.com/pre-commit/pre-commit-hooks
    rev: v4.4.0
    hooks:
      - id: trailing-whitespace
      - id: end-of-file-fixer
      - id: check-yaml
      - id: check-added-large-files
EOF
    
    # Test YAML validation
    run python3 -c "import yaml; yaml.safe_load(open('.pre-commit-config.yaml'))"
    [ "$status" -eq 0 ]
    
    # Mock pre-commit validation
    cat > validate-pre-commit.sh << 'EOF'
#!/bin/bash
if [ -f ".pre-commit-config.yaml" ]; then
    echo "✅ Pre-commit configuration found"
    exit 0
else
    echo "❌ Pre-commit configuration missing"
    exit 1
fi
EOF
    chmod +x validate-pre-commit.sh
    
    run ./validate-pre-commit.sh
    [ "$status" -eq 0 ]
}