# Roadmap

Future improvements for the open-source Claude Code plugin framework, ordered by expected return on investment.

## #1 - Configurable Domain Context Template

**Problem:** The fixed `domain-context` template suits pipeline-oriented systems but not every team. Consumers cannot currently override `skills/domain-context/templates/domain-module-template.md`.

**Proposed work:**
- Prefer `{project-root}/knowledge/.domain-module-template.md` when present.
- Fall back to `skills/domain-context/templates/domain-module-template.md`.
- Allow section titles to change while preserving the core input, output, and exclusion semantics.

## #2 - Skill Trigger Evaluation

**Current state:** `scripts/test-skill-triggers.sh` locks representative phrases for each skill and runs through `scripts/check.sh` in CI and pre-commit. It detects accidental changes to the dispatcher input surface; it does not simulate model recall.

**Proposed work:**
- Add representative phrases when real usage exposes recall gaps.
- Introduce a dedicated dispatcher evaluation environment only when stronger recall evidence is needed.

## Completed

- ~~CI and pre-commit checks~~: `scripts/check.sh` validates manifests, frontmatter, documentation inventory, release metadata, credential patterns, and the installer; GitHub Actions and pre-commit share the same script.
- ~~Release workflow~~: releases use `v<version>` tags, and CI verifies that each tag matches `plugin.json`.
- ~~Trigger regression fixtures~~: the repository gate enforces 11 representative trigger phrases.
- ~~Contributor guide~~: `CONTRIBUTING.md` documents skill authoring, validation, safety, review, and release rules.
- ~~Parallel i18n copies~~: English is the sole maintained language; the previous Chinese sources are available only as a frozen Git snapshot.
- ~~Cross-skill consistency review~~: the atomicity refactor removed all 19 cross-skill references, eliminating the need for a separate consistency script.
- ~~Skill creation template~~: new skills are rare enough that the authoring rules belong in `CONTRIBUTING.md` rather than another template.
- ~~Installer hardening~~: the plugin marketplace is the primary install path; `install.sh` remains a supported fallback.
