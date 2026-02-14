#!/usr/bin/env bash
# capture.sh -- Master orchestrator for all state captures
#
# Runs all capture scripts sequentially and produces a manifest.
# Each capture script connects to a target system (via SSH or API)
# and collects read-only state information for disaster recovery.
#
# CUSTOMIZATION:
# - Update the target list below to match your infrastructure
# - Update SSH targets (user@host) in each capture-*.sh script
# - Add or remove capture targets as needed
#
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
DATE=$(date +%Y-%m-%d)
SNAP_DIR="$SCRIPT_DIR/snapshots/$DATE"
MANIFEST="$SNAP_DIR/manifest.json"

echo "============================================"
echo "  Infrastructure State Capture"
echo "  Date: $DATE"
echo "============================================"
echo

# Workstation (local, always available)
echo "[1/5] Capturing workstation state..."
bash "$SCRIPT_DIR/capture-workstation.sh" "$SNAP_DIR/workstation"
echo

# Server 1 (SSH)
echo "[2/5] Capturing server-1 state..."
if ssh -o ConnectTimeout=5 labadmin@10.0.20.10 true 2>/dev/null; then
    bash "$SCRIPT_DIR/capture-server-1.sh" "$SNAP_DIR/server-1"
else
    echo "WARNING: server-1 unreachable, skipping"
    mkdir -p "$SNAP_DIR/server-1"
    echo "UNREACHABLE at $(date)" > "$SNAP_DIR/server-1/FAILED.txt"
fi
echo

# Server 2 (SSH)
echo "[3/5] Capturing server-2 state..."
if ssh -o ConnectTimeout=5 labadmin@10.0.20.20 true 2>/dev/null; then
    bash "$SCRIPT_DIR/capture-server-2.sh" "$SNAP_DIR/server-2"
else
    echo "WARNING: server-2 unreachable, skipping"
    mkdir -p "$SNAP_DIR/server-2"
    echo "UNREACHABLE at $(date)" > "$SNAP_DIR/server-2/FAILED.txt"
fi
echo

# Firewall (SSH)
echo "[4/5] Capturing firewall state..."
if ssh -o ConnectTimeout=5 root@10.0.10.1 true 2>/dev/null; then
    bash "$SCRIPT_DIR/capture-firewall.sh" "$SNAP_DIR/firewall"
else
    echo "WARNING: firewall unreachable, skipping"
    mkdir -p "$SNAP_DIR/firewall"
    echo "UNREACHABLE at $(date)" > "$SNAP_DIR/firewall/FAILED.txt"
fi
echo

# Issue Tracker (API)
# CUSTOMIZATION: Update the URL and token for your issue tracker
echo "[5/5] Capturing issue tracker state..."
TRACKER_URL="https://git.lab.example.com:8084"
if curl -sk --connect-timeout 5 "${TRACKER_URL}/api/v1/version" >/dev/null 2>&1; then
    bash "$SCRIPT_DIR/capture-issue-tracker.sh" "$SNAP_DIR/issue-tracker"
else
    echo "WARNING: Issue tracker unreachable, skipping"
    mkdir -p "$SNAP_DIR/issue-tracker"
    echo "UNREACHABLE at $(date)" > "$SNAP_DIR/issue-tracker/FAILED.txt"
fi
echo

# Generate manifest
TOTAL_FILES=$(find "$SNAP_DIR" -type f | wc -l)
TOTAL_SIZE=$(du -sh "$SNAP_DIR" | cut -f1)
cat > "$MANIFEST" <<EOF
{
  "capture_date": "$DATE",
  "capture_time": "$(date -Iseconds)",
  "hostname": "$(hostname)",
  "total_files": $TOTAL_FILES,
  "total_size": "$TOTAL_SIZE",
  "targets": {
    "workstation": $(test -f "$SNAP_DIR/workstation/FAILED.txt" && echo '"FAILED"' || echo "$(ls "$SNAP_DIR/workstation/" 2>/dev/null | wc -l)"),
    "server-1": $(test -f "$SNAP_DIR/server-1/FAILED.txt" && echo '"FAILED"' || echo "$(ls "$SNAP_DIR/server-1/" 2>/dev/null | wc -l)"),
    "server-2": $(test -f "$SNAP_DIR/server-2/FAILED.txt" && echo '"FAILED"' || echo "$(ls "$SNAP_DIR/server-2/" 2>/dev/null | wc -l)"),
    "firewall": $(test -f "$SNAP_DIR/firewall/FAILED.txt" && echo '"FAILED"' || echo "$(ls "$SNAP_DIR/firewall/" 2>/dev/null | wc -l)"),
    "issue-tracker": $(test -f "$SNAP_DIR/issue-tracker/FAILED.txt" && echo '"FAILED"' || echo "$(ls "$SNAP_DIR/issue-tracker/" 2>/dev/null | wc -l)")
  }
}
EOF

echo "============================================"
echo "  Capture complete!"
echo "  Files: $TOTAL_FILES"
echo "  Size:  $TOTAL_SIZE"
echo "  Path:  $SNAP_DIR"
echo "============================================"
