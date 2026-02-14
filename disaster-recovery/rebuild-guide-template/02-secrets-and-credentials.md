# Chapter 02 -- Secrets and Credentials

**Depends on:** [Chapter 01](./01-physical-topology.md) (network connectivity)
**Required before:** All remaining chapters (credentials needed for every system)

This chapter documents the credential management system, complete credential inventory, and access procedures for every service in the lab.

---

## Credential Management Architecture

### Primary: Password Vault

<!-- Document your primary credential store -->

| Setting | Value |
|---------|-------|
| Software | <!-- Vaultwarden, Bitwarden, KeePass, etc. --> |
| URL | <!-- https://vault.lab.example.com --> |
| User | <!-- admin user --> |
| TLS | <!-- cert type, expiry --> |
| Data Location | <!-- path on server --> |
| Container | <!-- how it runs --> |

### Offline Backup

<!-- Document your emergency offline credential backup -->

| Setting | Value |
|---------|-------|
| Path | <!-- /path/to/encrypted/backup --> |
| Format | <!-- YAML/JSON, encryption method --> |
| Status | <!-- Read-only backup, use vault as primary --> |

### Emergency Access (Vault Lockout)

<!-- Document how to access credentials if the vault is down -->

1. <!-- Decrypt offline backup -->
2. <!-- Extract needed credentials -->
3. <!-- Restore vault from backup before resuming -->

---

## Vault CLI Protocol

<!-- Document how to use your vault's CLI tool -->

### Step 1: Prepare (if TLS CA needed)

```bash
# If your vault uses a private CA, ensure the CA cert is available
# sudo cp /path/to/ca.crt /tmp/ca.crt && chmod 644 /tmp/ca.crt
```

### Step 2: Login / Unlock

```bash
# Example for Bitwarden/Vaultwarden CLI:
# bw login user@lab.example.com
# bw unlock
# export BW_SESSION=<token>
```

### Step 3: Retrieve Credentials

```bash
# Best practice: write to file, parse, delete -- never pipe directly
# bw get item <name> > /tmp/item.json
# python3 -c "import json; print(json.load(open('/tmp/item.json'))['login']['password'])"
# rm /tmp/item.json
```

---

## Complete Credential Inventory

### Firewall

| Vault Item | Type | Username | Purpose |
|-----------|------|----------|---------|
| <!-- firewall --> | Login | <!-- user --> | SSH/WebUI password |
| <!-- firewall.api --> | Secure note | -- | API key + secret |
| <!-- firewall.bmc --> | Login | <!-- user --> | BMC access |
| <!-- firewall.encryption --> | Secure note | -- | Disk encryption passphrase |

### Server 1

| Vault Item | Type | Username | Purpose |
|-----------|------|----------|---------|
| <!-- server-1.ssh --> | Login | <!-- user --> | SSH key reference |
| <!-- server-1.bmc --> | Login | <!-- user --> | BMC access |
| <!-- server-1.luks --> | Login | -- | LUKS disk unlock passphrase |

### Server 2

| Vault Item | Type | Username | Purpose |
|-----------|------|----------|---------|
| <!-- server-2.ssh --> | Login | <!-- user --> | SSH key reference |
| <!-- server-2.bmc --> | Login | <!-- user --> | BMC access |
| <!-- server-2.luks --> | Login | -- | LUKS disk unlock passphrase |

### Network Equipment

| Vault Item | Type | Purpose |
|-----------|------|---------|
| <!-- switch.user --> | <!-- type --> | Switch SSH username |
| <!-- switch.password --> | <!-- type --> | Switch SSH password |
| <!-- switch.enable --> | <!-- type --> | Switch enable secret |

### Directory Services

| Vault Item | Type | Purpose |
|-----------|------|---------|
| <!-- ad.admin --> | <!-- type --> | Domain admin password |
| <!-- ad.dsrm --> | <!-- type --> | Directory Services Restore Mode |

### Infrastructure Services

| Vault Item | Type | Purpose |
|-----------|------|---------|
| <!-- vault.secrets --> | <!-- type --> | Vault admin token |
| <!-- git.api --> | <!-- type --> | Git API token |
| <!-- sso.secrets --> | <!-- type --> | SSO admin + API token |
| <!-- monitoring.creds --> | <!-- type --> | Monitoring web UI |

### VoIP

| Vault Item | Type | Purpose |
|-----------|------|---------|
| <!-- pbx.admin --> | <!-- type --> | PBX web UI admin |
| <!-- sip.credentials --> | <!-- type --> | SIP trunk credentials |

### External Services

| Vault Item | Type | Purpose |
|-----------|------|---------|
| <!-- dns.api --> | <!-- type --> | DNS provider API key |
| <!-- email.api --> | <!-- type --> | Email service API key |
| <!-- vpn.config --> | <!-- type --> | VPN config + peer keys |

---

## Credential Access Recipes

### SSH to Lab Systems

```bash
# Server 1 (SSH key)
# ssh -i ~/.ssh/server-1-key labadmin@10.0.20.10

# Server 2 (SSH key)
# ssh -i ~/.ssh/server-2-key labadmin@10.0.20.20

# Firewall (password auth -- may need expect for special chars)
# <retrieve password from vault>
# ssh root@10.0.10.1
```

### Out-of-Band Management (BMC)

```bash
# IPMI examples:
# ipmitool -I lanplus -H <bmc-ip> -U <user> -P <pass> power status

# Some BMCs require specific cipher suites:
# ipmitool -I lanplus -H <bmc-ip> -U <user> -P <pass> -C 3 power status
```

### LUKS Disk Unlock

<!-- Document how to unlock each server's root volume after reboot -->
<!-- Include which console method works (serial, KVM, BMC text console) -->

### Switch Access

```bash
# Legacy switches may require old SSH ciphers:
# ssh -o KexAlgorithms=+diffie-hellman-group14-sha1 \
#     -o HostKeyAlgorithms=+ssh-rsa \
#     -o Ciphers=+aes128-cbc admin@10.0.10.21
```

---

## Vault Item Naming Convention

<!-- Document your naming convention for vault items -->

Items follow the pattern `device.subsection`:
- Login type: `login.username` + `login.password`
- Secure Note type: data in `notes` field
- Special cases: LUKS items (password-only), API items (multi-line notes), keyfile items (base64 custom field)

---

## Known Gotchas

<!-- Document credential-related pitfalls specific to your environment -->

- <!-- e.g., special characters in passwords that need escaping -->
- <!-- e.g., pipe pattern: never pipe vault CLI output directly -->
- <!-- e.g., BMC default credentials that should be changed -->
- <!-- e.g., legacy cipher requirements for old equipment -->

---

## Credential Rotation Status

| Credential | Last Rotated | Due | Notes |
|-----------|-------------|-----|-------|
| <!-- server-1 SSH key --> | <!-- date --> | <!-- date --> | |
| <!-- server-2 SSH key --> | <!-- date --> | <!-- date --> | |
| <!-- firewall password --> | <!-- date --> | <!-- date --> | |
| <!-- BMC defaults --> | <!-- status --> | <!-- status --> | |

---

## Verification Checklist

- [ ] Vault accessible at its URL
- [ ] Vault CLI retrieves a test item successfully
- [ ] Firewall SSH login succeeds
- [ ] Server 1 SSH login succeeds
- [ ] Server 2 SSH login succeeds
- [ ] All BMCs respond to IPMI queries
- [ ] Offline backup file exists and decrypts
