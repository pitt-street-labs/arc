# ARC Service Registry

> All 97 services deployed on ARC-001, with off-grid purpose, role mappings, criticality tier, and fallback procedures

## Overview

ARC-001 runs 97 services across 5 hosts (FIREWALL, Server-1, Server-2, workstation, pbx-1) plus network infrastructure (switch-1, UPS, WiFi AP). Each service has an **ARC Purpose** — its function in a post-collapse 150-person community operating without internet.

Services are organized into 4 criticality tiers:
- **Tier 1 (P0)** — Cannot lose. Community survival depends on these.
- **Tier 2 (P1)** — Serious degradation without. Operations become significantly harder.
- **Tier 3 (P2)** — Quality of life. Community functions but morale and efficiency suffer.
- **Tier 4 (P3)** — Rebuild capabilities. Long-term civilization reconstruction.
- **Infrastructure** — Always-on, not user-facing. Supports all other tiers.

---

## Tier 1 — Cannot Lose (P0)

These services are critical to community survival. Loss of any P0 service triggers an emergency response.

| # | Service | Host | Port | ARC Purpose | Primary Roles | Fallback |
|---|---------|------|------|-------------|---------------|----------|
| 1 | OPNsense Firewall | FIREWALL | 443 | Network perimeter — DNS resolution, DHCP, inter-VLAN routing, VPN for remote nodes. All internal service discovery depends on Unbound DNS. | IT Admin | Static IP configs, hosts files, direct routing |
| 2 | Kiwix | Server-1 | 8888 | **Primary reference library** — 77 ZIM files including full Wikipedia, StackExchange, medical references, survival guides. The single most important knowledge source for all roles. | All roles | Physical books, printed references |
| 3 | OpenEMR | Server-2 | 8160 | **Medical records system** — patient tracking, prescriptions, vitals, lab results. The Medical Officer's primary tool for managing health of 150 people. | Medical Officer, Nurse, Combat Medic | Paper charts, printed medication lists |
| 4 | Grocy | Server-2 | 8104 | **Community inventory** — food stock levels, expiration tracking, meal planning integration, chore assignments. Prevents spoilage and enables rationing. | Head Cook, Logistics Officer, all Food roles | Physical inventory logs, clipboards |
| 5 | Atlas (7 containers) | Server-1 | 8090 | **Offline mapping** — satellite imagery (z0-z13), vector tiles, routing, geocoding. Critical for patrols, foraging zones, water source locations, defensive planning. | Scouts, Security, Forager, Farmer, all roles | Paper maps, compass navigation |
| 6 | FarmOS | Server-2 | 8161 | **Agricultural management** — field mapping, planting schedules, harvest tracking, soil logs, livestock records. Feeds planning for 150 mouths. | Farmer, Livestock Manager, Forager | Paper crop logs, almanac |
| 7 | Vaultwarden | Server-2 | 8222 | **Credential vault** — all service passwords, API keys, encryption keys. Loss means potential lockout from other services. | IT Admin, Community Director | Offline backup (encrypted, printed) |
| 8 | Authentik SSO | Server-2 | 9443 | **Identity provider** — single sign-on for all services, role-based access via AD groups. Enforces who can access what. | IT Admin | Direct service logins, local accounts |
| 9 | FreePBX | pbx-1 | 80 | **Voice communications** — internal phone system (extensions 100/200/300/702), emergency broadcast, inter-group coordination. | Radio Operator, Watch Commander, all leaders | Runners, whistles, megaphone |
| 10 | Frigate NVR | Server-2 | 8146 | **Perimeter security** — camera feeds with object detection, motion alerts, recording. Eyes on the perimeter 24/7. | Security Chief, Watch Commander, Gate Guard | Physical patrols, guard rotation |

---

## Tier 2 — Serious Degradation (P1)

Operations continue but become significantly harder, slower, or riskier without these services.

| # | Service | Host | Port | ARC Purpose | Primary Roles | Fallback |
|---|---------|------|------|-------------|---------------|----------|
| 11 | Nextcloud | Server-2 | 8130 | **Shared documents** — file sync, calendars, contacts, SOPs. Community coordination hub. | All roles | USB drive sneakernet, bulletin boards |
| 12 | Moodle | Server-2 | 8142 | **Training platform** — courses, quizzes, certification tracking. Apprenticeship and cross-training delivery. | Educator, HR Manager | Classroom instruction, printed handouts |
| 13 | Prometheus | Server-2 | 9091 | **Metrics store** — system health, power consumption, network stats. Early warning for hardware failures. | IT Admin, Energy Analyst | Manual monitoring, visual inspection |
| 14 | Grafana | Server-2 | 3000 | **Dashboards** — 16 dashboards visualizing all Prometheus metrics. Decision support for resource allocation. | IT Admin, Community Director, Energy Analyst | Raw Prometheus queries, spreadsheets |
| 15 | Uptime Kuma | Server-2 | 8111 | **Service monitoring** — 80 probes tracking service availability. Alerts IT Admin before users notice outages. | IT Admin | Manual service checks |
| 16 | ntfy | Server-2 | 8150 | **Push notifications** — alert delivery for security events, system failures, emergency broadcasts. | All roles (receive), IT Admin (admin) | FreePBX intercom, runners |
| 17 | Paperless-ngx | Server-2 | 8134 | **Document archive** — OCR'd manuals, procedures, found documents. Searchable institutional memory. | Records Clerk, all roles | Physical filing cabinet |
| 18 | Cannery | Server-2 | 8118 | **Ammunition tracking** — inventory counts by caliber, range logs. Critical for defense resource planning. | Armorer, Security Chief | Paper ammo log |
| 19 | Tandoor Recipes | Server-2 | 8144 | **Recipe management** — meal planning for 150, shopping list generation from Grocy stock. | Head Cook, Food Preservation | Printed recipe binders |
| 20 | Taiga | Server-2 | 8132 | **Project management** — Kanban/Scrum boards for community projects, construction, defense preparations. | Community Director, Facilities Manager | Physical task boards, sticky notes |
| 21 | Vikunja | Server-2 | 8135 | **Task management** — work orders, maintenance schedules, daily assignments with CalDAV. | All group leaders | Paper task lists |
| 22 | Prosody XMPP | Server-2 | 5222 | **Text messaging** — community chat, group channels, presence. Async communication for all. | All roles | Radio, runners, bulletin boards |
| 23 | Calibre-Web | Server-1 | 8083 | **Ebook library** — survival manuals, medical references, technical guides, trade skill books. | All roles | Physical book library |
| 24 | Home Assistant | Server-2 | 8145 | **Sensor hub** — solar panel output, temperature sensors, water level sensors, automation triggers. | Solar Tech, Energy Analyst, Facilities | Manual gauge reading |
| 25 | InvenTree | Server-2 | 8136 | **Parts inventory** — BOM management, stock tracking, barcode scanning for repair parts. | Mechanic, Electrician, all maintenance | Paper parts log |
| 26 | Healthchecks | Server-2 | 8110 | **Cron monitor** — heartbeat checks for scheduled tasks (backups, updates, monitoring scripts). | IT Admin | Manual cron verification |
| 27 | Manyfold + 3D Search | Server-1 | 3214/8085 | **3D model library** — 193k printable models for replacement parts, tools, medical devices, construction hardware. | 3D Print Operator, all repair roles | Manual CAD design, improvisation |

---

## Tier 3 — Quality of Life (P2)

Community functions without these, but morale, efficiency, and convenience suffer.

| # | Service | Host | Port | ARC Purpose | Primary Roles | Fallback |
|---|---------|------|------|-------------|---------------|----------|
| 28 | Jellyfin | Server-2 | 8140 | **Entertainment** — movies, TV, music for community morale. Mental health is survival. | All (general population) | Board games, storytelling, music instruments |
| 29 | Navidrome | Server-2 | 8116 | **Music streaming** — Subsonic-compatible, playlists, community radio. | All (general population) | Physical media players, live music |
| 30 | HortusFox | Server-2 | 8105 | **Plant management** — care schedules, watering reminders for greenhouse/indoor growing. | Farmer, Herbalist | Paper care charts |
| 31 | CyberChef | Server-2 | 8101 | **Data analysis** — encoding, decryption, format conversion. SIGINT and intelligence support. | Intelligence Analyst, Radio/SIGINT, IT Admin | Manual analysis, lookup tables |
| 32 | IT-Tools | Server-2 | 8102 | **Developer utilities** — UUID, hash, JWT, base64, cron, network tools for system maintenance. | IT Admin | Command-line tools |
| 33 | Stirling-PDF | Server-2 | 8103 | **PDF toolkit** — merge, split, OCR, convert found documents. | Records Clerk, Intelligence Analyst | Manual transcription |
| 34 | LibreTranslate | Server-2 | 8115 | **Machine translation** — 30+ languages, no cloud dependency. For found documents, refugees, trade contacts. | Intelligence Analyst, Community Director | Bilingual community members, dictionaries |
| 35 | LanguageTool | Server-2 | 8114 | **Grammar/spell check** — for official documents, governance records, trade agreements. | Records Clerk, Judge | Proofreading |
| 36 | Super-Deredactor | Server-2 | 9110 | **Document forensics** — 4-engine OCR consensus, redaction detection, intelligence extraction. | Intelligence Analyst | Manual document analysis |
| 37 | Manticore Search | Server-2 | 8120 | **Full-text search** — cross-service search engine for ARCstore content. | All roles via Searchhead | Individual service search |
| 38 | Homebox | Server-2 | 8107 | **Home inventory** — asset tracking, warranty info, QR labels for community property. | Logistics Officer, Salvage Coordinator | Paper asset registry |
| 39 | OpenBoxes | Server-2 | 8119 | **Supply chain** — warehouse management, procurement tracking, fulfillment for trade goods. | Logistics Officer | Paper ledger |
| 40 | Syncthing | Server-2 | 8117 | **File sync** — peer-to-peer encrypted sync between terminals and field devices. | IT Admin | USB drive transfer |
| 41 | F-Droid Server | Server-1 | 8070 | **Mobile apps** — 1018 offline Android apps for field devices (GPS, compass, field guides). | IT Admin, field roles | Pre-installed apps |
| 42 | Trilium Notes | Server-2 | 8133 | **Note-taking** — hierarchical notes for meeting minutes, personal logs, research. | Community Director, all leaders | Paper notebooks |
| 43 | TimeTagger | Server-2 | 8106 | **Time tracking** — labor allocation tracking, work hour records for fair rotation. | HR Manager | Paper timesheets |
| 44 | Monica | Server-2 | 8174 | **Personal CRM** — community member tracking, relationship management, welfare checks. | HR Manager, Childcare/Welfare | Paper contact cards |
| 45 | FreshRSS | Server-2 | 8170 | **Feed reader** — pre-collapse: news aggregation. Post-collapse: monitor mesh network bulletins. | Intelligence Analyst | Manual radio monitoring |
| 46 | Anki Sync | Server-2 | 8143 | **Flashcard sync** — spaced repetition for cross-training, language learning, medical study. | Educator, all trainees | Physical flashcards |
| 47 | tar1090 | Server-2 | 8108 | **ADS-B tracking** — aircraft detection and mapping. Early warning for aerial approaches. | Radio/SIGINT, Security Chief | Visual/audio spotting |
| 48 | OpenWebRX+ | Server-2 | 8113 | **Software-defined radio** — web-based receiver, waterfall display, signal analysis. | Radio/SIGINT, Radio Operator | Dedicated SDR hardware |
| 49 | WiFi QR Codes | Server-1 | 8889 | **Network onboarding** — QR codes for WiFi connection, reducing IT support burden. | IT Admin | Manual WiFi config |

---

## Tier 4 — Rebuild Capabilities (P3)

Long-term civilization reconstruction. Not needed for immediate survival but critical for rebuilding.

| # | Service | Host | Port | ARC Purpose | Primary Roles | Fallback |
|---|---------|------|------|-------------|---------------|----------|
| 50 | Corpus Juris (planned) | — | — | **Legal reference** — US law, governance templates, conflict resolution frameworks. "Wasteland Judge." | Judge, Community Director | Printed constitution, common law |
| 51 | Firefly III | Server-2 | 8172 | **Trade ledger** — transaction tracking for inter-community trade, resource valuation. | Treasurer | Paper ledger, barter records |
| 52 | Actual Budget | Server-2 | 8171 | **Community budget** — resource allocation, envelope-style planning for limited supplies. | Treasurer | Paper budget sheets |
| 53 | Wiki.js | Server-2 | 8131 | **Governance records** — community constitution, laws, meeting minutes, institutional knowledge. | Judge, Records Clerk, Community Director | Paper records, oral tradition |
| 54 | Part-DB | Server-2 | 8109 | **Electronics database** — component catalog, datasheets, storage locations for electronics repair. | Electrician, IT Admin | Paper datasheet binders |
| 55 | Tube Archivist | Server-2 | 8141 | **Video archive** — instructional videos, how-to guides, training content preserved offline. | Educator, all roles | Live demonstrations |
| 56 | Digital Library | Server-1 | 8084 | **Ebook search** — FastAPI search across ebook collection, download manager. | All roles | Browse Calibre-Web directly |
| 57 | ArchiveBox | Server-2 | 8112 | **Web archive** — pre-collapse web pages preserved for reference (guides, forums, documentation). | Records Clerk, all roles | Kiwix ZIM files |
| 58 | X-Bookmarks Archive | Server-2 | 8082 | **OSINT archive** — 248 bookmarks, 242 context pages, 82 knowledge files from pre-collapse research. | Intelligence Analyst | Other reference sources |
| 59 | Retro OS Museum | Server-2 | 8888 | **Computing preservation** — vintage OS environments for understanding legacy systems. | IT Admin, Educator | Physical hardware |
| 60 | Video Archival | Server-1 | 8080 | **ZIM builder** — youtube2zim pipeline for creating new offline video archives. | IT Admin, Records Clerk | Manual download and storage |

---

## Infrastructure — Always-On

Not user-facing. These services support all other tiers and run continuously.

### Network Fabric

| # | Service | Host | Port | ARC Purpose | Fallback |
|---|---------|------|------|-------------|----------|
| 61 | managed L2 switch (48-port GbE, 4x SFP) (switch-1) | switch-1 | — | **Network backbone** — 48-port managed switch, 7 VLANs, LACP trunks. All wired connectivity. | Direct cable connections, no VLAN isolation |
| 62 | CyberPower UPS | FIREWALL | 3493 | **Power protection** — NUT monitored, ~18 min runtime for graceful shutdown. | Generator immediate-start, hard shutdown |
| 63 | ASUS wireless access point | AP | 8443 | **WiFi access** — 4 SSIDs across 4 VLANs for wireless terminals and field devices. | Wired connections only |
| 64 | WireGuard VPN | FIREWALL | 51820 | **Remote access** — tunnel for field nodes, remote admin. Post-collapse: mesh relay. | Physical access only |
| 65 | Suricata IDS | FIREWALL | — | **Intrusion detection** — ET Open ruleset, alerts on anomalous traffic (insider threats, compromised devices). | Manual log review |
| 66 | VLAN Segmentation | switch-1/FIREWALL | — | **Network security** — 7 VLANs isolating management, servers, workstations, IoT, VoIP. | Flat network (reduced security) |
| 67 | NFS Shared Storage | workstation/Server-1 | 2049 | **File sharing** — NFSv4.2 for video-archival and digital-library staging between hosts. | USB drive transfer |
| 68 | PXE Boot | workstation | 69 | **Network boot** — dnsmasq TFTP for imaging new/replacement terminals. | USB boot media |
| 69 | UPS Protection | FIREWALL | — | **Graceful shutdown** — NUT orchestration for clean poweroff sequence across all hosts. | Manual shutdown |

### Identity & DNS

| # | Service | Host | Port | ARC Purpose | Fallback |
|---|---------|------|------|-------------|----------|
| 70 | Active Directory (DC1) | DC1 | 389 | **Primary directory** — user accounts, group membership, machine auth. Foundation of role-gating. | Local accounts, LDAP fallback to DC2 |
| 71 | Active Directory (DC2) | DC2 | 389 | **Directory replica** — redundant AD for high availability. | DC1 primary |
| 72 | Unbound DNS | FIREWALL | 53 | **Primary DNS** — local resolution for all *.lab.example.com services. | Hosts files, DC1/DC2 fallback |
| 73 | Kea DHCP | FIREWALL | 67 | **IP assignment** — DHCP for all VLANs, pushes DNS servers and search domains. | Static IP assignment |
| 74 | LDAP Account Manager | Server-2 | 8890 | **AD management UI** — user provisioning, group membership changes without PowerShell. | PowerShell on DC1/DC2 |
| 75 | Central Proxy | Server-2 | 8443 | **Reverse proxy** — nginx + Authentik forward-auth, single entry point for all web services. | Direct service access by port |

### Monitoring Stack

| # | Service | Host | Port | ARC Purpose | Fallback |
|---|---------|------|------|-------------|----------|
| 76 | Loki | Server-2 | 3100 | **Log aggregation** — centralized logs from all hosts via Alloy. | journalctl on individual hosts |
| 77 | Alloy | Server-2 | 1514 | **Log shipping** — journald + syslog collection, forwards to Loki. | Direct log access |
| 78 | Alertmanager | Server-2 | 9093 | **Alert routing** — routes Prometheus alerts to ntfy/email/TTS. | Manual Grafana monitoring |
| 79 | node_exporter (Server-1) | Server-1 | 9100 | **System metrics** — CPU, memory, disk, network for Server-1. | Manual `top`/`df` checks |
| 80 | node_exporter (Server-2) | Server-2 | 9100 | **System metrics** — CPU, memory, disk, network for Server-2. | Manual `top`/`df` checks |
| 81 | node_exporter (workstation) | workstation | 9100 | **System metrics** — CPU, memory, disk, network for workstation. | Manual `top`/`df` checks |
| 82 | ipmi_exporter | Server-2 | 9290 | **BMC metrics** — temperatures, fans, power draw from IMM/iLO. | Manual BMC console checks |
| 83 | snmp_exporter | Server-2 | 9116 | **Network metrics** — switch port stats, firewall interface stats via SNMPv3. | Manual switch console |
| 84 | nut_exporter | Server-2 | 9199 | **UPS metrics** — battery charge, load, voltage, runtime. | Manual UPS LCD panel |
| 85 | blackbox_exporter | Server-2 | 9115 | **ICMP probes** — gateway and external reachability (pre-collapse). | Manual ping |
| 86 | speedtest_exporter | Server-2 | 9192 | **WAN bandwidth** — 5-minute interval speed tests (pre-collapse only). | Manual speedtest |
| 87 | asterisk_exporter | pbx-1 | 9200 | **PBX metrics** — call channels, registrations, SIP trunk status. | Manual `asterisk -r` |
| 88 | ilo_power_exporter | Server-2 | 9417 | **Power metrics** — HP iLO 3 RIBCL scrape for Server-2 power draw. | Manual iLO console |
| 89 | asus_wifi_exporter | Server-2 | 9193 | **WiFi metrics** — client counts, signal strength, bandwidth via SSH. | Manual WiFi admin panel |

### Out-of-Band Management

| # | Service | Host | Port | ARC Purpose | Fallback |
|---|---------|------|------|-------------|----------|
| 90 | FIREWALL IMM | firewall-imm | 443 | **FIREWALL remote console** — IPMI power control, SOL console, hardware status. | Physical console |
| 91 | Server-1 IMM | server-1-imm | 443 | **Server-1 remote console** — IPMI power control, VGA text console. | Physical console |
| 92 | Server-2 iLO | server-2-ilo | 80 | **Server-2 remote console** — IPMI power control, KVM, virtual serial port. | Physical console |

### Developer & Operational Tools

| # | Service | Host | Port | ARC Purpose | Fallback |
|---|---------|------|------|-------------|----------|
| 93 | Gitea | Server-2 | 8084 | **Source control & issues** — 62 repos, issue tracking, lab project management. | File-based version control |
| 94 | Zot OCI Registry | Server-2 | 5000 | **Container images** — pull-through cache, offline container image store. | Manual image transfer |
| 95 | Postfix MTA | Server-2 | 25 | **Email relay** — Alertmanager notification delivery (pre-collapse). | ntfy, XMPP |
| 96 | Qwen3-TTS | workstation | 8080 | **Voice notifications** — AI-generated speech alerts for hands-free operation. | Text alerts, manual reading |
| 97 | HALops | workstation | — | **Fine-tuned lab agent** — Qwen2.5-7B SFT model for operational assistance. ARCengine prototype. | General-purpose LLM |

### Services Not Counted (suspended/design-only)

| Service | Status | Notes |
|---------|--------|-------|
| ExampleOrg Viewer | Suspended | Blocked on Twilio SMS 2FA migration |
| Proxy Gateway | Pre-collapse only | Tor SOCKS5 proxy — useless without internet |
| WiFi Capture | Diagnostic tool | Packet capture — used only for troubleshooting |
| Lab Softphone | Derivative | WebRTC client for FreePBX (counted under FreePBX) |
| SIP Phones (x3) | Hardware | Grandstream GXP1630, Cisco 7942G, Cisco 7945G — endpoints, not services |
| Lab Documentation | Meta | MkDocs site about the lab itself |
| Archivist | Design phase | Corpus management dashboard (workstation) — not deployed |

---

## Service-to-Role Matrix Summary

| Group | Most-Used Services (top 5) |
|-------|---------------------------|
| Food & Water | Kiwix, Grocy, Tandoor, FarmOS, Calibre-Web |
| Shelter & Facilities | Kiwix, Manyfold/3D Search, InvenTree, Vikunja, Homebox |
| Energy & Power | Kiwix, Home Assistant, Grafana, Calibre-Web, Vikunja |
| Protection & Security | Frigate, Atlas, FreePBX, Cannery, ntfy |
| Administration | OpenEMR, Paperless-ngx, Wiki.js, Taiga, Nextcloud |
| Specialized Services | Moodle, FreePBX, Kiwix, FarmOS, Grafana |

---

## Host Load Summary

| Host | Service Count | Role | RAM | Criticality |
|------|--------------|------|-----|-------------|
| Server-2 | 56 | Primary app server | 128 GB | Highest — loss affects all tiers |
| Server-1 | 10 | Knowledge/media server | 64 GB | High — Kiwix, Atlas, Calibre, Manyfold |
| FIREWALL | 8 | Network edge | 16 GB | Critical — DNS, DHCP, routing, VPN |
| workstation | 5 | Admin/ARCengine | 64 GB | Medium — GPU inference, TTS, Archivist |
| pbx-1 | 2 | Voice comms | 4 GB | High — FreePBX, asterisk_exporter |
| switch-1 | 1 | Network fabric | — | Critical — all wired connectivity |
| DC1/DC2 | 2 | Directory | 4 GB ea | Critical — authentication for all services |

**Risk:** Server-2 hosts 56 of 97 services. Server-2 failure is a catastrophic event affecting every tier.
