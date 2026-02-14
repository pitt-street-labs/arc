#!/usr/bin/env bash
# capture-server-1.sh -- Capture primary server state via SSH (read-only)
#
# All operations are read-only. No system state is modified.
# Captures: system identity, storage, network, containers, packages, VMs, cron.
#
# CUSTOMIZATION:
# - Update SERVER variable with your server's SSH target (user@ip)
# - Update VM names in the virsh loop at the bottom
# - Add/remove sections based on your server's role
#
set -euo pipefail

SERVER="labadmin@10.0.20.10"
SNAP_DIR="${1:-$(dirname "$0")/snapshots/$(date +%Y-%m-%d)/server-1}"
mkdir -p "$SNAP_DIR"
echo "Capturing server-1 state to $SNAP_DIR ..."

# Helper: run command via SSH, save output to file
run() { ssh "$SERVER" "$1" > "$SNAP_DIR/$2" 2>&1 || echo "FAILED: $1" > "$SNAP_DIR/$2.err"; }

# --- System identity ---
run "hostnamectl" "hostnamectl.txt"
run "uname -a" "uname.txt"
run "cat /etc/os-release" "os-release.txt"
run "lscpu" "lscpu.txt"
run "free -h" "memory.txt"
run "timedatectl" "timedatectl.txt"

# --- Storage ---
run "lsblk -f" "lsblk.txt"
run "df -hT" "df.txt"
run "cat /etc/fstab" "fstab.txt"
run "cat /etc/crypttab" "crypttab.txt"
run "sudo -n lvs --noheadings -o lv_name,vg_name,lv_size,lv_attr 2>/dev/null || echo 'lvs requires root'" "lvm-lvs.txt"
run "sudo -n pvs --noheadings 2>/dev/null || echo 'pvs requires root'" "lvm-pvs.txt"
run "sudo -n vgs --noheadings 2>/dev/null || echo 'vgs requires root'" "lvm-vgs.txt"
# Filter out virtual filesystems for readable mount list
run "mount | grep -v 'type cgroup\|type proc\|type sys\|type devtmpfs\|type tmpfs\|type securityfs\|type pstore\|type bpf\|type fusectl\|type configfs\|type debugfs\|type hugetlbfs\|type mqueue\|type tracefs\|type nsfs\|type overlay'" "mounts-filtered.txt"

# --- Hardware ---
run "lspci" "lspci.txt"
run "lsusb 2>/dev/null || echo no lsusb" "lsusb.txt"

# --- Network ---
run "ip addr" "ip-addr.txt"
run "ip route" "ip-route.txt"
run "nmcli device status 2>/dev/null || echo no nmcli" "nmcli-devices.txt"
run "nmcli connection show 2>/dev/null || echo no nmcli" "nmcli-connections.txt"
run "ss -tlnp" "listening-ports.txt"
run "sudo -n firewall-cmd --list-all-zones 2>/dev/null || echo 'firewalld not active'" "firewalld-zones.txt"

# --- NFS ---
run "mount | grep nfs" "nfs-mounts.txt"
run "showmount -e localhost 2>/dev/null || echo 'no NFS exports'" "nfs-showmount.txt"

# --- Podman containers (rootless, user-level) ---
run "podman ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'" "podman-ps.txt"
run "podman images --format 'table {{.Repository}}\t{{.Tag}}\t{{.Size}}'" "podman-images.txt"
run "podman network ls" "podman-networks.txt"
run "podman volume ls" "podman-volumes.txt"

# --- Quadlet container definitions ---
# CUSTOMIZATION: Update path if your Quadlet files are elsewhere
run "ls ~/.config/containers/systemd/*.container ~/.config/containers/systemd/*.network 2>/dev/null" "quadlet-files-list.txt"
run "for f in ~/.config/containers/systemd/*.container ~/.config/containers/systemd/*.network; do echo '=== \$f ==='; cat \"\$f\" 2>/dev/null; echo; done" "quadlet-files-full.txt"

# --- Packages ---
# CUSTOMIZATION: Replace rpm with dpkg for Debian/Ubuntu
run "rpm -qa --qf '%{NAME}-%{VERSION}-%{RELEASE}.%{ARCH}\n' | sort" "rpm-list.txt"
run "pip list --format=columns 2>/dev/null || echo 'no pip'" "pip-list.txt"
run "pipx list 2>/dev/null || echo 'no pipx'" "pipx-list.txt"

# --- Systemd units ---
run "systemctl list-units --type=service --all --no-pager" "systemd-services.txt"
run "systemctl list-timers --all --no-pager" "systemd-timers.txt"
run "systemctl --user list-units --type=service --all --no-pager" "systemd-user-services.txt"
run "systemctl --user list-timers --all --no-pager" "systemd-user-timers.txt"

# --- Cron ---
run "crontab -l 2>/dev/null || echo 'No crontab'" "crontab.txt"

# --- Custom scripts ---
run "ls -la ~/bin/ 2>/dev/null || echo 'No ~/bin/'" "custom-scripts.txt"

# --- VMs (libvirt) ---
run "sudo -n virsh list --all" "virsh-list.txt"
run "sudo -n virsh net-list --all" "virsh-networks.txt"
run "sudo -n virsh pool-list --all" "virsh-pools.txt"
# CUSTOMIZATION: Update VM names to match your inventory
for vm in dc-1 test-vm-1 test-vm-2; do
    run "sudo -n virsh dumpxml $vm 2>/dev/null || echo 'VM $vm not found'" "vm-${vm}.xml"
done

echo "Server-1 capture complete: $(ls "$SNAP_DIR" | wc -l) files"
