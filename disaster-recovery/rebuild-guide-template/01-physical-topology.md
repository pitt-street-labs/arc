# Chapter 01 -- Physical Topology

**Depends on:** Nothing
**Required before:** All other chapters

This chapter documents the physical rack layout, cabling, VLAN architecture, IP addressing, and hardware specifications for every device in the lab.

---

## Network Diagram

<!-- Draw your network topology. Show WAN connections, firewall, switch, servers, and endpoints.
     Use ASCII art for portability. Example structure: -->

```
                          Internet
                    +----------+----------+
                    |                     |
              Primary WAN           Backup WAN
              (DHCP/static)         (DHCP/static)
                    |                     |
              +-----+---------------------+-----+
              |         FIREWALL                 |
              |     (your firewall OS)           |
              |   LAN: lagg0/bond0 (LACP)       |
              +--------------+------------------+
                             |
                +------------+------------+
                |     MANAGED SWITCH      |
                |   (model, port count)   |
                |   LACP Trunks to all    |
                +-----------+-------------+
                            |
      +---------+-----------+-----------+---------+
      |         |           |           |         |
   Server-1  Server-2  Workstation    WiFi AP   Phones
```

## VLAN Architecture

<!-- Define all your VLANs. Include subnet, gateway, DHCP range, and security policy. -->

| VLAN | Name | Subnet | Gateway | DHCP Range | Security Policy |
|------|------|--------|---------|------------|-----------------|
| <!-- ID --> | Management | <!-- 10.0.10.0/24 --> | <!-- .1 --> | <!-- .100-.200 --> | Full internal access |
| <!-- ID --> | Servers | <!-- 10.0.20.0/24 --> | <!-- .1 --> | <!-- .100-.200 --> | Full internal access |
| <!-- ID --> | Workstations | <!-- 10.0.30.0/24 --> | <!-- .1 --> | <!-- .100-.200 --> | Full internal access |
| <!-- ID --> | IoT | <!-- 10.0.100.0/24 --> | <!-- .1 --> | <!-- .100-.254 --> | Internet only |
| <!-- ID --> | VoIP | <!-- 10.0.200.0/24 --> | <!-- .1 --> | <!-- .100-.200 --> | Servers + Internet |
| <!-- ID --> | Testing | <!-- 10.0.240.0/24 --> | <!-- .1 --> | <!-- .100-.254 --> | Internet only |

**DHCP notes:**
<!-- Document any DHCP quirks: which DHCP server per VLAN, special options, phone provisioning, etc. -->

## IP Address Map -- Core Infrastructure

### Management VLAN

| IP | Hostname | Device | Switch Port | Notes |
|----|----------|--------|-------------|-------|
| <!-- .1 --> | <!-- firewall --> | Gateway | <!-- port-channel --> | <!-- native VLAN --> |
| <!-- .11 --> | <!-- firewall-bmc --> | BMC | <!-- port --> | <!-- access mode --> |
| <!-- .20 --> | <!-- server-1-mgmt --> | Server 1 management | <!-- port-channel --> | Tagged VLAN |
| <!-- .21 --> | <!-- switch --> | Switch SVI | -- | Switch management IP |
| <!-- .40 --> | <!-- server-2-mgmt --> | Server 2 management | <!-- port-channel --> | Tagged VLAN |
| <!-- etc. --> | | | | |

### Server VLAN

| IP | Hostname | Device | Notes |
|----|----------|--------|-------|
| <!-- .1 --> | <!-- firewall --> | Gateway | |
| <!-- .10 --> | <!-- server-1 --> | Primary server | Bond native |
| <!-- .20 --> | <!-- server-2 --> | Secondary server | Bond native |
| <!-- etc. --> | | | |

### WAN Interfaces

| IP | Interface | Provider | Type |
|----|-----------|----------|------|
| <!-- WAN IP --> | <!-- nic --> | <!-- ISP --> | DHCP/Static |
| <!-- Backup WAN IP --> | <!-- nic --> | <!-- Backup ISP --> | DHCP/Static |

### VPN Subnet

<!-- If you run WireGuard, OpenVPN, or IPsec, document the tunnel subnet and peers -->

| IP | Peer | Notes |
|----|------|-------|
| <!-- .1 --> | Server (listener) | <!-- port --> |
| <!-- .2 --> | <!-- mobile device --> | |
| <!-- .3 --> | <!-- travel laptop --> | |

---

## Hardware Specifications

### Firewall

<!-- Document CPU, RAM, storage, encryption, NIC map, disk layout, OOB management -->

| Component | Specification |
|-----------|---------------|
| CPU | <!-- model --> |
| RAM | <!-- size, ECC? --> |
| Storage | <!-- RAID config, capacity --> |
| Encryption | <!-- GELI, LUKS, etc. --> |
| OS | <!-- OPNsense, pfSense, VyOS, etc. --> |
| OOB | <!-- BMC type and IP --> |

**NIC Map:**

| NIC | Role | Notes |
|-----|------|-------|
| <!-- nic0-3 --> | LACP members | <!-- to switch ports --> |
| <!-- nic4 --> | WAN primary | <!-- ISP --> |
| <!-- nic5 --> | WAN backup | <!-- Backup ISP --> |

### Server 1

| Component | Specification |
|-----------|---------------|
| CPU | <!-- model, cores, threads --> |
| RAM | <!-- size, ECC, DIMM config --> |
| NICs | <!-- count, model, driver --> |
| Storage | <!-- RAID config, LUKS, LVM layout --> |
| OS | <!-- distro and version --> |
| OOB | <!-- BMC type and IP --> |

**Bonding:**
<!-- Document bond mode, members, VLAN subinterfaces, bridges -->

### Server 2

<!-- Same structure as Server 1 -->

### Workstation

| Component | Specification |
|-----------|---------------|
| CPU | <!-- model --> |
| RAM | <!-- size --> |
| GPU | <!-- if applicable --> |
| Storage | <!-- root, data, external drives --> |
| OS | <!-- distro and version --> |

### Switch

| Component | Specification |
|-----------|---------------|
| Model | <!-- model number --> |
| Firmware | <!-- IOS version, firmware --> |
| IP | <!-- management IP --> |
| Ports | <!-- count, PoE? --> |

---

## Switch Port Assignments

<!-- Document every used port on your switch -->

| Port | Device | Mode | VLANs | Speed | Status |
|------|--------|------|-------|-------|--------|
| <!-- ports --> | <!-- firewall LACP --> | Trunk | <!-- allowed VLANs --> | <!-- speed --> | Active |
| <!-- ports --> | <!-- server-1 LACP --> | Trunk | <!-- allowed VLANs --> | <!-- speed --> | Active |
| <!-- ports --> | <!-- server-2 LACP --> | Trunk | <!-- allowed VLANs --> | <!-- speed --> | Active |
| <!-- port --> | <!-- BMC --> | Access | <!-- mgmt VLAN --> | <!-- speed --> | Connected |
| <!-- port --> | <!-- phone --> | Access | <!-- VoIP VLAN --> | <!-- speed --> | Connected (PoE) |
| <!-- port --> | <!-- workstation --> | Trunk | <!-- allowed VLANs --> | <!-- speed --> | Connected |

---

## Physical Rack Layout

<!-- Draw your rack from bottom to top. Include U height. -->

```
+----------------------------------+
|  UPS (model)                     |  2U -- bottom
+----------------------------------+
|  Firewall (model)                |  1-2U
+----------------------------------+
|  Switch (model)                  |  1U
+----------------------------------+
|  Server 1 (model)                |  1-2U
+----------------------------------+
|  Server 2 (model)                |  1-2U
+----------------------------------+
|          (empty)                 |
+----------------------------------+

Workstation: desk-mounted
WiFi AP: wall-mounted
```

---

## Cabling Summary

### LACP Trunks

| Trunk | From -> To | Ports | NICs | VLANs |
|-------|-----------|-------|------|-------|
| <!-- Po1 --> | Firewall -> Switch | <!-- ports --> | <!-- nics --> | <!-- VLANs --> |
| <!-- Po2 --> | Server 2 -> Switch | <!-- ports --> | <!-- nics --> | <!-- VLANs --> |
| <!-- Po3 --> | Server 1 -> Switch | <!-- ports --> | <!-- nics --> | <!-- VLANs --> |

### OOB Management (Dedicated Ports)

| BMC | IP | Switch Port | Speed |
|-----|-----|-------------|-------|
| <!-- firewall BMC --> | <!-- IP --> | <!-- port --> | <!-- speed --> |
| <!-- server-1 BMC --> | <!-- IP --> | <!-- port --> | <!-- speed --> |
| <!-- server-2 BMC --> | <!-- IP --> | <!-- port --> | <!-- speed --> |

### Bridge Networks (Linux)

<!-- Document any Linux bridges used for VM networking -->

| Bridge | Host | Master | Purpose | Guests |
|--------|------|--------|---------|--------|
| <!-- br-servers --> | <!-- server-1 --> | <!-- bond0 --> | <!-- VLAN 20 traffic --> | <!-- dc1 --> |

---

## Verification Checklist

After cabling and powering on:

- [ ] Firewall responds to ping on its management IP
- [ ] Switch responds to ping on its management IP
- [ ] All BMCs respond to ping
- [ ] Workstation gets DHCP
- [ ] All LACP trunks show active/bundled on switch
- [ ] Inter-VLAN routing works (workstation can ping server VLAN)
- [ ] Internet access works from workstation
- [ ] WiFi AP broadcasts SSIDs with correct VLAN isolation
