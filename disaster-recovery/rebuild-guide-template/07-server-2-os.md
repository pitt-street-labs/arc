# Chapter 07 -- Server 2 OS Installation & Configuration

**Depends on:** [Chapters 01-04](./01-physical-topology.md)
**Required before:** [Chapter 08](./08-server-2-infrastructure.md)

This chapter covers bare-metal OS installation through to a bootable, network-ready system with storage, firewall, Podman, and libvirt configured. Service deployment is covered in Chapters 08-10.

## Hardware Summary

| Component | Specification |
|-----------|---------------|
| Chassis | <!-- model --> |
| CPU | <!-- model, cores, threads --> |
| RAM | <!-- size, ECC, DIMM count --> |
| Boot disk | <!-- size, controller --> |
| NVMe | <!-- size, mount point --> |
| External storage | <!-- USB drives, NAS mounts --> |
| NICs | <!-- count, model --> |
| OOB | <!-- BMC type at IP --> |

<!-- Document any hardware health warnings (e.g., degrading DIMMs, known issues) -->

---

## Step 1: Install OS

<!-- Same structure as Chapter 05: boot media, installer config, first boot -->

---

## Step 2: Disk Partitioning and LUKS

### Target Layout

| Partition | Size | Type | Filesystem | Mount |
|-----------|------|------|------------|-------|
| <!-- sda1 --> | <!-- size --> | <!-- boot/EFI --> | <!-- fs --> | <!-- mount --> |
| <!-- sda2 --> | <!-- size --> | <!-- /boot --> | <!-- fs --> | /boot |
| <!-- sda3 --> | <!-- size --> | LVM PV (LUKS) | LVM2_member | / |

### LUKS Encryption

- **LUKS UUID:** <!-- uuid -->
- **Passphrase:** Stored in vault under `<!-- item name -->`

---

## Step 3: Post-Install Base Configuration

### Passwordless Sudo

```bash
echo '<username> ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/<username>
sudo chmod 440 /etc/sudoers.d/<username>
```

### Essential Packages

```bash
sudo dnf install -y \
  vim tmux htop \
  firewalld nftables \
  podman buildah skopeo \
  libvirt qemu-kvm virt-install \
  python3 python3-pip
```

---

## Step 4: Additional Data Volumes

<!-- NVMe, external USB drives -- LUKS + keyfile auto-unlock -->
<!-- Document each volume: LUKS setup, crypttab, fstab, mount point -->

---

## Step 5: External Storage

<!-- If you have USB-attached drives, document:
     - Hardware (model, connection)
     - LUKS setup with keyfile
     - crypttab entry with nofail flag (critical for USB -- prevents boot hang)
     - fstab entry with nofail
     - Known issues (UAS abort storms, concurrent I/O limits)
     - Recovery procedure for device lockup
-->

---

## Step 6: Complete /etc/fstab and /etc/crypttab

<!-- Paste the full contents of both files -->

---

## Step 7: Network Configuration

### Architecture

<!-- Draw the network stack: physical NICs -> bond -> bridges -> VLANs -->

```
Physical NICs (4x GbE)
       |
  bond0 (802.3ad LACP, no IP)
       |
       +---> br-servers (bridge, <server-ip>/24, default gateway)
       |       +---> VM tap interfaces
       |
       +---> bond0.<mgmt-vlan> (<mgmt-ip>/24, management)
       |
       +---> bond0.<voip-vlan> (no IP)
               +---> br-voip (bridge for PBX VM)
```

### Bond Configuration

<!-- nmcli commands to create LACP bond -->

### Bridge Configuration

<!-- nmcli commands to create bridges, assign IPs -->

### VLAN Subinterfaces

<!-- nmcli commands for each VLAN subinterface -->

### Routing Table

<!-- Expected routes -->

---

## Step 8: FirewallD Configuration

<!-- Same structure as Chapter 05: zones, interfaces, services, ports -->

---

## Step 9: Podman Setup

### Rootless (Primary)

<!-- Container count, Quadlet directory, lingering, subuid/subgid -->

### Rootful (If needed for monitoring, etc.)

<!-- Rootful Quadlet files in /etc/containers/systemd/ -->

### Critical Rules

1. Never use podman-compose
2. Never use `podman run` for persistent containers
3. Use Quadlet + systemctl for everything
4. Boot serialization with `After=` directives

---

## Step 10: Hardware Health Monitoring

<!-- EDAC/rasdaemon for memory errors, SMART for disks, temperature monitoring -->

---

## Step 11: LUKS Unlock via BMC

<!-- Document the specific remote unlock procedure for this server -->
<!-- Include: BMC SSH, text console, character-by-character delays if needed -->

---

## Step 12: Libvirt/KVM Setup

### Virtual Networks

| Network | Purpose |
|---------|---------|
| <!-- name --> | <!-- description --> |

### VM Inventory

| VM | State | Autostart | Network | Purpose |
|----|-------|-----------|---------|---------|
| <!-- name --> | <!-- state --> | <!-- yes/no --> | <!-- bridge --> | <!-- purpose --> |

---

## Verification Checklist

```bash
# 1. Hostname
hostnamectl | grep "Static hostname"

# 2. LUKS volumes
lsblk -f | grep crypto_LUKS

# 3. Filesystems
df -h / /data1

# 4. Network bond
cat /proc/net/bonding/bond0 | head -20

# 5. IP addresses
ip -4 addr show br-servers | grep inet

# 6. FirewallD zones
sudo firewall-cmd --get-active-zones

# 7. Podman
podman --version

# 8. Libvirt
sudo virsh list --all

# 9. Connectivity
ping -c 1 <gateway>
```
