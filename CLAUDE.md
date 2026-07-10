# CLAUDE.md

A reusable Claude Code plugin framework — a collection of commands, skills, and MCP configurations.

## Repository Identity

This is not application code. It is a Claude Code plugin template repository. The repo is both a plugin and a marketplace (see `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`).

Only three kinds of artifacts:
- `.claude-plugin/{plugin,marketplace}.json` — plugin/marketplace manifests
- `commands/*.md` — slash commands
- `skills/<name>/SKILL.md` — skills

No source code, no build, no tests.

## Skill Sources

1. **Team-maintained** (edit in this repo): `domain-context`, `handoff`, `openspec-explore`, `best-effort-delivery`, `explore-legacy`, `light-explore`, `unknown-unknowns`, `skill-simplifier`
2. **Upstream-adapted**: `brainstorming` (from [obra/superpowers](https://github.com/obra/superpowers)). Adapted from upstream with modifications — see skill frontmatter for details.
3. **Consumer-installed**: `lark-*`, `meegle`, `planning-with-files`, and other vendor/community skills are installed by users in their own Claude Code environments. Not shipped here.

## Domain Knowledge Capture

The `domain-context` skill provides a general-purpose domain knowledge management protocol: distill rules surfaced in conversation into structured knowledge files following the "heavy on architecture, light on details" principle. Consumers build their own `knowledge/` directory structure as needed.

## Installation (Consumer Repos)

```bash
/plugin marketplace add <repo-url>
/plugin install skill@skill
```

Restart Claude Code. All commands, skills, and `.mcp.json` are loaded.

Upgrade: `/plugin update skill@skill` + restart.

### Manual symlink (fallback)

```bash
ln -sf ~/path/to/skill/commands   /path/to/project/.claude/commands
ln -sf ~/path/to/skill/skills     /path/to/project/.claude/skills
ln -sf ~/path/to/skill/.mcp.json  /path/to/project/.mcp.json
```

## Maintenance

When adding a skill or command:
1. Write the definition in `skills/<name>/SKILL.md` or `commands/<name>.md`
2. Notify consumers to run `/plugin update skill@skill` + restart Claude Code

See `ROADMAP.md` for planned improvements.
