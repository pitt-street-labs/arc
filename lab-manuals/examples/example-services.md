---
title: "Applications and Services"
subtitle: "Container Workloads, Web Applications, and Automation"
author: "Your Name"
date: "2026-01-15"
version: "1.0"
manual-id: "SVC-001"
---

\newpage

# Introduction

## Scope

<!-- Describe what this manual covers -->

This manual documents every application-layer service deployed in the lab. It covers container orchestration, reverse proxy configuration, monitoring stack, web applications, backup systems, and operational maintenance procedures.

The application layer sits atop the infrastructure described in earlier manuals. Servers, storage, and operating systems are documented in REF-001. Network plumbing --- VLANs, firewall rules, and routing --- lives in NET-001.

> **See Also:** REF-001, Section 2 --- Systems Summary for hardware inventory referenced throughout this manual.

## Deployment Strategy

<!-- Document your deployment philosophy -->

The lab follows a container-first deployment model:

1. **Containers** --- default for all services (Docker or Podman)
2. **Virtual machines** --- when full OS isolation is required
3. **Bare metal** --- only when direct hardware access is mandatory (GPU, PCI passthrough)

## Service Inventory

<!-- List all services across all hosts -->

| Service | Host | Type | Port(s) | Status |
|---------|------|------|---------|--------|
| Grafana | server2 | Container | 3000 | Active |
| Prometheus | server2 | Container | 9090 | Active |
| Loki | server2 | Container | 3100 | Active |
| Reverse Proxy | server2 | Container | 443 | Active |
| Git Server | server2 | Container | 8084 | Active |
| Vault | server2 | Container | 8200 | Active |
| Media Server | server1 | Container | 8096 | Active |
| Backup Agent | server1 | Container | --- | Active |
| Build Runner | server1 | Container | --- | Planned |

> **Note:** Port assignments listed here are the container-internal ports. The reverse proxy handles external TLS termination on port 443 for most services.

# Container Runtime

## Configuration

<!-- Document your container runtime setup -->

### Server 1 --- Docker

| Setting | Value |
|---------|-------|
| Runtime | Docker Engine 27.x |
| Storage Driver | overlay2 |
| Data Root | /var/lib/docker |
| Network Mode | bridge (default) |
| Log Driver | json-file (max 10MB, 3 files) |

### Server 2 --- Podman (Rootless)

| Setting | Value |
|---------|-------|
| Runtime | Podman 5.x |
| Storage Driver | overlay |
| Data Root | ~/.local/share/containers |
| Network Mode | pasta (rootless) |
| Service Manager | systemd (Quadlet) |

> **Warning:** Never use `docker-compose` or `podman-compose` in production on shared servers. Use Quadlet unit files (Podman) or Docker Compose with resource limits. Compose without limits can exhaust system memory.

## Container Management

<!-- Document how containers are managed -->

### Quadlet (Podman)

Quadlet files live in `~/.config/containers/systemd/` and are managed via systemd:

```bash
# Start a service
systemctl --user start myservice.service

# Check status
systemctl --user status myservice.service

# View logs
journalctl --user -u myservice.service -f

# Restart after editing the .container file
systemctl --user daemon-reload
systemctl --user restart myservice.service
```

### Example Quadlet File

```ini
# ~/.config/containers/systemd/grafana.container
[Unit]
Description=Grafana Dashboard
After=network-online.target

[Container]
Image=docker.io/grafana/grafana:11.4.0
PublishPort=3000:3000
Volume=grafana-data:/var/lib/grafana:Z
Environment=GF_SECURITY_ADMIN_USER=admin
Network=monitoring.network

[Service]
Restart=always
RestartSec=10

[Install]
WantedBy=default.target
```

> **Note:** The `:Z` suffix on volume mounts is required for SELinux relabeling on Fedora/RHEL systems.

# Monitoring Stack

## Architecture

<!-- Document your monitoring pipeline -->

```
  +-----------+     +-----------+     +---------+
  | Exporters | --> | Prometheus| --> | Grafana |
  | (metrics) |     | :9090     |     | :3000   |
  +-----------+     +-----------+     +---------+

  +-----------+     +-----------+
  | App Logs  | --> |   Loki    |
  | (stdout)  |     |  :3100    |
  +-----------+     +-----------+
```

## Prometheus

<!-- Document Prometheus configuration -->

| Setting | Value |
|---------|-------|
| Scrape Interval | 30s |
| Retention | 30 days |
| Storage | Local TSDB |
| Port | 9090 |

### Scrape Targets

| Job Name | Target | Metrics |
|----------|--------|---------|
| node | server1:9100, server2:9100 | CPU, memory, disk, network |
| docker | server1:9323 | Container stats |
| snmp | server2:9116 | Switch interface counters |
| blackbox | server2:9115 | HTTP/TCP endpoint probes |

## Grafana

<!-- Document Grafana setup -->

| Setting | Value |
|---------|-------|
| Port | 3000 |
| Auth | Local admin + LDAP (optional) |
| Data Sources | Prometheus, Loki |
| Dashboards | Node Overview, Network, Services |

> **See Also:** NET-001, Section 5 --- Network Monitoring for SNMP exporter configuration.

## Alerting

<!-- Document your alerting pipeline -->

| Alert | Condition | Severity | Notification |
|-------|-----------|----------|--------------|
| HostDown | `up == 0` for 2m | Critical | Email |
| HighCPU | CPU > 90% for 10m | Warning | Email |
| DiskFull | Disk > 85% | Warning | Email |
| ServiceDown | HTTP probe fails for 3m | Critical | Email |

> **STATUS: PLANNED** --- Add PagerDuty or Slack webhook integration for critical alerts.

# Reverse Proxy

## Configuration

<!-- Document your reverse proxy setup -->

| Setting | Value |
|---------|-------|
| Software | Nginx or Caddy |
| TLS | Automatic (Let's Encrypt or internal CA) |
| Port | 443 (HTTPS), 80 (redirect) |

## Virtual Hosts

<!-- Document each proxied service -->

| Domain | Backend | Port | Auth | Notes |
|--------|---------|------|------|-------|
| grafana.lab.local | server2 | 3000 | None (Grafana handles auth) | |
| git.lab.local | server2 | 8084 | None (Git server handles auth) | |
| vault.lab.local | server2 | 8200 | None (Vault handles auth) | |
| media.lab.local | server1 | 8096 | Forward auth (SSO) | |

> **Warning:** Services exposed through the reverse proxy must handle their own authentication or use forward-auth with your SSO provider. Never expose an unauthenticated service.

# Git Server

## Deployment

<!-- Document your Git hosting setup -->

| Setting | Value |
|---------|-------|
| Software | Gitea 1.22 |
| Port | 8084 (HTTPS), 2222 (SSH) |
| Storage | /data/gitea |
| Database | SQLite |

## Repositories

<!-- List key repositories -->

| Repository | Description | Visibility |
|------------|-------------|------------|
| lab-infrastructure | Ansible playbooks and configs | Private |
| lab-manuals | This documentation set | Private |
| scripts | Utility scripts and tools | Private |

# Credential Vault

## Deployment

<!-- Document your credential management system -->

| Setting | Value |
|---------|-------|
| Software | Vaultwarden 1.32 |
| Port | 8200 |
| Storage | /data/vaultwarden |
| Backup | Encrypted, daily |

> **Note:** Never store credentials in plain text in configuration files, environment variables, or documentation. Always reference vault paths.

## Vault Organization

<!-- Document how credentials are organized -->

| Folder | Contents |
|--------|----------|
| Network | Firewall, switch, AP credentials |
| Servers | SSH keys, BMC passwords |
| Services | Application admin accounts, API tokens |
| Certificates | TLS private keys, CA certificates |

# Backup System

## Architecture

<!-- Document your backup strategy -->

> **STATUS: PLANNED** --- Implement automated backup with the following architecture.

| Component | Role | Location |
|-----------|------|----------|
| Backup Agent | Initiates backups | Each server |
| Backup Server | Receives and stores backups | Dedicated host or NAS |
| Offsite Copy | Disaster recovery | Remote location or cloud |

## Backup Schedule

| Target | Frequency | Retention | Method |
|--------|-----------|-----------|--------|
| Service configs | Daily | 30 days | File-level backup |
| Container volumes | Daily | 14 days | Volume snapshot |
| Databases | Every 6 hours | 7 days | pg_dump / mysqldump |
| Full system | Weekly | 4 weeks | Image-level backup |

# Maintenance Procedures

## Adding a New Service

<!-- Document the standard process for deploying a new service -->

1. **Plan:** Determine resource requirements (CPU, RAM, storage, ports)
2. **Network:** Request firewall rule and DNS entry (see NET-001)
3. **Deploy:** Create Quadlet `.container` file or Docker Compose definition
4. **Proxy:** Add reverse proxy virtual host entry
5. **Monitor:** Add Prometheus scrape target and Grafana dashboard
6. **Backup:** Configure backup for persistent volumes
7. **Document:** Add entry to this manual's service inventory table

## Service Health Checks

<!-- Document routine checks -->

```bash
# Check all running containers
podman ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check systemd service status
systemctl --user list-units --type=service --state=running

# Verify reverse proxy endpoints
curl -s -o /dev/null -w "%{http_code}" https://grafana.lab.local
```

## Log Management

<!-- Document log rotation and retention -->

| Source | Retention | Storage |
|--------|-----------|---------|
| Container stdout | 7 days | Loki |
| systemd journal | 30 days | Local disk |
| Nginx access logs | 90 days | Local disk + Loki |
| Audit logs | 1 year | Dedicated volume |

> **Warning:** Unmanaged logs can fill disk partitions silently. Ensure all log sources have rotation configured and monitor disk usage with alerts.
