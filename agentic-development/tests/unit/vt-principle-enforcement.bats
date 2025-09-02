#!/usr/bin/env bats
# File: tests/unit/vt-principle-enforcement.bats
# Purpose: Test V/T (Verify, don't Trust) principle enforcement implementation
# Dependencies: BATS testing framework, agentic-development/protocols/vt-principle-enforcement.md

setup() {
    export SCRIPT_DIR="$BATS_TEST_DIRNAME/../scripts"
    export PROTOCOL_DIR="$BATS_TEST_DIRNAME/../protocols"
}

# V/T Principle Protocol File Tests
@test "V/T principle enforcement protocol file exists" {
    run test -f "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
}

@test "V/T principle protocol contains required sections" {
    run grep -q "## Core V/T Principle Requirements" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "### Definition" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "### Independent Verification Mandate" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "## QA Agent V/T Integration" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
}

@test "V/T principle protocol defines verification requirements" {
    run grep -q "Never accept assertions from other agents without verification" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "Always verify against actual code, documentation, or system state" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "Challenge unsubstantiated claims and require proof" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
}

# QA Agent Integration Tests
@test "QA agent file includes V/T principle enforcement" {
    run grep -q "V/T Principle.*Verify, don't Trust.*Enforcement" "$BATS_TEST_DIRNAME/../desktop-project-instructions/agents/qa.md"
    assert_success
}

@test "QA agent file replaces D/E with V/T principle" {
    # Should not contain old D/E references
    run grep -q "D/E Principle.*Demonstration-over-Explanation" "$BATS_TEST_DIRNAME/../desktop-project-instructions/agents/qa.md"
    assert_failure
    
    # Should contain new V/T references
    run grep -q "V/T Principle.*Verify, don't Trust" "$BATS_TEST_DIRNAME/../../agentic-development/desktop-project-instructions/agents/qa.md"
    assert_success
}

@test "QA agent includes verification requirements" {
    run grep -q "Never accept claims from other agents without independent verification" "$BATS_TEST_DIRNAME/../../agentic-development/desktop-project-instructions/agents/qa.md"
    assert_success
    
    run grep -q "Always verify against actual code, documentation, or system state" "$BATS_TEST_DIRNAME/../../agentic-development/desktop-project-instructions/agents/qa.md"
    assert_success
}

# Code Review Script Tests
@test "code review script includes V/T principle integration" {
    run grep -q "V/T Principle.*Verify all claims with evidence" "$SCRIPT_DIR/setup-code-review-desktop.sh"
    assert_success
}

@test "code review script includes agent claim verification" {
    run grep -q "Agent Claim Verification.*Challenge and verify any claims made by other agents" "$SCRIPT_DIR/setup-code-review-desktop.sh"
    assert_success
}

@test "code review script replaces D/E with V/T references" {
    # Should contain V/T principle references
    run grep -q "V/T Principle.*never trust without proof" "$SCRIPT_DIR/setup-code-review-desktop.sh"
    assert_success
    
    run grep -q "Independently verify all claims made by other agents" "$SCRIPT_DIR/setup-code-review-desktop.sh"
    assert_success
}

# GitHub Comment Standards Integration Tests
@test "github comment standards integrates V/T principle" {
    run grep -q "V/T.*Verify, don't Trust.*principle" "$PROTOCOL_DIR/github-comment-standards.md"
    assert_success
}

@test "github comment standards includes verification requirements" {
    run grep -q "All claims must be backed by verifiable evidence" "$PROTOCOL_DIR/github-comment-standards.md"
    assert_success
    
    run grep -q "Challenge unsubstantiated assertions from other agents" "$PROTOCOL_DIR/github-comment-standards.md"
    assert_success
}

@test "github comment standards shows verification examples" {
    run grep -q "V/T Principle - Independently Verified" "$PROTOCOL_DIR/github-comment-standards.md"
    assert_success
    
    run grep -q "verified by running" "$PROTOCOL_DIR/github-comment-standards.md"
    assert_success
}

# Comment Validation Script Tests  
@test "comment validation script checks V/T compliance for QA agents" {
    run grep -q "V/T principle compliance.*for QA agents" "$SCRIPT_DIR/validate-github-comments.sh"
    assert_success
}

@test "comment validation includes verification evidence checks" {
    run grep -q "verified.*evidence.*verification" "$SCRIPT_DIR/validate-github-comments.sh"
    assert_success
}

@test "comment validation provides V/T guidance" {
    run grep -q "QA agents must provide verification evidence" "$SCRIPT_DIR/validate-github-comments.sh"
    assert_success
}

# Protocol Integration Tests
@test "protocols README includes V/T principle protocol" {
    run grep -q "V/T Principle Enforcement" "$PROTOCOL_DIR/README.md"
    assert_success
    
    run grep -q "vt-principle-enforcement.md" "$PROTOCOL_DIR/README.md"
    assert_success
}

@test "protocols README includes V/T in dependency mapping" {
    run grep -q "vt-principle-enforcement.md.*Claim verification requirements" "$PROTOCOL_DIR/README.md"
    assert_success
}

@test "protocols README includes V/T in usage guidelines" {
    run grep -q "Apply V/T principle.*Verify all claims with evidence" "$PROTOCOL_DIR/README.md"
    assert_success
}

# V/T Principle Content Validation Tests
@test "V/T principle defines security context correctly" {
    run grep -q "security principle preventing agents from accepting other agents" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
}

@test "V/T principle includes verification templates" {
    run grep -q "Claim Verification Template" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "Verification Challenge Template" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
}

@test "V/T principle includes practical examples" {
    run grep -q "WRONG.*trusting without verification" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "RIGHT.*Independent Verification" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
}

@test "V/T principle includes verification scripts" {
    run grep -q "verify_test_claims" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "verify_coverage_claims" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "verify_functionality_claims" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
}

# Integration Point Validation Tests
@test "all integration points updated consistently" {
    # Count V/T references across key files
    local vt_count=0
    
    # QA agent file
    if grep -q "V/T Principle" "$BATS_TEST_DIRNAME/../../agentic-development/desktop-project-instructions/agents/qa.md"; then
        ((vt_count++))
    fi
    
    # Code review script
    if grep -q "V/T Principle" "$SCRIPT_DIR/setup-code-review-desktop.sh"; then
        ((vt_count++))
    fi
    
    # GitHub comment standards
    if grep -q "V/T.*principle" "$PROTOCOL_DIR/github-comment-standards.md"; then
        ((vt_count++))
    fi
    
    # Comment validation script
    if grep -q "V/T principle" "$SCRIPT_DIR/validate-github-comments.sh"; then
        ((vt_count++))
    fi
    
    # Should have V/T references in all 4 integration points
    [ "$vt_count" -eq 4 ]
}

@test "no remaining D/E references in updated files" {
    # QA agent should not have D/E references
    run grep -q "D/E Principle.*Demonstration-over-Explanation" "$BATS_TEST_DIRNAME/../desktop-project-instructions/agents/qa.md"
    assert_failure
    
    # Code review script should not have D/E references  
    run grep -q "D/E Principle.*Demonstration-over-Explanation" "$SCRIPT_DIR/setup-code-review-desktop.sh"
    assert_failure
}

# Success Metrics Validation
@test "V/T principle includes measurable success metrics" {
    run grep -q "Independent Verification Rate.*95%" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "Challenge Response Time.*30 minutes" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "False Claim Detection.*100%" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
}

@test "V/T principle includes implementation checklist" {
    run grep -q "Implementation Checklist" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "For All Agents" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "For QA Agents.*Mandatory" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
}

@test "V/T principle includes troubleshooting guidance" {
    run grep -q "Common V/T Implementation Issues" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "Agents Resist Verification Requests" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
    
    run grep -q "Evidence Is Not Reproducible" "$PROTOCOL_DIR/vt-principle-enforcement.md"
    assert_success
}