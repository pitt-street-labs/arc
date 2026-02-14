# Chapter 08 -- Server 2 Infrastructure Services

**Depends on:** [Chapter 07](./07-server-2-os.md)
**Required before:** [Chapters 09-10](./09-server-2-monitoring.md)

Core infrastructure services that other services depend on: git hosting, SSO/identity provider, reverse proxy, credential vault, and container registry.

---

## Service Overview

| Service | Container(s) | Port(s) | Purpose |
|---------|-------------|---------|---------|
| <!-- Git hosting --> | <!-- gitea, gitea-postgres --> | <!-- 8084, 2222 --> | Source code, issue tracking |
| <!-- SSO/IdP --> | <!-- authentik-server, authentik-worker, authentik-postgres, authentik-redis --> | <!-- 9443, 9300 --> | Single sign-on, LDAP proxy |
| <!-- Reverse proxy --> | <!-- central-proxy --> | <!-- 8443, 8880 --> | TLS termination, forward-auth |
| <!-- Credential vault --> | <!-- vaultwarden --> | <!-- 8222 --> | Password management |
| <!-- Container registry --> | <!-- zot --> | <!-- 5000 --> | OCI image registry |

---

## Service: Git Hosting

<!-- For each service, document:
     - Container name(s) and images
     - Ports and volumes
     - TLS certificate source
     - Database (type, backup procedure)
     - Configuration highlights
     - Dependencies (what must start first)
     - Deployment commands
-->

### Containers

| Container | Image | Port | Volume |
|-----------|-------|------|--------|
| <!-- gitea --> | <!-- image --> | <!-- port --> | <!-- data path --> |
| <!-- gitea-postgres --> | <!-- image --> | <!-- port --> | <!-- data path --> |

### TLS

<!-- How TLS is configured: Enterprise CA, Let's Encrypt, self-signed -->

### Database Backup

```bash
# Example PostgreSQL dump:
# podman exec <postgres-container> pg_dump -U <user> <db> > backup.sql
```

### Deployment

```bash
# Place Quadlet files in ~/.config/containers/systemd/
# systemctl --user daemon-reload
# systemctl --user start <service>.service
```

---

## Service: SSO / Identity Provider

<!-- Document SSO setup: provider (Authentik, Keycloak, etc.),
     LDAP integration, OIDC configuration, forward-auth proxy setup -->

---

## Service: Reverse Proxy

<!-- Document the reverse proxy (Caddy, Nginx, Traefik, etc.):
     - How services are exposed (subdomain routing, path routing)
     - TLS certificate management
     - Forward-auth integration with SSO
     - Port forwarding from firewall
-->

---

## Service: Credential Vault

<!-- Document Vaultwarden/Bitwarden deployment:
     - Container config
     - TLS setup
     - Admin panel access
     - SSO integration
     - Backup procedure
-->

---

## Service: Container Registry

<!-- Document OCI registry (Zot, Harbor, etc.):
     - Purpose (local image cache, private images)
     - Storage location and size
     - TLS and authentication
-->

---

## Deployment Order

1. <!-- Database containers first (postgres instances) -->
2. <!-- Core services (git, vault) -->
3. <!-- SSO (needs its database) -->
4. <!-- Reverse proxy (needs all backends running) -->
5. <!-- Registry -->

---

## Verification Checklist

- [ ] Git hosting accessible at URL, can clone a repo
- [ ] SSO login page loads
- [ ] Reverse proxy routes to all backends
- [ ] Vault accessible, CLI retrieves items
- [ ] Registry accepts push/pull
