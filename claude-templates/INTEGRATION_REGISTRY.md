# {ECOSYSTEM_NAME} Integration Registry

## Overview
This document provides the complete registry of repositories in the {ECOSYSTEM_NAME} for cross-repository integration and communication.

## Repository Registry

| Project Name | Repository URL | Purpose/Integration | Status |
|--------------|---------------|-------------------|--------|
| **{PROJECT_1}** | {PROJECT_1_URL} | {PROJECT_1_PURPOSE} | Active |
| **{PROJECT_2}** | {PROJECT_2_URL} | {PROJECT_2_PURPOSE} | Active |
| **{PROJECT_3}** | {PROJECT_3_URL} | {PROJECT_3_PURPOSE} | Active |
| **{CURRENT_PROJECT}** | {CURRENT_PROJECT_URL} | {CURRENT_PROJECT_PURPOSE} | Current Repository |

## Integration Status

### Documentation Organization Model
Implementation of the Claude Code documentation organization model across repositories:

- ✅ **{REFERENCE_PROJECT}**: Complete implementation (reference)
- 🔄 **{PROJECT_1}**: Implementation in progress
- 🔄 **{PROJECT_2}**: Implementation in progress  
- 🔄 **{PROJECT_3}**: Implementation in progress

### Cross-Repository Communication
- **Method**: GitHub Issues with standardized templates
- **Commands**: Available in `docs/.claude/commands/`
- **Active Commands**: `/resolve-issue`, `/update-current-state`, `/report-bug`, `/send-rqts`, `/ask-question`, `/suggest-improvement`, `/propose-alternative`

## Usage Guidelines

### For Cross-Repository Requests
1. Identify target repository from registry above
2. Use GitHub CLI to create issues with proper templates
3. Include integration context and repository reference
4. Follow up on responses and track progress

### For Integration Planning
- Reference this registry when planning cross-repository features
- Consider all ecosystem dependencies
- Coordinate with other repository teams via issues

## Maintenance Notes

- Update this registry when new repositories are added to the ecosystem
- Maintain integration status as projects implement the documentation model
- Archive completed integration initiatives in `docs/.temp/`

---

*Last updated: 2025-07-24*
*Maintained by: Claude Code sessions across {ECOSYSTEM_NAME}*