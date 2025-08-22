#!/usr/bin/env node

/**
 * Context Extraction Engine for /start-session Pattern Recognition
 * 
 * This module extracts task context from conversation history when patterns
 * don't explicitly include task descriptions.
 */

class ContextExtractor {
    constructor() {
        this.initializePatterns();
    }

    initializePatterns() {
        // Task description patterns
        this.taskPatterns = {
            bugs: [
                /(?:bug|issue|problem|error|broken|failing|not working)\s+(?:with|in|on)?\s*(.+)/i,
                /(.+)\s+(?:is|isn't|doesn't|won't|can't)\s+(?:working|functioning|loading|responding)/i,
                /(?:fix|resolve|debug)\s+(.+)/i
            ],
            features: [
                /(?:implement|add|create|build|develop)\s+(.+)/i,
                /(?:need|want|should)\s+(?:to\s+)?(?:add|create|implement|build)\s+(.+)/i,
                /(?:feature|functionality)\s+(?:for|to)\s+(.+)/i
            ],
            improvements: [
                /(?:improve|enhance|optimize|refactor|update)\s+(.+)/i,
                /(?:make|let's make)\s+(.+)\s+(?:better|faster|more|less)/i,
                /(?:upgrade|modernize)\s+(.+)/i
            ],
            documentation: [
                /(?:document|write|explain|describe)\s+(.+)/i,
                /(?:docs|documentation)\s+(?:for|about|on)\s+(.+)/i,
                /(?:readme|guide|tutorial)\s+(?:for|about)\s+(.+)/i
            ],
            deployment: [
                /(?:deploy|setup|configure|install)\s+(.+)/i,
                /(?:ci\/cd|pipeline|infrastructure)\s+(?:for|on)\s+(.+)/i,
                /(?:production|staging|environment)\s+(.+)/i
            ],
            ui: [
                /(?:ui|interface|design|styling|layout)\s+(?:for|of|on)\s+(.+)/i,
                /(?:component|page|view|screen)\s+(.+)/i,
                /(?:mobile|responsive|desktop)\s+(.+)/i
            ],
            api: [
                /(?:api|endpoint|route|service)\s+(?:for|to|on)\s+(.+)/i,
                /(?:backend|server|database)\s+(.+)/i,
                /(?:integration|webhook)\s+(?:with|for)\s+(.+)/i
            ]
        };

        // Reference resolution patterns
        this.referencePatterns = [
            /(?:this|that|the)\s+(.+)/i,
            /(?:it|these|those)\s+(.+)/i,
            /(?:above|previous|earlier)\s+(.+)/i
        ];

        // File/component mention patterns
        this.entityPatterns = [
            /(?:file|component|module|class|function)\s+(?:called|named)?\s*(.+)/i,
            /(?:in|from|on)\s+([\w\-\.\/]+\.(?:js|ts|jsx|tsx|py|php|md|json|yml|yaml))/i,
            /(?:the|this)\s+([\w\-]+(?:\s+[\w\-]+)*)\s+(?:component|module|file|class)/i
        ];

        // Priority indicators
        this.priorityIndicators = {
            urgent: ['urgent', 'asap', 'immediately', 'critical', 'emergency'],
            high: ['important', 'priority', 'needed', 'required'],
            medium: ['should', 'would be good', 'nice to have'],
            low: ['eventually', 'when possible', 'later']
        };
    }

    /**
     * Extract context from conversation messages
     * @param {Array} messages - Array of conversation messages
     * @param {Object} options - Extraction options
     * @returns {Object} - Extracted context
     */
    extractContext(messages, options = {}) {
        const {
            lookbackLimit = 10,
            includeUserMessages = true,
            includeAssistantMessages = false,
            requireTaskIndicators = false
        } = options;

        // Filter and prepare messages
        const relevantMessages = this.prepareMessages(messages, {
            lookbackLimit,
            includeUserMessages,
            includeAssistantMessages
        });

        if (relevantMessages.length === 0) {
            return this.createEmptyContext();
        }

        // Extract task information
        const taskInfo = this.extractTaskInformation(relevantMessages);
        
        // Extract entities (files, components, etc.)
        const entities = this.extractEntities(relevantMessages);
        
        // Resolve references
        const resolvedReferences = this.resolveReferences(relevantMessages);
        
        // Determine priority
        const priority = this.determinePriority(relevantMessages);
        
        // Combine all extracted information
        return this.combineContext({
            taskInfo,
            entities,
            resolvedReferences,
            priority,
            messages: relevantMessages
        });
    }

    prepareMessages(messages, options) {
        const filtered = messages
            .slice(-options.lookbackLimit)
            .filter(msg => {
                if (options.includeUserMessages && msg.role === 'user') return true;
                if (options.includeAssistantMessages && msg.role === 'assistant') return true;
                return false;
            })
            .map(msg => ({
                role: msg.role,
                content: msg.content || '',
                timestamp: msg.timestamp || new Date()
            }));

        return filtered.reverse(); // Most recent first
    }

    extractTaskInformation(messages) {
        const taskMatches = [];

        for (const message of messages) {
            const content = message.content;
            
            // Check each task category
            for (const [category, patterns] of Object.entries(this.taskPatterns)) {
                for (const pattern of patterns) {
                    const match = content.match(pattern);
                    if (match && match[1]) {
                        taskMatches.push({
                            category,
                            description: match[1].trim(),
                            confidence: this.calculateTaskConfidence(match[1], category),
                            messageIndex: messages.indexOf(message),
                            fullMatch: match[0]
                        });
                    }
                }
            }
        }

        // Sort by confidence and recency
        taskMatches.sort((a, b) => {
            if (Math.abs(a.confidence - b.confidence) < 0.1) {
                return a.messageIndex - b.messageIndex; // More recent first
            }
            return b.confidence - a.confidence; // Higher confidence first
        });

        return taskMatches.slice(0, 3); // Return top 3 matches
    }

    extractEntities(messages) {
        const entities = [];

        for (const message of messages) {
            const content = message.content;
            
            for (const pattern of this.entityPatterns) {
                const matches = content.matchAll(new RegExp(pattern.source, 'gi'));
                for (const match of matches) {
                    if (match[1]) {
                        entities.push({
                            type: this.classifyEntity(match[1]),
                            name: match[1].trim(),
                            context: match[0],
                            messageIndex: messages.indexOf(message)
                        });
                    }
                }
            }
        }

        return entities;
    }

    resolveReferences(messages) {
        const references = [];

        for (let i = 0; i < messages.length; i++) {
            const message = messages[i];
            const content = message.content;
            
            for (const pattern of this.referencePatterns) {
                const match = content.match(pattern);
                if (match) {
                    // Look in previous messages for context
                    const context = this.findReferenceContext(messages, i + 1);
                    references.push({
                        reference: match[0],
                        possibleContext: context,
                        messageIndex: i
                    });
                }
            }
        }

        return references;
    }

    findReferenceContext(messages, startIndex) {
        // Look in the next few messages for context
        const contextMessages = messages.slice(startIndex, startIndex + 3);
        const context = [];

        for (const msg of contextMessages) {
            // Extract potential subjects from the message
            const sentences = msg.content.split(/[.!?]/);
            for (const sentence of sentences) {
                if (sentence.trim().length > 10) {
                    context.push(sentence.trim());
                }
            }
        }

        return context.slice(0, 2); // Return top 2 context items
    }

    determinePriority(messages) {
        let priorityScore = 0;
        let priorityLevel = 'medium';

        for (const message of messages) {
            const content = message.content.toLowerCase();
            
            for (const [level, indicators] of Object.entries(this.priorityIndicators)) {
                for (const indicator of indicators) {
                    if (content.includes(indicator)) {
                        switch (level) {
                            case 'urgent': priorityScore += 4; break;
                            case 'high': priorityScore += 3; break;
                            case 'medium': priorityScore += 2; break;
                            case 'low': priorityScore += 1; break;
                        }
                    }
                }
            }
        }

        if (priorityScore >= 4) priorityLevel = 'urgent';
        else if (priorityScore >= 3) priorityLevel = 'high';
        else if (priorityScore >= 2) priorityLevel = 'medium';
        else priorityLevel = 'low';

        return { level: priorityLevel, score: priorityScore };
    }

    calculateTaskConfidence(description, category) {
        let confidence = 0.5; // Base confidence
        
        // Increase confidence based on description length and specificity
        if (description.length > 20) confidence += 0.1;
        if (description.length > 50) confidence += 0.1;
        
        // Category-specific boosts
        const categoryKeywords = {
            bugs: ['error', 'exception', 'crash', 'fail', 'broken'],
            features: ['new', 'add', 'implement', 'create'],
            improvements: ['better', 'faster', 'optimize', 'enhance'],
            documentation: ['docs', 'guide', 'explain', 'document'],
            deployment: ['deploy', 'production', 'live', 'server'],
            ui: ['interface', 'design', 'user', 'visual'],
            api: ['endpoint', 'service', 'backend', 'data']
        };

        const keywords = categoryKeywords[category] || [];
        const descLower = description.toLowerCase();
        
        for (const keyword of keywords) {
            if (descLower.includes(keyword)) {
                confidence += 0.05;
            }
        }

        return Math.min(confidence, 1.0);
    }

    classifyEntity(entityName) {
        const name = entityName.toLowerCase();
        
        if (name.match(/\.(js|ts|jsx|tsx)$/)) return 'javascript_file';
        if (name.match(/\.(py)$/)) return 'python_file';
        if (name.match(/\.(php)$/)) return 'php_file';
        if (name.match(/\.(md|txt)$/)) return 'documentation';
        if (name.match(/\.(json|yml|yaml)$/)) return 'config_file';
        if (name.includes('component')) return 'component';
        if (name.includes('api') || name.includes('endpoint')) return 'api';
        if (name.includes('database') || name.includes('db')) return 'database';
        
        return 'unknown';
    }

    combineContext(extracted) {
        const { taskInfo, entities, resolvedReferences, priority } = extracted;
        
        // Select best task description
        let title = 'Task from conversation';
        let description = 'Please specify the task details';
        let category = 'general';
        let confidence = 0;

        if (taskInfo.length > 0) {
            const bestTask = taskInfo[0];
            title = this.generateTitle(bestTask);
            description = bestTask.description;
            category = bestTask.category;
            confidence = bestTask.confidence;
        }

        // Enhance with entity information
        if (entities.length > 0) {
            const entityNames = entities.map(e => e.name).join(', ');
            if (description === 'Please specify the task details') {
                description = `Work on: ${entityNames}`;
            } else {
                description += ` (related to: ${entityNames})`;
            }
        }

        // Include reference context if available
        const contextNotes = [];
        if (resolvedReferences.length > 0) {
            contextNotes.push('References previous discussion');
        }
        if (entities.length > 0) {
            contextNotes.push(`Involves: ${entities.map(e => e.type).join(', ')}`);
        }

        return {
            title,
            description,
            category,
            confidence,
            priority: priority.level,
            entities,
            contextNotes,
            source: 'conversation_analysis',
            extractedTasks: taskInfo.slice(0, 3),
            references: resolvedReferences
        };
    }

    generateTitle(taskInfo) {
        const { category, description } = taskInfo;
        
        const prefixes = {
            bugs: 'Fix',
            features: 'Implement',
            improvements: 'Improve',
            documentation: 'Document',
            deployment: 'Deploy',
            ui: 'Update UI',
            api: 'API Work'
        };

        const prefix = prefixes[category] || 'Work on';
        const shortDesc = description.length > 30 
            ? description.substring(0, 30) + '...' 
            : description;
            
        return `${prefix}: ${shortDesc}`;
    }

    createEmptyContext() {
        return {
            title: 'New Task',
            description: 'Please specify the task details',
            category: 'general',
            confidence: 0,
            priority: 'medium',
            entities: [],
            contextNotes: ['No conversation context available'],
            source: 'no_context',
            extractedTasks: [],
            references: []
        };
    }

    /**
     * Quick context extraction for immediate use
     * @param {Array} messages - Recent messages
     * @returns {Object} - Simplified context
     */
    quickExtract(messages) {
        const lastUserMessage = messages
            .filter(m => m.role === 'user')
            .slice(-1)[0];

        if (!lastUserMessage) {
            return this.createEmptyContext();
        }

        // Try to extract task from the last user message
        const taskInfo = this.extractTaskInformation([lastUserMessage]);
        
        if (taskInfo.length > 0) {
            const task = taskInfo[0];
            return {
                title: this.generateTitle(task),
                description: task.description,
                category: task.category,
                confidence: task.confidence,
                priority: 'medium',
                source: 'last_message'
            };
        }

        return {
            title: 'Continue conversation',
            description: lastUserMessage.content.substring(0, 100) + '...',
            category: 'general',
            confidence: 0.3,
            priority: 'medium',
            source: 'last_message_fallback'
        };
    }
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = ContextExtractor;
}

// CLI usage
if (require.main === module) {
    const extractor = new ContextExtractor();
    
    // Sample conversation for testing
    const sampleMessages = [
        { role: 'user', content: 'The mobile menu component is broken on iOS devices' },
        { role: 'user', content: 'Users can\'t close it after opening' },
        { role: 'user', content: 'This is causing issues in production' },
        { role: 'user', content: 'Can someone fix this urgently?' }
    ];
    
    console.log('🔍 Context Extraction Example:');
    const context = extractor.extractContext(sampleMessages);
    console.log(JSON.stringify(context, null, 2));
    
    console.log('\n⚡ Quick Extract:');
    const quickContext = extractor.quickExtract(sampleMessages);
    console.log(JSON.stringify(quickContext, null, 2));
}