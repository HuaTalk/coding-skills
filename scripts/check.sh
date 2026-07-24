#!/usr/bin/env bash
set -euo pipefail

ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
ERRORS=0

pass() {
  printf 'PASS: %s\n' "$1"
}

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  ERRORS=$((ERRORS + 1))
}

frontmatter_value() {
  local file=$1
  local key=$2

  awk -v key="$key" '
    NR == 1 && $0 == "---" { in_frontmatter = 1; next }
    in_frontmatter && $0 == "---" { exit }
    in_frontmatter && $0 ~ "^[[:space:]]*" key ":[[:space:]]*" {
      sub("^[[:space:]]*" key ":[[:space:]]*", "")
      print
      exit
    }
  ' "$file"
}

check_manifests() {
  local manifest
  local errors_before=$ERRORS

  for manifest in "$ROOT"/.claude-plugin/*.json; do
    jq -e . "$manifest" >/dev/null || fail "invalid JSON: ${manifest#"$ROOT/"}"
  done

  if [[ $(jq -r '.name' "$ROOT/.claude-plugin/plugin.json") != \
        $(jq -r '.plugins[0].name' "$ROOT/.claude-plugin/marketplace.json") ]]; then
    fail "plugin and marketplace names differ"
  fi

  if [[ $(jq -r '.plugins[0].source' "$ROOT/.claude-plugin/marketplace.json") != "./" ]]; then
    fail "marketplace source must be ./"
  fi

  if ! jq -e '(.languages == ["en"]) and (has("description_zh") | not)' \
      "$ROOT/.claude-plugin/plugin.json" >/dev/null; then
    fail "plugin manifest must declare English as the only maintained language"
  fi

  if ((ERRORS == errors_before)); then
    pass "plugin manifests"
  fi
  return 0
}

check_english_only() {
  local matches grep_status

  if matches=$(git -C "$ROOT" grep -nI -P '[\x{4E00}-\x{9FFF}]' -- .); then
    printf '%s\n' "$matches" >&2
    fail "maintained files contain CJK text; archive historical Chinese content instead"
  else
    grep_status=$?
    if ((grep_status == 1)); then
      pass "English-only maintained tree"
    else
      fail "unable to scan maintained files for CJK text (git grep exit $grep_status)"
    fi
  fi
  return 0
}

check_skills() {
  local skill_file skill_dir name description author version category skill_status skill_token
  local skill_count=0
  local errors_before=$ERRORS

  shopt -s nullglob
  local skill_files=("$ROOT"/skills/*/SKILL.md)
  shopt -u nullglob

  if ((${#skill_files[@]} == 0)); then
    fail "no skills/*/SKILL.md files found"
    return 0
  fi

  for skill_file in "${skill_files[@]}"; do
    skill_dir=$(basename "$(dirname "$skill_file")")
    name=$(frontmatter_value "$skill_file" name)
    description=$(frontmatter_value "$skill_file" description)
    author=$(frontmatter_value "$skill_file" author)
    version=$(frontmatter_value "$skill_file" version)
    category=$(frontmatter_value "$skill_file" category)
    skill_status=$(frontmatter_value "$skill_file" status)
    skill_token=$(printf '\x60%s\x60' "$skill_dir")

    [[ $name =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]] || fail "$skill_dir: invalid or missing name"
    [[ $name == "$skill_dir" ]] || fail "$skill_dir: name does not match directory"
    [[ -n $description && $description != '""' ]] || fail "$skill_dir: missing description"
    [[ -n $author ]] || fail "$skill_dir: missing metadata.author"
    local quoted_semver='^"[0-9]+\.[0-9]+\.[0-9]+"$'
    [[ $version =~ $quoted_semver ]] || fail "$skill_dir: version must be a quoted semver"
    [[ $category == "methodology" || $category == "workflow" ]] || fail "$skill_dir: invalid metadata.category"
    [[ $skill_status == "stable" || $skill_status == "experimental" ]] || fail "$skill_dir: invalid metadata.status"
    grep -Fq "$skill_dir/" "$ROOT/README.md" || fail "$skill_dir: missing from README inventory"
    grep -Fq "$skill_token" "$ROOT/CLAUDE.md" || fail "$skill_dir: missing from CLAUDE.md inventory"
    skill_count=$((skill_count + 1))
  done

  if ((ERRORS == errors_before)); then
    pass "$skill_count skill definitions"
  fi
  return 0
}

check_release_metadata() {
  local version
  version=$(jq -r '.version' "$ROOT/.claude-plugin/plugin.json")

  if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    fail "plugin version is not semver: $version"
    return 0
  fi

  if ! grep -Fq "## [$version]" "$ROOT/CHANGELOG.md"; then
    fail "CHANGELOG.md has no entry for plugin version $version"
    return 0
  fi

  pass "release metadata for $version"
}

check_release_tag() {
  local ref=${GITHUB_REF:-}
  local tag version

  [[ $ref == refs/tags/* ]] || return 0
  tag=${ref#refs/tags/}
  version=$(jq -r '.version' "$ROOT/.claude-plugin/plugin.json")

  if [[ $tag != "v$version" ]]; then
    fail "release tag $tag does not match plugin version $version (expected v$version)"
    return 0
  fi

  pass "release tag $tag"
}

check_secrets() {
  local file matches found=0
  local secret_pattern='ghp_''[[:alnum:]]{20,}|sk-''[[:alnum:]_-]{20,}'

  while IFS= read -r -d '' file; do
    [[ -f "$ROOT/$file" ]] || continue
    if matches=$(grep -nEI "$secret_pattern" "$ROOT/$file"); then
      printf '%s:%s\n' "$file" "$matches" >&2
      found=1
    fi
  done < <(git -C "$ROOT" ls-files --cached --others --exclude-standard -z)

  if ((found == 0)); then
    pass "credential patterns"
  else
    fail "possible credential found in tracked or untracked files"
  fi
}

check_installer() {
  if (
    set -e
    temp_dir=$(mktemp -d "${TMPDIR:-/tmp}/skills-check.XXXXXX")
    trap 'find "$temp_dir" -depth -delete' EXIT
    bash -n "$ROOT/install.sh"
    bash "$ROOT/install.sh" --target "$temp_dir" >/dev/null
    installed_count=$(find "$temp_dir/.claude/skills" -mindepth 1 -maxdepth 1 -type l | wc -l | tr -d ' ')
    expected_count=$(find "$ROOT/skills" -mindepth 2 -maxdepth 2 -name SKILL.md | wc -l | tr -d ' ')
    [[ $installed_count == "$expected_count" ]]
    [[ -L $temp_dir/.mcp.json ]]
    [[ ! -e $temp_dir/.claude/commands ]]
  ); then
    pass "installer smoke test"
  else
    fail "installer smoke test"
  fi
  return 0
}

main() {
  command -v jq >/dev/null || { printf 'ERROR: jq is required\n' >&2; exit 2; }

  check_manifests
  check_skills
  check_english_only
  if ! bash "$ROOT/scripts/test-skill-triggers.sh"; then
    fail "skill trigger phrases"
  fi
  check_release_metadata
  check_release_tag
  check_secrets
  check_installer

  if ((ERRORS > 0)); then
    printf '\n%d check(s) failed.\n' "$ERRORS" >&2
    exit 1
  fi

  printf '\nAll repository checks passed.\n'
}

main "$@"
