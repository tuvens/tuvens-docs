#!/usr/bin/env node

/**
 * Flexible /start-session Pattern Recognition Engine
 * 
 * This module implements the actual pattern matching logic for Claude Desktop
 * to recognize flexible /start-session commands and natural language variations.
 */

class StartSessionPatternMatcher {
    constructor() {
        this.agents = {
            // Canonical agent names with variations
            'vibe-coder': ['vibe-coder', 'vibe coder', 'vibecoder', 'vibe', 'system architect', 'documentation expert', 'docs expert'],
            'react-dev': ['react-dev', 'react dev', 'react developer', 'react', 'frontend dev', 'ui developer', 'frontend developer'],
            'laravel-dev': ['laravel-dev', 'laravel dev', 'laravel developer', 'laravel', 'backend dev', 'api developer', 'backend developer'],
            'svelte-dev': ['svelte-dev', 'svelte dev', 'svelte developer', 'svelte', 'frontend', 'ui dev'],
            'node-dev': ['node-dev', 'node dev', 'node developer', 'node', 'nodejs', 'backend', 'api dev'],
            'devops': ['devops', 'dev ops', 'infrastructure', 'deployment', 'ci/cd', 'ops', 'infrastructure engineer']
        };

        this.initializePatterns();
    }

    initializePatterns() {
        // Direct /start-session patterns
        this.directPatterns = [
            // Exact format: /start-session agent "title" "description"
            /^\/start-session\s+(\S+)\s+"([^"]+)"\s+"([^"]+)"$/i,
            // Casual format: /start-session agent description...
            /^\/start-session\s+(\S+)\s+(.+)$/i,
            // Agent only: /start-session agent
            /^\/start-session\s+(\S+)$/i
        ];

        // Natural language session patterns
        this.sessionPatterns = [
            /(?:start\s+session\s+with|begin\s+session\s+with|start\s+working\s+with)\s+([^\s,]+)(?:\s+(?:for|on)\s+(.+))?/i,
            /(?:begin|start|initiate)\s+([^\s,]+)\s+session(?:\s+(?:for|on)\s+(.+))?/i,
            /(?:get|have)\s+([^\s,]+)\s+started(?:\s+on\s+(.+))?/i,
            /(?:kick\s+off|fire\s+up)\s+([^\s,]+)(?:\s+(?:for|session)\s+(.+))?/i
        ];

        // Traditional handoff patterns
        this.handoffPatterns = [
            /(?:get|have|ask|let)\s+([^\s,]+)\s+(?:to\s+)?(?:work\s+on|handle|do|take\s+care\s+of)\s+(.+)/i,
            /(?:give|assign|hand\s+off|transfer)\s+(?:this\s+to|to)\s+([^\s,]+)(?:\s+(.+))?/i,
            /([^\s,]+)\s+should\s+(?:handle|work\s+on|take\s+care\s+of)\s+(.+)/i
        ];

        // Claude Code specific patterns
        this.claudeCodePatterns = [
            /(?:use|set\s+up|launch|open|start)\s+claude\s+code\s+with\s+([^\s,]+)(?:\s+(?:for|on)\s+(.+))?/i,
            /get\s+claude\s+code\s+working\s+(?:on\s+)?(?:this\s+)?(?:with\s+)?([^\s,]+)(?:\s+(.+))?/i
        ];
    }

    /**
     * Main pattern recognition method
     * @param {string} input - User input text
     * @param {Array} conversationContext - Recent conversation messages for context
     * @returns {Object|null} - Parsed pattern or null if no match
     */
    recognizePattern(input, conversationContext = []) {
        const cleanInput = input.trim();
        
        // Try direct /start-session patterns first
        const directMatch = this.matchDirectPatterns(cleanInput);
        if (directMatch) return directMatch;

        // Try natural language session patterns
        const sessionMatch = this.matchSessionPatterns(cleanInput);
        if (sessionMatch) return sessionMatch;

        // Try traditional handoff patterns
        const handoffMatch = this.matchHandoffPatterns(cleanInput);
        if (handoffMatch) return handoffMatch;

        // Try Claude Code specific patterns
        const claudeCodeMatch = this.matchClaudeCodePatterns(cleanInput);
        if (claudeCodeMatch) return claudeCodeMatch;

        return null;
    }

    matchDirectPatterns(input) {
        for (const pattern of this.directPatterns) {
            const match = input.match(pattern);
            if (match) {
                const [, agentInput, title, description] = match;
                const agent = this.resolveAgentName(agentInput);
                
                if (agent) {
                    return {
                        type: 'direct',
                        confidence: 0.95,
                        agent: agent,
                        title: title || (match[2] || '').trim(),
                        description: description || (match[2] || '').trim(),
                        needsContext: !title && !description
                    };
                }
            }
        }
        return null;
    }

    matchSessionPatterns(input) {
        for (const pattern of this.sessionPatterns) {
            const match = input.match(pattern);
            if (match) {
                const [, agentInput, task] = match;
                const agent = this.resolveAgentName(agentInput);
                
                if (agent) {
                    return {
                        type: 'session',
                        confidence: 0.85,
                        agent: agent,
                        title: task || 'Session Task',
                        description: task || '',
                        needsContext: !task
                    };
                }
            }
        }
        return null;
    }

    matchHandoffPatterns(input) {
        for (const pattern of this.handoffPatterns) {
            const match = input.match(pattern);
            if (match) {
                const [, agentInput, task] = match;
                const agent = this.resolveAgentName(agentInput);
                
                if (agent) {
                    return {
                        type: 'handoff',
                        confidence: 0.80,
                        agent: agent,
                        title: task || 'Handoff Task',
                        description: task || '',
                        needsContext: !task
                    };
                }
            }
        }
        return null;
    }

    matchClaudeCodePatterns(input) {
        for (const pattern of this.claudeCodePatterns) {
            const match = input.match(pattern);
            if (match) {
                const [, agentInput, task] = match;
                const agent = this.resolveAgentName(agentInput);
                
                if (agent) {
                    return {
                        type: 'claude-code',
                        confidence: 0.90,
                        agent: agent,
                        title: task || 'Claude Code Task',
                        description: task || '',
                        needsContext: !task
                    };
                }
            }
        }
        return null;
    }

    /**
     * Resolve fuzzy agent names to canonical names
     * @param {string} input - Agent name input (possibly fuzzy)
     * @returns {string|null} - Canonical agent name or null
     */
    resolveAgentName(input) {
        const cleanInput = input.toLowerCase().trim();
        
        // Check exact matches first
        for (const [canonical, variations] of Object.entries(this.agents)) {
            if (variations.includes(cleanInput)) {
                return canonical;
            }
        }

        // Check partial matches
        for (const [canonical, variations] of Object.entries(this.agents)) {
            for (const variation of variations) {
                if (variation.includes(cleanInput) || cleanInput.includes(variation)) {
                    return canonical;
                }
            }
        }

        return null;
    }

    /**
     * Extract context from conversation when task description is missing
     * @param {Array} conversationContext - Recent messages
     * @param {number} lookbackLimit - How many messages to examine
     * @returns {Object} - Extracted context
     */
    extractContext(conversationContext, lookbackLimit = 5) {
        const recentMessages = conversationContext.slice(-lookbackLimit);
        
        // Look for task indicators in recent messages
        const taskIndicators = [
            /(?:fix|bug|issue|problem|error)\s+(.+)/i,
            /(?:implement|add|create|build)\s+(.+)/i,
            /(?:update|modify|change|refactor)\s+(.+)/i,
            /(?:deploy|setup|configure)\s+(.+)/i,
            /(?:document|write|explain)\s+(.+)/i
        ];

        for (const message of recentMessages.reverse()) {
            for (const pattern of taskIndicators) {
                const match = message.match(pattern);
                if (match) {
                    return {
                        title: match[1].trim(),
                        description: match[1].trim(),
                        source: 'conversation'
                    };
                }
            }
        }

        return {
            title: 'Task from conversation',
            description: 'Please specify the task details',
            source: 'none'
        };
    }

    /**
     * Generate confirmation message for user
     * @param {Object} parsedPattern - Result from recognizePattern
     * @param {Object} context - Additional context if needed
     * @returns {string} - Confirmation message
     */
    generateConfirmation(parsedPattern, context = null) {
        const { agent, title, description, type, confidence } = parsedPattern;
        
        const contextInfo = context ? ` (extracted from ${context.source})` : '';
        
        return `I understand you want ${agent} to work on: "${title}"

Should I set up a Claude Code session with:
• Agent: ${agent}
• Task: ${title}
• Description: ${description}${contextInfo}
• Pattern Type: ${type} (confidence: ${Math.round(confidence * 100)}%)

Type 'yes' to proceed or 'no' to cancel.`;
    }

    /**
     * Convert parsed pattern to standard /start-session format
     * @param {Object} parsedPattern - Result from recognizePattern
     * @returns {string} - Standard /start-session command
     */
    toStandardFormat(parsedPattern) {
        const { agent, title, description } = parsedPattern;
        return `/start-session ${agent} "${title}" "${description}"`;
    }
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = StartSessionPatternMatcher;
}

// CLI usage
if (require.main === module) {
    const matcher = new StartSessionPatternMatcher();
    const input = process.argv[2];
    
    if (!input) {
        console.log('Usage: node pattern-matcher.js "your input text"');
        process.exit(1);
    }
    
    const result = matcher.recognizePattern(input);
    if (result) {
        console.log('✅ Pattern recognized:');
        console.log(JSON.stringify(result, null, 2));
        console.log('\n📋 Confirmation:');
        console.log(matcher.generateConfirmation(result));
        console.log('\n🔧 Standard format:');
        console.log(matcher.toStandardFormat(result));
    } else {
        console.log('❌ No pattern recognized');
    }
}