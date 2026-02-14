# ARC Tier A Deployment Plan

> Deployment plan for 9 core services that close the most critical ARC capability gaps

## Deployment Order

Services are ordered by dependency chain — each service builds on the previous.

```
Phase 1: Foundation (no dependencies)
  ├── A5: Mosquitto MQTT Broker
  └── A7: RSSHub (news feed)

Phase 2: AI Pipeline (Mosquitto provides IoT bus)
  ├── A1: Ollama (workstation, GPU inference)
  ├── A2: Open WebUI (Server-2, chat interface → Ollama API)
  └── A3: ChromaDB (Server-1, vector store for RAG)

Phase 3: Security & Sensing (Mosquitto receives sensor data)
  ├── A4: Frigate NVR (Server-2, requires camera hardware)
  └── A6: rtl_433 (Server-2 or workstation, requires SDR hardware)

Phase 4: Mesh Communications (requires LoRa hardware)
  ├── A8: Meshtastic MQTT Bridge
  └── A9: Reticulum Hub
```

---

## Phase 1: Foundation

### A5: Mosquitto MQTT Broker

| Item | Detail |
|------|--------|
| **Image** | `eclipse-mosquitto:2.0` (pin to specific 2.0.x) |
| **Node** | Server-2 |
| **In Zot?** | Yes |
| **Port** | 1883 (MQTT), 9001 (WebSocket) |
| **RAM** | 64 MB |
| **Disk** | 100 MB |
| **Depends on** | Nothing — standalone broker |
| **Depended on by** | A6 (rtl_433), A8 (Meshtastic bridge), Home Assistant, all IoT sensors |

**Quadlet:** `~/.config/containers/systemd/mosquitto.container`

**Configuration:**
- Anonymous access for internal VLAN 20 only (no auth needed for lab-internal IoT)
- Persistence enabled (retain last message per topic)
- WebSocket listener for browser-based MQTT clients
- Firewall: port 1883/tcp on `lab-servers` zone

**Integration:**
- Home Assistant: add MQTT integration pointing to `10.0.20.20:1883`
- Grafana: MQTT data source plugin (or Prometheus via mqtt_exporter)

**DNS:** `mqtt.lab.example.com` → 10.0.20.20

**Rollback:** Stop and remove Quadlet. No other services depend on it initially.

---

### A7: RSSHub

| Item | Detail |
|------|--------|
| **Image** | `diygod/rsshub:latest` → pin to specific release tag after testing |
| **Node** | Server-2 |
| **In Zot?** | No — must preseed |
| **Port** | 1200 |
| **RAM** | 256 MB |
| **Disk** | 500 MB |
| **Depends on** | Nothing — standalone |
| **Depended on by** | FreshRSS (feed subscriptions), Searchhead news panel |

**Quadlet:** `~/.config/containers/systemd/rsshub.container`

**Configuration:**
- Cache: Redis or built-in memory cache (start with memory)
- Routes enabled: Twitter/X (`/twitter`), Reddit (`/reddit`), TikTok (`/tiktok`), Instagram (`/instagram`), YouTube (`/youtube`), Telegram (`/telegram`), HackerNews, plus 300+ news sources
- Rate limiting: 1 req/10s per route (avoid upstream bans while internet available)

**FreshRSS Integration (10+ sources):**

| Source | RSSHub Route | Category |
|--------|-------------|----------|
| Reuters | Native RSS | World News |
| AP News | Native RSS | World News |
| BBC World | Native RSS | World News |
| Al Jazeera | Native RSS | World News |
| NPR | Native RSS | US News |
| Hacker News | Native RSS | Tech |
| X/Twitter (curated lists) | `/twitter/list/:id` | Social/OSINT |
| Reddit (r/worldnews, r/collapse, r/preppers) | `/reddit/subreddit/:name` | Social/Analysis |
| TikTok (trending) | `/tiktok/trend` | Social/Trends |
| Instagram (accounts) | `/instagram/user/:id` | Social/Visual |
| YouTube (channels) | `/youtube/channel/:id` | Video/Analysis |
| Telegram (channels) | `/telegram/channel/:name` | Messaging/OSINT |

**Central-proxy route:** `rsshub.lab.example.com:8443` → `127.0.0.1:1200` (behind Authentik SSO)

**Searchhead integration:** Portal `/api/news/top` endpoint queries FreshRSS API for latest curated items, renders as a news ticker or card grid on the portal landing page.

**Rollback:** Stop Quadlet, remove FreshRSS feed subscriptions.

---

## Phase 2: AI Pipeline

### A1: Ollama

| Item | Detail |
|------|--------|
| **Image** | `ollama/ollama:0.6` (pin to minor version) |
| **Host** | workstation (Docker, not Podman — workstation runs Docker) |
| **In Zot?** | Yes |
| **Port** | 11434 |
| **RAM** | 4-16 GB (model-dependent, plus 8 GB VRAM) |
| **Disk** | 20 GB (models: qwen2.5:7b ~4 GB, llama3.2:3b ~2 GB, nomic-embed-text ~300 MB) |
| **Depends on** | GPU (consumer GPU (8GB VRAM)) — shared with TTS |
| **Depended on by** | A2 (Open WebUI), all ARCAI queries |

**Docker Compose (workstation):**
```yaml
services:
  ollama:
    image: ollama/ollama:0.6
    ports:
      - "11434:11434"
    volumes:
      - /home/labadmin/.ollama:/root/.ollama
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    restart: unless-stopped
```

**Models to pull (initial):**
1. `qwen2.5:7b-instruct-q4_K_M` — general assistant (4.4 GB, ~84 tok/s)
2. `llama3.2:3b-instruct-q4_K_M` — lightweight fallback (2 GB)
3. `nomic-embed-text` — embedding model for ChromaDB RAG (274 MB)
4. `qwen2.5:14b-instruct-q4_K_M` — complex reasoning (8.6 GB, ~30 tok/s)

**GPU contention with TTS:** Ollama and Qwen3-TTS cannot run simultaneously (both need VRAM). Options:
- Ollama `OLLAMA_GPU_MEMORY=6g` (leave 2 GB for TTS swap-in)
- Or: TTS yields to Ollama, Ollama yields to TTS via systemd dependency ordering
- Decision deferred to implementation

**Network access:** Ollama API must be reachable from Server-2 (Open WebUI). workstation firewall: allow 11434/tcp from VLAN 20.

**DNS:** `ollama.lab.example.com` → 10.0.10.141

---

### A2: Open WebUI

| Item | Detail |
|------|--------|
| **Image** | `open-webui/open-webui:v0.5` (pin to minor version) |
| **Node** | Server-2 |
| **In Zot?** | Yes |
| **Port** | 3080 |
| **RAM** | 512 MB |
| **Disk** | 2 GB (chat history, uploads) |
| **Depends on** | A1 (Ollama API at workstation:11434) |
| **Depended on by** | All ARCAI users via Searchhead |

**Quadlet:** `~/.config/containers/systemd/open-webui.container`

**Configuration:**
- `OLLAMA_BASE_URL=http://10.0.10.141:11434` (workstation Ollama)
- `WEBUI_AUTH=false` (use Authentik forward-auth instead)
- `DEFAULT_MODELS=qwen2.5:7b-instruct-q4_K_M`
- RAG: enable document upload, connect to ChromaDB when available
- User management: disabled (Authentik SSO provides identity)

**Central-proxy route:** `ai.lab.example.com:8443` → `127.0.0.1:3080` (behind Authentik SSO)

**NFS Risk:** Open WebUI on Server-2 depends on Ollama on workstation via network API. If workstation is powered off, Open WebUI shows "connection refused" to users. **Mitigation:** Display friendly "ARCengine offline" message. Future: CPU fallback Ollama instance on Server-2 for degraded mode.

**Rollback:** Stop Quadlet. Users lose chat interface but no other services affected.

---

### A3: ChromaDB

| Item | Detail |
|------|--------|
| **Image** | `chromadb/chroma:0.6` (pin to minor version) |
| **Node** | Server-1 |
| **In Zot?** | No — must preseed |
| **Port** | 8000 |
| **RAM** | 2-4 GB |
| **Disk** | 50 GB (embeddings grow with corpus size) |
| **Depends on** | Corpus data sources (Kiwix, Calibre-Web, Paperless-ngx — all on Server-1 or Server-2) |
| **Depended on by** | Open WebUI RAG, Corpus Juris, ARCAI routing |

**Quadlet:** `~/.config/containers/systemd/chromadb.container`

**Placement rationale:** Server-1 co-locates ChromaDB with its primary corpus sources (Kiwix, Calibre-Web, Manyfold, Digital Library, 3D Search — all on Server-1). This avoids cross-node NFS for the heaviest data sources.

**Embedding pipeline:**
1. Ollama on workstation runs `nomic-embed-text` model
2. Embedding worker script on workstation reads documents from corpus sources (some on Server-1 via NFS, some on Server-2 via API)
3. Embeddings written to ChromaDB on Server-1 via API (`10.0.20.10:8000`)
4. Open WebUI on Server-2 queries ChromaDB on Server-1 for RAG context

**NFS Risk:** Embedding generation crosses workstation → Server-1 boundary. This is a **batch operation** (acceptable per NFS policy). Real-time queries from Server-2 → Server-1 are API calls, not NFS.

**DNS:** `chromadb.lab.example.com` → 10.0.20.10

**Rollback:** Stop Quadlet. ARCAI loses RAG capability but still functions with direct LLM responses.

---

## Phase 3: Security & Sensing

### A4: Frigate NVR

| Item | Detail |
|------|--------|
| **Image** | `ghcr.io/blakeblackshear/frigate:0.14` (pin to minor) |
| **Node** | Server-2 |
| **In Zot?** | Yes |
| **Ports** | 5000 (web), 8554 (RTSP), 8555 (WebRTC) |
| **RAM** | 2-4 GB (depends on camera count and detection model) |
| **Disk** | 500 GB (30-day retention at 4 cameras) |
| **Depends on** | Camera hardware (PoE IP cameras on VLAN 100), Mosquitto (A5) for MQTT events |
| **Depended on by** | Story 9 (Watch Commander), Security roles |

**Quadlet:** `~/.config/containers/systemd/frigate.container`

**Blocked on:** Camera hardware procurement. Software can be deployed and configured in advance with test RTSP streams.

**Configuration:**
- MQTT: `mqtt.lab.example.com:1883` for event publication
- Detection: CPU-based (no Coral TPU; use OpenVINO on Server-2's CPU)
- Cameras: configure per-camera RTSP URLs when hardware arrives
- Retention: 30 days continuous, 90 days events-only
- Integration: Home Assistant (MQTT discovery), ntfy (person detection alerts)

**Central-proxy route:** `frigate.lab.example.com:8443` → `127.0.0.1:5000` (already in services.yaml)

**Firewall:** Frigate on Server-2 VLAN 20 must reach cameras on VLAN 100. FIREWALL rule exists (inter-VLAN routing).

---

### A6: rtl_433

| Item | Detail |
|------|--------|
| **Image** | `hertzg/rtl_433:latest` → pin after testing |
| **Host** | **workstation** (if NooElec SDR stays on workstation) or **Server-2** (if SDR moved) |
| **In Zot?** | No — must preseed |
| **Port** | None (publishes to MQTT) |
| **RAM** | 64 MB |
| **Disk** | 50 MB |
| **Depends on** | USB SDR hardware (NooElec NESDR SMArt), Mosquitto (A5) |
| **Depended on by** | Home Assistant (weather/sensor data), US-07 (weather alerts) |

**Hardware dependency:** SDR must be USB-passed through to container. If SDR is on workstation, this runs on workstation (Docker). If SDR is moved to Server-2, this runs as Quadlet on Server-2.

**Configuration:**
- Output: MQTT to `mqtt.lab.example.com:1883`
- Frequency: 433.92 MHz (ISM band — weather stations, soil sensors, tire pressure monitors)
- Protocols: enable all common sensor protocols
- SAME/NWR decoding: separate decoder needed for 162 MHz (different frequency)

---

## Phase 4: Mesh Communications

### A8: Meshtastic MQTT Bridge

| Item | Detail |
|------|--------|
| **Image** | Custom Python container |
| **Host** | Whichever host has Heltec V3 USB |
| **In Zot?** | N/A — custom build |
| **Port** | None (MQTT client) |
| **RAM** | 128 MB |
| **Depends on** | Heltec V3 hardware (USB serial), Mosquitto (A5) |

**Blocked on:** LoRa radio deployment. Heltec V3 hardware exists but is not deployed as a gateway.

**Function:** Bridges Meshtastic mesh messages to MQTT topics. Enables:
- Mesh text messages appearing in ntfy/Prosody XMPP
- Server-side logging of all mesh traffic
- Mesh alerts triggering ARCAI event processing

---

### A9: Reticulum Hub

| Item | Detail |
|------|--------|
| **Image** | Custom Python container (`pip install rns lxmf`) |
| **Host** | Server-2 (or whichever host has Heltec V2 USB) |
| **In Zot?** | N/A — custom build |
| **Port** | 4242 (Reticulum transport), 4281 (LXMF) |
| **RAM** | 128 MB |
| **Depends on** | Heltec V2 hardware (for RF transport), TCP transport (for LAN-based mesh) |

**Blocked on:** LoRa radio deployment for RF transport. Can deploy TCP-only transport immediately for LAN-based testing.

**Function:** Central Reticulum transport node. LXMF message relay for store-and-forward mesh messaging. Gateway between RF mesh and server-side services.

---

## Pre-Deployment Checklist

| # | Action | Status | Blocking? |
|---|--------|--------|-----------|
| 1 | Preseed Zot with `chromadb/chroma`, `diygod/rsshub`, `hertzg/rtl_433` | Pending | Yes (A3, A7, A6) |
| 2 | Scan all images with Trivy | Pending (Trivy not deployed) | Recommended, not blocking |
| 3 | Create DNS host overrides on FIREWALL | Pending | Yes (all services) |
| 4 | Open firewall ports on Server-2 | Pending | Yes (A4, A5, A7) |
| 5 | Open firewall port on workstation | Pending | Yes (A1: 11434/tcp from VLAN 20) |
| 6 | Verify Server-1 firewall allows 8000/tcp | Pending | Yes (A3: ChromaDB) |
| 7 | Create Quadlet files | Pending | Yes (all Server-1/Server-2 services) |
| 8 | Create Docker Compose for workstation | Pending | Yes (A1: Ollama) |
| 9 | Pull Ollama models | Pending | Yes (A1) |
| 10 | Configure FreshRSS feeds for RSSHub | Pending | After A7 deployed |
| 11 | Procure cameras | Pending | Blocks A4 full deployment |
| 12 | Deploy LoRa radios | Pending | Blocks A8, A9 |
| 13 | Add central-proxy routes | Pending | Yes (A2, A7, A4) |
| 14 | Add Authentik providers | Pending | Yes (A2, A7) |
| 15 | Add services.yaml entries | Pending | Tier 3 (post-deploy) |
| 16 | Add Uptime Kuma monitors | Pending | Tier 3 (post-deploy) |
| 17 | Pin image digests in Quadlet files | Pending | Best practice |

---

## Resource Impact Summary

| Host | Before | After Phase 1 | After Phase 2 | After Phase 3 | After Phase 4 |
|------|--------|---------------|---------------|---------------|---------------|
| **Server-2 RAM** | 37 GB | 37.3 GB (+320 MB) | 37.8 GB (+512 MB) | 41.8 GB (+4 GB) | 42.1 GB (+256 MB) |
| **Server-1 RAM** | 92 GB | 92 GB | 96 GB (+4 GB) | 96 GB | 96 GB |
| **workstation RAM** | ~20 GB | ~20 GB | ~36 GB (+16 GB) | ~36 GB | ~36 GB |
| **Server-2 containers** | 95 | 97 | 98 | 100 | 102 |
| **Server-1 containers** | 17 | 17 | 18 | 18 | 18 |

All hosts remain well within capacity at every phase.
