# ARC — Status & Handoff

## Context
ARC (Assisted Reconstitution of Civilization): post-cataclysm framework for rebuilding human civilization. ARC.ai = analytical engine. ARC.instance = Dunbar-numbered (~150) population unit. See README.md for full vision.

## Last Updated
2026-02-17 by Claude Code

## Session Summary
Established Claude Code ↔ Claude Web handoff protocol. STATUS.md is now the shared state file — Claude Code pushes to main at session end, Claude Web updates on working branches (merged with content PRs). Updated Claude Web project instructions to match.

## Recently Completed
- Repo scaffolded: 65+ files across design/, disaster-recovery/, lab-manuals/, halops/, presentations/
- 3-methodology security audit (gitleaks, pattern scan, threat model) — all findings fixed
- Security mechanisms: pre-commit hooks, CI workflow, CODEOWNERS, SECURITY.md, PR template
- Repo made public, branch protection enabled
- STATUS.md handoff protocol established (both sides read/write)
- CLAUDE.md + Claude Web project instructions finalized

## In Progress
- Nothing currently

## Ready for Claude Web
- `halops/eval/evaluation-framework.md` — needs more test cases across all 11 categories (currently sparse). See Section 4 for existing patterns.
- `lab-manuals/examples/` — could use a fourth example covering storage and backup topics.
- `disaster-recovery/rebuild-guide-template/` — chapter templates are skeleton-only. Any chapter could be fleshed out with generic best-practice content.
- `design/` docs — review for clarity, consistency, and completeness. Flag anything confusing.

## Blocked / Waiting
- Nothing currently

## Decisions Made
- [2026-02-14] Single monorepo structure (not multi-repo)
- [2026-02-14] Templates only (not redacted real content) for DR and lab manuals
- [2026-02-14] MIT license
- [2026-02-14] Anonymization scheme: 10.0.x.x IPs, generic hostnames, "Reference Lab" identity
- [2026-02-14] Branch-based hybrid collaboration: claude/* branches, PR to main, human review required
- [2026-02-14] Repo made public (security audit confirmed safe)
- [2026-02-14] Branch protection: 1 required review, dismiss stale reviews, admins exempt
- [2026-02-14] STATUS.md updated at end of session only (not start)
- [2026-02-14] CLAUDE.md = permanent policy, STATUS.md = session-specific state (two layers, some overlap OK)
- [2026-02-17] Claude Web updates STATUS.md on working branches (option 3 — merged with content PRs)
- [2026-02-17] Claude Web project instructions finalized (includes branch rules, anonymization, STATUS.md protocol)

## Open Questions
- Should the presentations/ directory grow, or is the single arcbot HTML a one-off?
- Future repo: `hp-ilo-power-exporter` (separate repo, deferred)

## Do Not Touch
- `.github/workflows/content-safety.yml` — changes require Claude Code review
- `.pre-commit-config.yaml` — changes require Claude Code review
- `.github/CODEOWNERS` — changes require Claude Code review
- `CLAUDE.md` — convention changes require human approval

## Repo Structure
```
arc/
├── README.md                    # Project overview
├── CLAUDE.md                    # AI agent instructions
├── STATUS.md                    # Handoff state (this file)
├── CONTRIBUTING.md              # Contribution guidelines
├── SECURITY.md                  # Responsible disclosure policy
├── LICENSE                      # MIT
├── .pre-commit-config.yaml      # Local safety hooks
├── .github/
│   ├── CODEOWNERS               # Require maintainer review
│   ├── pull_request_template.md # PR anonymization checklist
│   └── workflows/
│       └── content-safety.yml   # CI identifier/credential scan
├── design/                      # 15 ARC architecture docs
├── disaster-recovery/           # DR framework (21 templates + 9 scripts)
├── halops/                      # Session-to-SFT methodology (5 docs)
├── lab-manuals/                 # PDF generation toolkit (7 files)
└── presentations/               # Concept mockups (1 file)
```

---
<!--
MAINTENANCE NOTES:

Claude Code:
- Update this file at the END of every working session (direct push to main)
- Keep entries concise — this is consumed by an LLM with finite context
- Move completed items promptly; stale entries waste Claude Web's attention
- The "Decisions Made" section prevents re-litigation — use it liberally
- "Ready for Claude Web" should include file paths and specific asks

Claude Web:
- Update this file ON YOUR WORKING BRANCH as part of your PR
- Move your task from "Ready for Claude Web" → "In Progress" when you start
- Add open questions to "Open Questions" as you discover them
- Move your task to "Recently Completed" when your PR is ready for review
- Your STATUS.md changes are reviewed alongside your content changes
- Do NOT create a separate PR just for STATUS.md updates
-->
