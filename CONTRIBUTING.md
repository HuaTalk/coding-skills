# Contributing

This repository packages Claude Code skills. Contributions should stay focused on a skill's trigger behavior, workflow, safety boundary, or the plugin's distribution contract.

## Before You Start

- Create a branch from `main` with a focused name such as `feat/<topic>` or `fix/<topic>`.
- Read [CLAUDE.md](./CLAUDE.md) for the repository's design rules.
- Keep unrelated local files, planning notes, and symlinks out of the commit.

## Adding or Updating a Skill

1. Put the canonical definition at `skills/<name>/SKILL.md`.
2. Keep the directory name and frontmatter `name` identical.
3. Include a clear `description` with both the capability and realistic trigger phrases.
4. Keep `metadata.author`, quoted semver `version`, `category`, and `status` current.
5. Write maintained content in English. Do not add translated variants such as `SKILL-zh.md`; the historical Chinese snapshot is frozen and does not receive updates.
6. Update the human-facing inventory in `README.md` and `CLAUDE.md` when the shipped inventory changes.

For long examples, templates, or reference material, use a directly linked `references/` or `templates/` file instead of inflating the main skill prompt. Avoid cross-skill name dependencies unless the dependency is a real runtime requirement.

## Verification

Run the repository gate from the project root:

```bash
./scripts/check.sh
```

It validates manifests, skill metadata, documentation inventory, trigger fixtures, release metadata, credential patterns, and the installer smoke test. Install the optional local hook with `pre-commit install` to run the same gate before commits.

The trigger fixtures in `scripts/test-skill-triggers.sh` are intentionally small representative phrases, not a claim about model recall. Update them when a trigger is intentionally changed.

## Safety and Scope

- Never commit API keys, tokens, passwords, cookies, private URLs, or generated credentials.
- Do not add destructive, deployment, messaging, or paid-network behavior without an explicit confirmation gate and documentation of the risk.
- Keep historical ADRs and memory notes labeled as historical when they no longer describe current inventory.
- Keep behavior changes separate from broad prose cleanup so reviewers can evaluate them independently.

## Releases

1. Update `.claude-plugin/plugin.json` with the new semver.
2. Add a matching `## [version]` entry to `CHANGELOG.md`.
3. Run `./scripts/check.sh`.
4. Create the matching `v<version>` tag and push it. The tag workflow rejects mismatches.

Pull requests should explain the user-visible effect, the files changed, and the verification commands run. Maintainers review trigger recall, workflow correctness, safety boundaries, and documentation consistency before merging.
