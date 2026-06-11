---
name: brainstorming
description: "Before implementing a new feature, refactoring a module, or fixing a bug with unclear impact, use dialogue to clarify requirements, current state, constraints, and success criteria first — then propose solutions for the user to decide. Skip for well-defined small changes (single-line bugs, config tweaks, localized changes under 30 lines). 中文触发：方案讨论、需求不明确、评估方案、设计评审、技术选型、你先评估一下。"
metadata:
  upstream: "https://github.com/obra/superpowers"
  upstream-note: "Derived from upstream. Changes: (1) 9-step checklist → 3-step flow (Explore / Present / Build); (2) removed: HARD-GATE, Visual Companion, self-review checklist, process diagram; (3) design doc path: docs/superpowers/specs/ → openspec/changes/; (4) added: skip conditions for trivial changes."
---

# Brainstorming: Ask Before You Build

Turn vague ideas into implementable designs. **Core: ask first, propose options, let the user decide, then build.**

## When to Use / When to Skip

**Use this skill:**
- New features, modules, or components
- Bugs or performance issues with unclear impact/root cause
- Changes touching multiple files/modules
- User's description has ambiguity, missing constraints, or no success criteria

**Skip this skill, just do it:**
- Single-line bug fix (already pinpointed to a specific line)
- Config/copy/constant adjustments
- Localized change under 30 lines with clear intent
- User already provided a clear spec or specific patch

When unsure, **align with one sentence**: "This looks straightforward — want to brainstorm first or just do it?" Let the user decide.

## Flow (3 Steps)

### 1. Explore Requirements

- First, understand the current state: relevant files, recent commits, existing docs
- Ask one question at a time, prefer multiple-choice, covering: **purpose / constraints / success criteria / blast radius**
- If the ask spans multiple independent subsystems, help the user decompose and brainstorm each separately
- In existing codebases, understand actual current behavior before proposing changes — don't design from assumptions

### 2. Present 2-3 Options + Recommendation

- List options, state tradeoffs, give recommendation with rationale
- Don't give only one option; don't exceed 3 (choice paralysis)
- Options must be concrete (which files, what to introduce, how it fits with existing code), not abstract descriptions

### 3. User Decides → Build / Capture

- After user approves: **simple changes → implement directly**
- Larger changes (multi-module, new module, production-impacting): capture the design to `openspec/changes/<change-id>/proposal.md` via the OpenSpec workflow
- Design docs should include: background/goals, current state, proposal, impact, rollback toggle (if applicable)

## Anti-patterns

- ❌ **Proposing solutions before understanding** — designing from guesses leads to rework
- ❌ **Only one option** — no choice = no tradeoff analysis
- ❌ **Options stuck at abstraction level like "refactor module X"** — must be concrete enough to visualize in code
- ❌ **Running full process for trivial changes** — this skill has built-in skip conditions; don't process-worship
- ❌ **"You're absolutely right!" social validation** — respond with technical substance, not social agreement

## Key Principles

- One question at a time, prefer multiple-choice
- YAGNI: cut non-essential features from the design
- In existing codebases, follow existing patterns; only improve incidentally related things if directly relevant to the task
- Designs should decompose into clear-boundary units (one file, one responsibility) for readability and maintainability
