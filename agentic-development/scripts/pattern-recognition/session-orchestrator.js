#!/usr/bin/env node

/**
 * Session Orchestrator - Main Integration Point
 * 
 * This module orchestrates the entire pattern recognition flow and integrates
 * with the existing MCP automation system.
 */

const PatternMatcher = require('./pattern-matcher');
const AgentResolver = require('./agent-resolver');
const ContextExtractor = require('./context-extractor');
const ConfirmationHandler = require('./confirmation-handler');
const { spawn } = require('child_process');
const path = require('path');

class SessionOrchestrator {
    constructor(options = {}) {
        this.options = {
            autoConfirm: false,
            confidenceThreshold: 0.6,
            enableFuzzyMatching: true,
            enableContextExtraction: true,
            maxConversationHistory: 10,
            ...options
        };

        this.patternMatcher = new PatternMatcher();
        this.agentResolver = new AgentResolver();
        this.contextExtractor = new ContextExtractor();
        this.confirmationHandler = new ConfirmationHandler();
        
        this.state = {
            lastRecognition: null,
            pendingConfirmation: null,
            conversationHistory: []
        };
    }

    /**
     * Main entry point for processing user input
     * @param {string} userInput - User's message
     * @param {Array} conversationContext - Recent conversation messages
     * @returns {Object} - Processing result with action to take
     */
    async processInput(userInput, conversationContext = []) {
        try {
            // Update conversation history
            this.updateConversationHistory(userInput, conversationContext);

            // Step 1: Pattern Recognition
            const recognitionResult = this.recognizePattern(userInput);
            
            if (!recognitionResult) {
                return this.handleNoPattern(userInput);
            }

            // Step 2: Agent Resolution (if needed)
            const resolvedResult = await this.resolveAgent(recognitionResult, userInput);
            
            if (!resolvedResult.agent) {
                return this.handleAgentResolutionFailure(resolvedResult, userInput);
            }

            // Step 3: Context Extraction (if needed)
            const enrichedResult = await this.extractContext(resolvedResult, conversationContext);

            // Step 4: Confidence Check
            if (enrichedResult.confidence < this.options.confidenceThreshold) {
                return this.handleLowConfidence(enrichedResult, userInput);
            }

            // Step 5: Generate Confirmation
            const confirmation = this.generateConfirmation(enrichedResult, userInput);
            
            // Step 6: Auto-execute or request confirmation
            if (this.options.autoConfirm && enrichedResult.confidence > 0.9) {
                return this.executeSession(enrichedResult);
            }

            return confirmation;

        } catch (error) {
            return this.handleError(error, userInput);
        }
    }

    /**
     * Handle user response to confirmation
     * @param {string} response - User's response
     * @returns {Object} - Next action result
     */
    async handleConfirmationResponse(response) {
        if (!this.state.pendingConfirmation) {
            return {
                type: 'error',
                message: '❌ No pending confirmation found.'
            };
        }

        const handlingResult = this.confirmationHandler.handleResponse(
            response, 
            this.state.pendingConfirmation.data
        );

        switch (handlingResult.action) {
            case 'execute':
                this.state.pendingConfirmation = null;
                return this.executeSession(handlingResult.data);
                
            case 'cancel':
                this.state.pendingConfirmation = null;
                return {
                    type: 'cancelled',
                    message: handlingResult.message
                };
                
            case 'modify':
                return {
                    type: 'modification_request',
                    message: handlingResult.message,
                    data: handlingResult.data
                };
                
            default:
                return {
                    type: 'clarification',
                    message: handlingResult.message
                };
        }
    }

    /**
     * Execute the session creation with MCP automation
     * @param {Object} sessionData - Session configuration data
     * @returns {Object} - Execution result
     */
    async executeSession(sessionData) {
        try {
            const { agent, title, description } = sessionData;
            
            // Generate the standard /start-session command
            const command = `/start-session ${agent} "${title}" "${description}"`;
            
            // Execute the existing automation
            const result = await this.triggerMCPAutomation(agent, title, description);
            
            return {
                type: 'session_started',
                message: `✅ **Session Started Successfully**

**Agent**: ${agent}
**Task**: ${title}
**Description**: ${description}

${result.details || 'MCP automation triggered successfully.'}`,
                command,
                result
            };

        } catch (error) {
            return {
                type: 'execution_error',
                message: `❌ **Failed to Start Session**

Error: ${error.message}

You can try manually with:
\`/start-session ${sessionData.agent} "${sessionData.title}" "${sessionData.description}"\``,
                error
            };
        }
    }

    // Internal processing methods

    recognizePattern(userInput) {
        const result = this.patternMatcher.recognizePattern(
            userInput, 
            this.state.conversationHistory
        );
        
        this.state.lastRecognition = result;
        return result;
    }

    async resolveAgent(recognitionResult, userInput) {
        if (!recognitionResult.agent) {
            return recognitionResult;
        }

        // Use the agent resolver for fuzzy matching
        const resolution = this.agentResolver.resolveAgent(recognitionResult.agent);
        
        if (resolution.agent) {
            return {
                ...recognitionResult,
                agent: resolution.agent,
                agentResolution: resolution,
                confidence: Math.min(recognitionResult.confidence, resolution.confidence)
            };
        }

        return {
            ...recognitionResult,
            agent: null,
            agentResolution: resolution
        };
    }

    async extractContext(recognitionResult, conversationContext) {
        if (!recognitionResult.needsContext || !this.options.enableContextExtraction) {
            return recognitionResult;
        }

        const context = this.contextExtractor.extractContext(conversationContext, {
            lookbackLimit: this.options.maxConversationHistory
        });

        return {
            ...recognitionResult,
            title: recognitionResult.title || context.title,
            description: recognitionResult.description || context.description,
            extractedContext: context,
            confidence: Math.min(recognitionResult.confidence, context.confidence || 0.7)
        };
    }

    generateConfirmation(enrichedResult, userInput) {
        const confirmation = this.confirmationHandler.generateConfirmation(
            enrichedResult,
            enrichedResult.extractedContext,
            userInput
        );

        this.state.pendingConfirmation = confirmation;
        return confirmation;
    }

    /**
     * Trigger the existing MCP automation system
     * @param {string} agent - Agent name
     * @param {string} title - Task title
     * @param {string} description - Task description
     * @returns {Promise<Object>} - Automation result
     */
    async triggerMCPAutomation(agent, title, description) {
        return new Promise((resolve, reject) => {
            // Path to the existing automation script
            const automationScript = path.join(__dirname, '..', 'setup-agent-task-desktop.sh');
            
            // Execute the automation script
            const child = spawn('bash', [automationScript, agent, title, description], {
                stdio: ['pipe', 'pipe', 'pipe'],
                env: { ...process.env }
            });

            let stdout = '';
            let stderr = '';

            child.stdout.on('data', (data) => {
                stdout += data.toString();
            });

            child.stderr.on('data', (data) => {
                stderr += data.toString();
            });

            child.on('close', (code) => {
                if (code === 0) {
                    resolve({
                        success: true,
                        details: this.parseAutomationOutput(stdout),
                        output: stdout
                    });
                } else {
                    reject(new Error(`Automation failed with code ${code}: ${stderr}`));
                }
            });

            child.on('error', (error) => {
                reject(error);
            });
        });
    }

    parseAutomationOutput(output) {
        // Parse the automation script output to extract useful information
        const lines = output.split('\n');
        const details = [];

        for (const line of lines) {
            if (line.includes('GitHub issue created:')) {
                const issueMatch = line.match(/#(\d+)/);
                if (issueMatch) {
                    details.push(`📋 GitHub issue created: #${issueMatch[1]}`);
                }
            }
            if (line.includes('Worktree created:') || line.includes('Branch:')) {
                details.push(`🔧 ${line.trim()}`);
            }
            if (line.includes('Claude Code ready')) {
                details.push(`💻 Claude Code session ready`);
            }
        }

        return details.length > 0 ? details.join('\n') : 'Session setup completed';
    }

    // Error and edge case handlers

    handleNoPattern(userInput) {
        return {
            type: 'no_pattern',
            message: `❌ I couldn't recognize a /start-session pattern in your message.

Try one of these formats:
• \`/start-session [agent] "task title" "description"\`
• "start session with [agent] for [task]"
• "get [agent] to work on [task]"

Available agents: ${this.agentResolver.getAllAgents() ? Object.keys(this.agentResolver.getAllAgents()).join(', ') : 'vibe-coder, react-dev, laravel-dev, svelte-dev, node-dev, devops'}`,
            input: userInput
        };
    }

    handleAgentResolutionFailure(result, userInput) {
        const suggestions = result.agentResolution?.suggestions || [];
        
        return {
            type: 'agent_not_found',
            message: `❌ I couldn't find an agent matching "${result.agent}".

Available agents:
${suggestions.map((s, i) => `${i + 1}. **${s.canonical}** (try: ${s.shortcuts.join(', ')})`).join('\n')}

Please specify which agent you want to use.`,
            suggestions,
            input: userInput
        };
    }

    handleLowConfidence(result, userInput) {
        return {
            type: 'low_confidence',
            message: `⚠️ I think you want to start a session, but I'm not confident about the details.

What I understood:
• Agent: ${result.agent || 'unclear'}
• Task: ${result.title || 'unclear'}
• Confidence: ${Math.round(result.confidence * 100)}%

Please be more specific or use the explicit format:
\`/start-session [agent] "task title" "description"\``,
            result,
            input: userInput
        };
    }

    handleError(error, userInput) {
        console.error('Session orchestrator error:', error);
        
        return {
            type: 'system_error',
            message: `❌ **System Error**

An error occurred while processing your request: "${userInput}"

Error: ${error.message}

Please try again or use the manual format:
\`/start-session [agent] "task title" "description"\``,
            error: error.message
        };
    }

    updateConversationHistory(userInput, conversationContext) {
        // Add current input to history
        this.state.conversationHistory.unshift({
            role: 'user',
            content: userInput,
            timestamp: new Date()
        });

        // Merge with provided context
        if (conversationContext && conversationContext.length > 0) {
            this.state.conversationHistory = [
                ...this.state.conversationHistory.slice(0, 1), // Keep current input
                ...conversationContext.slice(0, this.options.maxConversationHistory - 1)
            ];
        }

        // Trim to max length
        this.state.conversationHistory = this.state.conversationHistory
            .slice(0, this.options.maxConversationHistory);
    }

    // Utility methods

    getState() {
        return { ...this.state };
    }

    reset() {
        this.state = {
            lastRecognition: null,
            pendingConfirmation: null,
            conversationHistory: []
        };
    }

    updateOptions(newOptions) {
        this.options = { ...this.options, ...newOptions };
    }
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = SessionOrchestrator;
}

// CLI usage
if (require.main === module) {
    const orchestrator = new SessionOrchestrator({
        autoConfirm: false,
        confidenceThreshold: 0.6
    });

    const userInput = process.argv[2];
    
    if (!userInput) {
        console.log('Usage: node session-orchestrator.js "your input"');
        console.log('\nExample inputs:');
        console.log('  "start session with react-dev to fix mobile menu"');
        console.log('  "/start-session vibe-coder fix the docs"');
        console.log('  "get devops to handle deployment"');
        process.exit(1);
    }

    // Sample conversation context
    const sampleContext = [
        { role: 'user', content: 'The mobile menu is broken on iOS' },
        { role: 'user', content: 'Users cant close it after opening' }
    ];

    console.log('🎯 Processing Input:', userInput);
    console.log('📝 With Context:', sampleContext.map(m => m.content).join(' | '));
    
    orchestrator.processInput(userInput, sampleContext)
        .then(result => {
            console.log('\n✅ Result:');
            console.log(JSON.stringify(result, null, 2));
            
            if (result.type === 'confirmation') {
                console.log('\n📋 Confirmation Message:');
                console.log(result.message);
            }
        })
        .catch(error => {
            console.error('❌ Error:', error);
        });
}