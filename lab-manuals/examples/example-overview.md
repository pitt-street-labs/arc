---
title: "Lab Master Reference"
subtitle: "Complete Index, Inventory, and Quick-Start Guide"
author: "Your Name"
date: "2026-01-15"
version: "1.0"
manual-id: "REF-001"
---

# Introduction

## Purpose

<!-- Describe the purpose of this master reference document -->

This manual is the entry point and master index for your lab documentation set. It provides a complete hardware inventory, network topology, IP allocation tables, security overview, and quick-start procedures for cold boot, shutdown, and emergency recovery.

## Document Set Overview

<!-- List all manuals in your documentation set -->

| Manual | Title | Scope |
|--------|-------|-------|
| **REF-001** | Lab Master Reference | This document --- index, inventory, topology |
| **NET-001** | Network Infrastructure | Firewall, switching, VLANs, routing |
| **SVC-001** | Applications and Services | Containers, web apps, automation |

## Conventions

Throughout all manuals, the following conventions are used:

- **Cross-references** between manuals use the format: "See NET-001, Section 3.2 --- Firewall Rules"
- **Planned features** are marked with colored callout boxes labeled "STATUS: PLANNED"
- **Credentials** are never included in any document --- vault path references are used instead
- **IP addresses** follow the addressing scheme documented in the Network Architecture section

> **Note:** This master reference is the canonical source for hardware specifications. Other manuals reference back to this document for inventory details.

# Lab Overview

## Architecture Diagram

<!-- Insert or describe your network/lab architecture here -->
<!-- You can use Mermaid diagrams, ASCII art, or reference an image file -->

```
                   +----------+
                   | Internet |
                   +----+-----+
                        |
                   +----+-----+
                   | Firewall |
                   | 10.0.0.1 |
                   +----+-----+
                        |
                   +----+-----+
                   |  Switch  |
                   | 10.0.0.2 |
                   +--+----+--+
                      |    |
              +-------+    +-------+
              |                    |
         +----+-----+       +-----+----+
         | Server 1 |       | Server 2 |
         | 10.0.1.10|       | 10.0.1.20|
         +----------+       +----------+
```

## Systems Summary

<!-- Document your hardware inventory here -->

| System | Role | Hardware | OS | Primary IP |
|--------|------|----------|----|-----------|
| firewall | Gateway / firewall | Dell R210 II | OPNsense 25.1 | 10.0.0.1 |
| switch | Core switch | Cisco 2960-S | IOS 15.2 | 10.0.0.2 |
| server1 | Application server | Dell R720 | Ubuntu 24.04 | 10.0.1.10 |
| server2 | Monitoring / services | HP DL360 G8 | Fedora 42 | 10.0.1.20 |

> **See Also:** NET-001, Section 2 --- Physical Connectivity for cabling details and port assignments.

# Hardware Inventory

## Servers

<!-- Document each server in detail -->

### Server 1

| Attribute | Value |
|-----------|-------|
| Model | Dell PowerEdge R720 |
| CPU | 2x Intel Xeon E5-2670 v2 (20 cores / 40 threads) |
| RAM | 128 GB DDR3 ECC |
| Storage | 4x 1TB SAS (RAID 10) |
| Network | 4x 1GbE (LACP bond) |
| BMC | iDRAC 7 Enterprise |

### Server 2

<!-- Copy the table pattern above for each server -->

## Network Equipment

### Firewall

| Attribute | Value |
|-----------|-------|
| Model | Dell R210 II |
| CPU | Intel Xeon E3-1220 |
| RAM | 16 GB DDR3 ECC |
| NICs | 4x Intel I350 GbE |
| Software | OPNsense 25.1 |

### Core Switch

| Attribute | Value |
|-----------|-------|
| Model | Cisco Catalyst 2960-S |
| Ports | 48x GigabitEthernet + 4x SFP |
| Firmware | IOS 15.2(7)E9 |
| Management IP | 10.0.0.2 |

# Network Architecture

## VLAN Design

<!-- Document your VLAN topology -->

| VLAN ID | Name | Subnet | Purpose |
|---------|------|--------|---------|
| 10 | Management | 10.0.0.0/24 | Network device management |
| 20 | Servers | 10.0.1.0/24 | Server-to-server traffic |
| 30 | Clients | 10.0.2.0/24 | End-user devices |
| 100 | Guest | 10.0.100.0/24 | Isolated guest network |

## IP Allocation

<!-- Document your IP address assignments -->

### VLAN 10 --- Management

| IP Address | Hostname | Device |
|-----------|----------|--------|
| 10.0.0.1 | firewall | OPNsense gateway |
| 10.0.0.2 | switch | Cisco 2960-S |
| 10.0.0.11 | server1-bmc | iDRAC 7 |
| 10.0.0.21 | server2-bmc | iLO 4 |

### VLAN 20 --- Servers

| IP Address | Hostname | Device |
|-----------|----------|--------|
| 10.0.1.10 | server1 | Dell R720 |
| 10.0.1.20 | server2 | HP DL360 G8 |

> **Warning:** Changing VLAN assignments requires coordinated updates to the switch, firewall, and any affected server interfaces. Plan a maintenance window.

# Security Overview

## Access Control

<!-- Document your access control strategy -->

- All management interfaces are restricted to VLAN 10
- SSH key-based authentication only (password auth disabled)
- BMC/IPMI interfaces on dedicated management VLAN
- Firewall rules enforce inter-VLAN segmentation

> **STATUS: PLANNED** --- Implement centralized authentication (LDAP/RADIUS) for all network devices.

## Credential Management

<!-- Describe your credential storage approach without including actual credentials -->

All credentials are stored in an encrypted vault. This document references vault paths only:

| Service | Vault Path |
|---------|-----------|
| Firewall admin | `vault://network/firewall-admin` |
| Switch console | `vault://network/switch-console` |
| Server 1 BMC | `vault://bmc/server1-idrac` |
| Server 2 BMC | `vault://bmc/server2-ilo` |

# Quick-Start Procedures

## Cold Boot Sequence

<!-- Document the correct power-on order for your lab -->

1. Verify UPS is online and battery charged
2. Power on network switch
3. Power on firewall --- wait for full boot (verify with ping to gateway)
4. Power on servers in order: server1, then server2
5. Verify all services are reachable

## Graceful Shutdown

<!-- Document the correct shutdown order -->

1. Stop application services on server2
2. Stop application services on server1
3. Shut down server2: `sudo shutdown -h now`
4. Shut down server1: `sudo shutdown -h now`
5. Shut down firewall via console
6. Power off switch (if full power-down required)

## Emergency Recovery

<!-- Document recovery procedures for common failure scenarios -->

### Single Server Failure

1. Check BMC for hardware errors
2. Attempt remote power cycle via BMC
3. If unresponsive, check physical power and drive LEDs
4. Boot from recovery media if OS is corrupted

### Network Outage

1. Verify switch port LEDs --- identify which links are down
2. Check firewall WAN connectivity
3. Verify VLAN trunk ports are up
4. Test with direct cable if switch port suspected bad
