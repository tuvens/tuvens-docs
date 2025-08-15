# Vibe Coder Wiki Synchronization Workflow

**Complete process documentation for Claude Code vibe coder agent to sync staged content to GitHub wiki**

## Overview

This document provides the Claude Code vibe coder agent with comprehensive instructions for detecting, reviewing, and synchronizing wiki-ready content from staging branches to the actual GitHub wiki repository.

## Agent Responsibilities

### 🎯 Primary Role
The vibe coder agent serves as the **Wiki Publication Orchestrator**, responsible for:
- Detecting wiki-ready content in pull requests
- Validating content quality and completeness
- Synchronizing approved content to GitHub wiki repository
- Maintaining wiki organization and navigation
- Cleaning up staging files from main repository
- Coordinating with content creators through PR comments

### 🔄 Workflow Integration  
- **Input**: Pull requests labeled with `wiki-ready`
- **Process**: Quality validation → Wiki sync → Staging cleanup
- **Output**: Published GitHub wiki content + clean main repository
- **Coordination**: PR comment communication with content creators

## Phase 1: Wiki-Ready Content Detection

### Automated Detection Triggers
```bash
# Monitor for PRs with wiki-ready label
gh pr list --label "wiki-ready" --state "open" --json number,title,author,labels

# Check for staged wiki content in PRs
find agentic-development/wiki/staging/ -name "*.md" -newer .last-wiki-sync
```

### PR Validation Checklist
When a `wiki-ready` PR is detected, validate:

✅ **Branch Targeting**: PR targets `dev` branch (not main/stage)  
✅ **Content Location**: Files in `agentic-development/wiki/staging/[category]/`  
✅ **Naming Convention**: Proper agent/wiki/descriptive-name branch format  
✅ **Label Requirements**: Contains `wiki-ready` and `documentation` labels  
✅ **Author Permissions**: Created by authorized agent account  

### Initial Response Protocol
Post standardized response to PR:

```markdown
👤 **Identity**: vibe-coder  
🎯 **Addressing**: [content-creator-agent]

## Wiki Content Review Started

I've detected your wiki-ready content and am beginning the review process.

### Content Detected
- **Files**: [list of staging files]
- **Category**: [architecture/agents/workflows/protocols/guides]
- **Scope**: [brief content summary]

### Review Process
1. ✅ Content structure and quality validation
2. ⏳ Technical accuracy verification  
3. ⏳ Wiki organization and categorization
4. ⏳ GitHub wiki synchronization
5. ⏳ Staging cleanup and PR merge

I'll provide updates as I progress through each phase.

**Expected Timeline**: 15-30 minutes for standard content review and sync.
```

## Phase 2: Content Quality Validation

### Structure Validation
Check each staged markdown file for:

```markdown
Required Elements:
✅ Document title (H1 heading)
✅ Overview/description section  
✅ Clear section organization (H2/H3 hierarchy)
✅ Professional writing quality
✅ Proper markdown formatting
✅ Complete information for target audience
```

### Technical Accuracy Review
```bash
# Validate file paths and references
grep -r "file_path:" agentic-development/wiki/staging/
grep -r "\[.*\](.*)" agentic-development/wiki/staging/ | grep -v "^#"

# Check for broken internal links
find . -name "*.md" -exec grep -l "agentic-development" {} \;

# Validate code examples and syntax
find agentic-development/wiki/staging/ -name "*.md" -exec grep -l "```" {} \;
```

### Content Completeness Assessment
- **Self-Contained**: Document includes all necessary context
- **Target Audience**: Appropriate level of detail for intended readers
- **Examples Included**: Concrete examples where helpful
- **Related Links**: References to related documentation
- **Maintenance Info**: Clear ownership and update procedures

### Quality Issues Response
If issues are found, post detailed feedback:

```markdown
👤 **Identity**: vibe-coder  
🎯 **Addressing**: [content-creator-agent]

## Content Review - Issues Found

I've identified some areas that need attention before wiki publication:

### Structure Issues
- [ ] [Specific formatting or organization problems]
- [ ] [Missing required sections or information]

### Technical Accuracy
- [ ] [Broken links or invalid references]
- [ ] [Outdated information or incorrect procedures]

### Completeness
- [ ] [Missing examples or unclear explanations]
- [ ] [Insufficient context for target audience]

Please address these issues and I'll re-review once you update the PR.

**Status**: Awaiting content improvements
```

## Phase 3: GitHub Wiki Synchronization

### Wiki Repository Setup
```bash
# Clone or update wiki repository
if [ ! -d "../wiki-temp" ]; then
  git clone https://github.com/tuvens/tuvens-docs.wiki.git ../wiki-temp
else
  cd ../wiki-temp && git pull origin master && cd -
fi
```

### Content Organization and Sync
```bash
# Create category-based organization in wiki repo
cd ../wiki-temp

# Map staging categories to wiki pages
# staging/architecture/ → Architecture-*.md
# staging/agents/ → Agent-*.md  
# staging/workflows/ → Workflow-*.md
# staging/protocols/ → Protocol-*.md
# staging/guides/ → Guide-*.md

# Copy and rename content with proper wiki naming
for file in ../tuvens-docs/agentic-development/wiki/staging/architecture/*.md; do
  basename=$(basename "$file" .md)
  cp "$file" "Architecture-${basename}.md"
done

# Update wiki navigation and index
# Edit Home.md to include new content links
# Update category index pages
# Create cross-references between related pages
```

### Wiki Index Update
Update the wiki's main navigation structure:

```markdown
# Tuvens Documentation Wiki

## System Architecture
- [Architecture Overview](Architecture-system-overview)
- [Multi-Agent Coordination](Architecture-multi-agent-coordination)
- [Repository Organization](Architecture-repository-structure)

## Agent Documentation  
- [Vibe Coder Agent](Agent-vibe-coder-overview)
- [DevOps Agent](Agent-devops-workflows)
- [Documentation Orchestrator](Agent-docs-orchestrator)

## Development Workflows
- [Branching Strategy](Workflow-branching-strategy)
- [Cross-Repository Development](Workflow-cross-repo-development)
- [Quality Assurance](Workflow-quality-assurance)

## Protocols & Standards
- [Safety Rules](Protocol-safety-rules)
- [Branch Protection](Protocol-branch-protection)  
- [Documentation Standards](Protocol-documentation-standards)

## User Guides
- [Getting Started](Guide-getting-started)
- [Agent Coordination](Guide-agent-coordination)
- [Mobile Development](Guide-mobile-development)
```

### Wiki Publication
```bash
cd ../wiki-temp

# Add all new and updated content
git add .

# Commit with descriptive message
git commit -m "docs: sync [category] documentation from main repository

- Add [list of new pages]
- Update [list of updated pages]  
- Improve navigation and cross-references
- Source: PR #[number] by [agent-name]

Co-authored-by: [agent-name] <noreply@anthropic.com>"

# Push to GitHub wiki repository
git push origin master
```

### Sync Confirmation
Post success confirmation to PR:

```markdown
👤 **Identity**: vibe-coder  
🎯 **Addressing**: [content-creator-agent]

## Wiki Synchronization Complete ✅

Your content has been successfully published to the GitHub wiki.

### Published Content
- **Wiki Pages**: [list of created/updated pages]
- **Category**: [architecture/agents/workflows/protocols/guides]  
- **Navigation**: Updated wiki index and cross-references
- **Access**: https://github.com/tuvens/tuvens-docs/wiki

### Changes Made
1. ✅ Content quality validated and approved
2. ✅ Organized into appropriate wiki categories
3. ✅ Added to wiki navigation structure  
4. ✅ Cross-references and links updated
5. ✅ Published to GitHub wiki repository

**Next**: Staging cleanup and PR completion
```

## Phase 4: Staging Cleanup and PR Completion

### Main Repository Cleanup
```bash
# Remove staged content from main repository
git rm -r agentic-development/wiki/staging/[category]/[content-files].md

# Commit cleanup
git commit -m "cleanup: remove wiki staging files after successful sync

- Content published to GitHub wiki
- Staging directory cleaned
- Wiki workflow completed successfully"

# Update wiki index if needed (add references to new wiki content)
```

### PR Merge Process
```bash
# Final review of PR changes
git diff HEAD~1

# Merge PR with squash to maintain clean history
gh pr merge [pr-number] --squash --subject "docs: add [description] via wiki workflow" --body "Content successfully synced to GitHub wiki and staging cleaned up."
```

### Post-Merge Validation
```bash
# Verify staging cleanup
ls -la agentic-development/wiki/staging/[category]/

# Confirm wiki publication
curl -s "https://api.github.com/repos/tuvens/tuvens-docs/wiki" | jq '.has_wiki'

# Update local wiki index timestamp
touch agentic-development/wiki/.last-wiki-sync
```

### Completion Notification
Final PR comment with completion summary:

```markdown
👤 **Identity**: vibe-coder  
🎯 **Addressing**: [content-creator-agent]

## Wiki Workflow Complete ✅

Successfully completed the full wiki publication workflow.

### Final Status
- ✅ Content quality validated and approved
- ✅ Published to GitHub wiki: https://github.com/tuvens/tuvens-docs/wiki
- ✅ Main repository staging cleaned up
- ✅ PR merged with clean commit history
- ✅ Wiki index and navigation updated

### Published Pages
[List of wiki pages created/updated]

**Total Processing Time**: [duration]  
**Wiki Content Status**: Live and accessible

Thank you for following the wiki content creation workflow!
```

## Error Handling and Recovery

### Common Issues and Solutions

#### Content Quality Issues
```markdown
Problem: Incomplete or poorly formatted content
Solution: 
1. Provide specific feedback via PR comments
2. Keep PR open for content improvements  
3. Re-validate after updates
4. Do not proceed with wiki sync until quality standards met
```

#### Wiki Repository Issues
```bash
# Wiki repository access problems
if ! git ls-remote https://github.com/tuvens/tuvens-docs.wiki.git; then
  echo "ERROR: Cannot access wiki repository"
  # Post error message to PR
  # Request manual intervention
fi

# Wiki content conflicts
cd ../wiki-temp
if ! git pull origin master; then
  echo "ERROR: Wiki repository merge conflicts"
  git status
  # Resolve conflicts manually or request assistance
fi
```

#### Staging Cleanup Failures
```bash
# If staging cleanup fails
if [ $? -ne 0 ]; then
  echo "WARNING: Staging cleanup failed"
  # Document which files couldn't be cleaned
  # Create follow-up issue for manual cleanup
  # Still complete PR merge
fi
```

### Emergency Procedures

#### Rollback Process
```bash
# If wiki content needs to be removed
cd ../wiki-temp
git revert [commit-hash]
git push origin master

# Document rollback in PR comments
# Create issue for content correction
```

#### Quality Escalation
When content quality issues cannot be resolved:
1. **Document Issues**: Detailed explanation of problems
2. **Pause Workflow**: Do not proceed with wiki sync
3. **Request Manual Review**: Involve additional agents or human oversight
4. **Preserve Staging**: Keep content in staging for manual processing

#### Communication Failures
If PR communication is interrupted:
1. **Status Documentation**: Record current workflow state in PR
2. **Handoff Instructions**: Clear next steps for workflow continuation  
3. **Issue Creation**: Create tracking issue for workflow completion
4. **Agent Notification**: Tag appropriate agents for continuation

## Performance Optimization

### Batch Processing
- Process multiple wiki-ready PRs together when possible
- Combine related content updates into single wiki commits
- Optimize repository cloning and updating procedures

### Automation Enhancement
- Implement webhook detection for immediate wiki-ready PR processing
- Automate quality validation checks where possible
- Create reusable templates for common PR responses

### Monitoring and Analytics
- Track wiki workflow performance metrics
- Monitor content quality improvement over time
- Analyze common issues for workflow enhancement opportunities

## Success Validation

### Workflow Completion Metrics
✅ **Content Quality**: All published content meets documentation standards  
✅ **Wiki Organization**: Proper categorization and navigation structure  
✅ **Clean Repository**: Staging files removed, minimal permanent files  
✅ **Timely Processing**: Consistent processing time for wiki-ready PRs  
✅ **Communication**: Clear updates and feedback throughout process  

### Quality Assurance Checks
✅ **Technical Accuracy**: Content information verified and current  
✅ **Link Validation**: All internal and external references working  
✅ **Format Consistency**: Professional formatting and structure  
✅ **Navigation Integration**: Content properly integrated into wiki structure  
✅ **Search Optimization**: Content organized for easy discovery  

---

**Last Updated**: 2025-08-15  
**Maintained By**: DevOps Agent  
**Version**: 1.0 - Initial wiki workflow implementation  

*This workflow enables the vibe coder agent to systematically review and publish high-quality wiki content while maintaining repository cleanliness and organizational standards.*