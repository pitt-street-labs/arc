#!/usr/bin/env bash
# capture-workstation.sh -- Capture workstation state (local, no SSH)
#
# All operations are read-only. No system state is modified.
# This runs locally on the workstation/admin machine.
#
# CUSTOMIZATION:
# - Update Docker vs. Podman sections based on your container runtime
# - Update the project discovery paths
# - Add/remove sections based on your workstation's role
#
set -euo pipefail

SNAP_DIR="${1:-$(dirname "$0")/snapshots/$(date +%Y-%m-%d)/workstation}"
mkdir -p "$SNAP_DIR"
echo "Capturing workstation state to $SNAP_DIR ..."

# --- System identity ---
hostnamectl > "$SNAP_DIR/hostnamectl.txt" 2>&1 || true
uname -a > "$SNAP_DIR/uname.txt"
cat /etc/os-release > "$SNAP_DIR/os-release.txt"
cat /etc/lsb-release > "$SNAP_DIR/lsb-release.txt" 2>/dev/null || true
lscpu > "$SNAP_DIR/lscpu.txt"
free -h > "$SNAP_DIR/memory.txt"
timedatectl > "$SNAP_DIR/timedatectl.txt" 2>&1 || true

# --- Storage ---
lsblk -f > "$SNAP_DIR/lsblk.txt"
df -hT > "$SNAP_DIR/df.txt"
cat /etc/fstab > "$SNAP_DIR/fstab.txt"
mount | grep -v 'type cgroup\|type proc\|type sys\|type devtmpfs\|type tmpfs\|type securityfs\|type pstore\|type bpf\|type fusectl\|type configfs\|type debugfs\|type hugetlbfs\|type mqueue\|type tracefs\|type fuse.portal\|type nsfs' > "$SNAP_DIR/mounts-filtered.txt" || true

# --- Hardware ---
lspci > "$SNAP_DIR/lspci.txt"
lsusb > "$SNAP_DIR/lsusb.txt" 2>/dev/null || true

# --- Network ---
ip addr > "$SNAP_DIR/ip-addr.txt"
ip link > "$SNAP_DIR/ip-link.txt"
ip route > "$SNAP_DIR/ip-route.txt"
resolvectl status > "$SNAP_DIR/resolvectl.txt" 2>&1 || true
ss -tlnp > "$SNAP_DIR/listening-ports.txt" 2>/dev/null || true

# --- NFS ---
cat /etc/exports > "$SNAP_DIR/nfs-exports.txt" 2>/dev/null || echo "No /etc/exports" > "$SNAP_DIR/nfs-exports.txt"
showmount -e localhost > "$SNAP_DIR/nfs-showmount.txt" 2>/dev/null || echo "showmount failed" > "$SNAP_DIR/nfs-showmount.txt"

# --- SSH config ---
# CUSTOMIZATION: Update path if your SSH config is elsewhere
cat ~/.ssh/config > "$SNAP_DIR/ssh-config.txt" 2>/dev/null || true

# --- Docker containers ---
# CUSTOMIZATION: Remove this section if you use Podman instead
docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}' > "$SNAP_DIR/docker-ps.txt" 2>/dev/null || echo "Docker not running" > "$SNAP_DIR/docker-ps.txt"
docker images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}' > "$SNAP_DIR/docker-images.txt" 2>/dev/null || true
docker network ls > "$SNAP_DIR/docker-networks.txt" 2>/dev/null || true
docker volume ls > "$SNAP_DIR/docker-volumes.txt" 2>/dev/null || true

# Docker compose projects
# CUSTOMIZATION: Update the search path for your projects
find ~/projects -maxdepth 3 -name "docker-compose.yml" -o -name "docker-compose.yaml" -o -name "compose.yml" -o -name "compose.yaml" 2>/dev/null | sort > "$SNAP_DIR/docker-compose-projects.txt" || true

# --- Packages ---
# CUSTOMIZATION: Use rpm -qa for Fedora/RHEL
dpkg -l > "$SNAP_DIR/dpkg-list.txt" 2>/dev/null || true
pip list --format=columns > "$SNAP_DIR/pip-list.txt" 2>/dev/null || true
pipx list > "$SNAP_DIR/pipx-list.txt" 2>/dev/null || true
snap list > "$SNAP_DIR/snap-list.txt" 2>/dev/null || true
flatpak list > "$SNAP_DIR/flatpak-list.txt" 2>/dev/null || true

# --- Systemd units ---
systemctl list-units --type=service --all --no-pager > "$SNAP_DIR/systemd-services.txt" 2>/dev/null || true
systemctl list-timers --all --no-pager > "$SNAP_DIR/systemd-timers.txt" 2>/dev/null || true
systemctl --user list-units --type=service --all --no-pager > "$SNAP_DIR/systemd-user-services.txt" 2>/dev/null || true
systemctl --user list-timers --all --no-pager > "$SNAP_DIR/systemd-user-timers.txt" 2>/dev/null || true

# --- Cron ---
crontab -l > "$SNAP_DIR/crontab.txt" 2>/dev/null || echo "No crontab" > "$SNAP_DIR/crontab.txt"

# --- Custom scripts ---
ls -la ~/bin/ > "$SNAP_DIR/custom-scripts-bin.txt" 2>/dev/null || echo "No ~/bin/" > "$SNAP_DIR/custom-scripts-bin.txt"
ls -la ~/.local/bin/ > "$SNAP_DIR/custom-scripts-local-bin.txt" 2>/dev/null || echo "No ~/.local/bin/" > "$SNAP_DIR/custom-scripts-local-bin.txt"

# --- Project inventory ---
# CUSTOMIZATION: Update paths for your project structure
ls ~/projects/ 2>/dev/null > "$SNAP_DIR/projects-list.txt" || true

echo "Workstation capture complete: $(ls "$SNAP_DIR" | wc -l) files"
