# Images

## Image Variants

| Tag | Contents |
| --- | --- |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3` | All bundled CLIs ("all-in-one") |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-claude` | Daemon + Claude Code only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-codex` | Daemon + Codex only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-copilot` | Daemon + Copilot only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-gemini` | Daemon + Gemini only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-opencode` | Daemon + OpenCode only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-pi` | Daemon + Pi only |

All published images are **multi-arch** (`linux/amd64` + `linux/arm64`), built natively on matching GitHub-hosted runners. See [`.github/workflows/multi-build.yaml`](../.github/workflows/multi-build.yaml).

## Repository Layout

```text
.
|-- Dockerfile                    # Builds the all-in-one runtime image
|-- docker-bake.hcl               # Multi-variant build definition
|-- docker-compose.yml            # Convenience runner for local development
|-- .env.example                  # Template for daemon runtime config
|-- CHANGELOG.md                  # Version history
|-- CONTRIBUTING.md               # Dockerfile and release conventions
|-- SECURITY.md                   # How to report token leaks / image vulnerabilities
|-- docs/                         # Project documentation
|-- src/
|   |-- docker-entrypoint.sh      # PID 1: configure + login + start daemon
|-- .github/workflows/
    |-- multi-build.yaml          # Multi-arch GHCR build and publish
```
