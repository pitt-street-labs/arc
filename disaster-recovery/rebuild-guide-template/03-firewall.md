# Chapter 03 -- Firewall

**Depends on:** [Chapter 01](./01-physical-topology.md), [Chapter 02](./02-secrets-and-credentials.md)
**Required before:** All remaining chapters (firewall is the network foundation)

## Overview

<!-- Describe your firewall's role: gateway, routing, NAT, DNS, DHCP, VPN, IDS -->

**Recovery priority:** The firewall must be operational before any other service can function.

## Hardware

| Component | Value |
|-----------|-------|
| Chassis | <!-- model --> |
| CPU | <!-- model --> |
| RAM | <!-- size --> |
| Storage | <!-- RAID config, capacity --> |
| Encryption | <!-- GELI, LUKS, etc. --> |
| Filesystem | <!-- ZFS, UFS, ext4, etc. --> |
| OOB | <!-- BMC type at IP --> |
| OS | <!-- OPNsense/pfSense/VyOS version --> |

### NIC Map

| NIC | Role | Notes |
|-----|------|-------|
| <!-- nic0-3 --> | LACP member | <!-- switch ports --> |
| <!-- nic4 --> | BMC shared | **DO NOT REASSIGN** if shared |
| <!-- nic5 --> | WAN primary | <!-- ISP --> |
| <!-- nic6 --> | WAN backup | <!-- Backup ISP --> |

### Boot Process

<!-- Document the boot sequence, especially any encryption unlock requirements.
     Note whether the unlock prompt is available via serial, KVM, or video console only. -->

## OOB Access

| Property | Value |
|----------|-------|
| IP | <!-- BMC IP --> |
| Username | <!-- user --> |
| Password | <!-- from vault --> |
| Notes | <!-- TLS issues, cipher requirements, etc. --> |

---

## Step 1: OS Installation

### 1.1 Prepare USB Installer

<!-- Download URL, dd command, BIOS boot config -->

### 1.2 Install to Disk

<!-- Installer choices: filesystem, encryption, partitioning -->

### 1.3 Initial Console Configuration

<!-- First boot: set console type, assign WAN interface for basic connectivity -->

---

## Step 2: LACP / Link Aggregation

<!-- Create the LACP bond/lagg before assigning the LAN interface -->

| Setting | Value |
|---------|-------|
| Parent interfaces | <!-- nic list --> |
| Protocol | LACP |
| Hash layers | <!-- L3, L4, etc. --> |

---

## Step 3: VLAN Configuration

<!-- Create VLANs on the aggregated interface -->

| VLAN Tag | Parent | Interface Created | Description |
|----------|--------|-------------------|-------------|
| <!-- 20 --> | <!-- lagg0/bond0 --> | <!-- lagg0.20 --> | Servers |
| <!-- 30 --> | <!-- lagg0/bond0 --> | <!-- lagg0.30 --> | Workstations |
| <!-- etc. --> | | | |

### 3.1 Assign VLAN Interfaces

<!-- Map each VLAN interface to an IP address -->

| Name | Interface | IP Address | Subnet |
|------|-----------|------------|--------|
| <!-- MGMT --> | <!-- lagg0 --> | <!-- 10.0.10.1 --> | /24 |
| <!-- SERVERS --> | <!-- lagg0.20 --> | <!-- 10.0.20.1 --> | /24 |
| <!-- etc. --> | | | |

---

## Step 4: Gateway and Multi-WAN

### 4.1 Gateways

| Gateway | Interface | Monitor IP | Default |
|---------|-----------|------------|---------|
| <!-- WAN_GW --> | <!-- WAN nic --> | <!-- 1.1.1.1 --> | Yes |
| <!-- BACKUP_GW --> | <!-- backup nic --> | <!-- 9.9.9.9 --> | No |

### 4.2 Gateway Group (if multi-WAN)

<!-- Load balancing or failover configuration -->

### 4.3 System DNS

<!-- DNS servers the firewall itself uses for recursive resolution -->

---

## Step 5: Firewall Rules

### 5.1 VLAN Security Policy

| VLAN | Outbound Access | Blocked From |
|------|-----------------|--------------|
| Management | Full | -- |
| Servers | Full | -- |
| Workstations | Full | -- |
| IoT | **Internet only** | All RFC1918 |
| VoIP | Servers + Internet | <!-- restricted VLANs --> |
| Testing | **Internet only** | All RFC1918 |

### 5.2 Rule Structure Per VLAN

<!-- Document the rule pattern for full-access vs. restricted VLANs -->

### 5.3 WAN Inbound Rules

<!-- Document WAN defense chain: blocklists, GeoIP, bogon blocks, rate limiting, NAT pass rules -->

### 5.4 VPN Interface Rules

<!-- Rules on VPN tunnel interface -->

### 5.5 IDS/IPS

<!-- Suricata, Snort, CrowdSec, or other IDS configuration -->

---

## Step 6: NAT Configuration

### 6.1 Outbound NAT

<!-- NAT mode (automatic, hybrid, manual), any manual overrides -->

### 6.2 Port Forwards

<!-- Document all inbound port forwards -->

| Description | Protocol | WAN Port | Destination | Dest Port | Source Restriction |
|-------------|----------|----------|-------------|-----------|-------------------|
| <!-- SIP to PBX --> | UDP | <!-- port --> | <!-- IP --> | <!-- port --> | <!-- source IPs --> |
| <!-- SMTP to server --> | TCP | <!-- port --> | <!-- IP --> | <!-- port --> | any |

---

## Step 7: DNS Configuration

### 7.1 General Settings

<!-- DNS resolver: Unbound, dnsmasq, etc. Listen interfaces, DNSSEC -->

### 7.2 Host Overrides / Local Records

<!-- List all internal DNS records. Group by category. -->

#### Infrastructure Hosts

| Hostname | IP |
|----------|----|
| <!-- firewall.lab.example.com --> | <!-- IP --> |
| <!-- server-1.lab.example.com --> | <!-- IP --> |
| <!-- etc. --> | |

#### Service Hostnames (resolve to server IPs)

<!-- List all service DNS names -->

### 7.3 DNS Forwarding

<!-- Domain forwarding rules (e.g., AD zones to domain controllers) -->

---

## Step 8: DHCP Configuration

| Interface | Range Start | Range End | Gateway | DNS |
|-----------|-------------|-----------|---------|-----|
| <!-- each VLAN --> | <!-- IP --> | <!-- IP --> | <!-- gateway --> | <!-- DNS server --> |

---

## Step 9: VPN Configuration

### 9.1 Server Configuration

| Setting | Value |
|---------|-------|
| Software | <!-- WireGuard, OpenVPN, IPsec --> |
| Listen port | <!-- port --> |
| Tunnel subnet | <!-- 10.10.10.0/24 --> |
| Public endpoint | <!-- vpn.example.com:port --> |

### 9.2 Peers

| Peer Name | Tunnel Address | Notes |
|-----------|---------------|-------|
| <!-- mobile --> | <!-- IP --> | |
| <!-- laptop --> | <!-- IP --> | |

### 9.3 VPN NAT

<!-- Manual NAT rules required for VPN traffic -->

---

## Step 10: TLS for WebUI

<!-- Document how to deploy a proper TLS certificate for the firewall web interface -->
<!-- Note any gotchas with cert deployment (e.g., API limitations, manual file copy required) -->

---

## Step 11: Additional Services

### NTP

<!-- NTP server config: listen interfaces, upstream servers -->

### SNMP

<!-- SNMP community string, monitoring integration -->

### SSH

<!-- SSH access restrictions, brute-force protection -->

### Traffic Shaper

<!-- Any QoS or bandwidth limiting rules -->

---

## Step 12: Config Backup and Restore

### Fastest Recovery Path

1. Fresh install (Steps 1.1-1.2)
2. Get basic network connectivity
3. Upload config backup via WebUI
4. Reboot

### Config Backup Location

<!-- Where is the config.xml / backup stored? -->

---

## Routing Table Reference

<!-- Expected routes after full configuration -->

| Destination | Gateway | Interface |
|-------------|---------|-----------|
| default | <!-- WAN gateway --> | <!-- WAN nic --> |
| <!-- VPN subnet --> | (direct) | <!-- tunnel --> |
| <!-- each VLAN subnet --> | (direct) | <!-- VLAN interface --> |

---

## Gotchas and Warnings

### Destructive Commands

| Command | Effect | Safe Alternative |
|---------|--------|-----------------|
| <!-- pfctl -Fs --> | Drops ALL connections | <!-- pfctl -k <ip> --> |
| <!-- configctl webgui restart --> | Regenerates self-signed cert | <!-- pkill -HUP lighttpd --> |

### Boot and Encryption

<!-- Encryption unlock gotchas: console-only, keyboard mapping, etc. -->

### NIC Assignment

<!-- NICs that must not be reassigned (e.g., BMC shared NIC) -->

---

## Verification Checklist

- [ ] Firewall WebUI accessible
- [ ] All VLANs have correct gateway IPs
- [ ] Inter-VLAN routing works
- [ ] Internet access works from all permitted VLANs
- [ ] DNS resolution works for internal and external names
- [ ] VPN tunnel connects from external client
- [ ] Firewall rules block traffic as expected (test IoT VLAN)
- [ ] Config backup exists and is stored securely
