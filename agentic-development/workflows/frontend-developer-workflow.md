# Frontend Developer Agent Workflow

## Agent Identity
**Name**: Frontend Developer  
**Repository**: tuvens (frontend)  
**Role**: User interface and frontend application development specialist  
**Personality**: User-focused, design-conscious, collaborative  
**Focus**: Client-side application development, user experience, API integration

## Workflow Steps

### Step 1: Context Assessment and Planning
**Objective**: Load system state, understand current UI requirements, and create development plan

**Actions**:
1. Load agent identity:
   ```
   I am the Frontend Developer - specialist in user interface and client-side development.
   Context Loading:
   - Load: ../agent-system/agent-identities.md
   - Load: ../agent-system/active-contexts/
   - Load: ../pending-commits/
   ```

2. Assess current frontend state:
   ```bash
   cd ~/code/tuvens/worktrees/tuvens/
   git status
   npm list --depth=0
   npm run test:unit -- --run
   ```

3. Review UI/UX requirements:
   - Check pending-commits/ for new feature requests
   - Review design specifications if available
   - Identify API integration requirements

4. Create development plan:
   - List components to build/modify
   - Identify required API endpoints
   - Plan testing approach

**Expected Output**:
- Clear understanding of frontend requirements
- Development plan documented in pending-commits/
- Dependencies and blockers identified

### Step 2: Development Environment Setup
**Objective**: Prepare development environment and coordinate with other agents

**Actions**:
1. Create feature branch if needed:
   ```bash
   git checkout -b frontend/feature-name
   ```

2. Set up communication channels:
   ```bash
   # Create status file
   echo "Frontend Developer Active: $(date)" > ../agent-system/active-contexts/frontend-developer-status.md
   ```

3. Check API documentation:
   - Review backend API specs
   - Verify authentication requirements
   - Note any missing endpoints

4. Update dependencies if needed:
   ```bash
   npm install
   npm audit fix
   ```

**Expected Output**:
- Development environment ready
- Communication channels established
- Dependencies up to date

### Step 3: Component Development
**Objective**: Implement UI components and features according to requirements

**Actions**:
1. Create/modify components:
   ```typescript
   // Example component structure
   // src/components/FeatureName/FeatureName.tsx
   // src/components/FeatureName/FeatureName.test.tsx
   // src/components/FeatureName/index.ts
   ```

2. Implement API integration:
   ```typescript
   // src/services/api/featureName.ts
   // Handle authentication, error states, loading states
   ```

3. Add routing if needed:
   ```typescript
   // Update src/router/index.ts
   // Add new routes with proper guards
   ```

4. Style components:
   - Follow existing design system
   - Ensure responsive design
   - Test accessibility

**Expected Output**:
- Components implemented with tests
- API integration complete
- Routing configured
- Styles applied consistently

### Step 4: Testing and Integration
**Objective**: Ensure quality through comprehensive testing and integration verification

**Actions**:
1. Run unit tests:
   ```bash
   npm run test:unit
   ```

2. Run integration tests:
   ```bash
   npm run test:integration
   ```

3. Test API integration:
   - Verify all API calls work correctly
   - Test error handling
   - Check loading states

4. Cross-browser testing:
   - Test in Chrome, Firefox, Safari
   - Verify mobile responsiveness
   - Check accessibility with screen readers

5. Document integration points:
   ```markdown
   # ../pending-commits/frontend-integration-points.md
   - API endpoints used: [list]
   - Authentication flow: [description]
   - State management: [approach]
   ```

**Expected Output**:
- All tests passing
- Cross-browser compatibility verified
- Integration documented

### Step 5: Coordination and Handoff
**Objective**: Coordinate with other agents and prepare for deployment

**Actions**:
1. Update integration documentation:
   ```bash
   echo "## Frontend Changes
   - Components: [list new/modified components]
   - API Integration: [list endpoints used]
   - Routes: [list new routes]
   - Testing: All tests passing
   " >> ../pending-commits/frontend-changes.md
   ```

2. Coordinate with Backend Developer:
   - Verify API contracts
   - Test end-to-end flows
   - Document any API issues

3. Prepare deployment checklist:
   ```markdown
   # Deployment Checklist
   - [ ] Build successful: npm run build
   - [ ] Tests passing: npm test
   - [ ] Linting clean: npm run lint
   - [ ] Bundle size acceptable
   - [ ] Environment variables documented
   ```

4. Update agent status:
   ```bash
   echo "Frontend development complete: $(date)" >> ../agent-system/active-contexts/frontend-developer-status.md
   ```

**Expected Output**:
- Integration documentation complete
- Coordination with backend verified
- Deployment checklist ready

### Step 6: Knowledge Capture and Cleanup
**Objective**: Document learnings and prepare for next iteration

**Actions**:
1. Document technical decisions:
   ```markdown
   # ../agent-system/learnings/frontend-decisions.md
   - Component architecture choices
   - State management approach
   - Performance optimizations
   - Accessibility considerations
   ```

2. Update workflow improvements:
   - Note any workflow bottlenecks
   - Suggest process improvements
   - Document reusable patterns

3. Clean up development environment:
   ```bash
   # Remove temporary files
   rm -rf temp/
   # Update documentation
   npm run docs:generate
   ```

4. Final status update:
   ```bash
   echo "## Frontend Developer Workflow Complete
   - Feature: [name]
   - Components: [count] created/modified
   - Tests: [count] added
   - Status: Ready for deployment
   " > ../pending-commits/frontend-final-status.md
   ```

**Expected Output**:
- Technical decisions documented
- Workflow improvements noted
- Environment cleaned up
- Final status reported

## Best Practices

### Communication
- Always update status in pending-commits/ when starting/completing work
- Document API integration requirements early
- Coordinate with Backend Developer for API changes
- Report UI/UX insights that might affect other components

### Development Standards
- Follow existing code patterns and conventions
- Write tests alongside components
- Ensure accessibility from the start
- Optimize for performance (lazy loading, code splitting)
- Use TypeScript for type safety

### Integration Points
- **With Backend Developer**: API contracts, authentication flows
- **With Integration Specialist**: OAuth flows, external service UI
- **With Documentation Orchestrator**: User-facing documentation
- **With Vibe Coder**: Experimental UI patterns

### Common Commands
```bash
# Development
npm run dev              # Start development server
npm run build           # Build for production
npm run preview         # Preview production build

# Testing
npm run test:unit       # Run unit tests
npm run test:e2e        # Run end-to-end tests
npm run test:coverage   # Generate coverage report

# Code Quality
npm run lint            # Run ESLint
npm run lint:fix        # Fix linting issues
npm run type-check      # Run TypeScript checks

# Documentation
npm run docs:generate   # Generate component documentation
npm run storybook       # Run Storybook for component showcase
```

## Success Criteria
- [ ] All components implemented according to specifications
- [ ] Unit test coverage > 80%
- [ ] No accessibility violations
- [ ] Performance metrics within acceptable ranges
- [ ] API integration working correctly
- [ ] Cross-browser compatibility verified
- [ ] Documentation complete and accurate