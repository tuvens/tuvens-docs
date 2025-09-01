#!/bin/bash
# TDD Test Runner for Agentic Development Scripts
# Comprehensive test execution with bats-core integration
# KISS principle: Simple test runner with clear output and failure handling

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script directory and test directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TESTS_DIR="$SCRIPT_DIR"
UNIT_TESTS_DIR="$TESTS_DIR/unit"
INTEGRATION_TESTS_DIR="$TESTS_DIR/integration"
TEMP_TEST_DIR="$TESTS_DIR/temp"

# Test execution tracking
TOTAL_TEST_FILES=0
PASSED_TEST_FILES=0
FAILED_TEST_FILES=0
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Print functions for consistent output
print_header() {
    echo -e "${PURPLE}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} $1"
    echo -e "${PURPLE}╚════════════════════════════════════════════════════════════════╝${NC}"
}

print_status() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${CYAN}[i]${NC} $1"
}

# Function to check if bats-core is installed
check_bats_installation() {
    if ! command -v bats >/dev/null 2>&1; then
        print_error "bats-core is not installed"
        echo ""
        echo "To install bats-core:"
        echo "  macOS:   brew install bats-core"
        echo "  Ubuntu:  sudo apt install bats"
        echo "  Other:   npm install -g bats"
        echo ""
        echo "Or clone from GitHub:"
        echo "  git clone https://github.com/bats-core/bats-core.git"
        echo "  cd bats-core && sudo ./install.sh /usr/local"
        return 1
    fi
    return 0
}

# Function to set up test environment
setup_test_environment() {
    print_status "Setting up test environment..."
    
    # Create temporary directory for test isolation
    mkdir -p "$TEMP_TEST_DIR"
    
    # Ensure we're in the project root for relative path resolution
    cd "$PROJECT_ROOT"
    
    # Set environment variables for tests
    export TEST_PROJECT_ROOT="$PROJECT_ROOT"
    export TEST_TEMP_DIR="$TEMP_TEST_DIR"
    export BATS_TEST_DIRNAME="$UNIT_TESTS_DIR"
    
    print_success "Test environment ready"
}

# Function to clean up test environment
cleanup_test_environment() {
    print_status "Cleaning up test environment..."
    
    if [ -d "$TEMP_TEST_DIR" ]; then
        rm -rf "$TEMP_TEST_DIR"
    fi
    
    print_success "Test cleanup complete"
}

# Function to run unit tests
run_unit_tests() {
    print_header "Running Unit Tests"
    
    if [ ! -d "$UNIT_TESTS_DIR" ]; then
        print_warning "Unit tests directory not found: $UNIT_TESTS_DIR"
        return 0
    fi
    
    local unit_test_files
    unit_test_files=($(find "$UNIT_TESTS_DIR" -name "*.bats" | sort))
    
    if [ ${#unit_test_files[@]} -eq 0 ]; then
        print_warning "No unit test files found in $UNIT_TESTS_DIR"
        return 0
    fi
    
    local unit_failures=0
    
    for test_file in "${unit_test_files[@]}"; do
        local test_name
        test_name=$(basename "$test_file" .bats)
        
        print_status "Running unit tests: $test_name"
        ((TOTAL_TEST_FILES++))
        
        # Run bats with tap format for detailed output
        if bats --tap "$test_file"; then
            print_success "Unit test passed: $test_name"
            ((PASSED_TEST_FILES++))
        else
            print_error "Unit test failed: $test_name"
            ((FAILED_TEST_FILES++))
            unit_failures=$((unit_failures + 1))
        fi
        
        echo ""
    done
    
    if [ $unit_failures -eq 0 ]; then
        print_success "All unit tests passed!"
    else
        print_error "$unit_failures unit test file(s) failed"
    fi
    
    return $unit_failures
}

# Function to run integration tests
run_integration_tests() {
    print_header "Running Integration Tests"
    
    if [ ! -d "$INTEGRATION_TESTS_DIR" ]; then
        print_warning "Integration tests directory not found: $INTEGRATION_TESTS_DIR"
        return 0
    fi
    
    local integration_test_files
    integration_test_files=($(find "$INTEGRATION_TESTS_DIR" -name "*.bats" | sort))
    
    if [ ${#integration_test_files[@]} -eq 0 ]; then
        print_warning "No integration test files found in $INTEGRATION_TESTS_DIR"
        return 0
    fi
    
    local integration_failures=0
    
    for test_file in "${integration_test_files[@]}"; do
        local test_name
        test_name=$(basename "$test_file" .bats)
        
        print_status "Running integration tests: $test_name"
        ((TOTAL_TEST_FILES++))
        
        # Run bats with tap format for detailed output
        if bats --tap "$test_file"; then
            print_success "Integration test passed: $test_name"
            ((PASSED_TEST_FILES++))
        else
            print_error "Integration test failed: $test_name"
            ((FAILED_TEST_FILES++))
            integration_failures=$((integration_failures + 1))
        fi
        
        echo ""
    done
    
    if [ $integration_failures -eq 0 ]; then
        print_success "All integration tests passed!"
    else
        print_error "$integration_failures integration test file(s) failed"
    fi
    
    return $integration_failures
}

# Function to run syntax validation tests
run_syntax_validation() {
    print_header "Running Syntax Validation Tests"
    
    local syntax_failures=0
    
    # Find all shell scripts
    local shell_scripts
    shell_scripts=($(find "$PROJECT_ROOT" -name "*.sh" -not -path "*/node_modules/*" -not -path "*/temp/*" -not -path "*/.git/*"))
    
    for script in "${shell_scripts[@]}"; do
        local script_name
        script_name=$(basename "$script")
        
        print_status "Validating syntax: $script_name"
        
        # Check shell syntax
        if bash -n "$script" >/dev/null 2>&1; then
            print_success "Syntax valid: $script_name"
        else
            print_error "Syntax error in: $script_name"
            # Show the actual error for debugging
            print_info "Error details:"
            bash -n "$script" 2>&1 | head -3 | sed 's/^/    /'
            syntax_failures=$((syntax_failures + 1))
        fi
    done
    
    if [ $syntax_failures -eq 0 ]; then
        print_success "All scripts have valid syntax!"
    else
        print_error "$syntax_failures script(s) have syntax errors"
    fi
    
    return $syntax_failures
}

# Function to run shellcheck if available
run_shellcheck_validation() {
    if ! command -v shellcheck >/dev/null 2>&1; then
        print_warning "shellcheck not available, skipping advanced linting"
        return 0
    fi
    
    print_header "Running ShellCheck Validation"
    
    local shellcheck_failures=0
    
    # Find all shell scripts
    local shell_scripts
    shell_scripts=($(find "$PROJECT_ROOT" -name "*.sh" -not -path "*/node_modules/*" -not -path "*/temp/*" -not -path "*/.git/*"))
    
    for script in "${shell_scripts[@]}"; do
        local script_name
        script_name=$(basename "$script")
        
        print_status "ShellCheck analysis: $script_name"
        
        # Run shellcheck with appropriate options
        if shellcheck -x "$script" >/dev/null 2>&1; then
            print_success "ShellCheck passed: $script_name"
        else
            print_warning "ShellCheck warnings in: $script_name"
            # Show warnings but don't fail the build for warnings
            shellcheck -x "$script" 2>&1 | head -5 | sed 's/^/    /'
        fi
    done
    
    print_success "ShellCheck validation complete"
    return 0
}

# Function to generate test report
generate_test_report() {
    local start_time="$1"
    local end_time
    local duration
    
    end_time=$(date +%s)
    duration=$((end_time - start_time))
    
    print_header "Test Results Summary"
    
    print_info "Test Suite: TDD Bash Script Testing Framework"
    print_info "Duration: ${duration}s"
    print_info "Test Files: $TOTAL_TEST_FILES"
    print_info "Passed Files: $PASSED_TEST_FILES"
    print_info "Failed Files: $FAILED_TEST_FILES"
    
    if [ $FAILED_TEST_FILES -eq 0 ]; then
        print_success "ALL TESTS PASSED! ✨"
        print_success "$(printf "%*s" 60 | tr ' ' '=')"
        return 0
    else
        print_error "TESTS FAILED! 💔"
        print_error "$(printf "%*s" 60 | tr ' ' '=')"
        print_error "Failed test files: $FAILED_TEST_FILES"
        print_warning "Please fix failing tests before committing"
        return 1
    fi
}

# Main execution function
main() {
    local start_time
    start_time=$(date +%s)
    
    local test_type="${1:-all}"
    local exit_code=0
    
    print_header "TDD Testing Framework for Agentic Development"
    print_info "Test Type: $test_type"
    print_info "Project: $(basename "$PROJECT_ROOT")"
    echo ""
    
    # Check dependencies
    if ! check_bats_installation; then
        exit 1
    fi
    
    # Set up test environment
    setup_test_environment
    
    # Run tests based on type
    case "$test_type" in
        "unit")
            run_unit_tests || exit_code=$?
            ;;
        "integration")
            run_integration_tests || exit_code=$?
            ;;
        "syntax")
            run_syntax_validation || exit_code=$?
            ;;
        "lint")
            run_shellcheck_validation || exit_code=$?
            ;;
        "all")
            run_unit_tests || exit_code=$?
            run_integration_tests || exit_code=$?
            run_syntax_validation || exit_code=$?
            run_shellcheck_validation || exit_code=$?
            ;;
        *)
            print_error "Unknown test type: $test_type"
            echo ""
            echo "Available test types:"
            echo "  unit         - Run unit tests only"
            echo "  integration  - Run integration tests only"
            echo "  syntax       - Run syntax validation only"
            echo "  lint         - Run shellcheck validation only"
            echo "  all          - Run all tests (default)"
            exit 1
            ;;
    esac
    
    # Clean up
    cleanup_test_environment
    
    # Generate final report
    if ! generate_test_report "$start_time"; then
        exit_code=1
    fi
    
    exit $exit_code
}

# Handle help and version
case "${1:-}" in
    --help|-h)
        echo "TDD Testing Framework for Agentic Development Scripts"
        echo ""
        echo "Usage: $0 [test-type]"
        echo ""
        echo "Test types:"
        echo "  unit         - Run unit tests only"
        echo "  integration  - Run integration tests only"
        echo "  syntax       - Run syntax validation only"
        echo "  lint         - Run shellcheck validation only"
        echo "  all          - Run all tests (default)"
        echo ""
        echo "Examples:"
        echo "  $0              # Run all tests"
        echo "  $0 unit         # Run only unit tests"
        echo "  $0 integration  # Run only integration tests"
        exit 0
        ;;
    --version)
        echo "TDD Testing Framework v1.0"
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac