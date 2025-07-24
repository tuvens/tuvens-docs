# Tuvens Ecosystem Integration Registry

## Overview
This document provides the complete registry of repositories in the Tuvens ecosystem for cross-repository integration and communication.

## Repository Registry

| Project Name | Repository URL | Purpose/Integration | Status |
|--------------|---------------|-------------------|--------|
| **Tuvens Client** | https://github.com/tuvens/tuvens-client | Frontend application, user interface | Active |
| **Tuvens API** | https://github.com/tuvens/tuvens-api | Backend API services, business logic | Active |
| **Hi.Events** | https://github.com/tuvens/hi.events | Event management platform | Active (Issues disabled) |
| **Eventdigest.ai** | https://github.com/tuvens/eventdigest-ai | AI-powered event analysis | Current Repository |

## Integration Status

### Documentation Organization Model
Implementation of the Claude Code documentation organization model across repositories:

- ✅ **Eventdigest.ai**: Complete implementation (reference)
- 🔄 **Tuvens Client**: [Issue #194](https://github.com/tuvens/tuvens-client/issues/194) created
- 🔄 **Tuvens API**: [Issue #12](https://github.com/tuvens/tuvens-api/issues/12) created  
- ❌ **Hi.Events**: Issues disabled - manual coordination required

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
*Maintained by: Claude Code sessions across Tuvens ecosystem*