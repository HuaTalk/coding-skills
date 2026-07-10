# Skill

A reusable Claude Code plugin framework — package your team's conventions for commands, skills, and MCP configurations so they work across every repo.

Built on the **"Rules Are for You"** philosophy: rules serve the AI's decision-making, never leak into output. A good skill acts like a senior engineer doing the work, not one reading a manual out loud.

This repo is both a Claude Code plugin and a marketplace.

## Quick Start

In any Claude Code project:

```
/plugin marketplace add <repo-url>
/plugin install skill@skill
```

Restart Claude Code. All commands, skills, and `.mcp.json` are now available.

Upgrade: `/plugin update skill@skill` + restart.

## Directory Structure

```
.
├── .claude-plugin/
│   ├── plugin.json         # Plugin manifest
│   └── marketplace.json    # Marketplace manifest
├── commands/               # Slash commands (auto-discovered at plugin root)
├── skills/                 # Skills (auto-discovered at plugin root)
│   ├── best-effort-delivery/   # Best-effort delivery for ambiguous tasks
│   ├── brainstorming/          # Needs clarification before building (from obra/superpowers)
│   ├── domain-context/         # Domain knowledge capture protocol
│   ├── explore-legacy/         # Legacy code exploration
│   ├── handoff/                # Session handoff
│   ├── light-explore/          # Lightweight exploration
│   ├── openspec-explore/       # OpenSpec free exploration
│   ├── skill-simplifier/       # Skill review and simplification
│   └── unknown-unknowns/       # Blind-spot detection
├── .mcp.json               # MCP servers (intellij-index)
├── .claude/
│   └── settings.json       # Self-use permissions (not distributed with plugin)
├── CLAUDE.md               # Project instructions
├── README.md               # This file
├── ROADMAP.md
└── docs/
    └── blog/
        └── blog-rules-are-for-you.md  # Design philosophy
```

> Claude Code plugin spec requires `commands/` and `skills/` at repo root — they can't live under `.claude/`. `.claude/settings.json` is this repo's self-use config and is NOT distributed via `/plugin install`.

## Setup Guide

### Install via Plugin Marketplace

```
/plugin marketplace add <repo-url>
/plugin install skill@skill
```

Restart Claude Code. All skills, commands, and MCP configurations are loaded.

### MCP Server

`.mcp.json` ships `intellij-index` for IntelliJ IDEA code intelligence.

Prerequisites: Install the IDE Index MCP Server plugin in IntelliJ IDEA. Once the IDE is running, the server listens on `127.0.0.1:29170`.

Verify: `lsof -i :29170` shows an `idea` process listening.

### Manual Symlink (Fallback)

```bash
ln -sf ~/path/to/skill/commands  /path/to/project/.claude/commands
ln -sf ~/path/to/skill/skills    /path/to/project/.claude/skills
ln -sf ~/path/to/skill/.mcp.json /path/to/project/.mcp.json
```

### Personal Settings

This repo's `.claude/settings.json` is self-use permission defaults (not distributed with the plugin). Write personal preferences to `.claude/settings.local.json` in your project (gitignored).

## Skill Selection Guide

| Scenario | Skill |
|----------|-------|
| New feature / major refactor / production impact | `brainstorming` |
| 1–2 small decisions to clarify | `light-explore` |
| Unfamiliar legacy code / root-cause investigation | `explore-legacy` |
| Question already implies a solution, but might be misaligned | `unknown-unknowns` |
| Ambiguous task, user wants autonomous execution | `best-effort-delivery` |
| Domain rule capture | `domain-context` |
| Single bug / config change / < 30 lines of clear change | Skip skills, just do it |

## Maintenance

Adding a new skill or command:
1. Write the definition in `skills/<name>/SKILL.md` or `commands/<name>.md`
2. Notify consumers to run `/plugin update skill@skill` + restart

See [ROADMAP.md](./ROADMAP.md) for planned improvements.
