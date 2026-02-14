#!/usr/bin/env bash
# diff-state.sh -- Compare two state snapshots to detect configuration drift
#
# Usage: ./diff-state.sh [date1] [date2]
# If no dates given, compares the two most recent snapshots.
# If one date given, compares it against the previous snapshot.
#
# This script highlights changes in:
# - Container lists (added/removed containers)
# - VM lists (added/removed VMs)
# - Listening ports (new services, removed services)
# - Disk usage (significant changes)
# - Mount configuration (fstab changes)
# - Quadlet/unit file changes
#
# CUSTOMIZATION:
# - Update the host list in the loop to match your infrastructure
# - Add domain-specific diff checks (e.g., firewall rule changes)
# - Update the issue tracker section if you use a different platform
#
set -euo pipefail

DR_DIR="$(cd "$(dirname "$0")/.." && pwd)"
SNAP_DIR="$DR_DIR/state-capture/snapshots"

# Determine which snapshots to compare
if [[ $# -ge 2 ]]; then
    OLD="$SNAP_DIR/$1"
    NEW="$SNAP_DIR/$2"
elif [[ $# -eq 1 ]]; then
    NEW="$SNAP_DIR/$1"
    OLD=$(ls -d "$SNAP_DIR"/2???-??-?? 2>/dev/null | sort | grep -v "$1" | tail -1)
else
    snapshots=($(ls -d "$SNAP_DIR"/2???-??-?? 2>/dev/null | sort))
    if [[ ${#snapshots[@]} -lt 2 ]]; then
        echo "ERROR: Need at least 2 snapshots to diff. Found ${#snapshots[@]}."
        echo "Run state-capture/capture.sh to create a new snapshot."
        exit 1
    fi
    OLD="${snapshots[-2]}"
    NEW="${snapshots[-1]}"
fi

if [[ ! -d "$OLD" ]]; then echo "ERROR: Old snapshot not found: $OLD"; exit 1; fi
if [[ ! -d "$NEW" ]]; then echo "ERROR: New snapshot not found: $NEW"; exit 1; fi

echo "Comparing snapshots:"
echo "  OLD: $(basename "$OLD")"
echo "  NEW: $(basename "$NEW")"
echo "============================================"

# Compare each host
# CUSTOMIZATION: Update this list to match your infrastructure
for host in workstation server-1 server-2 firewall; do
    echo
    echo "--- $host ---"

    OLD_DIR="$OLD/$host"
    NEW_DIR="$NEW/$host"

    if [[ ! -d "$OLD_DIR" ]]; then echo "  (no old snapshot)"; continue; fi
    if [[ ! -d "$NEW_DIR" ]]; then echo "  (no new snapshot)"; continue; fi

    # Files only in old/new
    old_files=$(ls "$OLD_DIR" 2>/dev/null | sort)
    new_files=$(ls "$NEW_DIR" 2>/dev/null | sort)
    added=$(comm -13 <(echo "$old_files") <(echo "$new_files"))
    removed=$(comm -23 <(echo "$old_files") <(echo "$new_files"))

    [[ -n "$added" ]] && echo "  ADDED files: $added"
    [[ -n "$removed" ]] && echo "  REMOVED files: $removed"

    # Key files to diff -- these are the most important indicators of change
    key_files=(
        "podman-ps.txt"        # Container changes
        "virsh-list.txt"       # VM changes
        "listening-ports.txt"  # Port changes
        "df.txt"               # Disk usage changes
        "fstab.txt"            # Mount changes
        "lsblk.txt"            # Block device changes
    )

    for f in "${key_files[@]}"; do
        if [[ -f "$OLD_DIR/$f" && -f "$NEW_DIR/$f" ]]; then
            if ! diff -q "$OLD_DIR/$f" "$NEW_DIR/$f" >/dev/null 2>&1; then
                echo
                echo "  CHANGED: $f"
                diff --unified=1 "$OLD_DIR/$f" "$NEW_DIR/$f" 2>/dev/null | head -30 || true
            fi
        fi
    done

    # Quadlet file changes (container unit additions/removals)
    for f in quadlet-files-list.txt quadlet-rootful-list.txt; do
        if [[ -f "$OLD_DIR/$f" && -f "$NEW_DIR/$f" ]]; then
            if ! diff -q "$OLD_DIR/$f" "$NEW_DIR/$f" >/dev/null 2>&1; then
                echo
                echo "  CHANGED: $f (Quadlet units added/removed)"
                diff --unified=0 "$OLD_DIR/$f" "$NEW_DIR/$f" 2>/dev/null | grep '^[+-]' | grep -v '^[+-][+-][+-]' || true
            fi
        fi
    done
done

# Issue tracker diff
echo
echo "--- issue-tracker ---"
if [[ -d "$OLD/issue-tracker" && -d "$NEW/issue-tracker" ]]; then
    if [[ -f "$OLD/issue-tracker/repos.json" && -f "$NEW/issue-tracker/repos.json" ]]; then
        old_repos=$(python3 -c "import json; print(len(json.load(open('$OLD/issue-tracker/repos.json'))))" 2>/dev/null || echo "?")
        new_repos=$(python3 -c "import json; print(len(json.load(open('$NEW/issue-tracker/repos.json'))))" 2>/dev/null || echo "?")
        echo "  Repos: $old_repos -> $new_repos"
    fi
fi

echo
echo "============================================"
echo "Diff complete."
