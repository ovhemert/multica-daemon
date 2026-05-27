# Images

## Image Variants

| Tag | Contents |
| --- | --- |
| `ghcr.io/ovhemert/multica-daemon:claude` | Daemon + Claude Code only |
| `ghcr.io/ovhemert/multica-daemon:codex` | Daemon + Codex only |
| `ghcr.io/ovhemert/multica-daemon:copilot` | Daemon + Copilot only |
| `ghcr.io/ovhemert/multica-daemon:gemini` | Daemon + Gemini only |
| `ghcr.io/ovhemert/multica-daemon:hermes` | Daemon + Hermes only |
| `ghcr.io/ovhemert/multica-daemon:opencode` | Daemon + OpenCode only |
| `ghcr.io/ovhemert/multica-daemon:pi` | Daemon + Pi only |

All published images are **multi-arch** (`linux/amd64` + `linux/arm64`) and built by GitHub Actions with Docker Buildx. See [`.github/workflows/multi-build.yaml`](../.github/workflows/multi-build.yaml).

Each per-agent image is published from a dedicated variant Dockerfile named `docker/Dockerfile.<variant>`. Each image starts from the Node.js 24 base, installs its agent, then installs the Multica daemon.

To target a specific version of the multica daemon for an agent, include the version as a tag in the image: `ghcr.io/ovhemert/multica-daemon:v<version>-<variant>` (for example `ghcr.io/ovhemert/multica-daemon:v0.3.8-hermes`). The latest release for each variant is also tagged as `latest-<variant>`, for example `ghcr.io/ovhemert/multica-daemon:latest-hermes`. Unversioned `:<variant>` tags track `main` and are intended for development/testing.

## Registry Cleanup

Untagged GHCR image versions and orphaned referrer artifacts are removed by [`.github/workflows/ghcr-cleanup.yaml`](../.github/workflows/ghcr-cleanup.yaml). The cleanup runs after successful publish workflows, on a weekly schedule, and on manual dispatch. Tagged release images such as `v0.3.8-hermes` and moving tags such as `latest-hermes` are preserved.

## CLI Versions

| Multica daemon version | Claude | Codex | Copilot | Gemini | Hermes | OpenCode | Pi |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `v0.3.8 (latest)` | `2.1.150` | `0.133.0` | `1.0.54` | `0.43.0` | `main (v0.14.0 at release)` | `1.15.10` | `0.75.5` |
| `v0.3.6` | `2.1.150` | `0.133.0` | `1.0.54` | `0.43.0` | `main (v0.14.0 at release)` | `1.15.10` | `0.75.5` |
| `v0.3.5` | `2.1.150` | `0.133.0` | `1.0.51` | `0.43.0` | `main` | `1.15.10` | `0.75.4` |
| `v0.3.4` | `2.1.144` | `0.131.0` | `1.0.50` | `0.42.0` | `main` | `1.15.5` | `0.75.3` |
| `v0.3.3` | `2.1.144` | `0.131.0` | `1.0.50` | `0.42.0` | - | `1.15.5` | `0.75.3` |
| `v0.3.2` | `2.1.143` | `0.130.0` | `1.0.48` | `0.42.0` | - | `1.15.4` | `0.75.3` |

