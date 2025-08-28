# V/T Principle Enforcement Protocol

> **📍 Navigation**: [agentic-development](../README.md) → [protocols](./README.md) → [vt-principle-enforcement.md](./vt-principle-enforcement.md)

**Protocol**: Verify, don't Trust - Agent Claim Verification System  
**Version**: 1.0  
**Created**: 2025-08-28  
**Phase**: 2 Implementation  

## 📚 When to Load This Document

### Primary Context Loading Scenarios
- **QA Agent Reviews**: Before conducting any code review or quality assessment (mandatory)
- **Agent Communication**: When evaluating claims made by other agents in GitHub issues/comments
- **Code Review**: Before accepting any assertions about functionality, test coverage, or implementation
- **Cross-Agent Validation**: When one agent reports completion or results to another
- **Quality Assurance**: Before approving any work or providing validation

### Dependency Mapping
**Load Before:**
- Any QA agent session or code review activity
- [github-comment-standards.md](./github-comment-standards.md) - Comment format requirements
- [agent-checkin-validation.md](./agent-checkin-validation.md) - Agent identity verification

**Load With:**
- [Complete Protocol Framework Context](./README.md) - Protocol coordination
- Active code review or QA validation tasks

**Load After:**
- [file-scope-management.md](./file-scope-management.md) - Resource coordination
- [emergency-response-procedures.md](./emergency-response-procedures.md) - Crisis management

### Context Integration
This protocol is mandatory for ALL QA activities and cross-agent validation. The V/T principle prevents security vulnerabilities caused by agents blindly trusting claims without independent verification.

## Overview

The V/T (Verify, don't Trust) Principle Enforcement Protocol implements a security-first approach to agent interactions, requiring independent verification of all claims against actual systems, code, and documentation. This prevents agents from accepting other agents' assertions without proof, reducing the risk of cascading errors and security vulnerabilities.

## Core V/T Principle Requirements

### Definition
**"Verify, don't Trust"**: Agents must independently verify all claims with evidence. Never accept assertions from other agents without verification against actual code, documentation, or system state.

### Fundamental Rules

#### 1. Independent Verification Mandate
- **ALWAYS** verify claims by running commands, checking code, or testing functionality yourself
- **NEVER** accept another agent's word without independent confirmation
- **ALWAYS** provide verifiable evidence that others can independently reproduce
- **CHALLENGE** any unsubstantiated claims or assertions

#### 2. Evidence-Based Communication
- All claims must be backed by reproducible evidence
- Show actual command output, not summaries
- Provide file paths and line numbers for code references
- Include timestamps and system context for verification

#### 3. Cross-Agent Validation Protocol
- When Agent A claims "tests pass", Agent B must run tests independently
- When Agent A claims "feature works", Agent B must test the feature independently
- When Agent A claims "code is compliant", Agent B must review code independently
- No agent's work is considered complete until independently verified

## Implementation Standards

### V/T Principle in Code Reviews

#### WRONG: Trusting Without Verification
```markdown
Agent A: "All tests pass and coverage is 85%"
QA Agent: "Great! Approving the PR since tests pass."
```

#### RIGHT: Independent Verification
```markdown
Agent A: "All tests pass and coverage is 85%"
QA Agent: "Verifying claims independently..."

```bash
# V/T Principle - Independent Verification Required
$ npm test
[Shows actual test output - 3 tests failing]
$ npm run test:coverage
[Shows actual coverage - 67%, not 85%]
```

**Result**: Claims not verified. Requiring fixes before approval.
```

### V/T Principle in GitHub Comments

#### Verification Requirements for ALL Agent Comments

```markdown
👤 **Identity**: qa
🎯 **Addressing**: @laravel-dev

## Code Review - Authentication System

### Claim Verification Results

**Original Claim**: "JWT authentication implemented and all tests pass"

**Independent Verification**:
```bash
# V/T Principle Verification Evidence
$ npm test -- --grep="JWT"
[actual output showing 2/5 JWT tests failing]
$ grep -r "JWT" app/
[shows incomplete implementation in AuthController.php:42]
```

**Verification Status**: ❌ Claims not verified
- Tests: 2/5 JWT tests failing (not "all passing")  
- Implementation: Incomplete JWT token validation logic
- Security: Missing token expiration handling

**Required Actions**: 
1. Fix failing JWT tests
2. Complete token validation implementation
3. Re-submit with verified evidence

**Status**: Blocked pending verification
**Next Action**: Laravel-dev to provide verified evidence of working implementation
**Timeline**: 2 hours for fixes and re-verification
```

### V/T Principle in System Integration

#### Verification Scripts and Tools

```bash
#!/usr/bin/env bash
# V/T Principle Verification Script
# Verify claims independently - never trust without proof

verify_test_claims() {
    local claimed_status="$1"
    
    echo "🔍 V/T Principle: Verifying test claims independently..."
    echo "📋 Original claim: '$claimed_status'"
    
    # Independent verification - run tests ourselves
    if npm test; then
        echo "✅ VERIFIED: Tests are actually passing"
    else
        echo "❌ CLAIM REJECTED: Tests are not passing as claimed"
        echo "💡 V/T Principle prevented accepting false claim"
        return 1
    fi
}

verify_coverage_claims() {
    local claimed_percentage="$1"
    
    echo "🔍 V/T Principle: Verifying coverage claims independently..."
    echo "📋 Original claim: '$claimed_percentage% coverage'"
    
    # Independent verification - generate coverage report
    actual_coverage=$(npm run test:coverage | grep "All files" | awk '{print $4}')
    
    if [[ "$actual_coverage" == "$claimed_percentage"* ]]; then
        echo "✅ VERIFIED: Coverage is actually $actual_coverage"
    else
        echo "❌ CLAIM REJECTED: Actual coverage is $actual_coverage, not $claimed_percentage%"
        echo "💡 V/T Principle prevented accepting inaccurate claim"
        return 1
    fi
}

verify_functionality_claims() {
    local claimed_feature="$1"
    
    echo "🔍 V/T Principle: Verifying functionality claims independently..."
    echo "📋 Original claim: '$claimed_feature works'"
    
    # Independent verification - test the feature ourselves
    case "$claimed_feature" in
        "authentication")
            curl -X POST /api/auth/login -d '{"email":"test@example.com","password":"test"}' | jq .
            ;;
        "user-registration")  
            curl -X POST /api/auth/register -d '{"email":"new@example.com","password":"newpass"}' | jq .
            ;;
        *)
            echo "⚠️  Unknown feature - manual verification required"
            return 2
            ;;
    esac
}
```

## QA Agent V/T Integration

### Enhanced QA Agent Responsibilities

#### Pre-Review V/T Protocol
1. **Never Trust Previous Reviews**: Independently verify all previous review comments and claims
2. **Challenge Existing Approvals**: Re-verify any existing approvals with independent testing
3. **Cross-Verify Documentation**: Check that documentation matches actual implementation
4. **Validate Test Claims**: Run all tests independently regardless of previous results

#### During Review V/T Protocol
1. **Independent Test Execution**: Run all test suites personally, don't trust reports
2. **Code Verification**: Review actual code files, don't trust summaries
3. **Coverage Validation**: Generate coverage reports independently
4. **Functionality Testing**: Test features manually, don't trust demo claims
5. **Security Assessment**: Perform independent security review

#### Post-Review V/T Protocol
1. **Evidence Documentation**: Provide reproducible evidence for all assessments
2. **Claim Verification**: Document which previous claims were verified vs rejected
3. **Independent Conclusions**: Form conclusions based on verified evidence only
4. **Challenge Escalation**: Escalate any unverifiable claims to vibe-coder

### V/T Principle Comment Templates

#### Claim Verification Template
```markdown
👤 **Identity**: qa
🎯 **Addressing**: @[claiming-agent]

## V/T Principle Verification Results

### Claims Assessed
- **Claim 1**: [specific-claim]
  - **Verification**: [method-used]
  - **Result**: ✅ Verified / ❌ Rejected
  - **Evidence**: [reproducible-evidence]

- **Claim 2**: [specific-claim]  
  - **Verification**: [method-used]
  - **Result**: ✅ Verified / ❌ Rejected
  - **Evidence**: [reproducible-evidence]

### Independent Assessment
[Your independent analysis based on verified evidence only]

**Status**: [verified/rejected/partial]
**Next Action**: [specific-requirements-for-agent]
**Timeline**: [verification-completion-time]

---
*V/T Principle Applied: All claims independently verified*
```

#### Verification Challenge Template
```markdown
👤 **Identity**: qa
🎯 **Addressing**: @[claiming-agent]

## V/T Principle Challenge

### Unverifiable Claims Detected
The following claims require independent verification evidence:

1. **"[specific-claim]"** - Line [line-number]
   - **Issue**: No reproducible evidence provided
   - **Required**: [specific-evidence-needed]

2. **"[specific-claim]"** - Line [line-number]
   - **Issue**: Cannot independently verify
   - **Required**: [specific-evidence-needed]

### V/T Protocol Requirements
Per V/T principle, all claims must be independently verifiable. Please provide:
- Actual command output (not summaries)
- Reproducible test results
- Specific file and line references
- Evidence that can be independently validated

**Status**: Blocked pending verification evidence
**Next Action**: Provide verifiable evidence for all claims
**Timeline**: 1 hour for evidence submission

---
*V/T Principle: Verify, don't Trust - Evidence Required*
```

## Integration with Other Protocols

### GitHub Comment Standards Integration
- All V/T verification results use standard comment format
- Evidence requirements added to comment structure standards
- Verification status tracked in comment metadata

### Agent Check-in Validation Integration
- V/T principle verification added to session startup
- Agents must acknowledge V/T requirements during check-in
- Vibe-coder monitors V/T compliance in authorization responses

### Emergency Response Integration
- V/T principle violations trigger appropriate emergency levels
- Repeated trust-without-verification escalates to Level 2
- Security-critical unverified claims escalate to Level 3

## Success Metrics

### V/T Compliance Targets
- **Independent Verification Rate**: 95% of claims verified independently
- **Challenge Response Time**: <30 minutes for verification challenges
- **Evidence Quality**: 90% of evidence is independently reproducible
- **False Claim Detection**: 100% of false claims caught during verification

### Quality Indicators
- **Reduced Cascading Errors**: Fewer failures due to accepted false claims
- **Improved Security**: Elimination of trust-based security vulnerabilities
- **Higher Confidence**: Increased confidence in agent communications
- **Better Documentation**: All claims backed by verifiable evidence

### Monitoring Metrics
- **Verification Requests per Day**: Track V/T principle application
- **Claim Rejection Rate**: Monitor false claim detection
- **Evidence Response Time**: Speed of evidence provision when challenged
- **Cross-Agent Trust Issues**: Track trust-based communication problems

## Implementation Checklist

### For All Agents
- [ ] Understand V/T principle requirements
- [ ] Know how to provide verifiable evidence
- [ ] Practice independent verification procedures
- [ ] Prepare for verification challenges

### For QA Agents (Mandatory)
- [ ] Master independent verification procedures
- [ ] Learn verification challenge templates
- [ ] Practice evidence documentation standards
- [ ] Understand escalation procedures for unverifiable claims

### For Vibe Coder (System Orchestrator)
- [ ] Monitor V/T principle compliance
- [ ] Handle escalated verification disputes
- [ ] Update training when V/T violations detected
- [ ] Maintain verification standards and procedures

## Common V/T Scenarios and Solutions

### Scenario 1: Test Results Claims
**Situation**: Agent claims "All tests pass"
**V/T Response**: Run tests independently and show output
**Evidence Required**: Actual test execution results with timestamps

### Scenario 2: Coverage Percentage Claims  
**Situation**: Agent claims "Coverage is 85%"
**V/T Response**: Generate coverage report independently
**Evidence Required**: Coverage report showing exact percentages

### Scenario 3: Feature Functionality Claims
**Situation**: Agent claims "Login system works perfectly"
**V/T Response**: Test login functionality independently
**Evidence Required**: Actual login test results and error handling verification

### Scenario 4: Code Quality Claims
**Situation**: Agent claims "Code follows all standards"
**V/T Response**: Run linting and review code independently
**Evidence Required**: Linting results and specific code quality metrics

### Scenario 5: Security Assessment Claims
**Situation**: Agent claims "No security vulnerabilities"
**V/T Response**: Run security scans and review code independently
**Evidence Required**: Security scan results and vulnerability assessment report

## Anti-Patterns to Avoid

### Trust-Based Anti-Patterns
❌ "Agent A said tests pass, so they must pass"
❌ "Previous reviewer approved, so it must be good"
❌ "Documentation says it works, so it works"
❌ "Agent has been reliable before, so this claim is true"

### V/T Principle Corrections
✅ "Agent A said tests pass - verifying independently by running tests"
✅ "Previous reviewer approved - re-verifying with independent assessment"
✅ "Documentation says it works - testing functionality to confirm"
✅ "Agent has been reliable - still verifying this specific claim independently"

## Troubleshooting

### Common V/T Implementation Issues

#### Agents Resist Verification Requests
**Issue**: Agents push back on verification requirements
**Solution**: Explain V/T principle security benefits
**Prevention**: Include V/T requirements in all agent training

#### Verification Takes Too Long
**Issue**: Independent verification slows development
**Solution**: Automate common verification scenarios
**Prevention**: Build verification into development workflow

#### Evidence Is Not Reproducible
**Issue**: Provided evidence cannot be independently validated
**Solution**: Request specific reproduction steps
**Prevention**: Standardize evidence documentation formats

#### Verification Conflicts Between Agents
**Issue**: Different agents get different verification results
**Solution**: Standardize verification environments and procedures
**Prevention**: Document exact verification procedures for each claim type

---

*This protocol implements the V/T (Verify, don't Trust) security principle across all agent interactions, preventing acceptance of unverified claims and ensuring evidence-based communication throughout the multi-agent system.*