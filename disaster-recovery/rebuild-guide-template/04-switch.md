# Chapter 04 -- Managed Switch

**Depends on:** [Chapter 01](./01-physical-topology.md), [Chapter 03](./03-firewall.md)
**Required before:** [Chapters 05+](./05-server-1-os.md)

## Overview

<!-- Describe your switch: model, L2/L3, port count, PoE, LACP capabilities -->

| Property | Value |
|----------|-------|
| Model | <!-- model number --> |
| Firmware | <!-- IOS version, firmware --> |
| Ports | <!-- count, PoE budget --> |
| Management IP | <!-- IP/mask on management VLAN SVI --> |
| Default Gateway | <!-- firewall management IP --> |
| LACP Hash | <!-- src-dst-ip, L3+4, etc. --> |

---

## VLAN Configuration

| VLAN | Name | Subnet | Purpose |
|------|------|--------|---------|
| <!-- 10 --> | Management | <!-- subnet --> | Switch mgmt, BMCs |
| <!-- 20 --> | Servers | <!-- subnet --> | Production services |
| <!-- etc. --> | | | |

### VLAN Creation Commands

```
! Adapt for your switch OS (IOS, NX-OS, EOS, JunOS, etc.)
enable
configure terminal

vlan 10
 name Management
vlan 20
 name Servers
! ... etc.
exit
```

### Management SVI

```
interface Vlan10
 ip address <switch-ip> <mask>
 no shutdown
!
ip default-gateway <firewall-ip>
```

---

## Port Assignments

### LACP Port-Channels

| Physical Ports | Port-Channel | Mode | Description |
|----------------|-------------|------|-------------|
| <!-- ports --> | <!-- Po1 --> | Trunk | Firewall LACP |
| <!-- ports --> | <!-- Po2 --> | Trunk | Server 2 LACP |
| <!-- ports --> | <!-- Po3 --> | Trunk | Server 1 LACP |

### BMC Access Ports

| Port | Mode | VLAN | Description |
|------|------|------|-------------|
| <!-- port --> | Access | <!-- mgmt VLAN --> | <!-- server BMC --> |

### VoIP Ports

| Port | Mode | VLAN | Description |
|------|------|------|-------------|
| <!-- port --> | Access | <!-- VoIP VLAN --> | <!-- phone model (PoE) --> |

### Endpoint Ports

| Port | Mode | VLAN/Trunk | Description |
|------|------|------------|-------------|
| <!-- port --> | Trunk | <!-- VLANs --> | WiFi AP |
| <!-- port --> | Trunk | <!-- VLANs --> | Workstation |

---

## Switch Configuration -- Trunks and Port-Channels

<!-- Paste full config blocks for each port-channel, trunk, and access port.
     This is the most critical section -- it must be paste-ready for rebuild. -->

### Firewall LACP

```
! Example for Cisco IOS:
interface range GigabitEthernet1/0/X, GigabitEthernet1/0/Y
 description Firewall LACP
 switchport mode trunk
 switchport trunk allowed vlan <vlan-list>
 channel-group 1 mode active
 spanning-tree portfast trunk
 no shutdown
!
interface Port-channel1
 description Firewall-LAGG
 switchport mode trunk
 switchport trunk allowed vlan <vlan-list>
```

### Server Port-Channels

<!-- Repeat for each server -->

### Access and Trunk Ports

<!-- Individual port configs for BMCs, phones, endpoints -->

---

## Spanning Tree

<!-- Document STP mode, portfast settings, root bridge priority -->

```
spanning-tree mode rapid-pvst
spanning-tree extend system-id
```

---

## PoE Configuration

| Port | Device | Expected Draw |
|------|--------|---------------|
| <!-- port --> | <!-- device --> | <!-- watts --> |

---

## Management Access

### SSH

```bash
# May need legacy ciphers for older switches:
# ssh -o KexAlgorithms=+diffie-hellman-group14-sha1 \
#     -o HostKeyAlgorithms=+ssh-rsa admin@<switch-ip>
```

### Serial Console (Fallback)

```bash
# USB console cable, typical settings:
# screen /dev/ttyACM0 9600
```

---

## Recovery Procedure

### Step 1: Factory Reset

<!-- How to erase config and reload -->

### Step 2: Initial Setup

<!-- Hostname, domain, SSH keys, management VLAN/IP, credentials -->

### Step 3: Create VLANs

<!-- Apply VLAN database commands -->

### Step 4: Configure Ports

<!-- Apply port-channel, trunk, and access port configs -->

### Step 5: Services

<!-- NTP, syslog, LACP hash, STP -->

### Step 6: Verify

```
show vlan brief
show interfaces trunk
show etherchannel summary
show ip interface brief
show power inline
```

### Step 7: Save

```
copy running-config startup-config
```

---

## Verification Commands Reference

| Command | Purpose |
|---------|---------|
| `show vlan brief` | VLANs and port membership |
| `show interfaces trunk` | Trunking ports and allowed VLANs |
| `show etherchannel summary` | LACP status |
| `show ip interface brief` | Interface IPs and status |
| `show power inline` | PoE budget and per-port status |
| `show mac address-table` | MAC to port mappings |
| `show running-config` | Full active configuration |

---

## Troubleshooting

### LACP Not Forming

<!-- Steps to diagnose LACP issues -->

### SSH Connection Refused

<!-- Steps to restore SSH access -->

### PoE Device Not Powering

<!-- Steps to diagnose PoE issues -->

### Trunk Not Passing VLAN Traffic

<!-- Steps to diagnose trunk issues -->

---

## Verification Checklist

- [ ] All VLANs exist in VLAN database
- [ ] All port-channels show active/bundled
- [ ] All trunks show correct allowed VLANs
- [ ] Management SVI is reachable from workstation
- [ ] PoE devices are powered
- [ ] SSH access works with credentials from vault
