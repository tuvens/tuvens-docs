#!/usr/bin/env bash
# Setup GitHub labels for agent workflow status tracking

set -euo pipefail

echo "🏷️  Setting up GitHub status labels..."
echo ""

# Status labels with colors and descriptions
declare -A status_labels=(
    ["status/active"]="28a745:Agent actively working on task"
    ["status/waiting"]="ffc107:Agent waiting for input or review"
    ["status/blocked"]="dc3545:Agent blocked by external dependencies"
    ["status/reviewing"]="6f42c1:Work completed, PR submitted for review"
    ["status/complete"]="0e8a16:Task completed successfully"
)

# Agent labels with colors
declare -A agent_labels=(
    ["agent/vibe-coder"]="9b59b6:Vibe Coder agent - System architecture"
    ["agent/devops"]="ff9900:DevOps agent - Infrastructure"
    ["agent/qa"]="d73a4a:QA agent - Testing and quality"
    ["agent/react-dev"]="61dafb:React Developer agent"
    ["agent/laravel-dev"]="ff2d20:Laravel Developer agent"
    ["agent/svelte-dev"]="ff3e00:Svelte Developer agent"
    ["agent/node-dev"]="339933:Node.js Developer agent"
    ["agent/codehooks-dev"]="007acc:CodeHooks Developer agent"
)

# Priority labels
declare -A priority_labels=(
    ["priority/critical"]="b60205:Critical priority - immediate attention"
    ["priority/high"]="d93f0b:High priority"
    ["priority/medium"]="fbca04:Medium priority"
    ["priority/low"]="0e8a16:Low priority"
)

# Create status labels
echo "📊 Creating status labels..."
for label in "${!status_labels[@]}"; do
    IFS=':' read -r color description <<< "${status_labels[$label]}"
    if gh label create "$label" --color "$color" --description "$description" 2>/dev/null; then
        echo "  ✅ Created: $label"
    else
        echo "  ⚠️  Exists: $label (updating...)"
        gh label edit "$label" --color "$color" --description "$description" 2>/dev/null || true
    fi
done

echo ""
echo "🤖 Creating agent labels..."
for label in "${!agent_labels[@]}"; do
    IFS=':' read -r color description <<< "${agent_labels[$label]}"
    if gh label create "$label" --color "$color" --description "$description" 2>/dev/null; then
        echo "  ✅ Created: $label"
    else
        echo "  ⚠️  Exists: $label (updating...)"
        gh label edit "$label" --color "$color" --description "$description" 2>/dev/null || true
    fi
done

echo ""
echo "🎯 Creating priority labels..."
for label in "${!priority_labels[@]}"; do
    IFS=':' read -r color description <<< "${priority_labels[$label]}"
    if gh label create "$label" --color "$color" --description "$description" 2>/dev/null; then
        echo "  ✅ Created: $label"
    else
        echo "  ⚠️  Exists: $label (updating...)"
        gh label edit "$label" --color "$color" --description "$description" 2>/dev/null || true
    fi
done

echo ""
echo "✅ Label setup complete!"
echo ""
echo "📝 Usage:"
echo "  Update issue status:  gh issue edit [number] --add-label 'status/waiting'"
echo "  List active agents:   gh issue list --label 'agent-task,status/active'"
echo "  List waiting tasks:   gh issue list --label 'status/waiting'"