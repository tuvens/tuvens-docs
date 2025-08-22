#!/usr/bin/env node

/**
 * Advanced Agent Name Resolution with Fuzzy Matching
 * 
 * This module provides sophisticated agent name resolution capabilities
 * including fuzzy matching, technology-based matching, and role-based resolution.
 */

class AgentResolver {
    constructor() {
        this.agentDatabase = {
            'vibe-coder': {
                canonical: 'vibe-coder',
                aliases: ['vibe-coder', 'vibe coder', 'vibecoder'],
                shortcuts: ['vibe'],
                roles: ['system architect', 'documentation expert', 'docs expert', 'architect'],
                technologies: ['documentation', 'system design', 'architecture'],
                responsibilities: ['system coordination', 'documentation', 'agent improvement']
            },
            'react-dev': {
                canonical: 'react-dev',
                aliases: ['react-dev', 'react dev', 'react developer'],
                shortcuts: ['react'],
                roles: ['frontend developer', 'ui developer', 'frontend dev', 'ui dev'],
                technologies: ['react', 'jsx', 'frontend', 'ui', 'component'],
                responsibilities: ['react development', 'frontend', 'ui components']
            },
            'laravel-dev': {
                canonical: 'laravel-dev',
                aliases: ['laravel-dev', 'laravel dev', 'laravel developer'],
                shortcuts: ['laravel'],
                roles: ['backend developer', 'api developer', 'backend dev', 'api dev'],
                technologies: ['laravel', 'php', 'backend', 'api', 'database'],
                responsibilities: ['laravel backend', 'api development', 'database']
            },
            'svelte-dev': {
                canonical: 'svelte-dev',
                aliases: ['svelte-dev', 'svelte dev', 'svelte developer'],
                shortcuts: ['svelte'],
                roles: ['frontend developer', 'ui developer', 'frontend dev'],
                technologies: ['svelte', 'sveltekit', 'frontend', 'ui'],
                responsibilities: ['svelte development', 'tuvens-client frontend']
            },
            'node-dev': {
                canonical: 'node-dev',
                aliases: ['node-dev', 'node dev', 'node developer'],
                shortcuts: ['node', 'nodejs'],
                roles: ['backend developer', 'api developer', 'nodejs developer'],
                technologies: ['node', 'nodejs', 'javascript', 'backend', 'api'],
                responsibilities: ['node.js backend', 'tuvens-api development']
            },
            'devops': {
                canonical: 'devops',
                aliases: ['devops', 'dev ops'],
                shortcuts: ['ops'],
                roles: ['infrastructure engineer', 'deployment engineer', 'ops engineer'],
                technologies: ['docker', 'ci/cd', 'infrastructure', 'deployment', 'github actions'],
                responsibilities: ['infrastructure', 'deployment', 'ci/cd pipelines']
            }
        };

        this.initializeLookupMaps();
    }

    initializeLookupMaps() {
        // Create reverse lookup maps for faster searching
        this.aliasMap = new Map();
        this.shortcutMap = new Map();
        this.roleMap = new Map();
        this.technologyMap = new Map();

        for (const [agentId, config] of Object.entries(this.agentDatabase)) {
            // Map aliases
            config.aliases.forEach(alias => {
                this.aliasMap.set(alias.toLowerCase(), agentId);
            });

            // Map shortcuts
            config.shortcuts.forEach(shortcut => {
                this.shortcutMap.set(shortcut.toLowerCase(), agentId);
            });

            // Map roles
            config.roles.forEach(role => {
                if (!this.roleMap.has(role.toLowerCase())) {
                    this.roleMap.set(role.toLowerCase(), []);
                }
                this.roleMap.get(role.toLowerCase()).push(agentId);
            });

            // Map technologies
            config.technologies.forEach(tech => {
                if (!this.technologyMap.has(tech.toLowerCase())) {
                    this.technologyMap.set(tech.toLowerCase(), []);
                }
                this.technologyMap.get(tech.toLowerCase()).push(agentId);
            });
        }
    }

    /**
     * Main agent resolution method with multiple strategies
     * @param {string} input - Agent name input
     * @returns {Object} - Resolution result with confidence score
     */
    resolveAgent(input) {
        const cleanInput = input.toLowerCase().trim();
        
        // Strategy 1: Exact alias match (highest confidence)
        const exactMatch = this.findExactMatch(cleanInput);
        if (exactMatch) {
            return {
                agent: exactMatch,
                confidence: 1.0,
                method: 'exact_alias',
                input: input
            };
        }

        // Strategy 2: Shortcut match
        const shortcutMatch = this.findShortcutMatch(cleanInput);
        if (shortcutMatch) {
            return {
                agent: shortcutMatch,
                confidence: 0.95,
                method: 'shortcut',
                input: input
            };
        }

        // Strategy 3: Role-based match
        const roleMatch = this.findRoleMatch(cleanInput);
        if (roleMatch) {
            return {
                agent: roleMatch.agent,
                confidence: roleMatch.confidence,
                method: 'role_based',
                input: input,
                matches: roleMatch.matches
            };
        }

        // Strategy 4: Technology-based match
        const techMatch = this.findTechnologyMatch(cleanInput);
        if (techMatch) {
            return {
                agent: techMatch.agent,
                confidence: techMatch.confidence,
                method: 'technology_based',
                input: input,
                matches: techMatch.matches
            };
        }

        // Strategy 5: Fuzzy string matching
        const fuzzyMatch = this.findFuzzyMatch(cleanInput);
        if (fuzzyMatch && fuzzyMatch.confidence > 0.6) {
            return {
                agent: fuzzyMatch.agent,
                confidence: fuzzyMatch.confidence,
                method: 'fuzzy_match',
                input: input,
                matchedString: fuzzyMatch.matchedString
            };
        }

        // No match found
        return {
            agent: null,
            confidence: 0,
            method: 'no_match',
            input: input,
            suggestions: this.getSuggestions(cleanInput)
        };
    }

    findExactMatch(input) {
        return this.aliasMap.get(input) || null;
    }

    findShortcutMatch(input) {
        return this.shortcutMap.get(input) || null;
    }

    findRoleMatch(input) {
        const matches = [];
        
        for (const [role, agents] of this.roleMap.entries()) {
            if (role.includes(input) || input.includes(role)) {
                matches.push({ role, agents, similarity: this.calculateSimilarity(input, role) });
            }
        }

        if (matches.length === 0) return null;

        // Sort by similarity and return best match
        matches.sort((a, b) => b.similarity - a.similarity);
        const bestMatch = matches[0];
        
        return {
            agent: bestMatch.agents[0], // Return first agent if multiple
            confidence: Math.min(0.85, bestMatch.similarity),
            matches: matches
        };
    }

    findTechnologyMatch(input) {
        const matches = [];
        
        for (const [tech, agents] of this.technologyMap.entries()) {
            if (tech.includes(input) || input.includes(tech)) {
                matches.push({ technology: tech, agents, similarity: this.calculateSimilarity(input, tech) });
            }
        }

        if (matches.length === 0) return null;

        // Sort by similarity and return best match
        matches.sort((a, b) => b.similarity - a.similarity);
        const bestMatch = matches[0];
        
        return {
            agent: bestMatch.agents[0], // Return first agent if multiple
            confidence: Math.min(0.80, bestMatch.similarity),
            matches: matches
        };
    }

    findFuzzyMatch(input) {
        let bestMatch = null;
        let highestSimilarity = 0;

        // Check against all aliases and roles
        for (const [agentId, config] of Object.entries(this.agentDatabase)) {
            const allStrings = [...config.aliases, ...config.roles, ...config.shortcuts];
            
            for (const str of allStrings) {
                const similarity = this.calculateSimilarity(input, str.toLowerCase());
                if (similarity > highestSimilarity && similarity > 0.6) {
                    highestSimilarity = similarity;
                    bestMatch = {
                        agent: agentId,
                        confidence: similarity * 0.75, // Reduce confidence for fuzzy matches
                        matchedString: str
                    };
                }
            }
        }

        return bestMatch;
    }

    /**
     * Calculate string similarity using Levenshtein distance
     * @param {string} str1 - First string
     * @param {string} str2 - Second string
     * @returns {number} - Similarity score (0-1)
     */
    calculateSimilarity(str1, str2) {
        const len1 = str1.length;
        const len2 = str2.length;
        
        if (len1 === 0) return len2 === 0 ? 1 : 0;
        if (len2 === 0) return 0;

        // Create distance matrix
        const matrix = Array(len1 + 1).fill().map(() => Array(len2 + 1).fill(0));
        
        // Initialize first row and column
        for (let i = 0; i <= len1; i++) matrix[i][0] = i;
        for (let j = 0; j <= len2; j++) matrix[0][j] = j;
        
        // Fill the matrix
        for (let i = 1; i <= len1; i++) {
            for (let j = 1; j <= len2; j++) {
                const cost = str1[i - 1] === str2[j - 1] ? 0 : 1;
                matrix[i][j] = Math.min(
                    matrix[i - 1][j] + 1,     // deletion
                    matrix[i][j - 1] + 1,     // insertion
                    matrix[i - 1][j - 1] + cost // substitution
                );
            }
        }
        
        const distance = matrix[len1][len2];
        const maxLen = Math.max(len1, len2);
        return 1 - (distance / maxLen);
    }

    getSuggestions(input) {
        const suggestions = [];
        
        // Get all agent names and common variations
        for (const [agentId, config] of Object.entries(this.agentDatabase)) {
            suggestions.push({
                agent: agentId,
                canonical: config.canonical,
                shortcuts: config.shortcuts,
                similarity: this.calculateSimilarity(input, agentId)
            });
        }

        // Sort by similarity and return top 3
        return suggestions
            .sort((a, b) => b.similarity - a.similarity)
            .slice(0, 3)
            .map(s => ({
                agent: s.agent,
                canonical: s.canonical,
                shortcuts: s.shortcuts
            }));
    }

    /**
     * Get all available agents with their information
     * @returns {Object} - Agent database
     */
    getAllAgents() {
        return this.agentDatabase;
    }

    /**
     * Validate if an agent exists
     * @param {string} agentId - Agent identifier
     * @returns {boolean} - Whether agent exists
     */
    isValidAgent(agentId) {
        return this.agentDatabase.hasOwnProperty(agentId);
    }
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AgentResolver;
}

// CLI usage
if (require.main === module) {
    const resolver = new AgentResolver();
    const input = process.argv[2];
    
    if (!input) {
        console.log('Usage: node agent-resolver.js "agent name"');
        console.log('\nAvailable agents:');
        const agents = resolver.getAllAgents();
        for (const [id, config] of Object.entries(agents)) {
            console.log(`  ${id}: ${config.shortcuts.join(', ')}`);
        }
        process.exit(1);
    }
    
    const result = resolver.resolveAgent(input);
    console.log('🔍 Agent Resolution Result:');
    console.log(JSON.stringify(result, null, 2));
    
    if (result.agent) {
        const agentInfo = resolver.getAllAgents()[result.agent];
        console.log(`\n✅ Resolved to: ${agentInfo.canonical}`);
        console.log(`📋 Responsibilities: ${agentInfo.responsibilities.join(', ')}`);
    } else {
        console.log('\n❌ No agent found');
        console.log('💡 Suggestions:');
        result.suggestions.forEach(s => {
            console.log(`  • ${s.canonical} (shortcuts: ${s.shortcuts.join(', ')})`);
        });
    }
}