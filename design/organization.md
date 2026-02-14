# ARC Organization

> Community structure, role assignments, and cross-training matrix for a ~150-person ARC community

## Overview

ARC serves a community of approximately 150 people organized into 6 functional groups with 50 active rotation slots filled by 44 unique roles. Every role has a designated primary and a backup drawn from a **different** group, ensuring no single group failure can eliminate a critical capability.

Approximately 50 people are in active rotation annually across the 6 groups. The remaining ~100 are general population (children, elderly, reserves, general labor) with limited ARC access.

---

## Group Structure

| # | Group | Slots | Mission |
|---|-------|-------|---------|
| 1 | Food & Water | 5 | Sustenance — water treatment, cooking, livestock, foraging, preservation |
| 2 | Shelter & Facilities | 8 | Infrastructure — construction, electrical, plumbing, manufacturing, sanitation, salvage |
| 3 | Energy & Power | 6 | Power generation and distribution — solar, diesel, battery, grid, fuel, alternative |
| 4 | Protection & Security | 15 | Defense — command, guard, armory, recon, SIGINT, intelligence, engineering, combat medic |
| 5 | Administration | 8 | Governance — leadership, medical, logistics, records, legal, finance, personnel |
| 6 | Specialized Services | 8 | Education, comms, IT, mechanical, agriculture, pharmacy, aerial, welfare |
| | **Total** | **50** | |

---

## Role Directory

### Group 1: Food & Water (5 slots)

| # | Role | ARC Access Level | Primary Services |
|---|------|-----------------|-----------------|
| 1 | Water Treatment Specialist | Domain: water, medical reference | Kiwix (WHO guidelines), FarmOS, OpenEMR (contamination protocols) |
| 2 | Head Cook / Nutrition Manager | Domain: food, inventory | Tandoor Recipes, Grocy, Kiwix (nutrition reference) |
| 3 | Livestock / Fishery Manager | Domain: agriculture, veterinary | FarmOS, Kiwix (animal husbandry), Calibre-Web (livestock manuals) |
| 4 | Forager / Wild Food Specialist | Domain: botany, toxicology | Kiwix (plant ID), Atlas (terrain/foraging zones), Calibre-Web |
| 5 | Food Preservation Specialist | Domain: food safety, chemistry | Kiwix (canning/preservation), Grocy (inventory), Tandoor |

### Group 2: Shelter & Facilities (8 slots)

| # | Role | ARC Access Level | Primary Services |
|---|------|-----------------|-----------------|
| 6 | Facilities Manager | Domain: all facilities | Vikunja (work orders), Homebox (asset tracking), InvenTree |
| 7 | Carpenter / Builder | Domain: construction | Kiwix (building codes), Manyfold (hardware models), Calibre-Web |
| 8 | Electrician | Domain: electrical, safety | Kiwix (NEC reference), Part-DB (components), Atlas (wiring maps) |
| 9 | Plumber / HVAC Tech | Domain: plumbing, water systems | Kiwix (plumbing codes), InvenTree (parts), Calibre-Web |
| 10 | Welder / Metalworker | Domain: metallurgy, fabrication | Kiwix (welding reference), Manyfold (fixtures/jigs), Calibre-Web |
| 11 | 3D Print Operator | Domain: manufacturing, CAD | Manyfold (193k models), 3D Search, InvenTree (filament stock) |
| 12 | Sanitation Engineer | Domain: waste, public health | Kiwix (sanitation guides), FarmOS (composting), OpenEMR |
| 13 | Salvage Coordinator | Domain: materials, logistics | Homebox (asset inventory), InvenTree (parts), OpenBoxes (supply chain) |

### Group 3: Energy & Power (6 slots)

| # | Role | ARC Access Level | Primary Services |
|---|------|-----------------|-----------------|
| 14 | Solar Technician | Domain: solar, electrical | Home Assistant (panel data), Kiwix (solar reference), Calibre-Web |
| 15 | Generator Mechanic | Domain: engines, fuel systems | Kiwix (engine manuals), Vikunja (maintenance schedule), InvenTree |
| 16 | Battery Systems Specialist | Domain: batteries, chemistry | Kiwix (battery reference), Home Assistant (charge data), Part-DB |
| 17 | Power Distribution Electrician | Domain: electrical, grid | Kiwix (NEC), Atlas (grid maps), Grafana (power metrics) |
| 18 | Fuel / Energy Analyst | Domain: logistics, planning | Grocy (fuel inventory), Grafana (consumption trends), Vikunja |
| 19 | Wind / Hydro Technician | Domain: renewable, mechanical | Kiwix (turbine reference), Home Assistant (output data), Calibre-Web |

### Group 4: Protection & Security (15 slots, 9 unique roles)

| # | Role | Slots | ARC Access Level | Primary Services |
|---|------|-------|-----------------|-----------------|
| 20 | Security Chief | 1 | Full security domain | Frigate NVR, Atlas, FreePBX, Grafana, ntfy, Prosody XMPP |
| 21 | Watch Commander | 2 | Security: cameras, comms, alerts | Frigate NVR, Atlas, FreePBX, ntfy |
| 22 | Gate Guard | 4 | Security: cameras, basic alerts | Frigate NVR, ntfy, Prosody XMPP |
| 23 | Armorer / Weapons Specialist | 1 | Domain: weapons, maintenance | Cannery (ammo tracking), Kiwix (TM manuals), InvenTree (parts) |
| 24 | Scout / Recon | 2 | Domain: terrain, navigation | Atlas (mapping/routing), Meshtastic (mesh comms), Kiwix |
| 25 | Radio / SIGINT Operator | 1 | Domain: signals, communications | OpenWebRX+ (SDR), tar1090 (ADS-B), Kiwix (frequency DB) |
| 26 | Intelligence Analyst | 1 | Domain: analysis, OSINT | Super-Deredactor (OCR/forensics), CyberChef, Manticore Search |
| 27 | Defensive Engineer | 1 | Domain: fortification, engineering | Atlas (terrain), Manyfold (defensive structures), Kiwix |
| 28 | Combat Medic | 2 | Domain: trauma, triage | OpenEMR, Kiwix (TCCC/IFAK guides), Calibre-Web (field medicine) |

### Group 5: Administration (8 slots)

| # | Role | ARC Access Level | Primary Services |
|---|------|-----------------|-----------------|
| 29 | Community Director | Full administrative access | All services (oversight), Taiga (project management), Wiki.js |
| 30 | Medical Officer (Doctor/PA) | Domain: medical (full) | OpenEMR (full EMR), Kiwix (medical reference), LibreTranslate |
| 31 | Nurse / Medical Assistant | Domain: medical (clinical) | OpenEMR (patient records), Kiwix (nursing reference) |
| 32 | Logistics / Supply Officer | Domain: supply chain, inventory | OpenBoxes, Grocy, InvenTree, Homebox, Grafana (storage metrics) |
| 33 | Records Clerk / Archivist | Domain: records, document management | Paperless-ngx, Stirling-PDF (OCR), Wiki.js, Manticore Search |
| 34 | Judge / Arbitrator | Domain: legal, governance | Corpus Juris (legal RAG), Wiki.js (governance records), Kiwix |
| 35 | Treasurer / Accountant | Domain: finance, trade | Firefly III (trade ledger), Actual Budget, Grocy (inventory valuation) |
| 36 | HR / Personnel Manager | Domain: personnel, training | LDAP Account Manager, Moodle (training records), Wiki.js |

### Group 6: Specialized Services (8 slots)

| # | Role | ARC Access Level | Primary Services |
|---|------|-----------------|-----------------|
| 37 | Educator / Teacher | Domain: education, reference | Moodle (LMS), Kiwix (reference), Anki (flashcards), Calibre-Web |
| 38 | Radio Operator / Comms | Domain: communications, radio | FreePBX, Prosody XMPP, ntfy, Meshtastic, OpenWebRX+ |
| 39 | IT / Systems Administrator | Full system access | All infrastructure services, Grafana, Prometheus, Gitea |
| 40 | Mechanic / Small Engine Repair | Domain: mechanical, engines | Kiwix (repair manuals), InvenTree (parts), Vikunja (work orders) |
| 41 | Farmer / Crop Manager | Domain: agriculture | FarmOS, Kiwix (agriculture reference), Atlas (field maps), HortusFox |
| 42 | Herbalist / Pharmacist | Domain: pharmacy, botany | OpenEMR (prescriptions), Kiwix (pharmacology), Calibre-Web |
| 43 | Drone Operator / Aerial Recon | Domain: aerial, mapping | Atlas (mapping), Frigate (feeds), Kiwix (drone reference) |
| 44 | Childcare / Community Welfare | Domain: education, welfare | Moodle, Jellyfin (entertainment), Kiwix, Nextcloud (documents) |

---

## Cross-Training Matrix

Every role has a designated backup in a **different** group. Pairings are based on skill overlap to minimize training burden.

| Primary Role | Group | Backup Role | Backup Group | Skill Overlap |
|-------------|-------|-------------|--------------|---------------|
| Water Treatment Specialist | Food | Plumber / HVAC Tech | Shelter | Water systems, chemistry |
| Head Cook / Nutrition Manager | Food | Nurse / Medical Assistant | Admin | Nutrition, dietary health |
| Livestock / Fishery Manager | Food | Farmer / Crop Manager | Special | Animal husbandry, agriculture |
| Forager / Wild Food Specialist | Food | Scout / Recon | Protection | Terrain navigation, botany |
| Food Preservation Specialist | Food | Herbalist / Pharmacist | Special | Chemistry, shelf life, safety |
| Facilities Manager | Shelter | Logistics / Supply Officer | Admin | Asset tracking, work orders |
| Carpenter / Builder | Shelter | Defensive Engineer | Protection | Construction, fortification |
| Electrician | Shelter | Power Distribution Electrician | Energy | Electrical codes, wiring |
| Plumber / HVAC Tech | Shelter | Water Treatment Specialist | Food | Water systems, plumbing |
| Welder / Metalworker | Shelter | Mechanic / Small Engine | Special | Metal fabrication, repair |
| 3D Print Operator | Shelter | IT / Systems Administrator | Special | Digital fabrication, CAD, systems |
| Sanitation Engineer | Shelter | Farmer / Crop Manager | Special | Composting, waste management |
| Salvage Coordinator | Shelter | Logistics / Supply Officer | Admin | Inventory, materials |
| Solar Technician | Energy | Electrician | Shelter | Electrical, panel wiring |
| Generator Mechanic | Energy | Mechanic / Small Engine | Special | Engine repair, fuel systems |
| Battery Systems Specialist | Energy | IT / Systems Administrator | Special | UPS/power systems, electronics |
| Power Distribution Electrician | Energy | Electrician | Shelter | Electrical distribution |
| Fuel / Energy Analyst | Energy | Treasurer / Accountant | Admin | Resource tracking, planning |
| Wind / Hydro Technician | Energy | Solar Technician | Energy | *Exception: same group, different specialization* |
| Security Chief | Protection | Community Director | Admin | Leadership, operational oversight |
| Watch Commander | Protection | Radio Operator / Comms | Special | Communications, shift management |
| Gate Guard | Protection | General population (trained) | — | Basic security procedures |
| Armorer / Weapons Specialist | Protection | Mechanic / Small Engine | Special | Mechanical repair, precision tools |
| Scout / Recon | Protection | Forager / Wild Food Specialist | Food | Terrain navigation, fieldcraft |
| Radio / SIGINT Operator | Protection | Radio Operator / Comms | Special | Radio operation, signals |
| Intelligence Analyst | Protection | Records Clerk / Archivist | Admin | Document analysis, research |
| Defensive Engineer | Protection | Carpenter / Builder | Shelter | Construction, engineering |
| Combat Medic | Protection | Medical Officer | Admin | Trauma care, triage |
| Community Director | Admin | Security Chief | Protection | Leadership, crisis management |
| Medical Officer | Admin | Combat Medic | Protection | Medical practice, triage |
| Nurse / Medical Assistant | Admin | Head Cook / Nutrition Manager | Food | Patient care, nutrition |
| Logistics / Supply Officer | Admin | Facilities Manager | Shelter | Inventory, asset management |
| Records Clerk / Archivist | Admin | Intelligence Analyst | Protection | Document management, analysis |
| Judge / Arbitrator | Admin | Community Director | Admin | *Exception: same group, different role* |
| Treasurer / Accountant | Admin | Fuel / Energy Analyst | Energy | Resource accounting, planning |
| HR / Personnel Manager | Admin | Educator / Teacher | Special | Training, personnel records |
| Educator / Teacher | Special | HR / Personnel Manager | Admin | Training programs, records |
| Radio Operator / Comms | Special | Radio / SIGINT Operator | Protection | Radio operation, protocols |
| IT / Systems Administrator | Special | 3D Print Operator | Shelter | Digital systems, troubleshooting |
| Mechanic / Small Engine | Special | Generator Mechanic | Energy | Engine repair, maintenance |
| Farmer / Crop Manager | Special | Livestock / Fishery Manager | Food | Agriculture, land management |
| Herbalist / Pharmacist | Special | Medical Officer | Admin | Pharmacology, patient care |
| Drone Operator / Aerial Recon | Special | Scout / Recon | Protection | Reconnaissance, mapping |
| Childcare / Community Welfare | Special | Educator / Teacher | Special | *Exception: same group, complementary roles* |

**Notes on exceptions:**
- Wind/Hydro ↔ Solar: Both in Energy, but distinct specializations with shared electrical fundamentals
- Judge ↔ Community Director: Both in Admin, but the legal and executive functions are deliberately separate
- Childcare ↔ Educator: Both in Specialized, but the youth welfare and education missions overlap naturally

---

## General Population (~100 people)

The remaining ~100 community members are not in active role rotation but contribute through general labor, apprenticeship, and reserve capacity.

### Demographics (estimated)

| Segment | Count | Notes |
|---------|-------|-------|
| Children (0-12) | 20-25 | Education via Moodle, entertainment via Jellyfin |
| Adolescents (13-17) | 10-15 | Apprenticeship tracks, limited ARC access |
| Elderly (65+) | 15-20 | Advisory roles, light duty, knowledge transfer |
| Pregnant / nursing | 3-5 | Reduced duty, medical monitoring |
| Specialist reserves | 10-15 | Cross-trained backups not in primary rotation |
| General labor pool | 30-40 | Agriculture, construction, maintenance support |

### ARC Access for General Population

General population has **read-only access** to a limited set of services:

| Service | Purpose | Access Level |
|---------|---------|-------------|
| Kiwix | Reference library (Wikipedia, StackExchange) | Read-only |
| Moodle | Education — courses, quizzes | Student role |
| Jellyfin | Entertainment — movies, TV, music | Playback only |
| Navidrome | Music streaming | Playback only |
| Nextcloud | Shared documents, calendars | Read/write (personal folder) |
| Prosody XMPP | Community messaging | Send/receive |
| Wiki.js | Community knowledge base | Read-only |
| Anki Sync | Flashcard study | Personal decks |

General population does **not** have access to:
- ARCAI query interface (no AI-assisted queries)
- Administrative services (OpenEMR, Grocy, InvenTree, etc.)
- Security services (Frigate, Cannery, etc.)
- Infrastructure services (Grafana, Prometheus, etc.)

---

## Rotation Policy

- **Annual rotation** — roles rotate once per year with 2-week overlap for handoff
- **Mandatory cross-training** — every role holder must train their backup during overlap period
- **Emergency succession** — if a role holder is incapacitated, their cross-trained backup assumes the role immediately
- **Apprenticeship pathway** — adolescents (13-17) shadow roles for 6 months before eligible for rotation
- **Retirement transition** — elderly transitioning out of active rotation serve as advisors for 1 rotation cycle

### Rotation Exceptions

- **Medical Officer** — does not rotate unless a replacement with equivalent training is available
- **IT / Systems Administrator** — does not rotate without 3-month handoff (system knowledge is deep)
- **Security Chief** — rotates only with Community Director approval

---

## AD Group Mapping (Future)

When ARCAI role-gating is implemented, AD groups will map to ARC access domains:

| AD Group | ARC Domain Access |
|----------|------------------|
| `ARC-Food` | food, water, agriculture, inventory |
| `ARC-Shelter` | construction, electrical, plumbing, manufacturing |
| `ARC-Energy` | power, solar, batteries, fuel |
| `ARC-Security` | defense, cameras, weapons, signals, intelligence |
| `ARC-Admin` | medical, legal, finance, logistics, personnel, governance |
| `ARC-Special` | education, communications, IT, mechanical, aerial |
| `ARC-General` | reference (read-only), entertainment, messaging |
| `ARC-Leadership` | all domains (Community Director, Security Chief) |
