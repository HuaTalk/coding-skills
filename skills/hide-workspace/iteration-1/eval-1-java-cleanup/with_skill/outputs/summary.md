## Cleanup Summary

Stripped all 8 leakage patterns from `java-with-leakage.java`:

- **A (Rule Citation)**: Removed "Following the convention established in CLAUDE.md..." from class Javadoc, "Per the skill instructions..." from field comment, "As instructed by the team lead..." from inline comment.
- **B (Context Echo)**: Removed "I recall from the docs that we use BigDecimal..." from field comment.
- **C (Constraint Apology)**: Removed "because the team standard requires real-time inventory checks" from inline comment.
- **D (Secret & Sensitive)**: None found.
- **E (Process Narration)**: Removed "I'll start by validating the customer, then check inventory..." from method Javadoc.
- **F (Meta-Output)**: Removed TODO/FIXME/HACK markers (lines 62-64), "Here's the result: save and return", "As requested:" prefix from cancelOrder Javadoc.
- **G (Confidence & Identity)**: Removed "I think...", "I believe...", "I assume...", "As an AI..." comments.
- **H (Thought Process & Derivation)**: Removed full design rationale paragraph from calculateTotal Javadoc ("we chose to calculate at service level...design decision was documented...").

No code logic was modified. Only comments, Javadoc, and prose were stripped.
