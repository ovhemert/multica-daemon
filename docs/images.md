# Images

## Image Variants

| Tag | Contents |
| --- | --- |
| `ghcr.io/ovhemert/multica-daemon:latest-claude` | Daemon + Claude Code only |
| `ghcr.io/ovhemert/multica-daemon:latest-codex` | Daemon + Codex only |
| `ghcr.io/ovhemert/multica-daemon:latest-copilot` | Daemon + Copilot only |
| `ghcr.io/ovhemert/multica-daemon:latest-gemini` | Daemon + Gemini only |
| `ghcr.io/ovhemert/multica-daemon:latest-hermes` | Daemon + Hermes only |
| `ghcr.io/ovhemert/multica-daemon:latest-opencode` | Daemon + OpenCode only |
| `ghcr.io/ovhemert/multica-daemon:latest-pi` | Daemon + Pi only |

All published images are **multi-arch** (`linux/amd64` + `linux/arm64`) and built by GitHub Actions with Docker Buildx. See [`.github/workflows/multi-build.yaml`](../.github/workflows/multi-build.yaml).

Each per-agent image is published from a dedicated variant Dockerfile named `docker/Dockerfile.<variant>`. Hermes is built from the upstream `nousresearch/hermes-agent` base image using [`docker/Dockerfile.hermes`](../docker/Dockerfile.hermes), then the Multica daemon is installed on top.

## CLI Versions

| Multica daemon version | Claude | Codex | Copilot | Gemini | Hermes base image | OpenCode | Pi |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `v0.3.5 (latest)` | `2.1.150` | `0.133.0` | `1.0.51` | `0.43.0` | `main` | `1.15.10` | `0.75.4` |
| `v0.3.4` | `2.1.144` | `0.131.0` | `1.0.50` | `0.42.0` | `main` | `1.15.5` | `0.75.3` |
| `v0.3.3` | `2.1.144` | `0.131.0` | `1.0.50` | `0.42.0` | - | `1.15.5` | `0.75.3` |
| `v0.3.2` | `2.1.143` | `0.130.0` | `1.0.48` | `0.42.0` | - | `1.15.4` | `0.75.3` |

