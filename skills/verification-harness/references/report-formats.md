# Verification Report Formats

Use only checks that apply to the project. Keep every configured or skipped layer visible.

## Single Project

```text
## Acceptance Report

Runtime dependencies: PASS | FAIL | SKIP (<reason>)
Build: PASS | FAIL | SKIP (<reason>)
Lint: PASS | WARN (<count and fixes>) | FAIL | SKIP (<reason>)
Type-check: PASS | FAIL | SKIP (<reason>)
Unit tests: PASS (<passed/skipped>) | FAIL | SKIP (<reason>)
Integration tests: PASS | FAIL | SKIP (<reason>)
E2E tests: PASS | FAIL | SKIP (<reason>)
Snapshot tests: PASS | FAIL | SKIP (<reason>)
Architecture tests: PASS | FAIL | SKIP (<reason>)
Adversarial review: PASS | FAIL | PARTIAL

VERDICT: PASS | FAIL | PARTIAL

Failures:
- <failed check, Expected versus Actual, and repair guidance>
```

## Monorepo

```text
## Acceptance Report (Monorepo)

Summary: N projects, M PASS, K FAIL

### <project>
Build: PASS | FAIL | SKIP
Lint: PASS | WARN | FAIL | SKIP
Unit tests: PASS | FAIL | SKIP
Adversarial review: PASS | FAIL | PARTIAL | SKIP
VERDICT: PASS | FAIL | PARTIAL

Failures:
- <failed check, Expected versus Actual, and repair guidance>

OVERALL VERDICT: PASS | FAIL | PARTIAL
```

Any project `FAIL` makes the overall verdict `FAIL`. Use `PARTIAL` only when environmental limits leave required checks unverified and no observed failure already requires `FAIL`.
