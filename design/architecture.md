# ARC Architecture

> Assisted Reconstitution of Civilization — System Architecture Reference

## Overview

ARC is a 4-layer architecture that provides AI-assisted knowledge access, decision support, and operational coordination for a post-collapse community of ~150 people. The system runs on a self-contained 6U server cabinet plus a standalone admin workstation, powered by solar/generator, operating fully air-gapped.

Every user interaction follows the same pattern regardless of role: authenticate at a terminal, query through a natural language interface, and receive AI-routed responses drawing from a curated offline knowledge corpus.

---

## Layer 1: Searchhead

**Purpose:** User-facing terminal interface — the single point of entry for all ARC interactions.

**Function:** Receives natural language queries from authenticated users, renders responses, and provides structured access to services and dashboards. All role-based access control begins here via Authentik SSO tied to Active Directory groups.

### Current Implementation

| Component | Service | Host | Status |
|-----------|---------|------|--------|
| Web Portal | Reference Lab Portal (Flask) | Server-2:8080 | Deployed |
| SSO / IdP | Authentik (OIDC, forward-auth) | Server-2:9443 | Deployed |
| Directory | Active Directory (DC-1/DC-2) | DC-1/DC-2 | Deployed |
| Full-text Search | Manticore Search | Server-2:8120 | Deployed |
| Central Proxy | nginx + Authentik outpost | Server-2:8443 | Deployed |

### Gaps

- No unified query bar (currently a service directory, not a chat interface)
- No ARCAI integration — portal serves static service links, not AI-routed responses
- No role-specific dashboard views — all authenticated users see the same interface

---

## Layer 2: ARCAI

**Purpose:** Lightweight AI routing and dispatch layer — classifies queries, checks permissions, and routes to the appropriate backend.

**Function:** Sits between Searchhead and ARCengine/ARCstore. Receives natural language input, determines domain (medical, security, agriculture, maintenance, etc.), assesses urgency, verifies the user's role has authorization, then routes to the correct processing backend. For safety-critical domains (medical, weapons, legal), ARCAI uses structured decision trees rather than free LLM generation.

### Design Principles

1. **Classify first, generate second** — Every query is classified by domain and urgency before any LLM inference
2. **Role-gating** — AD group membership determines what domains a user can query
3. **Safety-critical lockout** — Medical diagnoses, weapons procedures, and legal rulings use curated decision trees, not raw LLM output
4. **Urgency routing** — Emergency queries preempt the GPU queue; routine queries can use CPU fallback
5. **Cross-service orchestration** — ARCAI can trigger actions across multiple services (create a task, update inventory, log a record) as part of a single response

### Protocol (from HIVE design)

| Message Type | Purpose |
|--------------|---------|
| `QUERY` | User question → ARCAI classifies and routes |
| `EVENT` | System alert or sensor data → ARCAI evaluates and optionally notifies |
| `STATE_UPDATE` | Service status change → ARCAI updates internal state model |
| `ROUTE` | ARCAI dispatches work to ARCengine or ARCstore |

### Current Implementation

| Component | Status |
|-----------|--------|
| Query classifier | Not built |
| Role-gating (AD groups) | AD deployed, groups exist, not wired to query routing |
| HIVE protocol | Designed, not implemented |
| HALops SFT pipeline | Proven (Qwen2.5-7B, 60% accuracy, 84 tok/s) |
| Safety-critical decision trees | Not built |

---

## Layer 3: ARCengine

**Purpose:** AI inference engine — runs language models for query answering, classification, summarization, and decision support.

**Function:** Processes routed queries from ARCAI using the best available hardware. GPU inference for complex/emergency queries, CPU fallback for routine lookups. Scales from a Raspberry Pi (1.5B model, basic Q&A) to a full workstation with GPU (14-32B model, specialist reasoning).

### Hardware Tiers

| Tier | Hardware | Model Size | Speed | Capability |
|------|----------|-----------|-------|------------|
| T0 Micro | Raspberry Pi 4/5 | 1.5B Q4 | ~5 tok/s | Basic Q&A, lookup, simple triage |
| T1 Edge | Toughbook CF-31 (8GB) | 3-7B Q4 | ~10-15 tok/s | Field reference, medical decision trees, radio procedures |
| T2 Mid | Server-1/Server-2 (CPU) | 7-14B Q4 | ~15-30 tok/s | Reasonable assistant, RAG over corpus |
| T3 Core | workstation + consumer GPU (8GB VRAM) (8GB VRAM) | 14-32B Q4-Q8 | ~30-84 tok/s | Full capability, fine-tuned specialist, vision |

### Current Implementation

| Component | Service | Host | Status |
|-----------|---------|------|--------|
| GPU inference | llama.cpp / Ollama | workstation | Proven (HALops), Ollama planned (infrastructure#72) |
| CPU fallback | llama.cpp | Server-1/Server-2 | Not deployed |
| Voice output | Qwen3-TTS | workstation | Deployed |
| Model fine-tuning | QLoRA + GGUF pipeline | workstation | Proven |

### GPU Contention

The consumer GPU (8GB VRAM) is shared between ARCengine inference and TTS voice generation. Only one can hold VRAM at a time. ARCAI must manage GPU scheduling — TTS yields to emergency inference requests.

---

## Layer 4: ARCstore

**Purpose:** Unified corpus index across all knowledge assets — the memory of the community.

**Function:** Provides searchable, indexed access to ~1.9 TB of curated offline knowledge spanning reference materials, technical manuals, medical guides, legal documents, maps, 3D models, ebooks, and video archives. ARCAI queries ARCstore for RAG context before generating responses.

### Corpus Inventory

| Source | Service | Size | Content |
|--------|---------|------|---------|
| Wikipedia | Kiwix | 112 GB | Full English Wikipedia |
| Stack Overflow | Kiwix | 75 GB | Programming/engineering knowledge |
| ZIM collection | Kiwix | 318 GB | 77 offline reference files |
| Survival library | Calibre-Web | ~50+ GB | Curated survival/preparedness docs |
| Atlas satellite tiles | Atlas | 540 GB | z0-z13 global satellite imagery |
| 3D print archive | Manyfold + 3D Search | 432 GB | 193k+ printable models |
| F-Droid mirror | F-Droid Server | 15 GB | 1018 Android apps |
| Digital library | Calibre-Web | ~50+ GB | Ebook collection |
| Video archive | Tube Archivist | varies | Downloaded video library |
| Document archive | Paperless-ngx | varies | OCR'd document collection |
| Medical records | OpenEMR | varies | Patient management system |
| Legal corpus | Corpus Juris (planned) | ~35 GB | US legal reference (ChromaDB RAG) |

**Total curated corpus: ~1.9 TB**

### Current Implementation

| Component | Service | Host | Status |
|-----------|---------|------|--------|
| Reference library | Kiwix (77 ZIMs) | Server-1 | Deployed |
| Ebook library | Calibre-Web | Server-1 | Deployed |
| 3D model catalog | Manyfold + 3D Search | Server-1 | Deployed |
| Document management | Paperless-ngx | Server-2 | Deployed |
| Full-text search | Manticore Search | Server-2 | Deployed |
| Corpus management | Archivist | workstation | Designed |
| RAG embeddings | ChromaDB | — | Planned |
| Video archive | Tube Archivist | Server-2 | Deployed |
| Offline maps | Atlas (7 containers) | Server-1 | Deployed |

### Gaps

- **No unified index** — data is fragmented across 10+ services with separate search interfaces
- **No RAG pipeline** — ChromaDB not deployed, no embedding generation
- **Archivist not built** — designed as the unification layer but not implemented
- **No cross-corpus search** — querying Kiwix doesn't search Calibre-Web or Paperless-ngx

---

## Interaction Pattern

Every role story in [ARC-ROLE-STORIES.md](ARC-ROLE-STORIES.md) follows this 7-step pattern:

```
Step 1: AUTHENTICATE
  User at community terminal → Authentik SSO → AD group lookup → role determined

Step 2: QUERY
  User types natural language question into Searchhead

Step 3: CLASSIFY
  ARCAI determines:
    - Domain (medical, security, agriculture, maintenance, reference, etc.)
    - Urgency (emergency, urgent, routine, informational)
    - Sensitivity (public, role-restricted, leadership-only)
    - Authorization (does user's AD group grant access to this domain?)

Step 4: ROUTE
  ARCAI selects processing path:
    - ARCengine GPU → emergency or complex reasoning (preempts queue)
    - ARCengine CPU → routine inference (Server-1/Server-2 fallback)
    - ARCstore direct → pure lookup (no inference needed)
    - Service API → structured query to specific service (Grocy, OpenEMR, etc.)

Step 5: PROCESS
  Selected backend(s) execute:
    - ARCengine generates response with ARCstore RAG context
    - Service APIs return structured data
    - Multiple backends may be queried in parallel

Step 6: RESPOND
  Results returned to user via Searchhead:
    - Primary answer
    - Source citations (which corpus documents were consulted)
    - Cross-references to related information
    - Suggested follow-up actions

Step 7: ACT (optional)
  ARCAI triggers cross-service actions if authorized:
    - Create task in Vikunja/Taiga
    - Update inventory in Grocy/InvenTree
    - Log record in OpenEMR/FarmOS
    - Send notification via ntfy/FreePBX
    - Archive document in Paperless-ngx
```

---

## ARC-001 Hardware Manifest

ARC-001 is the reference homelab — the first production ARC environment.

### 6U Cabinet (rack-mounted, top to bottom)

| Position | Device | Role | Specs |
|----------|--------|------|-------|
| 1U | Blank panel | — | Cable management |
| 1U | managed L2 switch (48-port GbE, 4x SFP) (switch-1) | Network fabric | 48-port managed switch, 7 VLANs, LACP trunks, QoS |
| 1U | CyberPower PR1500LCDRT2U | Power protection | UPS, NUT monitored, ~18 min runtime at load |
| 1U | enterprise-firewall (1U rack-mount, 16GB RAM) | Network edge | OPNsense — DNS (Unbound), DHCP (Kea), VPN (WireGuard), IDS (Suricata), NUT |
| 1U | enterprise-server-2 (rack-mount, 96GB RAM, BMC) (Server-2) | Primary app server | 128 GB RAM, 44 containers, Authentik, Grafana, 60+ services |
| 1U | enterprise-server-1 (1U rack-mount, 64GB RAM) | Knowledge/media server | 64 GB RAM, 15+ containers, Kiwix, Atlas, Calibre, Manyfold |

### Cabinet-Adjacent

| Device | Role | Notes |
|--------|------|-------|
| Raspberry Pi 4/5 | Edge compute | T0 Micro ARCengine, field relay, Meshtastic gateway |
| 20 TB external drive (external-storage) | Bulk storage | Corpus archive, media library, download staging (exFAT) |
| Fiber modem | WAN connectivity | Pre-collapse internet provisioning |

### Standalone Workstation

| Device | Role | Notes |
|--------|------|-------|
| workstation Ultra | Admin workstation / ARCengine Core | consumer GPU (8GB VRAM) (8 GB VRAM), TTS, model training, Archivist |

### Network Architecture

```
Internet ←→ Fiber Modem ←→ FIREWALL (OPNsense)
                              ├── VLAN 10 (Management): switch-1, BMCs, workstation
                              ├── VLAN 20 (Servers): Server-1, Server-2
                              ├── VLAN 30 (Workstations): WiFi clients
                              ├── VLAN 50 (Home Devices): personal devices
                              ├── VLAN 100 (IoT): sensors, cameras
                              ├── VLAN 200 (VoIP): FreePBX, SIP phones
                              └── VLAN 240 (Testing): lab experiments
```

### Power Budget

| Device | Typical Draw | Peak Draw |
|--------|-------------|-----------|
| managed L2 switch (48-port GbE, 4x SFP) | ~40 W | ~65 W |
| CyberPower UPS | — (provides power) | 1500 VA / 1000 W capacity |
| FIREWALL (enterprise-firewall) | ~80 W | ~120 W |
| Server-2 (enterprise-server-2) | ~200 W | ~350 W |
| Server-1 (enterprise-server-1) | ~150 W | ~250 W |
| workstation Ultra (idle) | ~80 W | ~350 W (GPU load) |
| **Cabinet total** | **~470 W** | **~785 W** |
| **Full system** | **~550 W** | **~1135 W** |

---

## Document Cross-References

| Document | What It Covers |
|----------|---------------|
| [ARC-ORGANIZATION.md](ARC-ORGANIZATION.md) | Who uses ARC — 6 groups, 50 rotation slots, cross-training |
| [ARC-SERVICE-REGISTRY.md](ARC-SERVICE-REGISTRY.md) | All 97 services with off-grid purpose and criticality |
| [ARC-ROLE-STORIES.md](ARC-ROLE-STORIES.md) | How each role uses ARC — 14 detailed interaction stories |
| [ARC-DECISIONS.md](ARC-DECISIONS.md) | What's blocking — 7 decisions + 10 assumptions |
| [USER-STORIES.md](USER-STORIES.md) | 50 capability-focused user stories (what ARC provides) |
| [CORPUS-JURIS-PLAN.md](CORPUS-JURIS-PLAN.md) | Legal corpus design (Wasteland Judge) |
