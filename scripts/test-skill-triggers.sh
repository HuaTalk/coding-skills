#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

frontmatter_description() {
  local file=$1

  awk '
    NR == 1 && $0 == "---" { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter && /^description:/ {
      sub(/^description:[[:space:]]*/, "")
      print
      exit
    }
  ' "$file"
}

# Keep these phrases representative and stable. This is a regression guard for
# the dispatch surface, not a simulation of the host model's matching logic.
TRIGGERS=(
  'domain-context|Persist domain understanding'
  'explore-legacy|legacy'
  'light-explore|lightweight dialogue'
  'skill-simplifier|Simplify and compress'
  'unknown-unknowns|optimize'
  'verification-harness|acceptance'
  'verification-harness|verify'
)

failures=0
for trigger in "${TRIGGERS[@]}"; do
  skill=${trigger%%|*}
  phrase=${trigger#*|}
  file="$ROOT/skills/$skill/SKILL.md"

  if [[ ! -f $file ]]; then
    printf 'FAIL: %s: skill file is missing\n' "$skill" >&2
    failures=$((failures + 1))
    continue
  fi

  description=$(frontmatter_description "$file")
  if [[ $description != *"$phrase"* ]]; then
    printf 'FAIL: %s: description no longer contains trigger %s\n' "$skill" "$phrase" >&2
    failures=$((failures + 1))
  fi
done

if ((failures > 0)); then
  printf '\n%d trigger check(s) failed.\n' "$failures" >&2
  exit 1
fi

printf 'PASS: %d skill trigger phrases\n' "${#TRIGGERS[@]}"
