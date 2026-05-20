# Images

## Image Variants

| Tag | Contents |
| --- | --- |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3` | All bundled CLIs ("all-in-one") |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-claude` | Daemon + Claude Code only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-codex` | Daemon + Codex only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-copilot` | Daemon + Copilot only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-gemini` | Daemon + Gemini only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-hermes` | Daemon + Hermes only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-opencode` | Daemon + OpenCode only |
| `ghcr.io/ovhemert/multica-daemon:v0.3.3-pi` | Daemon + Pi only |

All published images are **multi-arch** (`linux/amd64` + `linux/arm64`), built natively on matching GitHub-hosted runners. See [`.github/workflows/multi-build.yaml`](../.github/workflows/multi-build.yaml).

## CLI Versions

| Multica daemon version | Claude | Codex | Copilot | Gemini | Hermes | OpenCode | Pi |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `v0.3.3` | `2.1.144` | `0.131.0` | `1.0.50` | `0.42.0` | latest | `1.15.5` | `0.75.3` |
| `v0.3.2` | `2.1.143` | `0.130.0` | `1.0.48` | `0.42.0` | — | `1.15.4` | `0.75.3` |
