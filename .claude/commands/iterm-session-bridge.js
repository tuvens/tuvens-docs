// iTerm MCP Bridge for setup-agent-task.sh Integration
// Issue #203: MCP bridge called by setup-agent-task.sh script
// 
// Purpose: Replace AppleScript iTerm automation with MCP integration
// Usage: Called by setup-agent-task.sh with proper error handling
// Integration: Works with user's existing iTerm MCP configuration

async function enhanceStartSession(agentName, worktreePath, promptFile) {
  try {
    // Input validation
    if (!agentName || !worktreePath || !promptFile) {
      throw new Error('Missing required parameters: agentName, worktreePath, promptFile');
    }

    // Validate that the iTerm MCP is available
    if (typeof iterm === 'undefined') {
      throw new Error('iTerm MCP server not available - ensure it is configured in Claude Desktop');
    }

    // Use user's configured iTerm MCP server
    const session = await iterm.open_terminal({
      name: `${agentName}-agent-session`,
      directory: worktreePath
    });

    // Display the agent prompt file
    await iterm.execute_command({
      sessionId: session.id,
      command: `cat "${promptFile}"`
    });

    // Start Claude Code in the iTerm session (real command, no fabricated flags)
    await iterm.execute_command({
      sessionId: session.id,
      command: 'claude'
    });
    
    return session;
  } catch (error) {
    console.error('iTerm MCP Bridge Error:', error.message);
    throw error;
  }
}

// Export for use by setup-agent-task.sh
module.exports = { enhanceStartSession };