# Task 6: tuvens-mobile Adaptation

## Task Overview

**Agent**: mobile-dev  
**Worktree**: `mobile-dev/task-06-mobile-adaptation`  
**Branch**: `mobile-dev/task-06-mobile-adaptation`  
**Estimated Time**: 1-2 focused sessions  

## Objective

Adapt the validated branch protection and collaborative workflow components from tuvens-docs to tuvens-mobile repository, with mobile development-specific customizations and Flutter workflow integration.

## Current State Analysis

### tuvens-docs Implementation (Post Tasks 1-5):
- Enhanced CLAUDE.md with comprehensive safety rules
- Branch protection GitHub Actions workflow
- Pre-merge safety validation scripts
- PR templates and CODEOWNERS
- Validated integration with agent workflows

### tuvens-mobile Current State:
- Basic repository structure with dev worktree
- Mobile development documentation standards
- Flutter-specific development patterns
- Integration specialist agent workflows
- No branch protection or safety automation

## Deliverables

### Primary Deliverables:

1. **Mobile-Specific CLAUDE.md Enhancement**
   - Adapted safety rules for mobile development context
   - Flutter development workflow integration
   - Mobile testing requirements and protocols
   - Platform-specific validation (iOS/Android)

2. **Mobile-Adapted Branch Protection Workflow**
   - Flutter build validation
   - Platform compatibility checking
   - Mobile-specific documentation validation
   - Integration with mobile development tools

3. **Mobile Development Safety Scripts**
   - Flutter project validation
   - Platform build verification
   - Mobile testing protocol enforcement
   - App store compliance checking

4. **Mobile-Focused PR Templates**
   - Flutter development checklists
   - Platform testing requirements
   - Mobile UX validation
   - Performance impact assessment

5. **Mobile Development CODEOWNERS**
   - Mobile expertise area assignment
   - Platform-specific reviewers
   - Flutter component ownership
   - Integration specialist coverage

## Implementation Specifications

### Mobile-Specific Adaptations:

#### 1. CLAUDE.md Enhancements for Mobile
```markdown
## 🚨 CRITICAL: Mobile Development Safety Rules

### Flutter Development Requirements
- **Flutter Version**: Maintain compatibility with specified Flutter version
- **Platform Testing**: Both iOS and Android validation required
- **Performance**: 60fps target maintenance
- **Memory**: Efficiency standards compliance
- **Dependencies**: Security and compatibility validation

### Mobile Branch Protection Rules
- mobile-dev/* branches for Flutter development
- integration-specialist/* for cross-platform work
- Platform-specific testing before merge
- App store compliance validation
```

#### 2. Mobile Branch Protection Workflow
```yaml
# Additional mobile-specific validation
- Flutter doctor validation
- Platform build verification (iOS/Android)
- Performance testing requirements
- App store guideline compliance
- Mobile UX standards checking
```

#### 3. Mobile Safety Scripts
```bash
# check-before-merge-mobile.sh
- Flutter project health validation
- Platform compatibility verification
- Mobile testing protocol compliance
- Performance impact assessment
- App store readiness checking
```

#### 4. Mobile PR Template Sections
```markdown
## Mobile Development Checklist
- [ ] Flutter version compatibility maintained
- [ ] iOS build successful
- [ ] Android build successful
- [ ] Performance targets met (60fps, memory)
- [ ] Mobile UX standards followed
- [ ] App store compliance verified
- [ ] Platform-specific testing completed
```

## Mobile Development Context Considerations

### Flutter Development Integration:
- Flutter doctor validation requirements
- Platform-specific build verification
- Dependency management safety
- Version compatibility maintenance
- Hot reload and development server considerations

### Platform-Specific Requirements:
- iOS development constraints and requirements
- Android development considerations
- Platform testing validation
- App store compliance checking
- Cross-platform consistency validation

### Mobile UX and Performance:
- 60fps performance target maintenance
- Memory usage optimization validation
- Battery efficiency considerations
- Platform UI/UX guideline compliance
- Accessibility requirement validation

## Success Criteria

### Functional Requirements:
- [ ] All branch protection components adapted for mobile context
- [ ] Flutter development workflow integration successful
- [ ] Platform-specific validation working correctly
- [ ] Mobile testing protocols enforced
- [ ] No disruption to existing mobile development patterns

### Mobile-Specific Requirements:
- [ ] Flutter doctor validation integrated
- [ ] Platform build verification automated
- [ ] Mobile performance standards enforced
- [ ] App store compliance checking functional
- [ ] Cross-platform consistency maintained

### Integration Requirements:
- [ ] Seamless integration with integration-specialist workflows
- [ ] Compatibility with existing mobile dev worktree patterns
- [ ] No conflicts with Flutter development tools
- [ ] Mobile-specific documentation validated

## Key Adaptations from tuvens-docs

### Repository Context Changes:
1. **Code vs. Documentation**: Adapt from documentation repository to code repository
2. **Flutter Integration**: Include Flutter-specific validation and requirements
3. **Platform Testing**: Add iOS/Android build and testing requirements
4. **Mobile Performance**: Include mobile-specific performance and UX validation

### Agent Pattern Adaptations:
- mobile-dev/* branches for Flutter development work
- integration-specialist/* for cross-platform integration
- Platform-specific validation requirements
- Mobile testing protocol integration

### Workflow Integration:
- Flutter development tool integration
- Platform build automation compatibility
- Mobile testing framework integration
- App deployment pipeline consideration

## Implementation Notes

### Must Preserve:
1. **Flutter Workflow**: Existing Flutter development patterns
2. **Platform Tools**: Integration with iOS/Android development tools
3. **Performance**: Mobile performance optimization workflows
4. **Testing**: Existing mobile testing procedures

### Must Enhance:
1. **Safety**: Prevent breaking changes to mobile apps
2. **Quality**: Ensure consistent mobile development standards
3. **Collaboration**: Safe multi-agent mobile development
4. **Compliance**: App store and platform guideline adherence

### Mobile-Specific Validations:
- Flutter project health and compatibility
- Platform build success verification
- Mobile performance standard compliance
- App store guideline validation
- Cross-platform consistency checking

## Files to Reference:
- Validated tuvens-docs implementation (Tasks 1-5 results)
- `/Users/ciarancarroll/Code/Tuvens/tuvens-mobile/` current structure
- Flutter development documentation and standards
- Mobile platform development requirements
- App store compliance guidelines

## Risks and Mitigation

### Mobile Development Risks:
1. **Build Complexity**: Mobile builds are more complex than documentation
2. **Platform Differences**: iOS vs Android validation requirements
3. **Tool Integration**: Integration with Flutter and platform tools
4. **Performance Impact**: Safety validation shouldn't slow development

### Mitigation Strategies:
1. **Incremental Implementation**: Start with basic adaptation, add complexity
2. **Platform-Aware Design**: Account for platform differences in validation
3. **Tool Compatibility**: Test integration with existing mobile development tools
4. **Performance Testing**: Ensure safety validation doesn't impact development speed

## Testing Plan

### Mobile-Specific Testing:
1. Test with actual Flutter project changes
2. Validate platform build verification works
3. Test mobile performance validation
4. Verify app store compliance checking
5. Test integration with mobile development tools

### Integration Testing:
1. Test with integration-specialist workflows
2. Validate mobile dev agent session patterns
3. Test cross-platform development scenarios
4. Verify no conflicts with Flutter tools

## Mobile Development Tools Integration

### Flutter CLI Integration:
- Flutter doctor validation automation
- Flutter test execution requirements
- Flutter build verification for platforms
- Flutter dependency management validation

### Platform Tool Integration:
- Xcode integration for iOS development
- Android Studio integration for Android development
- Platform-specific testing tool integration
- App store submission tool compatibility

## Session Startup Command

```bash
cd /Users/ciarancarroll/Code/Tuvens/tuvens-docs
/start-session mobile-dev
```

**Task Description for Session**: "Adapt validated branch protection and safety workflows from tuvens-docs to tuvens-mobile with Flutter development integration, platform-specific validation, and mobile UX/performance requirements."

## Dependencies
- Tasks 1-5: Complete and validated tuvens-docs implementation
- Access to tuvens-mobile repository structure
- Flutter development environment understanding
- Mobile platform development requirements
- User approval for mobile workflow changes

## Success Metrics
- All safety components successfully adapted for mobile context
- Flutter development workflow integration seamless
- Platform-specific validation functional
- No impact on mobile development velocity
- Mobile testing and compliance requirements enforced