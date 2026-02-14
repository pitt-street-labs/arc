# Chapter 16 -- Storage and Media

**Depends on:** [Chapter 05](./05-server-1-os.md), [Chapter 07](./07-server-2-os.md), [Chapter 12](./12-workstation.md)

## Storage Inventory

| Host | Mount | Device | Size | Encryption | Purpose |
|------|-------|--------|------|------------|---------|
| <!-- server-1 --> | / | <!-- device --> | <!-- size --> | LUKS2 | OS |
| <!-- server-1 --> | /data | <!-- device --> | <!-- size --> | LUKS2 | Data |
| <!-- server-2 --> | / | <!-- device --> | <!-- size --> | LUKS2 | OS |
| <!-- server-2 --> | /mnt/external | <!-- device --> | <!-- size --> | LUKS2 | Backup |
| <!-- workstation --> | / | <!-- device --> | <!-- size --> | LUKS2 | OS |
| <!-- workstation --> | /mnt/data | <!-- device --> | <!-- size --> | <!-- type --> | Data |

---

## LUKS Key Inventory

| Volume | Host | Key Source | Vault Item |
|--------|------|-----------|------------|
| <!-- root --> | <!-- server-1 --> | Manual passphrase | <!-- item --> |
| <!-- data --> | <!-- server-1 --> | Keyfile auto-unlock | <!-- item --> |

---

## Backup Strategy

<!-- Document backup targets, schedules, retention policies -->

---

## Media Libraries

<!-- If you have media collections, document location, format, and catalog tools -->

---

## NFS/SMB Shares

<!-- Cross-system file sharing configuration -->

---

## Verification Checklist

- [ ] All LUKS volumes open and mounted
- [ ] All NFS/SMB shares accessible
- [ ] Backup jobs completing successfully
- [ ] LUKS keyfiles backed up in vault
