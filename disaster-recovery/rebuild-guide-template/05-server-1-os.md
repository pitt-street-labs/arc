# Chapter 05 -- Server 1 OS Installation & Configuration

**Depends on:** [Chapters 01-04](./01-physical-topology.md)
**Required before:** [Chapter 06](./06-server-1-services.md)

## Hardware Summary

| Property | Value |
|----------|-------|
| Model | <!-- model --> |
| CPU | <!-- model, cores, threads --> |
| RAM | <!-- size, ECC, DIMM config --> |
| NICs | <!-- count, model, driver --> |
| Storage | <!-- drives, controllers --> |
| OOB | <!-- BMC type at IP --> |

---

## Step 1: Install OS

| Property | Value |
|----------|-------|
| OS | <!-- Fedora/Ubuntu/Debian version --> |
| Hostname | <!-- hostname --> |
| Timezone | <!-- timezone --> |
| Admin User | <!-- username (wheel/sudo group, passwordless sudo) --> |

### Installation

1. Boot from installation media via BMC virtual media or USB
2. Configure: hostname, timezone, admin user, disk layout (see Step 2)
3. Set hostname after install: `hostnamectl set-hostname <name>`

---

## Step 2: Disk Layout -- Root Volume (LUKS + LVM)

### Partition Table

| Partition | Size | Filesystem | Mount | Purpose |
|-----------|------|------------|-------|---------|
| <!-- sda1 --> | <!-- size --> | vfat | /boot/efi | EFI System Partition |
| <!-- sda2 --> | <!-- size --> | xfs | /boot | Kernel and initramfs |
| <!-- sda3 --> | <!-- size --> | LVM (LUKS) | / | Root filesystem |
| <!-- sda4 --> | <!-- size --> | <!-- fs --> | <!-- mount --> | Scratch/optional |

### LVM Layout

| VG | PV | LV | Size | Mount |
|----|----|----|------|-------|
| <!-- vg_name --> | <!-- /dev/sdX --> | root | <!-- size --> | / |

---

## Step 3: Additional Data Volumes (LUKS + LVM)

<!-- If you have NVMe or additional drives for data -->

### Create LUKS Containers

```bash
# Generate keyfiles for auto-unlock
mkdir -p /etc/luks-keys
dd if=/dev/urandom of=/etc/luks-keys/<volume-name> bs=4096 count=1
chmod 600 /etc/luks-keys/<volume-name>

# Encrypt
cryptsetup luksFormat --type luks2 /dev/<device> /etc/luks-keys/<volume-name>

# Open
cryptsetup luksOpen /dev/<device> <volume-name> --key-file /etc/luks-keys/<volume-name>
```

**CRITICAL: Back up keyfiles to your vault. Without them, data is unrecoverable.**

### Create LVM (if striped/RAID0)

```bash
# For software RAID0 across multiple drives:
pvcreate /dev/mapper/<vol1> /dev/mapper/<vol2>
vgcreate <vg-name> /dev/mapper/<vol1> /dev/mapper/<vol2>
lvcreate -n <lv-name> -l 100%FREE --stripes 2 <vg-name>
mkfs.xfs -L <label> /dev/<vg-name>/<lv-name>
```

---

## Step 4: Configure /etc/crypttab

```bash
# Root volume: manual passphrase at boot
<luks-name> UUID=<uuid> none discard

# Data volumes: auto-unlock via keyfile
<data-vol> UUID=<uuid> /etc/luks-keys/<keyfile> discard
```

Key points:
- Root volume uses `none` -- prompts for passphrase at boot via console
- Data volumes auto-unlock via keyfiles once root is mounted
- `discard` enables TRIM passthrough (important for SSD/NVMe)

---

## Step 5: Configure /etc/fstab

```bash
# Root
/dev/mapper/<luks-root-name> /  xfs  defaults,x-systemd.device-timeout=0  0 0

# Boot
UUID=<boot-uuid>  /boot  xfs  defaults  0 0

# EFI
UUID=<efi-uuid>  /boot/efi  vfat  umask=0077  0 2

# Data volumes
/dev/<vg>/<lv>  /data  xfs  defaults,nofail  0 0

# NFS mounts (if any -- use nofail and automount to prevent boot hangs)
# <remote-ip>:/export/path /mnt/name nfs4 vers=4.2,_netdev,nofail,x-systemd.automount 0 0
```

---

## Step 6: Network -- LACP Bond

### Physical NIC Map

| NIC | Switch Port | Notes |
|-----|-------------|-------|
| <!-- eno1 --> | <!-- port --> | Bond member |
| <!-- eno2 --> | <!-- port --> | Bond member |
| <!-- eno3 --> | <!-- port --> | Bond member |
| <!-- eno4 --> | <!-- port --> | Bond member |

### Create the Bond

```bash
# CRITICAL: ipv6.method=disabled prevents SLAAC cycling (see Gotchas)
nmcli connection add type bond con-name bond0 ifname bond0 \
  bond.options "mode=802.3ad,miimon=100,lacp_rate=fast,xmit_hash_policy=layer3+4" \
  ipv4.method disabled ipv6.method disabled

# Add slave interfaces
nmcli connection add type ethernet con-name bond0-eno1 ifname eno1 master bond0
nmcli connection add type ethernet con-name bond0-eno2 ifname eno2 master bond0
nmcli connection add type ethernet con-name bond0-eno3 ifname eno3 master bond0
nmcli connection add type ethernet con-name bond0-eno4 ifname eno4 master bond0

nmcli connection up bond0
```

---

## Step 7: Network -- Bridge for Server VLAN

<!-- If VMs need direct VLAN access, create a bridge on top of the bond -->

```bash
nmcli connection add type bridge con-name br-servers ifname br-servers \
  ipv4.method manual ipv4.addresses <server-ip>/24 ipv4.gateway <gateway> \
  ipv4.dns <dns-ip> ipv6.method disabled

# Make bond0 a bridge slave (modify in-place -- NEVER down bond0 first)
nmcli connection modify bond0 connection.master br-servers connection.slave-type bridge \
  ipv4.method disabled ipv4.addresses "" ipv4.gateway "" ipv4.dns ""

nmcli connection up bond0
nmcli connection up br-servers
```

---

## Step 8: Network -- Management VLAN Subinterface

```bash
nmcli connection add type vlan con-name bond0.<vlan-id> ifname bond0.<vlan-id> \
  vlan.parent bond0 vlan.id <vlan-id> \
  ipv4.method manual ipv4.addresses <mgmt-ip>/24 \
  ipv6.method disabled
```

---

## Step 9: Routing Table

<!-- Expected routes after configuration -->

```
default via <gateway-ip> dev br-servers
<mgmt-subnet> dev bond0.<vlan-id> src <mgmt-ip>
<server-subnet> dev br-servers src <server-ip>
```

---

## Step 10: FirewallD Configuration

### Zone Assignments

| Zone | Interfaces | Purpose |
|------|-----------|---------|
| <!-- lab-servers (default) --> | bond0, br-servers | Server traffic |
| <!-- lab-mgmt --> | bond0.<vlan-id> | Management (restricted) |
| <!-- trusted --> | <!-- podman subnet --> | Container traffic |

### Create Zones and Rules

```bash
firewall-cmd --permanent --new-zone=lab-servers
firewall-cmd --permanent --new-zone=lab-mgmt
firewall-cmd --permanent --set-default-zone=lab-servers

# lab-servers zone: SSH, HTTP, HTTPS, container ports
firewall-cmd --permanent --zone=lab-servers --add-service=ssh
firewall-cmd --permanent --zone=lab-servers --add-service=http
firewall-cmd --permanent --zone=lab-servers --add-service=https
# Add container ports as needed:
# firewall-cmd --permanent --zone=lab-servers --add-port=XXXX/tcp

# lab-mgmt zone: SSH + monitoring only
firewall-cmd --permanent --zone=lab-mgmt --add-service=ssh
firewall-cmd --permanent --zone=lab-mgmt --add-port=9100/tcp  # node_exporter

firewall-cmd --reload
```

---

## Step 11: NFS (Server and/or Client)

<!-- Document NFS exports and client mounts -->

---

## Step 12: Podman Rootless Setup

```bash
# Install
dnf install -y podman podman-plugins slirp4netns fuse-overlayfs aardvark-dns netavark

# Enable lingering
loginctl enable-linger <username>

# Verify subuid/subgid
grep <username> /etc/subuid /etc/subgid

# Quadlet directory
mkdir -p ~/.config/containers/systemd/
```

**CRITICAL: Use Quadlet + systemctl only. Never use podman-compose for persistent containers.**

---

## Step 13: Libvirt/KVM Setup

```bash
dnf install -y @virtualization-headless libvirt-daemon-kvm qemu-kvm virt-install
systemctl enable --now libvirtd
```

### Virtual Networks

| Name | Subnet | Purpose |
|------|--------|---------|
| <!-- primary-bridge --> | <!-- uses br-servers --> | VMs on server VLAN |

### VM Inventory

| VM | State | Autostart | Network | Purpose |
|----|-------|-----------|---------|---------|
| <!-- dc1 --> | running | yes | <!-- bridge --> | <!-- purpose --> |

---

## Step 14: System Services

```bash
systemctl enable --now sshd firewalld chronyd NetworkManager
systemctl enable --now node_exporter smartd
systemctl enable --now libvirtd
systemctl enable --now fail2ban
```

### Passwordless Sudo

```bash
echo '<username> ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/<username>
chmod 440 /etc/sudoers.d/<username>
```

---

## Step 15: LUKS Unlock Procedure (Boot Recovery)

<!-- Document the specific method to unlock LUKS after reboot.
     Include: which BMC console method works, any scripts, manual procedure. -->

### Boot Sequence After LUKS Unlock

1. Root LUKS passphrase entered via BMC console
2. systemd-cryptsetup opens root volume
3. LVM activates root LV
4. `/etc/luks-keys/` becomes available
5. Data volumes auto-unlock via keyfiles
6. Network comes up (bond -> bridge -> VLANs)
7. Podman containers start via user services
8. VMs resume via libvirt-guests

---

## Known Gotchas

<!-- Document any platform-specific gotchas -->

1. **IPv6 SLAAC Bond Cycling**: If `ipv6.method=auto` on bond0, NetworkManager cycles the bond every ~35s waiting for Router Advertisements. Always use `ipv6.method=disabled`.

2. **Bridge-on-Bond Migration**: Never `nmcli con down bond0` to add a bridge. Modify the existing connection in-place.

3. **LUKS Boot Recovery**: If bond0 goes down, recovery requires BMC console for LUKS re-entry after reboot.

4. **Container Boot Storm on HDD**: Many containers starting simultaneously can overwhelm spinning disks. Use `After=` dependencies in Quadlet files.

---

## Verification Checklist

| Check | Command | Expected |
|-------|---------|----------|
| Hostname | `hostnamectl` | <!-- name --> |
| LUKS root | `cryptsetup status <name>` | active |
| LVM | `lvs` | <!-- expected LVs --> |
| Bond | `cat /proc/net/bonding/bond0` | 4 slaves UP |
| Bridge IP | `ip addr show br-servers` | <!-- IP --> |
| Default route | `ip route show default` | via <!-- gateway --> |
| FirewallD | `firewall-cmd --get-active-zones` | <!-- zones --> |
| Podman | `podman info` | rootless, overlay |
| libvirtd | `virsh list --all` | <!-- VMs --> |
| SSH from workstation | `ssh <host> hostname` | <!-- hostname --> |
