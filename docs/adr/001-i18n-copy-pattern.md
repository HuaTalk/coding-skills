# ADR-001: i18n Copy Pattern for Skill Files

## Status

**Superseded** (2026-07-01). The project no longer maintains Chinese variants. All `SKILL-zh.md`, `CLAUDE-zh.md`, `README-zh.md`, `ROADMAP-zh.md`, and `i18n-switch.sh` have been removed. English is the sole maintained language. This ADR is retained for historical reference.

*Original status: Accepted (2026-06-09)*

## Context

The project supports English (default) and Chinese (zh). Claude Code's dispatcher loads `SKILL.md` directly — there is no built-in language switching mechanism at the plugin level.

We needed a way for consumers to switch the language of all skills, commands, and core files without breaking the dispatcher contract.

## Decision

Use the **copy pattern**: maintain `SKILL.md` (English, default) alongside `SKILL-zh.md` (Chinese variant). To switch:

```bash
cd skills/<skill-name>
cp SKILL-zh.md SKILL.md
```

Same convention applies to `CLAUDE.md` / `CLAUDE-zh.md`, `README.md` / `README-zh.md`, and `commands/*.md` / `commands/*-zh.md`.

## Alternatives Considered

### Symlink

```bash
ln -sf SKILL-zh.md SKILL.md
```

**Rejected** because:
- Not all filesystems support symlinks (network drives, some CI environments)
- ZIP downloads break symlinks
- Windows consumers may not have symlink permissions

### Frontmatter language toggle

```yaml
language: zh
```

**Rejected** because:
- Claude Code dispatcher does not read frontmatter for language selection
- Would require a pre-processing layer (complexity)
- File content would need to contain both languages (bloated)

### Subdirectory per language

```
skills/<name>/en/SKILL.md
skills/<name>/zh/SKILL.md
```

**Rejected** because:
- Claude Code dispatcher expects `SKILL.md` at the skill directory root
- Breaks `/plugin install` auto-discovery

### Copy pattern (chosen)

**Rationale**:
- `cp` is universal across all platforms
- Dispatcher loads `SKILL.md` unchanged — no tooling needed
- Single file per language keeps each variant clean and maintainable
- Explicit action gives consumers clarity about which language is active
- Zero runtime overhead

## Consequences

- **Positive**: Simple, universal, zero magic. Works with plugin install and symlink fallback.
- **Positive**: Language variants are full standalone files — can be reviewed, edited, and diffed independently.
- **Negative**: Manual switch — no auto-detection of user's preferred language.
- **Negative**: Risk of drift between `SKILL.md` and `SKILL-zh.md` if updates are only applied to one variant.
- **Mitigation**: Planned `scripts/i18n-check.sh` will verify that every `SKILL.md` has a corresponding `SKILL-zh.md` and flag frontmatter mismatches.

## References

- ROADMAP.md #1 (CI checks) — will include i18n pair validation
- CLAUDE.md — Internationalization section documents the convention for consumers
