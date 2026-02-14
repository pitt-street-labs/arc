# Chapter 10 -- Server 2 Application Services

**Depends on:** [Chapter 07](./07-server-2-os.md), [Chapter 08](./08-server-2-infrastructure.md)

Application-tier containers deployed in waves. These are the user-facing services beyond core infrastructure.

---

## Deployment Wave Plan

<!-- Organize services into waves based on priority and dependency -->

| Wave | Services | Count | Status |
|------|----------|-------|--------|
| 1 | <!-- highest priority services --> | <!-- N --> | <!-- deployed/planned --> |
| 2 | <!-- next priority --> | <!-- N --> | |
| 3 | <!-- etc. --> | | |

---

## Wave 1: <!-- Category Name -->

### <!-- Service Name -->

| Setting | Value |
|---------|-------|
| Container | <!-- name --> |
| Image | <!-- image:tag --> |
| Port | <!-- port --> |
| Volume | <!-- data path --> |
| SSO | <!-- yes/no, method --> |
| Proxy | <!-- reverse proxy path --> |

<!-- Repeat for each service in the wave -->

---

## Wave 2: <!-- Category Name -->

<!-- Same structure -->

---

## Container Port Registry

<!-- Master list of all port assignments to avoid conflicts -->

| Port | Service | Protocol |
|------|---------|----------|
| <!-- 8100 --> | <!-- service --> | TCP |
| <!-- 8101 --> | <!-- service --> | TCP |
| <!-- etc. --> | | |

---

## SSO Integration

<!-- Which services use SSO, which use forward-auth proxy, which have local auth -->

| Service | Auth Method | SSO Provider |
|---------|------------|-------------|
| <!-- service --> | OIDC | <!-- provider --> |
| <!-- service --> | Forward-auth | <!-- provider --> |
| <!-- service --> | Local | N/A |

---

## Database Services

<!-- Shared vs. dedicated database containers -->

| Database | Container | Clients |
|----------|-----------|---------|
| <!-- postgres-1 --> | <!-- container --> | <!-- services --> |
| <!-- redis-1 --> | <!-- container --> | <!-- services --> |

---

## Deployment Procedure

```bash
# For each wave:
# 1. Place Quadlet files in ~/.config/containers/systemd/
# 2. Reload systemd
systemctl --user daemon-reload

# 3. Start database containers first
systemctl --user start <db-service>.service

# 4. Start application containers
systemctl --user start <app-service>.service

# 5. Add DNS records on firewall
# 6. Add reverse proxy routes
# 7. Open firewall ports
```

---

## Verification Checklist

- [ ] All wave 1 services accessible via reverse proxy
- [ ] SSO login works for integrated services
- [ ] Database containers healthy
- [ ] No port conflicts in `ss -tlnp`
