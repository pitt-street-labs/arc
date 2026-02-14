---
title: "Network Infrastructure"
subtitle: "Firewall, Switching, VLANs, and Routing"
author: "Your Name"
date: "2026-01-15"
version: "1.0"
manual-id: "NET-001"
---

\newpage

# Introduction

## Scope

<!-- Describe what this manual covers -->

This manual documents the complete network infrastructure including firewall configuration, switch management, VLAN design, inter-VLAN routing, VPN tunnels, DNS, DHCP, and network security policies.

> **See Also:** REF-001, Section 2 --- Systems Summary for hardware specifications of all network equipment.

## Network Design Principles

<!-- Document your design philosophy -->

- Defense in depth: firewall at perimeter, inter-VLAN ACLs, host firewalls
- Redundancy where possible: dual WAN, LACP bonding, HA-ready configurations
- Least privilege: default-deny firewall policy, explicit allow rules only
- Separation of concerns: management traffic isolated from production

# Firewall

## Hardware and Software

<!-- Document your firewall platform -->

| Attribute | Value |
|-----------|-------|
| Platform | OPNsense 25.1 |
| Hardware | Dell R210 II |
| CPU | Intel Xeon E3-1220 |
| RAM | 16 GB DDR3 ECC |
| Management IP | 10.0.0.1 (VLAN 10) |

## Interface Assignments

<!-- Document your firewall NIC assignments -->

| Interface | NIC | Role | Notes |
|-----------|-----|------|-------|
| WAN | igb0 | Primary internet uplink | Fiber, DHCP from ISP |
| WAN2 | igb1 | Secondary internet uplink | Cellular backup |
| LAN | igb2-igb5 | LACP trunk to switch | 4x 1Gbps aggregate |

> **Note:** The LACP trunk carries all VLANs as tagged traffic. The switch must have a matching port-channel configuration.

## Firewall Rules

<!-- Document your rule sets by interface/VLAN -->

### WAN Inbound

| # | Action | Proto | Source | Dest | Port | Description |
|---|--------|-------|--------|------|------|-------------|
| 1 | Block | * | RFC1918 | * | * | Block private IPs on WAN (anti-spoof) |
| 2 | Allow | UDP | * | WAN addr | 51820 | WireGuard VPN |
| 3 | Block | * | * | * | * | Default deny inbound |

### VLAN 20 (Servers) to VLAN 10 (Management)

| # | Action | Proto | Source | Dest | Port | Description |
|---|--------|-------|--------|------|------|-------------|
| 1 | Allow | TCP | 10.0.1.0/24 | 10.0.0.1 | 53 | DNS to firewall |
| 2 | Allow | UDP | 10.0.1.0/24 | 10.0.0.1 | 53 | DNS to firewall |
| 3 | Allow | ICMP | 10.0.1.0/24 | 10.0.0.0/24 | * | ICMP for diagnostics |
| 4 | Block | * | 10.0.1.0/24 | 10.0.0.0/24 | * | Default deny to management |

> **Warning:** Adding broad allow rules from server VLAN to management VLAN defeats network segmentation. Always use specific source/destination/port combinations.

### VLAN 30 (Clients) Outbound

<!-- Document client VLAN rules -->

| # | Action | Proto | Source | Dest | Port | Description |
|---|--------|-------|--------|------|------|-------------|
| 1 | Allow | TCP | 10.0.2.0/24 | * | 80,443 | HTTP/HTTPS outbound |
| 2 | Allow | UDP | 10.0.2.0/24 | 10.0.0.1 | 53 | DNS to firewall |
| 3 | Allow | TCP | 10.0.2.0/24 | 10.0.1.0/24 | 8080,3000 | Access to lab services |
| 4 | Block | * | 10.0.2.0/24 | 10.0.0.0/16 | * | Block all other internal |
| 5 | Allow | * | 10.0.2.0/24 | * | * | Allow internet |

## VPN

<!-- Document VPN configuration -->

### WireGuard Site-to-Site

> **STATUS: PLANNED** --- WireGuard tunnel to remote backup site. Prerequisites: static IP or DDNS on both ends.

### WireGuard Road Warrior

| Setting | Value |
|---------|-------|
| Listen Port | 51820 |
| Tunnel Subnet | 10.99.0.0/24 |
| Allowed Networks | 10.0.0.0/16 |
| DNS Push | 10.0.0.1 |

## DNS

<!-- Document your DNS configuration -->

### Upstream Resolvers

| Priority | Server | Protocol |
|----------|--------|----------|
| Primary | 1.1.1.1 | DNS over TLS |
| Secondary | 9.9.9.9 | DNS over TLS |

### Local Overrides

<!-- Document internal DNS records -->

| Hostname | IP Address | Purpose |
|----------|-----------|---------|
| firewall.lab.local | 10.0.0.1 | Firewall web UI |
| switch.lab.local | 10.0.0.2 | Switch management |
| server1.lab.local | 10.0.1.10 | Application server |
| grafana.lab.local | 10.0.1.20 | Monitoring dashboard |

## DHCP

<!-- Document DHCP scopes -->

| VLAN | Range | Lease Time | Gateway | DNS |
|------|-------|------------|---------|-----|
| 10 (Mgmt) | Static only | --- | 10.0.0.1 | 10.0.0.1 |
| 20 (Servers) | Static only | --- | 10.0.1.1 | 10.0.0.1 |
| 30 (Clients) | 10.0.2.100--10.0.2.200 | 12h | 10.0.2.1 | 10.0.0.1 |
| 100 (Guest) | 10.0.100.100--10.0.100.200 | 2h | 10.0.100.1 | 10.0.0.1 |

# Switching

## Switch Configuration

<!-- Document your core switch setup -->

| Attribute | Value |
|-----------|-------|
| Model | Cisco Catalyst 2960-S |
| Firmware | IOS 15.2(7)E9 |
| Management IP | 10.0.0.2 (VLAN 10) |
| Spanning Tree | PVST+ (Rapid) |

## VLAN Database

| VLAN ID | Name | Description |
|---------|------|-------------|
| 10 | MGMT | Network management |
| 20 | SERVERS | Server traffic |
| 30 | CLIENTS | End-user devices |
| 100 | GUEST | Isolated guest access |
| 200 | VOIP | Voice traffic |

## Port Assignments

<!-- Document which device connects to which switch port -->

| Port | Mode | VLAN(s) | Connected Device | Notes |
|------|------|---------|------------------|-------|
| Gi1/0/1--4 | Trunk (Po1) | 10,20,30,100,200 | Firewall LACP | 4x 1Gbps |
| Gi1/0/5--8 | Trunk (Po2) | 10,20 | Server 1 LACP | 4x 1Gbps |
| Gi1/0/9--12 | Trunk (Po3) | 10,20 | Server 2 LACP | 4x 1Gbps |
| Gi1/0/45 | Trunk | 30,100 | WiFi AP | Client + guest |
| Gi1/0/47 | Access | 10 | Management workstation | |
| Gi1/0/48 | Access | 10 | Spare | |

> **Note:** Unused ports should be shut down and assigned to an unused VLAN for security. Enable port-security on access ports.

## Link Aggregation

<!-- Document LACP/port-channel configuration -->

| Port-Channel | Member Ports | Mode | Connected To |
|--------------|-------------|------|--------------|
| Po1 | Gi1/0/1--4 | LACP active | Firewall |
| Po2 | Gi1/0/5--8 | LACP active | Server 1 |
| Po3 | Gi1/0/9--12 | LACP active | Server 2 |

### Example Configuration

```
interface Port-channel1
 description FIREWALL-LACP
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,100,200
!
interface range GigabitEthernet1/0/1 - 4
 description FIREWALL-LACP-MEMBER
 switchport trunk encapsulation dot1q
 switchport mode trunk
 switchport trunk allowed vlan 10,20,30,100,200
 channel-group 1 mode active
```

# WiFi

## Access Point Configuration

<!-- Document your wireless setup -->

| Attribute | Value |
|-----------|-------|
| Model | ASUS RT-AX82U |
| Mode | Access Point (bridge) |
| Management IP | 10.0.2.100 |
| Uplink Port | Gi1/0/45 (trunk) |

## SSIDs

| SSID | VLAN | Band | Security | Purpose |
|------|------|------|----------|---------|
| Lab-WiFi | 30 | 2.4 + 5 GHz | WPA3-SAE | Primary lab wireless |
| Lab-Guest | 100 | 2.4 + 5 GHz | WPA2-PSK | Guest access (isolated) |

> **Warning:** Guest SSID credentials should be rotated monthly. Ensure the guest VLAN has no route to internal networks except DNS.

# Network Monitoring

## SNMP

<!-- Document SNMP monitoring configuration -->

| Device | Community / User | Monitored Metrics |
|--------|-----------------|-------------------|
| Switch | SNMPv3 user `monitor` | Interface counters, CPU, memory, VLAN status |
| Firewall | SNMPv3 user `monitor` | Interface traffic, state table, CPU |

> **See Also:** SVC-001, Section 4 --- Monitoring Stack for Prometheus/Grafana configuration that consumes these SNMP metrics.

## Syslog

<!-- Document centralized logging -->

| Source | Destination | Port | Format |
|--------|------------|------|--------|
| Firewall | 10.0.1.20 | 514/UDP | RFC 5424 |
| Switch | 10.0.1.20 | 514/UDP | RFC 3164 |

# Maintenance Procedures

## Firmware Updates

<!-- Document your update process -->

### Firewall

1. Download update from OPNsense mirrors
2. Take configuration backup: System > Configuration > Backups
3. Apply update via System > Firmware
4. Verify all interfaces and rules after reboot

### Switch

1. Copy new IOS image to flash via TFTP
2. Verify image checksum
3. Set boot variable: `boot system flash:new-image.bin`
4. Reload during maintenance window
5. Verify VLANs, port-channels, and spanning tree after boot

> **Warning:** Always have console access available during firmware updates. If the update fails, network connectivity may be lost entirely.

## Configuration Backup

<!-- Document your backup strategy -->

| Device | Method | Schedule | Destination |
|--------|--------|----------|-------------|
| Firewall | XML config export | Weekly | Encrypted backup server |
| Switch | `copy running-config tftp` | Weekly | TFTP server on VLAN 10 |
