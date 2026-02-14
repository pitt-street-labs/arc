# Chapter 17 -- PKI and TLS

**Depends on:** [Chapter 14](./14-directory-services.md) (CA lives on directory services or dedicated host)

## Certificate Authority Architecture

| CA | Type | Host | Purpose |
|----|------|------|---------|
| <!-- Root CA --> | <!-- offline/online --> | <!-- host --> | Root of trust |
| <!-- Enterprise/Intermediate CA --> | <!-- AD CS, step-ca, etc. --> | <!-- host --> | Issues leaf certs |

---

## Certificate Inventory

| Service | Hostname (SAN) | Issuer | Expiry | Cert Path |
|---------|---------------|--------|--------|-----------|
| <!-- firewall WebUI --> | <!-- fqdn --> | <!-- CA --> | <!-- date --> | <!-- path --> |
| <!-- git hosting --> | <!-- fqdn --> | <!-- CA --> | <!-- date --> | <!-- path --> |
| <!-- etc. --> | | | | |

---

## Certificate Request Procedure

<!-- How to request a new certificate from your CA -->

---

## Trust Store Configuration

<!-- How to install CA cert on Linux, Windows, browsers -->

---

## Certificate Renewal

<!-- Renewal procedure, automation (certbot, etc.) -->

---

## Verification Checklist

- [ ] CA cert installed in trust stores on all systems
- [ ] All services present valid certificates
- [ ] No certificates expiring within 30 days
