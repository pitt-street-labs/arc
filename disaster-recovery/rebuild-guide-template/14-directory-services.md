# Chapter 14 -- Directory Services

**Depends on:** [Chapter 05](./05-server-1-os.md), [Chapter 07](./07-server-2-os.md) (DCs are VMs on servers)

## Overview

<!-- Active Directory, FreeIPA, OpenLDAP -- document your directory services -->

| Component | Value |
|-----------|-------|
| Domain | <!-- ad.example.com --> |
| Forest functional level | <!-- level --> |
| DC count | <!-- number --> |

---

## Domain Controller Inventory

| DC | Host | VM Name | IP | FSMO Roles |
|----|------|---------|-----|-----------|
| <!-- DC1 --> | <!-- server-1 --> | <!-- vm-name --> | <!-- IP --> | <!-- roles --> |
| <!-- DC2 --> | <!-- server-2 --> | <!-- vm-name --> | <!-- IP --> | <!-- roles --> |

---

## DNS Integration

<!-- How AD DNS integrates with your firewall DNS (forwarding, zone delegation) -->

---

## LDAP Integration

<!-- Services that authenticate via LDAP: SSO, git, email, etc. -->

---

## Backup and Recovery

<!-- AD backup procedure, DSRM passwords, BitLocker recovery keys -->

---

## Rebuild Procedure

<!-- How to rebuild DCs from scratch if VMs are lost -->

---

## Verification Checklist

- [ ] Both DCs are running and replicating
- [ ] DNS resolution for AD domain works
- [ ] LDAP bind succeeds from SSO provider
- [ ] Domain join works from a test client
