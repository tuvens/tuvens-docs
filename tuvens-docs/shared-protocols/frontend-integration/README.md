# General Frontend Integration Guide

## 🎯 Overview

This guide provides comprehensive standards and patterns for frontend integration across the Tuvens ecosystem, ensuring consistency, performance, and maintainability across all frontend applications.

**Updated: August 2025** - Enhanced cross-repository notification system with intelligent comment-based tracking (syntax fixed).

## 📚 Documentation Index

### Core Standards
- [🏗️ Architecture Standards](./architecture-standards.md) - Technology stack, project structure, component patterns
- [🎨 Design System Integration](./design-system-integration.md) - Tuvens design system, color palette, typography
- [🔌 API Integration Patterns](./api-integration-patterns.md) - Service architecture, error handling, data flow

### Quality & Performance
- [🧪 Testing Standards](./testing-standards.md) - Unit, integration, E2E testing requirements
- [🚀 Performance Optimization](./performance-optimization.md) - Metrics, optimization techniques, monitoring
- [♿ Accessibility Standards](./accessibility-standards.md) - WCAG compliance, testing tools, best practices

### Security & Operations
- [🔒 Security Best Practices](./security-best-practices.md) - Authentication, data protection, vulnerability prevention
- [📊 Analytics and Monitoring](./analytics-monitoring.md) - Tracking, error monitoring, performance metrics
- [🚀 Deployment and CI/CD](./deployment-cicd.md) - Build process, environments, deployment strategy

## Quick Start

For Claude Code sessions, load only the sections relevant to your current task:

```markdown
# For component development
Load: shared-protocols/frontend-integration/architecture-standards.md
Load: shared-protocols/frontend-integration/design-system-integration.md

# For API integration work
Load: shared-protocols/frontend-integration/api-integration-patterns.md

# For testing implementation
Load: shared-protocols/frontend-integration/testing-standards.md

# For performance optimization
Load: shared-protocols/frontend-integration/performance-optimization.md

# For accessibility compliance
Load: shared-protocols/frontend-integration/accessibility-standards.md

# For security review
Load: shared-protocols/frontend-integration/security-best-practices.md

# For deployment setup
Load: shared-protocols/frontend-integration/deployment-cicd.md
```

## Compliance Requirements

All Tuvens frontend applications must meet:
- ✅ TypeScript strict mode
- ✅ 80%+ test coverage
- ✅ WCAG 2.1 AA accessibility
- ✅ Core Web Vitals performance targets
- ✅ Security best practices

## Contributing

When updating these standards:
1. Edit the specific micro-doc in the `frontend-integration/` directory
2. Update this index if adding new sections
3. Ensure cross-references between docs are maintained
4. Follow the established format and structure

---

*Maintained by: Tuvens development team*  
*Last updated: 2025-08-01*