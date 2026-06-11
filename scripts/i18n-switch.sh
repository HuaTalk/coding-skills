#!/usr/bin/env bash
set -euo pipefail

# i18n-switch.sh — Switch all skills and core files between en/zh.
#
# Usage:
#   ./scripts/i18n-switch.sh zh          # switch to Chinese
#   ./scripts/i18n-switch.sh en          # restore English via git

usage() {
  cat <<'EOF'
Usage: scripts/i18n-switch.sh <en|zh>

Switch all skills, commands, and core files between English and Chinese.

  zh  — copy SKILL-zh.md over SKILL.md for all skills and core files
  en  — restore English originals via git checkout

The script operates on the repo's own files. Symlinked projects
pick up changes automatically.
EOF
  exit 0
}

LANG="${1:-}"

if [[ "$LANG" != "en" && "$LANG" != "zh" ]]; then
  echo "Error: expected 'en' or 'zh', got '$LANG'"
  usage
fi

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/skills"
COMMANDS_DIR="$REPO_ROOT/commands"

echo "Switching to: $LANG"
echo ""

if [[ "$LANG" == "en" ]]; then
  # Restore English via git checkout
  echo "Restoring English originals via git..."
  git -C "$REPO_ROOT" checkout -- skills/
  git -C "$REPO_ROOT" checkout -- commands/
  git -C "$REPO_ROOT" checkout -- CLAUDE.md 2>/dev/null || true
  echo "Done. All files restored to English."
  exit 0
fi

# Switching to zh
switched=0
skipped=0

for skill_dir in "$SKILLS_DIR"/*/; do
  skill_name="$(basename "$skill_dir")"
  skill_md="$skill_dir/SKILL.md"
  zh_md="$skill_dir/SKILL-zh.md"

  if [[ -f "$zh_md" ]]; then
    cp "$zh_md" "$skill_md"
    echo "  [ok]   $skill_name"
    ((switched++)) || true
  else
    echo "  [skip] $skill_name (no SKILL-zh.md)"
    ((skipped++)) || true
  fi
done

# Switch CLAUDE.md
if [[ -f "$REPO_ROOT/CLAUDE-zh.md" ]]; then
  cp "$REPO_ROOT/CLAUDE-zh.md" "$REPO_ROOT/CLAUDE.md"
  echo "  [ok]   CLAUDE.md"
fi

# Switch commands (only the base files, not *-zh.md ones)
for cmd_file in "$COMMANDS_DIR"/*.md; do
  cmd_name="$(basename "$cmd_file")"
  # Skip already-zh files
  if [[ "$cmd_name" == *-zh.md ]]; then
    continue
  fi
  base="${cmd_name%.md}"
  zh_cmd="$COMMANDS_DIR/${base}-zh.md"
  if [[ -f "$zh_cmd" ]]; then
    cp "$zh_cmd" "$cmd_file"
    echo "  [ok]   commands/$cmd_name"
  fi
done

echo ""
echo "Switched: $switched skills, Skipped: $skipped"
echo "Done. Restart Claude Code for changes to take effect."
