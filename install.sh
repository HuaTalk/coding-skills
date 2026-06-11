#!/usr/bin/env bash
set -euo pipefail

# install.sh — Install the skill plugin into a target project.
#
# Usage:
#   ./install.sh --target /path/to/project
#   ./install.sh --target /path/to/project --lang zh
#   ./install.sh --target /path/to/project --skills handoff,domain-context
#   ./install.sh --target /path/to/project --skills handoff --lang zh

usage() {
  cat <<'EOF'
Usage: install.sh --target <path> [--skills <list>] [--lang <en|zh>]

Options:
  --target <path>   Target project directory (required)
  --skills <list>   Comma-separated skill names (default: all)
  --lang <en|zh>    Language for skill content (default: en)
  --help            Show this message

Available skills (auto-discovered from skills/ directory):
  run: ls skills/
EOF
  exit 0
}

# Parse arguments
TARGET=""
SKILLS=""
LANG="en"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --target) TARGET="$2"; shift 2 ;;
    --skills) SKILLS="$2"; shift 2 ;;
    --lang)   LANG="$2"; shift 2 ;;
    --help)   usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

if [[ -z "$TARGET" ]]; then
  echo "Error: --target is required"
  usage
fi

if [[ "$LANG" != "en" && "$LANG" != "zh" ]]; then
  echo "Error: --lang must be 'en' or 'zh'"
  exit 1
fi

# Resolve repo root (where this script lives)
REPO_ROOT="$(cd "$(dirname "$0")" && pwd)"

# Auto-discover all skills from the repo (any directory with SKILL.md)
ALL_SKILLS=()
for d in "$REPO_ROOT/skills"/*/; do
  if [[ -f "$d/SKILL.md" ]]; then
    ALL_SKILLS+=("$(basename "$d")")
  fi
done

# Determine which skills to install
if [[ -z "$SKILLS" ]]; then
  SELECTED=("${ALL_SKILLS[@]}")
else
  IFS=',' read -ra SELECTED <<< "$SKILLS"
  # Validate each skill exists
  for skill in "${SELECTED[@]}"; do
    skill=$(echo "$skill" | xargs) # trim whitespace
    if [[ ! -d "$REPO_ROOT/skills/$skill" ]]; then
      echo "Error: skill '$skill' not found in $REPO_ROOT/skills/"
      exit 1
    fi
  done
fi

# Create target directories
mkdir -p "$TARGET/.claude/skills"
mkdir -p "$TARGET/.claude/commands"

echo "Installing to: $TARGET"
echo "Skills: ${SELECTED[*]}"
echo "Language: $LANG"
echo ""

# Symlink selected skills (per-skill symlink for selective install)
for skill in "${SELECTED[@]}"; do
  skill=$(echo "$skill" | xargs)
  src="$REPO_ROOT/skills/$skill"
  dst="$TARGET/.claude/skills/$skill"

  if [[ -L "$dst" || -d "$dst" ]]; then
    echo "  [skip] $skill (already exists)"
  else
    ln -s "$src" "$dst"
    echo "  [ok]   $skill"
  fi

  # Apply language variant
  if [[ "$LANG" == "zh" && -f "$src/SKILL-zh.md" ]]; then
    cp "$src/SKILL-zh.md" "$src/SKILL.md"
    echo "         -> switched to zh"
  fi
done

# Symlink commands (only if not already linked)
if [[ -L "$TARGET/.claude/commands" ]]; then
  echo "  [skip] commands (already linked)"
else
  # If commands dir is a symlink to our commands, skip. Otherwise create per-file symlinks
  if [[ ! -d "$TARGET/.claude/commands" ]] || [[ -z "$(ls -A "$TARGET/.claude/commands" 2>/dev/null)" ]]; then
    ln -s "$REPO_ROOT/commands" "$TARGET/.claude/commands"
    echo "  [ok]   commands"
  else
    echo "  [skip] commands (directory not empty)"
  fi
fi

# Symlink .mcp.json
if [[ -L "$TARGET/.mcp.json" ]]; then
  echo "  [skip] .mcp.json (already linked)"
elif [[ -f "$TARGET/.mcp.json" ]]; then
  echo "  [skip] .mcp.json (file exists, not overwriting)"
else
  ln -s "$REPO_ROOT/.mcp.json" "$TARGET/.mcp.json"
  echo "  [ok]   .mcp.json"
fi

echo ""
echo "Done. Restart Claude Code in $TARGET to load the new skills."
