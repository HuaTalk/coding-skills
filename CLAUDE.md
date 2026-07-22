# CLAUDE.md

A reusable Claude Code plugin framework — a collection of skills and MCP configurations.

## Repository Identity

This is not application code. It is a Claude Code plugin template repository. The repo is both a plugin and a marketplace (see `.claude-plugin/plugin.json` and `.claude-plugin/marketplace.json`).

Only two kinds of plugin artifacts:
- `.claude-plugin/{plugin,marketplace}.json` — plugin/marketplace manifests
- `skills/<name>/SKILL.md` — skills

No source code, no build, no tests.

## Design Principles ("Rules Are for You")

Rules describe how the AI should think, not what it should say. A well-designed skill is invisible in output — like a compiler optimization. Three anti-patterns to avoid:
1. **Rule citation** — "Following the team's commit format..." (never surface the rule itself)
2. **Context echo** — "I recall from the architecture docs..." (never reference knowledge sources)
3. **Constraint apology** — "I can't use Mockito because..." (never explain limitations)

### Skill Atomicity

Skills are fully self-contained with zero cross-references. Describe scope boundaries using feature characteristics, not other skill names. Target structure:
1. One-line positioning: what problem I solve
2. Trigger conditions: when to use me (self-describing)
3. Not-applicable scenarios: conditions beyond my boundary (describe conditions, not which skill to use instead)
4. Own process/examples
5. Related resources (optional, only own files/templates)

### Stance vs Protocol

Skills declare their behavioral type in `metadata.category`:
- **Stance** — attitude/behavioral guidelines, no fixed steps (e.g. `explore-legacy`, `unknown-unknowns`, `openspec-explore`)
- **Protocol** — step-by-step workflow with mandatory execution order (e.g. `domain-context`, `best-effort-delivery`, `skill-simplifier`)

### "Heavy Architecture, Light Details"

Domain knowledge capture: write **why** not **what**. If a reader can reconstruct the fact by reading source code once, do not write it down. Architecture-level knowledge takes priority.

## Skill Frontmatter Format

```yaml
---
name: <skill-name>                    # Required. Must match directory name.
description: <trigger description>    # Required. Dispatcher's sole matching surface — deleting one keyword loses a recall category.
argument-hint: "<hint>"              # Optional. Shown as argument prompt.
metadata:
  author: <name>
  version: "<semver>"                 # Quoted string
  category: <methodology|workflow>    # Stance or protocol
  status: <stable|experimental>
  upstream: "<url>"                   # For derived skills
  upstream-note: "<changelog>"        # What changed from upstream
---
```

The `description` field is the dispatcher's sole matching surface. It doubles as the trigger keyword set — typically includes both Chinese and English keywords.

## Skill Sources

1. **Team-maintained** (edit in this repo): `best-effort-delivery`, `domain-context`, `explore-legacy`, `light-explore`, `openspec-explore`, `skill-simplifier`, `unknown-unknowns`, `verification-harness`
2. **Upstream-adapted**: `brainstorming` (from [obra/superpowers](https://github.com/obra/superpowers)). Adapted from upstream with modifications — see skill frontmatter for details.
3. **Consumer-installed**: `lark-*`, `meegle`, `planning-with-files`, and other vendor/community skills are installed by users in their own Claude Code environments. Not shipped here.

## Plugin Manifests

### plugin.json (identity)

Declares the plugin name, version, supported languages, keywords, and repository URL. The `name` field is the plugin identifier used in `skill@skill` install syntax.

### marketplace.json (self-distribution)

Allows the repo to act as its own marketplace. The `plugins` array declares available plugins with `"source": "./"` pointing to the repo root.

## Installation (Consumer Repos)

```bash
/plugin marketplace add <repo-url>
/plugin install skill@skill
```

Restart Claude Code. All skills and `.mcp.json` are loaded.

Upgrade: `/plugin update skill@skill` + restart.

### install.sh (script-based)

```bash
./install.sh --target /path/to/project [--skills domain-context,verification-harness]
```

Auto-discovers all skills from `skills/*/SKILL.md` and creates symlinks into the target's `.claude/skills/`.

### Manual symlink (fallback)

```bash
ln -sf ~/path/to/skills/skills     /path/to/project/.claude/skills
ln -sf ~/path/to/skills/.mcp.json  /path/to/project/.mcp.json
```

## Domain Knowledge Capture

The `domain-context` skill provides a general-purpose domain knowledge management protocol: distill rules surfaced in conversation into structured knowledge files following the "heavy on architecture, light on details" principle. Consumers build their own `knowledge/` directory structure as needed.

## MCP Configuration

`.mcp.json` ships an `intellij-index` MCP server for IntelliJ IDEA code intelligence, listening on `http://127.0.0.1:29170/index-mcp/streamable-http`.

## Maintenance

When adding a skill:
1. Write the definition in `skills/<name>/SKILL.md`
2. Ensure frontmatter has required fields (`name`, `description`)
3. Run `./scripts/check.sh`
4. Notify consumers to run `/plugin update skill@skill` + restart Claude Code

The checks require Bash, Git, and `jq`; on macOS, install `jq` with `brew install jq` when needed.

For a release, update `.claude-plugin/plugin.json` and `CHANGELOG.md`, then create a `v<version>` tag. The tag workflow rejects a mismatched version.

See `ROADMAP.md` for planned improvements.
