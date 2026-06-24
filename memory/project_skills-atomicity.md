# Skills Atomicity Improvement

Last updated: 2026-06-24

## Overview

All team-maintained skills have been refactored to be fully self-contained with zero cross-references. This enables independent skill evolution without cascading updates.

## Refactoring Results

### Completed Skills

| Skill | Changes | Status |
|-------|---------|--------|
| best-effort-delivery | Removed 3 cross-references, added self-describing patterns | ✅ Complete |
| light-explore | Removed comparison references, added scope boundaries | ✅ Complete |
| unknown-unknowns | Removed 5-skill relationship table, added self-describing boundaries | ✅ Complete |
| explore-legacy | Replaced skill name references with feature descriptions | ✅ Complete |
| skill-simplifier | Replaced all 4 skill name references with type descriptions | ✅ Complete |
| domain-context | Renamed "Boundaries with Other Skills" to "Scope Boundaries" | ✅ Complete |

### Verification Results

- ✅ All `[[wiki-link]]` cross-references eliminated (6 EN + 6 ZH files)
- ✅ All backtick-name explicit references eliminated
- ✅ Generic `[[other-skill]]` patterns preserved (non-specific)
- ✅ 3 already-atomic skills (brainstorming, handoff, openspec-explore) untouched
- ✅ Total: 12 files modified (6 SKILL.md + 6 SKILL-zh.md)

## Key Design Principle

**Scope Boundaries over Skill Names:** Skills should describe their scope boundaries using feature characteristics rather than naming other skills. This enables:
- Independent skill evolution
- No cascading updates when skills change
- Clearer mental model for consumers
- Easier maintenance and testing

## Implementation Pattern

**Before (anti-pattern):**
```markdown
## Relationship to Other Skills
- Use `[[light-explore]]` for quick exploration
- Use `[[brainstorming]]` for full analysis
```

**After (correct pattern):**
```markdown
## Scope Boundaries
- Use quick exploration for single-file changes
- Use full exploration with design artifacts for complex analysis
```

## Next Steps

1. Monitor skill usage for any remaining implicit dependencies
2. Consider adding automated cross-reference detection to CI
3. Document patterns for new skill development