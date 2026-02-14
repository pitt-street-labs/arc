#!/usr/bin/env bash
# validate.sh -- Compare rebuild guide claims against latest state snapshot
#
# Checks for drift between documentation and reality by verifying:
# 1. All expected chapter files exist
# 2. All snapshot directories have data
# 3. Container and VM counts match expectations
# 4. Knowledge archive is current
#
# CUSTOMIZATION:
# - Update the chapter list in Check 1 to match your guide structure
# - Update expected VM counts in Check 5
# - Update the knowledge archive paths in Check 6
# - Add domain-specific checks for your infrastructure
#
set -euo pipefail

DR_DIR="$(cd "$(dirname "$0")/.." && pwd)"
GUIDE_DIR="$DR_DIR/rebuild-guide"
SNAP_DIR="$DR_DIR/state-capture/snapshots"
ERRORS=0
WARNINGS=0

# Find latest snapshot
LATEST_SNAP=$(ls -d "$SNAP_DIR"/2???-??-?? 2>/dev/null | sort | tail -1)
if [[ -z "$LATEST_SNAP" ]]; then
    echo "ERROR: No snapshots found in $SNAP_DIR"
    echo "Run state-capture/capture.sh to create one."
    exit 1
fi
echo "Validating against snapshot: $LATEST_SNAP"
echo "============================================"

err()  { echo "  ERROR: $1"; ERRORS=$((ERRORS+1)); }
warn() { echo "  WARN:  $1"; WARNINGS=$((WARNINGS+1)); }
ok()   { echo "  OK:    $1"; }

# --- Check 1: All expected chapter files exist ---
# CUSTOMIZATION: Update this list to match your chapter filenames
echo
echo "[1] Checking chapter files exist..."
for ch in 00-README 01-physical-topology 02-secrets-and-credentials \
          03-firewall 04-switch 05-server-1-os 06-server-1-services \
          07-server-2-os 08-server-2-infrastructure 09-server-2-monitoring \
          10-server-2-app-services 11-voip 12-workstation \
          13-automation-environment 14-directory-services 15-vm-fleet \
          16-storage-and-media 17-pki-and-tls 18-networking-advanced \
          19-maintenance-runbooks 20-project-catalog; do
    if [[ -f "$GUIDE_DIR/${ch}.md" ]]; then
        ok "$ch.md"
    else
        err "Missing: $ch.md"
    fi
done

# --- Check 2: Snapshot completeness ---
echo
echo "[2] Checking snapshot completeness..."
# CUSTOMIZATION: Update host list to match your infrastructure
for host in workstation server-1 server-2 firewall issue-tracker; do
    if [[ -d "$LATEST_SNAP/$host" ]]; then
        count=$(ls "$LATEST_SNAP/$host" | wc -l)
        if [[ -f "$LATEST_SNAP/$host/FAILED.txt" ]]; then
            err "$host: capture FAILED"
        elif [[ $count -lt 5 ]]; then
            warn "$host: only $count files (expected 10+)"
        else
            ok "$host: $count files"
        fi
    else
        err "$host: no snapshot directory"
    fi
done

# --- Check 3: Container count drift ---
echo
echo "[3] Checking container counts..."
# CUSTOMIZATION: Update paths for your server hostnames
if [[ -f "$LATEST_SNAP/server-1/podman-ps.txt" ]]; then
    s1_containers=$(grep -c 'Up\|Exited' "$LATEST_SNAP/server-1/podman-ps.txt" 2>/dev/null || echo 0)
    ok "Server-1: $s1_containers containers in snapshot"
fi
if [[ -f "$LATEST_SNAP/server-2/podman-ps.txt" ]]; then
    s2_containers=$(grep -c 'Up\|Exited' "$LATEST_SNAP/server-2/podman-ps.txt" 2>/dev/null || echo 0)
    ok "Server-2: $s2_containers user containers in snapshot"
fi

# --- Check 4: VM count ---
echo
echo "[4] Checking VM counts..."
# CUSTOMIZATION: Update expected VM counts for your environment
EXPECTED_S1_VMS=5
EXPECTED_S2_VMS=4
if [[ -f "$LATEST_SNAP/server-1/virsh-list.txt" ]]; then
    s1_vms=$(grep -cE 'running|shut off' "$LATEST_SNAP/server-1/virsh-list.txt" 2>/dev/null || echo 0)
    if [[ $s1_vms -ne $EXPECTED_S1_VMS ]]; then
        warn "Server-1: $s1_vms VMs (expected $EXPECTED_S1_VMS)"
    else
        ok "Server-1: $s1_vms VMs"
    fi
fi
if [[ -f "$LATEST_SNAP/server-2/virsh-list.txt" ]]; then
    s2_vms=$(grep -cE 'running|shut off' "$LATEST_SNAP/server-2/virsh-list.txt" 2>/dev/null || echo 0)
    if [[ $s2_vms -ne $EXPECTED_S2_VMS ]]; then
        warn "Server-2: $s2_vms VMs (expected $EXPECTED_S2_VMS)"
    else
        ok "Server-2: $s2_vms VMs"
    fi
fi

# --- Check 5: Knowledge distillation completeness (optional) ---
echo
echo "[5] Checking knowledge distillation..."
# CUSTOMIZATION: Update these paths if you use the knowledge archive feature
KD_DIR="$DR_DIR/knowledge-distillation"
if [[ -d "$KD_DIR" ]]; then
    total_files=$(find "$KD_DIR" -type f 2>/dev/null | wc -l)
    ok "Knowledge archive: $total_files files"
else
    warn "No knowledge-distillation directory found (optional feature)"
fi

# --- Summary ---
echo
echo "============================================"
echo "  Validation complete"
echo "  Errors:   $ERRORS"
echo "  Warnings: $WARNINGS"
echo "============================================"

exit $ERRORS
