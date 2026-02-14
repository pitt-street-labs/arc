# Infrastructure Rebuild Guide

## Purpose

This guide documents everything needed to rebuild the lab infrastructure from bare metal on equivalent hardware, without access to any running services or session history.

If you are reading this after a catastrophic failure, start here.

## Prerequisites

- Physical access to the rack (or replacement hardware with similar specs)
- Access to the credential backup (encrypted vault export, GPG file, or offline password manager)
- A workstation with SSH, a web browser, and basic CLI tools
- Internet access for downloading OS images and container images

## Hardware Summary

<!-- Fill in your hardware inventory -->

| Device | Role | Model |
|--------|------|-------|
| <!-- firewall hostname --> | Firewall/router | <!-- model --> |
| <!-- switch hostname --> | L2/L3 switch | <!-- model --> |
| <!-- server-1 hostname --> | Server (containers + VMs) | <!-- model --> |
| <!-- server-2 hostname --> | Server (containers + VMs) | <!-- model --> |
| <!-- workstation hostname --> | Workstation | <!-- model --> |
| <!-- other devices --> | <!-- role --> | <!-- model --> |

## Reading Order

Chapters are ordered by **recovery dependency** -- someone reading 01 through 20 rebuilds in the correct sequence. Each chapter identifies what must be completed before it.

| # | Chapter | Depends On |
|---|---------|------------|
| 01 | Physical Topology | Nothing (plan cabling first) |
| 02 | Secrets and Credentials | 01 (need vault access to proceed) |
| 03 | Firewall | 01, 02 (firewall is the network foundation) |
| 04 | Switch | 01, 03 (switch trunks to firewall) |
| 05 | Server 1 OS | 01-04 (server needs network) |
| 06 | Server 1 Services | 05 (containers need the OS) |
| 07 | Server 2 OS | 01-04 (server needs network) |
| 08 | Server 2 Infrastructure | 07 (git hosting, SSO, reverse proxy, vault) |
| 09 | Server 2 Monitoring | 07, 08 (Prometheus, Grafana, Loki, alerting) |
| 10 | Server 2 App Services | 07, 08 (application-tier containers) |
| 11 | VoIP/PBX | 07 (PBX VM or container on a server) |
| 12 | Workstation | 01, 03 (workstation needs network) |
| 13 | Automation Environment | 12 (CI/CD, scripts, agents) |
| 14 | Directory Services | 05, 07 (DCs are VMs on servers) |
| 15 | VM Fleet | 05, 07 (all VMs across both servers) |
| 16 | Storage and Media | 05, 07, 12 (drives across all systems) |
| 17 | PKI and TLS | 14 (CA lives on directory services) |
| 18 | Networking Advanced | 03, 04 (LACP, QoS, VPN, DNS HA) |
| 19 | Maintenance Runbooks | Everything (operational procedures) |
| 20 | Project Catalog | Everything (inventory of all projects) |

## Appendices

<!-- Create appendices as needed for your environment -->

Raw reference data -- grep-friendly, not narrative:

| ID | Appendix | Content |
|----|----------|---------|
| A | Complete IP Map | Every IP address in the lab |
| B | Container Reference | Every container: image, ports, volumes, env |
| C | Container Unit Dump | Full text of all Quadlet/Compose unit files |
| D | Systemd Units | Custom systemd services and timers |
| E | Custom Scripts | Key automation scripts across all systems |
| F | SSH Config | Full SSH client config with all hosts |
| G | Package Manifests | Package lists per system |
| H | Issue Tracker Snapshot | All open/closed issues at capture time |
| I | Cron and Timers | Crontabs and systemd timers across all systems |

## Companion Documents

- **State Capture Scripts** -- Scripted snapshots of live system state
- **Maintenance Scripts** -- Refresh, validate, and diff tools
- **Knowledge Distillation** -- Copies of all automation configs, memory files, project docs

## How This Guide Was Generated

<!-- Fill in your generation methodology -->

This guide was generated on <!-- date --> by extracting knowledge from:
- <!-- list sources: config files, scripts, runbooks, session history, etc. -->

The `state-capture/` scripts can be re-run to refresh raw data. The `scripts/validate.sh` script compares guide claims against the latest snapshot.

## Conventions

- **Commands** are shown as bash snippets. Run them as your admin user unless `sudo` is specified.
- **IP addresses** use your production VLAN scheme.
- **Credential references** point to your vault item names.
- **Cross-references** use `[Chapter NN](./NN-name.md)` links.
- **Verification steps** appear at the end of each chapter as a checklist.
