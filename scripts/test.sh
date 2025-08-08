#!/bin/bash
# Tuvens-Docs Comprehensive Test Runner
# Provides branch-aware testing with safety validation and workflow verification

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
TEST_TIMEOUT=300  # 5 minutes max
COVERAGE_THRESHOLD=75

# Determine the current branch and context
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
IS_CI=${CI:-false}
TEST_MODE=${1:-auto}

# Function to print colored output
print_header() {
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} $1"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
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

# Function to check if we're in CI environment
is_ci() {
    [ "$IS_CI" = "true" ] || [ -n "${GITHUB_ACTIONS}" ] || [ -n "${CI}" ]
}

# Function to validate environment setup
validate_environment() {
    print_status "Validating test environment..."
    
    local validation_errors=0
    
    # Check Node.js version
    if ! command -v node >/dev/null 2>&1; then
        print_error "Node.js is not installed"
        validation_errors=$((validation_errors + 1))
    else
        local node_version=$(node --version | cut -d'v' -f2)
        local required_version="18"
        if [[ "$(printf '%s\n' "$required_version" "$node_version" | sort -V | head -n1)" != "$required_version" ]]; then
            print_warning "Node.js version $node_version detected, recommend v18+"
        fi
    fi
    
    # Validate project structure
    if [ ! -f "package.json" ]; then
        print_error "Not in project root directory (package.json not found)"
        validation_errors=$((validation_errors + 1))
    fi
    
    # Check required directories
    local required_dirs=("agentic-development" ".github/workflows" "scripts")
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            print_error "Required directory not found: $dir"
            validation_errors=$((validation_errors + 1))
        fi
    done
    
    # Check critical files
    local critical_files=("CLAUDE.md" ".pre-commit-config.yaml")
    for file in "${critical_files[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "Critical file not found: $file"
            validation_errors=$((validation_errors + 1))
        fi
    done
    
    if [ $validation_errors -gt 0 ]; then
        print_error "Environment validation failed with $validation_errors errors"
        return 1
    fi
    
    print_success "Environment validation passed"
    return 0
}

# Function to run safety validation tests
run_safety_tests() {
    print_status "Running safety and validation tests..."
    
    local safety_test_errors=0
    
    # CLAUDE.md validation
    print_info "Validating CLAUDE.md safety infrastructure..."
    if [ -f "scripts/hooks/validate-claude-md.sh" ]; then
        if ! ./scripts/hooks/validate-claude-md.sh; then
            print_error "CLAUDE.md validation failed"
            safety_test_errors=$((safety_test_errors + 1))
        else
            print_success "CLAUDE.md validation passed"
        fi
    else
        print_error "CLAUDE.md validation script not found"
        safety_test_errors=$((safety_test_errors + 1))
    fi
    
    # Branch naming validation
    print_info "Validating branch naming compliance..."
    if [ -f "scripts/hooks/check-branch-naming.sh" ]; then
        if ! ./scripts/hooks/check-branch-naming.sh; then
            print_error "Branch naming validation failed"
            safety_test_errors=$((safety_test_errors + 1))
        else
            print_success "Branch naming validation passed"
        fi
    else
        print_error "Branch naming validation script not found"
        safety_test_errors=$((safety_test_errors + 1))
    fi
    
    # Safety rules check
    print_info "Running safety rules check..."
    if [ -f "scripts/hooks/check-safety-rules.sh" ]; then
        if ! ./scripts/hooks/check-safety-rules.sh; then
            print_error "Safety rules check failed"
            safety_test_errors=$((safety_test_errors + 1))
        else
            print_success "Safety rules check passed"
        fi
    else
        print_error "Safety rules check script not found"
        safety_test_errors=$((safety_test_errors + 1))
    fi
    
    return $safety_test_errors
}

# Function to run workflow validation tests
run_workflow_tests() {
    print_status "Running GitHub Actions workflow validation..."
    
    local workflow_test_errors=0
    
    # YAML syntax validation
    print_info "Validating workflow YAML syntax..."
    local workflows=(.github/workflows/*.yml)
    for workflow in "${workflows[@]}"; do
        if [ -f "$workflow" ]; then
            if command -v yamllint >/dev/null 2>&1; then
                if ! yamllint "$workflow" >/dev/null 2>&1; then
                    print_error "YAML syntax error in $workflow"
                    workflow_test_errors=$((workflow_test_errors + 1))
                else
                    print_success "$(basename "$workflow") syntax valid"
                fi
            else
                # Basic YAML validation using Python if yamllint not available
                if ! python3 -c "import yaml; yaml.safe_load(open('$workflow'))" 2>/dev/null; then
                    print_error "YAML syntax error in $workflow"
                    workflow_test_errors=$((workflow_test_errors + 1))
                else
                    print_success "$(basename "$workflow") syntax valid"
                fi
            fi
        fi
    done
    
    # Branch protection workflow validation
    if [ -f ".github/workflows/branch-protection.yml" ]; then
        print_info "Validating branch protection workflow..."
        # Check for required validation steps
        if grep -q "Validate CLAUDE.md" ".github/workflows/branch-protection.yml" &&
           grep -q "Validate branch naming" ".github/workflows/branch-protection.yml"; then
            print_success "Branch protection workflow structure valid"
        else
            print_error "Branch protection workflow missing required validation steps"
            workflow_test_errors=$((workflow_test_errors + 1))
        fi
    else
        print_error "Branch protection workflow not found"
        workflow_test_errors=$((workflow_test_errors + 1))
    fi
    
    return $workflow_test_errors
}

# Function to run integration tests
run_integration_tests() {
    print_status "Running integration tests..."
    
    local integration_test_errors=0
    
    # Branch tracking system integration
    print_info "Testing branch tracking system integration..."
    if [ -f "agentic-development/scripts/update-branch-tracking.js" ]; then
        # Test branch tracking script with mock data
        if node agentic-development/scripts/update-branch-tracking.js --help >/dev/null 2>&1; then
            print_success "Branch tracking script integration valid"
        else
            print_error "Branch tracking script integration failed"
            integration_test_errors=$((integration_test_errors + 1))
        fi
    else
        print_error "Branch tracking script not found"
        integration_test_errors=$((integration_test_errors + 1))
    fi
    
    # Agent status scripts integration
    print_info "Testing agent status scripts..."
    if [ -f "agentic-development/scripts/agent-status.sh" ] && [ -f "agentic-development/scripts/system-status.sh" ]; then
        print_success "Agent status scripts found"
    else
        print_error "Agent status scripts not found"
        integration_test_errors=$((integration_test_errors + 1))
    fi
    
    # Interactive validation integration
    print_info "Testing interactive validation tools..."
    if [ -f "scripts/branch-check" ] && [ -x "scripts/branch-check" ]; then
        print_success "Interactive validation tools available"
    else
        print_error "Interactive validation tools not found or not executable"
        integration_test_errors=$((integration_test_errors + 1))
    fi
    
    return $integration_test_errors
}

# Function to run comprehensive validation
run_comprehensive_tests() {
    print_status "Running comprehensive system validation..."
    
    local comprehensive_test_errors=0
    
    # Run branch-check command if available
    if [ -f "scripts/branch-check" ] && [ -x "scripts/branch-check" ]; then
        print_info "Running comprehensive branch validation..."
        if ! ./scripts/branch-check --no-interactive; then
            print_error "Comprehensive branch validation failed"
            comprehensive_test_errors=$((comprehensive_test_errors + 1))
        else
            print_success "Comprehensive branch validation passed"
        fi
    fi
    
    # Validate all JSON files in branch-tracking
    print_info "Validating branch tracking JSON files..."
    local json_files=(agentic-development/branch-tracking/*.json)
    for json_file in "${json_files[@]}"; do
        if [ -f "$json_file" ]; then
            if ! python3 -c "import json; json.load(open('$json_file'))" 2>/dev/null; then
                print_error "Invalid JSON in $json_file"
                comprehensive_test_errors=$((comprehensive_test_errors + 1))
            else
                print_success "$(basename "$json_file") JSON valid"
            fi
        fi
    done
    
    return $comprehensive_test_errors
}

# Function to determine test level based on context
determine_test_level() {
    local test_level="quick"
    
    # Check command line arguments first  
    if [[ "${1}" == "--full" ]]; then
        test_level="full"
    elif [[ "${1}" == "--quick" ]]; then
        test_level="quick"
    elif [[ "${1}" == "--safety" ]]; then
        test_level="safety"
    elif [[ "${1}" == "--workflows" ]]; then
        test_level="workflows"
    elif [[ "${1}" == "--integration" ]]; then
        test_level="integration"
    elif is_ci; then
        test_level="full"
        print_info "CI environment detected - running full test suite"
    elif [[ "${CURRENT_BRANCH}" == "dev" ]] || [[ "${CURRENT_BRANCH}" == "test" ]]; then
        test_level="thorough"
        print_info "On ${CURRENT_BRANCH} branch - running thorough tests"
    elif [[ "${CURRENT_BRANCH}" == "stage" ]] || [[ "${CURRENT_BRANCH}" == "main" ]]; then
        test_level="full"
        print_info "On production branch - running full test suite"
    else
        print_info "Feature branch detected - running quick tests"
    fi
    
    echo "$test_level"
}

# Main test execution logic
main() {
    local start_time=$(date +%s)
    
    print_header "Tuvens-Docs Comprehensive Test Runner"
    print_info "Branch: ${CURRENT_BRANCH}"
    print_info "Test Mode: ${TEST_MODE}"
    print_info "CI Environment: $(is_ci && echo 'Yes' || echo 'No')"
    echo ""
    
    # Validate environment first
    if ! validate_environment; then
        print_error "Environment validation failed"
        exit 1
    fi
    
    # Determine test level
    local test_level
    test_level=$(determine_test_level "$1")
    
    # Track test results
    local total_errors=0
    local tests_run=0
    
    # Run tests based on determined level
    case "$test_level" in
        "quick")
            print_header "Quick Test Suite (Safety Tests Only)"
            if ! run_safety_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            ;;
            
        "safety")
            print_header "Safety-Focused Test Suite"
            if ! run_safety_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            ;;
            
        "workflows")
            print_header "Workflow-Focused Test Suite"
            if ! run_safety_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            
            if ! run_workflow_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            ;;
            
        "integration")
            print_header "Integration Test Suite"
            if ! run_safety_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            
            if ! run_integration_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            ;;
            
        "thorough")
            print_header "Thorough Test Suite (Safety + Workflows + Integration)"
            if ! run_safety_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            
            if ! run_workflow_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            
            if ! run_integration_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            ;;
            
        "full")
            print_header "Full Test Suite (All Tests + Comprehensive Validation)"
            if ! run_safety_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            
            if ! run_workflow_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            
            if ! run_integration_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            
            if ! run_comprehensive_tests; then
                total_errors=$((total_errors + 1))
            fi
            tests_run=$((tests_run + 1))
            ;;
    esac
    
    # Final results
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    print_header "Test Results Summary"
    
    print_info "Test Suite: $test_level"
    print_info "Tests Run: $tests_run"
    print_info "Duration: ${duration}s"
    print_info "Branch: $CURRENT_BRANCH"
    
    if [ $total_errors -eq 0 ]; then
        print_success "All tests passed! ✨"
        print_success "$(printf "%*s" 60 | tr ' ' '=')"
        exit 0
    else
        print_error "Tests failed! 💔"
        print_error "$(printf "%*s" 60 | tr ' ' '=')"
        print_error "Failed test suites: $total_errors"
        print_warning "Please fix failing tests before pushing or merging"
        exit 1
    fi
}

# Handle script arguments and help
case "${1:-}" in
    --help|-h)
        print_header "Tuvens-Docs Test Runner Help"
        echo ""
        echo "Usage: ./scripts/test.sh [options]"
        echo ""
        echo "Options:"
        echo "  --quick       Run only safety tests (fast, for development)"
        echo "  --safety      Run safety and validation tests"
        echo "  --workflows   Run safety + workflow validation tests"
        echo "  --integration Run safety + integration tests"
        echo "  --thorough    Run safety + workflows + integration tests"
        echo "  --full        Run complete test suite with comprehensive validation"
        echo "  --help        Show this help message"
        echo ""
        echo "Default behavior (auto-detection):"
        echo "  • Feature branches: Quick tests (safety only)"
        echo "  • Dev/Test branches: Thorough tests"
        echo "  • Stage/Main branches: Full test suite"
        echo "  • CI environment: Full test suite"
        echo ""
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac