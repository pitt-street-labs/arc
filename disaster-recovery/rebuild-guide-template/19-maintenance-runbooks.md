# Chapter 19 -- Maintenance Runbooks

**Depends on:** Everything (operational procedures reference all systems)

## Routine Maintenance

### OS Updates

<!-- Update procedure for each system, reboot policy -->

### Certificate Renewal

<!-- When and how to renew certificates -->

### Credential Rotation

<!-- Schedule and procedure for rotating passwords and SSH keys -->

### Backup Verification

<!-- How to verify backups are current and restorable -->

---

## Emergency Procedures

### Server Unresponsive

<!-- Steps: ping, SSH, BMC console, IPMI power cycle, LUKS unlock -->

### Firewall Down

<!-- Emergency recovery via BMC, config restore -->

### Disk Failure

<!-- SMART alerts, drive replacement, RAID rebuild, LUKS recovery -->

### Network Outage

<!-- Diagnostic steps: check bond, LACP, switch, firewall -->

### Container Crash Loop

<!-- Diagnose via journalctl, check volumes, restart procedure -->

---

## Scheduled Tasks

| Task | Frequency | Host | Script/Method |
|------|-----------|------|---------------|
| <!-- state capture --> | Weekly | Workstation | `state-capture/capture.sh` |
| <!-- backup verify --> | Monthly | Servers | <!-- method --> |
| <!-- cert check --> | Monthly | All | <!-- method --> |
| <!-- update check --> | Weekly | Servers | <!-- method --> |

---

## Monitoring Alerts Response

| Alert | Severity | Response |
|-------|----------|----------|
| <!-- Host Down --> | Critical | <!-- steps --> |
| <!-- Disk >90% --> | Warning | <!-- steps --> |
| <!-- Container Failed --> | Warning | <!-- steps --> |
| <!-- Certificate Expiring --> | Warning | <!-- steps --> |
