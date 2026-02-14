# Chapter 11 -- VoIP/PBX System

**Depends on:** [Chapter 07](./07-server-2-os.md) (PBX runs as VM or container on a server)

## Overview

<!-- Describe your VoIP setup: PBX software, SIP trunks, phone models, extensions -->

| Component | Value |
|-----------|-------|
| PBX Software | <!-- FreePBX, Asterisk, FusionPBX, etc. --> |
| Deployment | <!-- VM on server, container, bare metal --> |
| SIP Trunk | <!-- provider name --> |
| Phone Count | <!-- number --> |
| Extension Range | <!-- e.g., 100-199 --> |

---

## Network Architecture

<!-- VoIP VLAN, bridge configuration, NAT/port forwards for SIP -->

| Property | Value |
|----------|-------|
| VLAN | <!-- VoIP VLAN ID --> |
| PBX IP | <!-- IP --> |
| Bridge | <!-- br-voip on server --> |

---

## SIP Trunk Configuration

<!-- Trunk settings, port forwards on firewall, source IP restrictions -->

---

## Phone Provisioning

<!-- DHCP options for TFTP, phone configuration files -->

---

## Verification Checklist

- [ ] PBX web UI accessible
- [ ] Phones register and show online
- [ ] Internal call between extensions works
- [ ] Outbound call to PSTN works
- [ ] Inbound call from PSTN rings correct extension
