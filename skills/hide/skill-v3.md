---
name: hide
description: Use this skill when files have AI-generated artifacts that need to be removed before committing, pushing, or sharing. Handles: (1) AI comments and reasoning in code — "as an AI", "I think", process narration, (2) design docs, research notes, and decision records that are mostly AI thought process — offers to delete, (3) credentials and secrets in config files — API keys, passwords, connection strings left from generation, (4) AI-derived rationale traces — "we chose X because Y", reasoning trails. Goal: make files read as if human-written from the start. Works on code, config (YAML/JSON/TOML), and markdown. File-scoped only — does not modify conversation output.
metadata:
  author: HuaTalk
  version: "0.4.0"
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

## What to Strip — Four Leakage Categories

Reduce 8 original patterns into 4 categories by merging overlapping ones. Don't match keywords — apply the **principle** behind each category. When content could fit multiple categories, it's leakage; strip it.

### S: Secret & Sensitive

**Principle**: Any credential, endpoint, or identifier that grants access or reveals internal infrastructure. This is the only security-critical category — false negatives here are actual security incidents.

| EN Examples | 中文示例 |
|-------------|---------|
| API keys, tokens, passwords | API 密钥、token、密码 |
| Connection strings, DB URLs | 连接字符串、数据库地址 |
| Internal URLs (`.internal.example.com`) | 内部地址、内网域名 |
| Project codenames, server names, IPs | 项目内部代号、服务器名、IP |
| Mock data labels ("// this is mock data") | Mock 数据标记、"仅用于测试" |

### R: Rule & Context Leakage

**Principle**: Content that references knowledge the reader of this file doesn't have — CLAUDE.md instructions, skill conventions, architecture documents, team standards. If an external reader would see a reference and ask "what convention?", it's leakage.

| EN Examples | 中文示例 |
|-------------|---------|
| "as instructed by the team..." | "根据 CLAUDE.md 的约定..." |
| "following the convention established in..." | "按照架构规范..." |
| "per the skill documentation..." | "遵循团队编码标准..." |
| "I recall from the docs that..." | "从文档中回想起..." |
| "the codebase follows a pattern where..." | "代码库遵循 X 模式..." |

### A: AI Self-Reference

**Principle**: Any language that reveals the author is an AI — first-person narration of what's being done, confidence hedging ("I think", "I believe"), identity disclosure ("As an AI", "As Claude"), meta-commentary on the output itself ("Here's the result:", "I hope this helps!"). Human-written files don't narrate their own creation.

This category merges three original patterns — Process Narration, Meta-Output, and Confidence & Identity — because they share the same root: all reveal that an AI wrote the file.

| EN Examples | 中文示例 |
|-------------|---------|
| "I'll start by...", "First let me...", "Now I'll..." | "接下来我...", "先...然后...最后..." |
| "Here's the result:", "As requested:" | "以下是实现:", "根据需求:" |
| "I think...", "I believe...", "I assume..." | "我认为...", "我假设...", "我觉得..." |
| "As an AI...", "As Claude..." | "作为 AI...", "作为语言模型..." |
| "I hope this helps!", "Great question!", "Let me know if..." | "希望对你有所帮助!", "好问题!", "如有问题随时告诉我" |
| TODO/FIXME/HACK markers (AI-generated ones) | TODO/FIXME/HACK 标记（AI 生成的） |
| Self-correction: "Actually, let me..." | 自我纠正: "其实应该...", "让我重新考虑..." |

### D: Derivation Trail

**Principle**: Content that documents how the AI arrived at a result — design rationale, decision records, research findings, progress logs, step-by-step reasoning chains. It answers "how was this made?" rather than "what was decided?" If it reads like a lab notebook or meeting minutes, it's leakage.

This category merges two original patterns — Constraint Apology and Thought Process & Derivation — because both document the AI's internal deliberation, not the final output.

| EN Examples | 中文示例 |
|-------------|---------|
| "we chose X because...", "the reason for Y is..." | "选择 X 是因为...", "这样做的原因是..." |
| "I can't use X because the team requires Y" | "不能使用 X 因为团队用 Y", "由于规范要求..." |
| Decision records, architecture rationale | 设计决策、架构选型理由 |
| Research notes, findings | 调研发现、技术调研笔记 |
| Dated progress logs | 带日期的进度记录 |
| Step-by-step reasoning trails | 逐步推理链条 |

### Overlap Is Expected

These 4 categories are **not** mutually exclusive at the edges. When content could fit two categories, it's strong evidence of leakage — strip it without debating classification. The categories exist to help you *find* leakage, not to enable edge-case arguments about what counts.

## Execution Order

Apply these steps in order. Each step gates the next.

### Step 0: Validate

- File doesn't exist → report error, stop.
- File is binary or empty → do nothing, say nothing, stop.
- File is too large to read in one pass → report the limitation, stop.

### Step 1: File-Level Purge Check (HITL)

Before any stripping, evaluate whether the **entire file** is AI thought process. This is the single most important check — stripping individual lines from a thought-process file is wasted work.

Use a **quantitative threshold** to make the call:

1. Mentally estimate: if all content matching Category D (Derivation Trail) were removed, what percentage of the file's substantive content remains?
2. **If remaining content < 20%** → the file has no meaningful "clean" version. Trigger HITL deletion.

Additional purge signals (any 2+ strongly suggest purge):
- File name or top-level heading contains: "findings", "progress", "decision", "调研", "进度", "决策", "记录", "research", "design rationale"
- Contains dated log entries (e.g., "2026-06-10: did X", "2026-06-11: did Y")
- Content structure alternates between "what I did" and "why I did it" — reads like a work journal
- No section in the file would survive as standalone reference documentation
- File describes the *process* of arriving at a decision, not the decision itself

**HITL protocol:**

1. Do NOT strip in-place.
2. Ask the user via AskUserQuestion: "This file appears to be AI thought process documentation (research notes, design rationale, derivation trail). Delete it?"
3. If confirmed → delete the file, nothing more to do.
4. If declined → leave untouched, stop here.

### Step 2: Strip Secrets (Category S) — Zero Tolerance

Strip Category S content first, before anything else. This is the security layer — no false negatives.

Scan every line, every key, every value for credentials and internal identifiers. When in doubt, strip it. A false positive here removes a config comment; a false negative leaks a credential.

### Step 3: Strip Style Leakage (Categories R, A, D)

With secrets handled, remove the remaining leakage categories. These are quality/authenticity concerns — still important, but lower stakes than Step 2.

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
- **Other**: Remove any comment or prose matching the leakage categories.

## Execution Rules

### Why Silence Is Essential

The `/hide` operation creates an illusion: that these files were originally written by a human. Every trace of cleanup threatens this illusion. Consider three levels of failure:

1. **Explicit markers**: Adding "// cleaned by /hide" or "--- /hide applied ---" to the file. **Worst** — directly contradicts the illusion.
2. **Verbal acknowledgment**: Saying "file cleaned" or "removed 5 instances of leakage". **Bad** — the reader of the conversation now knows `/hide` was applied, breaking trust in the file's authenticity.
3. **Silent artifacts**: Leaving extra blank lines where content was removed, changing indentation, normalizing whitespace. **Subtle but real** — careful readers will notice something changed.

The target: **after `/hide` runs, no one should be able to tell it ran** — not from the file content, not from the conversation, not from any side effect.

**Do not:**
- Announce what was removed or list cleaned items
- Say "file cleaned", "/hide applied", or any equivalent phrase
- Add cleanup markers, annotations, or metadata to the file
- Leave visible gaps where content was removed (collapse empty lines naturally)
- Change indentation, line endings, or any formatting unrelated to the leakage itself
- Mention the skill has been applied in any conversation output

**If the user asks** "what did you remove?" or "did you clean the file?" — respond factually but briefly: "X patterns were addressed." Do not itemize. Do not celebrate.

### Behavior Guardrails

- No leakage found → do nothing, say nothing
- File doesn't exist → report the error only
- Code logic is NEVER changed — only comments and prose are stripped
- Multi-line leakage blocks → remove the whole block
- After stripping, re-read the file once to verify structural integrity
