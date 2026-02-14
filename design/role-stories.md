# ARC Role Stories

> 14 representative stories showing how each group interacts with ARC through the 7-step pattern

## How to Read These Stories

Each story follows the [interaction pattern](ARC-ARCHITECTURE.md#interaction-pattern):

1. **AUTHENTICATE** — User logs in at a community terminal
2. **QUERY** — User asks a natural language question
3. **CLASSIFY** — ARCAI determines domain, urgency, sensitivity, authorization
4. **ROUTE** — ARCAI selects processing backend(s)
5. **PROCESS** — Backend(s) execute
6. **RESPOND** — Results displayed with sources and follow-up actions
7. **ACT** — Optional cross-service actions triggered

Each story includes a dependency chain (which services must respond), a required services table with fallbacks, and notes on invalid assumptions.

---

## Group 1: Food & Water

### Story 1: Water Treatment Specialist — "Is this water source safe?"

**Scenario:** A scouting team found a creek 2 km north. The Water Treatment Specialist needs to determine if it's safe for collection and what treatment is required.

#### Interaction

**Step 1: AUTHENTICATE**
Water Treatment Specialist logs in at community terminal. Authentik SSO validates AD credentials. AD group `ARC-Food` grants access to water, medical reference, and agriculture domains.

**Step 2: QUERY**
> "We found a creek at grid reference NE-7-14. Surface water, slow-moving, downstream of an abandoned farm. Is it safe for collection? What treatment do we need?"

**Step 3: CLASSIFY**
- **Domain:** Water safety (primary), Medical reference (secondary)
- **Urgency:** Urgent — community water supply decision
- **Sensitivity:** Public — all group leaders should see this assessment
- **Authorization:** `ARC-Food` group — authorized for water domain

**Step 4: ROUTE**
- ARCengine GPU — medical reasoning about waterborne pathogens
- ARCstore → Kiwix (WHO water treatment guidelines, CDC waterborne disease reference)
- ARCstore → Calibre-Web (water purification manuals)
- Atlas API — terrain/elevation data for the grid reference

**Step 5: PROCESS**
1. Atlas returns terrain data: creek location, upstream land use, elevation profile
2. Kiwix returns WHO guidelines for surface water near agricultural land
3. ARCengine synthesizes: agricultural runoff risk (pesticides, nitrates, animal waste), recommended treatment chain
4. Calibre-Web returns relevant chapters from water purification manuals

**Step 6: RESPOND**
```
ASSESSMENT: Surface water downstream of abandoned farm — HIGH RISK

Contaminants of concern:
  - Agricultural runoff (pesticides, fertilizer nitrates)
  - Animal waste (E. coli, Giardia, Cryptosporidium)
  - Sediment (turbidity)

Required treatment chain:
  1. Settle/pre-filter (reduce turbidity)
  2. Chemical treatment (chlorine 2 mg/L, 30 min contact time)
     OR boil (rolling boil 1 minute, 3 minutes above 2000m)
  3. Activated carbon filter (removes chemical contaminants)
  4. Test: pH 6.5-8.5, residual chlorine 0.2-0.5 mg/L

Sources: WHO Guidelines for Drinking-water Quality (4th ed),
         CDC Wilderness Water Treatment, Field Water Purification Manual

NOTE: Without lab testing, assume worst case. Boiling alone does NOT
remove chemical contaminants from agricultural runoff.
```

**Step 7: ACT**
- Create task in Vikunja: "Set up water collection point at NE-7-14 — treatment chain required"
- Log water source in FarmOS: location, assessment date, risk level
- Send ntfy notification to Community Director: "New water source assessed — HIGH RISK, treatable"

#### Dependency Chain

```
User Query
  ├── Atlas (terrain/location) ─────────────┐
  ├── Kiwix (WHO guidelines) ───────────────┤
  ├── Calibre-Web (purification manuals) ───┼── ARCengine GPU (synthesis)
  └── ARCengine (medical reasoning) ────────┘        │
                                                      ├── Response to user
                                                      ├── Vikunja (create task)
                                                      ├── FarmOS (log source)
                                                      └── ntfy (notify leadership)
```

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Atlas | Grid reference lookup | Yes | Paper maps with grid overlay |
| Kiwix | WHO/CDC water guidelines | Yes | Printed WHO guidelines (must stock) |
| Calibre-Web | Treatment manuals | Helpful | Kiwix water entries sufficient for basics |
| ARCengine GPU | Risk synthesis | Yes | CPU fallback (slower, adequate) |
| Vikunja | Task creation | Optional | Paper work order |
| FarmOS | Source logging | Optional | Paper water source log |
| ntfy | Leadership notification | Optional | Radio/runner |

---

### Story 2: Head Cook — "Plan this week's meals for 150"

**Scenario:** Sunday evening. The Head Cook needs to plan meals for the coming week based on what's actually in stock.

#### Interaction

**Step 1: AUTHENTICATE**
Head Cook logs in. AD group `ARC-Food` confirmed.

**Step 2: QUERY**
> "Plan meals for 150 people for the next 7 days. We need breakfast, lunch, and dinner. Use what we have in stock. Flag anything we're running low on."

**Step 3: CLASSIFY**
- **Domain:** Food, inventory
- **Urgency:** Routine — weekly planning
- **Sensitivity:** Public — meal plans posted for community
- **Authorization:** `ARC-Food` — authorized

**Step 4: ROUTE**
- Grocy API — current stock levels, expiration dates
- Tandoor API — recipe database, nutritional info, portion scaling
- ARCengine CPU — meal planning optimization (routine, no GPU needed)

**Step 5: PROCESS**
1. Grocy returns current inventory: 200 kg rice, 50 kg beans, 30 kg flour, 15 kg sugar, seasonal vegetables (squash, carrots, onions), 20 kg dried meat, 50 L preserved fruit, 100 L milk (goats)
2. Tandoor returns recipes matching available ingredients, scaled to 150 portions
3. ARCengine optimizes: caloric targets (~2,200 kcal/person/day), nutritional balance, expiration-first usage, variety across the week

**Step 6: RESPOND**
```
WEEKLY MEAL PLAN — Feb 12-18 (150 people)

Monday:
  Breakfast: Rice porridge with preserved fruit (rice: 15kg, fruit: 8L)
  Lunch: Bean and vegetable stew, flatbread (beans: 8kg, flour: 5kg)
  Dinner: Dried meat rice bowl with roasted squash (meat: 3kg, rice: 12kg)

[... Tuesday through Sunday ...]

INVENTORY ALERTS:
  ⚠ Flour: 30 kg remaining, 7-day usage: 25 kg — 5 kg buffer only
  ⚠ Dried meat: 20 kg remaining, 7-day usage: 18 kg — resupply needed
  ⚠ Squash: 3 units expiring Feb 14 — prioritized for Mon/Tue

WEEKLY TOTALS: Rice 90kg, Beans 45kg, Flour 25kg, Meat 18kg
CALORIC AVG: 2,180 kcal/person/day (target: 2,200)

Sources: Grocy inventory (queried 18:30), Tandoor recipe DB
```

**Step 7: ACT**
- Update Grocy: projected consumption for the week (reserved stock)
- Create Vikunja task: "Source additional flour and dried meat — 7-day buffer critical"
- Post meal plan to Nextcloud shared calendar
- Send ntfy to Logistics Officer: "Flour and dried meat resupply needed this week"

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Grocy | Current inventory | Yes | Manual pantry count |
| Tandoor | Recipe database | Yes | Paper recipe binders |
| ARCengine CPU | Meal optimization | Helpful | Manual planning (slower) |
| Vikunja | Task creation | Optional | Paper task list |
| Nextcloud | Calendar posting | Optional | Printed meal plan posted on bulletin board |
| ntfy | Resupply alert | Optional | Radio to Logistics |

---

## Group 2: Shelter & Facilities

### Story 3: 3D Print Operator — "Find a replacement part"

**Scenario:** The community's water pump failed. The impeller is cracked. No physical replacement available. Can we print one?

#### Interaction

**Step 1: AUTHENTICATE**
3D Print Operator logs in. AD group `ARC-Shelter` confirmed.

**Step 2: QUERY**
> "I need a replacement impeller for a Flotec FP5172 sump pump. The original is 4.5 inches diameter, 6 vanes. Can we print one?"

**Step 3: CLASSIFY**
- **Domain:** Manufacturing, water systems (cross-domain)
- **Urgency:** Urgent — water pump is critical infrastructure
- **Sensitivity:** Public
- **Authorization:** `ARC-Shelter` — authorized for manufacturing domain

**Step 4: ROUTE**
- ARCstore → 3D Search (keyword: "pump impeller", "sump pump impeller")
- ARCstore → Manyfold (browse water pump category)
- ARCstore → Kiwix (pump specifications, material requirements)
- InvenTree API — filament stock check
- ARCengine CPU — material suitability assessment

**Step 5: PROCESS**
1. 3D Search returns 47 impeller models, 3 close matches for sump pump applications
2. Manyfold provides STL previews, dimensions, print settings for best match
3. Kiwix returns pump specifications: max RPM 3,450, max temp 40°C, water contact
4. InvenTree returns filament stock: PETG (2.1 kg white, 0.8 kg black), PLA (3.5 kg), ASA (0.5 kg)
5. ARCengine assesses: PETG suitable (water-resistant, adequate temp range, sufficient toughness at 3,450 RPM for impeller loads)

**Step 6: RESPOND**
```
MATCH FOUND: "Universal Sump Pump Impeller" (Model #STL-47291)
  Dimensions: 4.25" diameter (adjustable via scaling to 4.5"), 6 vanes
  Designer notes: "Tested to 3,000 RPM in water"

PRINT RECOMMENDATION:
  Material: PETG (water-resistant, 80°C heat deflection)
  Infill: 100% (structural part under load)
  Layer height: 0.15mm (smooth vane surfaces)
  Orientation: Vanes up, supports on hub
  Print time: ~6 hours
  Filament needed: ~120g PETG

STOCK CHECK: ✅ PETG available — 2.1 kg white (17x this part)

⚠ LIMITATIONS:
  - 3D printed impeller is TEMPORARY — expect 3-6 months lifespan
  - Monitor for vibration (imbalance from print artifacts)
  - Scale to 105% if original was 4.5" (model is 4.25")

Sources: 3D Search index, Manyfold catalog, Kiwix pump specifications
```

**Step 7: ACT**
- Log print job in Vikunja: "Print replacement impeller — URGENT, water pump down"
- Deduct 120g PETG from InvenTree stock (upon print start confirmation)
- Create follow-up task: "Source permanent replacement impeller for Flotec FP5172"
- Notify Plumber via ntfy: "Replacement impeller printing — ETA 6 hours"

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| 3D Search | Model lookup | Yes | Browse Manyfold manually |
| Manyfold | STL preview/download | Yes | Cannot print without model |
| InvenTree | Filament stock | Yes | Manual filament check |
| Kiwix | Pump specifications | Helpful | Measure original part |
| ARCengine CPU | Material assessment | Helpful | Operator experience |

---

### Story 4: Electrician — "Wire gauge for 200A solar feed"

**Scenario:** The Solar Technician is installing a new 200A feed from the solar array to the battery bank, 50 feet run. The Electrician needs to verify wire gauge.

#### Interaction

**Step 1: AUTHENTICATE**
Electrician logs in. AD group `ARC-Shelter` confirmed.

**Step 2: QUERY**
> "What wire gauge do I need for a 200A DC feed, 48V system, 50 foot run? Copper, in conduit."

**Step 3: CLASSIFY**
- **Domain:** Electrical, safety
- **Urgency:** Routine — planning phase
- **Sensitivity:** Public
- **Authorization:** `ARC-Shelter` — authorized

**Step 4: ROUTE**
- ARCengine CPU — voltage drop calculation (routine math, no GPU needed)
- ARCstore → Kiwix (NEC wire gauge tables, ampacity ratings)

**Step 5: PROCESS**
1. Kiwix returns NEC Table 310.16 (ampacity) and voltage drop calculation formula
2. ARCengine calculates: 200A × 50ft × 2 (round trip) = 20,000 A·ft. At 48V, 3% max voltage drop = 1.44V. Required circular mils = 20,000 × 10.75 / 1.44 = 149,306 CM → 3/0 AWG (167,800 CM)
3. Cross-reference NEC ampacity: 3/0 AWG copper in conduit at 75°C = 200A ✓

**Step 6: RESPOND**
```
WIRE GAUGE: 3/0 AWG Copper

Calculation:
  Load: 200A DC at 48V
  Run: 50 ft (100 ft round trip)
  Max voltage drop: 3% = 1.44V
  Required: 149,306 circular mils → 3/0 AWG (167,800 CM)

NEC Ampacity: 3/0 AWG copper at 75°C in conduit = 200A ✅
Voltage drop at 200A: 2.57% (within 3% limit) ✅

ALSO NEEDED:
  - Overcurrent protection: 200A DC breaker or fuse
  - Grounding: #4 AWG equipment ground (NEC 250.122)
  - Conduit: 1.5" minimum for two 3/0 AWG conductors

Sources: NEC 2023 Table 310.16, Chapter 9 Table 8, Article 250.122
```

**Step 7: ACT**
- Check InvenTree: "3/0 AWG copper" — display stock quantity
- Create Vikunja task if stock insufficient: "Source 100+ ft 3/0 AWG copper wire"

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Kiwix | NEC tables | Yes | Printed NEC code book |
| ARCengine CPU | Voltage drop calculation | Helpful | Calculator + tables |
| InvenTree | Wire stock check | Optional | Physical inventory |

---

## Group 3: Energy & Power

### Story 5: Solar Technician — "Panel output dropped 30%"

**Scenario:** Morning check shows the solar array is producing 30% less than yesterday at the same time of day. Weather is clear.

#### Interaction

**Step 1: AUTHENTICATE**
Solar Technician logs in. AD group `ARC-Energy` confirmed.

**Step 2: QUERY**
> "Solar array output dropped 30% compared to yesterday. Same time of day, clear sky both days. What's wrong and what do I check?"

**Step 3: CLASSIFY**
- **Domain:** Solar, electrical
- **Urgency:** Urgent — power generation degradation
- **Sensitivity:** Public — affects community power budget
- **Authorization:** `ARC-Energy` — authorized

**Step 4: ROUTE**
- Home Assistant API — historical solar output data (yesterday vs today)
- Grafana API — power metrics trending
- ARCstore → Kiwix (solar panel troubleshooting guides)
- ARCengine CPU — diagnostic reasoning

**Step 5: PROCESS**
1. Home Assistant returns: Yesterday 10 AM: 4.2 kW. Today 10 AM: 2.9 kW. Delta: -31%
2. Grafana returns 7-day trend: steady degradation over 3 days (not sudden)
3. Kiwix returns solar troubleshooting checklist
4. ARCengine correlates: gradual decline + clear weather = not inverter failure (that would be sudden). Likely causes ranked: (1) panel soiling/debris, (2) connection degradation, (3) partial shading from new obstruction, (4) panel degradation

**Step 6: RESPOND**
```
DIAGNOSIS: Gradual 30% decline over 3 days — NOT sudden failure

Most likely causes (ranked):
  1. Panel soiling/debris (70% probability)
     - Check: Visual inspection, clean panels, re-measure
     - Common after dust storms, pollen season, bird droppings

  2. Partial shading from new obstruction (15%)
     - Check: Inspect array at current sun angle for shadows
     - New vegetation, moved equipment, structural changes

  3. Connection degradation (10%)
     - Check: Junction box connections, combiner box, wire damage
     - Measure string voltages — uneven = connection issue

  4. Panel degradation (5%)
     - Check: Hotspot inspection (IR camera if available)
     - Individual panel output comparison

RECOMMENDED ACTION:
  Start with visual inspection and cleaning (resolves 70% of cases)
  Time: 30 minutes

Historical data: 4.2 kW → 3.8 kW → 3.2 kW → 2.9 kW (3-day trend)

Sources: Home Assistant solar metrics, Kiwix Solar Panel Maintenance Guide
```

**Step 7: ACT**
- Create Vikunja task: "Inspect and clean solar array — 30% output drop"
- Assign to Solar Technician, priority: Urgent
- Log diagnostic query in FarmOS energy log

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Home Assistant | Historical output data | Yes | Manual meter readings log |
| Kiwix | Troubleshooting guide | Yes | Printed solar manual |
| ARCengine CPU | Diagnostic reasoning | Helpful | Manual troubleshooting checklist |
| Grafana | Trend visualization | Helpful | Home Assistant data sufficient |

---

### Story 6: Generator Mechanic — "Oil change interval for this model"

**Scenario:** Community has a Honda EU7000is generator. Mechanic needs maintenance schedule and oil specs.

#### Interaction

**Step 1: AUTHENTICATE**
Generator Mechanic logs in. AD group `ARC-Energy` confirmed.

**Step 2: QUERY**
> "What's the oil change interval for a Honda EU7000is generator? What oil type? How much?"

**Step 3: CLASSIFY**
- **Domain:** Engines, maintenance
- **Urgency:** Routine
- **Sensitivity:** Public
- **Authorization:** `ARC-Energy` — authorized

**Step 4: ROUTE**
- ARCstore → Kiwix (Honda generator manuals)
- ARCstore → Calibre-Web (small engine maintenance reference)
- ARCengine CPU — extract specs

**Step 5: PROCESS**
1. Kiwix returns Honda EU7000is owner's manual data
2. Calibre-Web supplements with general generator maintenance best practices

**Step 6: RESPOND**
```
HONDA EU7000is OIL CHANGE SCHEDULE

First oil change: 20 hours (break-in)
Subsequent: Every 100 hours of operation

Oil type: SAE 10W-30 (API SJ or later)
  - Below 0°C: SAE 5W-30
  - Above 30°C: SAE 10W-40 acceptable
Capacity: 1.5 quarts (1.42 L) with filter change

MAINTENANCE SCHEDULE:
  Every 50 hrs: Check oil level, clean air filter
  Every 100 hrs: Change oil, inspect spark plug
  Every 200 hrs: Replace air filter, clean spark arrestor
  Every 300 hrs: Replace spark plug
  Every 500 hrs: Valve clearance check

Sources: Honda EU7000is Owner's Manual (Kiwix), Generator Maintenance Guide
```

**Step 7: ACT**
- Create recurring Vikunja task: "Honda EU7000is oil change — every 100 hours"
- Check InvenTree for SAE 10W-30 oil stock
- Log maintenance schedule in Vikunja with hour-meter tracking

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Kiwix | Equipment manual | Yes | Physical manual (if available) |
| Calibre-Web | Supplemental reference | Helpful | Kiwix sufficient for basics |
| ARCengine CPU | Spec extraction | Helpful | Manual reading |
| Vikunja | Maintenance scheduling | Optional | Paper maintenance log |
| InvenTree | Parts/consumables check | Optional | Physical inventory |

---

## Group 4: Protection & Security

### Story 7: Armorer — "BCG cleaning procedure for M4 after 500 rounds"

**Scenario:** Armorer is performing post-range maintenance on an M4 carbine after an extended defensive training session.

#### Interaction

**Step 1: AUTHENTICATE**
Armorer logs in. AD group `ARC-Security` confirmed.

**Step 2: QUERY**
> "Full BCG cleaning procedure for M4A1 after 500 rounds. Include carbon removal steps and inspection points."

**Step 3: CLASSIFY**
- **Domain:** Weapons maintenance
- **Urgency:** Routine — scheduled maintenance
- **Sensitivity:** Role-restricted — `ARC-Security` only
- **Authorization:** `ARC-Security` — authorized

**Step 4: ROUTE**
- ARCstore → Kiwix (TM 9-1005-319-10: M4/M4A1 Operator's Manual)
- ARCstore → Calibre-Web (weapons maintenance reference)
- Cannery API — current ammo inventory for this caliber
- ARCengine CPU — procedure extraction

**Step 5: PROCESS**
1. Kiwix returns TM 9-1005-319-10 BCG maintenance section
2. Cannery returns: 5.56 NATO inventory — 2,400 rounds remaining (500 expended today)
3. ARCengine extracts and formats step-by-step procedure

**Step 6: RESPOND**
```
M4A1 BOLT CARRIER GROUP (BCG) — FULL CLEANING PROCEDURE
(Post 500-round session, per TM 9-1005-319-10)

1. DISASSEMBLY
   - Clear weapon, remove magazine, lock bolt to rear, verify clear
   - Push rear takedown pin, separate upper/lower
   - Pull charging handle and BCG from upper receiver
   - Remove firing pin retaining pin → firing pin → cam pin → bolt

2. CARBON REMOVAL (BCG)
   - Soak bolt tail and carrier key in CLP (15 min)
   - Scrub carbon ring on bolt tail with brass brush (DO NOT use steel)
   - Clean gas rings with dental pick (check gas ring alignment — gaps must NOT align)
   - Clean carrier key interior with pipe cleaner + CLP
   - Scrub bolt face with brass brush, clear extractor channel

3. INSPECTION POINTS (500-round check)
   ✓ Bolt lugs — cracks, chipping (replace bolt if ANY cracks)
   ✓ Cam pin hole — elongation (replace bolt if oval)
   ✓ Firing pin tip — mushrooming (replace if flattened)
   ✓ Gas rings — stack 3 rings, close gaps (replace if bolt slides under own weight)
   ✓ Extractor spring — tension (should snap back firmly)
   ✓ Ejector spring — function check (press with punch, should return)

4. LUBRICATION
   - CLP on bolt lugs (light coat), cam pin, carrier rails
   - One drop CLP in carrier key
   - DO NOT over-lubricate firing pin channel

5. REASSEMBLY (reverse order)
   - Bolt → cam pin (oriented correctly) → firing pin → retaining pin
   - Function check: charging handle, bolt release, safety selector

AMMO STATUS: 5.56 NATO — 2,400 rounds remaining (500 expended today)

Sources: TM 9-1005-319-10 (Operator's Manual, M4/M4A1), Cannery inventory
```

**Step 7: ACT**
- Update Cannery: log 500 rounds expended, note training session date
- Create Vikunja task if any inspection points fail: "Replace [component] — M4A1 S/N [xxx]"
- Log maintenance in weapons maintenance record

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Kiwix | TM manual reference | Yes | Physical TM manual |
| Cannery | Ammo inventory update | Yes | Paper ammo log |
| ARCengine CPU | Procedure formatting | Helpful | Read TM directly |
| Vikunja | Replacement task | Optional | Paper maintenance log |

---

### Story 8: Intelligence Analyst — "Analyze this recovered document"

**Scenario:** A patrol recovered a partially redacted document from an abandoned building. The Intelligence Analyst needs to extract maximum information.

#### Interaction

**Step 1: AUTHENTICATE**
Intelligence Analyst logs in. AD group `ARC-Security` confirmed.

**Step 2: QUERY**
> "Analyze this recovered document. It's partially redacted and water-damaged. I need OCR, deredaction attempt, and cross-reference against our intelligence database."

*[Document image uploaded via Searchhead]*

**Step 3: CLASSIFY**
- **Domain:** Intelligence, OSINT
- **Urgency:** Urgent — time-sensitive intelligence
- **Sensitivity:** Leadership-only — intelligence product
- **Authorization:** `ARC-Security` — authorized for intelligence domain

**Step 4: ROUTE**
- Super-Deredactor → 4-engine OCR consensus + redaction analysis
- ARCengine GPU — document understanding (vision model, emergency preempt)
- ARCstore → Manticore Search (cross-reference extracted terms)
- ARCstore → X-Bookmarks Archive (OSINT cross-reference)

**Step 5: PROCESS**
1. Super-Deredactor runs 4 OCR engines, consensus text extraction, identifies 3 redacted regions
2. Deredaction CNN attempts recovery on redacted regions (2 of 3 partially recovered)
3. ARCengine GPU processes document image with vision model — identifies document type, organization, date
4. Manticore Search cross-references extracted names, locations, terms against existing corpus
5. X-Bookmarks Archive checked for related OSINT context

**Step 6: RESPOND**
```
DOCUMENT ANALYSIS — CLASSIFICATION: LEADERSHIP-ONLY

OCR CONFIDENCE: 87% (water damage reduced clarity in sections 2, 4)

EXTRACTED TEXT:
  [Full OCR text with confidence scores per section]

DEREDACTION RESULTS:
  Region 1 (header): RECOVERED — organization letterhead identified as [...]
  Region 2 (paragraph 3): PARTIAL — 60% confidence on 4 words
  Region 3 (signature block): FAILED — insufficient pixel data

CROSS-REFERENCES:
  - Location "Pine Ridge" — matches Atlas POI at grid SE-12-8 (3.2 km south)
  - Name "[redacted]" — no matches in existing intelligence corpus
  - Date format suggests document is 3-6 months old

ASSESSMENT: [ARCengine analysis of document significance]

Sources: Super-Deredactor OCR (4-engine consensus), Manticore Search, Atlas POI database
```

**Step 7: ACT**
- Archive original + analysis in Paperless-ngx (leadership-only tag)
- Create intelligence brief in Wiki.js (restricted page)
- Notify Security Chief via ntfy: "Intelligence product ready for review"
- Pin location in Atlas: "Pine Ridge — referenced in recovered document"

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Super-Deredactor | OCR + deredaction | Yes | Manual transcription (much slower) |
| ARCengine GPU | Vision model analysis | Yes | CPU fallback (much slower) |
| Manticore Search | Cross-reference | Helpful | Manual search across services |
| Paperless-ngx | Document archival | Yes | Physical filing |
| Atlas | Location cross-reference | Helpful | Paper maps |

---

### Story 9: Watch Commander — "Perimeter alert on north camera"

**Scenario:** 0230 hours. Frigate triggers a person detection alert on the north perimeter camera. Watch Commander needs rapid assessment.

#### Interaction

**Step 1: AUTHENTICATE**
Watch Commander is already authenticated (persistent security session during watch).

**Step 2: QUERY**
> "Person detected on north camera. Show me the feed, overlay terrain, and alert the response team."

**Step 3: CLASSIFY**
- **Domain:** Security, emergency
- **Urgency:** EMERGENCY — potential perimeter breach
- **Sensitivity:** Security-restricted
- **Authorization:** `ARC-Security` — authorized, Watch Commander role confirmed

**Step 4: ROUTE**
- Frigate NVR API — live camera feed + detection snapshot + event history
- Atlas API — terrain overlay for north perimeter sector
- FreePBX API — emergency alert to response team
- ntfy — push notification to Security Chief, Gate Guards
- ARCengine GPU — PREEMPTIVE (emergency preempts all other GPU tasks)

**Step 5: PROCESS**
1. Frigate returns: detection snapshot, bounding box, confidence 94%, event timestamp 02:28:47
2. Atlas returns: north perimeter terrain — tree line 50m, approach routes, dead ground
3. ARCengine GPU processes snapshot: single individual, on foot, no visible weapons, approaching from northeast tree line
4. FreePBX initiates emergency broadcast to extensions 100, 200, 300 (guard stations)
5. ntfy sends push: "ALERT: Person detected, North perimeter, 0228"

**Step 6: RESPOND**
```
🔴 PERIMETER ALERT — NORTH SECTOR

Detection: 1 person, on foot, NE approach from tree line
Confidence: 94%
Time: 02:28:47
Camera: North-1

[Live feed link]    [Detection snapshot]    [Terrain overlay]

Approach analysis:
  - Tree line 50m NE of perimeter
  - 2 concealed approach routes identified
  - Nearest gate: North Gate (Guard Post 2)

ACTIONS TAKEN:
  ✅ FreePBX emergency alert sent (ext 100, 200, 300)
  ✅ ntfy push sent to Security Chief, all Gate Guards
  ✅ Frigate recording to continuous mode (north sector)

RECOMMENDED:
  - Dispatch Scout team to NE tree line
  - Illuminate north sector (if flood lights available)
  - Gate Guard 2 to elevated watch
```

**Step 7: ACT**
- FreePBX: emergency ring to guard stations (already triggered)
- ntfy: push alerts (already sent)
- Frigate: switch north cameras to continuous recording
- Atlas: mark detection point with timestamp for patrol briefing
- Log event in Wiki.js security log

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Frigate NVR | Camera feed + detection | Yes | Physical patrol (no advance warning) |
| Atlas | Terrain overlay | Helpful | Mental map, paper maps |
| FreePBX | Emergency alert | Yes | Radio, manual alarm |
| ntfy | Push notifications | Yes | FreePBX intercom sufficient |
| ARCengine GPU | Image analysis | Helpful | Human visual assessment of feed |

---

## Group 5: Administration

### Story 10: Medical Officer — "Emergency appendicitis decision support"

**Scenario:** A community member presents with right lower quadrant pain, fever 101.4°F, nausea. Medical Officer suspects appendicitis and needs decision support for a potential field appendectomy.

#### Interaction

**Step 1: AUTHENTICATE**
Medical Officer logs in. AD group `ARC-Admin` confirmed with full medical domain access.

**Step 2: QUERY**
> "EMERGENCY. 34-year-old male, RLQ pain 8/10 for 12 hours, fever 101.4, rebound tenderness positive, Rovsing sign positive. Suspected appendicitis. Decision support for field appendectomy."

**Step 3: CLASSIFY**
- **Domain:** Medical — SAFETY-CRITICAL
- **Urgency:** EMERGENCY — life-threatening condition
- **Sensitivity:** Medical confidential (HIPAA-equivalent)
- **Authorization:** `ARC-Admin` with medical role — authorized for full medical domain

**SAFETY-CRITICAL PROTOCOL ENGAGED:** Medical emergency queries use structured decision trees, NOT free LLM generation. ARCengine provides curated clinical pathways, not creative output.

**Step 4: ROUTE**
- ARCengine GPU — PREEMPTIVE ALLOCATION (emergency, bumps all other tasks)
- ARCstore → Kiwix (WHO surgical guidelines, emergency surgery protocols)
- ARCstore → Calibre-Web (field surgery manuals, ATLS reference)
- OpenEMR API — patient record lookup, allergy check, medication history

**Step 5: PROCESS**
1. OpenEMR returns patient record: no allergies, no medications, last vitals normal, no surgical history
2. Kiwix returns WHO emergency surgery guidelines for appendectomy
3. Calibre-Web returns field surgery reference chapters
4. ARCengine GPU presents STRUCTURED DECISION TREE (not free-form advice):

**Step 6: RESPOND**
```
🔴 EMERGENCY MEDICAL DECISION SUPPORT
⚠ THIS IS A DECISION AID — CLINICAL JUDGMENT REMAINS WITH THE PHYSICIAN

ALVARADO SCORE ASSESSMENT:
  Migration of pain to RLQ:     +1
  Anorexia:                     [ASK PATIENT]
  Nausea/vomiting:              +1
  RLQ tenderness:               +2
  Rebound tenderness:           +1
  Elevated temperature:         +1
  Leukocytosis:                 [LAB NEEDED]
  Left shift:                   [LAB NEEDED]
  CURRENT SCORE: 6+ (probable appendicitis)
  SCORE ≥7 = surgical intervention recommended

DECISION TREE:
  IF Alvarado ≥ 7 AND no lab available:
    → Clinical diagnosis sufficient for surgical intervention
    → Proceed to operative planning

  IF Alvarado 5-6:
    → Observe 6-12 hours with serial exams
    → IV antibiotics (if available): Ceftriaxone 1g + Metronidazole 500mg
    → Reassess — if worsening, proceed to surgery

FIELD APPENDECTOMY CHECKLIST:
  □ Confirm no contraindications (review patient record)
  □ Informed consent (patient or next of kin)
  □ Anesthesia plan: [depends on available agents]
  □ Surgical approach: McBurney incision (open)
  □ Antibiotic prophylaxis: pre-incision
  □ Blood type: [CHECK OpenEMR] — cross-match if transfusion risk
  □ Post-op monitoring plan: vitals q15min × 4hrs, then q1hr × 24hrs

PATIENT RECORD: No allergies, no medications, no prior surgery
BLOOD TYPE: [Not on file — MUST determine before surgery]

Sources: WHO Emergency Surgery Manual, ATLS 10th Ed, Alvarado Scoring System
         OpenEMR Patient Record (queried just now)
```

**Step 7: ACT**
- Update OpenEMR: log emergency encounter, vitals, assessment, Alvarado score
- ntfy ALERT to Nurse/Medical Assistant: "Emergency surgical case — report to medical"
- FreePBX: page Combat Medic (surgical assist)
- Create OpenEMR surgical note template (pre-populated with patient data)
- Log blood type determination as critical pending task

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| OpenEMR | Patient record | Yes | Paper chart (if exists) |
| Kiwix | Surgical guidelines | Yes | Printed surgical manual (MUST stock) |
| Calibre-Web | Field surgery reference | Helpful | Kiwix sufficient for basics |
| ARCengine GPU | Decision tree presentation | Yes (emergency preempt) | CPU fallback acceptable |
| FreePBX | Staff paging | Yes | Runner to fetch staff |
| ntfy | Alert notification | Yes | FreePBX intercom |

**Critical Assumption:** The Medical Officer is a licensed physician or PA capable of performing surgery. ARCAI provides decision support, NOT clinical direction. See [ARC-DECISIONS.md](ARC-DECISIONS.md) assumption A-8.

---

### Story 11: Records Clerk — "OCR and archive this found manual"

**Scenario:** A patrol recovered a paper copy of a diesel engine repair manual. Records Clerk needs to digitize and index it.

#### Interaction

**Step 1: AUTHENTICATE**
Records Clerk logs in. AD group `ARC-Admin` confirmed.

**Step 2: QUERY**
> "I have a 200-page diesel engine repair manual (Caterpillar 3306). Scan is complete. OCR it, archive it, and make it searchable."

*[PDF scan uploaded via Searchhead]*

**Step 3: CLASSIFY**
- **Domain:** Records management, document processing
- **Urgency:** Routine — no emergency
- **Sensitivity:** Public — reference material
- **Authorization:** `ARC-Admin` — authorized for records domain

**Step 4: ROUTE**
- Stirling-PDF → OCR processing (200 pages)
- Paperless-ngx API → archive with metadata
- ARCstore → Manticore Search (index for full-text search)
- ARCengine CPU — metadata extraction (title, author, categories)

**Step 5: PROCESS**
1. Stirling-PDF OCRs all 200 pages (batch processing, ~10 minutes)
2. ARCengine CPU extracts metadata: "Caterpillar 3306 Service Manual", categories: diesel, engine, repair, heavy equipment
3. Paperless-ngx archives OCR'd PDF with metadata tags
4. Manticore Search indexes full text for corpus-wide search

**Step 6: RESPOND**
```
DOCUMENT ARCHIVED SUCCESSFULLY

Title: Caterpillar 3306 Diesel Engine Service Manual
Pages: 200 (198 OCR'd successfully, 2 pages too damaged)
OCR Quality: 94% average confidence
File size: 45 MB (original scan), 12 MB (compressed OCR PDF)

Tags assigned: diesel, engine, repair, caterpillar, heavy-equipment, maintenance
Archive ID: PAPER-2026-0211-001
Location: Paperless-ngx → Equipment Manuals → Diesel Engines

Full-text search: ✅ Indexed in Manticore Search
Cross-references found:
  - Kiwix: "Diesel engine" (Wikipedia) — linked
  - Calibre-Web: 3 related diesel reference books
  - InvenTree: CAT 3306 parts category exists (12 items)

DAMAGED PAGES: Pages 47, 128 — too water-damaged for OCR
  Recommendation: Manual transcription of critical content

Sources: Stirling-PDF OCR, Paperless-ngx, Manticore Search
```

**Step 7: ACT**
- Document archived in Paperless-ngx (complete)
- Indexed in Manticore Search (complete)
- Create Vikunja task: "Manual transcription needed — pages 47, 128 of CAT 3306 manual"
- Notify Generator Mechanic via ntfy: "New diesel engine manual archived — CAT 3306"
- Update Wiki.js equipment reference: link to new manual

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Stirling-PDF | OCR processing | Yes | Manual transcription (extremely slow) |
| Paperless-ngx | Document archive | Yes | Physical filing + manual index |
| Manticore Search | Full-text indexing | Helpful | Paperless-ngx built-in search |
| ARCengine CPU | Metadata extraction | Helpful | Manual tagging |

---

## Group 6: Specialized Services

### Story 12: Educator — "Create a lesson on basic first aid"

**Scenario:** The Educator is preparing a first aid training course for adolescents entering the apprenticeship program.

#### Interaction

**Step 1: AUTHENTICATE**
Educator logs in. AD group `ARC-Special` confirmed.

**Step 2: QUERY**
> "Create a basic first aid lesson plan for teenagers. Cover bleeding control, CPR, choking, and burns. Include a quiz. This is for Moodle."

**Step 3: CLASSIFY**
- **Domain:** Education, medical reference
- **Urgency:** Routine — course planning
- **Sensitivity:** Public — educational content
- **Authorization:** `ARC-Special` — authorized for education domain; medical reference read-only

**Step 4: ROUTE**
- ARCstore → Kiwix (Red Cross first aid, TCCC simplified, CPR guidelines)
- ARCengine CPU — lesson plan generation (routine, no GPU needed)
- Moodle API — course structure creation

**Step 5: PROCESS**
1. Kiwix returns American Red Cross first aid guidelines, CPR procedures (2025 AHA guidelines)
2. ARCengine CPU generates age-appropriate lesson plan with 4 modules
3. Lesson formatted for Moodle import (quiz questions, completion tracking)

**Step 6: RESPOND**
```
LESSON PLAN: Basic First Aid (Adolescent Level)
Duration: 4 hours (2 classroom + 2 hands-on)
Prerequisites: None
Certification: First Aid Basics (apprenticeship requirement)

MODULE 1: Bleeding Control (45 min)
  - Direct pressure technique
  - Tourniquet application (when and how)
  - Wound packing basics
  - Practice: bandaging station (simulated wounds)
  Quiz: 5 questions (70% pass required)

MODULE 2: CPR (60 min)
  - Scene safety and assessment
  - Compression-only CPR (hands-only)
  - Full CPR with rescue breaths
  - AED operation (if available)
  - Practice: CPR mannequin station
  Quiz: 5 questions

MODULE 3: Choking Response (30 min)
  - Conscious adult/child: abdominal thrusts
  - Conscious infant: back blows + chest thrusts
  - Unconscious: CPR protocol
  Quiz: 3 questions

MODULE 4: Burn Treatment (30 min)
  - Classification: 1st, 2nd, 3rd degree
  - Immediate treatment: cool water (NOT ice), cover loosely
  - When to escalate to Medical Officer
  Quiz: 3 questions

FINAL ASSESSMENT: 16 questions total, 75% to pass

Ready to import to Moodle? [Confirm to create course]

Sources: American Red Cross First Aid Manual, AHA CPR Guidelines 2025 (Kiwix)
```

**Step 7: ACT**
- Create course in Moodle: "Basic First Aid" with 4 modules + quizzes
- Assign to apprenticeship track (adolescent learners)
- Notify Medical Officer via ntfy: "First aid course created — review requested before launch"
- Create Vikunja task: "Medical Officer review of first aid course content"

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Kiwix | Medical/first aid reference | Yes | Printed first aid manual |
| Moodle | Course delivery | Yes | Classroom instruction with handouts |
| ARCengine CPU | Lesson plan generation | Helpful | Manual lesson planning |
| ntfy | Review notification | Optional | Direct request to Medical Officer |

---

### Story 13: IT Admin — "Server-2 disk at 85%, identify cleanup targets"

**Scenario:** Prometheus alert: Server-2 root filesystem at 85% usage. IT Admin needs to find what to clean up.

#### Interaction

**Step 1: AUTHENTICATE**
IT Admin logs in. AD group `ARC-Special` with full system access confirmed.

**Step 2: QUERY**
> "Server-2 disk at 85%. Show me what's using the most space and what's safe to clean up."

**Step 3: CLASSIFY**
- **Domain:** IT infrastructure
- **Urgency:** Urgent — approaching disk full (system degradation at 90%+)
- **Sensitivity:** IT-restricted
- **Authorization:** `ARC-Special` with IT Admin role — full system access

**Step 4: ROUTE**
- Prometheus API — disk usage metrics, per-mount breakdown
- Portal container dashboard — per-container resource usage
- ARCengine CPU — cleanup recommendation

**Step 5: PROCESS**
1. Prometheus returns: `/` at 85%, `/data` at 72%, individual container volume sizes
2. Portal container API returns: top consumers — Tube Archivist (45 GB), Jellyfin (38 GB cache), Nextcloud (22 GB), Loki logs (15 GB)
3. ARCengine identifies safe cleanup targets based on service criticality

**Step 6: RESPOND**
```
SERVER-2 DISK USAGE ANALYSIS

Filesystem: /dev/sda2 (root)
Usage: 85% (340 GB / 400 GB)
Free: 60 GB
Critical threshold: 90% (systemd-oomd triggers)

TOP CONSUMERS:
  1. Tube Archivist cache:    45 GB  [SAFE TO CLEAN — regenerable]
  2. Jellyfin transcode:      38 GB  [SAFE TO CLEAN — temporary files]
  3. Nextcloud data:          22 GB  [DO NOT CLEAN — user data]
  4. Loki log retention:      15 GB  [SAFE TO TRIM — reduce retention]
  5. Podman image layers:     12 GB  [SAFE TO PRUNE — unused images]
  6. Container logs:           8 GB  [SAFE TO ROTATE]

RECOMMENDED CLEANUP:
  Priority 1: Jellyfin transcode cache      -38 GB  (zero impact)
  Priority 2: Podman image prune            -12 GB  (old images only)
  Priority 3: Container log rotation         -6 GB  (keep 7 days)
  Priority 4: Loki retention 30d → 14d      -8 GB  (reduced history)
  TOTAL RECOVERABLE:                        ~64 GB  (→ 69% usage)

Commands:
  podman exec jellyfin rm -rf /cache/transcodes/*
  podman image prune -a --filter "until=168h"
  # Loki: update retention_period in config

⚠ DO NOT clean: Nextcloud, OpenEMR, Paperless-ngx, Vaultwarden (user data)

Sources: Prometheus node_exporter, Portal container dashboard
```

**Step 7: ACT**
- Execute cleanup commands (with IT Admin confirmation)
- Update Grafana annotation: "Disk cleanup performed — recovered XX GB"
- Create Healthchecks ping for disk usage monitoring
- Silence Prometheus disk alert for 1 hour during cleanup

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Prometheus | Disk metrics | Yes | SSH + `df -h` |
| Portal (container API) | Per-container usage | Helpful | `podman stats` manually |
| ARCengine CPU | Cleanup recommendations | Helpful | Manual assessment |
| Grafana | Annotation | Optional | Log in Wiki.js |

---

### Story 14: Radio Operator — "Unknown signal on 462.5 MHz"

**Scenario:** Radio Operator detected an unfamiliar signal during routine monitoring. Needs identification and assessment.

#### Interaction

**Step 1: AUTHENTICATE**
Radio Operator logs in. AD group `ARC-Special` confirmed. Cross-domain access to communications + security (radio signals may be security-relevant).

**Step 2: QUERY**
> "Unknown signal on 462.5625 MHz, FM modulation, intermittent, ~2 second bursts every 30 seconds. Not one of ours. Identify and assess."

**Step 3: CLASSIFY**
- **Domain:** Communications, security (cross-domain)
- **Urgency:** Urgent — unknown radio activity near community
- **Sensitivity:** Security-relevant — notify Security Chief
- **Authorization:** `ARC-Special` — authorized for communications; security notification triggered

**Step 4: ROUTE**
- ARCstore → Kiwix (FRS/GMRS frequency allocations, radio reference)
- OpenWebRX+ API — tune to frequency, record sample
- ARCengine CPU — signal analysis context
- Atlas API — direction-finding overlay (if antenna array available)

**Step 5: PROCESS**
1. Kiwix returns: 462.5625 MHz = FRS Channel 1 / GMRS Channel 1 (shared, license-free)
2. OpenWebRX+ recording captured: FM voice, partial intelligible speech, 2 speakers
3. ARCengine analyzes: FRS radios, typical range 0.5-2 miles depending on terrain, consumer-grade equipment

**Step 6: RESPOND**
```
SIGNAL IDENTIFICATION

Frequency: 462.5625 MHz
Identification: FRS Channel 1 / GMRS Channel 1
  - Family Radio Service (license-free, consumer walkie-talkies)
  - Max legal power: 2W (FRS) / 50W (GMRS with license)
  - Typical range: 0.5-2 miles (FRS), up to 5 miles (GMRS)

Modulation: FM (consistent with FRS/GMRS)
Pattern: 2-second voice bursts every ~30 seconds (conversation)

ASSESSMENT:
  - Consumer-grade radios (FRS/GMRS walkie-talkies)
  - At least 2 individuals communicating
  - Estimated distance: 0.5-2 miles based on signal strength
  - Direction: [requires directional antenna for bearing]

THREAT LEVEL: LOW-MODERATE
  - Could be: travelers, scavengers, hunters, another community
  - NOT military/tactical (would use different frequencies and protocols)
  - Intermittent pattern suggests casual communication, not coordinated operation

RECOMMENDED ACTIONS:
  1. Continue monitoring (record all transmissions)
  2. Deploy directional antenna for bearing if available
  3. Cross-reference with patrol reports (any visual contacts?)
  4. Do NOT transmit on this frequency (reveals our radio capability)

Sources: Kiwix FCC Frequency Allocation Table, OpenWebRX+ recording
```

**Step 7: ACT**
- Notify Security Chief via ntfy: "Unknown FRS radio activity detected — 462.5625 MHz, 0.5-2 mi range"
- Notify Intelligence Analyst via ntfy: "Radio intercept for analysis"
- Log in Wiki.js security log: signal details, timestamp, assessment
- OpenWebRX+: set continuous recording on 462.5625 MHz
- Create Atlas marker: "Radio activity detected" at estimated bearing (if available)

#### Required Services

| Service | Role | Required? | Fallback |
|---------|------|-----------|----------|
| Kiwix | Frequency database | Yes | Printed frequency allocation chart |
| OpenWebRX+ | SDR recording | Yes | Standalone SDR receiver |
| ARCengine CPU | Signal context analysis | Helpful | Operator knowledge |
| Atlas | Direction-finding overlay | Optional | Compass bearing + paper map |
| ntfy | Security notification | Yes | Radio to Security Chief |

---

## Story Summary Matrix

| # | Group | Role | Query | Urgency | Key Services | Cross-Service Actions |
|---|-------|------|-------|---------|-------------|----------------------|
| 1 | Food | Water Treatment | Water source safety | Urgent | Atlas, Kiwix, ARCengine GPU | Vikunja, FarmOS, ntfy |
| 2 | Food | Head Cook | Weekly meal plan | Routine | Grocy, Tandoor, ARCengine CPU | Vikunja, Nextcloud, ntfy |
| 3 | Shelter | 3D Print Operator | Replacement part | Urgent | 3D Search, Manyfold, InvenTree | Vikunja, ntfy |
| 4 | Shelter | Electrician | Wire gauge calc | Routine | Kiwix, ARCengine CPU | InvenTree |
| 5 | Energy | Solar Technician | Panel output drop | Urgent | Home Assistant, Kiwix, Grafana | Vikunja |
| 6 | Energy | Generator Mechanic | Oil change interval | Routine | Kiwix, Calibre-Web | Vikunja, InvenTree |
| 7 | Protection | Armorer | BCG cleaning | Routine | Kiwix, Cannery | Vikunja |
| 8 | Protection | Intel Analyst | Document analysis | Urgent | Super-Deredactor, ARCengine GPU | Paperless-ngx, Wiki.js, ntfy |
| 9 | Protection | Watch Commander | Perimeter alert | EMERGENCY | Frigate, Atlas, FreePBX, ntfy | Wiki.js |
| 10 | Admin | Medical Officer | Appendicitis | EMERGENCY | OpenEMR, Kiwix, ARCengine GPU | FreePBX, ntfy |
| 11 | Admin | Records Clerk | OCR + archive | Routine | Stirling-PDF, Paperless-ngx | Vikunja, Wiki.js, ntfy |
| 12 | Special | Educator | First aid lesson | Routine | Kiwix, Moodle | Vikunja, ntfy |
| 13 | Special | IT Admin | Disk cleanup | Urgent | Prometheus, Portal API | Grafana |
| 14 | Special | Radio Operator | Unknown signal | Urgent | Kiwix, OpenWebRX+, ntfy | Atlas, Wiki.js |

### Urgency Distribution
- **EMERGENCY:** 2 stories (perimeter alert, medical emergency) — GPU preemption, immediate alerts
- **Urgent:** 7 stories — priority processing, leadership notification
- **Routine:** 5 stories — CPU processing, no interruptions

### Most-Referenced Services (across all 14 stories)
1. **Kiwix** — 11 stories (reference library for everything)
2. **ntfy** — 10 stories (notification hub)
3. **Vikunja** — 8 stories (task creation)
4. **ARCengine CPU** — 8 stories (routine inference)
5. **ARCengine GPU** — 4 stories (emergency/complex)
6. **Atlas** — 4 stories (mapping/terrain)
7. **InvenTree** — 4 stories (parts/stock check)
8. **Wiki.js** — 4 stories (record keeping)
