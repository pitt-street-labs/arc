# Chapter 15 -- VM Fleet

**Depends on:** [Chapter 05](./05-server-1-os.md), [Chapter 07](./07-server-2-os.md)

## VM Inventory

| VM | Host | State | Autostart | vCPU | RAM | Network | Purpose |
|----|------|-------|-----------|------|-----|---------|---------|
| <!-- name --> | <!-- server --> | <!-- running/off --> | <!-- yes/no --> | <!-- N --> | <!-- GB --> | <!-- bridge --> | <!-- purpose --> |

---

## VM Disk Images

| VM | Disk Path | Format | Size |
|----|-----------|--------|------|
| <!-- name --> | <!-- /var/lib/libvirt/images/xxx.qcow2 --> | qcow2 | <!-- GB --> |

---

## VM Network Configuration

<!-- Which VMs use bridged networking, which use NAT, IP assignments -->

---

## Backup and Restore

```bash
# Export VM definition
virsh dumpxml <vm-name> > vm-<name>.xml

# Restore VM
virsh define vm-<name>.xml
virsh autostart <vm-name>  # if needed
```

---

## Rebuild from Scratch

<!-- For each critical VM, document the installation procedure -->

---

## Verification Checklist

- [ ] All VMs defined in libvirt
- [ ] Autostart VMs are running after host reboot
- [ ] VM network connectivity verified
