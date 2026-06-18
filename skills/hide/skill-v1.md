---
name: hide
description: Use this skill when files have AI-generated artifacts that need to be removed before committing, pushing, or sharing. Handles: (1) AI comments and reasoning in code — "as an AI", "I think", process narration, (2) design docs, research notes, and decision records that are mostly AI thought process — offers to delete, (3) credentials and secrets in config files — API keys, passwords, connection strings left from generation, (4) AI-derived rationale traces — "we chose X because Y", reasoning trails. Goal: make files read as if human-written from the start. Works on code, config (YAML/JSON/TOML), and markdown. File-scoped only — does not modify conversation output.
metadata:
  author: HuaTalk
  version: "0.2.0"
  category: output-discipline
---

# /hide

Strip AI leakage from files. Cleaned files should read as if written by a human — no traces of AI reasoning, no rule citations, no self-reference.

**Scope**: Files only (code, config, markdown, docs). Does NOT modify agent replies or conversation output.

## Usage

```
/hide <file>    Clean a specific file
/hide           Clean the file currently in context
```

## What to Strip — Guided by Principles, Not Keywords

Don't grep for specific phrases. Use these **principles** to judge whether content is leakage. The examples help calibrate your judgment, but the principle is what matters.

### Pattern S: Secret & Sensitive

**Principle**: Any credential, endpoint, or identifier that grants access or reveals internal infrastructure. These are actual security risks, not cosmetic issues.

Examples: API keys, tokens, passwords, connection strings, internal URLs (`.internal.example.com`), project codenames, mock data labels, server names, IPs.

### Pattern R: Rule & Context Leakage

**Principle**: Content that references knowledge the reader doesn't have — skill instructions, CLAUDE.md conventions, architecture documents, team standards. If a reader who only has this file would be confused by a reference, it's leakage.

Examples: "as instructed by...", "following the convention...", "per the skill...", "I recall from the docs...", "the codebase follows a pattern where...", "根据 CLAUDE.md...", "按照...的约定".

### Pattern C: Constraint & Rationale

**Principle**: Content that explains why a choice was made rather than documenting what was chosen. The output should state decisions, not justify them. If the reasoning is about constraints the AI faced (not business constraints), it's leakage.

Examples: "I can't use X because the team standard requires...", "不能使用 X 因为团队用 Y", "由于规范要求...", "we chose X because...", "the reason for Y is...", "调研发现...", "设计决策...".

### Pattern A: AI Self-Reference

**Principle**: Any language that reveals the author is an AI — first-person narration of actions, confidence hedging, identity disclosure, meta-commentary on the output itself. Human-written files don't say "Here's the result:" or "I hope this helps!".

Examples: "I'll start by...", "First let me...", "接下来我...", "Here's the result:", "As requested:", "I think...", "I believe...", "I assume...", "As an AI...", "As Claude...", "I hope this helps!", "Great question!", "Let me know if...", TODO/FIXME/HACK markers, self-corrections in comments.

### Pattern T: Thought Process & Derivation

**Principle**: Content that documents how the AI arrived at a result — research logs, design rationale trails, progress entries, step-by-step reasoning. If it reads like a lab notebook rather than a reference document, it's leakage.

Examples: "we chose X because...", step-by-step reasoning trails, dated progress logs, research findings, decision records, "调研发现...", "设计决策...", "进度...", "progress".

> **Note on overlap**: Patterns intentionally overlap at the edges. When in doubt, apply the stricter judgment. The goal is not perfect classification — it's removing everything that shouldn't be there.

## Execution Order

Apply these steps in order. Each step gates the next.

### Step 0: Validate

- File doesn't exist → report error, stop.
- File is binary or empty → do nothing, say nothing, stop.
- File is too large to read in one pass → report the limitation, stop.

### Step 1: File-Level Purge Check (HITL)

Before any stripping, evaluate whether the **entire file** is AI thought process. This is the single most important check — stripping individual lines from a thought-process file is wasted work.

When the file's content is predominantly Pattern T (Thought Process & Derivation):

1. Do NOT strip in-place.
2. Ask the user via AskUserQuestion: "This file appears to be AI thought process documentation (research notes, design rationale, derivation trail). Delete it?"
3. If confirmed → delete the file, nothing more to do.
4. If declined → leave untouched, stop here.

**Purge indicators:**
- File describes how decisions were made, not what was decided
- Content reads like a log of AI reasoning steps, not reference documentation
- Contains "调研发现", "findings", "设计决策", "decision record", "进度", "progress"
- File name or title contains signals like "findings", "progress", "decision", "调研", "进度", "决策"
- Removing all thought-process content would leave the file empty or near-empty

### Step 2: Strip Secrets (Pattern S) — Zero Tolerance

Strip Pattern S content first, before anything else. This is the security layer — no false negatives.

Scan every line, every key, every value for credentials and internal identifiers. When in doubt, strip it. A false positive here removes a config comment; a false negative leaks a credential.

### Step 3: Strip Style Leakage (Patterns R, C, A, T)

With secrets handled, remove the remaining leakage patterns. These are cosmetic/quality concerns — still important, but lower stakes than Step 2.

### Step 4: Verify

After stripping, quick sanity check:
- Code files: do braces/brackets still match? Are imports intact?
- Config files: is YAML/JSON/TOML still valid?
- Markdown: are headings and code blocks intact?

If stripping broke something structural, leave a minimal necessary structure (e.g., keep a valid comment wrapper with empty body rather than deleting the whole javadoc block and breaking the syntax).

## Strip Strategy by File Type

- **Code** (.java, .py, .ts, .go, .rs, etc.): Remove comment lines and doc strings containing leakage. Keep executable code as-is. If removing a comment would leave an empty comment block (e.g., `/** */`), remove the whole block.
- **Markdown** (.md): Remove leakage paragraphs and sentences. Keep technical content.
- **Config** (.yml, .json, .xml, .toml): Remove leakage comments and sensitive values. Keep config structure and non-sensitive values.
- **Other**: Remove any comment or prose matching the leakage patterns.

## Execution Rules

### Why Silence Matters

The goal is to make files look like they were **originally written by a human**. Any trace of cleanup — a marker, an annotation, even a verbal confirmation — destroys this illusion. The reader should never know `/hide` was applied.

**Do not:**
- Announce what was removed or list cleaned items
- Say "file cleaned", "/hide applied", or any equivalent
- Add cleanup markers, annotations, or metadata to the file
- Leave empty lines where leakage was removed (collapse them)
- Change the file's modification pattern in any visible way

### Behavior Guardrails

- No leakage found → do nothing, say nothing
- File doesn't exist → report the error only
- Code logic is NEVER changed — only comments and prose are stripped
- Multi-line leakage blocks → remove the whole block
