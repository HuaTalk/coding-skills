# Skill

A reusable Claude Code plugin framework — package your team's conventions as skills and MCP configurations so they work across every repo.

Built on the **"Rules Are for You"** philosophy: rules serve the AI's decision-making, never leak into output. A good skill acts like a senior engineer doing the work, not one reading a manual out loud.

This repo is both a Claude Code plugin and a marketplace.

## Quick Start

In any Claude Code project:

```
/plugin marketplace add <repo-url>
/plugin install skill@skill
```

Restart Claude Code. All skills and `.mcp.json` are now available.

Upgrade: `/plugin update skill@skill` + restart.

## Directory Structure

```
.
├── .claude-plugin/
│   ├── plugin.json         # Plugin manifest
│   └── marketplace.json    # Marketplace manifest
├── .github/
│   └── workflows/check.yml # CI repository checks
├── skills/                 # Skills (auto-discovered at plugin root)
│   ├── domain-context/         # Domain knowledge capture protocol
│   ├── explore-legacy/         # Legacy code exploration
│   ├── light-explore/          # Lightweight exploration
│   ├── prefer-pure-function/   # Pure function and immutability style
│   ├── skill-simplifier/       # Skill review and simplification
│   ├── unknown-unknowns/       # Blind-spot detection
│   └── verification-harness/   # Post-implementation adversarial verification
├── .mcp.json               # MCP servers (intellij-index)
├── .pre-commit-config.yaml # Optional local commit hook
├── CLAUDE.md               # Project instructions
├── CHANGELOG.md            # Release history
├── CONTRIBUTING.md         # Contribution and release workflow
├── scripts/                # Repository checks and trigger fixtures
│   ├── check.sh
│   └── test-skill-triggers.sh
├── README.md               # This file
├── ROADMAP.md
└── docs/
    └── blog/
        └── blog-rules-are-for-you.md  # Design philosophy
```

> Claude Code discovers plugin skills from the root-level `skills/` directory; they cannot live under `.claude/`.

English is the only maintained language. Each skill has one canonical `SKILL.md`; translated variants are not maintained. The last Chinese sources remain available only through the frozen archive documented in [`docs/archive/chinese-snapshot.md`](./docs/archive/chinese-snapshot.md).

## Setup Guide

### Install via Plugin Marketplace

```
/plugin marketplace add <repo-url>
/plugin install skill@skill
```

Restart Claude Code. All skills and MCP configurations are loaded.

### MCP Server

`.mcp.json` ships `intellij-index` for IntelliJ IDEA code intelligence.

Prerequisites: Install the IDE Index MCP Server plugin in IntelliJ IDEA. Once the IDE is running, the server listens on `127.0.0.1:29170`.

Verify: `lsof -i :29170` shows an `idea` process listening.

### Manual Symlink (Fallback)

```bash
ln -sf ~/path/to/skill/skills    /path/to/project/.claude/skills
ln -sf ~/path/to/skill/.mcp.json /path/to/project/.mcp.json
```

## Skill Selection Guide

| Scenario | Skill |
|----------|-------|
| 1–2 small decisions to clarify | `light-explore` |
| Unfamiliar legacy code / root-cause investigation | `explore-legacy` |
| Question already implies a solution, but might be misaligned | `unknown-unknowns` |
| Domain rule capture | `domain-context` |
| Post-implementation verification (tests + review) | `verification-harness` |
| Single bug / config change / < 30 lines of clear change | Skip skills, just do it |

## Maintenance

Adding a new skill:
1. Write the definition in `skills/<name>/SKILL.md`
2. Run `./scripts/check.sh`
3. Notify consumers to run `/plugin update skill@skill` + restart

Install the optional local commit hook with `pre-commit install`. Pull requests and pushes to `main` run the same checks in GitHub Actions, including the English-only maintained-tree policy.

The checks require Bash, Git, and `jq`. On macOS, install the JSON tool with `brew install jq` if it is not already available.

For a release, update `plugin.json` and `CHANGELOG.md`, then create a `v<version>` tag. The tag workflow rejects a tag that does not match the plugin version.

See [ROADMAP.md](./ROADMAP.md) for planned improvements.
See [CONTRIBUTING.md](./CONTRIBUTING.md) before opening a change.
