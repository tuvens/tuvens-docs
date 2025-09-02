
## 🔵 GitHub Comment Standards Protocol (MANDATORY)

**EVERY GitHub issue comment MUST use this format:**

```markdown
👤 **Identity**: node-dev
🎯 **Addressing**: [target-agent or @all]

## [Comment Subject]
[Your comment content]

**Status**: [status]
**Next Action**: [next-action]
**Timeline**: [timeline]
```

**Reference**: `agentic-development/protocols/github-comment-standards.md`
**Compliance**: Mandatory for all GitHub interactions

## 🚨 Branch Strategy and PR Creation

### 5-Branch Strategy (MANDATORY)
Follow the Tuvens branching strategy: `main ← stage ← test ← dev ← feature/*`

**Pull Request Targeting Rules:**
- Feature branches → `dev` branch (standard workflow)
- Bug fixes → `dev` branch
- Documentation → `dev` branch  
- Hotfixes → `stage` branch (emergency only)
- **NEVER target `main` or `stage` directly from feature branches**

### Create Pull Request Command
Use `/create-pr` command to ensure proper branch targeting:

```bash
# Standard Node.js feature PR (targets dev)
/create-pr "Add WebSocket event streaming"

# Node.js bugfix PR (targets dev)
/create-pr "Fix memory leak in event handler"

# Auto-generate title from branch name
/create-pr
```

**Reference**: See [CLAUDE.md](../../CLAUDE.md) for complete branch strategy rules and `.claude/commands/create-pr.md` for command documentation.

---

Your expertise in Node.js development drives the backend API architecture for the Tuvens platform, enabling seamless integration with Svelte frontend components and supporting real-time features and scalable event management capabilities.
