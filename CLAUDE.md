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

## Current State (2026-06-25)

### i18n Translation — Complete ✅

All 9 team-maintained skills have been translated from English to Chinese:

**Translated Skills:**
- `best-effort-delivery` — SKILL.md + SKILL-zh.md
- `brainstorming` — SKILL.md + SKILL-zh.md
- `domain-context` — SKILL.md + SKILL-zh.md
- `explore-legacy` — SKILL.md + SKILL-zh.md
- `handoff` — SKILL.md + SKILL-zh.md
- `light-explore` — SKILL.md + SKILL-zh.md
- `openspec-explore` — SKILL.md + SKILL-zh.md
- `skill-simplifier` — SKILL.md + SKILL-zh.md
- `unknown-unknowns` — SKILL.md + SKILL-zh.md

**Convention:**
- `SKILL.md` — English (loaded by dispatcher)
- `SKILL-zh.md` — Chinese variant (for local testing)

**Verification:** All 18 files (9 EN + 9 ZH) updated consistently.

### Skill Atomicity Improvement — Complete

All 6 team-maintained skills have been refactored to be fully self-contained with zero cross-references:

**Refactored Skills:**
- `best-effort-delivery` — Removed 3 cross-references, added self-describing patterns
- `light-explore` — Removed comparison references, added scope boundaries
- `unknown-unknowns` — Removed 5-skill relationship table, added self-describing boundaries
- `explore-legacy` — Replaced skill name references with feature descriptions
- `skill-simplifier` — Replaced all 4 skill name references with type descriptions
- `domain-context` — Renamed "Boundaries with Other Skills" to "Scope Boundaries"

**Verification Results:**
- ✅ All `[[wiki-link]]` cross-references eliminated (6 EN + 6 ZH files)
- ✅ All backtick-name explicit references eliminated
- ✅ Generic `[[other-skill]]` patterns preserved (non-specific)
- ✅ 3 already-atomic skills (brainstorming, handoff, openspec-explore) untouched
- ✅ Total: 12 files modified (6 SKILL.md + 6 SKILL-zh.md)

**Key Insight:**
Skills should describe their scope boundaries using feature characteristics rather than naming other skills. This enables independent evolution without cascading updates.
