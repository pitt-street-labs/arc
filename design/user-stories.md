# ARC User Stories

**Assisted Reconstitution of Civilization — Capability Requirements**

## Purpose

This document defines what the ARC provides, who uses it, why it matters, and what must be true for each capability to work. It is written for the people who will live in the ARC — not just the engineers who build it.

The ARC is a self-sufficient, off-grid environment designed to sustain a Dunbar group (~150 people) after a societal collapse. It combines solar power, diesel backup, battery storage, mesh communications, offline knowledge, medical capability, food production, manufacturing, and governance into a single integrated system.

The reference homelab is a working prototype. Every story in this document either maps to a service running today or identifies a gap that must be closed.

## How to Read This Document

Each story follows a hybrid format:

1. **Scenario** — A short narrative. A real person doing a real thing. No jargon.
2. **User story** — The formal "As a / I want / So that" decomposition.
3. **Acceptance criteria** — Observable outcomes. If these are true, the capability works.
4. **Prerequisites** — What systems, hardware, or integrations must exist.
5. **Lab mapping** — Which reference lab services fulfill this today, if any.

### Priority Matrix

Every story carries two ratings:

**Survival Criticality** — What happens if this capability doesn't exist?

| Rating | Meaning | Example |
|--------|---------|---------|
| **P0** | **Life-threatening** — People die or are seriously harmed | Medical reference, power, water |
| **P1** | **Mission-critical** — Serious degradation of the group's ability to function | Communications, networking, food tracking |
| **P2** | **Quality of life** — Important for morale, education, productivity, long-term thriving | Music, education, recipes |
| **P3** | **Civilization rebuild** — Enables governance, justice, trade, manufacturing, cultural preservation | Voting, legal AI, inter-site trade |

**Implementation Readiness** — How close is this to working?

| Rating | Meaning | Example |
|--------|---------|---------|
| **R0** | **Working today** — Fully operational in the lab | Kiwix, FreePBX, Vaultwarden |
| **R1** | **Partially ready** — Components exist but need integration or hardware | OpenEMR (deployed, needs clinical data) |
| **R2** | **Designed** — Architecture documented, no implementation | Frigate NVR, Reticulum mesh |
| **R3** | **Conceptual** — Idea stage, needs design work | Solar array, water monitoring |

### Glossary

| Term | Meaning |
|------|---------|
| **ARC** | Assisted Reconstitution of Civilization — the complete self-sufficient environment |
| **HAL** | Hardware Abstraction Layer — the bootable USB/drive containing the full ARC software stack |
| **Dunbar group** | ~150 people — the upper limit of stable social relationships |
| **Mesh** | A radio network where every node can relay messages, with no central tower required |
| **ZIM** | A compressed offline archive format (used for Wikipedia, StackExchange, etc.) |
| **Quadlet** | A systemd-native way to run containers that auto-restarts on failure |
| **Enterprise CA** | The lab's own certificate authority for secure (HTTPS) connections |
| **VLAN** | Virtual LAN — network segmentation that isolates traffic types |

---

## Summary Matrix

| # | Title | P | R | Category |
|---|-------|---|---|----------|
| US-01 | Emergency medical reference lookup | P0 | R0 | Health |
| US-02 | Solar array powers critical systems through the night | P0 | R3 | Power |
| US-03 | Diesel generator auto-starts on battery low | P0 | R3 | Power |
| US-04 | Perimeter intrusion detected on camera | P0 | R2 | Security |
| US-05 | Emergency radio broadcast reaches all mesh nodes | P0 | R2 | Comms |
| US-06 | Electronic medical record for patient tracking | P0 | R1 | Health |
| US-07 | Weather alert warns of severe incoming storm | P0 | R2 | Safety |
| US-08 | Password vault survives power loss and reboots | P0 | R0 | Security |
| US-09 | UPS keeps servers alive during generator switchover | P0 | R3 | Power |
| US-10 | Water system monitoring and contamination alert | P0 | R3 | Safety |
| US-11 | VoIP phone call between two ARC buildings | P1 | R0 | Comms |
| US-12 | Mesh text message sent to a field team 2km away | P1 | R2 | Comms |
| US-13 | Offline map with routing for supply run planning | P1 | R0 | Navigation |
| US-14 | Grocery and food inventory tracked after harvest | P1 | R0 | Food |
| US-15 | Farm plot and livestock tracked through seasons | P1 | R1 | Agriculture |
| US-16 | Network intrusion detected and blocked by IDS | P1 | R0 | Security |
| US-17 | VPN tunnel connects remote ARC site | P1 | R0 | Comms |
| US-18 | All services authenticate through single sign-on | P1 | R0 | Identity |
| US-19 | Ammunition and defensive supply inventory | P1 | R0 | Security |
| US-20 | Push notification alerts operators to service failure | P1 | R0 | Monitoring |
| US-21 | Document scanned, OCR'd, and archived | P1 | R0 | Records |
| US-22 | AI assistant answers a practical question offline | P1 | R1 | AI |
| US-23 | Container service auto-restarts after crash | P1 | R0 | Infra |
| US-24 | DNS resolves even if primary resolver fails | P1 | R0 | Infra |
| US-25 | Shared file storage syncs between ARC workstations | P1 | R0 | Storage |
| US-26 | Student completes a lesson on the LMS | P2 | R1 | Education |
| US-27 | Resident looks up a Wikipedia article offline | P2 | R0 | Knowledge |
| US-28 | Mechanic searches 3D models for a replacement part | P2 | R0 | Manufacturing |
| US-29 | 3D printer produces a replacement bracket overnight | P2 | R1 | Manufacturing |
| US-30 | Family watches an archived educational video | P2 | R0 | Media |
| US-31 | Cook plans meals for the week with available inventory | P2 | R0 | Food |
| US-32 | Resident listens to music on community speakers | P2 | R0 | Media |
| US-33 | Gardener logs plant health and watering schedule | P2 | R0 | Agriculture |
| US-34 | Child studies with flashcards on a tablet | P2 | R1 | Education |
| US-35 | Resident reads an ebook on a shared tablet | P2 | R0 | Knowledge |
| US-36 | Translator converts a found foreign document | P2 | R1 | Tools |
| US-37 | Resident tracks personal finances and barter ledger | P2 | R0 | Finance |
| US-38 | Resident manages personal health records | P2 | R1 | Health |
| US-39 | Team tracks project tasks on a kanban board | P2 | R0 | Productivity |
| US-40 | Resident uses CyberChef to decode a found data format | P2 | R0 | Tools |
| US-41 | Council resolves a property dispute using legal AI | P3 | R2 | Governance |
| US-42 | Technician installs F-Droid apps on community phones | P3 | R0 | Software |
| US-43 | New ARC site receives a seeded HAL drive | P3 | R2 | Expansion |
| US-44 | Mesh network bridges two ARC sites 10km apart | P3 | R2 | Comms |
| US-45 | Historian archives community decisions and events | P3 | R0 | Records |
| US-46 | Electronics tech finds a part spec in Part-DB | P3 | R0 | Manufacturing |
| US-47 | Community votes on resource allocation policy | P3 | R3 | Governance |
| US-48 | Operator fine-tunes the AI on local knowledge | P3 | R1 | AI |
| US-49 | ARC time-capsule backup written to cold storage | P3 | R1 | Preservation |
| US-50 | Inter-ARC trade ledger synchronized over mesh | P3 | R3 | Finance |

---

## P0 — Life-Threatening

These capabilities prevent death or serious harm. Their absence is not acceptable.

---

### US-01: Emergency Medical Reference Lookup
**Priority:** P0/R0 | **Category:** Health

> **Scenario:** Marcus, the ARC's medic, is treating a child with a high fever and a rash he doesn't recognize. He opens Kiwix on the clinic tablet, searches the offline Wikipedia medical articles, and finds the differential diagnosis for scarlet fever — including the antibiotic dosage from the WHO Essential Medicines list. He cross-references with a PDF from the ebook library. The child gets the right treatment within the hour.

**As a** medic, **I want** to search offline medical references instantly, **so that** I can diagnose and treat patients even without internet access.

**Acceptance Criteria:**
- [ ] Medical articles (Wikipedia Medicine, WHO references) are searchable offline
- [ ] Search returns results in under 3 seconds on the clinic workstation
- [ ] Drug interaction and dosage information is available for common medications
- [ ] The reference library includes at least emergency medicine, pediatrics, trauma, and infectious disease
- [ ] Content is updated at least annually when connectivity is available

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Kiwix with medical ZIM archives | software | live |
| Digital Library with medical ebooks | software | live |
| Clinic workstation or tablet with network access | hardware | live |
| Wikipedia Medicine ZIM (downloaded) | data | live |

**Lab Mapping:** Kiwix (Server-1:8888) — offline Wikipedia, StackExchange, medical ZIMs. Calibre-Web (Server-1:8083) and Digital Library (Server-1:8084) — ebook collection including medical references.

---

### US-02: Solar Array Powers Critical Systems Through the Night
**Priority:** P0/R3 | **Category:** Power

> **Scenario:** It's 2 AM and the ARC has been running on solar-charged batteries since sunset. The battery bank is at 43% — well above the 20% threshold that triggers the diesel generator. The servers, clinic refrigerator, perimeter cameras, and radio repeater all stay powered. Elena, on night watch, glances at the power dashboard on her tablet and sees eight more hours of battery remaining at current load. She doesn't touch anything. The system just works.

**As a** facility operator, **I want** the solar array and battery bank to power all critical systems from sunset to sunrise, **so that** essential services never go offline due to power loss.

**Acceptance Criteria:**
- [ ] Solar panels charge battery bank to full capacity during a typical sunny day
- [ ] Battery bank sustains critical load (servers, clinic, comms, security) for at least 12 hours without sun
- [ ] Charge controller prevents battery over-discharge (cutoff at 20% SoC)
- [ ] Power dashboard shows real-time generation, consumption, and battery state of charge
- [ ] Non-critical loads (media, 3D printing) are automatically shed when battery drops below 40%

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Solar panel array (sized for load + reserve) | hardware | conceptual |
| Battery bank (LiFePO4 or lead-acid) | hardware | conceptual |
| MPPT charge controller(s) | hardware | conceptual |
| Pure sine wave inverter(s) | hardware | conceptual |
| Power monitoring integration (Home Assistant / Grafana) | software | partial |
| Automatic load shedding relay panel | hardware | conceptual |

**Lab Mapping:** Home Assistant (Server-2:8145) is deployed and could integrate solar monitoring via Modbus/MQTT. Grafana (Server-2:3000) and Prometheus (Server-2:9091) provide the dashboard and metrics infrastructure. No solar hardware exists yet.

---

### US-03: Diesel Generator Auto-Starts on Battery Low
**Priority:** P0/R3 | **Category:** Power

> **Scenario:** Three consecutive overcast days have drained the battery bank to 25%. At 22% SoC, the automatic transfer switch (ATS) sends the start signal to the diesel generator. It cranks, catches, and stabilizes within 15 seconds. The ATS switches the critical bus to generator power while the charger begins replenishing the batteries. A push notification reaches every operator's phone: "Generator auto-started. Battery at 22%. Fuel: 72 hours remaining." Nobody had to leave their post.

**As a** facility operator, **I want** the diesel generator to start automatically when battery charge drops below a safe threshold, **so that** critical systems remain powered during extended low-solar periods.

**Acceptance Criteria:**
- [ ] Generator auto-starts when battery SoC drops below configurable threshold (default 22%)
- [ ] Automatic transfer switch transitions load within 30 seconds
- [ ] Generator charges batteries while powering critical loads
- [ ] Fuel level is monitored and alerts sent when below 48 hours remaining
- [ ] Generator auto-stops when batteries reach 80% SoC (to conserve fuel)
- [ ] Manual override is available for both start and stop

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Diesel generator (sized for critical load + charging) | hardware | conceptual |
| Automatic transfer switch (ATS) | hardware | conceptual |
| Fuel tank with level sensor | hardware | conceptual |
| Generator controller with remote start/stop | hardware | conceptual |
| Monitoring integration (SNMP/Modbus → Prometheus) | software | partial |
| ntfy push notification for operator alerts | software | live |

**Lab Mapping:** ntfy (Server-2:8150) handles push notifications. Prometheus/Grafana provide metrics/dashboards. No generator or ATS hardware exists.

---

### US-04: Perimeter Intrusion Detected on Camera
**Priority:** P0/R2 | **Category:** Security

> **Scenario:** At 3:17 AM, a motion-triggered camera on the north fence line captures two figures approaching with flashlights. Frigate NVR's object detection classifies them as "person" and sends an alert to the night watch operator's phone via ntfy. She pulls up the live feed on the security station monitor, confirms the intrusion, and activates the compound alarm. The recording is automatically saved with a 30-second pre-buffer. By the time the response team arrives at the fence, they have a clear image of the intruders' approach vector.

**As a** security watch operator, **I want** perimeter cameras to automatically detect and alert on human intrusion, **so that** the compound can respond to threats before they breach the perimeter.

**Acceptance Criteria:**
- [ ] Cameras cover all perimeter approach vectors with overlapping fields of view
- [ ] Object detection distinguishes people from animals with >90% accuracy
- [ ] Alert delivered to operator within 10 seconds of detection
- [ ] Pre-event buffer captures at least 30 seconds before the trigger
- [ ] Recordings are retained for at least 30 days
- [ ] System operates in complete darkness (IR illumination)

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| PoE IP cameras (IR, outdoor-rated) | hardware | planned |
| PoE network switch for camera VLAN | hardware | planned |
| Frigate NVR with object detection | software | planned |
| ntfy push notification integration | software | live |
| Dedicated camera VLAN (isolated from servers) | infra | planned |
| Storage for 30-day retention (~2TB per camera) | hardware | planned |

**Lab Mapping:** Frigate NVR (Server-2) has a services.yaml entry and health check endpoint defined. ntfy (Server-2:8150) is live for alerting. Home Assistant (Server-2:8145) can serve as automation hub. No cameras or PoE infrastructure deployed yet.

---

### US-05: Emergency Radio Broadcast Reaches All Mesh Nodes
**Priority:** P0/R2 | **Category:** Comms

> **Scenario:** A flash flood warning needs to reach every ARC member immediately — including the three-person foraging team 1.5 km upstream. The operations center operator types the emergency message into the LXMF broadcast interface. The message propagates through the Reticulum mesh network: from the hub node to the rooftop relay, to the hilltop repeater, to each team member's Meshtastic radio. Within 90 seconds, every mesh node in range has received the alert. The foraging team begins moving to high ground.

**As an** operations center operator, **I want** to broadcast emergency messages to all mesh nodes simultaneously, **so that** every ARC member receives critical warnings regardless of their location.

**Acceptance Criteria:**
- [ ] Emergency broadcast reaches all mesh nodes within 2 minutes
- [ ] Coverage radius of at least 3 km from the hub in open terrain
- [ ] Messages are received on handheld radios without requiring a phone
- [ ] Broadcast is prioritized over normal mesh traffic
- [ ] Offline — no internet or cell service required
- [ ] Message acknowledgment from each node is logged

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Reticulum mesh hub (containerized) | software | designed |
| LXMF relay for message propagation | software | designed |
| LoRa gateway node(s) for RF coverage | hardware | planned |
| Meshtastic-compatible handheld radios (per team) | hardware | partial |
| Hilltop/rooftop repeater for range extension | hardware | planned |
| Reticulum ↔ Meshtastic bridge | integration | designed |

**Lab Mapping:** Reticulum stack is designed (see `memory/reticulum-stack.md`). Meshtastic/MeshCore research is active (`~/projects/offgrid-comms/`). No deployed mesh nodes yet. Baofeng UV-5R/UV-82 and Quansheng UV-K5 radios available for voice but not data mesh.

---

### US-06: Electronic Medical Record for Patient Tracking
**Priority:** P0/R1 | **Category:** Health

> **Scenario:** Dr. Chen sees 12 patients today at the ARC clinic. For each one, she opens OpenEMR on the clinic workstation, reviews their history, records vitals, updates medications, and notes her assessment. When Marcus the medic treats a laceration that evening, he pulls up the patient's record to check for allergies and tetanus vaccination status. The record is there, complete, and current. No paper charts to lose. No guessing about medication interactions.

**As a** medical provider, **I want** a complete electronic medical record system, **so that** patient history, medications, allergies, and treatment records are always accessible to authorized caregivers.

**Acceptance Criteria:**
- [ ] Patient demographics, allergies, medications, and problem list are stored electronically
- [ ] Multiple providers can access the same patient record concurrently
- [ ] Vital signs (BP, HR, temp, SpO2, weight) can be recorded and trended over time
- [ ] Prescription and medication tracking with interaction warnings
- [ ] Access is restricted to authorized medical personnel (SSO role-based)
- [ ] Records survive server reboots and power cycles

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| OpenEMR deployment | software | live |
| Authentik SSO integration | integration | partial |
| Clinical data templates (encounter types, vitals forms) | data | planned |
| Clinic workstation with network access | hardware | live |
| Backup strategy for medical records | infra | partial |

**Lab Mapping:** OpenEMR (Server-2:8160) is deployed behind central-proxy with Authentik SSO. The application is running but has not been configured with clinical templates, provider accounts, or patient data. Rated R1 because the software is live but not clinically ready.

---

### US-07: Weather Alert Warns of Severe Incoming Storm
**Priority:** P0/R2 | **Category:** Safety

> **Scenario:** A severe thunderstorm warning is issued by NOAA for the county. The ARC's NWR (NOAA Weather Radio) receiver picks up the SAME-encoded alert on 162.475 MHz. The decoding software identifies the alert type (Severe Thunderstorm Warning), affected area, and duration. A push notification goes to all operators: "SVR TSTM WARNING until 1845. Expected: 60mph winds, quarter-size hail. Secure outdoor equipment." The garden crew begins covering the raised beds.

**As a** facility operator, **I want** automatic weather alert monitoring and notification, **so that** the ARC can prepare for severe weather before it arrives.

**Acceptance Criteria:**
- [ ] NWR receiver monitors local NOAA Weather Radio frequency continuously
- [ ] SAME (Specific Area Message Encoding) alerts are decoded automatically
- [ ] Alert type, severity, affected area, and duration are extracted and displayed
- [ ] Push notification sent to all operators within 30 seconds of reception
- [ ] Alert history is logged for pattern analysis
- [ ] System operates without internet (RF-based)

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| NWR antenna (162 MHz, ~$15) | hardware | planned |
| NWR receiver (RTL-SDR or dedicated) | hardware | partial |
| SAME decoding software | software | designed |
| ntfy push notification integration | software | live |
| Weather dashboard in Grafana | software | partial |

**Lab Mapping:** NooElec NESDR SMArt SDR is available for RF reception (`~/projects/sdr/`). ntfy (Server-2:8150) handles push notifications. Weather Mesh project (`~/projects/weather-mesh/`) has designed the NWR/SAME + GOES architecture. RTL-SDR hardware exists but is not deployed for weather monitoring.

---

### US-08: Password Vault Survives Power Loss and Reboots
**Priority:** P0/R0 | **Category:** Security

> **Scenario:** A thunderstorm takes out power for 40 minutes. When the generator kicks in and systems come back online, the operations team needs to log into six different services to verify the ARC is fully operational. Sarah opens Vaultwarden on her phone, authenticates with her master password, and every credential is exactly where she left it. No corruption. No data loss. The vault survived the unclean shutdown because its data lives on a LUKS-encrypted volume with journaling filesystem, and the Quadlet container auto-restarted when systemd came back up.

**As a** system operator, **I want** the password vault to survive power loss, reboots, and unclean shutdowns without data corruption, **so that** credentials remain accessible after any disruption.

**Acceptance Criteria:**
- [ ] Vault data persists across clean and unclean reboots
- [ ] Container auto-restarts via Quadlet/systemd after power restoration
- [ ] All stored credentials are accessible after restart without manual intervention
- [ ] Vault is accessible from any device on the ARC network (phones, tablets, workstations)
- [ ] Data is encrypted at rest (LUKS volume) and in transit (TLS)
- [ ] Offline backup exists and is tested periodically

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Vaultwarden (Bitwarden-compatible) | software | live |
| Quadlet auto-restart (systemd) | infra | live |
| LUKS-encrypted data volume | infra | live |
| Enterprise CA TLS certificate | infra | live |
| GPG-encrypted offline backup | infra | live |

**Lab Mapping:** Vaultwarden (Server-2:8222) — fully operational. Quadlet-managed, Enterprise CA TLS, LUKS-encrypted volume, SSO via Authentik. Offline backup at `/media/labadmin/external-storage/secrets/<encrypted-credentials-file>`. This capability is fully realized today.

---

### US-09: UPS Keeps Servers Alive During Generator Switchover
**Priority:** P0/R3 | **Category:** Power

> **Scenario:** The main power feed drops without warning — a tree on the power line. The CyberPower UPS immediately takes over, providing clean power to both server racks. The battery has 18 minutes of runtime at current load. The diesel generator starts automatically 15 seconds later (see US-03). After the ATS switches over to generator power, the UPS transitions back to line mode and begins recharging. Total disruption to services: zero. Not a single container restarted. Not a single SSH session dropped.

**As a** system operator, **I want** UPS units to bridge the gap between power loss and generator start, **so that** servers never experience even a momentary power interruption.

**Acceptance Criteria:**
- [ ] UPS provides at least 15 minutes runtime at full server load
- [ ] Transition from line to battery is instantaneous (no gap)
- [ ] NUT (Network UPS Tools) monitors battery state and alerts on low charge
- [ ] Graceful shutdown is triggered if battery reaches critical level without generator
- [ ] UPS health metrics (charge, load, voltage, runtime) are visible in Grafana
- [ ] Multiple UPS units cover both server racks independently

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Rack-mount UPS units (per rack) | hardware | partial |
| NUT server and monitoring | software | live |
| NUT exporter for Prometheus | software | live |
| Graceful shutdown orchestration | integration | partial |
| Grafana UPS dashboard | software | live |

**Lab Mapping:** CyberPower PR1500LCDRT2U UPS exists, monitored by NUT on FIREWALL (usbhid-ups driver). NUT exporter (Server-2:9199) feeds Prometheus. Grafana UPS dashboard shows charge, load, voltage, runtime. Currently covers FIREWALL only — servers (Server-1, Server-2) lack dedicated UPS protection. Rated R3 because the monitoring stack is complete but server-rack UPS hardware is missing.

---

### US-10: Water System Monitoring and Contamination Alert
**Priority:** P0/R3 | **Category:** Safety

> **Scenario:** The ARC's well water passes through a filtration system into a 500-gallon storage tank. A pH sensor and turbidity sensor monitor water quality continuously. At 6:14 AM, the turbidity sensor reads 8 NTU — above the 4 NTU safe threshold. The system immediately closes the supply valve, sends an alert to all operators ("WATER ALERT: High turbidity detected — 8 NTU. Supply valve closed. Do not use tap water until cleared."), and logs the event. The water team inspects the filter and finds a cracked cartridge. After replacement and a clear test reading, they manually reopen the valve.

**As a** facility operator, **I want** continuous water quality monitoring with automatic shutoff and alerts, **so that** contaminated water never reaches ARC residents.

**Acceptance Criteria:**
- [ ] pH, turbidity, and chlorine residual are measured continuously
- [ ] Automatic valve closure when any parameter exceeds safe threshold
- [ ] Push notification to all operators within 60 seconds of detection
- [ ] Manual override available for valve control
- [ ] Sensor readings logged and trended in Grafana
- [ ] Tank level monitoring with low-level alert

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Water quality sensors (pH, turbidity, chlorine) | hardware | conceptual |
| Motorized shutoff valve | hardware | conceptual |
| Sensor controller (Arduino/ESP32 + MQTT) | hardware | conceptual |
| Home Assistant integration for automation | software | live |
| Grafana dashboard for water metrics | software | partial |
| ntfy alerting integration | software | live |

**Lab Mapping:** Home Assistant (Server-2:8145) is deployed and supports MQTT sensor integration. Grafana (Server-2:3000) and Prometheus (Server-2:9091) can visualize sensor data. ntfy (Server-2:8150) handles push alerts. No water monitoring hardware exists.

---

## P1 — Mission-Critical

Loss of these capabilities seriously degrades the group's ability to function.

---

### US-11: VoIP Phone Call Between Two ARC Buildings
**Priority:** P1/R0 | **Category:** Comms

> **Scenario:** Maria in the clinic needs to reach the supply depot about an insulin shipment. She picks up the SIP desk phone on her desk, dials extension 200, and the SIP desk phone in the depot rings. Tom answers. They coordinate the delivery schedule in a 3-minute call. No cell towers. No internet. Just two phones, a PBX, and a VLAN. The call quality is crystal clear because QoS on the switch prioritizes voice traffic over everything else.

**As an** ARC resident, **I want** to make phone calls between buildings using desk phones, **so that** I can communicate instantly without walking across the compound.

**Acceptance Criteria:**
- [ ] SIP phones in each building can call each other by dialing extensions
- [ ] Call quality is clear with no perceptible delay (<150ms latency)
- [ ] QoS prioritizes voice traffic over data traffic
- [ ] Phone system operates without internet connectivity
- [ ] At least one phone per major building (clinic, depot, operations, housing)
- [ ] WebRTC softphone available as backup from any browser

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| FreePBX/Asterisk PBX | software | live |
| SIP desk phones (various manufacturers) | hardware | live |
| VoIP VLAN (200) with QoS | infra | live |
| WebRTC softphone (SIP.js) | software | live |
| TFTP provisioning for SIP desk phones | infra | live |

**Lab Mapping:** FreePBX (pbx-1:80) — PBX distribution, Asterisk, extensions 100/200/300/702. SIP desk phone (model A) (ext 100), SIP desk phone (model B) (ext 200), SIP desk phone (model C) (ext 300). Lab Softphone (portal:8443/softphone) — browser-based WebRTC (ext 702). VLAN 200 with QoS. Fully operational.

---

### US-12: Mesh Text Message Sent to a Field Team 2km Away
**Priority:** P1/R2 | **Category:** Comms

> **Scenario:** A supply team is harvesting timber 2 km east of the compound. The operations center needs to recall them — a storm is approaching (see US-07). The operator sends an LXMF message through the Reticulum mesh: "Return to compound. Storm ETA 45 min." The message hops from the hub to the hilltop repeater to the team leader's Meshtastic radio. She reads the message on the radio's screen, acknowledges it, and the team starts packing up. Total time from send to acknowledgment: 47 seconds.

**As an** operations center operator, **I want** to send text messages to field teams via mesh radio, **so that** I can communicate with people beyond voice range who have no cell service.

**Acceptance Criteria:**
- [ ] Text messages are sent and received over mesh radio (no internet or cell)
- [ ] Reliable delivery at 2+ km in open terrain
- [ ] Message acknowledgment confirms receipt
- [ ] Messages queue and retry if the recipient is temporarily out of range
- [ ] Works with handheld radios (no phone required for receiving)
- [ ] Message history is logged at the hub

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Reticulum mesh hub | software | designed |
| LXMF message relay | software | designed |
| LoRa radio nodes (Meshtastic/MeshCore) | hardware | partial |
| Hilltop/rooftop repeater | hardware | planned |
| Reticulum ↔ Meshtastic bridge | integration | designed |

**Lab Mapping:** Reticulum stack designed but not deployed. Meshtastic research active in `~/projects/offgrid-comms/`. Handheld radios (Baofeng, Quansheng) available for voice but not yet configured for data mesh.

---

### US-13: Offline Map with Routing for Supply Run Planning
**Priority:** P1/R0 | **Category:** Navigation

> **Scenario:** Jake needs to plan a supply run to an abandoned hardware store 15 km away. He opens Atlas on the operations workstation and searches for the address. The offline map shows the route — including a bridge that's marked as damaged from a previous recon note. He drags the route to avoid the bridge, adding 3 km but keeping to paved roads. He prints the route card with turn-by-turn directions, distance, and estimated travel time. The supply team departs with a paper map and a plan.

**As a** logistics coordinator, **I want** offline maps with routing and search, **so that** I can plan supply runs and navigation without internet access.

**Acceptance Criteria:**
- [ ] Detailed street-level map of the local region is available offline
- [ ] Turn-by-turn routing between any two points
- [ ] Address and place-name search (geocoding)
- [ ] Route can be manually modified to avoid obstacles
- [ ] Satellite imagery overlay available for terrain assessment
- [ ] Map is printable for field use

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Atlas mapping stack (vector tiles, routing, geocoding) | software | live |
| OpenStreetMap data (regional extract) | data | live |
| Satellite imagery tiles | data | live |
| Martin tile server + VALHALLA routing | software | live |
| Photon geocoder | software | live |

**Lab Mapping:** Atlas (Server-1:8090) — complete offline mapping stack with 7 containers: vector tiles (OpenMapTiles), routing (Valhalla), geocoding (Photon), satellite tiles, contour lines, Martin overlays. Fully operational.

---

### US-14: Grocery and Food Inventory Tracked After Harvest
**Priority:** P1/R0 | **Category:** Food

> **Scenario:** The garden crew just harvested 40 kg of tomatoes, 15 kg of peppers, and 8 kg of herbs. Rosa, the kitchen manager, opens Grocy on her tablet and scans the barcode labels she printed last week. She enters the quantities. Grocy updates the stock levels, adjusts the expiration tracking (tomatoes: 7 days, peppers: 14 days), and flags that they now have enough tomatoes for this week's meal plan but the canning crew should preserve the surplus. The cook checks Tandoor for recipes that use the available ingredients.

**As a** kitchen manager, **I want** to track all food inventory including harvests, consumption, and expiration, **so that** nothing spoils and meals can be planned with what's actually available.

**Acceptance Criteria:**
- [ ] All food items tracked with quantity, location, and expiration date
- [ ] Barcode/QR scanning for rapid inventory entry
- [ ] Expiration alerts warn before food spoils
- [ ] Inventory levels visible to kitchen staff and garden crew
- [ ] Integration with meal planning (Tandoor recipes reference available stock)
- [ ] Consumption tracking shows usage patterns over time

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Grocy (household/inventory management) | software | live |
| Tandoor Recipes (meal planning) | software | live |
| Barcode scanner or phone camera | hardware | live |
| Network-connected tablet for kitchen | hardware | live |

**Lab Mapping:** Grocy (Server-2:8104) — grocery tracking, inventory, chore management. Tandoor Recipes (Server-2:8144) — recipe management and meal planning. Both deployed behind Authentik SSO.

---

### US-15: Farm Plot and Livestock Tracked Through Seasons
**Priority:** P1/R1 | **Category:** Agriculture

> **Scenario:** It's planting season. Diego, the farm lead, opens FarmOS on the field tablet and reviews last year's data for the north plot: the tomatoes did well, but the corn yield was below expectations — soil pH was 5.8 when corn needs 6.0-6.8. He logs this year's plan: rotate corn to the east plot (pH 6.4 last test), plant beans in the north plot to fix nitrogen. He records the planting date, seed variety, and expected harvest window. When the chickens move to a new pasture section, he logs that too. By harvest, FarmOS will show exactly what worked and what didn't.

**As a** farm lead, **I want** to track planting, harvesting, soil conditions, and livestock across seasons, **so that** we can improve yields year over year with data-driven decisions.

**Acceptance Criteria:**
- [ ] Field/plot maps with crop assignments per season
- [ ] Planting, fertilizing, and harvest events logged with dates and quantities
- [ ] Soil test results (pH, NPK, moisture) recorded per plot
- [ ] Livestock counts and pasture rotation tracked
- [ ] Historical yield data for year-over-year comparison
- [ ] Weather correlation with crop performance (when weather data available)

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| FarmOS deployment | software | live |
| Field tablet with network access | hardware | live |
| Soil testing kit | hardware | planned |
| Plot mapping data (GIS/manual) | data | planned |
| Weather station integration (see US-07) | integration | planned |

**Lab Mapping:** FarmOS (Server-2:8161) is deployed behind Authentik SSO. The application is running but has not been configured with plots, crops, or livestock data. Rated R1 because the software is live but not operationally populated.

---

### US-16: Network Intrusion Detected and Blocked by IDS
**Priority:** P1/R0 | **Category:** Security

> **Scenario:** An unknown device connects to the ARC network on the IoT VLAN — someone plugged in a scavenged router without checking it first. The router begins scanning the network. Suricata on FIREWALL detects the port scan within seconds, matches it against the ET Open ruleset, and fires an alert. The alert appears in Grafana and triggers a push notification to the security operator. She reviews the alert, identifies the source MAC address, and blocks it at the switch. The firewall logs show exactly which ports were probed and from where.

**As a** security operator, **I want** network intrusion detection that alerts on suspicious traffic, **so that** threats to the ARC network are identified and stopped before they cause damage.

**Acceptance Criteria:**
- [ ] All inter-VLAN traffic is inspected by the IDS
- [ ] Known attack signatures (port scans, exploit attempts) trigger alerts
- [ ] Alerts are visible in Grafana and sent via push notification
- [ ] Alert includes source IP, destination, protocol, and signature match
- [ ] False positive rate is manageable (tuned ruleset)
- [ ] IDS operates on all VLANs including IoT and guest networks

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Suricata IDS on FIREWALL | software | live |
| ET Open ruleset (updated) | data | live |
| Grafana alerting integration | software | live |
| Push notification (Alertmanager → ntfy) | software | live |
| VLAN segmentation (7 VLANs) | infra | live |

**Lab Mapping:** Suricata IDS on FIREWALL with ET Open ruleset. Grafana (Server-2:3000) with dedicated Suricata dashboard (Loki queries). Alertmanager (Server-2:9093) routes alerts to ntfy. 7 VLANs segmented on switch-1. Fully operational.

---

### US-17: VPN Tunnel Connects Remote ARC Site
**Priority:** P1/R0 | **Category:** Comms

> **Scenario:** A second ARC site has been established 50 km away. They have their own servers and services but need access to the primary site's medical records and supply database. The network operator configures a WireGuard tunnel between the two OPNsense firewalls. Once the tunnel is up, a doctor at the remote site can query OpenEMR at the primary site as if they were on the same LAN. Latency is 12ms. The tunnel auto-reconnects if either site reboots.

**As a** network operator, **I want** to establish encrypted VPN tunnels between ARC sites, **so that** remote sites can access shared resources securely.

**Acceptance Criteria:**
- [ ] WireGuard tunnel established between two sites with persistent configuration
- [ ] Tunnel auto-reconnects after reboot or network interruption
- [ ] Remote site can access designated services on the primary site's network
- [ ] Traffic is encrypted end-to-end
- [ ] Tunnel status is monitored in Grafana with latency and throughput metrics
- [ ] Multiple tunnels supported for redundancy or additional sites

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| WireGuard on OPNsense (FIREWALL) | software | live |
| WireGuard tunnel configuration | infra | live |
| Static public IP or DDNS | infra | live |
| Firewall rules for tunnel traffic | infra | live |
| Grafana WireGuard dashboard | software | live |

**Lab Mapping:** WireGuard VPN on FIREWALL (vpn.example.com:51820). Tunnel 10.10.10.0/24 overlay with full VLAN access. Grafana WireGuard dashboard with handshake, transfer, and endpoint metrics. Fully operational for remote access — site-to-site tunnel is the same technology, just different peer configuration.

---

### US-18: All Services Authenticate Through Single Sign-On
**Priority:** P1/R0 | **Category:** Identity

> **Scenario:** New resident Ahmed is given an ARC account by the admin. He opens his laptop, goes to any ARC service — Wiki.js, Grocy, FarmOS — and sees the same login screen. He enters his username and password once. For the rest of the day, every service he visits recognizes him automatically. When he leaves the ARC, the admin disables his account in one place — and he's immediately locked out of everything. No service-by-service password resets. No orphaned accounts.

**As an** ARC administrator, **I want** all services to authenticate through a single identity provider, **so that** user accounts, access, and offboarding are managed in one place.

**Acceptance Criteria:**
- [ ] Single username/password grants access to all ARC services
- [ ] New user provisioning requires only one account creation
- [ ] Disabling an account immediately revokes access to all services
- [ ] Role-based access controls restrict sensitive services (medical, security, admin)
- [ ] Session timeout enforces re-authentication after inactivity
- [ ] Works without internet (local LDAP/SSO)

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Authentik SSO (OIDC provider) | software | live |
| Active Directory (LDAP backend) | software | live |
| Forward-auth proxy (nginx + Authentik outpost) | infra | live |
| Per-service OIDC/LDAP integration | integration | live |
| LDAP Account Manager for user provisioning | software | live |

**Lab Mapping:** Authentik (Server-2:9443) — SSO with OIDC providers, forward-auth proxy, AD LDAP sync. Active Directory on DC-1/DC-2. Central-proxy (Server-2:8443) with nginx forward-auth for 42+ services. LDAP Account Manager (Server-2:8890) for account provisioning. Fully operational.

---

### US-19: Ammunition and Defensive Supply Inventory
**Priority:** P1/R0 | **Category:** Security

> **Scenario:** The security lead needs to report current ammunition stocks for the monthly readiness review. He opens Cannery on his tablet, filters by caliber, and sees: 1,247 rounds of 5.56 NATO, 890 rounds of 9mm, 340 rounds of 12-gauge buckshot. He also checks the last range log — 200 rounds of 5.56 were used in training last week. The system shows consumption rate and projects that at current training tempo, the 5.56 stock will last 6 more weeks. He adjusts the training schedule accordingly.

**As a** security lead, **I want** to track ammunition inventory and consumption, **so that** defensive supplies are managed responsibly and shortages are anticipated.

**Acceptance Criteria:**
- [ ] All ammunition tracked by caliber, quantity, and storage location
- [ ] Range logs record rounds expended per training session
- [ ] Consumption rate calculated with stock projection
- [ ] Low-stock alerts at configurable thresholds
- [ ] Audit trail for all inventory changes (who added/removed, when)
- [ ] Access restricted to security-cleared personnel

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Cannery (ammunition tracking) | software | live |
| Authentik SSO with role-based access | infra | live |

**Lab Mapping:** Cannery (Server-2:8118) — ammunition inventory and range logs, deployed behind Authentik SSO. Fully operational.

---

### US-20: Push Notification Alerts Operators to Service Failure
**Priority:** P1/R0 | **Category:** Monitoring

> **Scenario:** At 2:30 AM, the DNS service on FIREWALL stops responding. Within 60 seconds, Uptime Kuma detects the failure and sends a push notification via ntfy to every operator's phone: "DNS (FIREWALL Unbound) — DOWN since 02:30." The on-call operator wakes up, SSHes into FIREWALL, and restarts Unbound. Two minutes later, a recovery notification arrives: "DNS (FIREWALL Unbound) — UP. Downtime: 4 minutes." The operator goes back to sleep.

**As a** system operator, **I want** immediate push notifications when any critical service fails, **so that** I can respond to outages before they impact ARC residents.

**Acceptance Criteria:**
- [ ] All critical services are monitored at least every 60 seconds
- [ ] Failure detection triggers push notification within 2 minutes
- [ ] Notification includes service name, status, and timestamp
- [ ] Recovery notification sent when service comes back online
- [ ] Multiple notification channels (ntfy push, email, voice TTS)
- [ ] Notification history is logged and searchable

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Uptime Kuma (status monitoring) | software | live |
| ntfy (push notifications) | software | live |
| Alertmanager (alert routing) | software | live |
| Prometheus (metrics collection) | software | live |
| Grafana (dashboards and alert rules) | software | live |

**Lab Mapping:** Uptime Kuma (Server-2:8111) — 80 monitors. ntfy (Server-2:8150) — push notifications. Alertmanager (Server-2:9093) — alert routing. Prometheus (Server-2:9091) — 45 alert rules. Grafana (Server-2:3000) — 16 dashboards. Qwen3-TTS (workstation:8080) — voice notifications. Fully operational.

---

### US-21: Document Scanned, OCR'd, and Archived
**Priority:** P1/R0 | **Category:** Records

> **Scenario:** A scavenging team returns with a box of paper documents — medical records from an abandoned clinic, a maintenance manual for a diesel generator, and several pages of handwritten notes. The records clerk feeds them through the scanner. Paperless-ngx OCRs each page, extracts the text, and assigns tags based on content. The diesel manual is tagged "maintenance, generator, diesel" and becomes searchable. When the mechanic needs the oil change interval three months later, she searches "diesel oil change" and finds the exact page in seconds.

**As a** records clerk, **I want** to scan paper documents, OCR them, and archive them with searchable tags, **so that** physical documents are preserved digitally and can be found when needed.

**Acceptance Criteria:**
- [ ] Paper documents are scanned and stored as searchable PDFs
- [ ] OCR extracts text with >95% accuracy on printed documents
- [ ] Tags can be applied manually or auto-suggested based on content
- [ ] Full-text search across all archived documents
- [ ] Original scan is preserved alongside the OCR'd version
- [ ] Documents are organized by type and date

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Paperless-ngx (document management) | software | live |
| Stirling-PDF (PDF toolkit with OCR) | software | live |
| Document scanner hardware | hardware | live |
| Authentik SSO integration | infra | live |

**Lab Mapping:** Paperless-ngx (Server-2:8134) — document management with OCR, tagging, full-text search. Stirling-PDF (Server-2:8103) — PDF merge, split, convert, OCR, compress. Both behind Authentik SSO. Fully operational.

---

### US-22: AI Assistant Answers a Practical Question Offline
**Priority:** P1/R1 | **Category:** AI

> **Scenario:** The mechanic is rebuilding a carburetor she's never worked on before. She opens the AI assistant on the workshop tablet and asks: "What is the correct float height for a Holley 4160 carburetor?" The local LLM — running entirely on ARC hardware — responds with the specification (0.375 inches from the gasket surface), the adjustment procedure, and a warning about ethanol fuel deposits. No internet required. The knowledge was part of the model's training data, supplemented by locally-indexed repair manuals.

**As an** ARC resident, **I want** to ask an AI assistant practical questions and get useful answers offline, **so that** I have access to expert-level knowledge for tasks I'm not trained in.

**Acceptance Criteria:**
- [ ] AI responds to practical questions (repair, medical basics, agriculture, cooking) accurately
- [ ] Response time is under 30 seconds for a typical question
- [ ] No internet connectivity required — model runs entirely on local hardware
- [ ] Responses can reference locally-indexed documents (RAG)
- [ ] Model is aware of ARC-specific context (inventory, procedures, local conditions)
- [ ] GPU or CPU inference is available depending on hardware

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Local LLM (Qwen2.5-7B or similar) | software | live |
| GPU for inference (workstation RTX 3060) | hardware | live |
| RAG pipeline with local document index | software | partial |
| Web interface for queries | software | partial |
| ARC-specific fine-tuning data | data | planned |

**Lab Mapping:** HALops (workstation) — Qwen2.5-7B fine-tuned lab agent with GPU inference. Archivist (`~/projects/archivist/`) is building the corpus acquisition and RAG search infrastructure. The LLM exists and runs but lacks a general-purpose web interface and ARC-specific knowledge base. Rated R1.

---

### US-23: Container Service Auto-Restarts After Crash
**Priority:** P1/R0 | **Category:** Infra

> **Scenario:** At 4 AM, the Grocy container crashes due to a PHP memory error. Nobody is awake. Systemd detects the container has exited, waits 10 seconds (configured restart delay), and starts it again. The container passes its health check. Healthchecks.io records the brief gap. When Rosa opens Grocy at 6 AM to plan breakfast, everything works. She never knew it was down. The operations dashboard shows a brief blip in the Uptime Kuma timeline — 47 seconds of downtime, fully automated recovery.

**As a** system operator, **I want** all containerized services to automatically restart after crashes, **so that** service outages are recovered without human intervention.

**Acceptance Criteria:**
- [ ] All containers are managed by Quadlet (systemd-native)
- [ ] Crashed containers restart automatically with configurable delay
- [ ] Start limits prevent crash loops from consuming system resources
- [ ] Health checks verify the service is actually working after restart
- [ ] Restart events are logged and visible in monitoring
- [ ] No manual `podman run` — all containers have Quadlet definitions

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Podman with Quadlet on all nodes | software | live |
| Systemd user services with linger | infra | live |
| Container health checks | infra | live |
| Uptime Kuma monitoring | software | live |
| Healthchecks dead-man switch | software | live |

**Lab Mapping:** All containers on Server-1 and Server-2 are managed via Podman Quadlet. 44 containers with systemd auto-restart. Uptime Kuma (80 monitors) and Healthchecks (5 checks) provide monitoring. Start limits configured in `[Unit]` section (critical — `[Service]` is silently ignored by systemd). Fully operational.

---

### US-24: DNS Resolves Even if Primary Resolver Fails
**Priority:** P1/R0 | **Category:** Infra

> **Scenario:** FIREWALL, which runs the primary Unbound DNS resolver, needs a firmware update and will be offline for 10 minutes. Before the update, the operator verifies that DC-1 and DC-2 (the Active Directory domain controllers) are serving DNS for all `lab.example.com` and `lab.example.com` zones. She reboots FIREWALL. During the 10 minutes it's down, every device on the network seamlessly fails over to DC-1 (10.0.20.11) or DC-2 (10.0.20.21) — because DHCP pushes all three resolvers to every client. When FIREWALL comes back, it resumes as primary. Zero DNS resolution failures.

**As a** network operator, **I want** DNS to keep working even if the primary resolver goes down, **so that** name resolution never fails during maintenance or outages.

**Acceptance Criteria:**
- [ ] At least three DNS resolvers serve all ARC zones
- [ ] DHCP pushes all resolvers to every client
- [ ] Clients automatically fail over to secondary resolvers when primary is unavailable
- [ ] All resolvers serve identical zone data (synchronized)
- [ ] DNS resolution works for both forward and reverse lookups
- [ ] Resolver health is monitored with alerts on failure

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| FIREWALL Unbound (primary resolver) | software | live |
| DC-1 AD DNS (secondary) | software | live |
| DC-2 AD DNS (tertiary) | software | live |
| Kea DHCP pushing all 3 resolvers | infra | live |
| DNS sync script (Unbound → AD) | software | live |
| DNS monitoring in Uptime Kuma | software | live |

**Lab Mapping:** Three resolvers: FIREWALL Unbound (10.0.10.1), DC-1 (10.0.20.11), DC-2 (10.0.20.21). AD-integrated zones `lab.example.com` (93 records) and `lab.example.com` (3 records). Sync script on DC-1 runs every 6 hours. DHCP pushes all 3 DNS servers on VLANs 10/20/30/240. Fully operational.

---

### US-25: Shared File Storage Syncs Between ARC Workstations
**Priority:** P1/R0 | **Category:** Storage

> **Scenario:** The teacher creates a lesson plan on her workstation in the schoolroom. She saves it to the "Shared - Education" folder in Nextcloud. Within seconds, the file is available on the classroom projector workstation, on her tablet, and on the library terminal. When she edits the file that evening from her housing unit's workstation, the changes sync everywhere. If the network goes down temporarily, changes queue locally and sync when connectivity returns.

**As an** ARC resident, **I want** shared file storage that syncs across all my devices, **so that** I can access and collaborate on files from anywhere in the compound.

**Acceptance Criteria:**
- [ ] Files saved to shared folders are available on all connected devices
- [ ] Sync happens automatically within 60 seconds of a change
- [ ] Offline edits are queued and synced when connectivity returns
- [ ] Conflict resolution handles simultaneous edits
- [ ] Calendars, contacts, and collaborative documents are supported
- [ ] Storage quotas prevent any single user from filling the disk

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Nextcloud (file sync + collaboration) | software | live |
| Syncthing (peer-to-peer sync) | software | live |
| LDAP authentication | integration | live |
| NFS shared storage (server-side) | infra | live |
| Adequate disk space | hardware | live |

**Lab Mapping:** Nextcloud (Server-2:8130) — file sync, calendars, contacts, collaborative editing with LDAP auth. Syncthing (Server-2:8117) — peer-to-peer encrypted sync. NFS shared storage between workstation and Server-1. Both behind Authentik SSO. Fully operational.

---

## P2 — Quality of Life

These capabilities sustain morale, education, productivity, and long-term thriving.

---

### US-26: Student Completes a Lesson on the LMS
**Priority:** P2/R1 | **Category:** Education

> **Scenario:** Fourteen-year-old Kai sits down at the schoolroom workstation for today's lesson: basic electronics. The Moodle course walks him through resistor color codes, has him answer five quiz questions, and then assigns a hands-on exercise: "Build a voltage divider on the breadboard at your bench and measure the output with the multimeter." He submits a photo of his breadboard through the assignment upload. The teacher reviews it that evening, leaves feedback, and marks it complete. Kai's progress is tracked across all subjects.

**As a** student, **I want** to complete structured lessons with quizzes and assignments on the learning platform, **so that** I can learn systematically even without a traditional school.

**Acceptance Criteria:**
- [ ] Courses are organized by subject and difficulty level
- [ ] Lessons include text, images, embedded video, and interactive quizzes
- [ ] Assignments can be submitted as text, file upload, or photo
- [ ] Teachers can grade assignments and leave feedback
- [ ] Student progress is tracked across all courses
- [ ] Works on tablets and desktop workstations

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Moodle LMS | software | live |
| LDAP authentication | integration | live |
| Course content (curricula, lessons, quizzes) | data | planned |
| Tablets or workstations for students | hardware | live |

**Lab Mapping:** Moodle (Server-2:8142) is deployed behind Authentik SSO. Running but needs course content creation. Rated R1.

---

### US-27: Resident Looks Up a Wikipedia Article Offline
**Priority:** P2/R0 | **Category:** Knowledge

> **Scenario:** During a community discussion about crop rotation, someone mentions the "three sisters" planting technique but nobody can remember the details. Ben walks to the library terminal, opens Kiwix, and searches "Three Sisters agriculture." The full Wikipedia article loads instantly — complete with diagrams showing how corn, beans, and squash support each other. He reads the key points aloud. The farming crew decides to try it in the east plot next season.

**As an** ARC resident, **I want** to look up Wikipedia articles offline, **so that** I have access to encyclopedic knowledge without internet.

**Acceptance Criteria:**
- [ ] Full Wikipedia content is available offline (English, at minimum)
- [ ] Search returns results in under 2 seconds
- [ ] Articles include images and diagrams
- [ ] StackExchange Q&A archives are also available
- [ ] Content is updated periodically when connectivity is available
- [ ] Accessible from any device on the ARC network

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Kiwix with Wikipedia ZIM | software | live |
| StackExchange ZIM archives | data | live |
| Network-accessible from all terminals | infra | live |

**Lab Mapping:** Kiwix (Server-1:8888) — offline Wikipedia, StackExchange, and custom ZIM archives. Fully operational.

---

### US-28: Mechanic Searches 3D Models for a Replacement Part
**Priority:** P2/R0 | **Category:** Manufacturing

> **Scenario:** The greenhouse irrigation system has a cracked T-junction fitting — a standard 3/4" PVC tee. The hardware store is 40 km away and the roads are questionable. Carlos opens the 3D Model Search on the workshop workstation and types "PVC tee fitting 3/4 inch." The search returns 14 models from the 193k-model archive. He previews them in 3D, finds one with the right dimensions, and sends it to the 3D printer queue. By tomorrow morning, the greenhouse has a working replacement.

**As a** mechanic or maintenance worker, **I want** to search a library of 3D models for replacement parts, **so that** I can 3D-print solutions instead of waiting for supply runs.

**Acceptance Criteria:**
- [ ] 3D model archive contains common mechanical parts, fittings, brackets, and tools
- [ ] Full-text search across model names, descriptions, and tags
- [ ] 3D preview in the browser (rotate, zoom, measure)
- [ ] Models are downloadable in printable formats (STL, 3MF, OBJ)
- [ ] Archive contains 100,000+ models across categories
- [ ] New models can be uploaded and tagged by users

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| 3D Model Search (FastAPI + Three.js) | software | live |
| Manyfold catalog (15k+ models) | software | live |
| Full 3D print archive (193k+ models, 432 GB) | data | live |

**Lab Mapping:** 3D Model Search (Server-1:8085) — full-text search with 3D preview. Manyfold (Server-1:3214) — browseable 3D model catalog with 15k+ models. Archive contains 193k+ models across 432 GB. Fully operational.

---

### US-29: 3D Printer Produces a Replacement Bracket Overnight
**Priority:** P2/R1 | **Category:** Manufacturing

> **Scenario:** The solar panel mount on the roof has a broken bracket. The design team modified a model from the archive to match the exact dimensions needed — 4mm thicker for wind resistance. They export the STL, open OrcaSlicer, configure the print settings (PETG for UV resistance, 40% infill for strength), and start the Creality K1C. The print will take 6 hours. By morning, the bracket is ready. It's installed by noon. No supply run needed.

**As a** maintenance team member, **I want** to 3D-print custom parts from designs, **so that** broken equipment can be repaired without external supply chains.

**Acceptance Criteria:**
- [ ] 3D printer accepts standard file formats (STL, 3MF, G-code)
- [ ] Multiple material options (PLA, PETG, ABS) for different applications
- [ ] Print monitoring (webcam, progress, temperature) available remotely
- [ ] Print queue management for multiple jobs
- [ ] Reference documentation for material selection and print settings
- [ ] Printer maintenance procedures documented

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Creality K1C 3D printer | hardware | live |
| OrcaSlicer (slicing software) | software | live |
| Filament stock (PLA, PETG) | consumables | partial |
| Print monitoring integration | software | planned |
| Offline reference for 3D printing | data | live |

**Lab Mapping:** Creality K1C exists with Klipper firmware. OrcaSlicer configured. 3D printing reference in `~/projects/3d-printing/`. Printer is operational but not network-monitored or queue-managed. Rated R1.

---

### US-30: Family Watches an Archived Educational Video
**Priority:** P2/R0 | **Category:** Media

> **Scenario:** It's Saturday evening. The Rodriguez family wants to watch a documentary about renewable energy — partly for entertainment, partly because they're helping design the ARC's wind turbine proposal. They open Jellyfin on the community room TV, browse the "Science & Technology" category, and find three renewable energy documentaries archived from YouTube. They watch a 45-minute film about small-scale wind power. The kids ask questions. The father takes notes. It's both family time and education.

**As an** ARC resident, **I want** to watch archived educational and entertainment videos, **so that** families have access to media for learning and morale.

**Acceptance Criteria:**
- [ ] Video library is browseable by category (science, history, how-to, entertainment)
- [ ] Streaming works on community TVs, workstations, and tablets
- [ ] Hardware transcoding ensures smooth playback on all devices
- [ ] Search and browse by title, description, or tags
- [ ] No internet required — all content is locally stored
- [ ] New content can be added from archived YouTube channels

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Jellyfin (media server) | software | live |
| Tube Archivist (YouTube archiver) | software | live |
| Video archive (4,300+ files) | data | live |
| Hardware transcoding support | hardware | live |
| Network-connected display devices | hardware | live |

**Lab Mapping:** Jellyfin (Server-2:8140) — media streaming with hardware transcoding. Tube Archivist (Server-2:8141) — YouTube archival and indexing. Video archive: ~4,300 files, 100% H.264/HEVC. Fully operational.

---

### US-31: Cook Plans Meals for the Week with Available Inventory
**Priority:** P2/R0 | **Category:** Food

> **Scenario:** Sunday is meal planning day. Chef Lisa opens Tandoor Recipes on her tablet and reviews the week ahead — 150 people, three meals a day. She checks Grocy for current inventory: plenty of rice, beans, onions, and canned tomatoes; low on fresh vegetables (next harvest in 4 days); eggs from the chickens arriving daily. She builds the week's menu: bean soup Monday, rice and vegetable stir-fry Tuesday (using the last of the peppers), egg scramble Wednesday. For each meal, Tandoor shows the recipe, serving multiplier, and ingredients needed. She generates a "shopping list" of items needed from storage.

**As a** cook, **I want** to plan weekly meals based on what food is actually in stock, **so that** meals are nutritious, varied, and don't waste scarce ingredients.

**Acceptance Criteria:**
- [ ] Recipes are searchable by ingredient, category, and dietary restriction
- [ ] Serving size can be scaled (e.g., from 4 servings to 150)
- [ ] Meal plan calendar shows breakfast, lunch, and dinner for each day
- [ ] Integration with inventory shows which ingredients are available and which are short
- [ ] Shopping/requisition list generated automatically from planned meals
- [ ] Nutritional information displayed per recipe

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Tandoor Recipes | software | live |
| Grocy (inventory) | software | live |
| Recipe collection (imported or created) | data | partial |
| Kitchen tablet | hardware | live |

**Lab Mapping:** Tandoor Recipes (Server-2:8144) — recipe management, meal planning, shopping lists. Grocy (Server-2:8104) — grocery and inventory tracking. Both behind Authentik SSO. Fully operational.

---

### US-32: Resident Listens to Music on Community Speakers
**Priority:** P2/R0 | **Category:** Media

> **Scenario:** It's been a hard week. The community gathering after dinner could use some energy. DJ Priya opens Navidrome on her phone, browses the music library, and creates a playlist: some upbeat folk, classic rock, and a few songs that have become unofficial ARC anthems. She streams it to the community room's speakers via the local network. For an hour, people eat dessert, play cards, and sing along. It's a small thing. It matters enormously.

**As an** ARC resident, **I want** to browse and stream music from the community library, **so that** we have music for gatherings, work, and personal enjoyment.

**Acceptance Criteria:**
- [ ] Music library is browseable by artist, album, genre, and playlist
- [ ] Streaming works on phones, tablets, and desktop browsers
- [ ] Subsonic-compatible apps (DSub, Ultrasonic) work for mobile playback
- [ ] Playlists can be created and shared
- [ ] No internet required — all music is locally stored
- [ ] Search by title, artist, or album

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Navidrome (music server) | software | live |
| Music library (local collection) | data | live |
| Network-connected speakers or devices | hardware | live |

**Lab Mapping:** Navidrome (Server-2:8116) — Subsonic-compatible music streaming with playlists and smart albums. Behind Authentik SSO. Fully operational.

---

### US-33: Gardener Logs Plant Health and Watering Schedule
**Priority:** P2/R0 | **Category:** Agriculture

> **Scenario:** Maya tends the herb garden every morning. She opens HortusFox on her phone, selects the basil bed, and logs today's observations: "Strong growth, no pests, watered 10 minutes." She takes a photo showing the plants are about 20 cm tall. HortusFox reminds her that the rosemary in bed #3 is due for deep watering today — she flagged it three days ago. She walks over, waters it, and marks the task complete. Over months, the photo gallery shows the garden's progress from bare soil to abundance.

**As a** gardener, **I want** to log plant health observations and watering schedules, **so that** garden care is consistent even when different people tend the beds.

**Acceptance Criteria:**
- [ ] Each plant or garden bed has its own profile with care history
- [ ] Watering, fertilizing, and pruning events are logged with dates
- [ ] Photo gallery shows plant growth over time
- [ ] Care reminders (watering schedule, fertilizer intervals) with notifications
- [ ] Multiple gardeners can contribute observations
- [ ] Plant health notes are searchable

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| HortusFox (plant management) | software | live |
| Phone or tablet with camera | hardware | live |

**Lab Mapping:** HortusFox (Server-2:8105) — plant management with care schedules, watering reminders, and photo gallery. Behind Authentik SSO. Fully operational.

---

### US-34: Child Studies with Flashcards on a Tablet
**Priority:** P2/R1 | **Category:** Education

> **Scenario:** Eight-year-old Lily is learning multiplication tables. Every morning before class, she opens the Anki app on her tablet and reviews her flashcards for 10 minutes. The spaced repetition algorithm shows her the ones she's struggling with more often and the ones she knows well less frequently. Her progress syncs to the local Anki Sync server — so when the teacher checks the dashboard, she can see that Lily has mastered her 2s through 7s but needs more work on 8s and 9s. The teacher adjusts tomorrow's lesson accordingly.

**As a** student, **I want** to study with spaced-repetition flashcards that sync across devices, **so that** I can memorize important information efficiently.

**Acceptance Criteria:**
- [ ] Flashcard decks are available for core subjects (math, science, vocabulary, history)
- [ ] Spaced repetition algorithm schedules reviews optimally
- [ ] Progress syncs between tablet and teacher's dashboard
- [ ] New decks can be created by teachers
- [ ] Works offline — syncs when connected
- [ ] Supports images and audio in cards

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Anki Sync server | software | live |
| Anki app on tablets | software | partial |
| Flashcard deck content | data | planned |
| Tablets for students | hardware | partial |

**Lab Mapping:** Anki Sync (Server-2:8143) — spaced repetition sync server. Server is deployed but needs Anki desktop/mobile clients installed on devices and flashcard decks created. Rated R1.

---

### US-35: Resident Reads an Ebook on a Shared Tablet
**Priority:** P2/R0 | **Category:** Knowledge

> **Scenario:** After a long day, Alex borrows the library tablet and browses Calibre-Web for something to read. He finds a survival manual he's been meaning to finish and a novel he hasn't read. He opens the survival manual in the browser-based EPUB reader, picks up where he left off (the chapter on water purification), and reads for an hour. The ebook library contains thousands of titles — technical manuals, fiction, history, cooking, medicine — all available offline.

**As an** ARC resident, **I want** to browse and read ebooks on shared devices, **so that** I have access to books for learning and recreation.

**Acceptance Criteria:**
- [ ] Ebook library is browseable by author, title, category, and format
- [ ] EPUB and PDF formats are readable in the browser
- [ ] Reading position is saved per user
- [ ] Library contains both technical/reference and fiction/recreation titles
- [ ] Search by title, author, or subject
- [ ] New ebooks can be added to the collection

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Calibre-Web (ebook reader) | software | live |
| Digital Library (search/download) | software | live |
| Ebook collection | data | live |
| Shared tablets or workstations | hardware | live |

**Lab Mapping:** Calibre-Web (Server-1:8083) — browser-based ebook reader. Digital Library (Server-1:8084) — search and download interface. Ebook collection available. Fully operational.

---

### US-36: Translator Converts a Found Foreign Document
**Priority:** P2/R1 | **Category:** Tools

> **Scenario:** The scavenging team found a technical manual for a water pump — but it's in Spanish. Nobody on the water team speaks Spanish fluently. The clerk opens LibreTranslate on the workstation, uploads the document text, selects Spanish → English, and gets a working translation in 30 seconds. It's not perfect, but the technical terms are clear enough to understand the pump's maintenance schedule. LanguageTool polishes the grammar of the translated text for the final version that goes into the knowledge base.

**As a** records clerk or technician, **I want** to translate documents between languages offline, **so that** found materials in foreign languages can be understood and used.

**Acceptance Criteria:**
- [ ] Translation between at least 10 major languages
- [ ] Works offline — no cloud API required
- [ ] Handles technical vocabulary reasonably well
- [ ] Supports text input (paste or type)
- [ ] Grammar checking available for translated output
- [ ] API available for integration with other tools

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| LibreTranslate (offline translation) | software | live |
| LanguageTool (grammar checker) | software | live |
| Language models downloaded | data | partial |

**Lab Mapping:** LibreTranslate (Server-2:8115) — offline translation, 30+ languages. LanguageTool (Server-2:8114) — grammar and spell checking. Both deployed. Language model download completeness varies by language pair. Rated R1 due to model coverage gaps for less common languages.

---

### US-37: Resident Tracks Personal Finances and Barter Ledger
**Priority:** P2/R0 | **Category:** Finance

> **Scenario:** In the ARC, some transactions happen through barter, some through community credits, and some through whatever currency is still circulating. Marcus uses Firefly III to track it all: "Traded 2 kg tomatoes for 1 kg dried beans — value: 5 credits. Paid 10 credits for boot repair from the cobbler." At the end of the month, he can see his balance: what he's produced, consumed, and traded. The community treasurer uses Actual Budget for the shared accounts — fuel reserves, medical supplies, seeds.

**As an** ARC resident, **I want** to track my personal finances and barter transactions, **so that** I understand my economic activity and can plan ahead.

**Acceptance Criteria:**
- [ ] Income, expenses, and barter trades are logged with amounts and categories
- [ ] Reports show spending patterns and balances over time
- [ ] Community shared budget tracking (separate from personal)
- [ ] Supports custom "currencies" (credits, barter, external currency)
- [ ] Data is private per user (LDAP auth)
- [ ] Import/export for data portability

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Firefly III (personal finance) | software | live |
| Actual Budget (budgeting) | software | live |
| LDAP authentication | integration | live |

**Lab Mapping:** Firefly III (Server-2:8172) — personal finance with transactions, budgets, reports. Actual Budget (Server-2:8171) — envelope-style budgeting. Both behind Authentik SSO. Fully operational.

---

### US-38: Resident Manages Personal Health Records
**Priority:** P2/R1 | **Category:** Health

> **Scenario:** Ahmed wants to keep track of his own health data — blood pressure readings he takes at home, his medication schedule, allergies, and his last dental visit. He opens OpenEMR's patient portal and enters today's blood pressure reading: 128/82. The system shows his trend over the last 3 months — a gradual improvement since he started daily walks. He also notes that his ibuprofen supply is getting low. When he sees Dr. Chen next week, she'll have this data in his chart already.

**As an** ARC resident, **I want** to view and contribute to my own health records, **so that** I can track my health between medical visits and share relevant data with my care provider.

**Acceptance Criteria:**
- [ ] Patient portal allows viewing own medical records
- [ ] Self-reported data (BP, weight, symptoms) can be entered by the patient
- [ ] Medication schedule and reminders
- [ ] Allergy and emergency information accessible
- [ ] Privacy controls — only the patient and their providers can see records
- [ ] Works on tablets and phones

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| OpenEMR patient portal | software | live |
| Patient accounts provisioned | integration | planned |
| Clinical templates configured | data | planned |

**Lab Mapping:** OpenEMR (Server-2:8160) has a patient portal feature but it has not been configured for patient self-service access. Rated R1.

---

### US-39: Team Tracks Project Tasks on a Kanban Board
**Priority:** P2/R0 | **Category:** Productivity

> **Scenario:** The construction team is building a new chicken coop. The project has 23 tasks: site prep, foundation, framing, roofing, fencing, nesting boxes, water supply, and more. The team lead opens Taiga and moves "Frame walls" from "In Progress" to "Done." She assigns "Install roofing" to Miguel and sets a due date for Thursday. The whole team can see the board — who's doing what, what's blocked, and what's next. When the project is complete, the board becomes a record of how long each phase took, useful for planning the next structure.

**As a** team lead, **I want** to track project tasks on a kanban board with assignments and due dates, **so that** the team knows who is doing what and nothing falls through the cracks.

**Acceptance Criteria:**
- [ ] Kanban board with customizable columns (To Do, In Progress, Done, Blocked)
- [ ] Tasks can be assigned to team members with due dates
- [ ] Drag-and-drop task movement between columns
- [ ] Multiple project boards for different teams/projects
- [ ] Task comments and attachments
- [ ] LDAP authentication for team access

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Taiga (agile project management) | software | live |
| Vikunja (task management) | software | live |
| LDAP authentication | integration | live |

**Lab Mapping:** Taiga (Server-2:8132) — Scrum/Kanban boards. Vikunja (Server-2:8135) — task lists, kanban, Gantt, CalDAV. Both behind Authentik SSO. Fully operational.

---

### US-40: Resident Uses CyberChef to Decode a Found Data Format
**Priority:** P2/R0 | **Category:** Tools

> **Scenario:** The electronics team recovered a USB drive from an abandoned office. Some files have unusual encodings — one is Base64-encoded, another appears to be ROT13, and a third is a hex dump of what might be a firmware binary. The technician opens CyberChef, drags the Base64 decode operation onto the recipe, pastes the file contents, and gets readable text — it's a configuration file for a solar charge controller. Extremely useful. She decodes the others and adds the results to the knowledge base.

**As a** technician, **I want** a data analysis toolkit that can decode, convert, and analyze found data, **so that** recovered digital materials can be made useful.

**Acceptance Criteria:**
- [ ] 300+ data operations (encode/decode, encrypt/decrypt, compress, parse)
- [ ] Drag-and-drop recipe builder for chaining operations
- [ ] Input/output displayed side by side
- [ ] Works entirely in the browser (no server-side processing)
- [ ] Handles binary data (hex, Base64, raw bytes)
- [ ] No internet required

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| CyberChef | software | live |
| Modern browser on any ARC workstation | hardware | live |

**Lab Mapping:** CyberChef (Server-2:8101) — 300+ data operations, fully client-side. Behind Authentik SSO. Fully operational.

---

## P3 — Civilization Rebuild

These capabilities enable governance, justice, trade, manufacturing, and cultural preservation — the building blocks of a functioning society.

---

### US-41: Council Resolves a Property Dispute Using Legal AI
**Priority:** P3/R2 | **Category:** Governance

> **Scenario:** Two families dispute the boundary between their assigned garden plots. The council mediator opens the legal AI assistant and describes the situation. The AI references relevant principles from the ARC's governance charter, analogous case precedents from the Corpus Juris Americana (the offline legal reference), and applicable common law principles. It suggests a resolution framework: survey the original plot assignments, measure the actual boundaries, and apply the ARC's dispute resolution protocol. The mediator uses this analysis to structure a fair hearing. The decision is recorded in the community archive.

**As a** council mediator, **I want** an AI assistant trained on legal principles and the ARC governance charter, **so that** disputes can be resolved fairly and consistently even without trained lawyers.

**Acceptance Criteria:**
- [ ] Legal AI has access to the ARC governance charter and dispute resolution procedures
- [ ] Corpus Juris Americana (offline legal reference) is indexed and searchable
- [ ] AI can reference relevant legal principles for common dispute types
- [ ] Suggestions are presented as frameworks, not binding decisions
- [ ] All consultations are logged for precedent tracking
- [ ] Works entirely offline

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Local LLM with legal fine-tuning | software | partial |
| Corpus Juris Americana (legal corpus) | data | designed |
| ARC governance charter | document | planned |
| RAG pipeline for legal document search | software | partial |

**Lab Mapping:** HALops (workstation) provides the base LLM. Corpus Juris Americana is tracked in arc#1. Archivist is building the RAG pipeline. No legal-specific fine-tuning or governance charter exists yet. Rated R2.

---

### US-42: Technician Installs F-Droid Apps on Community Phones
**Priority:** P3/R0 | **Category:** Software

> **Scenario:** Three new phones were scavenged from a vacated house — all Android. The IT technician connects them to the ARC WiFi, opens the browser, scans the WiFi QR code page for quick setup, then points the F-Droid app to the local repository at fdroid.lab.example.com:8070. The phones pull the app index — 1,018 packages from 18 repos. She installs Conversations (XMPP chat), Anki (flashcards), OsmAnd (offline maps), and Signal (if external comms are available). Within 30 minutes, the phones are ready for their new owners. No Google Play Store needed. No internet needed.

**As an** IT technician, **I want** to install apps on community phones from a local F-Droid repository, **so that** phones are useful without depending on Google Play or the internet.

**Acceptance Criteria:**
- [ ] Local F-Droid repository serves 1,000+ app packages
- [ ] Phones can point to the local repo and browse/install apps
- [ ] Key apps available: messaging, maps, flashcards, file manager, calculator
- [ ] Repository is updated periodically when internet is available
- [ ] WiFi QR codes available for quick phone onboarding
- [ ] Works on any Android phone with F-Droid installed

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| F-Droid Server (local repository) | software | live |
| WiFi QR Codes (onboarding page) | software | live |
| Android phones | hardware | live |

**Lab Mapping:** F-Droid Server (Server-1:8070) — 1,018 packages from 18 repos. WiFi QR Codes (Server-1:8889) — scan-to-connect landing page. Fully operational.

---

### US-43: New ARC Site Receives a Seeded HAL Drive
**Priority:** P3/R2 | **Category:** Expansion

> **Scenario:** A group of 30 people has found a suitable location for a second ARC site, 80 km away. They need the full software stack but can't build it from scratch. The IT lead at the primary site prepares a HAL (Hardware Abstraction Layer) drive — a bootable SSD containing the complete ARC operating environment: all containerized services, offline knowledge bases, 3D model archive, medical references, maps, the AI model, and a configuration wizard. The drive is physically carried to the new site. The technician there boots a server from the HAL drive, runs the setup wizard (configuring network, DNS, and credentials for the new site), and within 4 hours, the new ARC has a fully functional digital infrastructure.

**As a** technician at a new ARC site, **I want** to receive a pre-built bootable drive containing the entire ARC software stack, **so that** I can stand up digital infrastructure in hours instead of weeks.

**Acceptance Criteria:**
- [ ] HAL drive boots to a functional server environment
- [ ] All ARC services are pre-loaded and configured
- [ ] Setup wizard customizes network settings, DNS, and credentials for the new site
- [ ] Offline knowledge bases (Wikipedia, medical, legal, maps) are included
- [ ] 3D model archive and AI model are included
- [ ] Drive creation is scripted and reproducible

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| HAL drive build system | software | designed |
| Container image export/import pipeline | integration | partial |
| Configuration wizard | software | planned |
| Bootable OS image (Fedora/similar) | software | partial |
| Large SSD or NVMe drive (2-4 TB) | hardware | planned |
| Zot OCI Registry (image source) | software | live |

**Lab Mapping:** Zot OCI Registry (Server-2:5000) mirrors container images from major registries. Disaster recovery project (`~/projects/disaster-recovery/`) has an 8-hour full lab restore design. The concept exists but no HAL build system or setup wizard has been implemented. Rated R2.

---

### US-44: Mesh Network Bridges Two ARC Sites 10km Apart
**Priority:** P3/R2 | **Category:** Comms

> **Scenario:** The primary and secondary ARC sites are 10 km apart, separated by a ridge. Direct LoRa communication is unreliable at that distance. The comms team installs a solar-powered Reticulum relay on the ridgetop — a weatherproof box with a LoRa radio, a Raspberry Pi, and a small solar panel. The relay extends mesh coverage to both sites. Text messages, weather alerts, and small data packets now flow reliably between sites. The WireGuard VPN tunnel (US-17) handles bulk data when the two sites can connect via landline or restored internet, but the mesh ensures communication never goes dark.

**As a** comms operator, **I want** a mesh relay that bridges two ARC sites beyond direct radio range, **so that** communities can communicate even without internet or phone networks.

**Acceptance Criteria:**
- [ ] Relay extends mesh coverage to at least 10 km between sites
- [ ] Relay is solar-powered and weather-hardened for autonomous operation
- [ ] Text messages and alerts propagate reliably through the relay
- [ ] Relay operates autonomously (no daily maintenance)
- [ ] Status monitoring from either site (battery, temperature, link quality)
- [ ] Supports at least 3 simultaneous message streams

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| LoRa radio with directional antenna | hardware | planned |
| Raspberry Pi (relay computer) | hardware | live |
| Reticulum software stack | software | designed |
| Solar panel + battery for relay | hardware | planned |
| Weatherproof enclosure | hardware | planned |

**Lab Mapping:** Reticulum mesh designed. Raspberry Pi hardware available. Off-Grid Comms project (`~/projects/offgrid-comms/`) is researching mesh networking solutions. No relay hardware deployed. Rated R2.

---

### US-45: Historian Archives Community Decisions and Events
**Priority:** P3/R0 | **Category:** Records

> **Scenario:** Every week, the ARC council meets to discuss resource allocation, dispute resolution, and project priorities. The historian, Grace, attends each meeting and writes a summary in Wiki.js: the date, attendees, decisions made, and action items assigned. She also records significant events — births, deaths, harvests, weather events, construction milestones. Over the months, this becomes the ARC's institutional memory. When someone asks "Why did we decide to plant soybeans instead of wheat?" the answer is in the wiki, with context.

**As a** community historian, **I want** a wiki to record council decisions, significant events, and institutional knowledge, **so that** the community has a permanent, searchable memory of its own history.

**Acceptance Criteria:**
- [ ] Wiki pages can be created and edited by authorized users
- [ ] Full-text search across all wiki content
- [ ] Revision history tracks all changes (who changed what, when)
- [ ] Pages can be organized by category (decisions, events, procedures, people)
- [ ] Supports Markdown and WYSIWYG editing
- [ ] LDAP authentication controls who can edit vs. read

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Wiki.js | software | live |
| LDAP authentication | integration | live |
| Note-taking tools (Trilium) | software | live |

**Lab Mapping:** Wiki.js (Server-2:8131) — knowledge wiki with Markdown/WYSIWYG, full-text search, LDAP auth. Trilium Notes (Server-2:8133) — hierarchical note-taking for personal or detailed records. Both behind Authentik SSO. Fully operational.

---

### US-46: Electronics Tech Finds a Part Spec in Part-DB
**Priority:** P3/R0 | **Category:** Manufacturing

> **Scenario:** The radio team is repairing a Baofeng UV-5R and needs a replacement 10 kohm resistor — 1/4 watt, 5% tolerance. The electronics tech opens Part-DB and searches "10k resistor." The database shows 23 matching parts in stock, organized by storage location: "Bin A3, Shelf 2, Drawer 7." She pulls the resistor, logs the withdrawal (stock drops from 23 to 22), and completes the repair. The datasheet PDF is attached to the part entry — she uses it to verify the footprint before soldering.

**As an** electronics technician, **I want** to search a component database with datasheets and stock locations, **so that** I can find the right part quickly and know where it's stored.

**Acceptance Criteria:**
- [ ] Component catalog searchable by part number, description, and parameters
- [ ] Storage location tracking (bin, shelf, drawer)
- [ ] Stock quantity with withdrawal logging
- [ ] Datasheets attached to parts (PDF/images)
- [ ] Category tree for organizing part types
- [ ] Barcode/QR label printing for bins

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Part-DB (electronic parts database) | software | live |
| Component inventory data | data | partial |
| Datasheets (downloaded) | data | partial |

**Lab Mapping:** Part-DB (Server-2:8109) — electronic parts database with catalog, datasheets, storage locations. Currently stopped but deployable. InvenTree (Server-2:8136) provides additional BOM and stock management. Fully operational (pending Part-DB restart).

---

### US-47: Community Votes on Resource Allocation Policy
**Priority:** P3/R3 | **Category:** Governance

> **Scenario:** The ARC council proposes a new policy: allocate 20% of diesel reserves to agricultural equipment (tractors, tillers) instead of the current 10%. This is a significant change that affects everyone. The council decides to put it to a community vote. The governance app creates a ballot with the proposal text, opens voting for 72 hours, and enforces one-vote-per-resident using LDAP identity verification. After the vote closes, the results are published: 87 in favor, 52 against, 11 abstentions. The policy passes with a 63% majority. The results and the full vote record are archived in the wiki.

**As a** council member, **I want** a secure, auditable voting system for community decisions, **so that** important policies are decided democratically with a transparent record.

**Acceptance Criteria:**
- [ ] Proposal text is published with a clear question
- [ ] Voting period is configurable (24-168 hours)
- [ ] One vote per resident, enforced by identity verification
- [ ] Secret ballot (vote choice is not linked to voter identity in results)
- [ ] Results are tallied automatically and published after voting closes
- [ ] Full audit trail is preserved (participation verified, choices anonymous)

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Voting/polling application | software | conceptual |
| LDAP identity verification | integration | live |
| Governance charter defining voting rules | document | planned |
| Audit trail storage | infra | live |

**Lab Mapping:** No voting application exists. LDAP/Authentik provides identity infrastructure. Wiki.js could host governance records. The voting application itself needs to be designed and built. Rated R3.

---

### US-48: Operator Fine-Tunes the AI on Local Knowledge
**Priority:** P3/R1 | **Category:** AI

> **Scenario:** The ARC's AI assistant keeps giving generic answers about soil amendment because its training data is from temperate climates — but the ARC is in a subtropical zone with heavy clay soil. The AI operator collects the local agricultural data from FarmOS (3 years of soil tests, yield records, and planting notes), formats it as training data, and runs a fine-tuning job on the workstation's RTX 3060. After 4 hours of training, the model now knows that "lime application at 2 tons/acre raised pH from 5.4 to 6.2 in the east plot last year." The next time a gardener asks about soil pH, the AI gives ARC-specific advice.

**As an** AI operator, **I want** to fine-tune the local AI model on ARC-specific data, **so that** the AI gives contextually relevant answers based on our actual conditions and history.

**Acceptance Criteria:**
- [ ] Fine-tuning pipeline accepts structured data (CSV, JSON, text)
- [ ] Training runs on local GPU without cloud access
- [ ] Model performance is evaluated before/after fine-tuning
- [ ] Previous model versions are preserved (rollback capability)
- [ ] Fine-tuning completes within reasonable time (4-12 hours for typical dataset)
- [ ] RAG index is updated alongside fine-tuning for retrieval-augmented generation

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Local LLM (Qwen2.5-7B) | software | live |
| GPU (RTX 3060, 12GB VRAM) | hardware | live |
| Fine-tuning pipeline (LoRA/QLoRA) | software | partial |
| ARC-specific training data | data | planned |
| RAG pipeline | software | partial |

**Lab Mapping:** HALops (workstation) — Qwen2.5-7B with GPU inference. RTX 3060 (12GB VRAM) available for training. Fine-tuning pipeline partially implemented. Archivist building RAG infrastructure. Rated R1 because components exist but the end-to-end pipeline needs integration.

---

### US-49: ARC Time-Capsule Backup Written to Cold Storage
**Priority:** P3/R1 | **Category:** Preservation

> **Scenario:** Every quarter, the preservation officer creates a "time capsule" — a complete snapshot of the ARC's digital civilization. This includes: all container configurations and data volumes, the full offline knowledge base (Wikipedia, medical, legal, maps, 3D models), all community records (wiki, governance decisions, medical records, farm data), and the AI model with its local fine-tuning. The snapshot is written to a cold-storage drive, GPG-encrypted, and stored in a fireproof safe. If the ARC's servers are ever completely destroyed, this drive can rebuild the digital infrastructure from scratch.

**As a** preservation officer, **I want** to write a complete ARC digital backup to cold storage, **so that** our collective knowledge and records survive even catastrophic hardware loss.

**Acceptance Criteria:**
- [ ] Full backup includes all service data, knowledge bases, and configurations
- [ ] Backup is encrypted (GPG) and compressed
- [ ] Backup is written to physically separate cold storage (external drive)
- [ ] Restore procedure is documented and tested
- [ ] Backup includes the HAL drive build system (self-bootstrapping)
- [ ] Quarterly schedule with verification after each backup

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Disaster recovery backup script | software | partial |
| External storage drive(s) | hardware | live |
| GPG encryption | software | live |
| Documented restore procedure | document | partial |
| Backup verification/testing | integration | planned |

**Lab Mapping:** Disaster recovery project (`~/projects/disaster-recovery/`) has an 8-hour full lab restore design covering flash configs/VMs + bulk data + remote rsync. GPG encryption is available. External drives (external-storage) exist. The quarterly automated backup process is not yet scripted end-to-end. Rated R1.

---

### US-50: Inter-ARC Trade Ledger Synchronized Over Mesh
**Priority:** P3/R3 | **Category:** Finance

> **Scenario:** ARC-Alpha has surplus dried beans but needs solar panel mounting brackets. ARC-Beta, 10 km away, has a metalworking shop and needs food. The trade coordinators at each site negotiate a deal over mesh radio (US-44): 50 kg of dried beans for 20 custom brackets. Each coordinator enters the trade into their local ledger. The next time the mesh has bandwidth, the ledger entries synchronize — both sites now have a matching record of the transaction. Over time, the ledger builds a picture of inter-community trade flows, helping both sites plan production for what the other needs.

**As a** trade coordinator, **I want** a ledger that synchronizes trade records between ARC sites over mesh, **so that** inter-community commerce is tracked and both parties have matching records.

**Acceptance Criteria:**
- [ ] Trade entries include items, quantities, values, and both parties
- [ ] Ledger synchronizes between sites when mesh connectivity is available
- [ ] Conflict resolution handles simultaneous edits at both sites
- [ ] Trade history is searchable by item, partner site, and date range
- [ ] Offline-first — entries are recorded locally even without connectivity
- [ ] Audit trail for all ledger changes

**Prerequisites & Dependencies:**
| Requirement | Type | Status |
|-------------|------|--------|
| Distributed ledger application | software | conceptual |
| Mesh network between sites (US-44) | infra | designed |
| Conflict-free replicated data type (CRDT) or similar | software | conceptual |
| LDAP identity for trade coordinators | integration | live |

**Lab Mapping:** No distributed ledger application exists. Mesh networking is designed but not deployed. This requires both the mesh infrastructure (US-44) and a purpose-built application. Rated R3.

---

## Appendix A: Lab Capability Inventory → Story Mapping

This table maps every relevant reference lab service to the user stories it supports.

| Service | Host | Stories |
|---------|------|---------|
| Kiwix | Server-1 | US-01, US-27 |
| Calibre-Web | Server-1 | US-01, US-35 |
| Digital Library | Server-1 | US-01, US-35 |
| Atlas | Server-1 | US-13 |
| 3D Model Search | Server-1 | US-28 |
| Manyfold | Server-1 | US-28 |
| F-Droid Server | Server-1 | US-42 |
| WiFi QR Codes | Server-1 | US-42 |
| Video Archival | Server-1 | US-30 |
| OPNsense (FIREWALL) | FIREWALL | US-16, US-17, US-24 |
| Suricata IDS | FIREWALL | US-16 |
| WireGuard VPN | FIREWALL | US-17 |
| Unbound DNS | FIREWALL | US-24 |
| NUT UPS | FIREWALL | US-09 |
| FreePBX / Asterisk | pbx-1 | US-11 |
| SIP desk phone (model A) | sip-phone-a | US-11 |
| SIP desk phone (model B) / 7945G | sip-phone-bc | US-11 |
| Lab Softphone | portal | US-11 |
| DC-1 / DC-2 (AD DNS) | DC-1/DC-2 | US-18, US-24 |
| Vaultwarden | Server-2 | US-08 |
| Authentik SSO | Server-2 | US-18, US-06, US-19 |
| LDAP Account Manager | Server-2 | US-18 |
| Grocy | Server-2 | US-14, US-31 |
| Tandoor Recipes | Server-2 | US-14, US-31 |
| HortusFox | Server-2 | US-33 |
| FarmOS | Server-2 | US-15 |
| OpenEMR | Server-2 | US-06, US-38 |
| Cannery | Server-2 | US-19 |
| Jellyfin | Server-2 | US-30 |
| Tube Archivist | Server-2 | US-30 |
| Navidrome | Server-2 | US-32 |
| Moodle | Server-2 | US-26 |
| Anki Sync | Server-2 | US-34 |
| Wiki.js | Server-2 | US-45, US-47 |
| Trilium Notes | Server-2 | US-45 |
| Taiga | Server-2 | US-39 |
| Vikunja | Server-2 | US-39 |
| Paperless-ngx | Server-2 | US-21 |
| Stirling-PDF | Server-2 | US-21 |
| CyberChef | Server-2 | US-40 |
| LibreTranslate | Server-2 | US-36 |
| LanguageTool | Server-2 | US-36 |
| Firefly III | Server-2 | US-37 |
| Actual Budget | Server-2 | US-37 |
| Part-DB | Server-2 | US-46 |
| InvenTree | Server-2 | US-46 |
| Nextcloud | Server-2 | US-25 |
| Syncthing | Server-2 | US-25 |
| Home Assistant | Server-2 | US-02, US-10 |
| Frigate NVR | Server-2 | US-04 |
| Uptime Kuma | Server-2 | US-20, US-23 |
| Healthchecks | Server-2 | US-23 |
| Prometheus | Server-2 | US-09, US-20 |
| Grafana | Server-2 | US-02, US-09, US-10, US-16, US-20 |
| Alertmanager | Server-2 | US-16, US-20 |
| ntfy | Server-2 | US-03, US-04, US-05, US-07, US-10, US-20 |
| Prosody XMPP | Server-2 | US-12 |
| Zot OCI Registry | Server-2 | US-23, US-43 |
| Central Proxy | Server-2 | US-18 |
| Gitea | Server-2 | US-45 |
| ArchiveBox | Server-2 | US-45 |
| HALops | workstation | US-22, US-41, US-48 |
| Qwen3-TTS | workstation | US-20 |
| Archivist | workstation | US-22, US-30 |
| Creality K1C | local | US-29 |
| NooElec SDR | local | US-07 |
| Baofeng/Quansheng radios | local | US-05, US-12 |

## Appendix B: Gap Analysis — Critical Deficiencies

These are **P0 or P1 stories at R2 or R3 readiness** — capabilities where failure is life-threatening or mission-critical, but the implementation doesn't exist yet.

| Story | Priority | Readiness | Gap | What's Needed |
|-------|----------|-----------|-----|---------------|
| **US-02** | P0 | R3 | Solar power | Solar panels, charge controllers, inverters, battery bank, monitoring integration |
| **US-03** | P0 | R3 | Diesel backup | Generator, auto-transfer switch, fuel tank with sensor, controller |
| **US-09** | P0 | R3 | Server UPS | Rack UPS units for Server-1/Server-2 (FIREWALL UPS exists, monitoring stack complete) |
| **US-10** | P0 | R3 | Water monitoring | pH/turbidity/chlorine sensors, motorized valve, controller, MQTT integration |
| **US-04** | P0 | R2 | Perimeter cameras | PoE cameras, PoE switch, Frigate NVR deployment, camera VLAN |
| **US-05** | P0 | R2 | Emergency mesh broadcast | Deployed LoRa nodes, Reticulum hub, LXMF relay, mesh repeaters |
| **US-07** | P0 | R2 | Weather alerting | 162 MHz antenna, NWR receiver (SDR or dedicated), SAME decoder |
| **US-12** | P1 | R2 | Mesh messaging | Same as US-05 — shared mesh infrastructure |

### Observations

1. **Power is the #1 gap.** Three of the seven critical gaps (US-02, US-03, US-09) are power-related. Without power, nothing else works. Solar + diesel + UPS is the foundation layer.

2. **Mesh communications are the #2 gap.** US-05 and US-12 share the same infrastructure (Reticulum + LoRa). Building the mesh closes both gaps simultaneously.

3. **Water monitoring (US-10) is the most conceptual P0.** It requires physical sensor hardware, plumbing integration, and automation — the most hardware-intensive gap to close.

4. **Weather alerting (US-07) is the cheapest gap to close.** A $15 antenna and an existing SDR (NooElec NESDR SMArt) could provide basic NWR reception. The software stack (RTL-SDR → SAME decoder → ntfy) is straightforward.

5. **Camera/NVR (US-04) is well-designed but needs hardware.** Frigate NVR is registered in the service catalog. The software deployment is straightforward once cameras and PoE infrastructure are procured.

6. **The monitoring stack is already complete.** Every gap that needs alerting (power, water, weather, cameras) can plug into the existing Prometheus → Grafana → ntfy pipeline. The sensors are missing, not the monitoring.

---

*This document is maintained in the `pitt-street-labs/arc` repository. Last updated: 2026-02-11.*
