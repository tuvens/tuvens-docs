#!/bin/bash

# Documentation Templates Setup Script
# This script sets up the Claude Code documentation structure in your repository

set -e

REPO_NAME=""
SETUP_TYPE=""

show_help() {
    echo "Documentation Templates Setup Script"
    echo ""
    echo "Usage: $0 --repo REPO_NAME [--type TYPE]"
    echo ""
    echo "Arguments:"
    echo "  --repo REPO_NAME    Your repository name (e.g., tuvens-client, tuvens-api, hi.events)"
    echo "  --type TYPE         Setup type: submodule, copy, or subdirectory (default: copy)"
    echo ""
    echo "Examples:"
    echo "  $0 --repo tuvens-client"
    echo "  $0 --repo tuvens-api --type submodule"
    echo ""
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --repo)
            REPO_NAME="$2"
            shift 2
            ;;
        --type)
            SETUP_TYPE="$2"
            shift 2
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$REPO_NAME" ]]; then
    echo "Error: --repo is required"
    show_help
    exit 1
fi

# Set default setup type
if [[ -z "$SETUP_TYPE" ]]; then
    SETUP_TYPE="copy"
fi

echo "Setting up Tuvens documentation templates for: $REPO_NAME"
echo "Setup type: $SETUP_TYPE"
echo ""

# Create docs structure
echo "Creating docs structure..."
mkdir -p docs/.claude/commands
mkdir -p docs/.temp/{complete,redundant,in-progress,ready-for-implementation,integration-rqts,bug-reports,archived,deprecated,screenshots,reports,implementation-guides,integration-docs,auto-generated,commands}

# Copy templates based on setup type
case $SETUP_TYPE in
    submodule)
        echo "Setting up as git submodule..."
        git submodule add https://github.com/tuvens/tuvens-docs.git docs/shared-templates
        git submodule update --init --recursive
        cp -r docs/shared-templates/claude-templates/commands/* docs/.claude/commands/
        cp docs/shared-templates/claude-templates/INTEGRATION_REGISTRY.md docs/.claude/
        ;;
    subdirectory)
        echo "Setting up as subdirectory..."
        git clone https://github.com/tuvens/tuvens-docs.git docs/tuvens-shared
        ln -sf ../tuvens-shared/claude-templates/commands/* docs/.claude/commands/
        ln -sf ../tuvens-shared/claude-templates/INTEGRATION_REGISTRY.md docs/.claude/
        ;;
    copy|*)
        echo "Copying templates..."
        # For this script, we assume templates are in the same directory
        cp -r claude-templates/commands/* docs/.claude/commands/
        cp claude-templates/INTEGRATION_REGISTRY.md docs/.claude/
        ;;
esac

echo "Customizing templates for $REPO_NAME..."

# Update repository references in all files
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{CURRENT_REPOSITORY}/$REPO_NAME/g" {} \;
find docs/.claude -name "*.json" -type f -exec sed -i.bak "s/{PROJECT_NAME}/$REPO_NAME/g" {} \;
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{ECOSYSTEM_NAME}/Your Ecosystem/g" {} \;

# Update integration registry placeholders (user should customize these)
sed -i.bak "s/{CURRENT_PROJECT}/$REPO_NAME/g" docs/.claude/INTEGRATION_REGISTRY.md

# Clean up backup files
find docs/.claude -name "*.bak" -delete

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "1. Review docs/.claude/commands/commands.json"
echo "2. Check docs/.claude/INTEGRATION_REGISTRY.md"
echo "3. Customize any repository-specific details"
echo "4. Commit the changes to your repository"
echo ""
echo "Your Claude Code documentation structure is ready!"