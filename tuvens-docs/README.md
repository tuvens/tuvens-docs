# Tuvens Documentation Templates

Shared Claude Code documentation templates and structure for the Tuvens ecosystem repositories.

## Purpose

This repository provides standardized documentation templates that enable:
- ✅ Consistent Claude Code experience across all Tuvens repositories
- ✅ Cross-repository communication via standardized commands
- ✅ Organized temporary documentation sharing between Claude sessions
- ✅ Reduced maintenance overhead through centralized templates

## Structure

```
claude-templates/
├── commands/
│   ├── commands.json          # Command registry
│   ├── resolve-issue.md       # Close GitHub issues properly
│   ├── update-current-state.md # Project status updates
│   ├── report-bug.md          # Cross-repo bug reports
│   ├── send-rqts.md           # Feature requests
│   ├── ask-question.md        # Cross-repo questions
│   ├── suggest-improvement.md # Optimization suggestions
│   └── propose-alternative.md # Architectural alternatives
├── INTEGRATION_REGISTRY.md   # Tuvens ecosystem repository registry
└── .temp/                     # Organized temporary documentation structure
    ├── complete/
    ├── redundant/
    ├── in-progress/
    ├── ready-for-implementation/
    ├── integration-rqts/
    ├── bug-reports/
    ├── archived/
    ├── deprecated/
    ├── screenshots/
    ├── reports/
    ├── implementation-guides/
    ├── integration-docs/
    ├── auto-generated/
    └── commands/
```

## How to Use in Your Repository

### Option 1: Git Submodule (Recommended)

Add as a submodule to get automatic updates:

```bash
# In your repository root
git submodule add https://github.com/tuvens/tuvens-docs.git docs/shared-templates
git submodule update --init --recursive

# Copy templates to your docs structure
mkdir -p docs/.claude
cp -r docs/shared-templates/claude-templates/* docs/.claude/
cp -r docs/shared-templates/claude-templates/.temp docs/
```

### Option 2: Direct Copy

For a one-time setup:

```bash
# Clone the templates
git clone https://github.com/tuvens/tuvens-docs.git temp-docs

# Copy to your docs structure  
mkdir -p docs/.claude
cp -r temp-docs/claude-templates/* docs/.claude/
cp -r temp-docs/claude-templates/.temp docs/

# Cleanup
rm -rf temp-docs
```

### Option 3: Subdirectory Include

Include the entire repository as a subdirectory:

```bash
# In your repository root
git clone https://github.com/tuvens/tuvens-docs.git docs/tuvens-shared

# Reference files from docs/tuvens-shared/claude-templates/
```

## Customization Required

After copying templates, **you must customize repository references**:

1. **Update commands.json**: Change the description to reflect your repository name
2. **Update INTEGRATION_REGISTRY.md**: Mark your repository as "Current Repository" 
3. **Update command templates**: Replace repository references throughout all .md files

### Find and Replace Needed:
- `eventdigest-ai` → `your-repo-name`
- `eventdigest-ai/client` → `your-repo-name`

## Tuvens Ecosystem Repositories

| Repository | Purpose | Status |
|------------|---------|--------|
| [tuvens-client](https://github.com/tuvens/tuvens-client) | Frontend application | Active |
| [tuvens-api](https://github.com/tuvens/tuvens-api) | Backend API services | Active |
| [hi.events](https://github.com/tuvens/hi.events) | Event management platform | Active |
| [eventdigest-ai](https://github.com/tuvens/eventdigest-ai) | AI-powered event analysis | Active |

## Maintenance

This repository is maintained across all Tuvens ecosystem projects. Updates here automatically benefit all repositories using these templates.

To contribute improvements:
1. Fork this repository
2. Make improvements to templates
3. Submit pull request
4. Once merged, update submodules in other repositories

## Support

For questions about these templates or Claude Code integration:
- Reference the original implementation: [eventdigest-ai](https://github.com/tuvens/eventdigest-ai)
- Check existing GitHub issues in this repository
- Create new issues for template improvements

---

*Maintained by: Tuvens development team*  
*Last updated: 2025-07-24*