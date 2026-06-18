---
name: hide
description: Use this skill when files have AI-generated artifacts that need to be removed before committing, pushing, or sharing. Handles: (1) AI comments and reasoning in code — "as an AI", "I think", process narration, (2) design docs, research notes, and decision records that are mostly AI thought process — offers to delete, (3) credentials and secrets in config files — API keys, passwords, connection strings left from generation, (4) AI-derived rationale traces — "we chose X because Y", reasoning trails. Goal: make files read as if human-written from the start. Works on code, config (YAML/JSON/TOML), and markdown. File-scoped only — does not modify conversation output.
metadata:
  author: HuaTalk
  version: "0.1.0"
  category: output-discipline
---

# /hide

Strip rule leakage from files. Rules are for the AI, not the output — but sometimes they leak into comments and docs. `/hide` cleans them up.

**Scope**: Files only (code, config, markdown, docs). Does NOT modify agent replies or conversation output.

## Usage

```
/hide <file>    Clean a specific file
/hide           Clean the file currently in context
```

## What Gets Stripped

Eight leakage patterns — identified and removed from comments, doc strings, and narrative text:

| Pattern | What it looks like |
|---------|-------------------|
| **Rule Citation** | "as instructed by...", "following the convention...", "per the skill...", "根据 CLAUDE.md...", "按照...的约定" |
| **Context Echo** | "I recall from the docs...", "the codebase follows a pattern where...", "从架构文档中回想起...", "代码库遵循 X 模式..." |
| **Constraint Apology** | "I can't use X because...", "the team standard requires...", "不能使用 X 因为团队用 Y", "由于规范要求..." |
| **Secret & Sensitive** | API keys, tokens, passwords, connection strings, internal URLs/endpoints, internal project codenames, mock data labels ("// this is mock data", "// for testing only"), environment details (server names, IPs) |
| **Process Narration** | "I'll start by...", "First let me...", "Now I'll...", "接下来我...", "先...然后...最后..." in comments — narrating the AI's action steps |
| **Meta-Output** | "Here's the result:", "As requested:", "Here's the implementation:", TODO/FIXME/HACK markers, "Actually, let me...", self-correction in comments |
| **Confidence & Identity** | "I think...", "I believe...", "This might not cover...", "I assume...", "As an AI...", "As Claude...", "I hope this helps!", "Great question!", "Let me know if..." |
| **Thought Process & Derivation** | Research notes, design rationale, decision records, "we chose X because...", "the reason for Y is...", step-by-step reasoning trails, "调研发现...", "设计决策..." — content that documents how the AI arrived at a result rather than the result itself |

## File-Level Purging (HITL)

Some files are **entirely** thought process — research logs, design decision records, derivation trails. Stripping individual lines from them is pointless; the file itself is the leak.

When `/hide` encounters a file where the **majority of content** matches Pattern H (Thought Process & Derivation):

1. **Do NOT strip in-place.** The file has no meaningful "clean" version.
2. **Ask the user** (AskUserQuestion): "This file appears to be AI thought process documentation (research notes, design rationale, derivation trail). Delete it?"
3. If user confirms → delete the file.
4. If user declines → leave it untouched.

**Indicators that a file should be purged rather than stripped:**
- File describes how a decision was made, not what was decided
- Contains "调研发现", "findings", "设计决策", "decision record", "进度", "progress"
- Reads like a log of AI reasoning steps rather than reference documentation
- Removing all thought-process content would leave the file empty or near-empty

## Strip Strategy by File Type

- **Code** (.java, .py, .ts, .go, .rs, etc.): Remove comment lines containing leakage. Keep executable code as-is.
- **Markdown** (.md): Remove leakage paragraphs. Keep technical content.
- **Config** (.yml, .json, .xml, .toml): Remove leakage comments. Keep config values.
- **Other**: Remove any comment or prose matching the leakage patterns.

## Execution Rules

**Silent. Do not:**
- Announce what was removed
- List cleaned items
- Say "file cleaned" or "/hide applied"
- Add cleanup markers or annotations to the file

**The cleaned file should read as if it was written that way from the start.**

## Behavior Guardrails

- If no leakage found → do nothing, say nothing
- If file doesn't exist → report the error (this is a user mistake, not a rule leak)
- Code logic is NEVER changed — only comments and prose are stripped
- Multi-line leakage blocks (e.g. entire comment paragraphs explaining rules) → remove the whole block
