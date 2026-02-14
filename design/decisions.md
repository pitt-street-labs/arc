# ARC Decisions

> Blocking decisions that must be resolved before implementation, and declared assumptions that constrain the design

## Blocking Decisions

These decisions block forward progress on ARC implementation. Each has clear options and impact. Tracked as Gitea issues.

| # | Decision | Status | Gitea |
|---|----------|--------|-------|
| D-1 | Searchhead UX model | Open | arc#11 |
| D-2 | ARCAI implementation approach | Open | arc#12 |
| D-3 | Role-gating enforcement point | Open | arc#13 |
| D-4 | Safety-critical decision trees | Open | arc#14 |
| D-5 | ARCstore unified search technology | Open | arc#15 |
| D-6 | Terminal hardware standard | Open | arc#16 |
| D-7 | General population ARC access level | Open | arc#17 |

---

### D-1: Searchhead UX Model

**Question:** How do users interact with ARC at a terminal?

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **(a) Unified search bar** | Single text input, like a search engine. ARCAI routes behind the scenes. | Simple, familiar UX. One interface for everything. | Requires sophisticated query classification. Hard to surface structured data (dashboards, inventories). |
| **(b) Portal + chat overlay** | Current portal with service links, plus a chat panel for ARCAI queries. | Preserves direct service access. Incremental build on existing portal. | Two interaction models may confuse non-technical users. |
| **(c) Role-specific dashboards** | Each role sees a customized landing page with relevant services and a domain-specific query bar. | Best UX per role. Reduces information overload. | 44 dashboards to build and maintain. Role changes require dashboard reassignment. |

**Impact:** Determines frontend architecture, ARCAI integration pattern, and development effort.

**Recommendation:** Start with **(b)** — lowest risk, builds on existing portal, ARCAI chat can evolve into (a) or (c) based on usage patterns.

---

### D-2: ARCAI Implementation Approach

**Question:** How does ARCAI classify queries and route them?

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **(a) Fine-tuned classifier** | Train a small model (1-3B) specifically for query classification. Separate from the reasoning model. | Fast, deterministic, low resource usage. Can run on CPU. | Requires labeled training data. Must retrain when adding domains. |
| **(b) Prompt-engineered routing** | Use the general LLM with a system prompt that includes classification instructions and tool-use for routing. | No training needed. Flexible. Adapts to new domains via prompt changes. | Slower (full LLM inference for every classification). Less deterministic. Higher resource usage. |

**Impact:** Determines training data requirements, inference resource allocation, and reliability of routing.

**Recommendation:** Start with **(b)** for prototyping, migrate to **(a)** once query patterns are understood and training data exists. HALops pipeline is ready for fine-tuning when the time comes.

---

### D-3: Role-Gating Enforcement Point

**Question:** Where does ARC enforce role-based access control?

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **(a) UI filtering** | Searchhead hides services/domains the user's role can't access. Backend remains open. | Easy to implement. Good UX — users only see what they can use. | Security theater — direct API access bypasses filtering. |
| **(b) ARCAI refusal** | ARCAI checks role authorization before routing. Refuses unauthorized queries with explanation. | Centralized enforcement. Works regardless of UI. | ARCAI becomes a single point of failure for access control. Prompt injection risk. |
| **(c) Service-level AD group checks** | Each service enforces its own access control via AD group membership. ARCAI routes freely. | Defense in depth. Each service is independently secure. | 97 services to configure. Inconsistent enforcement across services. Some services don't support AD auth. |

**Impact:** Security model, implementation complexity, and trust boundaries.

**Recommendation:** **(b) + (c) layered** — ARCAI provides first-line refusal (fast feedback to user), services enforce their own access as defense in depth. This is the standard security pattern (don't rely on a single enforcement point).

---

### D-4: Safety-Critical Decision Trees

**Question:** How are procedures for safety-critical domains (medical, weapons, legal) curated and delivered?

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **(a) Manual curation** | Subject matter experts write structured decision trees. ARCAI presents them verbatim, no LLM generation. | Highest reliability. Reviewed by qualified humans. No hallucination risk. | Extremely labor-intensive. Requires SME access. Difficult to keep current. |
| **(b) LLM + human review** | ARCengine generates initial decision support, flagged for human review before delivery. Approved content is cached. | Faster initial content creation. LLM handles edge cases. | Review bottleneck. Risk of unreviewed content reaching users in edge cases. |
| **(c) Standards body import** | Import existing clinical guidelines (WHO, AHA), military TMs, legal codes directly. ARCAI navigates them. | Proven, peer-reviewed content. No hallucination. | Format conversion work. May not cover all scenarios. Copyright/licensing concerns. |

**Impact:** Quality assurance of life-safety information. Directly affects trust in ARC for medical/weapons/legal queries.

**Recommendation:** **(c) primary + (a) for gaps** — import existing standards (they're already in Kiwix/Calibre-Web), build decision tree navigation. Manual curation only for scenarios not covered by existing standards. Never use (b) alone for safety-critical content.

---

### D-5: ARCstore Unified Search Technology

**Question:** What search technology unifies the fragmented corpus?

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **(a) Manticore Search** | Already deployed. SQL-compatible full-text search. | Deployed, proven, fast. Good for keyword search. | No semantic search. No vector embeddings. Won't understand natural language queries well. |
| **(b) Meilisearch** | Planned for Archivist project. Typo-tolerant, fast, simple API. | Great UX — typo tolerance, instant results. Easy to deploy. | No vector/semantic search. Another search engine to maintain. |
| **(c) ChromaDB** | Planned for Corpus Juris RAG pipeline. Vector database for semantic search. | Semantic understanding — finds related content even with different wording. Essential for RAG. | Requires embedding generation (GPU/CPU intensive). Different paradigm from keyword search. |
| **(d) Manticore + ChromaDB** | Keyword search via Manticore, semantic search via ChromaDB. ARCAI decides which to use per query. | Best of both worlds. Keyword for precise lookups, semantic for natural language. | Two systems to maintain. Complexity. Must keep indexes in sync. |

**Impact:** Determines whether ARCAI can understand natural language queries or is limited to keyword matching. Directly affects the quality of every role story's "PROCESS" step.

**Recommendation:** **(d)** — both are needed. Manticore for structured/keyword queries (already deployed), ChromaDB for RAG/semantic queries (needed for ARCAI reasoning). The Archivist project should unify indexing so both are fed from the same pipeline. Drop Meilisearch to avoid 3-engine fragmentation.

---

### D-6: Terminal Hardware Standard

**Question:** What hardware do community members use to access ARC?

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **(a) Toughbooks only** | Ruggedized laptops at fixed stations. Standardized, field-proven. | Durable, repairable, consistent UX. Field-deployable. | Expensive to stockpile. Limited quantity. |
| **(b) Desktop terminals** | Salvaged desktops at fixed locations (mess hall, medical, armory, etc.). | Plentiful, cheap, repairable from parts. | Not portable. Fragile. Diverse hardware complicates support. |
| **(c) Mixed fleet** | Toughbooks for field roles (scouts, combat medic), desktops for fixed-location roles. | Right tool for the job. | Two support models. More spare parts variety. |
| **(d) Thin clients** | Raspberry Pi or similar as thin clients, all processing on Server-1/Server-2. | Cheapest, most replaceable, lowest power. | Network-dependent. Pi availability may be limited. |

**Sub-decision:** Authentication method?
- **Password** — simple, no hardware required, shoulder-surfing risk
- **Smart card (PIV/CAC)** — physical token, no shoulder-surfing, requires card reader infrastructure
- **Both** — smart card for sensitive roles, password for general population

**Impact:** Physical security model, procurement planning, spare parts strategy.

---

### D-7: General Population ARC Access Level

**Question:** What do the ~100 non-rotation community members get access to?

| Option | Description | Pros | Cons |
|--------|-------------|------|------|
| **(a) Read-only reference + entertainment** | Kiwix, Moodle, Jellyfin, Navidrome, Nextcloud, XMPP only. No ARCAI. | Low resource usage. Simple access control. Clear boundary. | Underutilizes ARC for 2/3 of community. May create information inequality. |
| **(b) Full ARCAI with role filtering** | Everyone gets ARCAI, but queries are filtered by `ARC-General` role (reference only, no admin/security). | More equitable. ARCAI helps everyone learn and contribute. | Higher resource usage (50+ concurrent users vs 50 rotation). GPU contention. May expose information that should be role-restricted. |
| **(c) Scheduled ARCAI sessions** | General population gets ARCAI access during designated hours (e.g., education block, evening reference). | Balances access with resource management. Predictable load. | Complexity. Doesn't help in ad-hoc situations. |

**Impact:** Resource consumption, social equity, GPU scheduling, and security model.

**Recommendation:** Start with **(a)**, evolve to **(c)** once resource capacity is validated. General population's primary need is reference (Kiwix) and communication (XMPP), not AI-assisted decision support.

---

## Declared Assumptions

These assumptions constrain the ARC design. Invalid or unvalidated assumptions are flagged as risks.

| # | Assumption | Status | Risk | Gitea |
|---|------------|--------|------|-------|
| A-1 | Internet is unavailable post-collapse | Valid design constraint | If internet is available, services like Proxy Gateway, FreshRSS, and email become relevant again. Design should gracefully re-enable these. | — |
| A-2 | Power is available (solar + generator) | Valid prerequisite | Without power: need documented manual procedures for all critical functions. ARC is useless without electricity. | — |
| A-3 | All 97 services fit on the 6U cabinet | **Needs validation** | Server-2 runs 56 services at ~60% RAM (128 GB). Adding ARCAI inference + ChromaDB may exceed capacity. May force service prioritization or hardware expansion. | — |
| A-4 | Authentik works air-gapped | **Needs testing** | Authentik may phone home for license validation, update checks, or telemetry. Must test full air-gap operation and document any required config changes. | — |
| A-5 | Annual rotation is the right cadence | **Needs validation** | Military uses 6-12 month rotations for combat roles, longer for technical roles. Annual may be too frequent for deep technical roles (Medical Officer, IT Admin) and too infrequent for physical roles (Gate Guard). | — |
| A-6 | Cannery tracks ammunition adequately | **Invalid** | Cannery only tracks round counts. Does NOT track lot numbers, manufacturing date, condition, storage environment, or age. Ammunition degrades — lot tracking and condition monitoring are essential for reliability. Need InvenTree custom fields or Cannery extension. | arc#18 |
| A-7 | AD Domain Controllers run without license renewal | **Needs verification** | Windows Server 2025 licenses may expire or require reactivation. In an air-gapped environment, KMS activation will fail. May need to migrate to FreeIPA/Samba4 AD or ensure perpetual licensing. | arc#19 |
| A-8 | OpenEMR is the right medical tool | **Needs validation** | OpenEMR is a full EMR designed for medical practices with billing, scheduling, insurance. A 150-person post-collapse community may need a simpler triage-focused tool. OpenEMR's complexity may hinder rather than help a field medic. | arc#20 |
| A-9 | 150 is the right group size | Valid (Dunbar's number) | Could realistically be 50 (extended family) or 500 (small town). ARC architecture should scale in both directions. Current design handles 50-200 without changes. | — |
| A-10 | exFAT external-storage survives transport | **Risk** | USB mechanical connector is fragile. exFAT has no journaling — power loss or improper disconnect causes corruption. 20 TB of data on a single non-redundant device with a fragile filesystem. Need: LUKS+XFS (or ext4), redundant copies, and a padded transport case. | arc#21 |

### Assumption Status Legend

| Status | Meaning |
|--------|---------|
| **Valid** | Confirmed as a reasonable design constraint |
| **Needs validation** | Plausible but unverified — requires testing or research |
| **Needs testing** | Specifically requires hands-on testing in the lab |
| **Needs verification** | Requires factual confirmation (licensing, specs, etc.) |
| **Invalid** | Known to be wrong — needs remediation |
| **Risk** | Valid concern with known mitigation path |
