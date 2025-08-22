#!/usr/bin/env node

/**
 * Confirmation Flow Handler for /start-session Pattern Recognition
 * 
 * This module handles user confirmation before triggering MCP automation,
 * providing clear information about what will be executed.
 */

class ConfirmationHandler {
    constructor() {
        this.initializeTemplates();
    }

    initializeTemplates() {
        // Confirmation message templates
        this.templates = {
            direct: `🎯 **Direct /start-session Command Recognized**

I'll set up a Claude Code session with:
• **Agent**: {agent}
• **Task**: {title}
• **Description**: {description}
• **Pattern**: {pattern_type} (confidence: {confidence}%)

Should I proceed? Type 'yes' to continue or 'no' to cancel.`,

            session: `🚀 **Session Start Request Detected**

I understood: "{user_input}"

I'll set up a Claude Code session with:
• **Agent**: {agent}
• **Task**: {title}
• **Description**: {description}
• **Pattern**: Natural language (confidence: {confidence}%)

Should I proceed? Type 'yes' to continue or 'no' to cancel.`,

            handoff: `🤝 **Agent Handoff Request Detected**

I understood: "{user_input}"

I'll hand this off to {agent}:
• **Agent**: {agent}
• **Task**: {title}
• **Description**: {description}
• **Pattern**: Traditional handoff (confidence: {confidence}%)

Should I proceed? Type 'yes' to continue or 'no' to cancel.`,

            claude_code: `💻 **Claude Code Request Detected**

I understood: "{user_input}"

I'll set up Claude Code with:
• **Agent**: {agent}
• **Task**: {title}
• **Description**: {description}
• **Pattern**: Claude Code specific (confidence: {confidence}%)

Should I proceed? Type 'yes' to continue or 'no' to cancel.`,

            context_extracted: `🔍 **Pattern + Context Extracted**

I understood: "{user_input}"

Based on our conversation, I'll set up:
• **Agent**: {agent}
• **Task**: {title}
• **Description**: {description}
• **Context Source**: {context_source}
• **Pattern**: {pattern_type} (confidence: {confidence}%)

{context_notes}

Should I proceed? Type 'yes' to continue or 'no' to cancel.`,

            fuzzy_match: `🎯 **Fuzzy Match Found**

I understood: "{user_input}"

Did you mean:
• **Agent**: {agent} (matched from "{matched_string}")
• **Task**: {title}
• **Description**: {description}
• **Match Method**: {match_method} (confidence: {confidence}%)

Should I proceed? Type 'yes' to continue or 'no' to cancel.`,

            clarification_needed: `❓ **Clarification Needed**

I recognized that you want to start a session, but I need clarification:

{clarification_reason}

Available agents:
{agent_list}

Please clarify your request or use the format:
\`/start-session [agent] "task title" "task description"\``,

            multiple_agents: `🤔 **Multiple Agents Could Handle This**

I understood: "{user_input}"

Multiple agents could handle this task:
{agent_options}

Which agent would you prefer? Reply with the agent name or number.`
        };

        // Error message templates
        this.errorTemplates = {
            no_pattern: `❌ **No Pattern Recognized**

I couldn't recognize a /start-session pattern in: "{user_input}"

Try one of these formats:
• \`/start-session [agent] "task title" "description"\`
• "start session with [agent] for [task]"
• "get [agent] to work on [task]"

Available agents: {agent_list}`,

            invalid_agent: `❌ **Agent Not Found**

I couldn't find an agent matching "{agent_input}".

Available agents:
{agent_suggestions}

Did you mean one of these?`,

            low_confidence: `⚠️ **Low Confidence Match**

I think you want to start a session, but I'm not confident about:
{uncertainty_details}

Please be more specific or use the explicit format:
\`/start-session [agent] "task title" "description"\``
        };
    }

    /**
     * Generate confirmation message based on pattern recognition result
     * @param {Object} recognitionResult - Result from pattern matcher
     * @param {Object} context - Additional context from conversation
     * @param {string} userInput - Original user input
     * @returns {Object} - Confirmation message and metadata
     */
    generateConfirmation(recognitionResult, context = null, userInput = '') {
        if (!recognitionResult || !recognitionResult.agent) {
            return this.generateErrorMessage(recognitionResult, userInput);
        }

        const { type, confidence, agent, title, description, needsContext } = recognitionResult;
        
        // Determine template based on pattern type and context availability
        let templateKey = type;
        if (needsContext && context) {
            templateKey = 'context_extracted';
        } else if (recognitionResult.method === 'fuzzy_match') {
            templateKey = 'fuzzy_match';
        }

        const template = this.templates[templateKey] || this.templates.direct;
        
        // Prepare template variables
        const variables = {
            user_input: userInput,
            agent: agent,
            title: title || 'Task from conversation',
            description: description || 'Please specify task details',
            pattern_type: this.getPatternTypeLabel(type),
            confidence: Math.round(confidence * 100),
            context_source: context?.source || 'conversation',
            context_notes: this.formatContextNotes(context),
            match_method: recognitionResult.method || type,
            matched_string: recognitionResult.matchedString || agent
        };

        const message = this.interpolateTemplate(template, variables);
        
        return {
            type: 'confirmation',
            message,
            data: {
                agent,
                title: variables.title,
                description: variables.description,
                confidence,
                pattern_type: type,
                user_input: userInput,
                context
            },
            actions: ['yes', 'no', 'modify']
        };
    }

    /**
     * Generate error messages for failed pattern recognition
     * @param {Object} recognitionResult - Failed recognition result
     * @param {string} userInput - Original user input
     * @returns {Object} - Error message and suggestions
     */
    generateErrorMessage(recognitionResult, userInput) {
        if (!recognitionResult) {
            return {
                type: 'error',
                subtype: 'no_pattern',
                message: this.interpolateTemplate(this.errorTemplates.no_pattern, {
                    user_input: userInput,
                    agent_list: this.getAgentList()
                }),
                suggestions: this.getPatternSuggestions(),
                actions: ['retry', 'help']
            };
        }

        if (recognitionResult.confidence < 0.5) {
            return {
                type: 'error',
                subtype: 'low_confidence',
                message: this.interpolateTemplate(this.errorTemplates.low_confidence, {
                    uncertainty_details: this.getUncertaintyDetails(recognitionResult)
                }),
                suggestions: this.getPatternSuggestions(),
                actions: ['retry', 'help']
            };
        }

        if (recognitionResult.suggestions) {
            return {
                type: 'error',
                subtype: 'invalid_agent',
                message: this.interpolateTemplate(this.errorTemplates.invalid_agent, {
                    agent_input: recognitionResult.input,
                    agent_suggestions: this.formatAgentSuggestions(recognitionResult.suggestions)
                }),
                suggestions: recognitionResult.suggestions,
                actions: ['retry', 'help']
            };
        }

        return {
            type: 'error',
            subtype: 'unknown',
            message: `❌ Unable to process your request: "${userInput}"\n\nPlease try again with a clearer pattern.`,
            actions: ['retry', 'help']
        };
    }

    /**
     * Generate clarification request when multiple interpretations are possible
     * @param {Array} options - Array of possible interpretations
     * @param {string} userInput - Original user input
     * @returns {Object} - Clarification message
     */
    generateClarification(options, userInput) {
        if (options.length === 0) {
            return this.generateErrorMessage(null, userInput);
        }

        if (options.some(opt => !opt.agent)) {
            return {
                type: 'clarification',
                subtype: 'agent_needed',
                message: this.interpolateTemplate(this.templates.clarification_needed, {
                    clarification_reason: 'I need to know which agent should handle this task.',
                    agent_list: this.getAgentList()
                }),
                options,
                actions: ['specify_agent', 'cancel']
            };
        }

        if (options.length > 1) {
            return {
                type: 'clarification',
                subtype: 'multiple_agents',
                message: this.interpolateTemplate(this.templates.multiple_agents, {
                    user_input: userInput,
                    agent_options: this.formatAgentOptions(options)
                }),
                options,
                actions: ['select_agent', 'cancel']
            };
        }

        // Single option - proceed with confirmation
        return this.generateConfirmation(options[0], null, userInput);
    }

    /**
     * Handle user response to confirmation
     * @param {string} response - User's response (yes/no/modify)
     * @param {Object} confirmationData - Original confirmation data
     * @returns {Object} - Next action to take
     */
    handleResponse(response, confirmationData) {
        const normalizedResponse = response.toLowerCase().trim();
        
        if (['yes', 'y', 'proceed', 'go', 'continue'].includes(normalizedResponse)) {
            return {
                action: 'execute',
                command: this.generateStandardCommand(confirmationData),
                data: confirmationData
            };
        }
        
        if (['no', 'n', 'cancel', 'abort', 'stop'].includes(normalizedResponse)) {
            return {
                action: 'cancel',
                message: '❌ Session creation cancelled.'
            };
        }
        
        if (['modify', 'edit', 'change', 'update'].includes(normalizedResponse)) {
            return {
                action: 'modify',
                message: '✏️ What would you like to modify? You can specify:\n• Agent\n• Task title\n• Task description',
                data: confirmationData
            };
        }
        
        return {
            action: 'clarify',
            message: '❓ Please respond with "yes" to proceed, "no" to cancel, or "modify" to make changes.'
        };
    }

    // Helper methods
    interpolateTemplate(template, variables) {
        let result = template;
        for (const [key, value] of Object.entries(variables)) {
            const placeholder = new RegExp(`\\{${key}\\}`, 'g');
            result = result.replace(placeholder, value || '');
        }
        return result;
    }

    getPatternTypeLabel(type) {
        const labels = {
            direct: 'Direct command',
            session: 'Natural language session',
            handoff: 'Agent handoff',
            claude_code: 'Claude Code specific',
            fuzzy: 'Fuzzy match'
        };
        return labels[type] || type;
    }

    formatContextNotes(context) {
        if (!context || !context.contextNotes) return '';
        
        return '\n**Context Notes**:\n' + 
               context.contextNotes.map(note => `• ${note}`).join('\n');
    }

    getAgentList() {
        return 'vibe-coder, react-dev, laravel-dev, svelte-dev, node-dev, devops';
    }

    formatAgentSuggestions(suggestions) {
        return suggestions
            .map((s, i) => `${i + 1}. **${s.canonical}** (shortcuts: ${s.shortcuts.join(', ')})`)
            .join('\n');
    }

    formatAgentOptions(options) {
        return options
            .map((opt, i) => `${i + 1}. **${opt.agent}** - ${opt.title}`)
            .join('\n');
    }

    getPatternSuggestions() {
        return [
            'Direct: `/start-session vibe-coder "Fix docs" "Update API reference"`',
            'Casual: `/start-session react-dev fix mobile menu`',
            'Natural: "start session with devops for deployment"',
            'Handoff: "get laravel-dev to work on the API"'
        ];
    }

    getUncertaintyDetails(result) {
        const details = [];
        if (result.confidence < 0.3) details.push('Very low pattern confidence');
        if (!result.agent) details.push('Agent could not be determined');
        if (!result.title && !result.description) details.push('Task details are unclear');
        return details.join('\n• ');
    }

    generateStandardCommand(data) {
        return `/start-session ${data.agent} "${data.title}" "${data.description}"`;
    }
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ConfirmationHandler;
}

// CLI usage
if (require.main === module) {
    const handler = new ConfirmationHandler();
    
    // Example usage
    const sampleResult = {
        type: 'session',
        confidence: 0.85,
        agent: 'react-dev',
        title: 'Fix mobile menu',
        description: 'Mobile menu not closing on iOS devices',
        needsContext: false
    };
    
    const sampleContext = {
        source: 'conversation',
        contextNotes: ['Referenced in previous discussion', 'High priority issue']
    };
    
    console.log('🔍 Confirmation Example:');
    const confirmation = handler.generateConfirmation(
        sampleResult, 
        sampleContext, 
        'start session with react dev to fix mobile menu'
    );
    
    console.log(confirmation.message);
    console.log('\n📋 Response handling:');
    
    const yesResponse = handler.handleResponse('yes', confirmation.data);
    console.log('User says "yes":', yesResponse);
    
    const noResponse = handler.handleResponse('no', confirmation.data);
    console.log('User says "no":', noResponse);
}