#!/usr/bin/env bash
# File: install-status-automation.sh
# Purpose: Install git hooks and configure iTerm2 status automation
# Part of Phase 2 iTerm2 Status Automation

set -euo pipefail

echo "🔧 Installing iTerm2 Status Automation - Phase 2"
echo "=============================================="
echo ""

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(git rev-parse --show-toplevel)"
HOOKS_DIR="$REPO_ROOT/.git/hooks"

# Function to install a git hook
install_hook() {
    local hook_name="$1"
    local source_file="$SCRIPT_DIR/git-hooks/$hook_name"
    local target_file="$HOOKS_DIR/$hook_name"
    
    if [[ ! -f "$source_file" ]]; then
        echo "❌ Hook source not found: $source_file"
        return 1
    fi
    
    # Backup existing hook if it exists
    if [[ -f "$target_file" ]]; then
        echo "📄 Backing up existing $hook_name hook"
        cp "$target_file" "$target_file.backup.$(date +%s)"
    fi
    
    # Copy and make executable
    cp "$source_file" "$target_file"
    chmod +x "$target_file"
    
    echo "✅ Installed $hook_name hook"
}

# Function to verify prerequisites
verify_prerequisites() {
    local missing_tools=()
    
    # Check required tools
    if ! command -v git >/dev/null 2>&1; then
        missing_tools+=("git")
    fi
    
    if ! command -v gh >/dev/null 2>&1; then
        missing_tools+=("gh")
    fi
    
    if ! command -v jq >/dev/null 2>&1; then
        missing_tools+=("jq")
    fi
    
    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        echo "❌ Missing required tools: ${missing_tools[*]}"
        echo "   Please install these tools before proceeding"
        return 1
    fi
    
    # Check if we're in a git repo
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo "❌ Not in a git repository"
        return 1
    fi
    
    # Check GitHub authentication
    if ! gh auth status >/dev/null 2>&1; then
        echo "❌ GitHub CLI not authenticated"
        echo "   Run: gh auth login"
        return 1
    fi
    
    # Check if automation scripts exist
    if [[ ! -f "$SCRIPT_DIR/status-determination-engine.sh" ]]; then
        echo "❌ Status determination engine not found"
        return 1
    fi
    
    if [[ ! -f "$SCRIPT_DIR/iterm-status-updater.sh" ]]; then
        echo "❌ iTerm status updater not found"
        return 1
    fi
    
    echo "✅ Prerequisites verified"
    return 0
}

# Function to install git hooks
install_git_hooks() {
    echo ""
    echo "📋 Installing Git Hooks..."
    
    local hooks=("post-commit" "pre-push" "post-merge")
    
    for hook in "${hooks[@]}"; do
        install_hook "$hook"
    done
    
    echo ""
    echo "📝 Git hooks installed:"
    echo "  • post-commit: Sets status to ACTIVE after commits"
    echo "  • pre-push: Sets status to REVIEWING when pushing to PR branch"  
    echo "  • post-merge: Sets status to COMPLETE when PR is merged"
}

# Function to make scripts executable
setup_script_permissions() {
    echo ""
    echo "🔐 Setting up script permissions..."
    
    local scripts=(
        "github-webhook-handler.sh"
        "status-determination-engine.sh" 
        "iterm-status-updater.sh"
        "setup-status-labels.sh"
    )
    
    for script in "${scripts[@]}"; do
        if [[ -f "$SCRIPT_DIR/$script" ]]; then
            chmod +x "$SCRIPT_DIR/$script"
            echo "✅ Made $script executable"
        fi
    done
}

# Function to create status automation log
setup_logging() {
    echo ""
    echo "📊 Setting up logging..."
    
    local log_file="$REPO_ROOT/.git/status-automation.log"
    
    # Create log file if it doesn't exist
    if [[ ! -f "$log_file" ]]; then
        touch "$log_file"
        echo "$(date): Status automation installed" >> "$log_file"
        echo "✅ Created status automation log: $log_file"
    else
        echo "✅ Status automation log exists: $log_file"
    fi
}

# Function to test the installation
test_installation() {
    echo ""
    echo "🧪 Testing installation..."
    
    # Test status determination engine
    if "$SCRIPT_DIR/status-determination-engine.sh" test >/dev/null 2>&1; then
        echo "✅ Status determination engine test passed"
    else
        echo "⚠️  Status determination engine test failed"
    fi
    
    # Test iTerm status updater
    if "$SCRIPT_DIR/iterm-status-updater.sh" test >/dev/null 2>&1; then
        echo "✅ iTerm status updater test passed"
    else
        echo "⚠️  iTerm status updater test failed"
    fi
    
    # Check git hooks are executable
    local hooks=("post-commit" "pre-push" "post-merge")
    local hooks_ok=true
    
    for hook in "${hooks[@]}"; do
        if [[ -x "$HOOKS_DIR/$hook" ]]; then
            echo "✅ $hook hook is executable"
        else
            echo "❌ $hook hook is not executable"
            hooks_ok=false
        fi
    done
    
    if [[ "$hooks_ok" == "true" ]]; then
        echo "✅ All git hooks installed correctly"
    else
        echo "❌ Some git hooks have issues"
        return 1
    fi
}

# Function to display next steps
show_next_steps() {
    echo ""
    echo "🎯 Next Steps:"
    echo ""
    echo "1. **Configure iTerm2 Status Bar** (if not done already):"
    echo "   • Go to iTerm2 → Preferences → Profiles → Session"
    echo "   • Configure Status Bar with these components:"
    echo "     - Interpolated String: \\(user.issue_number)"
    echo "     - Interpolated String: \\(user.issue_status)" 
    echo "     - Interpolated String: \\(user.file_changes)"
    echo "     - Interpolated String: \\(user.issue_updated)"
    echo ""
    echo "2. **Test the automation:**
    echo "   • Make a commit and check if status updates to ACTIVE"
    echo "   • Create a PR and check if status updates to REVIEWING"
    echo "   • Post an agent comment with status and verify updates"
    echo ""
    echo "3. **Monitor logs:**
    echo "   • View automation log: tail -f .git/status-automation.log"
    echo "   • Check GitHub issue labels for automatic updates"
    echo ""
    echo "4. **Webhook setup** (optional, for full automation):"
    echo "   • Configure GitHub webhook pointing to your server"
    echo "   • Use github-webhook-handler.sh to process events"
    echo ""
    echo "🚀 Status automation is now installed and ready!"
}

# Main installation process
main() {
    echo "Starting installation..."
    
    # Verify prerequisites
    if ! verify_prerequisites; then
        echo ""
        echo "❌ Installation failed - prerequisites not met"
        exit 1
    fi
    
    # Install components
    setup_script_permissions
    install_git_hooks
    setup_logging
    
    # Test installation
    if ! test_installation; then
        echo ""
        echo "⚠️  Installation completed with warnings"
        echo "   Some components may not work correctly"
        echo "   Check the error messages above"
        exit 1
    fi
    
    # Show next steps
    show_next_steps
    
    echo ""
    echo "✅ Installation completed successfully!"
    echo ""
}

# Uninstall function
uninstall() {
    echo "🗑️  Uninstalling iTerm2 Status Automation..."
    echo ""
    
    local hooks=("post-commit" "pre-push" "post-merge")
    
    for hook in "${hooks[@]}"; do
        local hook_file="$HOOKS_DIR/$hook"
        if [[ -f "$hook_file" ]]; then
            # Check if this is our hook (contains our signature)
            if grep -q "Part of Phase 2 iTerm2 Status Automation" "$hook_file"; then
                rm "$hook_file"
                echo "✅ Removed $hook hook"
                
                # Restore backup if it exists
                local backup_file="$hook_file.backup."*
                if ls $backup_file >/dev/null 2>&1; then
                    local latest_backup
                    latest_backup=$(ls -t $backup_file 2>/dev/null | head -1)
                    if [[ -f "$latest_backup" ]]; then
                        mv "$latest_backup" "$hook_file"
                        echo "✅ Restored backup for $hook"
                    fi
                fi
            else
                echo "⚠️  $hook hook exists but doesn't appear to be ours - skipping"
            fi
        fi
    done
    
    echo ""
    echo "✅ Uninstall completed"
    echo "   Manual status updates can still be done with:"
    echo "   ./agentic-development/scripts/iterm-status-updater.sh [issue]"
}

# Handle command line arguments
case "${1:-install}" in
    "install")
        main
        ;;
    "uninstall")
        uninstall
        ;;
    "test")
        verify_prerequisites && test_installation
        ;;
    *)
        echo "Usage: $0 [install|uninstall|test]"
        echo ""
        echo "Commands:"
        echo "  install   - Install status automation (default)"
        echo "  uninstall - Remove status automation hooks"
        echo "  test      - Test installation"
        exit 1
        ;;
esac