# ARC Container & VM Gap Analysis

> Complete inventory of additional services needed to fulfill ARC use cases, with node placement, image governance, and deployment readiness

## Current State (2026-02-11)

| Host | RAM Total | RAM Used | RAM Avail | Disk Total | Disk Used | Disk Avail | Containers |
|------|-----------|----------|-----------|------------|-----------|------------|------------|
| Server-2 | 314 GB | 37 GB (12%) | 276 GB | 2.5 TB | 392 GB (16%) | 2.1 TB | 95 |
| Server-1 | 188 GB | 92 GB (49%) | 96 GB | 3.3 TB | 1.7 TB (51%) | 1.6 TB | 17 |
| workstation | 64 GB | ~20 GB | ~44 GB | 2 TB | ~800 GB | ~1.2 TB | 0 (Docker) |

**Zot Registry:** 97 repos cached at `zot-registry.lab.example.com:5000` (pull-through + local store).

---

## Tier A — Fills P0/P1 Gaps (Core ARC Capabilities)

These services close the most critical gaps: AI inference, RAG pipeline, perimeter security, mesh communications, and environmental monitoring.

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| A1 | Ollama | `ollama/ollama` | **Yes** | workstation (GPU) | 4-16 GB (model dependent) | 20 GB (models) | US-22, ARCAI, all role stories |
| A2 | Open WebUI | `open-webui/open-webui` | **Yes** | Server-2 | 512 MB | 2 GB | US-22, Searchhead chat (D-1) |
| A3 | ChromaDB | `chromadb/chroma` | No | Server-1 | 2-4 GB | 50 GB (embeddings) | D-5, Corpus Juris, RAG pipeline |
| A4 | Frigate NVR | `ghcr.io/blakeblackshear/frigate` | **Yes** | Server-2 | 2-4 GB | 500 GB (retention) | US-04, Story 9 |
| A5 | Mosquitto MQTT | `eclipse-mosquitto` | **Yes** | Server-2 | 64 MB | 100 MB | US-07/10, IoT sensor hub |
| A6 | rtl_433 | `hertzg/rtl_433` | No | Server-2 | 64 MB | 50 MB | US-07, weather/sensor decode |
| A7 | RSSHub | `diygod/rsshub` | No | Server-2 | 256 MB | 500 MB | Searchhead news feed |
| A8 | Meshtastic MQTT Bridge | Custom Python | N/A | Server-2 | 128 MB | 100 MB | US-05/12, mesh→server alerts |
| A9 | Reticulum Hub | Custom Python | N/A | Server-2 | 128 MB | 200 MB | US-05/12/44, mesh networking |

**Tier A Total Estimate:** ~7-25 GB RAM, ~573 GB disk (mostly Frigate retention + ChromaDB embeddings)

### Placement Rationale — Tier A

- **Ollama on workstation:** Requires GPU (consumer GPU (8GB VRAM)). Cannot run GPU inference on Server-1/Server-2 (no GPU). CPU fallback mode on nodes is a future secondary deployment.
- **Open WebUI on Server-2:** Web frontend, pairs with Authentik SSO already on Server-2. Queries Ollama on workstation via network API.
- **ChromaDB on Server-1:** Co-locates with Kiwix, Calibre-Web, Manyfold — the corpus sources it indexes. Avoids adding to Server-2's 95-container load. **NFS risk:** If embedding generation runs on workstation and writes to ChromaDB on Server-1, this crosses a network boundary.
- **Frigate NVR on Server-2:** Already has services.yaml entry. Needs local disk for retention. Camera feeds arrive via VLAN 100 (IoT) routed through FIREWALL.
- **Mosquitto on Server-2:** Lightweight, central broker for all IoT/sensor data → Home Assistant (also on Server-2).
- **rtl_433 on Server-2:** Requires USB SDR passthrough. If SDR hardware is on workstation, this moves to workstation instead.
- **RSSHub on Server-2:** Web service, pairs with FreshRSS (also Server-2).
- **Mesh services on Server-2:** LoRa hardware (Heltec V3) connects via USB serial to whichever host has physical access. If hardware is on workstation, these move to workstation.

---

## Tier B — Fills Functional Gaps in Role Stories

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| B1 | Faster-Whisper | `fedirz/faster-whisper-server` | No | workstation (GPU) | 2-4 GB | 3 GB (models) | Story 8/14, radio transcription |
| B2 | Octoprint | `octoprint/octoprint` | No | Server-1 | 256 MB | 1 GB | US-29, Story 3, print mgmt |
| B3 | Docuseal | `docuseal/docuseal` | No | Server-2 | 512 MB | 2 GB | Story 10, consent/governance |
| B4 | Homepage | `ghcr.io/gethomepage/homepage` | No | Server-2 | 128 MB | 100 MB | D-1, role dashboards |
| B5 | Label Studio | `heartexlabs/label-studio` | No | workstation | 512 MB | 5 GB | US-48, AI training data |
| B6 | Immich | `ghcr.io/immich-app/immich-server` | No | Server-1 | 1 GB | 50 GB | Field documentation, evidence |
| B7 | BookStack | `linuxserver/bookstack` | No | Server-2 | 256 MB | 2 GB | US-41/45, SOPs, governance |
| B8 | Upsnap (WoL) | `ghcr.io/seriousm4x/upsnap` | No | Server-2 | 64 MB | 50 MB | Power management |

**Tier B Total Estimate:** ~5-7 GB RAM, ~63 GB disk

---

## Tier C — Civilization Rebuild (P3)

| # | Service | Image/VM | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|----------|---------|-------------|----------|-----------|-------|
| C1 | Decidim | `decidim/decidim` | No | Server-2 | 1 GB | 5 GB | US-47, community voting |
| C2 | Samba4 AD DC | VM (Alma/Fedora) | N/A | Server-1 VM | 4 GB | 20 GB | A-7, AD license fallback |
| C3 | GnuHealth | VM or container | No | Server-2 | 2 GB | 10 GB | A-8, simplified triage |
| C4 | ERPNext | `frappe/erpnext` | No | Server-2 | 2 GB | 10 GB | US-50, unified trade/inventory |

**Tier C Total Estimate:** ~9 GB RAM, ~45 GB disk

---

## Tier D — Intelligence, Comms & Security Enhancements

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| D1 | Tesseract Server | `ricardorey/tesseract-server` | No | Server-2 | 256 MB | 500 MB | Story 11, batch OCR |
| D2 | CrowdSec | `crowdsecurity/crowdsec` | No | Server-2 | 256 MB | 1 GB | US-16, collaborative IDS |
| D3 | Draw.io (Excalidraw) | `excalidraw/excalidraw` | No | Server-2 | 128 MB | 100 MB | Defensive planning, maps |
| D4 | SearXNG | `searxng/searxng` | No | Server-2 | 256 MB | 500 MB | Pre-collapse meta-search |

**Tier D Total Estimate:** ~1 GB RAM, ~2 GB disk

---

## Tier E — Cybersecurity, IT Operations & ARCclient

Pure technology functions supporting the IT/Systems Administrator and Security roles.

### E1: Security Operations

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Purpose |
|---|---------|-------|---------|-------------|----------|-----------|---------|
| E1a | Trivy | `aquasec/trivy` | No | Server-2 | 512 MB | 5 GB (vuln DB) | Container image scanning, SBOM generation |
| E1b | ClamAV | `clamav/clamav` | No | Server-2 | 1 GB | 1 GB (signatures) | Malware scanning API for Paperless-ngx, file uploads |
| E1c | Wazuh Manager | `wazuh/wazuh-manager` | No | Server-2 | 2-4 GB | 20 GB (events) | SIEM + endpoint detection (agents on all hosts) |
| E1d | Wazuh Dashboard | `wazuh/wazuh-dashboard` | No | Server-2 | 1 GB | 2 GB | Wazuh web UI |
| E1e | Wazuh Indexer | `wazuh/wazuh-indexer` | No | Server-2 | 2 GB | 20 GB (indices) | OpenSearch-based event storage |
| E1f | Greenbone OpenVAS | `greenbone/vulnerability-tests` | No | Server-2 | 4 GB | 10 GB (NVT DB) | Vulnerability scanning for all lab hosts |
| E1g | Velociraptor | `velocidex/velociraptor` | No | Server-2 | 1 GB | 10 GB (artifacts) | Endpoint forensics, live response |
| E1h | YARA Scanner | `blacktop/yara` | No | Server-2 | 256 MB | 500 MB | Rule-based malware/IOC detection |

### E2: IT Operations

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Purpose |
|---|---------|-------|---------|-------------|----------|-----------|---------|
| E2a | Netbox | `netboxcommunity/netbox` | No | Server-2 | 1 GB | 5 GB | DCIM/IPAM — network documentation, IP management |
| E2b | Snipe-IT | `snipe/snipe-it` | No | Server-2 | 512 MB | 2 GB | IT asset management (complements Homebox) |
| E2c | Semaphore | `semaphoreui/semaphore` | No | Server-2 | 256 MB | 500 MB | Ansible automation UI — playbook management |
| E2d | Guacamole | `guacamole/guacamole` + `guacamole/guacd` | No | Server-2 | 512 MB | 1 GB | Remote desktop/SSH gateway — HTML5 |
| E2e | Portainer CE | `portainer/portainer-ce` | No | Server-2 | 256 MB | 500 MB | Container management UI (read-only for monitoring) |
| E2f | Rundeck | `rundeck/rundeck` | No | Server-2 | 1 GB | 2 GB | Job scheduling, runbook automation |

### E3: ARCclient-Capable Containers

Containers light enough to run on a Toughbook (8-16 GB RAM), Raspberry Pi, or similar field device with container runtime. These are **copied to** or **synced with** ARCclient devices for disconnected field use.

| # | Service | Image | Size | RAM | Purpose | Field Use Case |
|---|---------|-------|------|-----|---------|----------------|
| E3a | Ollama (CPU) | `ollama/ollama` | ~1 GB + model | 2-8 GB | LLM inference (CPU-only, 1.5-7B models) | Field Q&A, triage, reference |
| E3b | Kiwix Serve | `kiwix/kiwix-serve` | ~200 MB + ZIMs | 256 MB | Offline reference library | Wikipedia, medical, survival |
| E3c | CyberChef | `gchq/cyberchef` | ~50 MB | 64 MB | Data analysis toolkit | Signal analysis, decoding |
| E3d | Stirling-PDF | `frooodle/s-pdf` | ~500 MB | 512 MB | PDF toolkit + OCR | Document processing in field |
| E3e | IT-Tools | `corentinth/it-tools` | ~50 MB | 64 MB | Developer utilities | Network tools, encoding |
| E3f | Atlas (MapLibre) | `maptiler/tileserver-gl` | ~200 MB + tiles | 512 MB | Offline mapping | Navigation, patrol planning |
| E3g | LibreTranslate | `libretranslate/libretranslate` | ~500 MB + models | 1 GB | Translation | Foreign document translation |
| E3h | Calibre-Web | `linuxserver/calibre-web` | ~200 MB + library | 256 MB | Ebook reader | Reference manuals in field |
| E3i | Meshtastic (daemon) | `meshtastic/meshtasticd` | ~100 MB | 64 MB | Mesh radio management | LoRa mesh comms |
| E3j | Prometheus+Grafana (mini) | `prom/prometheus` + `grafana/grafana` | ~400 MB | 512 MB | Local system monitoring | ARCclient health monitoring |

**ARCclient distribution method:** Zot OCI registry → `podman pull` over WiFi/LAN, or `podman save` → USB drive sneakernet.

**Tier E Total Estimate:** Security ops ~12 GB RAM, 70 GB disk. IT ops ~3.5 GB RAM, 11 GB disk. ARCclient images ~3 GB download + data.

---

## Node Placement Plan — SPOF Prevention

### Principle: All Elements on Same Node

Each service and its dependencies (database, cache, search index) must reside on the same node. No container should depend on a cross-node network call for core function.

### Current Placement + New Services

| Node | Current Load | New Services (Tier A-E) | Post-Deploy Est. |
|------|-------------|------------------------|-----------------|
| **Server-2** | 95 containers, 37 GB RAM used | A2, A4-A9, B3-B4/B7-B8, C1/C3-C4, D1-D4, E1a-E1h, E2a-E2f | ~130 containers, ~80 GB RAM |
| **Server-1** | 17 containers, 92 GB RAM used | A3, B2/B6, C2 (VM) | ~20 containers + 1 VM, ~100 GB RAM |
| **workstation** | 0 containers (Docker host) | A1, B1/B5 | ~3 containers, ~30 GB RAM |

### Critical SPOF: Server-2

Server-2 hosts **95 of 97 services** and would host the majority of new services. Server-2 failure is a catastrophic event.

**Mitigations (documented, not implemented):**
1. **Service migration candidates to Server-1:** Move knowledge/reference services currently on Server-2 to Server-1 where they'd co-locate with Kiwix/Atlas:
   - Calibre-Web (already on Server-1)
   - Manticore Search → Server-1 (co-locates with corpus sources)
   - Paperless-ngx → Server-1 (document storage)
   - ArchiveBox → Server-1 (web archive)
   - Wiki.js → Server-1 (governance records)

2. **Stateless service replication:** Some services could run on both nodes with DNS failover:
   - CyberChef, IT-Tools, Stirling-PDF (stateless tools)
   - Kiwix (read-only, can run duplicate instance)

3. **Database backup:** All PostgreSQL/MariaDB/SQLite databases on Server-2 should have automated backup to Server-1 (or external-storage).

### NFS Cross-Sharing — Documented Risks

| Current NFS Mount | Source | Destination | Risk |
|-------------------|--------|-------------|------|
| Video archival staging | workstation | Server-1 | Server-1 services dependent on workstation uptime for video processing |
| Digital library staging | workstation | Server-1 | Same — workstation power-off breaks Server-1 library updates |

| Proposed NFS Mount | Source | Destination | Risk |
|--------------------|--------|-------------|------|
| ChromaDB embeddings | Server-1 | workstation (for generation) | Embedding generation requires network path; workstation reboot interrupts indexing |
| Ollama models | workstation | Server-2 (Open WebUI) | If workstation is off, Open WebUI has no backend — **single dependency** |
| Frigate recordings | Server-2 | external-storage (archival) | USB drive disconnect loses recording archive |

**Policy:** NFS cross-sharing is acceptable for **staging/batch operations** (can tolerate outage, resume later). It is NOT acceptable for **real-time service dependencies** (breaks when remote host is down).

**For true HA:** Each node must be independently functional for its assigned services. Cross-node dependencies should be async (rsync/backup) not sync (NFS mount required for service startup).

---

## Container Image Governance

### Current State: No Pinning

Most Quadlet files on Server-1/Server-2 reference `:latest` tags. This creates three risks:

| Risk | Description | Severity |
|------|-------------|----------|
| **Silent drift** | `podman pull` gets a different image than tested. Behavior changes without awareness. | High |
| **Reproducibility** | Cannot rebuild a known-good state. "It worked yesterday" is undebuggable. | High |
| **Supply chain** | A compromised `:latest` push replaces a trusted image silently. | Critical |
| **Air-gap break** | Post-collapse, no pulls possible. `:latest` resolution fails if Zot doesn't have exact manifest cached. | Critical |

### Recommended Policy

1. **Pin all production images to digest** (`image@sha256:abc123...`). Store the pinned digest in the Quadlet file.
2. **Tag with version** (`image:1.2.3`) as human-readable secondary. Never `:latest` in production Quadlets.
3. **Update workflow:**
   - Pull new version to Zot (pre-collapse, while internet available)
   - Scan with Trivy (see below)
   - Test on workstation (Docker, non-production)
   - Update Quadlet digest on Server-1/Server-2
   - Restart service
4. **Zot local copies:** All 97+ production images must exist in Zot's local store (not just pull-through cache). Pull-through cache entries expire; local store is permanent.
5. **Offline manifest:** Maintain a `pinned-images.yaml` listing every service → image → digest → last-scanned date.

### Should We Preseed Zot Now?

**Yes — strongly recommended.** While internet is available, pull all gap images into Zot's local store. Reasons:

1. **Air-gap readiness:** Post-collapse, no new pulls possible. Every image must already be cached.
2. **Cost of delay:** Images may be removed from upstream registries (Docker Hub rate limits, project abandonment, DMCA).
3. **Registry storage is cheap:** ~50 GB for all gap images on Server-2's 2.1 TB free disk.
4. **Scan before trust:** Images pulled now can be scanned with Trivy before any deployment.

**Images to preseed (not yet in Zot):**

```
# Tier A
chromadb/chroma
diygod/rsshub
hertzg/rtl_433

# Tier B
fedirz/faster-whisper-server
octoprint/octoprint
docuseal/docuseal
ghcr.io/gethomepage/homepage
heartexlabs/label-studio
ghcr.io/immich-app/immich-server
linuxserver/bookstack
ghcr.io/seriousm4x/upsnap

# Tier C
decidim/decidim
frappe/erpnext
quay.io/keycloak/keycloak

# Tier D
ricardorey/tesseract-server
crowdsecurity/crowdsec
excalidraw/excalidraw
searxng/searxng

# Tier E — Security
aquasec/trivy
clamav/clamav
wazuh/wazuh-manager
wazuh/wazuh-dashboard
wazuh/wazuh-indexer
greenbone/vulnerability-tests
greenbone/openvas-scanner
greenbone/gsad
greenbone/gvmd
greenbone/pg-gvm
velocidex/velociraptor
blacktop/yara

# Tier E — IT Ops
netboxcommunity/netbox
snipe/snipe-it
semaphoreui/semaphore
guacamole/guacamole
guacamole/guacd
portainer/portainer-ce
rundeck/rundeck
```

**Already in Zot (no action needed):**
`ollama/ollama`, `open-webui/open-webui`, `blakeblackshear/frigate`, `eclipse-mosquitto`, `meshtastic/meshtasticd`, `kiwix/kiwix-serve`, `gchq/cyberchef`, `frooodle/s-pdf`, `corentinth/it-tools`, `maptiler/tileserver-gl`, `libretranslate/libretranslate`, `linuxserver/calibre-web`, `grafana/grafana`, `prom/prometheus`

---

## Trivy Assessment

### Do We Need Trivy Now?

**Yes.** The case is strong:

| Factor | Assessment |
|--------|-----------|
| **Image count** | 97 repos in Zot today, growing to ~140. Attack surface is large. |
| **Upstream trust** | Most images are community-maintained. No commercial SLA on vulnerability patching. |
| **Air-gap window** | Once air-gapped, no upstream security updates. Must know current vulnerability posture. |
| **Compliance** | ARC serves medical (OpenEMR), financial (Firefly), and security (Frigate, Cannery) functions. |
| **New images incoming** | 35+ new images to preseed. Each is an unknown trust boundary. |
| **Known risk** | vxcontrol/kali-linux and vxcontrol/pentagi already in Zot — these are attack tooling images that should be scanned and isolated. |

### Recommended Trivy Deployment

1. **Deploy Trivy as Quadlet on Server-2** — scans Zot registry directly via local API
2. **Initial full scan** — scan all 97 existing + 35 new images, generate baseline report
3. **Scheduled scan** — weekly cron via Healthchecks, flag new CVEs
4. **Gate on preseed** — scan each new image before adding to Zot's local store
5. **SBOM generation** — `trivy image --format spdx-json` for every production image
6. **Integration:** Results → Grafana dashboard (Trivy JSON → Prometheus pushgateway or Loki)

### Trivy Resource Requirements

| Resource | Requirement |
|----------|-------------|
| RAM | 512 MB (scanning), spikes to 2 GB during DB update |
| Disk | 5 GB (vulnerability database) |
| Network | Initial DB download ~500 MB; offline mode after |
| CPU | Burst during scans, idle otherwise |

Trivy supports **offline mode** — download the vulnerability database while internet is available, then scan locally post-collapse. This is critical for air-gap readiness.

---

## VM Images Required

The following VM base images should be downloaded and staged now:

| VM Purpose | Base Image | Download URL | Est. Size | Staging Location |
|------------|-----------|-------------|-----------|-----------------|
| Samba4 AD DC (A-7 fallback) | AlmaLinux 9 minimal ISO | `repo.almalinux.org` | 2 GB | `external-storage/vm-staging/` |
| GnuHealth medical (A-8 alternative) | GNU Health official VM or FreeBSD ISO | `health.gnu.org` | 3 GB | `external-storage/vm-staging/` |
| Kali Linux (security testing) | Kali QEMU image | `kali.org/get-kali/#kali-virtual-machines` | 4 GB | `external-storage/vm-staging/` |
| FreeIPA (AD alternative, testing) | Fedora Server | Already in Zot (`library/fedora`) | 2 GB | `external-storage/vm-staging/` |

---

## Hardware-Dependent Equipment Gaps

These are NOT software gaps — they require physical procurement. Tracked as Gitea issue.

### P0 — Life Safety

| Item | Estimated Cost | Integrates With | User Story |
|------|---------------|-----------------|------------|
| PoE IP cameras (IR, outdoor) x4 | $400-800 | Frigate NVR (A4) | US-04 |
| PoE switch (camera VLAN 100) | $100-200 | switch-1 trunk | US-04 |
| NWR antenna (162 MHz) | $15 | rtl_433 (A6) | US-07 |
| Water quality sensors (pH, turbidity, chlorine) | $200-500 | Mosquitto (A5) → Home Assistant | US-10 |
| Motorized water shutoff valve | $50-100 | Home Assistant | US-10 |
| ESP32 + sensor controller | $20-40 | Mosquitto (A5) | US-10 |

### P0 — Power (Deferred, Major Capital)

| Item | Estimated Cost | Integrates With | User Story |
|------|---------------|-----------------|------------|
| Solar panel array (sized for ~1 kW cabinet load) | $2,000-5,000 | Home Assistant, Grafana | US-02 |
| LiFePO4 battery bank (48V, 200Ah+) | $3,000-8,000 | Home Assistant, Grafana | US-02 |
| MPPT charge controller | $200-500 | Home Assistant | US-02 |
| Pure sine wave inverter (2 kW+) | $500-1,000 | NUT | US-02 |
| Diesel generator (3-5 kW) | $1,000-3,000 | NUT, ntfy | US-03 |
| Automatic transfer switch (ATS) | $300-800 | NUT | US-03/09 |
| Rack UPS for Server-1 | $500-1,000 | NUT | US-09 |
| Rack UPS for Server-2 | $500-1,000 | NUT | US-09 |

### P1 — Communications

| Item | Estimated Cost | Integrates With | User Story |
|------|---------------|-----------------|------------|
| Heltec V3 LoRa nodes x6 | $150-300 | Meshtastic, Reticulum (A8/A9) | US-05/12 |
| Directional antenna (for relay) | $50-100 | Meshtastic repeater | US-44 |
| Solar + battery for relay station | $100-200 | Relay power | US-44 |
| Weatherproof enclosures x2 | $50-100 | Relay housing | US-44 |
| Weather station (433 MHz) | $50-100 | rtl_433 (A6) | US-07 |
| Soil moisture sensors x4 | $40-80 | Mosquitto (A5) → FarmOS | US-15 |

### P2 — Manufacturing

| Item | Estimated Cost | Integrates With | User Story |
|------|---------------|-----------------|------------|
| 3D printer filament stock (PETG, PLA, ASA) | $200-500 | InvenTree, Octoprint (B2) | US-29 |
| Spare nozzles, build plates | $50-100 | Octoprint (B2) | US-29 |

---

## Summary Statistics

| Tier | New Containers | New VMs | Est. RAM | Est. Disk | Images to Preseed |
|------|---------------|---------|----------|-----------|-------------------|
| A | 9 | 0 | 7-25 GB | 573 GB | 3 new (6 already in Zot) |
| B | 8 | 0 | 5-7 GB | 63 GB | 7 new |
| C | 4 | 1 | 9 GB | 45 GB | 4 new |
| D | 4 | 0 | 1 GB | 2 GB | 4 new |
| E (security) | 8 | 0 | 12 GB | 70 GB | 12 new |
| E (IT ops) | 7 | 0 | 3.5 GB | 11 GB | 7 new |
| E (ARCclient) | 10 | 0 | — (on clients) | — | 0 new (all in Zot) |
| **Total** | **50** | **1** | **37-58 GB** | **764 GB** | **37 new images** |

Server-2 post-deployment: ~80 GB RAM used of 314 GB (25%) — well within capacity.
Server-1 post-deployment: ~100 GB RAM used of 188 GB (53%) — comfortable.
workstation: ~30 GB RAM used of 64 GB (47%) — comfortable with GPU VRAM separate.

---

## Tier F — Thematic Expansion (2026-02-12, x-bookmarks-driven)

Surfaced from x-bookmarks sync (50 new bookmarks, Feb 5-12) and ARC thematic gap analysis. Tracked via arc#39-49.

### F1: Supply Chain & Trade (arc#39)

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| F1a | ERPNext | `frappe/erpnext` | **Yes** | Server-2 | 2 GB | 10 GB | Unified trade/barter ledger |
| F1b | Odoo | `library/odoo` | **Yes** (preseeded 2026-02-12) | Server-2 | 1 GB | 5 GB | Alternative ERP — broader module ecosystem |

### F2: Governance & Voting (arc#40)

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| F2a | Decidim | `decidim/decidim` | **Yes** | Server-2 | 1 GB | 5 GB | Participatory democracy, community voting |
| F2b | Docuseal | `docuseal/docuseal` | **Yes** | Server-2 | 512 MB | 2 GB | Document signing for governance |
| F2c | Loomio | `loomio/loomio` | **Yes** (preseeded 2026-02-12) | Server-2 | 512 MB | 2 GB | Collaborative decision-making |

### F3: Mental Health & Wellbeing (arc#41)

No new containers — configuration/content task using existing services (Moodle for CBT modules, Monica for community tracking).

### F4: Energy Management (arc#42)

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| F4a | OpenEMS | `openems/edge` | **Yes** | Server-2 | 512 MB | 2 GB | Solar/battery/generator optimization |
| F4b | Emoncms | `openenergymonitor/emoncms` | **Yes** (preseeded 2026-02-12) | Server-2 | 256 MB | 1 GB | Energy monitoring/graphing |

### F5: AI Media Processing (arc#43, arc#44)

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| F5a | ebook2audiobook | `athomasson2/ebook2audiobook` | **Yes** (preseeded 2026-02-12) | workstation (GPU) | 4 GB | 7 GB | ARC corpus → audio for field use |
| F5b | Real-ESRGAN | `ralphv/realesrgan` | **Yes** (preseeded 2026-02-12) | workstation (GPU) | 2 GB | 6 GB | Image upscaling for surveillance/docs |

### F6: Situation Awareness (arc#45)

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| F6a | WorldMonitor | Custom build (static+Nginx) | Pending build | Server-2 | 128 MB | 100 MB | Situation awareness dashboard |

### F7: Document Processing & Pentesting (arc#46)

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| F7a | olmOCR | Evaluate (GitHub-only) | No | Server-2 | 512 MB | 2 GB | PDF processing for LLM training |
| F7b | Shannon | Evaluate (GitHub-only) | No | workstation | 1 GB | 3 GB | Autonomous pentesting |

### F8: Cartography & Terrain Intelligence (arc#47)

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| F8a | uMap | `umap/umap:3.6.1` | **Yes** (preseeded 2026-02-12) | Server-2 | 256 MB | 500 MB | Collaborative map annotation |

### F9: Communications Archive / SIGINT (arc#48)

Pipeline using existing images: Faster-Whisper (in Zot) → ArchiveBox (deployed) → Wazuh/OpenSearch (in Zot). No new images needed.

### F10: Agriculture Intelligence (arc#49)

| # | Service | Image | In Zot? | Target Node | Est. RAM | Est. Disk | Fills |
|---|---------|-------|---------|-------------|----------|-----------|-------|
| F10a | Open Food Facts | `ghcr.io/openfoodfacts/openfoodfacts-server` | Pending preseed | Server-2 | 1.5 GB | 10 GB | Nutritional database |

### Tier F Summary

| Sub-tier | New Containers | Est. RAM | Est. Disk | Images Preseeded |
|----------|---------------|----------|-----------|------------------|
| F1 (Trade) | 2 | 3 GB | 15 GB | 1 new (1 existing) |
| F2 (Governance) | 3 | 2 GB | 9 GB | 1 new (2 existing) |
| F3 (Mental Health) | 0 | — | — | — |
| F4 (Energy) | 2 | 768 MB | 3 GB | 1 new (1 existing) |
| F5 (AI Media) | 2 | 6 GB | 13 GB | 2 new |
| F6 (Awareness) | 1 | 128 MB | 100 MB | Pending build |
| F7 (Doc/Pentest) | 2 | 1.5 GB | 5 GB | Pending eval |
| F8 (Cartography) | 1 | 256 MB | 500 MB | 1 new |
| F9 (SIGINT) | 0 | — | — | Pipeline only |
| F10 (Agriculture) | 1 | 1.5 GB | 10 GB | Pending preseed |
| **Total** | **14** | **~15 GB** | **~56 GB** | **6 preseeded, 3 pending** |
