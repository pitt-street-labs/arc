# Chapter 06 -- Server 1 Services

**Depends on:** [Chapter 05](./05-server-1-os.md)
**Required before:** [Chapter 16](./16-storage-and-media.md), [Chapter 19](./19-maintenance-runbooks.md)

Server 1 runs containerized services managed via Podman Quadlet (systemd). Never use `podman-compose` or `podman run` for persistent services.

---

## Container Overview

<!-- List all containers on this server -->

| # | Container | Image | Port | Purpose |
|---|-----------|-------|------|---------|
| 1 | <!-- name --> | <!-- image:tag --> | <!-- port --> | <!-- purpose --> |
| 2 | <!-- name --> | <!-- image:tag --> | <!-- port --> | <!-- purpose --> |
| <!-- etc. --> | | | | |

**Networks:** <!-- list Podman networks -->

---

## Service Group: <!-- Name -->

<!-- Repeat this section for each logical group of containers -->

### Storage

| Path | Size | Contents |
|------|------|----------|
| <!-- /data/service/ --> | <!-- size --> | <!-- description --> |

### Container Startup Order

<!-- Document After= dependencies between containers -->

1. <!-- database container first -->
2. <!-- backend containers -->
3. <!-- frontend/proxy last -->

### Critical Configuration

<!-- SELinux labels, resource limits, resolver settings, concurrency limits -->

### Backup

<!-- Backup target, script, schedule -->

### Management Commands

```bash
# Start/stop service group
systemctl --user start <service-1> <service-2> <service-3>
systemctl --user stop <service-3> <service-2> <service-1>

# Check status
systemctl --user status <service-*>

# View logs
journalctl --user -u <service> -f
```

---

## Service Group: <!-- Next Group -->

<!-- Repeat the service group template -->

---

## Standalone Services

### <!-- service name -->

| Setting | Value |
|---------|-------|
| Port | <!-- port --> |
| Purpose | <!-- description --> |

---

## Boot Serialization

<!-- Document the tier ordering for container startup -->

```
Tier 1: database containers
Tier 2: backend services
Tier 3: frontend/proxy
Tier 4: utility services
```

Maximum <!-- N --> concurrent container starts per tier.

---

## Quadlet File Locations

All Quadlet files are in `~/.config/containers/systemd/`:

```
<!-- list all .container and .network files -->
```

---

## Verification Checklist

- [ ] `systemctl --user list-units --type=service | grep running` shows expected count
- [ ] <!-- Service 1 accessible at URL -->
- [ ] <!-- Service 2 accessible at URL -->
- [ ] <!-- Metrics endpoint returns data -->
