#!/bin/bash
# Environment Setup Automation - Tuvens Project Infrastructure
# Replicates event-harvester environment setup patterns

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
REQUIRED_NODE_VERSION="18"
REQUIRED_PYTHON_VERSION="3.8"

print_header() {
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC} $1"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
}

print_status() {
    echo -e "${BLUE}[SETUP]${NC} $1"
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

# Function to check and install Node.js if needed
setup_nodejs() {
    print_status "Checking Node.js setup..."
    
    if command -v node >/dev/null 2>&1; then
        local node_version=$(node --version | cut -d'v' -f2)
        if [[ "$(printf '%s\n' "$REQUIRED_NODE_VERSION" "$node_version" | sort -V | head -n1)" == "$REQUIRED_NODE_VERSION" ]]; then
            print_success "Node.js v$node_version is installed and compatible"
        else
            print_warning "Node.js v$node_version detected, but v$REQUIRED_NODE_VERSION+ is recommended"
        fi
    else
        print_error "Node.js is not installed"
        print_info "Please install Node.js v$REQUIRED_NODE_VERSION+ from https://nodejs.org/"
        return 1
    fi
    
    # Check npm
    if command -v npm >/dev/null 2>&1; then
        local npm_version=$(npm --version)
        print_success "npm v$npm_version is available"
    else
        print_error "npm is not available"
        return 1
    fi
}

# Function to setup Python environment
setup_python() {
    print_status "Checking Python setup..."
    
    if command -v python3 >/dev/null 2>&1; then
        local python_version=$(python3 --version | cut -d' ' -f2)
        print_success "Python $python_version is installed"
    else
        print_error "Python 3 is not installed"
        print_info "Please install Python 3.8+ from https://python.org/"
        return 1
    fi
    
    # Check pip
    if command -v pip3 >/dev/null 2>&1 || command -v pip >/dev/null 2>&1; then
        print_success "pip is available"
    else
        print_warning "pip is not available - some features may not work"
    fi
}

# Function to setup git hooks
setup_git_hooks() {
    print_status "Setting up git hooks..."
    
    if [ -f ".pre-commit-config.yaml" ]; then
        if command -v pre-commit >/dev/null 2>&1; then
            print_info "Installing pre-commit hooks..."
            if pre-commit install; then
                print_success "Pre-commit hooks installed"
            else
                print_error "Failed to install pre-commit hooks"
                return 1
            fi
        else
            print_warning "pre-commit not found, installing via pip..."
            if command -v pip3 >/dev/null 2>&1; then
                pip3 install pre-commit
                pre-commit install
                print_success "Pre-commit installed and hooks configured"
            else
                print_error "Cannot install pre-commit - pip3 not available"
                return 1
            fi
        fi
    else
        print_warning ".pre-commit-config.yaml not found - skipping hook setup"
    fi
}

# Function to validate project structure
validate_project_structure() {
    print_status "Validating project structure..."
    
    local validation_errors=0
    
    # Check for required directories
    local required_dirs=("agentic-development" "scripts" "scripts/hooks")
    for dir in "${required_dirs[@]}"; do
        if [ ! -d "$dir" ]; then
            print_error "Required directory missing: $dir"
            validation_errors=$((validation_errors + 1))
        else
            print_success "Directory found: $dir"
        fi
    done
    
    # Check for critical files
    local critical_files=("CLAUDE.md" "package.json")
    for file in "${critical_files[@]}"; do
        if [ ! -f "$file" ]; then
            print_error "Critical file missing: $file"
            validation_errors=$((validation_errors + 1))
        else
            print_success "File found: $file"
        fi
    done
    
    # Check script permissions
    local scripts=("scripts/branch-check")
    for script in "${scripts[@]}"; do
        if [ -f "$script" ]; then
            if [ ! -x "$script" ]; then
                print_warning "Making $script executable..."
                chmod +x "$script"
            fi
            print_success "Script executable: $script"
        fi
    done
    
    return $validation_errors
}

# Function to create .env template if needed
setup_environment_files() {
    print_status "Setting up environment files..."
    
    if [ ! -f ".env.example" ]; then
        print_info "Creating .env.example template..."
        cat > .env.example << 'EOF'
# Tuvens Project Environment Configuration
# Copy this file to .env and configure as needed

# Development settings
NODE_ENV=development
DEBUG=true

# GitHub integration (optional)
GITHUB_TOKEN=your_github_token_here

# Agent configuration
AGENT_NAME=devops
TASK_TYPE=feature

# Branch tracking
ENABLE_BRANCH_TRACKING=true
BRANCH_PROTECTION_ENABLED=true

# Testing configuration
TEST_TIMEOUT=300
COVERAGE_THRESHOLD=75

# Logging
LOG_LEVEL=info
LOG_FILE=logs/tuvens.log
EOF
        print_success ".env.example created"
    else
        print_success ".env.example already exists"
    fi
    
    # Create logs directory if it doesn't exist
    if [ ! -d "logs" ]; then
        mkdir -p logs
        echo "*.log" > logs/.gitignore
        print_success "logs directory created"
    fi
}

# Function to install npm dependencies
setup_npm_dependencies() {
    print_status "Installing npm dependencies..."
    
    if [ -f "package.json" ]; then
        if npm install; then
            print_success "npm dependencies installed"
        else
            print_error "Failed to install npm dependencies"
            return 1
        fi
    else
        print_warning "package.json not found - skipping npm install"
    fi
}

# Function to run initial validation
run_initial_validation() {
    print_status "Running initial system validation..."
    
    # Try to run the branch check if available
    if [ -f "scripts/branch-check" ] && [ -x "scripts/branch-check" ]; then
        print_info "Running branch validation check..."
        if ./scripts/branch-check --no-interactive 2>/dev/null; then
            print_success "Initial branch validation passed"
        else
            print_warning "Branch validation completed with warnings - this is normal for setup"
        fi
    fi
    
    # Validate JSON files if they exist
    local json_files=("agentic-development/branch-tracking/*.json")
    for pattern in "${json_files[@]}"; do
        for json_file in $pattern; do
            if [ -f "$json_file" ]; then
                if python3 -c "import json; json.load(open('$json_file'))" 2>/dev/null; then
                    print_success "JSON valid: $(basename "$json_file")"
                else
                    print_warning "JSON validation failed: $(basename "$json_file")"
                fi
            fi
        done
    done
}

# Main setup function
main() {
    local start_time=$(date +%s)
    
    print_header "Tuvens Project Environment Setup"
    print_info "Initializing development environment..."
    print_info "Working directory: $(pwd)"
    echo ""
    
    local setup_errors=0
    
    # Run setup steps
    setup_nodejs || setup_errors=$((setup_errors + 1))
    setup_python || setup_errors=$((setup_errors + 1))
    
    if ! validate_project_structure; then
        setup_errors=$((setup_errors + 1))
    fi
    
    setup_environment_files
    setup_npm_dependencies || setup_errors=$((setup_errors + 1))
    setup_git_hooks || setup_errors=$((setup_errors + 1))
    
    run_initial_validation
    
    # Final results
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    echo ""
    print_header "Environment Setup Results"
    
    if [ $setup_errors -eq 0 ]; then
        print_success "Environment setup completed successfully! ✨"
        print_info "Duration: ${duration}s"
        echo ""
        print_info "Next steps:"
        print_info "  • Run 'npm test' to validate the setup"
        print_info "  • Run 'npm run validate' to check branch status"
        print_info "  • Review .env.example for configuration options"
        print_info "  • Check CLAUDE.md for development guidelines"
        echo ""
        print_success "Your development environment is ready!"
        exit 0
    else
        print_error "Environment setup completed with $setup_errors errors"
        print_warning "Please resolve the errors above before proceeding"
        print_info "Duration: ${duration}s"
        exit 1
    fi
}

# Handle script arguments and help
case "${1:-}" in
    --help|-h)
        print_header "Tuvens Environment Setup Help"
        echo ""
        echo "Usage: ./scripts/setup-environment.sh [options]"
        echo ""
        echo "This script sets up the development environment by:"
        echo "  • Validating Node.js and Python installations"
        echo "  • Installing npm dependencies"
        echo "  • Setting up git pre-commit hooks"
        echo "  • Creating environment file templates"
        echo "  • Validating project structure"
        echo "  • Running initial system validation"
        echo ""
        echo "Options:"
        echo "  --help        Show this help message"
        echo ""
        exit 0
        ;;
    *)
        main "$@"
        ;;
esac