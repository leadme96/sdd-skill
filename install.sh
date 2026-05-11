#!/bin/bash
# sdd-skill: one-click install for Claude Code / OpenCode
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
  ORCHESTRATOR_DEST="$PWD/.agents/skills"
else
  DEST="$HOME/.claude/skills"
  ORCHESTRATOR_DEST="$HOME/.agents/skills"
fi

mkdir -p "$DEST"
mkdir -p "$ORCHESTRATOR_DEST"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)

# Install orchestrator to .agents/skills/sdd
orchestrator_src="$SCRIPT_DIR/.agents/skills/sdd"
orchestrator_dest="$ORCHESTRATOR_DEST/sdd"
if [ -d "$orchestrator_src" ]; then
  if [ -e "$orchestrator_dest" ]; then
    if [ -L "$orchestrator_dest" ]; then
      existing=$(readlink "$orchestrator_dest")
      if [ "$existing" = "$orchestrator_src" ]; then
        echo "  ✓ sdd (orchestrator) already installed"
      else
        echo "  ~ sdd (orchestrator) upgrading..."
        rm -f "$orchestrator_dest"
        ln -s "$orchestrator_src" "$orchestrator_dest"
        echo "  ✓ sdd (orchestrator) → $orchestrator_dest"
      fi
    else
      echo "  ! sdd (orchestrator) exists as a file/directory (not a symlink), skipping"
    fi
  else
    ln -s "$orchestrator_src" "$orchestrator_dest"
    echo "  ✓ sdd (orchestrator) → $orchestrator_dest"
  fi
else
  echo "  ✗ sdd (orchestrator) source not found at $orchestrator_src"
fi

# Install 12 action skills to .claude/skills/
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
echo "SDD installed! 1 orchestrator + 12 skills to $DEST"
echo ""
echo "Usage:"
echo "  sdd ./my-project                  # Unified entry (auto-detect path)"
echo "  sdd-init ./my-project             # First: initialize project"
echo "  sdd-doctor ./my-project           # Check environment"
echo ""
echo "Uninstall:"
echo "  rm -rf $ORCHESTRATOR_DEST/sdd $DEST/sdd-*"