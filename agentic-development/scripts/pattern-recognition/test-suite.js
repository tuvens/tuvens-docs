#!/usr/bin/env node

/**
 * Comprehensive Test Suite for Pattern Recognition System
 * 
 * This script tests all components of the flexible /start-session pattern recognition.
 */

const SessionOrchestrator = require('./session-orchestrator');
const PatternMatcher = require('./pattern-matcher');
const AgentResolver = require('./agent-resolver');
const ContextExtractor = require('./context-extractor');
const ConfirmationHandler = require('./confirmation-handler');

class PatternRecognitionTestSuite {
    constructor() {
        this.orchestrator = new SessionOrchestrator({ autoConfirm: false });
        this.patternMatcher = new PatternMatcher();
        this.agentResolver = new AgentResolver();
        this.contextExtractor = new ContextExtractor();
        this.confirmationHandler = new ConfirmationHandler();
        
        this.testCases = this.initializeTestCases();
        this.results = {
            passed: 0,
            failed: 0,
            total: 0,
            details: []
        };
    }

    initializeTestCases() {
        return {
            // Direct /start-session patterns
            direct: [
                {
                    input: '/start-session vibe-coder "Fix Documentation" "Update API reference docs"',
                    expected: { agent: 'vibe-coder', title: 'Fix Documentation', confidence: '>0.9' }
                },
                {
                    input: '/start-session react-dev fix mobile menu bug',
                    expected: { agent: 'react-dev', title: 'fix mobile menu bug', confidence: '>0.8' }
                },
                {
                    input: '/start-session devops',
                    expected: { agent: 'devops', needsContext: true, confidence: '>0.8' }
                }
            ],

            // Natural language session patterns
            session: [
                {
                    input: 'start session with devops for deployment',
                    expected: { agent: 'devops', title: 'deployment', confidence: '>0.7' }
                },
                {
                    input: 'begin react-dev session to fix the UI',
                    expected: { agent: 'react-dev', title: 'fix the UI', confidence: '>0.7' }
                },
                {
                    input: 'get vibe-coder started on documentation',
                    expected: { agent: 'vibe-coder', title: 'documentation', confidence: '>0.7' }
                }
            ],

            // Traditional handoff patterns
            handoff: [
                {
                    input: 'Get vibe-coder to work on this documentation issue',
                    expected: { agent: 'vibe-coder', title: 'documentation issue', confidence: '>0.7' }
                },
                {
                    input: 'Have the devops agent handle this deployment issue',
                    expected: { agent: 'devops', title: 'deployment issue', confidence: '>0.7' }
                },
                {
                    input: 'Ask react-dev to fix this UI bug',
                    expected: { agent: 'react-dev', title: 'UI bug', confidence: '>0.7' }
                }
            ],

            // Fuzzy agent matching
            fuzzy: [
                {
                    input: '/start-session vibe fix the docs',
                    expected: { agent: 'vibe-coder', title: 'fix the docs', confidence: '>0.8' }
                },
                {
                    input: 'start session with react developer to fix components',
                    expected: { agent: 'react-dev', title: 'fix components', confidence: '>0.7' }
                },
                {
                    input: 'get the laravel developer to work on API',
                    expected: { agent: 'laravel-dev', title: 'API', confidence: '>0.7' }
                }
            ],

            // Technology-based matching
            technology: [
                {
                    input: 'start working with laravel on authentication',
                    expected: { agent: 'laravel-dev', title: 'authentication', confidence: '>0.6' }
                },
                {
                    input: 'get react to handle the frontend',
                    expected: { agent: 'react-dev', title: 'frontend', confidence: '>0.6' }
                },
                {
                    input: 'have node work on the API',
                    expected: { agent: 'node-dev', title: 'API', confidence: '>0.6' }
                }
            ],

            // Context extraction scenarios
            context: [
                {
                    input: '/start-session react-dev',
                    context: [
                        { role: 'user', content: 'The mobile menu component is broken on iOS' },
                        { role: 'user', content: 'Users cant close it after opening' }
                    ],
                    expected: { agent: 'react-dev', title: 'mobile menu', confidence: '>0.7' }
                }
            ],

            // Error cases
            errors: [
                {
                    input: 'invalid command without pattern',
                    expected: { type: 'no_pattern' }
                },
                {
                    input: '/start-session unknownagent fix something',
                    expected: { type: 'agent_not_found' }
                }
            ]
        };
    }

    async runAllTests() {
        console.log('🧪 Starting Comprehensive Pattern Recognition Test Suite\n');
        
        // Test each category
        for (const [category, tests] of Object.entries(this.testCases)) {
            console.log(`📋 Testing ${category.toUpperCase()} patterns:`);
            await this.runCategoryTests(category, tests);
            console.log();
        }

        // Run component-specific tests
        await this.runComponentTests();

        // Generate report
        this.generateReport();
    }

    async runCategoryTests(category, tests) {
        for (let i = 0; i < tests.length; i++) {
            const test = tests[i];
            const testName = `${category}-${i + 1}`;
            
            try {
                const result = await this.orchestrator.processInput(
                    test.input, 
                    test.context || []
                );
                
                const passed = this.validateResult(result, test.expected);
                this.recordResult(testName, test.input, result, test.expected, passed);
                
                console.log(`  ${passed ? '✅' : '❌'} ${testName}: "${test.input}"`);
                
            } catch (error) {
                this.recordResult(testName, test.input, null, test.expected, false, error);
                console.log(`  ❌ ${testName}: ERROR - ${error.message}`);
            }
        }
    }

    async runComponentTests() {
        console.log('🔧 Testing Individual Components:');
        
        // Test pattern matcher
        await this.testPatternMatcher();
        
        // Test agent resolver
        await this.testAgentResolver();
        
        // Test context extractor
        await this.testContextExtractor();
        
        // Test confirmation handler
        await this.testConfirmationHandler();
    }

    async testPatternMatcher() {
        const tests = [
            { input: '/start-session vibe-coder "test"', expected: 'direct' },
            { input: 'start session with devops', expected: 'session' },
            { input: 'get react-dev to work on this', expected: 'handoff' }
        ];

        for (const test of tests) {
            const result = this.patternMatcher.recognizePattern(test.input);
            const passed = result && result.type === test.expected;
            this.recordResult(`pattern-${test.expected}`, test.input, result, test.expected, passed);
            console.log(`  ${passed ? '✅' : '❌'} Pattern Matcher: ${test.input}`);
        }
    }

    async testAgentResolver() {
        const tests = [
            { input: 'vibe', expected: 'vibe-coder' },
            { input: 'react developer', expected: 'react-dev' },
            { input: 'laravel', expected: 'laravel-dev' },
            { input: 'invalid-agent', expected: null }
        ];

        for (const test of tests) {
            const result = this.agentResolver.resolveAgent(test.input);
            const passed = result.agent === test.expected;
            this.recordResult(`agent-${test.input}`, test.input, result, test.expected, passed);
            console.log(`  ${passed ? '✅' : '❌'} Agent Resolver: "${test.input}" → ${result.agent || 'null'}`);
        }
    }

    async testContextExtractor() {
        const messages = [
            { role: 'user', content: 'The mobile menu is broken' },
            { role: 'user', content: 'It wont close on iOS devices' }
        ];

        const result = this.contextExtractor.extractContext(messages);
        const passed = result.title && result.title.includes('mobile');
        this.recordResult('context-extraction', 'mobile menu issue', result, 'extracted context', passed);
        console.log(`  ${passed ? '✅' : '❌'} Context Extractor: Found "${result.title}"`);
    }

    async testConfirmationHandler() {
        const sampleResult = {
            type: 'direct',
            confidence: 0.9,
            agent: 'react-dev',
            title: 'Test task',
            description: 'Test description'
        };

        const confirmation = this.confirmationHandler.generateConfirmation(
            sampleResult, 
            null, 
            '/start-session react-dev "Test task"'
        );

        const passed = confirmation.type === 'confirmation' && confirmation.message.includes('react-dev');
        this.recordResult('confirmation', 'generate confirmation', confirmation, 'confirmation message', passed);
        console.log(`  ${passed ? '✅' : '❌'} Confirmation Handler: Generated confirmation`);
    }

    validateResult(result, expected) {
        if (expected.type) {
            return result.type === expected.type;
        }

        if (!result.data && !result.agent) {
            return false;
        }

        const data = result.data || result;
        
        // Check agent
        if (expected.agent && data.agent !== expected.agent) {
            return false;
        }

        // Check title/task
        if (expected.title) {
            const title = data.title || data.description || '';
            if (!title.toLowerCase().includes(expected.title.toLowerCase())) {
                return false;
            }
        }

        // Check confidence
        if (expected.confidence) {
            const confidence = data.confidence || 0;
            if (expected.confidence.startsWith('>')) {
                const threshold = parseFloat(expected.confidence.substring(1));
                if (confidence <= threshold) {
                    return false;
                }
            }
        }

        // Check needsContext
        if (expected.needsContext !== undefined) {
            if (data.needsContext !== expected.needsContext) {
                return false;
            }
        }

        return true;
    }

    recordResult(testName, input, result, expected, passed, error = null) {
        this.results.total++;
        if (passed) {
            this.results.passed++;
        } else {
            this.results.failed++;
        }

        this.results.details.push({
            test: testName,
            input,
            result,
            expected,
            passed,
            error: error?.message
        });
    }

    generateReport() {
        const { passed, failed, total } = this.results;
        const successRate = Math.round((passed / total) * 100);

        console.log('📊 TEST RESULTS SUMMARY');
        console.log('========================');
        console.log(`Total Tests: ${total}`);
        console.log(`Passed: ${passed} ✅`);
        console.log(`Failed: ${failed} ❌`);
        console.log(`Success Rate: ${successRate}%`);
        console.log();

        if (failed > 0) {
            console.log('❌ FAILED TESTS:');
            console.log('================');
            
            const failedTests = this.results.details.filter(d => !d.passed);
            failedTests.forEach(test => {
                console.log(`• ${test.test}: "${test.input}"`);
                if (test.error) {
                    console.log(`  Error: ${test.error}`);
                } else {
                    console.log(`  Expected: ${JSON.stringify(test.expected)}`);
                    console.log(`  Got: ${JSON.stringify(test.result?.agent || test.result?.type || 'null')}`);
                }
                console.log();
            });
        }

        console.log(`🎯 Pattern Recognition System: ${successRate >= 80 ? 'READY' : 'NEEDS IMPROVEMENT'}`);
        
        if (successRate >= 80) {
            console.log('✅ The pattern recognition system is working well and ready for integration!');
        } else {
            console.log('⚠️ Some test cases failed. Review the implementation before deploying.');
        }
    }
}

// Export for module usage
if (typeof module !== 'undefined' && module.exports) {
    module.exports = PatternRecognitionTestSuite;
}

// CLI usage
if (require.main === module) {
    const testSuite = new PatternRecognitionTestSuite();
    
    console.log('🚀 Running Pattern Recognition Test Suite...\n');
    
    testSuite.runAllTests()
        .then(() => {
            console.log('\n✅ Test suite completed!');
            process.exit(testSuite.results.failed > 0 ? 1 : 0);
        })
        .catch(error => {
            console.error('❌ Test suite failed:', error);
            process.exit(1);
        });
}