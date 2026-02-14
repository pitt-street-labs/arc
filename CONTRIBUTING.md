# Contributing to ARC

## Branch Model

| Branch | Purpose | Who Writes |
|--------|---------|-----------|
| `main` | Stable, reviewed content | Merged via PR only |
| `claude/*` | AI-assisted drafts and edits | Claude Web / Claude Code |
| `feature/*` | Human contributor work | Anyone with access |
| `draft/*` | Work-in-progress, not ready for review | Anyone |

### Workflow

1. Create a branch from `main` using the appropriate prefix
2. Make your changes
3. Open a Pull Request against `main`
4. At least one human review required before merge
5. Squash merge preferred for clean history

### AI-Assisted Contributions

This project uses Claude (both Claude Code and Claude Web) as a contributor. AI-generated or AI-assisted commits are tagged with:

```
Co-Authored-By: Claude <noreply@anthropic.com>
```

The `claude/*` branch namespace is reserved for AI-initiated work. These branches follow the same PR review process as any other contribution.

## Content Guidelines

### Anonymization

All content in this repository is anonymized. When contributing:

- Use `10.0.x.x` for IP addresses (not real lab IPs)
- Use generic hostnames: `server-1`, `server-2`, `firewall`, `workstation`, `switch-1`
- Use `lab.example.com` for domain references
- Use `labadmin` for username references
- Describe hardware by category, not model: "enterprise server (64GB RAM, dual 10GbE)"
- Never include credentials, API tokens, vault paths, or certificate details

### Writing Style

- Practical over theoretical — describe what works, not what might work
- Include the "why" alongside the "what"
- Reference real constraints (power, compute, bandwidth) with specific numbers
- Use tables for structured comparisons
- Keep documents self-contained — minimize cross-references that break without context

## What We're Looking For

- **Design reviews:** Do the architecture decisions hold up under scrutiny?
- **Scenario testing:** What failure modes haven't we considered?
- **Knowledge corpus curation:** What essential knowledge is missing from the ARC data drive?
- **Hardware alternatives:** What other compute platforms should ARC support?
- **Mesh networking:** Better approaches to low-bandwidth communication?
- **AI methodology:** Improvements to the session-to-SFT fine-tuning pipeline?

## Questions?

Open an issue. We'll respond.
