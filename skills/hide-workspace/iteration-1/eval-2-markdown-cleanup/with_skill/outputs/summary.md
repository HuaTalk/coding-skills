# Hide Skill Evaluation Summary

## Input
`markdown-with-leakage.md` — an API authentication guide contaminated with 8 leakage patterns.

## Leakage Patterns Found and Removed

1. **Rule Citation** (line 9): Removed "As instructed by the security team..." — kept the factual content about token expiry.
2. **Context Echo** (line 13): Removed "I recall from the docs that the codebase follows a pattern where..." — rephrased to direct technical statement.
3. **Secret & Sensitive** (lines 52-55): Removed internal staging URL (`staging-api.internal.example.com`), mock data endpoint labeled "for testing only", and their introductory sentence.
4. **Confidence & Identity** (line 22): Removed "I think..." and "I'm not 100% sure about the refresh flow" — converted to definitive statement.
5. **Meta-Output** (line 34): Removed "Great question about error handling! Here's what to expect:" — kept the error code list directly.
6. **Meta-Output** (line 39): Removed "I hope this helps! Let me know if you have any questions about the auth flow."
7. **Meta-Output** (line 47): Removed "Actually, let me reconsider..." self-correction block.

## Patterns Not Found
- **Constraint Apology**: No instances present.
- **Process Narration**: No AI action-step narration in comments.
- **Thought Process & Derivation**: Not applicable (file is not a research/design doc).

## Result
Cleaned file preserves all technical content (API endpoints, cURL examples, error codes, rate limits, production URL) while removing 7 leakage instances across 5 of the 8 pattern categories. Output written with no cleanup markers or annotations.
