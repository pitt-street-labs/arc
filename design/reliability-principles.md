# ARC Reliability & Portability Principles

> Design considerations for decade-scale operation, hardware transplantation, and "always on, always running" resilience

## Purpose

ARC-001 runs 97 services across 5 hosts with container orchestration, VLAN segmentation, reverse proxies, SSO, and a monitoring stack. This is excellent engineering for a homelab. It is fragile engineering for a post-collapse system.

Every layer of abstraction (container runtime, orchestrator, reverse proxy, SSO provider, DNS resolver) is a layer that can fail, that someone must understand, and that must be reproduced on unknown future hardware. This document defines 11 architectural principles that ensure ARC survives being ripped out of a 6U rack and dropped onto three laptops and a NAS someone found in a warehouse.

These aren't prescriptions to rearchitect today. They're a **lens** to evaluate every future decision through.

---

## Principle 1: The `cp -r` Test

**The single most important reliability test: can you copy the entire system to a new disk and have it work?**

Every architectural decision should be evaluated against this. If migrating a service requires reconfiguring database connection strings, regenerating TLS certificates, updating DNS records, re-authenticating OAuth2 clients, and rebuilding container images — that service will not survive transplantation.

### What Passes Today

| Asset | Format | Why It Passes |
|-------|--------|---------------|
| Kiwix ZIM files | Self-contained archive | Zero config, any Kiwix reader works |
| Calibre-Web library | SQLite DB + ebook files | Copy directory, point new instance at it |
| Atlas tile directories | z/x/y file tree | Any tile server reads the same format |
| 3D print STL archive | Flat files | No database dependency |
| F-Droid APK mirror | Flat files + metadata JSON | Self-describing |
| GGUF model files | Self-contained | Any llama.cpp reads them |

### What Fails Today

| Service | Why It Fails | What Breaks |
|---------|-------------|-------------|
| OpenEMR | MySQL + PHP + Apache + OAuth2 + TLS | Connection strings, auth config, certificates |
| Authentik | PostgreSQL + Redis + LDAP bindings + OIDC configs | Every service's SSO integration |
| Grafana | PostgreSQL + datasource configs + dashboard provisioning | Prometheus URL references, credential stores |
| FarmOS | Drupal + MySQL + OAuth2 | PHP runtime, database connection, auth |
| Wiki.js | PostgreSQL + custom config | Database migration, search index rebuild |

### Design Recommendation

For every P0/P1 service, document a "cold start on blank hardware" procedure that a competent but non-expert person can execute. If that procedure is longer than one page, the service is too complex for its criticality tier.

---

## Principle 2: SQLite Is the Most Important Technology in ARC

SQLite has properties no other database engine offers for ARC's constraints:

| Property | Why It Matters for ARC |
|----------|----------------------|
| **Single file** | Backup = cp. Migration = cp. Recovery = cp. |
| **Zero configuration** | No server process, no port, no auth, no connection strings |
| **Runs everywhere** | Every OS, every CPU architecture, every language has bindings |
| **ACID compliant** | Data integrity without a DBA |
| **Corruption-resistant** | WAL mode survives power loss; `PRAGMA integrity_check` verifies |
| **2050 support commitment** | The author has publicly pledged support until 2050 |
| **Concurrent reads** | Multiple processes can read simultaneously |
| **Embedded** | No client-server protocol — library linked directly into application |

### Application to ARC

Every service that stores structured data critical to ARC operations should either:

1. **Use SQLite natively** (Grocy, Calibre-Web, Vikunja already do), or
2. **Have an export-to-SQLite procedure** that runs nightly

When the MySQL instance backing OpenEMR dies in year 4, the SQLite export file is still readable by any language on any hardware. Applications are replaceable; data is not.

### Critical Data That Needs SQLite Exports

| Data | Current Storage | Export Format |
|------|----------------|---------------|
| Patient records | MySQL (OpenEMR) | SQLite: patients, encounters, allergies, medications |
| Community credentials | PostgreSQL (Vaultwarden) | Encrypted SQLite (already has bitwarden export) |
| User accounts & groups | Active Directory (DC1/DC2) | SQLite: users, groups, memberships (from LDIF) |
| Governance records | PostgreSQL (Wiki.js) | Markdown files + SQLite index |
| Farm data | MySQL (FarmOS/Drupal) | SQLite: fields, harvests, livestock, water sources |
| Financial records | PostgreSQL (Firefly III) | SQLite: transactions, accounts, categories |

---

## Principle 3: Static Binaries Over Container Stacks

Containers solve dependency isolation and reproducible builds. In a post-collapse context, they introduce failure modes:

| Container Failure Mode | Impact |
|----------------------|--------|
| Container runtime crash (Podman/Docker) | All services down simultaneously |
| Image registry unavailable (Zot down) | Cannot pull images for new deployments |
| Volume mount corruption | Data loss for services using named volumes |
| Network namespace issues | Services can't reach each other |
| OCI spec changes between runtime versions | Old images may not run on new runtime |
| BoltDB lock contention (current issue) | Cascading failures across all containers |

A statically-linked Rust binary that reads a TOML config file and writes to a SQLite database has **zero external dependencies**. It runs on any Linux kernel from 3.2 onward. It survives OS reinstalls, container runtime upgrades, and hardware transplantation.

### What This Means Practically

1. **ARCAI middleware** — must be a static binary, not a containerized app
2. **Critical data services** — should have lightweight static-binary fallback readers
3. **Reference services** (Kiwix, Calibre, Atlas) — already file-based, leave them alone
4. **Monitoring** — a shell script checking `systemctl is-active` + writing to a log is more reliable than a 4-container Prometheus/Grafana/Loki/Alloy stack

**General principle:** The reliability of a system is inversely proportional to its dependency count.

---

## Principle 4: Heterogeneous Compute Mesh — Keep It Stupid Simple

The vision of multiple computers pooling GPUs for distributed inference is achievable — if kept simple.

### What Works: Stateless HTTP Inference

Ollama exposes inference as a stateless HTTP API. This is the entire distributed compute architecture needed:

```
Any device with a GPU or sufficient CPU:
  1. Install Ollama (or llama-server)
  2. Pull/copy model file
  3. Listen on port 11434

ARCAI middleware:
  1. Maintain a list of inference endpoints
  2. Health-check each every 30 seconds
  3. Route requests to any healthy endpoint
  4. If one dies, remove from list. If one joins, add to list.
```

No Kubernetes. No container orchestration. No consensus protocol. No distributed state. Each inference instance is independent, stateless, and disposable.

### Service Discovery Progression

| Version | Mechanism | Complexity | Infrastructure Required |
|---------|-----------|------------|------------------------|
| v0 | TOML file listing endpoints, edited by hand | Trivial | Text editor |
| v1 | mDNS/Avahi — each node advertises `_arcai._tcp.local` | Low | avahi-daemon (preinstalled on most Linux) |
| v2 | Gossip protocol over Reticulum mesh | Medium | Mesh transport |

mDNS is built into every Linux distribution. Zero configuration, zero DNS infrastructure, works on ad-hoc WiFi networks.

### What Doesn't Work: Distributed Model Sharding

Splitting a single model across GPUs on different physical machines requires low-latency high-bandwidth interconnect (not WiFi, not LoRa), synchronized memory management, tensor parallelism frameworks, and identical GPU architectures.

**Don't attempt it.** A mesh of five laptops each running a 7B model independently is more reliable than five laptops collaborating on one 35B model. The quality gap between 7B and 35B matters less than the reliability gap between "works" and "might work."

### GPU Scheduling

When multiple models compete for one GPU, use **temporal partitioning:**

- Emergency queries preempt everything (model hot-swap ~5 seconds)
- Waking hours: inference model loaded
- Quiet hours (0200-0600): training, fine-tuning, batch RAG indexing
- TTS loaded on-demand, released after 60 seconds idle

This can be a 50-line shell script. It doesn't need to be software.

---

## Principle 5: Graceful Degradation Tiers

Extend the P0-P3 service criticality tiers into a hardware degradation model:

| Available Hardware | What Runs | What Doesn't |
|-------------------|-----------|-------------|
| **Full rack** (current ARC-001) | Everything. All 97 services. Full GPU inference. | Nothing missing |
| **Two servers** | P0 + P1 services. AI on CPU (7B Q4, ~15 tok/s). | P2/P3 shed. No GPU inference. |
| **One server** | P0 only. All critical services on one host. | P1/P2/P3 shed. Monitoring minimal. |
| **One laptop + external drive** | Kiwix, SQLite patient records, basic AI (3B Q4). File-based everything. | No containers. No database servers. No monitoring stack. |
| **Raspberry Pi + USB drive** | Kiwix reader, 1.5B Q4 Q&A, LXMF mesh relay. | Text only. No web UIs. Terminal interface. |
| **USB thumb drive only (HAL)** | Boot, read ZIM files, basic Q&A with 1.5B model. | No persistent records. Read-only reference. |

**Key insight:** Every tier should be an **additive layer**, not a different system. The same data formats, the same query patterns, the same file structures. Moving from a Pi to a full rack means "more services start," not "we set up a completely different architecture."

This means:
- Patient records: SQLite file readable on Pi, laptop, server
- Knowledge corpus: ZIM + ebook + tile files — no database for read access
- Configuration: TOML files, not database-stored settings
- ARCAI: single binary that scales behavior based on what responds to health checks

---

## Principle 6: Eliminate Software SPOFs

Hardware SPOFs (one power supply, one switch, one UPS) are acceptable — you can't duplicate physical infrastructure infinitely. Software SPOFs are unacceptable because they're free to eliminate.

| Current SPOF | Impact if Down | Mitigation |
|-------------|----------------|------------|
| **Authentik SSO** | All authenticated services inaccessible | Every service must have a local admin fallback account |
| **Unbound DNS (FIREWALL)** | No service discovery by name | `/etc/hosts` with all service IPs, distributed on ARC drive |
| **Central Proxy (nginx)** | No web access to proxied services | Direct port access must always work |
| **Active Directory** | No SSO, no group membership | Local accounts + LDIF export on ARC drive |
| **Podman runtime** | All containerized services down | P0 services must have non-containerized fallback |
| **Vaultwarden** | No credential access | Encrypted credential export on ARC drive |

**The test:** Shut down Authentik, Unbound DNS, and the central proxy simultaneously. Can the medic still access patient records? If not, there is a critical reliability flaw.

**Design recommendation:** P0 services must work with zero infrastructure services — no DNS, no SSO, no proxy, no container runtime. Just the application, a data file, and a network connection (or not even that).

---

## Principle 7: Human-Readable State

Every piece of critical state should be readable by a human with a text editor. Not a database client. Not a web UI. A text editor.

| Data | Current Format | Human-Readable Fallback |
|------|---------------|------------------------|
| Patient records | MySQL (OpenEMR) | Nightly export to CSV/JSON per patient |
| Food inventory | SQLite (Grocy) | SQLite already readable with `sqlite3` CLI |
| Credentials | PostgreSQL (Vaultwarden) | Encrypted YAML export (already exists) |
| Service configuration | Container env vars, DB settings | Single TOML file per service on ARC drive |
| Maps | Tile files (Atlas) | Already human-navigable as file directories |
| Knowledge | ZIM files (Kiwix) | Already self-contained |
| Community records | PostgreSQL (Wiki.js) | Export to Markdown files on ARC drive |

**Why this matters:** In year 7, the maintainer may not know what PostgreSQL is. They may not know how to run `psql`. But they can open a text file. If the patient allergy list is a JSON file on the ARC drive, it's accessible to anyone on any computer forever.

---

## Principle 8: The Laminated Card Test

For every critical procedure: **can it fit on a laminated card that lives physically next to the hardware?**

### Cards That Should Exist

1. **Cold boot procedure** — Power-on order, BIOS boot sequence, LUKS passphrase location, service verification checklist
2. **Add a new computer to the mesh** — Connect to network, install Ollama, pull model, verify with `curl localhost:11434`
3. **Patient emergency when IT is down** — Open SQLite file at `/arc/data/patients.db`, query: `SELECT * FROM patients WHERE name LIKE '%smith%'`
4. **Restore from ARC drive** — Plug in drive, run `./restore.sh`, enter passphrase, wait for services
5. **Generator won't start** — Fuel check, oil check, battery check, pull start, manual transfer switch position

If a procedure requires 20 pages of documentation, it won't be executed correctly under stress. If it's 10 steps on a laminated card, it will.

**Design recommendation:** Every P0 service gets a laminated card. These cards are part of the ARC system — as important as the software.

---

## Principle 9: Time-Tested Over Cutting-Edge

ARC is designed for decades. Choose technologies with long track records:

| Prefer | Over | Rationale |
|--------|------|-----------|
| SQLite | CockroachDB, SurrealDB | 24 years old, runs everywhere, committed to 2050 |
| HTTP/REST | gRPC, GraphQL | Every language, every device, every era understands it |
| TOML/JSON config files | etcd, Consul, Vault | Text files on disk outlast all configuration services |
| systemd services | Kubernetes, Docker Compose | systemd exists as long as Linux exists |
| mDNS (Avahi) | Consul, CoreDNS | Built into every Linux distribution since 2005 |
| SSH | Tailscale, Nebula, WireGuard mesh | Works with nothing but OpenSSH |
| Cron | Temporal, Airflow | Will exist until heat death |
| rsync | Custom replication protocols | 28 years old, handles interruption, works over SSH |
| ext4 | ZFS, Btrfs | Most battle-tested filesystem. Boring. Reliable. |

For the **foundation** (data storage, service management, networking, scheduling), choose boring technology. Use interesting technology for **applications** (LLM inference, 3D model search, signal analysis) where failure is inconvenient but not catastrophic.

---

## Principle 10: Reduce the Service Count

The hardest recommendation but the most impactful. 97 services is too many for a system maintained by a small team under stress.

### Consolidation Opportunities

| Current (Multiple Services) | Consolidated Alternative | Count Reduction |
|---------------------------|------------------------|-----------------|
| Grocy + InvenTree + Cannery + OpenBoxes + Homebox | One inventory system with categories (Grocy with extensions, or custom) | 5 → 1 |
| Vikunja + Taiga | One task system (Vikunja already has Kanban boards) | 2 → 1 |
| Trilium + Wiki.js + Nextcloud Notes | One knowledge base (Wiki.js or Trilium) | 3 → 1 |
| Firefly III + Actual Budget | One financial tracker | 2 → 1 |
| Prometheus + Grafana + Loki + Alloy + Alertmanager + Uptime Kuma + Healthchecks | One monitoring system + shell scripts | 7 → 2 |
| Calibre-Web + Digital Library | One library interface | 2 → 1 |

**Potential reduction:** 97 → ~60-70 services with equivalent functional coverage.

Every eliminated service is:
- One fewer thing that can break
- One fewer thing someone must understand
- One fewer container image to store and maintain
- One fewer API for ARCAI to integrate with
- One fewer credential to manage
- Less RAM, less CPU, less power

**The counterargument:** specialized tools do their jobs better. True. But "does its job at all, reliably, for years" beats "does its job perfectly but requires a DevOps engineer to keep running."

---

## Principle 11: Offline-First Data Architecture

Every piece of data ARCAI needs should exist as a **file on the ARC drive**, not as a response from a running service. Services provide convenient access; files provide guaranteed access.

### ARC Drive Layout

```
/arc/
├── knowledge/              # Read-only reference corpus
│   ├── zim/                # Kiwix ZIM files (Wikipedia, medical, StackExchange)
│   ├── ebooks/             # Calibre library (survival, medical, technical)
│   ├── tiles/              # Atlas satellite/vector tiles (z0-z13)
│   ├── models-3d/          # STL/3MF printable models (193k+)
│   ├── video/              # Archived instructional video
│   └── legal/              # Corpus Juris legal reference
├── data/                   # Writable operational data
│   ├── patients.db         # SQLite: patient records (OpenEMR export)
│   ├── inventory.db        # SQLite: food/parts/ammo (Grocy/InvenTree export)
│   ├── farm.db             # SQLite: fields, harvests, livestock (FarmOS export)
│   ├── tasks.db            # SQLite: work orders (Vikunja export)
│   ├── credentials.db      # SQLite: credential vault (encrypted)
│   ├── people.db           # SQLite: community members, skills, training (Monica export)
│   └── governance/         # Markdown: constitution, rulings, precedents
├── config/                 # TOML: all configuration
│   ├── arcai.toml          # ARCAI middleware settings
│   ├── services.toml       # Service registry (endpoints, auth)
│   └── roles.toml          # Role definitions and domain access
├── models/                 # GGUF model files for ARCengine
│   ├── qwen2.5-7b-q4.gguf # Primary inference model
│   ├── classifier.gguf     # Domain classifier
│   └── embeddings.gguf     # RAG embedding model
├── bin/                    # Static binaries (multi-arch)
│   ├── x86_64/
│   │   ├── arcai           # ARCAI middleware
│   │   ├── llama-server    # llama.cpp inference
│   │   └── kiwix-serve     # Kiwix server
│   └── aarch64/
│       ├── arcai           # Same binary, ARM64
│       ├── llama-server
│       └── kiwix-serve
├── procedures/             # Laminated card content
│   ├── cold-boot.md
│   ├── add-node.md
│   ├── patient-emergency.md
│   └── restore-from-drive.md
└── bootstrap.sh            # "Plug in drive, run this script"
```

### Transplantation Procedure

When ARC is moved to new hardware:

1. Mount the ARC drive
2. Run `./bootstrap.sh` — detects CPU architecture, links correct binaries
3. `./bin/{arch}/arcai --config ./config/arcai.toml` starts
4. ARCAI reads `services.toml`, health-checks each endpoint, operates with whatever responds
5. If nothing responds, ARCAI falls back to file-based access: query ZIM files directly, read SQLite databases directly, run inference with local GGUF model

**This is the "always on, always running" architecture.** Not redundant servers or Kubernetes clusters. The data and the tools to access it are always co-located on the same physical medium, in formats that require nothing but a Linux kernel.

---

## Summary Table

| # | Principle | One-Line Rule |
|---|-----------|--------------|
| 1 | The `cp -r` Test | If you can't copy it to new hardware and have it work, it's too complex |
| 2 | SQLite Everything | Critical data in single-file databases, not client-server RDBMS |
| 3 | Static Binaries | Zero-dependency executables over containerized stacks for critical paths |
| 4 | Stupid Simple Mesh | HTTP health checks + endpoint list. No orchestration frameworks. |
| 5 | Graceful Degradation | Every tier from full rack to USB stick should work, just less capable |
| 6 | Eliminate Software SPOFs | Every P0 service must work without DNS, SSO, proxy, or container runtime |
| 7 | Human-Readable State | If a human with a text editor can't read it, it's not durable |
| 8 | Laminated Card Test | If the recovery procedure doesn't fit on one card, simplify it |
| 9 | Time-Tested Over Cutting-Edge | SQLite, HTTP, SSH, cron, rsync, ext4. Boring is reliable. |
| 10 | Reduce Service Count | Every service is a failure point. Consolidate where possible. |
| 11 | Offline-First Data | Files on disk, not responses from running services |

---

## Related Documents

- [ARC-ARCHITECTURE.md](ARC-ARCHITECTURE.md) — 4-layer system architecture
- [ARC-INTEGRATION-ANALYSIS.md](ARC-INTEGRATION-ANALYSIS.md) — 12 cross-service integration chains
- [ARC-SERVICE-REGISTRY.md](ARC-SERVICE-REGISTRY.md) — All 97 services with criticality tiers
- [ARC-DECISIONS.md](ARC-DECISIONS.md) — 7 blocking design decisions
