---
name: light-explore
description: Use a lightweight dialogue before small-to-medium changes when requirements are mostly clear and only one or two details remain. Clarify, present options, and decide within one or two rounds without writing a design document. Skip vague work needing full exploration, unfamiliar legacy code, and obvious single-point fixes or configuration changes.
metadata:
  author: HuaTalk
  version: "1.0.0"
  category: workflow
  status: stable
---
# Light Explore

**When:** Requirements are ~80% clear, only 1-2 points need confirmation; or the user has a vague request but it's a small-to-medium change (not worth full exploration).

**Core action:** One or two rounds → no artifacts → decide and go.

## When to Use

- Change is 30-200 lines, touches 1-2 files/classes
- Minor unknowns remain (variable semantics, edge cases, backward compatibility, etc.)
- Requests like "add an X field", "tweak Y logic" — intent is clear but details are ambiguous

## When NOT to Use

- **Vague requirements**: New features, new modules, cross-file refactors, changes affecting production behavior — needs full exploration with design artifacts, not a quick chat
- **Just do it**: Single-line bugs, config/constant changes, obvious patches
- **Formal process needed**: Changes needing formal documentation and team review — escalate to a structured change proposal process

## Flow

1. **Restate the ask in one sentence** + list 1-2 clarification points (max 2; more means escalate to full exploration)
2. After user answers: directly give **one proposal** (small changes don't need 2-3 options), clearly stating **which files, key change points, risks**
3. User approves → go. User disagrees or more ambiguity emerges → escalate to full exploration with design artifacts

## Anti-patterns

- ❌ Running a full 9-step design process — this is a quick chat, not a structured exploration
- ❌ Writing a design doc (light exploration leaves no artifacts)
- ❌ Asking 3+ questions at once (signal to escalate to full exploration)
- ❌ Suggesting "while we're at it, also fix X" unprompted

## Scope Boundaries

- **Lighter than full exploration**: No design docs, single proposal not 2-3 options — one or two rounds to clarify and decide
- **More deliberate than direct action**: At least one round of "restate + clarify + propose" before making changes
- **Trigger heuristic**: **Number of unknowns** — 0 = just do it, 1-2 = this skill, 3+ = needs full exploration with design artifacts
