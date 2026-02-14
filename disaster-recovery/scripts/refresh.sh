#!/usr/bin/env bash
# refresh.sh -- Re-run all captures and optionally update knowledge archive
#
# Usage: ./refresh.sh [--captures-only] [--knowledge-only]
#
# This script:
# 1. Runs all state capture scripts (creates a new dated snapshot)
# 2. Refreshes a knowledge distillation archive (copies of config files,
#    automation scripts, project docs, etc.)
#
# CUSTOMIZATION:
# - Update the knowledge distillation section to copy YOUR automation
#   configs, runbooks, and project docs
# - The knowledge archive is optional -- remove it if you only need snapshots
#
set -euo pipefail

DR_DIR="$(cd "$(dirname "$0")/.." && pwd)"
DATE=$(date +%Y-%m-%d)

do_captures=true
do_knowledge=true

for arg in "$@"; do
    case "$arg" in
        --captures-only) do_knowledge=false ;;
        --knowledge-only) do_captures=false ;;
        *) echo "Unknown arg: $arg"; exit 1 ;;
    esac
done

if $do_captures; then
    echo "=== Running state captures ==="
    bash "$DR_DIR/state-capture/capture.sh"
    echo
fi

if $do_knowledge; then
    echo "=== Refreshing knowledge distillation ==="

    # CUSTOMIZATION: Update these paths for your environment.
    # The idea is to copy anything that would be needed to reconstruct
    # your automation knowledge if all running systems were lost.

    # Example: Copy automation config/memory files
    # echo "Copying automation configs..."
    # rsync -a --delete ~/.config/my-automation/ \
    #     "$DR_DIR/knowledge-distillation/automation-archive/"

    # Example: Copy project documentation
    # echo "Copying project docs..."
    # mkdir -p "$DR_DIR/knowledge-distillation/project-docs"
    # find ~/projects/ -maxdepth 2 -name "README.md" -type f 2>/dev/null | while read -r f; do
    #     rel="${f#$HOME/projects/}"
    #     safename="${rel//\//__}"
    #     cp "$f" "$DR_DIR/knowledge-distillation/project-docs/$safename"
    # done

    # Example: Copy emergency procedures
    # cp ~/projects/EMERGENCY-PROCEDURES.md \
    #     "$DR_DIR/knowledge-distillation/" 2>/dev/null || true

    echo "Knowledge distillation refreshed."
    echo
fi

echo "=== Refresh complete at $(date) ==="
echo "Run scripts/validate.sh to check guide consistency."
