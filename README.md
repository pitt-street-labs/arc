# ARC — Assisted Reconstitution of Civilization

A post-collapse knowledge preservation and reconstitution system designed for a Dunbar group (~150 humans) using whatever compute survives.

## What Is This?

ARC is a design framework for building a self-contained, offline-capable knowledge and AI system that could help a small community survive and rebuild after a civilizational disruption. It assumes:

- **No internet.** Everything runs air-gapped on local hardware.
- **Degraded compute.** From a Raspberry Pi to a rack server — the system scales to whatever survives.
- **Shared terminals.** No personal devices. Community access with role-based permissions.
- **Power constraints.** Solar + generator with limited fuel. Every watt matters.
- **Human governance.** Technology serves the community, not the other way around.

## Components

ARC has three physical/logical layers:

| Component | What It Is |
|-----------|-----------|
| **HAL** (Hydratable ARC Logic) | Bootable USB drive — minimal Linux, bootstrap AI model, Kiwix reader, mesh tools, hydration scripts |
| **ARC** (the data drive) | 2-8 TB curated offline knowledge corpus — medical, agricultural, engineering, legal, educational |
| **ARCAI** (the AI layer) | Scalable assistant that runs on available hardware — from 1.5B Q4 on a Pi to 32B on a server |

## Repository Structure

```
design/              ARC system design documents
disaster-recovery/   DR framework and rebuild guide templates
lab-manuals/         PDF manual generation toolkit (Pandoc + XeLaTeX)
halops/              AI agent fine-tuning methodology (session-to-SFT pipeline)
presentations/       Visual demos and mockups
```

### design/

The core ARC design — architecture, build specifications, decision log, reliability principles, user/role stories, service registry, and deployment tiers. These documents describe a real system being built on real hardware, anonymized for sharing.

### disaster-recovery/

A template framework for writing comprehensive disaster recovery documentation for any home lab or small infrastructure. Includes a 20-chapter rebuild guide structure, state capture scripts, and maintenance automation.

### lab-manuals/

A complete toolkit for generating professional PDF manuals from Markdown using Pandoc and XeLaTeX. Includes custom LaTeX templates, Lua filters for callout boxes, and a Makefile build system.

### halops/

Methodology for fine-tuning a small open-source LLM on Claude Code session data to create an autonomous lab operations agent. Covers the session-to-SFT pipeline, QLoRA training approach, evaluation framework, and lessons learned.

## Origin

This project grew from a working home lab — 45+ containerized services, redundant servers, managed switching, enterprise PKI, SSO, monitoring, mesh networking, and AI inference — built primarily through collaboration between a human operator and Claude Code over ~300 sessions in one month.

The ARC concept asks: *if you had to rebuild civilization's knowledge infrastructure from scratch, what would you actually need, and how would you organize it?*

The answer turns out to be surprisingly close to what a well-run home lab already provides.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for the branch model and workflow.

## License

MIT — see [LICENSE](LICENSE) for details.
