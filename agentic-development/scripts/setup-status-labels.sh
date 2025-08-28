#!/usr/bin/env bash
# Setup GitHub labels for agent workflow status tracking

set -euo pipefail

echo "🏷️  Setting up GitHub status labels..."
echo ""

# Status labels - using simple format
echo "📊 Creating status labels..."
gh label create "status/active" --color "28a745" --description "Agent actively working on task" 2>/dev/null || echo "  ⚠️  Exists: status/active"
gh label create "status/waiting" --color "ffc107" --description "Agent waiting for input or review" 2>/dev/null || echo "  ⚠️  Exists: status/waiting"
gh label create "status/blocked" --color "dc3545" --description "Agent blocked by external dependencies" 2>/dev/null || echo "  ⚠️  Exists: status/blocked"
gh label create "status/reviewing" --color "6f42c1" --description "Work completed, PR submitted for review" 2>/dev/null || echo "  ⚠️  Exists: status/reviewing"
gh label create "status/complete" --color "0e8a16" --description "Task completed successfully" 2>/dev/null || echo "  ⚠️  Exists: status/complete"

echo ""
echo "🤖 Creating agent labels..."
gh label create "agent/vibe-coder" --color "9b59b6" --description "Vibe Coder agent - System architecture" 2>/dev/null || echo "  ⚠️  Exists: agent/vibe-coder"
gh label create "agent/devops" --color "ff9900" --description "DevOps agent - Infrastructure" 2>/dev/null || echo "  ⚠️  Exists: agent/devops"
gh label create "agent/qa" --color "d73a4a" --description "QA agent - Testing and quality" 2>/dev/null || echo "  ⚠️  Exists: agent/qa"
gh label create "agent/react-dev" --color "61dafb" --description "React Developer agent" 2>/dev/null || echo "  ⚠️  Exists: agent/react-dev"
gh label create "agent/laravel-dev" --color "ff2d20" --description "Laravel Developer agent" 2>/dev/null || echo "  ⚠️  Exists: agent/laravel-dev"
gh label create "agent/svelte-dev" --color "ff3e00" --description "Svelte Developer agent" 2>/dev/null || echo "  ⚠️  Exists: agent/svelte-dev"
gh label create "agent/node-dev" --color "339933" --description "Node.js Developer agent" 2>/dev/null || echo "  ⚠️  Exists: agent/node-dev"
gh label create "agent/codehooks-dev" --color "007acc" --description "CodeHooks Developer agent" 2>/dev/null || echo "  ⚠️  Exists: agent/codehooks-dev"

echo ""
echo "🎯 Creating priority labels..."
gh label create "priority/critical" --color "b60205" --description "Critical priority - immediate attention" 2>/dev/null || echo "  ⚠️  Exists: priority/critical"
gh label create "priority/high" --color "d93f0b" --description "High priority" 2>/dev/null || echo "  ⚠️  Exists: priority/high"
gh label create "priority/medium" --color "fbca04" --description "Medium priority" 2>/dev/null || echo "  ⚠️  Exists: priority/medium"
gh label create "priority/low" --color "0e8a16" --description "Low priority" 2>/dev/null || echo "  ⚠️  Exists: priority/low"

echo ""
echo "✅ Label setup complete!"
echo ""
echo "📝 Usage:"
echo "  Update issue status:  gh issue edit [number] --add-label 'status/waiting'"
echo "  List active agents:   gh issue list --label 'agent-task,status/active'"
echo "  List waiting tasks:   gh issue list --label 'status/waiting'"