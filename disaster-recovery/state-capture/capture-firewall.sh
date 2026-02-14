#!/usr/bin/env bash
# capture-firewall.sh -- Capture firewall state via SSH (read-only)
#
# All operations are read-only. No system state is modified.
# This script is written for an OPNsense/FreeBSD firewall.
#
# CUSTOMIZATION:
# - Update FIREWALL variable with your firewall's SSH target
# - For pfSense: commands are similar (pfctl, ifconfig)
# - For VyOS: replace with `show` commands (show configuration, show interfaces, etc.)
# - For Linux iptables/nftables: replace pfctl with iptables-save/nft list ruleset
# - Add/remove capture commands based on your firewall's services
#
set -euo pipefail

FIREWALL="root@10.0.10.1"
SNAP_DIR="${1:-$(dirname "$0")/snapshots/$(date +%Y-%m-%d)/firewall}"
mkdir -p "$SNAP_DIR"
echo "Capturing firewall state to $SNAP_DIR ..."

# Helper: run command via SSH, save output to file
run() { ssh -o ConnectTimeout=10 "$FIREWALL" "$1" > "$SNAP_DIR/$2" 2>&1 || echo "FAILED: $1" > "$SNAP_DIR/$2.err"; }

# System identity
run "uname -a" "uname.txt"
run "freebsd-version" "freebsd-version.txt"
# CUSTOMIZATION: Replace with your firewall's version command
run "opnsense-version" "opnsense-version.txt"

# Storage
run "df -h" "df.txt"
# CUSTOMIZATION: FreeBSD uses gpart; Linux uses lsblk
run "gpart show" "gpart.txt"

# Network
run "ifconfig -a" "ifconfig.txt"
# CUSTOMIZATION: Update the aggregation interface name (lagg0, bond0, etc.)
run "ifconfig lagg0" "lagg0.txt"
run "netstat -rn -f inet" "routing-table.txt"
run "sockstat -4 -l" "netstat-inet.txt"

# Firewall rules (pf)
# CUSTOMIZATION: For iptables, use: iptables-save
# CUSTOMIZATION: For nftables, use: nft list ruleset
run "pfctl -sr" "pf-rules.txt"
run "pfctl -sn" "pf-nat.txt"
run "pfctl -sa" "pf-all.txt"
run "pfctl -si" "pf-info.txt"

# VLANs
run "ifconfig | grep -A2 'vlan[0-9]'" "vlan-group.txt"

# DNS (Unbound)
# CUSTOMIZATION: Update paths for your DNS resolver config
run "cat /var/unbound/host_entries.conf 2>/dev/null || echo 'No host entries file'" "unbound-host-entries.txt"
run "cat /var/unbound/domainoverrides.conf 2>/dev/null || echo 'No domain overrides'" "unbound-domain-entries.txt"

# DHCP leases
run "cat /var/dhcpd/var/db/dhcpd.leases 2>/dev/null || echo 'No ISC leases'" "dhcp-leases.txt"

# VPN
# CUSTOMIZATION: Update for your VPN software (WireGuard, OpenVPN, IPsec)
run "wg show 2>/dev/null || echo 'WireGuard not active'" "wireguard.txt"

# Full config export (WARNING: may contain passwords -- handle carefully)
# CUSTOMIZATION: Update config file path for your firewall OS
run "cat /conf/config.xml" "config.xml"

# Installed packages/plugins
run "pkg info" "pkg-info.txt"
run "opnsense-version -l 2>/dev/null || pkg query '%n-%v' | grep -i opnsense" "opnsense-plugins.txt"

# TLS certificates
run "ls -la /usr/local/etc/ssl/certs/ 2>/dev/null || echo 'no cert dir'" "cert-files.txt"

echo "Firewall capture complete: $(ls "$SNAP_DIR" | wc -l) files"
