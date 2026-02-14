# Claude Code / Claude Web Instructions

These instructions apply to all AI agents (Claude Code, Claude Web) working on this repository.

## Status & Handoff

**Read `STATUS.md` first.** It contains current session state, what's in progress, what's ready for work, settled decisions, and files that should not be modified without review.

- **Claude Code** updates STATUS.md at the end of every working session (direct push to main).
- **Claude Web** updates STATUS.md on its working branch as part of the same PR as its content changes. Move your task from "Ready for Claude Web" to "In Progress", add open questions, note completions. The STATUS.md diff is reviewed alongside the content diff.

## Branch Rules

**NEVER push directly to `main`.** All changes must arrive via pull request.

| Branch Prefix | Who Creates | Purpose |
|---------------|-------------|---------|
| `claude/*` | Claude Web or Claude Code | AI-drafted changes |
| `feature/*` | Human contributors | Human-authored work |
| `draft/*` | Anyone | Work-in-progress, not ready for review |
| `main` | **PR merge only** | Stable, reviewed content |

### Workflow

1. Create a branch from `main` using the appropriate prefix (e.g., `claude/improve-halops-eval`)
2. Make your changes on that branch
3. Open a Pull Request against `main`
4. Wait for human review and approval — do not merge your own PRs
5. Squash merge is preferred for clean history

## Commit Convention

Every commit must include:

```
Co-Authored-By: Claude <noreply@anthropic.com>
```

Write commit messages that explain **why**, not just what. Keep the first line under 72 characters.

## Anonymization Rules — CRITICAL

This repository is anonymized. All content must use fictional/generic identifiers. **If you are unsure whether something is real or anonymized, do not include it.**

### Required Substitutions

| Category | Use This | Never Use |
|----------|----------|-----------|
| IP addresses | `10.0.x.x` range | Any `172.16.x.x`, `192.168.x.x`, or real public IPs |
| Hostnames | `server-1`, `server-2`, `firewall`, `switch-1`, `workstation`, `pbx-1` | Real device names |
| Domain controllers | `DC-1`, `DC-2` | Real DC names |
| Domains | `lab.example.com` | Any real domains |
| Organization | "Reference Lab" or "the project lab" | Real lab/org names |
| Usernames | `labadmin` | Real usernames |
| Hardware | Generic descriptions (e.g., "enterprise server, 64GB RAM") | Specific model numbers that identify real equipment |
| Phone models | "SIP desk phone" | Specific make/model |
| BMC/IPMI | "BMC" | iLO, IMM, iDRAC with version numbers |
| Credentials | `<from-vault>`, `<retrieve-from-vault>`, placeholder text | Real tokens, passwords, API keys, paths to real credential stores |
| Backup paths | Generic paths with `<placeholder>` markers | Real file paths to credential backups |

### Self-Check Before Committing

Before creating a commit, mentally verify:

1. No IP addresses outside `10.0.x.x`, `127.0.0.1`, or well-known public DNS (1.1.1.1, 9.9.9.9)
2. No real hostnames, domain names, or organization names
3. No credentials, tokens, API keys, or paths to credential stores
4. No specific hardware model numbers that could identify real equipment
5. No real person names, usernames, or email addresses

A CI workflow (`content-safety.yml`) runs on every push and PR to catch violations automatically, but do not rely on it as the only check.

## Content Guidelines

### What This Repo Contains

- **design/**: Architecture and planning documents for the ARC system
- **disaster-recovery/**: Generic templates for infrastructure rebuild guides
- **lab-manuals/**: Pandoc+XeLaTeX toolkit for generating PDF manuals
- **halops/**: Methodology for fine-tuning LLMs on operator session data
- **presentations/**: Concept mockups and demos

### Writing Style

- Practical over theoretical — describe what works, not what might work
- Include the "why" alongside the "what"
- Use tables for structured comparisons
- Keep documents self-contained

### What You Can Do

- Improve documentation clarity, fix typos, restructure for readability
- Add new template content (DR chapters, manual examples, methodology docs)
- Improve the build tooling (Makefile, LaTeX template, Lua filters)
- Add evaluation test cases to the HALops framework
- Propose new sections or documents via PR description

### What Requires Discussion First

- Changing the anonymization scheme or identifier mappings
- Adding new top-level directories or restructuring the repo
- Modifying the CI workflow or pre-commit hooks
- Anything that changes the security posture of the repo

## Pull Request Format

```markdown
## Summary
- Bullet points describing what changed and why

## Anonymization Check
- [ ] No real IPs, hostnames, domains, or credentials
- [ ] No specific hardware model numbers
- [ ] No real person names or usernames
- [ ] CI content-safety check passes

## Test plan
- How to verify the changes are correct
```

## Security

If you discover real (non-anonymized) infrastructure identifiers anywhere in the repo, **stop and report it** in the PR description or as a new issue. Do not attempt to fix it silently — the maintainer needs to assess whether the exposure requires additional action beyond the fix.

See `SECURITY.md` for the full responsible disclosure policy.
