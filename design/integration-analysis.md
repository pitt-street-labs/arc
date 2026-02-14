# ARC Service Integration Analysis

> First-pass mapping of cross-service integration chains, middleware requirements, and synergistic combinations across the 97-service ARC inventory

## Purpose

ARC-001 runs 97 deployed services. The missing piece is not more services — it's the **connective tissue** between them. This document maps every viable service-to-service integration chain, identifies the middleware (ARCAI Layer 2) required to orchestrate them, and prioritizes implementation by operational impact.

Every integration chain below flows through the 7-step interaction pattern defined in [ARC-ARCHITECTURE.md](ARC-ARCHITECTURE.md): AUTHENTICATE → QUERY → CLASSIFY → ROUTE → PROCESS → RESPOND → ACT.

---

## ARCAI as Middleware: Three Core Capabilities

ARCAI Layer 2 is a **message bus with a brain**. It needs three capabilities to enable all integration chains:

| Capability | What It Does | Implementation |
|------------|-------------|----------------|
| **Query Classifier** | Maps natural language → domain + urgency + sensitivity | Small classifier model, or keyword/regex for v0 |
| **Service Connector Registry** | Knows every service's API endpoint, auth method, and data shape | Config mapping: service → endpoint → auth → schema |
| **Action Dispatcher** | Executes cross-service writes (create task, log record, send notification) | Async task queue with rollback on partial failure |

### Implementation Language Decision

Two viable options exist for the ARCAI middleware:

#### Option A: Rust (Recommended for ARC)

| Factor | Assessment |
|--------|-----------|
| **Memory footprint** | ~5-15 MB (static binary) vs ~50-100 MB (Python + runtime + deps) |
| **Deployment** | Single binary, zero runtime dependencies — critical for post-collapse |
| **Long-running reliability** | No GC pauses, ownership-enforced memory safety, no memory leaks |
| **Cross-compile** | `cargo build --target aarch64-unknown-linux-gnu` for Pi (T0/T1 tiers) |
| **Async I/O** | tokio ecosystem: reqwest (HTTP), rumqttc (MQTT), tokio-tungstenite (WebSocket) |
| **LLM integration** | reqwest to Ollama HTTP API (clean REST), or llama.cpp FFI via bindgen |
| **CalDAV/WebDAV** | reqwest + quick-xml (manual but straightforward) |
| **Estimated LOC** | ~6,000-8,000 |
| **Post-collapse resilience** | Runs on bare metal, no Python/pip/venv needed, survives OS reinstalls |

#### Option B: Python (Faster to Prototype)

| Factor | Assessment |
|--------|-----------|
| **Memory footprint** | ~50-100 MB with runtime and dependencies |
| **Deployment** | Requires Python 3.x, venv, pip, dependency management |
| **Long-running reliability** | GC pauses possible, memory leaks in long-running async code |
| **Library ecosystem** | Richer: httpx, paho-mqtt, caldav, python-xmpp, openai SDK |
| **Iteration speed** | Faster prototyping, easier to modify without recompile |
| **Estimated LOC** | ~4,000 |
| **Post-collapse resilience** | Needs Python runtime installed on every target |

**Recommendation:** Rust. For a system designed to run for years without maintenance on degraded hardware, the single-binary deployment, zero-dependency runtime, and memory safety guarantees outweigh the slower initial development. The middleware is I/O-bound (HTTP API calls to 20+ services), which tokio handles excellently. Ollama exposes a clean REST API that reqwest can consume directly.

**Hybrid approach:** Prototype the query classifier and 3 service connectors in Python (1 week), validate the integration patterns work, then rewrite in Rust for production. The Python prototype becomes the integration test suite.

---

## API Surface: Service Integration Readiness

### Tier 1 — Production-Quality REST APIs (Ready Now)

| Service | API Type | Auth Method | Key Endpoints |
|---------|----------|-------------|---------------|
| **Grocy** | REST | API key header | `/api/stock`, `/api/objects/products`, `/api/chores` |
| **OpenEMR** | REST (partial FHIR) | OAuth2 | `/apis/default/fhir/Patient`, `/apis/default/api/encounter` |
| **Nextcloud** | WebDAV/CalDAV/REST | App password | CalDAV: `/remote.php/dav/`, OCS: `/ocs/v2.php/` |
| **Vikunja** | REST | API token | `/api/v1/tasks`, `/api/v1/projects`, `/api/v1/labels` |
| **ntfy** | HTTP POST | Token (optional) | `POST /topic` with JSON body |
| **InvenTree** | REST | Token | `/api/stock/`, `/api/part/`, `/api/order/` |
| **Tandoor** | REST | Token | `/api/recipe/`, `/api/meal-plan/`, `/api/shopping-list/` |
| **Firefly III** | REST | OAuth2/PAT | `/api/v1/transactions`, `/api/v1/accounts` |
| **Wiki.js** | GraphQL | API key | Single endpoint: `/graphql` |
| **Home Assistant** | REST + WebSocket | Long-lived token | `/api/states`, `/api/services`, WebSocket `/api/websocket` |
| **Prometheus** | PromQL HTTP | None | `/api/v1/query`, `/api/v1/query_range` |
| **Grafana** | REST | API key | `/api/dashboards`, `/api/annotations` |
| **Paperless-ngx** | REST | Token | `/api/documents/`, `/api/tags/`, `/api/correspondents/` |
| **Trilium** | REST | Token | `/api/notes`, `/api/branches`, `/api/attributes` |
| **LibreTranslate** | REST | Optional key | `POST /translate`, `GET /languages` |
| **Manticore Search** | SQL-like HTTP | None | `POST /sql` with SQL query |
| **Taiga** | REST | Token | `/api/v1/userstories`, `/api/v1/tasks`, `/api/v1/projects` |
| **FarmOS** | JSON:API (Drupal) | OAuth2 | `/api/log/harvest`, `/api/asset/land`, `/api/quantity/` |
| **Moodle** | REST/SOAP | Token | `/webservice/rest/server.php?wsfunction=` |

### Tier 2 — Usable with Workarounds

| Service | API Type | Notes |
|---------|----------|-------|
| **Kiwix** | Search API (basic) | `/search?pattern=` — returns HTML, needs parsing |
| **Atlas (Martin)** | Tile API | `/tiles/{z}/{x}/{y}` — good for tiles, limited for queries |
| **Frigate** | MQTT + REST | MQTT preferred for events; REST for clips/snapshots |
| **FreePBX** | AMI (Asterisk Manager) | TCP socket protocol, not REST — needs dedicated connector |
| **Prosody XMPP** | XMPP protocol | Not REST — needs XMPP client library (xmpp-rs in Rust) |
| **Monica CRM** | REST | API adequate but less documented |
| **Healthchecks** | REST | Simple ping API, limited query capability |

### Tier 3 — Limited or No API

| Service | Issue | Workaround |
|---------|-------|------------|
| **Calibre-Web** | No search API | OPDS feed parsing, or direct SQLite query on Calibre DB |
| **CyberChef** | Client-side JS only | Embed CyberChef operations as library calls |
| **Super-Deredactor** | Custom pipeline | Direct container invocation via CLI |
| **Cannery** | Unknown API surface | Needs investigation — may require scraping or DB access |
| **HortusFox** | Limited API | Needs investigation |
| **Anki Sync** | Sync protocol only | Custom deck creation via AnkiConnect or direct SQLite |

---

## 12 Integration Chains

### Chain 1: Field Medic → EMR → AI → Calendar

**Trigger:** Human query (medical domain)
**Scenario:** Medic encounters a patient with an infected wound in the field.

**Flow:**

```
Medic authenticates (Authentik/AD: ARC-Medical group)
    │
    ├── Step A: QUERY OpenEMR API
    │   └── GET /patient/{id}/allergies → "Penicillin allergy confirmed"
    │
    ├── Step B: QUERY Kiwix + Calibre-Web (RAG context)
    │   └── "Infected wound management for penicillin-allergic patient"
    │   └── Returns: clindamycin 300mg PO q6h, wound irrigation protocol
    │
    ├── Step C: WRITE OpenEMR API
    │   └── POST /encounter → wound care encounter, clindamycin prescription
    │
    ├── Step D: WRITE Nextcloud CalDAV
    │   └── POST calendar event: "Follow-up wound check" → 48h from now
    │
    ├── Step E: WRITE Vikunja API
    │   └── POST task: "Prepare clindamycin 300mg x20 doses" → assigned to Pharmacist
    │
    └── Step F: NOTIFY ntfy
        └── POST: "MEDICAL: New wound care case, follow-up scheduled 48h"
```

**Services (8):** Authentik, OpenEMR, Kiwix, Calibre-Web, ARCengine, Nextcloud, Vikunja, ntfy
**Safety-critical ordering:** Allergy check (Step A) MUST complete before drug recommendation (Step B). This is not parallelizable.
**API readiness:** All APIs available. OpenEMR needs clinical configuration (providers, templates, drug database).

---

### Chain 2: Perimeter Breach → Security Response → Communications

**Trigger:** Event-driven (Frigate MQTT, no human query)
**Scenario:** Frigate detects a human at the perimeter at 0300.

**Flow:**

```
Frigate MQTT event: {type: "new", label: "person", camera: "north_fence", score: 0.87}
    │
    ├── Step A: CLASSIFY urgency
    │   └── person + nighttime (0000-0600) + perimeter zone = EMERGENCY
    │
    ├── Step B: QUERY Atlas API
    │   └── GET terrain around camera location → approach vectors, cover positions
    │
    ├── Step C: NOTIFY ntfy (priority: urgent)
    │   └── "PERIMETER: Human detected north fence, 0300. Confidence 87%"
    │
    ├── Step D: NOTIFY FreePBX (AMI)
    │   └── Auto-dial ext 702 (Watch Commander) + TTS announcement
    │
    ├── Step E: WRITE Vikunja
    │   └── POST task: "Investigate north fence breach" → Security team, priority urgent
    │
    ├── Step F: WRITE Trilium Notes
    │   └── POST incident log: timestamp, camera, screenshot URL, confidence
    │
    └── Step G: IF Reticulum deployed → LXMF broadcast
        └── Mesh text to patrol units: "ALERT: North fence, approach with caution"
```

**Services (8):** Frigate (MQTT), Atlas, ntfy, FreePBX (AMI), Vikunja, Trilium, Reticulum/LXMF
**Key design:** This is **event-driven** — ARCAI needs an MQTT subscriber that feeds into the EVENT message type. No human initiates this chain.
**Middleware requirement:** MQTT listener (rumqttc in Rust / paho-mqtt in Python) subscribed to `frigate/events`.

---

### Chain 3: Harvest → Inventory → Meal Planning → Task Assignment

**Trigger:** Human action (farmer logs harvest)
**Scenario:** Farmer logs 200 lbs tomatoes. System cascades through food logistics.

**Flow:**

```
Farmer authenticates (ARC-Food group)
    │
    ├── Step A: WRITE FarmOS API
    │   └── POST /api/log/harvest → 200 lbs tomatoes, Field 3, 2026-02-15
    │
    ├── Step B: WRITE Grocy API (auto-triggered by harvest log)
    │   └── POST /api/stock → 200 lbs tomatoes, received date, predicted spoilage
    │
    ├── Step C: QUERY Tandoor API
    │   └── GET /api/recipe/?search=tomato → 47 recipes, sorted by ingredient match
    │
    ├── Step D: QUERY Grocy API (cross-reference)
    │   └── GET /api/stock → check complementary ingredients for top recipes
    │
    ├── Step E: GENERATE meal plan (ARCengine)
    │   └── "Plan 21 meals for 150 people, prioritize tomato consumption before spoilage"
    │   └── Cross-reference Grocy stock for what else is available
    │
    ├── Step F: WRITE Vikunja
    │   └── POST tasks: "Prep 50 lbs tomato sauce (Mon)", "Can remaining tomatoes (Wed)"
    │
    └── Step G: NOTIFY ntfy
        └── "FOOD: 200 lbs tomatoes received. Meal plan updated. Canning needed by Wed."
```

**Services (7):** FarmOS, Grocy, Tandoor, ARCengine, Vikunja, ntfy
**Key pattern:** This is a **cascade chain** — one write triggers dependent reads and further writes. Middleware must handle ordering and partial failure (if Tandoor is down, meal plan still works from Grocy stock alone).

---

### Chain 4: Legal Dispute → Corpus Juris → Governance Record

**Trigger:** Human query (governance domain)
**Scenario:** Two community members dispute water rights. Judge queries ARC.

**Flow:**

```
Judge authenticates (ARC-Governance group)
    │
    ├── Step A: QUERY Corpus Juris (ChromaDB RAG)
    │   └── "Water rights disputes between adjacent property users"
    │   └── Returns: riparian rights doctrine, prior appropriation, relevant case law
    │
    ├── Step B: QUERY Kiwix
    │   └── "Water rights common law" → Wikipedia legal article + citations
    │
    ├── Step C: QUERY Wiki.js (GraphQL)
    │   └── GET community constitution → Section 12: Resource Disputes
    │   └── "All natural resources shared communally; disputes resolved by Council vote"
    │
    ├── Step D: GENERATE ruling framework (ARCengine)
    │   └── Synthesize: constitutional communal sharing + common law riparian rights
    │   └── Recommend framework that respects both principles
    │
    ├── Step E: WRITE Wiki.js (GraphQL mutation)
    │   └── POST precedent record: "Case #7: Water dispute, ruling framework: ..."
    │
    ├── Step F: WRITE Nextcloud CalDAV
    │   └── POST: "Council hearing — Water dispute resolution" → 3 days from now
    │
    └── Step G: NOTIFY ntfy
        └── "GOVERNANCE: Water dispute hearing scheduled. Precedent research complete."
```

**Services (7):** Corpus Juris (ChromaDB + Ollama), Kiwix, Wiki.js, ARCengine, Nextcloud, ntfy
**Blocked by:** D-1 (base model), Ollama deployment (infrastructure#72), ChromaDB deployment, Corpus Juris build (arc#1)

---

### Chain 5: Equipment Failure → Parts Search → 3D Print → Repair

**Trigger:** Human query (maintenance domain)
**Scenario:** Water pump impeller fails. Mechanic needs a replacement.

**Flow:**

```
Mechanic authenticates (ARC-Maintenance group)
    │
    ├── Step A: QUERY InvenTree API
    │   └── GET /api/stock/?search=impeller → 0 in stock, last used 2026-01-15
    │
    ├── Step B: QUERY Part-DB
    │   └── GET part specifications → dimensions, material requirements (ABS/PETG)
    │
    ├── Step C: QUERY 3D Search (Manyfold API)
    │   └── GET /search?q=pump+impeller → 14 models from 193k archive
    │   └── Filter by dimensional match → 3 candidates
    │
    ├── Step D: QUERY Kiwix
    │   └── "Water pump impeller replacement procedure" → maintenance guide
    │
    ├── Step E: WRITE Vikunja
    │   └── POST task: "3D print impeller (Model #7234)" → 3D Print Operator
    │   └── POST task: "Install impeller after print" → Mechanic (blocked by print task)
    │
    ├── Step F: WRITE InvenTree API
    │   └── PATCH stock item: mark impeller as "on order" (3D print in progress)
    │
    └── Step G: NOTIFY ntfy
        └── "MAINTENANCE: Water pump down. Impeller printing. ETA ~8 hours."
```

**Services (7):** InvenTree, Part-DB, Manyfold/3D Search, Kiwix, Vikunja, ntfy
**Key integration:** InvenTree ↔ Manyfold linkage — when stock reaches zero, automatically search 3D archive for printable alternatives. This is a **zero-stock manufacturing** pattern unique to ARC.

---

### Chain 6: Training & Certification → Moodle → Skills Matrix

**Trigger:** Human action (educator enrolls trainee)
**Scenario:** New community member needs medical first responder cross-training.

**Flow:**

```
Educator authenticates (ARC-Support group)
    │
    ├── Step A: QUERY Monica CRM API
    │   └── GET person profile → existing skills, background, prior training
    │
    ├── Step B: QUERY Moodle API
    │   └── GET /webservice/rest/server.php?wsfunction=core_course_search_courses
    │   └── Available: "First Responder Basic", "Wound Care", "Triage"
    │   └── Prerequisites: "First Responder" requires no prereqs
    │
    ├── Step C: WRITE Moodle API
    │   └── POST enrollment: student → "First Responder Basic" course
    │
    ├── Step D: QUERY Kiwix + Calibre-Web
    │   └── Pull supplementary reading: TCCC manual, WHO emergency care guide
    │
    ├── Step E: GENERATE + WRITE Anki
    │   └── ARCengine generates flashcard deck from training material
    │   └── Push deck via AnkiConnect API
    │
    ├── Step F: WRITE Nextcloud CalDAV
    │   └── POST: "First Responder Training — Week 1" → schedule block
    │
    └── Step G: WRITE Monica CRM API
        └── PATCH person: add tag "Enrolled: First Responder program"
```

**Services (8):** Monica, Moodle, Kiwix, Calibre-Web, ARCengine, Anki, Nextcloud, Monica
**Key AI role:** ARCengine auto-generates Anki flashcards from training material — turns passive reading into active recall study aids.

---

### Chain 7: Radio Intelligence → Signal Analysis → Threat Assessment

**Trigger:** Human action (SIGINT operator captures unknown signal)
**Scenario:** Unknown radio transmission detected on SDR.

**Flow:**

```
Radio/SIGINT authenticates (ARC-Security group)
    │
    ├── Step A: CAPTURE via OpenWebRX+
    │   └── Record unknown signal, export IQ data file
    │
    ├── Step B: QUERY tar1090 API
    │   └── GET aircraft tracks during signal window → check for ADS-B correlation
    │
    ├── Step C: ANALYZE signal characteristics
    │   └── Frequency, modulation, bandwidth, duration, bearing (if directional antenna)
    │
    ├── Step D: QUERY Kiwix
    │   └── "Radio frequency allocation [frequency band]" → identify licensed use
    │
    ├── Step E: GENERATE assessment (ARCengine)
    │   └── "Unknown signal on [freq], [modulation]. Correlates with [aircraft/none].
    │        Assessment: likely [civilian/military/unknown]. Threat level: [low/med/high]"
    │
    ├── Step F: WRITE Trilium Notes
    │   └── POST SIGINT log: recording reference, analysis, assessment, bearing
    │
    ├── Step G: IF threat ≥ medium → NOTIFY ntfy + FreePBX
    │   └── Alert Security Chief (ntfy urgent) + Watch Commander (AMI auto-dial)
    │
    └── Step H: WRITE Vikunja
        └── POST task: "Continuous monitoring on [freq] for 24 hours" → SIGINT operator
```

**Services (8):** OpenWebRX+, tar1090, Kiwix, ARCengine, Trilium, ntfy, FreePBX, Vikunja
**Note:** CyberChef is client-side JS only — signal analysis would need embedded DSP logic in the middleware or a separate signal processing tool.

---

### Chain 8: Power Management → Load Shedding → Service Priority

**Trigger:** Event-driven (Home Assistant sensor threshold)
**Scenario:** Battery at 30%, solar output declining, generator fuel low.

**Flow:**

```
Home Assistant EVENT: battery_level < 30%
    │
    ├── Step A: QUERY Home Assistant API
    │   └── GET /api/states → solar_output, battery_level, generator_fuel, total_load
    │
    ├── Step B: QUERY Prometheus API
    │   └── GET /api/v1/query → per-service resource consumption (CPU, RAM)
    │   └── Correlate with known power draw per host
    │
    ├── Step C: CLASSIFY against ARC Service Registry tiers
    │   └── Map running services → P0, P1, P2, P3 criticality
    │   └── Calculate power savings per tier shed
    │
    ├── Step D: GENERATE load-shedding plan (ARCengine)
    │   └── "Battery exhausts in 4.2 hours at current draw.
    │        Shed P3 (Jellyfin, Navidrome, retro museum) → saves ~45W
    │        Shed P2 if below 15% (CyberChef, IT-Tools) → saves ~30W
    │        P0/P1 remain until generator start or sunrise"
    │
    ├── Step E: ACT — stop P3 services (REQUIRES approval gate)
    │   └── Community Director must approve before systemctl stop
    │   └── ntfy prompt: "POWER: Approve P3 shutdown? Battery 30%, 4.2h remaining"
    │
    ├── Step F: WRITE Grafana API
    │   └── POST /api/annotations → "Load shedding activated: P3 stopped"
    │
    └── Step G: NOTIFY ntfy + FreePBX
        └── "POWER: Battery 30%. P3 services stopped. Generator needed within 4 hours."
```

**Services (7):** Home Assistant, Prometheus, ARCengine, systemd, Grafana, ntfy, FreePBX
**Key design:** ARCAI has the Service Registry internalized — it can make **informed** load-shedding decisions based on criticality tier, not crude "everything off." This is intelligence that no individual service provides alone.
**Safety gate:** Service shutdown requires human approval — ARCAI proposes, human disposes.

---

### Chain 9: Supply Run Planning → Maps → Inventory → Comms

**Trigger:** Human query (security + logistics domains)
**Scenario:** Scouts plan a supply run to an abandoned hardware store 8 km away.

**Flow:**

```
Scout Leader authenticates (ARC-Security group)
    │
    ├── Step A: QUERY Atlas API
    │   └── GET route options to target coordinates
    │   └── Terrain analysis: road condition, elevation, cover positions
    │   └── Satellite imagery of target building and surroundings
    │
    ├── Step B: QUERY Grocy + InvenTree APIs (parallel)
    │   └── GET critical shortages → priority acquisition list
    │   └── "Priority: pipe fittings, 14ga wire, M8 fasteners, adjustable wrench"
    │
    ├── Step C: QUERY Cannery
    │   └── GET ammunition status → "Adequate for 4-person team, 2-day mission"
    │
    ├── Step D: GENERATE mission brief (ARCengine)
    │   └── Route plan (primary + alternate), acquisition priorities ranked by weight
    │   └── Comms schedule (check-in every 2 hours), contingency plans
    │
    ├── Step E: WRITE Vikunja
    │   └── POST tasks: "Pre-mission equipment check", "Departure 0600", "RTB NLT 1800"
    │
    ├── Step F: WRITE Nextcloud
    │   └── POST document: mission brief (shared with team + leadership)
    │
    └── Step G: CONFIGURE mesh comms
        └── Verify Reticulum/Meshtastic relay coverage along route
        └── Set check-in schedule in Vikunja as recurring tasks
```

**Services (8):** Atlas, Grocy, InvenTree, Cannery, ARCengine, Vikunja, Nextcloud, Reticulum/Meshtastic

---

### Chain 10: Population Health Surveillance → Outbreak Detection

**Trigger:** Scheduled analysis (ARCAI cron, daily at 0200)
**Scenario:** ARCAI detects a pattern in OpenEMR encounter data — no human initiates this.

**Flow:**

```
ARCAI scheduled task (daily 0200, no human trigger)
    │
    ├── Step A: QUERY OpenEMR API
    │   └── GET encounters (last 14 days) → aggregate by chief complaint
    │   └── Result: 7 patients with GI symptoms in 10 days (baseline: 1-2)
    │
    ├── Step B: CLASSIFY — 3.5x baseline = potential outbreak = URGENT
    │
    ├── Step C: QUERY Kiwix + Calibre-Web (RAG)
    │   └── "Waterborne illness outbreaks in small communities"
    │   └── "Norovirus vs bacterial gastroenteritis differential by presentation"
    │
    ├── Step D: CORRELATE across services (parallel queries)
    │   └── FarmOS: any changes to water source or collection point?
    │   └── Grocy: common food item consumed by all 7 patients?
    │   └── Home Assistant: water quality sensor anomalies?
    │
    ├── Step E: GENERATE epidemiological report (ARCengine)
    │   └── "GI cluster: 7 cases in 10 days (3.5x baseline).
    │        5/7 patients used Creek NE-7-14 water (assessed HIGH RISK on 2026-02-10).
    │        Likely waterborne. Recommend: suspend creek collection, test stored water,
    │        isolate symptomatic cases, boil water advisory."
    │
    ├── Step F: WRITE OpenEMR API
    │   └── POST population health alert flag on all 7 patient records
    │
    ├── Step G: NOTIFY ntfy (CRITICAL priority)
    │   └── "MEDICAL ALERT: GI outbreak. 7 cases/10 days. Likely waterborne. See report."
    │
    └── Step H: WRITE Vikunja
        └── POST tasks: "Emergency water testing", "Patient isolation", "Boil water advisory"
```

**Services (8):** OpenEMR, Kiwix, Calibre-Web, FarmOS, Grocy, Home Assistant, ARCengine, ntfy, Vikunja
**Key insight:** This is **proactive AI** — no human asked a question. ARCAI runs scheduled analysis across multiple data sources and raises alerts when patterns emerge. This is where the real operational excellence lives — humans can't manually cross-reference EMR data with water sources and food inventory daily, but ARCAI can.

---

### Chain 11: Document Recovery → OCR → Intelligence → Archive

**Trigger:** Human action (intelligence analyst processes found documents)
**Scenario:** Patrol finds documents in an abandoned building.

**Flow:**

```
Intelligence Analyst authenticates (ARC-Security group)
    │
    ├── Step A: UPLOAD to Paperless-ngx
    │   └── Scanned pages → OCR pipeline → full text extracted automatically
    │
    ├── Step B: IF foreign language → QUERY LibreTranslate API
    │   └── POST /translate → English translation of extracted text
    │
    ├── Step C: IF redacted content → invoke Super-Deredactor
    │   └── 4-engine OCR consensus → attempt recovery of redacted sections
    │
    ├── Step D: ANALYZE content (ARCengine)
    │   └── Classify: military orders / supply manifest / medical / personal / technical
    │   └── Extract: locations, names, quantities, dates, organizations
    │
    ├── Step E: WRITE Paperless-ngx API
    │   └── POST tags: "intelligence", "patrol-20260215", classification label
    │
    ├── Step F: IF actionable → WRITE Trilium Notes
    │   └── POST intelligence assessment with extracted data and cross-references
    │
    └── Step G: IF urgent → NOTIFY ntfy
        └── Alert Security Chief with summary of actionable intelligence
```

**Services (7):** Paperless-ngx, LibreTranslate, Super-Deredactor, ARCengine, Trilium, ntfy
**Multi-language support:** LibreTranslate handles 30+ languages offline — critical for processing documents from unknown sources.

---

### Chain 12: Inter-Community Trade → Ledger → Inventory → Mesh

**Trigger:** Event-driven (inbound LXMF message from neighboring ARC site)
**Scenario:** ARC-002 proposes a trade via mesh network.

**Flow:**

```
Inbound LXMF message: "ARC-002 offers 50 lbs wheat flour for 20 lbs salt"
    │
    ├── Step A: QUERY Grocy API
    │   └── GET current salt stock → 85 lbs (20 lbs = 23.5% of stock, acceptable)
    │   └── GET current flour stock → 12 lbs (critically low — trade is favorable)
    │
    ├── Step B: GENERATE trade assessment (ARCengine)
    │   └── "Trade favorable. Flour critically needed. Salt surplus adequate.
    │        Caloric value analysis: flour 50 lbs = ~82,000 cal; salt essential but non-caloric.
    │        Recommendation: ACCEPT. Suggest future trade terms for ongoing relationship."
    │
    ├── Step C: NOTIFY Community Director + Logistics Officer
    │   └── ntfy: "TRADE: ARC-002 offers 50 lbs flour for 20 lbs salt. AI recommends accept."
    │
    ├── Step D: IF approved → WRITE Firefly III API
    │   └── POST transaction: trade record with valuation, counterparty, date
    │
    ├── Step E: WRITE Grocy API (after physical exchange)
    │   └── POST stock adjustments: -20 lbs salt, +50 lbs flour
    │
    └── Step F: REPLY via Reticulum/LXMF
        └── "ARC-001 accepts. Rendezvous: [Atlas coordinates]. Time: [from Nextcloud calendar]."
```

**Services (7):** Reticulum/LXMF, Grocy, ARCengine, ntfy, Firefly III, Atlas, Nextcloud
**Blocked by:** Reticulum deployment (offgrid-comms#3), Firefly III clinical configuration

---

## Synergy Map: Cross-Chain Intelligence

Individual chains are useful. Cross-chain intelligence is transformational — capabilities that emerge only when ARCAI reasons across multiple data sources simultaneously.

| Combination | Emergent Capability | Services Involved |
|-------------|-------------------|-------------------|
| **OpenEMR + Grocy + FarmOS** | Medical nutrition: "Patient diabetic → flag high-sugar meal plans → adjust farm planting priorities toward low-glycemic crops" | OpenEMR, Grocy, Tandoor, FarmOS |
| **Frigate + Atlas + Reticulum** | Tactical response: "Breach detected → terrain overlay with approach vectors → mesh alert to patrol with cover positions" | Frigate, Atlas, Reticulum, ntfy |
| **Grocy + Tandoor + FarmOS** | Farm-to-table loop: "Harvest logged → recipes selected by spoilage urgency → meal planned → canning scheduled → waste minimized" | FarmOS, Grocy, Tandoor, Vikunja |
| **InvenTree + Manyfold + Part-DB** | Zero-stock manufacturing: "Part broken → no stock → printable model found automatically → print queued → repair scheduled" | InvenTree, Part-DB, Manyfold, Vikunja |
| **Prometheus + HA + Service Registry** | Intelligent load shedding: "Power low → rank services by criticality tier → shed non-essential → preserve P0 services → restore when power recovers" | Home Assistant, Prometheus, Grafana, systemd |
| **OpenEMR + Moodle + Monica** | Workforce resilience: "3 people sick → cross-training records checked → reassign trained backup → adjust training schedule" | OpenEMR, Moodle, Monica, Nextcloud |
| **Corpus Juris + Wiki.js + Nextcloud** | Governance pipeline: "Dispute filed → legal research → constitution check → precedent search → hearing scheduled → ruling recorded → precedent indexed" | Corpus Juris, Wiki.js, Nextcloud, Vikunja |
| **Kiwix + LibreTranslate + Paperless** | Document intelligence: "Found doc → OCR → language detect → translate → classify → archive → alert if actionable" | Paperless-ngx, LibreTranslate, Kiwix, Trilium |
| **Cannery + Atlas + Vikunja** | Defense logistics: "Ammo below threshold → known cache at grid ref → mission planned with route → team tasked" | Cannery, Atlas, Vikunja, Nextcloud |
| **OpenEMR + FarmOS + Grocy + HA** | Epidemiological detection: "GI cluster in EMR → correlate with water source changes and food inventory → identify likely source → issue boil advisory" | OpenEMR, FarmOS, Grocy, Home Assistant |

---

## Middleware Component Architecture

### Component 1: Query Router

**Purpose:** Receive natural language queries, classify domain, check authorization, route to appropriate service connectors.

**Inputs:** User query text + Authentik JWT (contains AD group membership)
**Outputs:** Structured response + optional ACT commands

**Domain classifier (v0 — keyword/regex):**

| Domain | Keywords/Patterns | AD Group Required |
|--------|-------------------|-------------------|
| medical | patient, symptom, diagnosis, medication, allergy, wound, fever | ARC-Medical |
| food | harvest, inventory, meal, recipe, stock, spoilage, ration | ARC-Food |
| security | perimeter, threat, patrol, ammunition, breach, radio, signal | ARC-Security |
| maintenance | repair, broken, part, replace, pump, generator, tool | ARC-Maintenance |
| governance | dispute, law, ruling, vote, constitution, trade, treaty | ARC-Governance |
| education | training, course, certification, study, teach, learn | ARC-Support |
| reference | how to, what is, explain, define, Wikipedia, search | All groups |
| power | battery, solar, generator, load, watt, fuel, UPS | ARC-Support |

**Domain classifier (v1 — fine-tuned model):** Small classifier (DistilBERT-sized) fine-tuned on ARC domain examples. Runs on CPU in <50ms. Replaces keyword matching.

### Component 2: Service Connector Registry

**Purpose:** Abstraction layer over all service APIs. Each connector knows: endpoint URL, auth method, request format, response parsing.

**Connector interface (Rust trait / Python ABC):**

```
trait ServiceConnector {
    fn name(&self) -> &str;
    fn health_check(&self) -> Result<bool>;
    fn query(&self, params: QueryParams) -> Result<QueryResponse>;
    fn write(&self, action: WriteAction) -> Result<WriteResponse>;
}
```

**Initial connectors (Phase 1 MVP):**

| Connector | Service | Operations |
|-----------|---------|------------|
| `OpenEmrConnector` | OpenEMR | patient lookup, allergy check, encounter create |
| `GrocyConnector` | Grocy | stock query, stock adjust, expiration check |
| `KiwixConnector` | Kiwix | full-text search, article retrieval |
| `VikunjaConnector` | Vikunja | task create, task assign, project list |
| `NtfyConnector` | ntfy | notification send (with priority levels) |
| `NextcloudConnector` | Nextcloud | CalDAV event create, file upload |
| `ArcEngineConnector` | Ollama | LLM inference (generate, classify) |

**Phase 2 connectors:**

| Connector | Service | Operations |
|-----------|---------|------------|
| `FrigateConnector` | Frigate | MQTT event subscribe, snapshot retrieve |
| `HomeAssistantConnector` | Home Assistant | state query, service call |
| `PrometheusConnector` | Prometheus | PromQL query |
| `AtlasConnector` | Atlas/Martin | tile retrieve, route query, geocode |
| `InvenTreeConnector` | InvenTree | stock query, stock adjust |
| `FarmOsConnector` | FarmOS | harvest log, asset query |
| `TandoorConnector` | Tandoor | recipe search, meal plan create |
| `PaperlessConnector` | Paperless-ngx | document upload, tag, search |

### Component 3: Event Listener

**Purpose:** Subscribe to event sources (MQTT, webhooks, WebSocket) and feed events into ARCAI without human queries.

**Event sources:**

| Source | Protocol | Events |
|--------|----------|--------|
| Frigate | MQTT (`frigate/events`) | Object detection, motion |
| Home Assistant | WebSocket | Sensor threshold crossings |
| Alertmanager | Webhook (HTTP POST) | Prometheus alert firing |
| Reticulum/LXMF | Custom (RNS API) | Inbound mesh messages |
| Healthchecks | Webhook | Cron job failures |

### Component 4: Scheduled Analysis Engine

**Purpose:** Run periodic cross-service analysis to detect patterns humans would miss.

| Schedule | Analysis | Services Queried |
|----------|----------|------------------|
| Daily 0200 | Population health trends | OpenEMR |
| Daily 0300 | Food expiration warnings | Grocy |
| Hourly | Power budget assessment | Home Assistant, Prometheus |
| Weekly | Inventory reorder alerts | Grocy, InvenTree, Cannery |
| Weekly | Training certification expiry | Moodle, Monica |
| Daily | Service health summary | Uptime Kuma, Healthchecks |

---

## Safety-Critical Domain Handling

For medical, weapons, and legal domains, ARCAI MUST NOT use free LLM generation. These domains require **structured decision trees** that guide the user through validated protocols.

### Medical Decision Trees (Priority)

| Tree | Protocol | Source |
|------|----------|--------|
| Trauma triage | MARCH (Massive hemorrhage, Airway, Respiration, Circulation, Hypothermia) | TCCC guidelines |
| Patient assessment | SAMPLE (Signs/Symptoms, Allergies, Medications, Past history, Last intake, Events) | EMT curriculum |
| Drug interactions | Allergy cross-reference → contraindication check → dosage by weight | WHO Essential Medicines |
| Vital sign interpretation | Normal ranges by age → deviation severity → escalation triggers | Pediatric/adult reference |

### Weapons Decision Trees

| Tree | Protocol | Source |
|------|----------|--------|
| Ammunition allocation | Stock check → mission requirement → reserve threshold → approve/deny | Community policy |
| Use of force | Threat level assessment → proportional response → escalation ladder | Rules of engagement |

### Legal Decision Trees

| Tree | Protocol | Source |
|------|----------|--------|
| Dispute resolution | Constitutional check → precedent search → procedural requirements → hearing format | Community constitution |
| Sentencing | Offense classification → prior history → mitigating factors → sentencing guidelines | Governance framework |

The LLM (ARCengine) supplements these trees with RAG context (Kiwix articles, Calibre-Web references), but the **decision structure is hardcoded**, not generated.

---

## Implementation Phases

### Phase 0: Unblock (1-2 days)

| Task | Deliverable | Blocked By |
|------|------------|------------|
| Decide D-1 (base model) | Recommendation: Qwen2.5-7B (proven with HALops) | Nothing |
| Deploy Ollama on Server-2 (CPU) | `ollama.container` Quadlet | infrastructure#72 |
| Deploy ChromaDB on Server-2 | `chromadb.container` Quadlet | Ollama |
| Seed OpenEMR clinical data | Provider accounts, patient templates, WHO drug DB | Nothing |

### Phase 1: MVP Query Router (3-5 days)

| Task | Deliverable |
|------|------------|
| ARCAI query router binary/service | Handles 3 domains: medical, inventory, reference |
| 7 service connectors | OpenEMR, Grocy, Kiwix, Vikunja, ntfy, Nextcloud, Ollama |
| Searchhead chat integration | Chat bar in Portal, role-based response filtering |
| ACT dispatcher | Creates Vikunja tasks + sends ntfy notifications from query results |

### Phase 2: Event-Driven Chains (1 week)

| Task | Deliverable |
|------|------------|
| MQTT event listener | Frigate perimeter events → security alerting (Chain 2) |
| Home Assistant integration | Power management events → load shedding (Chain 8) |
| Scheduled analysis engine | Daily OpenEMR analysis → outbreak detection (Chain 10) |
| 7 additional connectors | Frigate, HA, Prometheus, Atlas, InvenTree, FarmOS, Tandoor |

### Phase 3: Full Orchestration (2-4 weeks)

| Task | Deliverable |
|------|------------|
| All 12 chains operational | Complete integration across 20+ services |
| Safety-critical decision trees | Medical (MARCH, SAMPLE), weapons, legal |
| Mesh integration | Reticulum/LXMF for Chains 2, 9, 12 |
| Voice interface | Whisper STT + Qwen3-TTS (already deployed) for voice queries |
| Role-based Searchhead views | Custom dashboard per AD group (D-7) |
| Corpus Juris deployment | ChromaDB RAG for legal queries (Chain 4) |
| Population health dashboard | Grafana panel showing OpenEMR trends |

---

## Deployment Architecture

### ARCAI Middleware Container

Deployed as a Podman Quadlet on Server-2 (primary app server):

```ini
# ~/.config/containers/systemd/arcai.container
[Unit]
Description=ARCAI Middleware
After=ollama.service chromadb.service

[Container]
Image=localhost/arcai:latest
Network=host
Environment=OLLAMA_URL=http://localhost:11434
Environment=CHROMADB_URL=http://localhost:8000
Environment=OPENEMR_URL=http://localhost:8160
# ... all service endpoints
Volume=/home/labadmin/data/arcai:/data:Z

[Service]
Restart=always

[Install]
WantedBy=default.target
```

### Network Access

ARCAI needs HTTP access to all service APIs on Server-1 and Server-2. All services are on the `br-servers` bridge (VLAN 20) or `host` network. No firewall changes needed for same-host services. Cross-host (Server-2 → Server-1) uses existing VLAN 20 routing.

### Authentication

ARCAI authenticates to each service using dedicated API tokens stored in Vaultwarden. One `bw` item per service connector:

| Vaultwarden Item | Service | Token Type |
|------------------|---------|------------|
| `arcai.openemr` | OpenEMR | OAuth2 client credentials |
| `arcai.grocy` | Grocy | API key |
| `arcai.vikunja` | Vikunja | API token |
| `arcai.nextcloud` | Nextcloud | App password |
| `arcai.inventree` | InvenTree | API token |
| `arcai.grafana` | Grafana | Service account token |
| ... | ... | ... |

---

## Open Questions

1. **Rust vs Python for v0 prototype?** This document recommends Rust for production, with optional Python prototype for validation. Decision needed.
2. **ARCAI hosting: Server-2 or workstation?** Server-2 is the app server (closer to services), workstation has the GPU (needed for ARCengine). Recommendation: ARCAI middleware on Server-2, ARCengine inference on workstation via Ollama HTTP API.
3. **ChromaDB embedding model?** Need to select embedding model for RAG index. Options: `nomic-embed-text` (768d, good quality), `all-minilm` (384d, faster, smaller).
4. **Cannery API investigation needed.** Current API surface unknown — may need custom connector or DB-level access.
5. **CyberChef integration path?** Client-side JS only — either embed as library, skip, or build custom signal analysis tooling.
6. **Approval gates for ACT actions.** Which write operations require human approval before execution? Medical writes? Service shutdowns? All writes?

---

## Related Documents

- [ARC-ARCHITECTURE.md](ARC-ARCHITECTURE.md) — 4-layer system architecture, 7-step interaction pattern
- [ARC-SERVICE-REGISTRY.md](ARC-SERVICE-REGISTRY.md) — All 97 services with ARC purpose and criticality
- [ARC-ROLE-STORIES.md](ARC-ROLE-STORIES.md) — 14 detailed interaction stories showing service dependencies
- [ARC-ORGANIZATION.md](ARC-ORGANIZATION.md) — 6 groups, 44 roles, AD group mappings
- [ARC-DECISIONS.md](ARC-DECISIONS.md) — 7 blocking design decisions (D-1 through D-7)
- [ARC-TIER-A-DEPLOYMENT.md](ARC-TIER-A-DEPLOYMENT.md) — Phase plan for first 9 core services
- [ARC-CONTAINER-GAPS.md](ARC-CONTAINER-GAPS.md) — 50+ additional services with container gap analysis
- [CORPUS-JURIS-PLAN.md](CORPUS-JURIS-PLAN.md) — Legal RAG system design (Chain 4 dependency)
