---
name: domain-context
description: Persist domain understanding from a session into `knowledge/domain/<module>.md`. Triggers: persist domain knowledge, capture context, organize session knowledge, update domain docs, add or update domain context.
metadata:
  author: HuaTalk
  version: "2.0.1"
  category: workflow
  status: stable
---
# Persist Domain Understanding into the Knowledge Base

This skill is the **write side** of domain knowledge. The read side handles on-demand loading; the write side ensures new/changed domain rules land correctly in a single source of truth.

## Core Principle: Heavy Architecture, Light Details (Answer Before Writing)

Module files are split into two layers by **drift velocity**:

- **Architecture layer** (long-lived, grep can't replace): system skeleton, cache models, responsibility chains/extension points, cross-cutting concerns (feature flags / AB / canary / metrics / degradation), design intent, implicit conventions, historical pitfalls.
- **Domain layer** (drifts quickly, grep can mostly replace): judgment logic for specific business rules.

**The test for whether a rule deserves to be persisted (must ask before writing)**:

> "If I deleted this, could a reader reconstruct it by reading the source once?" → reconstructable = **don't write**; not reconstructable = write.

**Typical anti-examples (reject on sight)**:
- "`FooService.bar()` takes 3 params, returns `Set<Integer>`" — obvious from the signature, don't write.
- "This enum has 7 values: …" — one Read makes it clear, don't write.
- "At line X it does Y" — line numbers drift daily, don't write; rewrite as "`FooService#bar` does Y" as a grep anchor.

**Worth writing (even if it seems trivial)**:
- "Config changes take 30 minutes to propagate" — implicit convention; missing this introduces bugs.
- "`candidates.get(0)` is the project's default convention" — implicit contract in collection context.
- "type=4 ⇒ status is always ACTIVE_*, so this path skips isValid check" — design intent, essential for understanding the whole chain.

**Architecture-first**: When material fits both architecture and domain layers, default to architecture. Architecture modules have the broadest coverage and highest ROI; creating a new domain module is the last resort.

## When to Trigger

- User says "persist what we just discussed" / "organize as context" / "write it up as docs."
- User provides a handoff / research notes / PR description and says "add this to our context system."
- You discover a domain rule during investigation that **holds across sessions** and is worth persisting.

Do NOT trigger:
- Debugging process for a one-off bug fix.
- Facts already written in code comments / Javadoc that one Read would reveal.
- Temporary state meaningful only within the current task's context.

## Execution Protocol

### Step 1 — Gather Material

Two entry points, mutually exclusive:

**Entry A: Reflect on current session context**
- Do not read external files; only organize domain conclusions already reached in this session.
- Draft rule entries (one sentence each + grep anchor `Class#method` as evidence) for "what I learned this session that holds across sessions."
- Exclude: pure task progress, personal preferences, content already in CLAUDE.md or existing module files.
- **Detail filter**: Run each draft through the "can you reconstruct it by reading the source once?" test from the Core Principle above. Discard reconstructable items.

**Entry B: User-specified files**
- Use Read to load all file paths the user provides (handoffs, research notes, PR diffs, source snippets, etc.).
- Similarly extract into "rule entry + evidence" drafts.
- **Same detail filter**: only extract why, constraints, and pitfalls.

### Step 2 — Match Modules (Architecture First, Then Domain)

Against the project's `knowledge/` directory structure, tag each rule **in this priority order**:

1. **First ask: can this go into the architecture layer?** Anything involving cache windows, responsibility chain stages, extension points, feature flags, canary, monitoring, degradation, or design intent → **default to architecture layer**.
2. If architecture layer can't absorb it, then consider domain layer.

| Candidate Rule Home | Action |
|---|---|
| Hits an existing architecture module | Go to Step 3, prepare to **update** that architecture module |
| Hits an existing domain module | Go to Step 3, prepare to **update** that domain module; also check whether the "why / cache / cross-cutting" parts should be lifted to architecture layer |
| Fits no existing module | Use AskUserQuestion first: confirm whether to create a new module, its name, and whether it's architecture or domain layer |

> **Don't create new domain modules lightly.** Before creating one, ask: can this rule be split into "architecture skeleton + one or two domain pitfalls (into an existing domain module)"? If yes, split it.

### Step 3 — Load Current State and Detect Conflicts

For each existing module file that's been matched, Read it in full, then compare candidate rules **one by one** against the existing content. Conflict types:

1. **Direct contradiction**: Candidate rule says "A is X", existing module says "A is Y".
2. **Unclear coverage relationship**: Candidate rule adds a branch or exception, but existing rules don't say whether it's exclusive or supplementary.
3. **Semantic overlap**: Candidate rule and existing §N cover the same thing with different wording.
4. **Implied obsolescence**: Candidate rule implies an old rule is outdated.
5. **Naming trap collision**: Candidate rule mentions a new name that "looks like" an existing concept — clarify whether it's a new concept or a synonym.

For every conflict or suspected conflict, **do not decide unilaterally** — go to Step 4.

### Step 4 — Human-in-the-Loop Adjudication

Use **AskUserQuestion** to surface conflicts, one question per conflict. Each question must include at minimum:

- Brief conflict description ("Existing §N says X, new material says Y").
- Options (max 4, first is your recommendation):
  - "Overwrite old rule with new rule"
  - "Add new rule as supplement/exception to old rule"
  - "Keep old rule, discard new rule"
  - "Keep both, need to reorganize sections"
- TL;DR line-level conflicts must be explicitly asked; **never** silently overwrite TL;DR.

The only cases where you can **skip** human confirmation and merge directly:
- Pure additive supplement: the candidate rule covers something entirely absent from the existing file, and contradicts nothing.
- Typo / broken link fixes only (must still report these in the final summary).

### Step 5 — Write

#### 5a. Domain-layer files: use template as skeleton

When creating a new domain module, you **must** copy `skills/domain-context/templates/domain-module-template.md` to `knowledge/domain/<module>.md` as the starting point. The template locks in a fixed section structure; if a section doesn't apply, write `N/A — <reason>`. **Do not delete sections.**

#### 5b. Architecture-layer files: keep existing free structure

Architecture modules vary widely; the domain template is **not required**.

#### 5c. Writing requirements (universal)

1. **Write Why, not What**. After every sentence, ask: "Could a reader reconstruct this from the source?" If yes → delete it.
2. **Architecture layer: no line numbers**. Line numbers signal leaked implementation details; rewrite.
3. **Domain layer: grep anchors only**. Write `UserService#findById`, not `UserService.java:560-566`.
4. **TL;DR: constraints and pitfalls only**. Max 30 chars per entry. Never restate API shapes.
5. **Single source of truth**: One rule lives in exactly one module. Cross-module references use `[[link]]`. When architecture and domain layers overlap: **architecture keeps why, domain keeps judgment**.
6. **Never write domain details into CLAUDE.md** — CLAUDE.md only gets a one-line pointer.
7. File size limits: architecture layer ≤ 8KB; domain layer ≤ 5KB. Exceeding means details weren't filtered enough.

### Step 6 — Sync Index

If this was a **new module** or a **module TL;DR changed**, update the project's knowledge index file (if it exists).

### Step 7 — Report

Brief summary (not a document):
1. Which files were created/updated.
2. Which conflicts, how they were adjudicated.
3. Whether the index was synced.
4. Any material "not persisted but worth revisiting" for next time.

Do not git commit unless the user explicitly asks.

## Anti-patterns

- ❌ When reflecting on a session, writing "task progress / user preferences / what I did" as module rules. Module files hold only **domain knowledge**.
- ❌ **Transcribing source snippets, field tables, and line numbers verbatim into module files**. Anything reconstructable from source is never persisted.
- ❌ **Architecture-layer files containing `:line_number` or concrete source blocks**. Architecture layer only describes stages, contracts, and extension points.
- ❌ **Creating a new domain module as the first move for new rules**. Try architecture layer first, then existing domain modules; new domain modules are the last option.
- ❌ Silently merging conflicts. Even if you're "very sure", TL;DR line-level changes must go through AskUserQuestion.
- ❌ Writing domain details into SKILL.md / CLAUDE.md. They can only be **routers** and **global specs**.
- ❌ Creating multiple new modules at once. Max 1 new module per session to avoid index bloat.
- ❌ Writing the same rule into multiple modules simultaneously. Cross-module reuse always uses `[[link]]`.
- ❌ Saving "code snapshots from the moment of writing" as long-term facts.
- ❌ **Deleting core section headings** in domain modules. If not applicable, write `N/A — <reason>`; keep the heading.

## Scope Boundaries

- **Transient vs persistent**: This skill handles **permanently valid domain rules** that hold across sessions. Transient session context (task progress, current findings for the next agent) is a separate concern — both can coexist.
- **Interactive vs autonomous**: This skill's conflict adjudication relies on interactive confirmation (AskUserQuestion). When operating in zero-interaction mode, skip the confirmation step and route conflicts to an external pending-confirmation artifact instead.
