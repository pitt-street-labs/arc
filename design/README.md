# ARC Design Documents

These documents describe the architecture, organization, and deployment strategy for the ARC system. They were developed iteratively through ~300 collaborative sessions between a human lab operator and Claude Code.

## Reading Order

Start here if you're new:

1. **[architecture.md](architecture.md)** — The 4-layer system architecture (Searchhead → ARCAI → Corpus → Infrastructure)
2. **[organization.md](organization.md)** — How the ARC community is organized (roles, governance, resource allocation)
3. **[role-stories.md](role-stories.md)** — Detailed scenarios for each community role interacting with ARC
4. **[user-stories.md](user-stories.md)** — Comprehensive user stories across all roles and capabilities
5. **[decisions.md](decisions.md)** — Key architectural decisions and their rationale

## Deep Dives

Once you understand the basics:

- **[build-spec.md](build-spec.md)** — Physical hardware specifications and bill of materials
- **[seed-architecture.md](seed-architecture.md)** — The minimal viable ARC deployment (what fits in a pelican case)
- **[reliability-principles.md](reliability-principles.md)** — How the system stays running with degraded hardware and no supply chain
- **[dev-environments.md](dev-environments.md)** — Development and testing environments for ARC components
- **[service-registry.md](service-registry.md)** — Every software service ARC runs, with scaling tiers
- **[container-gaps.md](container-gaps.md)** — Gap analysis: what's deployed vs. what ARC needs
- **[integration-analysis.md](integration-analysis.md)** — How existing lab services map to ARC requirements
- **[tier-a-deployment.md](tier-a-deployment.md)** — First-priority deployment plan
