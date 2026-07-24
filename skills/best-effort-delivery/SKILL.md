---
name: best-effort-delivery
description: For ambiguous or broad tasks, proceed without interrupting the user: implement high-confidence items directly and collect low-confidence decisions in an interactive HTML document for later confirmation. Triggers: best effort, don't ask me, proceed autonomously, unattended, just do what you can.
metadata:
  author: HuaTalk
  version: "1.0.1"
  category: workflow
  status: stable
---
# Best-Effort Delivery

## When to Use

The user explicitly signals:
- "Don't ask me", "don't ask if unsure", "autonomous", "do what you can first".
- Task scope is large but they want a single push (unwilling to be interrupted by multiple AskUserQuestion rounds).
- User is away / async, wants to review once at the end.

Not applicable:
- Destructive operations (delete data, force-push to master, send messages, close PRs) — these always require confirmation.
- Tiny tasks answerable in 1-2 questions — asking directly is faster than running this protocol.

## Core Contract: The Bifurcation

All output is forcibly split into exactly two tiers — no third option:

| Tier | Landing Form | Criteria |
|------|-------------|----------|
| **High-confidence** | Edit / Write directly into source-of-truth files | 1) Clear evidence from code/docs/existing rules; 2) Even if wrong, can be quickly caught and reverted next round |
| **Low-confidence** | Append to **interactive HTML pending-confirmation doc** | 1) Requires business judgment; 2) Multiple reasonable interpretations exist; 3) Changes to TL;DR / API contracts / naming conventions (hard to revert) |

**Judgment principle**:
- When unsure, **default to low-confidence**. This skill's goal is to avoid bothering the user, not to take risks on their behalf.
- Every high-confidence edit must survive a one-sentence test: "Why am I certain this is correct?" Can't answer → low-confidence.

## Execution Protocol

### Step 1 — Decompose
Break the user's goal into the smallest units that can independently have confidence assessed. One unit per line, tagged `[H]` / `[L]` as a preliminary assessment.

### Step 2 — Gather Evidence (subagent-friendly)
For each unit, decide the evidence-gathering method:
- Cross-file search / broad grep → **dispatch Explore subagents** in parallel.
- Single-point confirmation → direct grep/Read.
- User-provided materials → Read and archive into evidence list.

When dispatching subagents in parallel, use multiple Agent calls in one message with self-contained prompts.

### Step 3 — Land by Tier

**High-confidence units**:
- Edit / Write directly into source-of-truth files.
- Follow the target file's existing writing discipline (e.g., for domain knowledge files: write why not what, architecture over details — anything reconstructable from source code doesn't need to be persisted).
- For each edit, mentally note "evidence is X" and report in the final summary.

**Low-confidence units**:
- Append to an HTML file in the OS temp directory (**never inside the repo**, to avoid git tracking):
  - macOS / Linux: `$TMPDIR/pending-confirm-<topic>-<YYYYMMDD>.html`
  - Fallback: `mktemp -t pending-confirm-<topic>` for the full path
  - Output is transient inter-session media, not version-controlled — the temp file can be handed off to the next session or person
- HTML must be **interactive** (see format below). Use `references/sample.html` as a structural starting point, but rewrite evidence/candidate wording per task.
- Never leave half-finished work / TODOs / placeholders in source-of-truth files. Half-finished goes only into HTML.

### Step 4 — Report
Use this minimal template — no free-form elaboration, no restating what's already in the HTML:

```
✅ High-confidence landed (N items):
- <file:§section> — <one-line evidence, e.g., grep anchor>
- ...

⏸ Low-confidence pending (M items):
→ <absolute path to HTML>

⚠ Deadlocks (k items): <only fill if k>0, explain why neither landed nor went to HTML — usually signals Step 1 decomposition failure, needs redo>
```

Deadlocks should theoretically be 0; any occurrence signals a decomposition failure.

## Interactive HTML Pending-Confirmation Doc Format

Only the **contract** is specified, not CSS / DOM templates — Claude writes the page ad-hoc. Use `references/sample.html` as a starting point (stable structure, contract-aligned), but rewrite evidence/candidate wording per task.

### Must Satisfy
- Each item is a **single-choice question**, not a button group. 2-4 **concrete candidate wordings/solutions** + "Other (write-in)" fallback.
- The **first** candidate per item is marked as **recommended** (visually distinguishable) and **pre-selected** on page load — enabling sub-second "accept all".
- Candidate wordings are **self-contained semantically**: reading the candidate alone should convey the trade-off without referencing evidence. Banned: abstract verbs ("adjust", "reorganize", "rewrite") — must be directly actionable concrete phrasing.
- Each item has its own evidence section (grep anchor + excerpt); user shouldn't need to consult the repo.
- Top "Export" button copies JSON to clipboard in one click. JSON per item includes at minimum `id` / `target` (file+§number) / `choice` / `choiceLabel` / `other` (write-in content).
- Top progress counter (decided N / total M) so the user knows what's left.

### Forbidden
- ❌ Legacy "Accept / Reject / Rewrite" three-button pattern — coarse-grained decisions push work back to the user.
- ❌ No recommended item / no default selection — loses the core "sub-second decision" value.
- ❌ More than 4 candidates (excluding "Other") — choice overload causes users to skip. More than 4 = split into two questions.
- ❌ Empty verbs like "rewrite" in candidates without providing the new wording.
- ❌ Placing "destructive / irreversible" candidates in the recommended slot (e.g., default-recommending "delete the entire section").

## Anti-patterns

- ❌ "I'm unsure, I'll change half and leave a TODO in the source file" — half-finished work never goes into source files, only HTML.
- ❌ "I'm unsure, I'll dump everything into HTML" — high-confidence items not landed in source files = not done. Both sides of the bifurcation require judgment.
- ❌ HTML lists questions without evidence — that's pushing work to the user. Every item must carry `grep anchor + excerpt`.
- ❌ Using AskUserQuestion mid-flow — this skill's core contract is no interruptions; all confirmations go to HTML.
- ❌ Serial subagent dispatch within a single task — cross-file searches must be parallel to save wall-clock time.
- ❌ Classifying "destructive / irreversible operations" as high-confidence. Deletion, renaming, overwriting large existing sections = default low-confidence.

## Scope Boundaries

- **Capture scenarios**: Follow the "write why not what, architecture over details" discipline — anything reconstructable from source code doesn't need to be persisted. Skip interactive confirmation steps; route conflicts to HTML instead.
- **Dialogue-based clarification**: This skill is designed for zero-interaction delivery. When the user is open to clarifying questions, dialogue-based approaches are more appropriate — this skill activates only when the user explicitly signals "don't ask me."
- **Output artifact**: The HTML pending-confirmation doc is transient inter-session media. It can be shared with the next session or person for continued adjudication.
