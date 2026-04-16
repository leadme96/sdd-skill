#!/bin/bash
# sdd-skill: one-click install for Claude Code
# Usage:
#   curl -fsSL https://... | bash
#   # or locally:
#   bash install.sh

set -euo pipefail

# Target: project-level or user-level
TARGET_DIR="${1:-project}"

SKILL_NAMES="sdd-init sdd-doctor sdd-brainstorm sdd-propose sdd-continue sdd-ff sdd-plan sdd-apply sdd-review-spec sdd-review-code sdd-verify sdd-ship"

if [ "$TARGET_DIR" = "project" ]; then
  DEST="$PWD/.claude/skills"
else
  DEST="$HOME/.claude/skills"
fi

mkdir -p "$DEST"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

for name in $SKILL_NAMES; do
  src="$SCRIPT_DIR/$name"
  if [ -d "$src" ]; then
    dest="$DEST/$name"
    if [ -e "$dest" ]; then
      if [ -L "$dest" ]; then
        existing=$(readlink "$dest")
        if [ "$existing" = "$src" ]; then
          echo "  ✓ $name already installed"
          continue
        else
          echo "  ~ $name upgrading..."
          rm -f "$dest"
        fi
      else
        echo "  ! $name exists as a file/directory (not a symlink), skipping"
        continue
      fi
    fi
    ln -s "$src" "$dest"
    echo "  ✓ $name → $dest"
  else
    echo "  ✗ $name source not found at $src"
  fi
done

echo ""
echo "SDD installed! 12 skills installed to $DEST"
echo ""
echo "Usage:"
echo "  sdd-init ./my-project          # First: initialize project"
echo "  sdd-doctor ./my-project        # Check environment"
echo "  sdd-propose ./my-project ...   # Create change proposal"
echo ""
echo "Uninstall: rm -rf $DEST/sdd-*"
