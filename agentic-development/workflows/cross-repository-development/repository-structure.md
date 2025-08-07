# 🏗️ Repository Structure Standards

### Standard Directory Layout

All Tuvens repositories should follow this consistent structure:

```
repository-name/
├── .github/
│   ├── workflows/              # CI/CD pipelines
│   ├── ISSUE_TEMPLATE/         # Issue templates
│   └── pull_request_template.md
├── docs/
│   ├── .claude/                # Claude Code integration
│   │   ├── commands/           # Custom commands
│   │   └── INTEGRATION_REGISTRY.md
│   ├── api/                    # API documentation
│   ├── deployment/             # Deployment guides
│   └── development/            # Development setup
├── src/                        # Source code
├── tests/                      # Test files
├── scripts/                    # Build and utility scripts
├── CLAUDE.md                   # Claude Code instructions
├── README.md                   # Project overview
├── CONTRIBUTING.md             # Contribution guidelines
└── package.json / requirements.txt
```

### Claude Code Integration

Every repository must include:

1. **CLAUDE.md** - Claude Code session instructions
2. **docs/.claude/** - Claude integration directory
3. **INTEGRATION_REGISTRY.md** - Cross-repository integration tracking