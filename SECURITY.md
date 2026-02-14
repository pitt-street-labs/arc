# Security Policy

## Reporting a Vulnerability

If you discover a security issue in this repository — including accidental exposure of real infrastructure identifiers, credentials, or other sensitive data — please report it responsibly.

**Email:** carlson.jeffrey2006@gmail.com

**What to include:**
- Description of the issue
- File path and line number(s)
- Steps to reproduce (if applicable)

**Response time:** We aim to acknowledge reports within 48 hours and resolve critical issues within 7 days.

## Scope

This repository contains anonymized documentation and generic templates. All IP addresses, hostnames, domain names, and infrastructure details are fictional or anonymized.

If you believe you have found real (non-anonymized) infrastructure identifiers in this repository, please treat it as a security report using the process above.

## Automated Protections

This repository uses the following automated checks:

- **Pre-commit hooks** scan for known real-identifier patterns before every commit
- **GitHub Actions CI** runs the same scan on every push and pull request
- **GitHub secret scanning** monitors for accidentally committed credentials
- **CODEOWNERS** requires maintainer review on all pull requests
