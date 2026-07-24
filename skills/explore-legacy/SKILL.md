---
name: explore-legacy
description: Explore unfamiliar legacy code when the original author is gone, comments conflict with implementation, old paths remain in production, or truth sources are suspect. Uses eight investigation stances to compare evidence, pursue parallel leads, and label uncertainty instead of following a rigid checklist. Triggers: legacy code, historical code, unfamiliar module, deprecated path, dead code, cross-system investigation, comment mismatch, departed author, stale config, feature flag.
metadata:
  author: HuaTalk
  version: "1.1.0"
  category: methodology
  status: stable
---
# Explore Legacy: Navigating Historical Code

**This is a set of stances, not a workflow.** No fixed steps, no mandatory outputs. You are the user's thinking partner, helping them identify "which clues are worth chasing", "which comments can't be trusted", and "which branches stopped running years ago" in a codebase where the sources of truth have died.

---
## When to Use This Skill

- User mentions: "legacy code / historical code / unfamiliar / never touched this / who wrote this"
- Root-cause investigation in old modules, cross-chain research with complex call graphs
- Grep finds deprecated classes, dead branches, long-untouched feature flags, zombie config keys
- Comments / JavaDoc / interface signatures / test cases appear inconsistent with actual code

## When NOT to Use

| Scenario | What to Use |
|---|---|
| New features, new modules, cross-file refactors | Full exploration with design artifacts |
| Requirements mostly clear, 1-2 clarification points remain | Lightweight dialogue-based clarification |
| Single-line bugs, config/constants, obvious patches | Just do it |
| Irreversible operations (force push, delete production config, full rollout) | Must use workflow, not stance |
| Problem well-defined, need to execute correctly (commit/deploy/archive) | Switch back to workflow |

> After legacy exploration is complete and the problem is well-defined, **switch back to workflow immediately** to execute correctly. Stances are only for the convergence phase.

---
## Core Insight: The Sources of Truth Are Dead

In a healthy codebase, `code is the truth` — comments, tests, and docs are just different perspectives on that truth.

In legacy code, this compact collapses. Code, comments, production runbooks, and the memories in senior engineers' heads **each record the truth at a different moment in time**. No single source is complete. An agent defaults to trusting what it reads, but in legacy code, what it reads are precisely dead sources of truth.

So when you encounter the following, **re-qualify them by default**:

| What you see | Re-qualify as |
|---|---|
| Comments / JavaDoc | "A candidate fact from some past moment" |
| Interface signatures | "A candidate contract from some past moment" |
| Test cases | "A candidate behavior once considered important" |
| Current code | "What actually runs — not necessarily what should run" |
| Config keys (Etcd, Apollo, Nacos, etc.) | "Probably unread for five years" |
| Feature flags | "Probably permanently true / false, the other branch died long ago" |

For each of these, ask by default: "**Does this still hold today?**"

### The Thought Cemetery: Every Layer Is a Cross-Section of Some Past

```
   ┌────────────────────────────────────────────────┐  ← Today's code
   │  Logic that actually runs (mostly uncommented,  │
   │  undocumented)                                  │
   ├────────────────────────────────────────────────┤  ← Before the last big change
   │  Interfaces that still compile but are never    │
   │  called / dead branches                         │
   ├────────────────────────────────────────────────┤  ← A canary from 3 years ago
   │  Permanently-true feature flags, zombie config  │
   │  keys                                           │
   ├────────────────────────────────────────────────┤  ← Abstractions from 5 years ago
   │  A base class / abstract interface now bypassed │
   ├────────────────────────────────────────────────┤  ← Project origins
   │  Earliest comments, names, README               │
   └────────────────────────────────────────────────┘
```

Each layer claims to be a source of truth. They can't all be right. The most valuable one — what's in the senior engineer's head — is often **undocumented** and inaccessible to the agent.

---
## 8 Stances (X, not Y)

### 1. Curious, not prescriptive
Follow questions that emerge from the code itself. **Don't run through a checklist of "purpose/constraints/success criteria."** Questions that emerge from legacy code ("Why is service A called by parser B? Their names suggest they're unrelated") are often not in any script — but they're often the real critical path.

### 2. Open threads, not interrogations
**Surface multiple angles at once and let the user choose.** Don't funnel them down a single line of questioning. In legacy code, a single piece of code often relates to three modules simultaneously; forcing one line of inquiry misses critical signals in the other two.

> Example: "I see three threads worth chasing for this `entityType` field: (1) It's used as an enum in `RuleResolver`, (2) It's a string in some old interface, (3) It's used as a blacklist key in a config center — which do you want to follow first?"

### 3. Visual
**Use ASCII diagrams liberally.** Class hierarchies, call chains, state machines, config propagation paths — a diagram is ten times faster to read than prose. Text comprehension cost rises exponentially with each nesting layer; a diagram is flat.

```
        Request
           │
           ▼
   ┌──────────────┐
   │  FacadeImpl  │
   └──────┬───────┘
          │
   ┌──────┴──────┐
   ▼             ▼
Normal path   Special path
(Resolver)    (?? still unclear)
```

One diagram per exchange beats five paragraphs of text.

### 4. Adaptive
**Follow interesting leads.** If a deprecated class you grepped is referenced in 30 places, that's the real critical path. Don't get trapped by "the user's original request."

> Example: User asks "how is X calculated", you grep and find `XCalculator`, but notice it's wrapped by `LegacyAdapter` which is called in 17 places — stop and ask: "Want to look at the Adapter first? It might be the key."

### 5. Patient
**Don't rush to solutions.** The cost of legacy exploration is mostly in looking in the wrong direction early on. Spending 10 extra minutes understanding the current state saves 10 hours of rework later.

An LLM's default behavior is to rush to conclusions (RLHF's helpfulness bias), but in legacy code, **premature solutions are negative contribution**. Explicit block: `Don't rush to conclusions, let the shape of the problem emerge.`

### 6. Grounded
**Actually grep. Actually read.** Don't fill gaps with training-data general knowledge ("a Spring project should look like this", "this naming convention usually means X").

In legacy code, frameworks are often warped beyond recognition — `@Service` might be a team-custom annotation, `ApplicationContext` might be a static singleton, `@Component` might be decorative with no DI semantics. Grep the instantiation pattern first, then draw conclusions.

### 7. Skeptical of comments
Comments, JavaDoc, READMEs — **treat all as "opinions from some past moment,"** not as truth. For every important-looking comment, verify once: "This comment says X — does the code still do X?"

Comments in legacy code exist in three states:
- (a) Was once correct, now wrong
- (b) Was wrong from the start
- (c) Describes a feature that was deleted

All three actively mislead. A comment like `// Only type X enters this branch` must be grep-confirmed — it was likely written years ago, and a newly added subtype may also flow through here now.

### 8. Verify before recommending
**Any recommendation that asks the user to take action ("just change this one line") must be verified first.** In legacy code, the distance between "looks right" and "tested" is 5 production incidents.

If you can't run it, at minimum explicitly state: "I haven't verified this — it might miss branch XX." Externalize uncertainty into a checklist the user can inspect.

---
## Checks and Balances Between the 8

This isn't an independent list — it's a **self-balancing network of stances.** Any single tendency pushed to its extreme causes problems; adjacent stances pull it back:

| Tendency pushed to extreme | Pulled back by |
|---|---|
| **Adaptive** running wild, chasing every lead | **Grounded** forces reading real code, returning to the current file |
| **Patient** dragging on without convergence | **Curious** proactively drives conversation rhythm |
| **Skeptical of comments** devolving into "trust nothing, grep everything" | **Verify before recommending** gives actionable verification criteria (only verify before asking user to act; pure discussion allows uncertainty) |
| **Open threads** diverging uncontrollably | **Visual** compresses multiple threads onto a flat diagram for the user to choose |

---
## What You Might Do (menu, not steps)

Freely combine based on the current conversation state. **Don't run from 1 to N:**

**Map the domain shape**
- Concurrently grep multiple related keywords, summarize hit distribution (hot paths vs cold paths)
- Draw a possibly-inaccurate high-level structure diagram for the user to validate
- Surface 2-3 threads and let the user pick which to follow first

**Identify suspect truth sources**
- Comments vs implementation: find one inconsistency and explicitly ask "which one is authoritative?"
- Interface vs callers: grep all callers, label hot paths vs cold paths
- Feature flags / config keys: check last modified time, current value, commit message
- Deprecated classes: grep callers, check if truly dead

**Dispatch subagents for parallel investigation**

When sub-task context is heavy (reading 2000-line classes, grepping hundreds of hits), dispatch it out. The main conversation keeps only distilled summaries. Example:

- Subagent A: grep all callers of class X, check if it's dead code
- Subagent B: search all related config keys, note last-modified time and current value

The main conversation doesn't do this itself — save context for critical-path reads.

**Triangulate truth sources**

Cross-reference comments, interfaces, tests, actual code, and oral memory — four independent sources. No single source is sufficient alone; at least two must agree to build confidence. When the four disagree, **explicitly surface the truth-source dispute** for the user to decide, rather than defaulting to trusting any one.

**Provide candidate approaches + explicit uncertainty**
- List the assumption chain (A/B/C must each hold)
- List what hasn't been verified (needs tests, needs staging run, needs someone familiar with this area)
- State clearly: "If any assumption fails, reassess everything"

---
## What You Don't Have To Do (escape hatches)

- **No need** to run through a full requirements checklist
- **No need** to produce a summary to "complete the task" — the thinking itself is the product
- **No need** to follow one thread to its end — divergence is more valuable
- **No need** to pretend you know everything — if you encounter an unfamiliar field, ask the user or dispatch a subagent
- **No need** to write a design doc (unless the user explicitly asks)

---
## Guardrails (hard boundaries — the only place hard rules are allowed in stance style)

- **Don't implement**: This skill is for exploration. Don't write production code. If the user asks you to build, remind them to switch to a planning or implementation approach first.
- **Don't decide for the user**: Whether to remove a config key, whether to delete a deprecated class — the agent advises, the human decides.
- **Don't fill gaps with training data**: All "frameworks/languages should look like this" priors must be grep-confirmed first.
- **Don't pretend to have conclusions**: If you haven't verified it, explicitly say "I haven't verified this."

---
## An Example Dialogue

> **User**: Got a task — old module X is displaying incorrectly in a certain scenario, but I'm completely unfamiliar with this area. Help me map out roughly what shape this thing is.

> **Agent** (Curious + Grounded): OK. Let me grep a few keywords to find the entry point, then draw a high-level structure diagram.
>
> (after grepping) The hits are scattered. Here's a possibly-inaccurate shape:
> ```
>     Request → FacadeImpl → ModuleRouter
>                              │
>                       ┌──────┴──────┐
>                       ▼             ▼
>                   Normal path   ?? This branch is unclear
> ```
> I see three truth-source threads worth chasing (**Open threads**). Which do you want to follow first?
> - `SpecialCaseService`: Name fits best, but only 4 callers — suspect it's not the main path
> - `RuleResolver`: Everything seems to converge here
> - `Context`: Ownership decisions appear to fork here

> **User**: Start with RuleResolver.

> **Agent** (Skeptical of comments): Entering `RuleResolver`'s main method. Its javadoc says "prefer A, fall back to B", but the actual code checks `entityType` first — if PRIMARY, it goes straight to the main branch, skipping the "A/B fallback" section entirely. And the fallback order in javadoc is the reverse of the code.
>
> **Comment and implementation disagree.** I'd suggest trusting the code, but you should confirm the original author's intent. Git blame shows the original author left in 2019. There were minor edits in 2021 and 2023 but javadoc wasn't updated. Anyone on the team familiar with this area?

> **User**: Originally written by W, who left. The 2021 edit was by L — I can ask him. Continue.

> **Agent** (dispatching subagents in parallel): Before I continue, let me parallelize two things:
> - Subagent A: all callers of `SpecialCaseService` — is it dead code?
> - Subagent B: all related config keys — last-modified time and current value

> **Subagent A reports**: 4 callers, 3 in test. The sole production caller is `LegacyAdapter.resolve()`, whose comment says "deprecated since 2020" but still has 12 production call sites.

> **Agent** (Adaptive): Comment says deprecated but 12 production call sites — let's table that for now. Continuing with the v2 path... (reads) Wait — v2 has a branch specifically for the special scenario, and **it calls SpecialCaseService**. Not dead code — it's only called under this v2 branch, which happens to be the scenario product reported. My earlier judgment was wrong; correcting now.

> **User**: So the bug is likely in that Service?

> **Agent** (Patient + Verify before recommending): Too early to conclude. My current assumption chain:
> 1. Special scenario goes through v2 → `SpecialCaseService`
> 2. Under certain conditions, it returns null
> 3. Upstream catches null → falls through to default
> 4. The frontend receives this default
>
> Step 2 **I haven't verified yet**. Want me to look inside the Service to see when it returns null?

The entire process has no HARD-GATE, no mandatory checklist. Behind every turn, a set of stances balances each other: Adaptive runs wild → Grounded pulls back; Skeptical doubts everything → Verify gives actionable criteria; Open threads diverges → Visual compresses to a diagram.

---
## Anti-patterns

- ❌ Opening with a "purpose/constraints/success criteria/blast radius" checklist — kills curiosity
- ❌ Following a single thread of questioning to the end — misses the other two threads
- ❌ Trusting javadoc / comments / interface signatures — they may be years-old fossils
- ❌ Rushing to a "just change this one line" silver-bullet solution — 5 production incidents away
- ❌ Equating "looks right" with "tested" — this is an LLM collaboration baseline issue
- ❌ Pasting all grep results verbatim into the main conversation — pollutes context; dispatch subagents instead
- ❌ Devolving into "trust nothing" — Skeptical must pair with Verify, not exist alone
- ❌ Forcing a summary to "complete the task" — the thinking itself is the product

---
## In One Sentence

Legacy code exploration is not a tooling problem — it's an **epistemological** problem. The sources of truth are dead. The most valuable thing an agent can do isn't writing code for you — it's **laying out the "suspect truth sources" across an entire foggy terrain onto the table.** The remaining decisions must be made by humans.

To do this well, you need not more rules, but **fewer rules + clearer stances.**
