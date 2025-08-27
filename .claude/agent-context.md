# Devops Agent Context - Safety Check Clarity Improvements

## Agent Identity
**Agent**: devops (Infrastructure Specialist)
**Task**: Improve safety check clarity and escalation protocols
**Repository**: tuvens-docs

## Problem Statement
Currently, agents encounter blocking safety checks when committing documentation that contains words like 'key', 'api', 'token', etc. The safety checks don't provide:
- Clear explanations of what was flagged
- Why it was flagged (e.g., "example in documentation" vs "actual secret")
- How to properly resolve the issue
- Escalation path to vibe-coder orchestrator

This causes agents to waste time investigating and working around legitimate blocks.

## Solution Requirements
1. **Enhanced Error Messages**: Clear, specific feedback about what triggered the safety check
2. **Context Awareness**: Differentiate between documentation examples and actual secrets
3. **Resolution Guidance**: Step-by-step instructions for legitimate bypasses
4. **Escalation Protocol**: Automated way to request orchestrator review
5. **Audit Trail**: Log all bypasses and escalations for security

## Technical Approach
- Enhance `scripts/hooks/check-safety-rules.sh` with better detection and messaging
- Create escalation workflow for orchestrator review
- Add documentation vs. code context detection
- Implement secure bypass mechanism with proper logging

## Success Criteria
- Agents understand exactly why commits are blocked
- Clear path to resolution without compromising security
- Reduced time spent on false positive safety blocks
- Proper audit trail for all security decisions
