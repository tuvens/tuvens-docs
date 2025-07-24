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

# Define ecosystem defaults (users can customize these later)
ECOSYSTEM_NAME="Tuvens"
PROJECT_1="tuvens-api"
PROJECT_2="eventdigest-ai"
PROJECT_3="hi.events"
REFERENCE_PROJECT="tuvens-docs"

# Generate placeholder URLs and purposes
CURRENT_PROJECT_URL="https://github.com/tuvens/$REPO_NAME"
PROJECT_1_URL="https://github.com/tuvens/tuvens-api"
PROJECT_2_URL="https://github.com/tuvens/eventdigest-ai"
CURRENT_PROJECT_PURPOSE="Component of the $ECOSYSTEM_NAME ecosystem"
PROJECT_1_PURPOSE="Backend API services for the $ECOSYSTEM_NAME platform"
PROJECT_2_PURPOSE="Event aggregation and curation frontend application"
PROJECT_3_PURPOSE="Ticketing platform integration"

# Update all repository references in files
echo "Replacing basic placeholders..."
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{CURRENT_REPOSITORY}/$REPO_NAME/g" {} \;
find docs/.claude -name "*.json" -type f -exec sed -i.bak "s/{PROJECT_NAME}/$REPO_NAME/g" {} \;
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{CURRENT_PROJECT}/$REPO_NAME/g" {} \;

# Update ecosystem and project placeholders
echo "Replacing ecosystem placeholders..."
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{ECOSYSTEM_NAME}/$ECOSYSTEM_NAME/g" {} \;
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{REFERENCE_PROJECT}/$REFERENCE_PROJECT/g" {} \;

# Update project registry placeholders
echo "Replacing integration registry placeholders..."
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{PROJECT_1}/$PROJECT_1/g" {} \;
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{PROJECT_2}/$PROJECT_2/g" {} \;
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{PROJECT_3}/$PROJECT_3/g" {} \;

# Update URL placeholders
echo "Replacing URL placeholders..."
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s|{CURRENT_PROJECT_URL}|$CURRENT_PROJECT_URL|g" {} \;
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s|{PROJECT_1_URL}|$PROJECT_1_URL|g" {} \;
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s|{PROJECT_2_URL}|$PROJECT_2_URL|g" {} \;

# Update purpose placeholders
echo "Replacing purpose placeholders..."
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{CURRENT_PROJECT_PURPOSE}/$CURRENT_PROJECT_PURPOSE/g" {} \;
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{PROJECT_1_PURPOSE}/$PROJECT_1_PURPOSE/g" {} \;
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{PROJECT_2_PURPOSE}/$PROJECT_2_PURPOSE/g" {} \;
find docs/.claude -name "*.md" -type f -exec sed -i.bak "s/{PROJECT_3_PURPOSE}/$PROJECT_3_PURPOSE/g" {} \;

# Verify all placeholders have been replaced
echo "Verifying placeholder replacement..."
REMAINING_PLACEHOLDERS=$(find docs/.claude -name "*.md" -o -name "*.json" | xargs grep -l '{[A-Z_]*}' 2>/dev/null || true)
if [ -n "$REMAINING_PLACEHOLDERS" ]; then
    echo "⚠️  Warning: Some placeholders may still need manual customization:"
    find docs/.claude -name "*.md" -o -name "*.json" | xargs grep -n '{[A-Z_]*}' 2>/dev/null || true
    echo ""
    echo "   Please review and customize these placeholders manually."
fi

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