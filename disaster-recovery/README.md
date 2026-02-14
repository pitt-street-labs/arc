# Disaster Recovery Framework

A templatized disaster recovery rebuild guide framework for home labs and small infrastructure environments. This framework provides the structure, scripts, and methodology to document your entire infrastructure so it can be rebuilt from bare metal.

## What This Provides

1. **Rebuild Guide Templates** (`rebuild-guide-template/`) -- Skeleton markdown chapters ordered by recovery dependency. Each chapter has the section structure and placeholder content explaining what to document. Fill in your own hardware, IPs, credentials, and configurations.

2. **State Capture Scripts** (`state-capture/`) -- Bash scripts that SSH into each system and capture its current configuration (read-only). Outputs are stored as dated snapshots for drift detection and disaster recovery reference.

3. **Maintenance Scripts** (`scripts/`) -- Tools to refresh captures, validate guide accuracy against snapshots, and diff two snapshots to detect configuration drift over time.

## Design Philosophy

- **Recovery-ordered chapters**: Chapters are numbered in the order you would rebuild after a total loss. Chapter 01 (physical topology) must be done before anything else; the firewall before servers; servers before services.
- **Self-contained**: The rebuild guide plus a credential backup should be sufficient to reconstruct everything without access to any running system.
- **State capture as ground truth**: The guide is documentation; the snapshots are evidence. The validation script detects when they diverge.
- **Read-only captures**: All capture scripts are strictly read-only. They never modify any system state.

## How to Customize

### Step 1: Inventory Your Infrastructure

Before filling in templates, catalog:
- All physical devices (servers, switches, firewalls, workstations, APs)
- All VLANs and IP subnets
- All credential storage (vault, password manager, encrypted files)
- All services (containers, VMs, bare-metal daemons)

### Step 2: Fill In the Rebuild Guide

Work through each chapter template in order. Replace all `<!-- placeholder -->` comments with your actual configuration. Delete sections that do not apply to your environment and add sections for anything unique to your setup.

Key customization points:
- **Chapter 01**: Your network diagram, VLAN layout, IP map, hardware specs
- **Chapter 02**: Your credential management system and vault item inventory
- **Chapters 03-04**: Your firewall and switch configurations
- **Chapters 05-10**: Your server OS, storage, networking, and services
- **Chapters 11+**: Workstations, directory services, VMs, PKI, advanced networking

### Step 3: Customize the Capture Scripts

Edit the capture scripts to match your infrastructure:
- Update SSH targets (hostnames/IPs) and usernames
- Update the firewall capture for your firewall OS (pfSense, OPNsense, VyOS, etc.)
- Update the issue tracker capture for your platform (Gitea, GitHub, GitLab, etc.)
- Add or remove capture targets as needed

### Step 4: Run and Validate

```bash
# Run all state captures
bash state-capture/capture.sh

# Validate guide against latest snapshot
bash scripts/validate.sh

# Compare two snapshots for drift
bash scripts/diff-state.sh 2025-01-15 2025-02-15
```

## Directory Structure

```
disaster-recovery/
  README.md                          # This file
  rebuild-guide-template/
    00-README.md                     # Guide overview and reading order
    01-physical-topology.md          # Rack layout, VLANs, IP map, cabling
    02-secrets-and-credentials.md    # Credential management and inventory
    03-firewall.md                   # Firewall/router rebuild
    04-switch.md                     # Managed switch configuration
    05-server-1-os.md               # Primary server OS installation
    06-server-1-services.md         # Primary server container/service deployment
    07-server-2-os.md               # Secondary server OS installation
    08-server-2-infrastructure.md   # Core infrastructure services (git, SSO, proxy)
    09-server-2-monitoring.md       # Monitoring stack (Prometheus, Grafana, etc.)
    10-server-2-app-services.md     # Application-tier containers
    11-voip.md                      # VoIP/PBX system
    12-workstation.md               # Primary workstation setup
    13-automation-environment.md    # Automation tooling (CI/CD, scripts, agents)
    14-directory-services.md        # Active Directory / LDAP
    15-vm-fleet.md                  # Virtual machine inventory and rebuild
    16-storage-and-media.md         # Storage layouts, backups, media libraries
    17-pki-and-tls.md               # Certificate authority and TLS certificates
    18-networking-advanced.md       # LACP tuning, QoS, VPN, DNS HA
    19-maintenance-runbooks.md      # Operational procedures and runbooks
    20-project-catalog.md           # Inventory of all projects and repositories
  state-capture/
    capture.sh                      # Master orchestrator
    capture-firewall.sh             # Firewall state capture
    capture-server-1.sh             # Primary server state capture
    capture-server-2.sh             # Secondary server state capture
    capture-workstation.sh          # Workstation state capture
    capture-issue-tracker.sh        # Issue tracker API capture
  scripts/
    refresh.sh                      # Re-run captures + refresh knowledge archive
    validate.sh                     # Compare guide vs. latest snapshot
    diff-state.sh                   # Compare two snapshots for drift
```

## Requirements

- Bash 4+
- SSH access (key-based) to all remote systems
- `curl` for API-based captures
- `python3` for JSON parsing in diff/validation scripts
- `rsync` for knowledge distillation sync
- Credential access (vault CLI or encrypted backup file)

## Assumptions

This framework assumes a small lab or homelab with:
- 1-2 rack-mount or tower servers running Linux (Fedora, Ubuntu, Debian, etc.)
- A dedicated firewall appliance (OPNsense, pfSense, VyOS, or similar)
- A managed L2/L3 switch
- A workstation for administration
- Containers managed via Podman Quadlet or Docker Compose
- VMs managed via libvirt/KVM
- LUKS disk encryption on servers
- A credential vault (Vaultwarden, Bitwarden, KeePass, etc.)

Scale up or down as needed. The chapter structure accommodates anywhere from a single server to a multi-rack deployment.

## License

This framework is provided as-is for use in documenting your own infrastructure. Adapt freely.
