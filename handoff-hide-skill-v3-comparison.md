# Handoff: /hide Skill v0.1.0 vs v0.4.0 Comparison Analysis

## Context

Compared `skills/hide/SKILL.md` (v0.1.0, current production) against `skills/hide/skill-v3.md` (v0.4.0 candidate). Iteration-1 evals confirmed v0.1.0 passes 100% (36/36 expectations across 5 test cases). The key differentiator is eval 4 (thought-process HITL): with-skill passes 4/4, baseline passes 1/4.

Automated eval runner cannot be used — `run_eval.py` had 0% recall with third-party models (stream-json detection incompatibility). Analysis is manual.

## Version Progression

| Version | File | Key Changes |
|---------|------|-------------|
| v0.1.0 | `SKILL.md` (~78 lines) | 8 flat categories, keyword-driven, no execution order |
| v0.2.0 | `skill-v1.md` | + pattern WHY principles, + execution order (Step 0-4), 5 patterns (S/R/C/A/T) |
| v0.3.0 | `skill-v2.md` | + HITL quantitative threshold (<20%), + silent execution 3-level failure WHY |
| v0.4.0 | `skill-v3.md` (~175 lines) | 5→4 merged categories (S/R/A/D), Chinese/English separate table columns |

## v3 Regression Risks

### Medium: Over-stripping internal URLs (Eval 3)
v3 Step 2 "Zero Tolerance" + "When in doubt, strip it" for Category S, combined with explicit ".internal.example.com" example. Risk: non-sensitive internal URLs (grafana.internal.example.com, pagerduty.internal.example.com) get stripped alongside secrets. v0.1.0's Secret pattern is softer and correctly keeps these.

### Low: Merged category granularity loss
D (Derivation Trail) merges security-adjacent Constraint Apology with research-oriented Thought Process. Model loses specific hooks from 8→4 categories. TBD if this matters in practice.

### Low: Length tax
175 vs 78 lines. v0.1.0 already adds ~30s overhead (65s vs 35s baseline). v3's extra length may add more.

### Low: Execution order rigidity
Step 1 (HITL) gates Step 2 (Secrets). Edge case: file with both credentials AND thought-process structure gets deleted instead of stripped. Defensible but worth noting.

## v3 Improvements Over v0.1.0

- Principle-driven: model generalizes beyond keyword matching
- Execution order: gated Step 0-4 flow prevents skipping critical checks
- Quantitative HITL threshold (<20%): replaces fuzzy "majority"
- Step 4 Verify: structural integrity check after stripping
- 3-level silence WHY: model understands silence purpose, not just rules
- Anti-pattern guidance: "when in doubt" rules reduce classification debates
- Explicit overlap handling: "When content fits two categories, strip it"

## Recommendation

**Path A (preferred): Ship v2 (`skill-v2.md`, v0.3.0).** Keeps 5 granular patterns (S/R/C/A/T) with all structural improvements (principles, execution order, quantitative HITL, silence WHY) but avoids v3's category merge risk and internal URL over-stripping risk.

**Path B: Fix v3.** Clarify Category S boundary: "Internal infrastructure hostnames alone are NOT secrets — strip only when paired with credentials. Dashboard/monitoring URLs are NOT secrets." Then re-test eval 3.

## Files

### In this branch
- `skills/hide/SKILL.md` — v0.1.0 (current production, with updated trigger description)
- `skills/hide/SKILL-zh.md` — Chinese variant
- `skills/hide/skill-v1.md` — v0.2.0 candidate
- `skills/hide/skill-v2.md` — v0.3.0 candidate
- `skills/hide/skill-v3.md` — v0.4.0 candidate
- `skills/hide/evals/evals.json` — 5 test cases + assertions
- `skills/hide/evals/fixtures/` — test fixture files
- `skills/hide-workspace/` — iteration-1 eval results, benchmark, review.html
- `docs/hide-skill-design/` — frozen design artifacts (findings, task_plan, progress)
- `ROADMAP.md` — updated with #6 hide skill entry
- `README.md`, `README-zh.md` — updated

### Do not touch
- `docs/hide-skill-design/*` — frozen artifacts
- `skills/hide-workspace/skill-snapshot/` — frozen v0.1.0 snapshot

## Next Session

1. Decide Path A vs Path B
2. If Path A: promote `skill-v2.md` → `SKILL.md`, run eval loop
3. If Path B: fix v3 Category S boundary, then promote and eval
4. Delete unused version files after decision
5. Update `SKILL-zh.md` to match final version

## Original Handoff Reference

See `/var/folders/r6/nrx4y4ns4vx5d_5bgcpnf9jh0000gr/T/handoff-hide-skill-v3-comparison.md` for the input handoff that initiated this analysis.
