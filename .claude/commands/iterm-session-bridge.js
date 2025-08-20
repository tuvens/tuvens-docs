// iTerm MCP Bridge for /start-session Integration
// Issue #203: Simple MCP bridge that connects Claude Desktop → iTerm MCP → Claude Code
// 
// Purpose: Enhance existing /start-session command with iTerm automation
// Usage: Called automatically when /start-session is used
// Integration: Works with user's existing iTerm MCP configuration

async function enhanceStartSession(agentName, taskDescription) {
  // Agent directory mappings (matches PR #204 specifications exactly)
  const agentDirs = {
    'vibe-coder': '/Users/ciarancarroll/Code/Tuvens/tuvens-docs',
    'devops': '/Users/ciarancarroll/Code/Tuvens/tuvens-docs',
    'react-dev': '/Users/ciarancarroll/Code/Tuvens/hi.events',
    'laravel-dev': '/Users/ciarancarroll/Code/Tuvens/hi.events',
    'node-dev': '/Users/ciarancarroll/Code/Tuvens/tuvens-api',
    'svelte-dev': '/Users/ciarancarroll/Code/Tuvens/tuvens-client'
  };

  // Use user's configured iTerm MCP server
  const session = await iterm.open_terminal({
    name: `${agentName}-session`,
    directory: agentDirs[agentName]
  });

  // Start Claude Code in the iTerm session (real command, no fabricated flags)
  await iterm.execute_command({
    sessionId: session.id,
    command: 'claude'
  });
  
  return session;
}

// Export for use by /start-session command
module.exports = { enhanceStartSession };