# Security

## Reporting a vulnerability

**Do not open a public GitHub issue for security vulnerabilities.**

Please email **osmond@vanhemert.nu** with:

- A description of the vulnerability and its potential impact.
- Steps to reproduce or a proof-of-concept (if available).
- Your preferred contact for follow-up.

You will receive an acknowledgement within 48 hours. We aim to release a fix or mitigation within 14 days of confirmation.

## Scope

This repository contains only the Dockerfile, entrypoint script, and CI configuration for packaging the Multica daemon alongside AI coding agent CLIs. The following categories are in scope:

| Category | Examples |
| --- | --- |
| Token / credential leaks | `MULTICA_TOKEN` or CLI API keys exposed in image layers or logs |
| Container privilege escalation | Breaking out of the non-root `multica` user context |
| Dependency vulnerabilities | Critical CVEs in the `node:24-trixie-slim` base image or pinned CLIs |
| Supply-chain issues | Tampered npm packages or compromised install scripts |

Vulnerabilities in the upstream Multica server, AI CLI tools, or GitHub Actions runners should be reported to their respective projects.

## Security model

### Credentials at runtime

- `MULTICA_TOKEN` is a **runtime installer token** used only at container startup (by `multica login`). It is passed as an environment variable and is not baked into the image.
- AI CLI credentials (`ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `GITHUB_TOKEN`, etc.) are never stored in the image. They must be injected at runtime via environment variables or by mounting a credentials directory into `/multica` (the container `$HOME`).
- Do **not** hardcode any token in `docker-compose.yml`, the Dockerfile, or CI configuration. Use `.env` files (excluded from git via `.gitignore`) or your secret manager of choice.

### Image supply chain

- All CLI versions are pinned to exact semver tags in `docker-bake.hcl` and the Dockerfile `ARG` declarations.
- Images are published to `ghcr.io/ovhemert/multica-daemon` from a GitHub Actions workflow triggered only by signed version tags on `main`.
- Multi-arch builds run on GitHub-hosted runners (no self-hosted runners with persistent state).

### Container hardening

- The container runs as a non-root `multica` user (`useradd -m`).
- Only the ports the daemon explicitly listens on need to be exposed; the default configuration does not expose any host ports.
- The `HEALTHCHECK` uses `multica daemon status` to detect dead containers without requiring network exposure.
