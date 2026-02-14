# ARC Seed Architecture

> ARC as genome — a single binary that discovers its environment and expresses capabilities accordingly

## Purpose

ARC is not a server deployment. It is a **genome** — a set of instructions that, when placed in an environment, expresses the capabilities that environment can support. The hardware is the organism. The ARC binary + data drive is the DNA.

This document defines the architectural vision for a single Rust binary that runs on any hardware from a 2018 Android phone to a full server rack, self-assesses available resources at startup, and activates only the capabilities the host can support. The same codebase, the same binary (per architecture), the same data formats — different expression.

---

## The Biological Model

| Biology | ARC Equivalent |
|---------|---------------|
| **DNA** | The Rust binary + data format specifications (SQLite schemas, ZIM format, TOML config spec) |
| **Seed** | Binary + minimal data (bootstrap corpus: medical ZIM, WHO drug list, emergency procedures) |
| **Soil** | Available hardware (CPU cores, RAM, storage capacity, GPU, radio interfaces) |
| **Water** | Power source (solar, generator, battery, wall outlet) |
| **Sunlight** | Network connectivity (mesh, WiFi, Ethernet, nothing) |
| **Expression** | Which capabilities activate based on discovered resources |
| **Phenotype** | The running system — looks different on every host but shares the same genome |
| **Mutation** | Community-specific adaptations — custom decision trees, local crop data, regional medical protocols |
| **Epigenetics** | Configuration (`arcai.toml`) — same genome, different expression based on environment signals |

The server rack with a GPU has "abnormally good vision" — it can do vision model inference that the Pi cannot. The Pi 5 with a LoRa hat has "exceptionally developed toes" — it can relay mesh messages that the server cannot because the server has no radio. Same organism, different specializations driven by environment.

---

## Cross-Compilation Targets

Rust with musl libc produces **fully static binaries** — no glibc, no shared libraries, no runtime dependencies. Just a Linux kernel (3.2+).

```
cargo build --target x86_64-unknown-linux-musl        # Any x86_64 Linux
cargo build --target aarch64-unknown-linux-musl        # Pi 5, modern ARM64
cargo build --target armv7-unknown-linux-musleabihf    # Pi 3, older ARM, 2015-era devices
cargo build --target aarch64-linux-android             # Android native (via NDK)
```

One codebase. Four binaries. Covers everything from a 2012 Chromebook to a 2026 server.

---

## Runtime Self-Assessment

The ARC binary does not need different builds for different hardware. It needs **one binary that discovers its environment at startup:**

```
On startup, ARCAI performs:

  1. How many CPU cores?           → Sets concurrency limits
  2. How much RAM?                 → Chooses model size (1.5B / 3B / 7B / 14B)
  3. Is there a GPU? What VRAM?   → GPU inference vs CPU-only
  4. What storage is mounted?      → Which ZIM files, SQLite DBs, models are available
  5. What network is available?    → WiFi (full), LoRa (text-only), none (local-only)
  6. What services respond?        → Health-check known endpoints, use what's alive
  7. Are there other ARC nodes?    → mDNS discovery, join mesh if found
```

Then it **expresses** accordingly. On a phone, it is a reference tool with chat. On a laptop, it is a full Searchhead with local inference. On a server, it is a 97-service orchestrator. Same DNA. Different organism.

### Resource-Driven Expression Table

| Resource Discovered | Capability Activated |
|--------------------|---------------------|
| ≥512 MB free RAM | TUI interface, SQLite query engine, ZIM reader |
| ≥2 GB free RAM | 1.5B Q4 model loaded for basic Q&A |
| ≥4 GB free RAM | 3B Q4 model, full Searchhead web UI served |
| ≥8 GB free RAM | 7B Q4 model, RAG pipeline with embeddings |
| ≥16 GB free RAM | 14B Q4 model, multi-domain specialist |
| GPU with ≥4 GB VRAM | GPU-accelerated inference (llama.cpp CUDA/ROCm) |
| GPU with ≥8 GB VRAM | 14-32B Q8 models, vision models, TTS |
| Network interface up | HTTP server for web UI, mDNS advertisement |
| Other ARC nodes found (mDNS) | Distributed inference routing, mesh coordination |
| Ollama endpoint responding | Delegate inference to external engine |
| OpenEMR endpoint responding | Live patient record queries (vs SQLite fallback) |
| Grocy endpoint responding | Live inventory queries (vs SQLite fallback) |
| Kiwix endpoint responding | Delegate ZIM search (vs built-in reader) |
| Frigate MQTT broker found | Subscribe to security events |
| Home Assistant responding | Subscribe to sensor events (power, water, temp) |
| LoRa radio detected | Mesh relay activated (Reticulum/LXMF) |
| Bluetooth available | Device pairing for Meshtastic nodes |
| GPIO available (Pi) | Sensor reading, relay control |

---

## Hardware Expression Profiles

### Android Phone (2018) — Snapdragon 845, 4 GB RAM, 64 GB + SD

**Expressed phenotype:** Field reference terminal + mesh relay

| Capability | Status | Notes |
|-----------|--------|-------|
| ZIM reference lookup | Active | Medical Wikipedia, WHO drug list |
| Patient records (SQLite) | Active | Read-only from exported `patients.db` |
| Drug interaction check | Active | SQLite query against medication database |
| LLM Q&A | Active | 1.5B Q4 at ~8-12 tok/s on Snapdragon 845 |
| Web UI | Active | `localhost:8080` in phone browser |
| Mesh relay | Active | Bluetooth to Meshtastic, WiFi hotspot for local nodes |
| Task creation | Active | Write to local `tasks.db`, sync when connected |
| Live service queries | Inactive | No services running on phone |
| GPU inference | Inactive | No GPU API available in Termux |
| Event listeners | Inactive | No MQTT broker, no Home Assistant |

**Deployment options:**

- **Termux (no root):** Install from F-Droid mirror. Copy `arcai` binary + data to phone storage. Run `./arcai --config arcai.toml`. Access web UI in browser.
- **Native Android app (NDK):** Same Rust code compiled with Android NDK. Minimal Java/Kotlin shell for lifecycle management, notifications, Bluetooth API, background service.

**Use case:** A medic in the field with a 2018 phone pulled from a drawer can look up patient allergies, check drug interactions, search medical articles, run a 1.5B model for triage Q&A, and relay mesh messages. No app store. No internet. No server.

### Laptop (2015) — Core i5-5200U, 8 GB RAM, 256 GB SSD

**Expressed phenotype:** Full Searchhead with local inference

| Capability | Status | Notes |
|-----------|--------|-------|
| ZIM reference lookup | Active | Full corpus if storage allows |
| Patient records (SQLite) | Active | Read/write, full encounter logging |
| Drug interaction check | Active | Full WHO database |
| LLM Q&A | Active | 3-7B Q4 at ~10-15 tok/s on Broadwell i5 |
| Web UI | Active | Full Searchhead interface |
| Mesh hub | Active | WiFi AP mode for local mesh |
| Task management | Active | Full Vikunja-equivalent from `tasks.db` |
| Live service queries | Conditional | If other nodes on network, delegates |
| GPU inference | Inactive | Intel HD 5500 not useful for LLM |
| Event listeners | Conditional | If Frigate/HA on network |

**Use case:** Clinic workstation. Doctor runs full patient workflow, searches references, gets AI-assisted differential diagnosis, logs encounters, assigns follow-up tasks. All local, all offline.

### Raspberry Pi 5 — Cortex-A76, 8 GB RAM, 256 GB SD + USB

**Expressed phenotype:** Identical to laptop but ARM64 + GPIO + LoRa

| Capability | Status | Notes |
|-----------|--------|-------|
| All laptop capabilities | Active | Same binary, different target triple |
| GPIO sensor reading | Active | Temperature, humidity, water level |
| LoRa mesh gateway | Active | Via LoRa hat or USB RNode |
| Low power operation | Active | 5-15W, runs on small solar panel |

**Use case:** Permanent installation at a remote outpost. Solar-powered, LoRa-connected, provides reference + mesh relay + sensor monitoring. Runs unattended for months.

### Toughbook CF-31 — Core i5-2520M, 8 GB RAM, 500 GB HDD

**Expressed phenotype:** Ruggedized field station

| Capability | Status | Notes |
|-----------|--------|-------|
| All laptop capabilities | Active | Same x86_64 binary |
| Rugged operation | Active | MIL-STD-810G, rain/dust/drop resistant |
| Larger storage | Active | 500 GB HDD fits more ZIM files, full ebook library |
| Field medical station | Active | OpenEMR-equivalent via SQLite, full reference corpus |

**Use case:** Deployed with a patrol or field medical team. Withstands physical abuse. Same capabilities as a clinic workstation but in a case you can drop down a hill.

### workstation + consumer GPU (8GB VRAM) — Core i9, 64 GB RAM, 2 TB NVMe

**Expressed phenotype:** Full capability core node

| Capability | Status | Notes |
|-----------|--------|-------|
| All previous capabilities | Active | Plus GPU |
| GPU inference | Active | 14-32B Q8 models at 30-84 tok/s |
| Vision models | Active | Image analysis, document OCR assist |
| TTS | Active | Qwen3-TTS voice output |
| Model training | Active | QLoRA fine-tuning for community-specific knowledge |
| Inference server for mesh | Active | Other nodes route complex queries here |

**Use case:** The brain of the community. Handles the hard questions. Trains models on local data. Generates voice announcements. Other ARC nodes discover it via mDNS and delegate their GPU-class work.

### Server Rack (Server-1 + Server-2) — Dual Xeon, 192 GB combined

**Expressed phenotype:** Maximum expression — full service orchestration

| Capability | Status | Notes |
|-----------|--------|-------|
| All previous capabilities | Active | Plus distributed services |
| Container orchestration | Active | 97 services via Podman Quadlet |
| Full monitoring stack | Active | Prometheus, Grafana, Loki |
| SSO / Identity | Active | Authentik, Active Directory |
| Full database services | Active | MySQL, PostgreSQL for rich applications |
| Cross-service integration | Active | All 12 integration chains (ARC-INTEGRATION-ANALYSIS.md) |
| Multi-user concurrent | Active | 150 users simultaneously |

**Use case:** The mighty oak. Full ARC-001 as it exists today. The ARCAI binary acts as orchestrator, delegating to specialized services rather than doing everything itself. It still reads SQLite and ZIM files directly — but it *prefers* to use the richer service APIs when they're available.

---

## The Binary Internals

### Rust Crate Architecture

The binary is a single Rust workspace with feature flags that control compilation:

| Crate / Module | Rust Dependencies | What It Provides |
|---------------|-------------------|-----------------|
| `arcai-core` | `rusqlite`, `toml`, `tracing` | Config loading, SQLite engine, logging, self-assessment |
| `arcai-zim` | `zim` (or custom parser) | Direct ZIM file reading without kiwix-serve |
| `arcai-llm` | `llama-cpp-rs` (FFI) | Local model inference when no Ollama endpoint exists |
| `arcai-web` | `axum`, `rust-embed`, `tower` | HTTP server, embedded web UI assets, API endpoints |
| `arcai-tui` | `ratatui`, `crossterm` | Terminal interface for headless/minimal environments |
| `arcai-http` | `reqwest` | HTTP client for all service API connectors |
| `arcai-mqtt` | `rumqttc` | MQTT subscriber for Frigate, Home Assistant events |
| `arcai-caldav` | `reqwest`, `quick-xml` | CalDAV client for Nextcloud calendar integration |
| `arcai-mdns` | `mdns-sd` | Service discovery and ARC node mesh formation |
| `arcai-mesh` | Reticulum FFI or port | LoRa/mesh transport for LXMF messaging |
| `arcai-classify` | `candle` or regex engine | Query domain classification (v0: regex, v1: small model) |
| `arcai-decision` | Custom logic | Safety-critical decision trees (medical, weapons, legal) |
| `arcai-schedule` | `tokio-cron-scheduler` | Periodic analysis tasks (outbreak detection, inventory alerts) |

### Feature Flags

```toml
[features]
default = ["core", "zim", "web", "tui", "sqlite"]
core = []                    # Always included: config, self-assessment, logging
zim = []                     # ZIM file reader
web = ["axum", "rust-embed"] # HTTP server + embedded web UI
tui = ["ratatui"]            # Terminal UI
sqlite = ["rusqlite"]        # SQLite read/write
llm = ["llama-cpp-rs"]       # Local LLM inference (adds ~10 MB to binary)
mqtt = ["rumqttc"]           # MQTT event listener
mesh = []                    # Reticulum mesh transport
gpu = ["llama-cpp-rs/cuda"]  # GPU inference (requires CUDA at build time)
android = []                 # Android-specific lifecycle management
```

**Minimal build** (reference terminal): `core + zim + tui + sqlite` → ~5 MB binary
**Standard build** (full capability): `default + llm + mqtt` → ~20 MB binary
**Full build** (GPU + mesh): all features → ~25 MB binary

### Estimated Binary Sizes

| Target | Features | Size | Fits On |
|--------|----------|------|---------|
| `aarch64-unknown-linux-musl` (minimal) | core + zim + tui + sqlite | ~5 MB | Any SD card, any phone |
| `x86_64-unknown-linux-musl` (standard) | default + llm + mqtt | ~20 MB | Any storage medium |
| `x86_64-unknown-linux-gnu` (full + GPU) | all features | ~25 MB | Any disk |

For comparison: a single Docker image for a Node.js web app is typically 200-500 MB. The entire ARCAI binary with embedded web UI, ZIM reader, LLM engine, and MQTT client is smaller than a typical JPEG photograph from a modern phone camera.

---

## Data Architecture: What Travels With the Seed

### Minimum Viable Seed (~2 GB)

The absolute minimum to be useful. Fits on a USB stick from 2010.

| Component | Size | Content |
|-----------|------|---------|
| `arcai` binary (4 architectures) | ~80 MB | x86_64, aarch64, armv7, android-aarch64 |
| Bootstrap model (1.5B Q4 GGUF) | ~900 MB | Basic Q&A, triage, lookup |
| Medical ZIM (Wikipedia Medicine) | ~700 MB | Emergency medical reference |
| WHO Essential Medicines DB | ~5 MB | Drug interactions, dosages (SQLite) |
| Emergency procedures (Markdown) | ~2 MB | Laminated card content, trauma protocols |
| `arcai.toml` + `roles.toml` | ~10 KB | Default configuration |
| `bootstrap.sh` | ~5 KB | Architecture detection, first-run setup |

### Standard Seed (~50 GB)

Fits on a 64 GB USB drive or SD card. Covers most daily operations.

| Component | Size | Content |
|-----------|------|---------|
| Everything in Minimum Viable | ~2 GB | Core genome + bootstrap data |
| Full Wikipedia (English) | ~22 GB | ZIM: Complete reference |
| Medical ebooks (curated) | ~5 GB | Trauma, infectious disease, pediatrics, surgery |
| 7B Q4 model | ~4 GB | Full-capability inference for 8+ GB RAM hosts |
| Patient records template DB | ~1 MB | Empty OpenEMR-schema SQLite, ready for data entry |
| Inventory template DB | ~1 MB | Empty Grocy-schema SQLite |
| Survival/engineering library | ~10 GB | Curated ebooks: water, shelter, agriculture, repair |
| Embedding model (nomic-embed) | ~300 MB | RAG embeddings for knowledge search |
| F-Droid APK selection | ~2 GB | Essential Android apps (GPS, compass, radio, medical) |

### Full ARC Drive (~2 TB)

The complete knowledge corpus. Requires external drive or large internal storage.

| Component | Size | Content |
|-----------|------|---------|
| Everything in Standard Seed | ~50 GB | Core + standard |
| Full ZIM collection (77 files) | ~318 GB | StackExchange, WikiHow, medical, language |
| Atlas satellite tiles (z0-z13) | ~540 GB | Global offline mapping |
| 3D print archive | ~432 GB | 193k+ printable models |
| Ebook library (full Calibre) | ~50 GB | Complete curated collection |
| Video archive (instructional) | ~200 GB | How-to, training, educational |
| Legal corpus (Corpus Juris) | ~35 GB | US law, governance, case law |
| 14B+ models (multiple) | ~40 GB | Specialist models for different domains |
| Remaining ZIMs + content | ~200 GB | Full preservation corpus |

---

## Service Delegation Model

The binary always has built-in capability. When richer services exist on the network, it **delegates** rather than duplicates:

| Capability | Built-In (Always Works) | Delegated (When Available) |
|-----------|------------------------|---------------------------|
| Patient lookup | `SELECT * FROM patients.db` | OpenEMR REST API `/apis/default/fhir/Patient` |
| Drug reference | SQLite query on WHO meds DB | OpenEMR pharmacy module |
| Knowledge search | Built-in ZIM reader + FTS5 | Kiwix search API + Manticore full-text |
| Food inventory | SQLite query on `inventory.db` | Grocy REST API `/api/stock` |
| Task management | SQLite read/write on `tasks.db` | Vikunja REST API `/api/v1/tasks` |
| Calendar | SQLite table of events | Nextcloud CalDAV |
| LLM inference | llama.cpp built-in | Ollama HTTP API at any discovered endpoint |
| Notifications | Log to file / TUI alert | ntfy HTTP POST / FreePBX AMI |
| Maps | Tile files read from disk | Atlas/Martin tile server API |
| Monitoring | `systemctl is-active` + process checks | Prometheus PromQL + Grafana API |

**The delegation is automatic.** On startup, ARCAI health-checks all known endpoints. If Grocy responds, inventory queries go to Grocy (richer data, web UI, multi-user). If Grocy doesn't respond, inventory queries go to the local SQLite file (read-only snapshot, but always available).

This is the core of the "always on, always running" guarantee. The binary never says "service unavailable." It says "I'll use what I have."

### Sync Protocol

When a field device (phone, Toughbook) returns to a network with running services, it needs to sync local changes back:

1. **Tasks created offline** → Push to Vikunja via API
2. **Patient encounters logged offline** → Push to OpenEMR via API
3. **Inventory changes noted offline** → Push to Grocy via API
4. **SQLite databases updated** → Pull fresh exports from services

This is a **last-write-wins with conflict log** model. If the same patient record was modified both on the phone and in OpenEMR while disconnected, both versions are preserved and a human resolves the conflict. The system never silently discards data.

---

## Mesh Compute Architecture

### Node Discovery

When multiple ARC nodes exist on a network, they find each other via mDNS:

```
Node A (Pi 5, 8 GB RAM, no GPU):
  Advertises: _arcai._tcp.local
  Capabilities: {ram: 8192, gpu: false, models: ["1.5b-q4"], storage: 256}

Node B (Laptop, 16 GB RAM, no GPU):
  Advertises: _arcai._tcp.local
  Capabilities: {ram: 16384, gpu: false, models: ["7b-q4"], storage: 512}

Node C (workstation, 64 GB RAM, RTX 2080):
  Advertises: _arcai._tcp.local
  Capabilities: {ram: 65536, gpu: true, gpu_vram: 8192, models: ["14b-q8", "7b-q4"], storage: 2048}
```

### Inference Routing

When Node A receives a query it can't handle well (needs a larger model), it routes to a more capable node:

```
Query: "Differential diagnosis for joint swelling, fatigue, fever in 12-year-old"
  │
  ├── Node A classifier: domain=medical, complexity=high
  ├── Node A self-assessment: 1.5B model insufficient for medical reasoning
  ├── Node A checks mesh: Node C has 14B-q8 model + GPU
  └── Node A routes to Node C → response returned → displayed on Node A
```

**No central coordinator.** Each node makes its own routing decisions based on the mesh capability advertisements. If Node C goes offline, Node A falls back to its local 1.5B model with a quality warning: "Running on limited model. Verify recommendations with medical references."

### Data Replication

Critical databases should exist on every node. When a node joins the mesh:

1. Compares `last_modified` timestamps on SQLite databases
2. Pulls newer versions of `patients.db`, `inventory.db`, `tasks.db`
3. Uses rsync-over-SSH or HTTP range requests (resume-capable)
4. Knowledge corpus (ZIM files) synced opportunistically (large files, low priority)

---

## Inside-Out Development Strategy

ARC is not built top-down (design perfect system, then implement). It is built **inside-out** — each layer is useful alone, and each subsequent layer is additive:

### Layer 1: Core Genome (MVP — weeks)

```
arcai-core + arcai-zim + arcai-tui + arcai-sqlite
```

- Reads TOML config
- Opens SQLite databases, provides query interface
- Reads ZIM files, provides search
- TUI for headless operation
- Runs on everything including a Pi Zero

**Already useful:** A medic can look up drug interactions and search Wikipedia from a terminal.

### Layer 2: Web Interface (+ days)

```
+ arcai-web (axum + rust-embed)
```

- HTTP server with embedded HTML/JS/CSS
- Searchhead web UI in a browser
- API endpoints for programmatic access
- Same data, better presentation

**Already useful:** Multiple users can access ARC from any device with a browser.

### Layer 3: Local Intelligence (+ days)

```
+ arcai-llm (llama-cpp-rs)
```

- Loads GGUF model based on available RAM
- Natural language Q&A over corpus
- Query classification (medical, security, food, etc.)
- RAG: retrieves ZIM/ebook context before generating

**Already useful:** Users ask questions in English, get synthesized answers with sources.

### Layer 4: Service Integration (+ week)

```
+ arcai-http (reqwest service connectors)
```

- Health-checks known service endpoints
- Delegates to richer services when available
- Falls back to local SQLite when not
- ACT dispatcher: creates tasks, sends notifications

**Already useful:** When connected to a full ARC installation, orchestrates across all services.

### Layer 5: Event-Driven (+ week)

```
+ arcai-mqtt + arcai-schedule
```

- MQTT subscriber for Frigate, Home Assistant
- Scheduled analysis (outbreak detection, inventory alerts)
- Proactive alerting without human queries

**Already useful:** ARC warns about problems before humans notice them.

### Layer 6: Mesh (+ weeks)

```
+ arcai-mesh + arcai-mdns
```

- mDNS discovery of other ARC nodes
- Distributed inference routing
- Data replication between nodes
- LoRa/Reticulum transport for off-grid

**Already useful:** Multiple ARC installations collaborate, share compute, and communicate.

---

## Comparison: Current vs Seed Architecture

| Dimension | Current (97 Services) | Seed (Single Binary) |
|-----------|----------------------|---------------------|
| Deployment | Hours of container setup | Copy binary + data, run |
| Dependencies | Podman, container images, PostgreSQL, MySQL, Redis, PHP, Python, Node.js, Java | Linux kernel |
| Migration | Reconfigure every service | `cp -r /arc /new-disk` |
| Failure modes | 97 independent failure points | 1 binary + data files |
| Minimum hardware | Server rack (>16 GB RAM) | Phone (2 GB RAM) |
| Binary size | ~50 GB container images | ~20 MB binary |
| Startup time | Minutes (container orchestration) | Seconds (single process) |
| Monitoring | 7-service stack | Built-in health checks |
| Authentication | Authentik + AD + LDAP | TOML file with bcrypt hashes |
| Service discovery | DNS + reverse proxy | mDNS (zero-config) |
| Network requirement | VLANs, managed switch, firewall | Any network, or none |
| Power requirement | ~500W (full rack) | ~5W (Pi), ~15W (laptop) |

**The current architecture is not wrong.** It is the full expression — the mighty oak with deep roots and broad canopy. The seed architecture is the acorn that contains the same genetic information in a package small enough to carry in a pocket.

Both must exist. The 97-service deployment is what you run when you have a server rack and 500 watts. The seed is what you plant when all you have is a laptop and a USB drive.

---

## Open Questions

1. **Reticulum Rust port vs FFI?** Pure Rust port of Reticulum is significant effort but eliminates Python dependency. FFI wrapping the existing Python implementation is faster but reintroduces a runtime dependency. Decision needed.
2. **Android distribution method?** Termux-based (simpler, no signing) vs native APK (better UX, requires Android SDK toolchain). Could ship both.
3. **Embedded web UI framework?** Static HTML + vanilla JS (simplest, most portable) vs lightweight framework (Svelte, Preact — better UX, build step required). Recommendation: vanilla JS for v0.
4. **ZIM reader implementation?** Existing `zim` Rust crate vs custom parser. Existing crate is unmaintained but functional. Custom parser is more work but no external dependency.
5. **Model selection at runtime.** How does the binary decide which GGUF model to load? Largest that fits in 50% of available RAM? User-configurable? Both?
6. **Offline-first sync conflicts.** Last-write-wins is simple but can lose data. CRDTs are robust but complex. What conflict resolution model is appropriate for patient records? (Safety-critical — must not silently discard.)
7. **Decision tree format.** Hardcoded Rust structs? External DSL? TOML? Decision trees must be auditable by medical personnel, not just programmers.
8. **Licensing.** If ARC is open-sourced, what license? GPLv3 (copyleft, derivatives must share)? Apache 2.0 (permissive)? AGPL (network use triggers sharing)?

---

## Related Documents

- [ARC-ARCHITECTURE.md](ARC-ARCHITECTURE.md) — 4-layer system architecture, 7-step interaction pattern
- [ARC-RELIABILITY-PRINCIPLES.md](ARC-RELIABILITY-PRINCIPLES.md) — 11 architectural principles for decade-scale operation
- [ARC-INTEGRATION-ANALYSIS.md](ARC-INTEGRATION-ANALYSIS.md) — 12 cross-service integration chains
- [ARC-SERVICE-REGISTRY.md](ARC-SERVICE-REGISTRY.md) — All 97 services with ARC purpose and criticality
- [ARC-BUILD-SPEC.md](ARC-BUILD-SPEC.md) — Hardware tier profiles and provisioning
- [ARC-DECISIONS.md](ARC-DECISIONS.md) — 7 blocking design decisions
