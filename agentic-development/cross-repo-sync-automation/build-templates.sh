#!/bin/bash

# Template assembly script
# Builds final notification templates from modular components

TEMPLATE_DIR="./templates"
COMMON_DIR="$TEMPLATE_DIR/_common"

# Function to build a template
build_template() {
    local repo_type=$1
    local output_file="$TEMPLATE_DIR/${repo_type}-notification.md"
    
    echo "Building ${repo_type} notification template..."
    
    # Start with header
    sed "s/\[REPO_TYPE\]/${repo_type}/g" "$COMMON_DIR/header-template.md" > "$output_file"
    echo "" >> "$output_file"
    
    # Add critical changes (repo-specific)
    if [ -f "$TEMPLATE_DIR/_repo-specific/${repo_type}-critical-changes.md" ]; then
        cat "$TEMPLATE_DIR/_repo-specific/${repo_type}-critical-changes.md" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    # Add required actions header
    echo "### 📋 REQUIRED ACTIONS" >> "$output_file"
    echo "" >> "$output_file"
    
    # Add common submodule update step
    cat "$COMMON_DIR/submodule-update-step.md" >> "$output_file"
    echo "" >> "$output_file"
    
    # Add verification step (repo-specific paths)
    if [ -f "$TEMPLATE_DIR/_repo-specific/${repo_type}-verification.md" ]; then
        cat "$TEMPLATE_DIR/_repo-specific/${repo_type}-verification.md" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    # Add repo-specific actions
    if [ -f "$TEMPLATE_DIR/_repo-specific/${repo_type}-specific-actions.md" ]; then
        cat "$TEMPLATE_DIR/_repo-specific/${repo_type}-specific-actions.md" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    # Add completion confirmation (repo-specific)
    if [ -f "$TEMPLATE_DIR/_repo-specific/${repo_type}-completion.md" ]; then
        cat "$TEMPLATE_DIR/_repo-specific/${repo_type}-completion.md" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    # Add common timeline
    cat "$COMMON_DIR/timeline-requirements.md" >> "$output_file"
    echo "" >> "$output_file"
    
    # Add help section with repo-specific additions
    cat "$COMMON_DIR/help-section.md" >> "$output_file"
    if [ -f "$TEMPLATE_DIR/_repo-specific/${repo_type}-help-additions.md" ]; then
        cat "$TEMPLATE_DIR/_repo-specific/${repo_type}-help-additions.md" >> "$output_file"
    fi
    echo "" >> "$output_file"
    
    # Add common automated verification
    cat "$COMMON_DIR/automated-verification-setup.md" >> "$output_file"
    echo "" >> "$output_file"
    
    # Add repo-specific quality standards
    if [ -f "$TEMPLATE_DIR/_repo-specific/${repo_type}-quality-standards.md" ]; then
        cat "$TEMPLATE_DIR/_repo-specific/${repo_type}-quality-standards.md" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    # Add common footer
    cat "$COMMON_DIR/footer.md" >> "$output_file"
    
    echo "✅ Built $output_file"
}

# Create directory structure
mkdir -p "$TEMPLATE_DIR/_repo-specific"

# Build all templates
build_template "backend"
build_template "frontend" 
build_template "integration"
build_template "mobile"

echo ""
echo "🎉 All templates built successfully!"
echo "Templates are modular and maintainable:"
echo "  - Common sections: $COMMON_DIR/"
echo "  - Repo-specific: $TEMPLATE_DIR/_repo-specific/"
echo ""
echo "To modify shared content: Edit files in $COMMON_DIR/"
echo "To modify repo-specific content: Edit files in $TEMPLATE_DIR/_repo-specific/"
echo "To rebuild: Run this script again"