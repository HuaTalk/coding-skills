---
name: verification-harness
description: Run a post-implementation acceptance pipeline for non-trivial changes: detect project commands, build, lint and type-check, run unit/integration/E2E/architecture tests, dispatch a read-only adversarial reviewer for bugs and functional drift, and return a structured PASS, FAIL, or PARTIAL verdict. Triggers: verify, review changes, run tests, validate implementation, acceptance check, check changes.
metadata:
  author: HuaTalk
  version: "1.0.1"
  category: workflow
  status: stable
---

# Verification Harness

Run this acceptance pipeline after implementation and before claiming completion. It verifies that the change works; it is not a prose-only code review.

## Activation

Use it when:
- An agent completes a non-trivial change, such as edits across three or more files, a backend/API change, or infrastructure work.
- The user asks to verify, review changes, run tests, validate the implementation, or perform acceptance checks.
- An autonomous prompt-to-merge flow finishes implementation.

Scale it down when:

| Case | Action |
|------|--------|
| One- or two-line change in one file | Run the relevant project test directly. |
| Documentation or comment-only change | Skip tests; run the applicable linter or document checker. |
| User explicitly declines validation | Respect the request. |

## Pipeline

### Phase 0: Detect the Project

Read project instructions and build manifests before running anything. Determine the project type, commands, runtime dependencies, and monorepo boundaries using [project-detection.md](references/project-detection.md).

Project-defined commands in `CLAUDE.md`, `AGENTS.md`, a `Makefile`, or package scripts take precedence over defaults.

### Phase 1: Runtime Dependencies and Build

1. Run the detected `RUNTIME_DEPS`, if any.
2. Run `BUILD_CMD`, if configured.
3. A failed dependency setup or build produces `FAIL` and stops later phases for that project.

### Phase 2: Lint and Type-Check

1. Run `LINT_CMD`, if configured.
2. If it fails and a safe fix mode exists, run the fix once and rerun the linter.
3. Syntax or import failures are blocking. Style-only warnings are recorded as `WARN` and do not block later phases.
4. Run `TYPE_CHECK_CMD`, if configured. Type errors are blocking.

Prefer linters that emit actionable fixes. A line number and rule code alone are insufficient for autonomous repair.

### Phase 3: Unit Tests

Run `TEST_CMD`. Record passed, failed, skipped, warning, and duration counts when available. Any test failure produces `FAIL`.

Tests are context, not conclusive evidence. Passing tests do not replace the independent checks below.

### Phase 4: Integration, E2E, Snapshots, and Architecture

Run each configured command independently:
- Integration and E2E tests.
- Snapshot tests that detect response or rendering drift.
- `ARCH_TEST_CMD` for module boundaries and dependency rules.

Use `SKIP` when a command is not configured or does not apply. Do not claim that an absent check passed.

### Phase 5: Adversarial Review

Dispatch a read-only reviewer using the complete prompt in [reviewer-prompt.md](references/reviewer-prompt.md). Provide the original task, changed files, implementation approach, and authoritative test commands.

The reviewer must run relevant checks, attempt to break the implementation, and end with exactly one machine-readable verdict:

```text
VERDICT: PASS
VERDICT: FAIL
VERDICT: PARTIAL
```

`PARTIAL` is only for environmental limits such as a missing test framework, unavailable tool, or server that cannot start.

## Verdict Handling

| Verdict | Main-agent action |
|---------|-------------------|
| `PASS` | Rerun two or three reviewer commands and confirm their outputs. |
| `FAIL` | Fix the reported issue, then dispatch a fresh reviewer against the updated files. |
| `PARTIAL` | Report what passed, what remains unverified, and the environmental reason. |

Repeat `FAIL -> fix -> reverify` at most three times. After the third failed cycle, stop and ask the user for direction. Do not retry the same failed approach unchanged.

## Stage Output

Phases 1-4 each emit:

```text
STATUS: PASS | FAIL | SKIP | WARN
SUMMARY: <one-line result>
DETAILS: <structured counts or reason>
```

The final report must distinguish every configured and skipped layer and end with `VERDICT: PASS | FAIL | PARTIAL`. Use the exact templates in [report-formats.md](references/report-formats.md).

For a monorepo, run Phases 1-4 independently per changed project. A failure in one project does not prevent checks in other projects. Run Phase 5 only for changed projects, report each project separately, and aggregate the verdict; any project failure makes the aggregate verdict `FAIL`.

## Non-Negotiable Rules

- Never accept "the code looks correct" as verification; run observable checks.
- Keep the adversarial reviewer read-only. It may write temporary scripts only under `/tmp` or `$TMPDIR`.
- Every reviewer `PASS` requires the exact command and observed output.
- Check the last 20 percent: boundaries, error handling, persistence, concurrency, and functional drift where applicable.
- Record `Expected` versus `Actual` for every failure.
- Never report an unavailable or skipped check as passed.
