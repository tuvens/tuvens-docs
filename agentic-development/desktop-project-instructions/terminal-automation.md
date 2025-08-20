# Terminal Automation with iTerm MCP Server

**[DESKTOP] - Terminal automation patterns for multi-agent coordination**

The iTerm MCP Server enables automated terminal management across all agents in the Tuvens multi-agent system.

## Core Concepts

### Agent Terminal Isolation
Each agent maintains separate, named terminal sessions to prevent conflicts:

```
# Naming Convention: {agent-name}-{purpose}
node-dev-main          # Main development server
node-dev-test          # Test runner
laravel-dev-serve      # Laravel artisan serve
react-dev-storybook    # Storybook component development
svelte-dev-main        # Svelte dev server
devops-docker          # Docker operations
devops-k8s             # Kubernetes monitoring
```

### Session Lifecycle Management
1. **Create**: Open named terminal for specific purpose
2. **Execute**: Run commands and monitor output
3. **Monitor**: Read output to verify success
4. **Cleanup**: Close terminal when task completes

## Agent-Specific Patterns

### Node.js Development (node-dev)
```
# Start development environment
open_terminal name="node-dev-main" 
execute_command terminal="node-dev-main" command="cd tuvens-api && npm run dev"

# Run tests in parallel
open_terminal name="node-dev-test"
execute_command terminal="node-dev-test" command="cd tuvens-api && npm test -- --watch"

# Database operations
open_terminal name="node-dev-db"
execute_command terminal="node-dev-db" command="cd tuvens-api && npm run db:seed"
```

### Laravel Development (laravel-dev)
```
# Laravel application server
open_terminal name="laravel-dev-serve"
execute_command terminal="laravel-dev-serve" command="cd hi.events && php artisan serve"

# Queue worker
open_terminal name="laravel-dev-queue"
execute_command terminal="laravel-dev-queue" command="cd hi.events && php artisan queue:work"

# Database operations
open_terminal name="laravel-dev-migrate"
execute_command terminal="laravel-dev-migrate" command="cd hi.events && php artisan migrate:fresh --seed"
```

### React Development (react-dev)
```
# React development server
open_terminal name="react-dev-main"
execute_command terminal="react-dev-main" command="cd hi.events/frontend && npm start"

# Storybook for component development
open_terminal name="react-dev-storybook"
execute_command terminal="react-dev-storybook" command="cd hi.events/frontend && npm run storybook"

# Testing environment
open_terminal name="react-dev-test"
execute_command terminal="react-dev-test" command="cd hi.events/frontend && npm test -- --watchAll"
```

### Svelte Development (svelte-dev)
```
# Svelte development server (tuvens-client)
open_terminal name="svelte-dev-main"
execute_command terminal="svelte-dev-main" command="cd tuvens-client && npm run dev"

# Svelte 5 development (eventsdigest-ai)
open_terminal name="svelte-dev-ai"
execute_command terminal="svelte-dev-ai" command="cd eventsdigest-ai && npm run dev"

# Build and preview
open_terminal name="svelte-dev-build"
execute_command terminal="svelte-dev-build" command="cd tuvens-client && npm run build && npm run preview"
```

### DevOps Operations (devops)
```
# Docker Compose operations
open_terminal name="devops-docker"
execute_command terminal="devops-docker" command="docker-compose up -d"

# Kubernetes monitoring
open_terminal name="devops-k8s"
execute_command terminal="devops-k8s" command="kubectl get pods -w"

# Log monitoring
open_terminal name="devops-logs"
execute_command terminal="devops-logs" command="docker-compose logs -f api"
```

## Git Workflow Integration

### Branch Operations
```
# Create feature branch
execute_command terminal="main" command="git checkout -b feature/new-component"

# Check status and commit
execute_command terminal="main" command="git status"
read_output terminal="main"
execute_command terminal="main" command="git add . && git commit -m 'Add new component'"

# Push and create PR
execute_command terminal="main" command="git push -u origin feature/new-component"
```

### Automated Testing Before Commits
```
# Run test suite
execute_command terminal="test" command="npm test"
read_output terminal="test"

# Only proceed if tests pass
execute_command terminal="main" command="git add . && git commit -m 'Feature complete'"
```

## Multi-Repository Coordination

### Cross-Repository Operations
```
# Update all repositories
open_terminal name="sync-repos"
execute_command terminal="sync-repos" command="cd ~/Code/Tuvens && for repo in */; do echo \"Updating $repo\"; cd \"$repo\" && git pull && cd ..; done"

# Check status across all repos
execute_command terminal="sync-repos" command="cd ~/Code/Tuvens && for repo in */; do echo \"=== $repo ===\"; cd \"$repo\" && git status --porcelain && cd ..; done"
```

### Environment Synchronization
```
# Start all development servers
open_terminal name="start-all"
execute_command terminal="start-all" command="cd ~/Code/Tuvens && ./scripts/start-dev-environment.sh"

# Stop all servers
execute_command terminal="start-all" command="pkill -f 'npm run dev' && pkill -f 'php artisan serve'"
```

## Output Monitoring and Validation

### Command Success Verification
```
# Execute command and verify success
execute_command terminal="build" command="npm run build"
read_output terminal="build"

# Check output for success indicators
# Look for: "Build completed successfully", exit code 0, etc.
```

### Error Detection and Recovery
```
# Monitor for errors
execute_command terminal="dev" command="npm run dev"
read_output terminal="dev"

# If errors detected, restart with clean state
close_terminal terminal="dev"
open_terminal name="dev-clean"
execute_command terminal="dev-clean" command="rm -rf node_modules && npm install && npm run dev"
```

## Best Practices

### Session Management
1. **Always use descriptive names** that include agent and purpose
2. **One terminal per distinct process** (dev server, tests, database, etc.)
3. **Clean up terminals** when tasks complete to avoid resource leaks
4. **Monitor output** after commands to verify success

### Security and Safety
1. **Validate commands** before execution, especially destructive operations
2. **Use working directories** to ensure commands run in correct context
3. **Read output** to detect errors and security warnings
4. **Timeout long operations** to prevent hung processes

### Performance Optimization
1. **Reuse terminals** for similar operations when appropriate
2. **Close unused terminals** to free system resources
3. **Use background processes** for long-running servers
4. **Monitor system resources** when running multiple development servers

## Troubleshooting

### Terminal Not Responding
```
# Check if terminal exists and is responsive
list_terminals

# If unresponsive, force close and recreate
close_terminal terminal="problematic-terminal"
open_terminal name="recovery-terminal"
```

### Command Execution Failures
```
# Read error output
read_output terminal="failed-terminal"

# Check current working directory
execute_command terminal="failed-terminal" command="pwd"

# Verify environment variables
execute_command terminal="failed-terminal" command="env | grep NODE"
```

### iTerm2 Integration Issues
1. **Ensure iTerm2 is running** before starting Claude Desktop
2. **Check automation permissions** in iTerm2 preferences
3. **Verify MCP server connection** in Claude Desktop console
4. **Restart Claude Desktop** if connection is lost

## Integration with Existing Workflows

### With `/start-session` Command
When using `/start-session [agent]`, the system can automatically:
1. Create appropriate terminal sessions for the agent
2. Navigate to correct repository directory
3. Start relevant development servers
4. Set up monitoring and logging

### With GitHub Issue Creation
Terminal automation enhances issue workflow:
1. **Automated testing** before issue resolution
2. **Environment setup** for issue reproduction
3. **Deployment verification** after fixes
4. **Clean environment cleanup** after issue closure

### With Branch Tracking System
Terminal operations are integrated with branch management:
1. **Automatic branch switching** when starting work
2. **Environment reloading** when switching contexts
3. **Test execution** before merge operations
4. **Cleanup scripts** when branches are merged

## Advanced Patterns

### Conditional Command Execution
```
# Run tests, only deploy if they pass
execute_command terminal="test" command="npm test"
read_output terminal="test"
# Parse output, if success then:
execute_command terminal="deploy" command="npm run deploy"
```

### Parallel Process Management
```
# Start multiple services simultaneously
open_terminal name="api-server"
open_terminal name="frontend-dev"
open_terminal name="database"

execute_command terminal="api-server" command="cd tuvens-api && npm run dev"
execute_command terminal="frontend-dev" command="cd tuvens-client && npm run dev"
execute_command terminal="database" command="docker-compose up postgres"
```

### Automated Health Checks
```
# Periodically check service health
execute_command terminal="health" command="curl -f http://localhost:3000/health"
read_output terminal="health"

# Restart services if health check fails
close_terminal terminal="api-server"
open_terminal name="api-server"
execute_command terminal="api-server" command="cd tuvens-api && npm run dev"
```

For detailed installation and setup, see:
- `agentic-development/scripts/setup-iterm-mcp.sh`
- `QUICK_START_ITERM.md`
- `ITERM_MCP_USAGE.md`
