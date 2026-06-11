---
name: skill-simplifier
description: Simplify, shrink, and compress existing Claude Code skill SKILL.md files (including references/ and knowledge/). Identifies redundancy, AI filler phrases, "What" restatements, overly long examples, and domain details that can be pushed down. Follows "measure first, classify, then cut, HITL decides." Only edits existing skills; does not create new ones (that's skill-writer). Triggers: simplify skill, shrink skill, compress skill, SKILL.md too long, skill redundant, refactor skill, condense skill. 中文触发：简化 skill、压缩 skill、精简 SKILL.md、skill 太长了、skill 冗余、瘦身。
---

# skill-simplifier

SKILL.md is a prompt read by an LLM, not a document. Every extra sentence = extra tokens burned on every match. Compress bloated SKILL.md files back to "good enough, then stop."

## When to Use

- User says "this skill is too long / simplify / shrink / compress / condense."
- You read a SKILL.md > 200 lines or with noticeably high redundancy — proactively suggest.
- Routine maintenance: after adding a new §N, total word count balloons — compress it back.

Skip: creating new skills (separate concern); semantic/flow errors → fix directly, not via this skill; skills < 80 lines / < 4KB → default to skip, run Step 1 first.

## Three Skill Types, Three Compression Strategies

Identify which category the target falls into — mismatching will damage the skill:

| Type | Examples | Expected Shape | Compression Direction |
|---|---|---|---|
| Router | A routing-layer skill | frontmatter + loading protocol + module index | Body → `knowledge/`; SKILL.md keeps the routing table |
| Protocol | A step-by-step workflow skill | Step-by-step flow + anti-patterns | Delete What restatements, merge duplicate anti-patterns, push long examples to `references/` |
| Capability | A when-to-use + flow skill | When-to-use + flow + anti-patterns | Delete decorative paragraphs, preserve judgment criteria and boundaries |

Don't compress a protocol into a router (steps are the body, not details). Don't compress a capability into frontmatter-only (flow descriptions are LLM decision inputs).

## Protocol

### Step 1 — Size Assessment

`wc -lc` the target SKILL.md. Check for `references/` / `knowledge/` subdirectories and their sizes. Classify the target. Thresholds (not absolute):

- Router type > 100 lines / > 5KB → body likely not pushed down.
- Protocol type > 250 lines / > 10KB → likely has What restatements or long examples.
- Capability type > 150 lines / > 6KB → likely has decorative paragraphs.

If below thresholds and no obvious redundancy detected → tell the user "already compact enough, not worth simplifying" and stop. **Over-simplification is worse than no simplification.**

### Step 2 — List Candidate Cuts (review only, don't touch)

Scan section by section, tag against this table:

| Signal | Action |
|---|---|
| Same rule repeated three ways | Keep the sharpest one |
| Restates "what this skill does" (What) | Delete — frontmatter `description` already says it |
| Long code / DSL example > 15 lines | Move to `references/<topic>.md`, leave one-line pointer |
| Domain knowledge (business rules, field tables, enum values) | Move to `references/` or `knowledge/`; SKILL.md doesn't carry these |
| Decorative rhetoric, triads, transition-stacking ("first... second... finally", "not only... but also...", "in other words") | Delete |
| em-dash chains > 2 | Rewrite as short sentences |
| Anti-pattern list > 7 items | Merge semantically overlapping ones; usually compressible to 4-5 |
| §N body < 3 lines | Merge into parent § or delete |
| "To help you understand better, let's..." style meta-narration | Delete all |
| Concepts already covered in [[other-skill]] | Replace with link |
| Meta-sections listing "design sources / skills referenced" | Delete — internalize into the protocol itself; the reader doesn't need to know how you arrived at it |

**Red lines (do not touch)**:

1. frontmatter `name` — renaming equals replacing the skill.
2. Trigger keyword set in frontmatter `description` — the dispatcher matches on this; losing keywords = lost recall. Can shorten the description, but trigger words (synonyms in all supported languages) must stay.
3. Cross-skill references `[[other-skill]]` — unless that skill was also renamed.
4. Protocol-type skill's Step 1→N semantic order — the LLM's execution basis; can't merge to save characters.
5. HITL / safety hard constraints ("must AskUserQuestion / never silently overwrite / don't auto-commit") — can abbreviate, cannot delete.

### Step 3 — HITL Decision

The following changes are asked one-by-one via **AskUserQuestion**, never batched:

- frontmatter `description` rewrite: show current vs proposed side-by-side, ask "accept?"
- Deleting an entire §N: list content summary, ask "delete / keep / rewrite."
- New `references/<file>.md` to push content down: list filename + scope of moved content, ask "accept split / keep all / split elsewhere."
- Cross-skill link replacing restatement: list original paragraph + proposed `[[skill]]` reference, ask whether to accept.

Skippable HITL: pure deletion of decorative filler, pure merging of semantically-overlapping anti-patterns, pure compression of verbose prose without semantic change. Report these in Step 6.

### Step 4 — Execute

- Edit SKILL.md. Write new `references/<topic>.md` when needed.
- Don't renumber existing §N (breaks external anchors). If renumbering is unavoidable, list old→new mapping in the report.
- Don't touch `.claude-plugin/` or README — this skill doesn't manage index sync.

### Step 5 — Verify

- `wc -lc` re-measure, note before/after.
- Grep to confirm frontmatter `description` trigger keyword set is intact (synonyms in all supported languages present).
- Grep to confirm `[[other-skill]]` doesn't point to nonexistent skills.
- Read the entire revised SKILL.md — if a human reads it without stumbling = not over-compressed.

### Step 6 — Report

Brief summary (not a document):
1. Which files changed, new references created, what was deleted.
2. Before/after line count + byte count.
3. HITL points asked, user's decisions.
4. Items merged without HITL, by category.
5. Reminder: plugin cache requires `/plugin update skill@skill` + restart Claude Code to take effect.

Do not git commit unless the user explicitly asks.

## Anti-patterns

- ❌ Compressing without classifying. Compressing a protocol to frontmatter-only loses flow steps; on recall, the LLM has no protocol to follow.
- ❌ Deleting trigger keywords for brevity. `description` is the dispatcher's matching surface; losing one keyword = losing one recall class. The token savings are never worth it.
- ❌ Deleting hard constraints under the banner of "AI filler." "Must AskUserQuestion / never silently overwrite" may sound forceful but are necessary constraints, not filler.
- ❌ Silently rewriting `description`. Frontmatter description is externally visible and affects matching — must go through HITL.
- ❌ Chasing a character-count floor. If the compressed result reads as "jumpy / unclear what's happening," you've gone too far — roll back.
- ❌ Incidentally changing semantics. This skill only compresses form. If you find a rule that's factually wrong, flag it separately; don't smuggle fixes.
- ❌ Simplifying multiple skills in one round. One at a time, to avoid HITL decision fatigue and rollback noise.

## Boundaries

- **Skill creation**: Creating new skills is a separate concern. This skill only edits existing ones.
- **Source code review**: Simplifying source code (code quality, reuse) is a different concern — different audience, different optimization target (prompt signal-to-noise and trigger-keyword coverage, not code reuse).
- **Human-facing polish**: Removing AI-writing tells for human readers is a separate concern. Step 2 already internalizes its decorative-phrase checklist; do not apply it wholesale — SKILL.md is read by a machine and is not required to "sound human."
- **Domain knowledge writing**: When a SKILL.md leaks domain details, the sink is domain knowledge files. This skill only flags the leak and leaves a clean pointer; it does not write the knowledge file.
