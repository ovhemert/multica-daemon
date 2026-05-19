# Multica Daemon — Containerized Runtimes

Docker images that bundle the [Multica](https://multica.ai) daemon together with one or more AI coding agent CLIs (Claude Code, Codex, Copilot, Gemini, OpenCode, Pi, …). Run them anywhere Docker runs to spin up scalable, isolated [Multica runtimes](https://multica.ai/docs/daemon-runtimes) without polluting your host machine.

> A **runtime** in Multica is the combination of *daemon × one AI coding tool*. This repo packages that combination into reproducible container images so you can scale runtimes horizontally — locally with Docker Compose, on a server, or on Kubernetes — instead of installing every CLI on every developer's laptop.

## What's in the box

Each image contains:

- **Node.js 24** (Debian Trixie slim base) — needed by most CLIs, which are distributed as npm packages
- **The Multica CLI / daemon** — installed from the official `install.sh`
- **Pinned versions of the AI coding agent CLIs** (see [`Dockerfile`](./Dockerfile) for the exact `*_VERSION` build args):
  - `@anthropic-ai/claude-code` — Claude Code
  - `@openai/codex` — Codex
  - `@github/copilot` — GitHub Copilot CLI
  - `@google/gemini-cli` — Gemini
  - `opencode-ai` — OpenCode
  - `@earendil-works/pi-coding-agent` — Pi
- **An entrypoint** ([`src/docker-entrypoint.sh`](./src/docker-entrypoint.sh)) that:
  1. Disables any CLI you have not opted-in via `*_ENABLED` env vars (by pointing its `MULTICA_*_PATH` at `/`)
  2. Configures the daemon (`server_url`, `app_url`, `device_name`)
  3. Logs in with `MULTICA_TOKEN`
  4. Starts `multica daemon start --foreground` as PID 1

The container runs as a non-root `multica` user with `HOME=/multica` and a workspace root at `/workspaces` (override with `MULTICA_WORKSPACES_ROOT`).

## Quick start (Docker Compose)

1. **Get a runtime installer token** from the Multica UI (Settings → Runtimes → *Install a runtime*). It looks like `mul_…`.

2. **Create your `.env`** by copying the example and filling in the token:

   ```bash
   cp .env.example .env
   $EDITOR .env
   ```

   Minimum required variables:

   | Variable | Description |
   | --- | --- |
   | `MULTICA_APP_URL` | URL of the Multica web app (e.g. `https://app.multica.ai`) |
   | `MULTICA_SERVER_URL` | URL of the Multica API/WebSocket server |
   | `MULTICA_TOKEN` | Runtime installer token (`mul_…`) |
   | `MULTICA_DAEMON_ID` | A unique name for this daemon (shown in the Runtimes page) |
   | `<TOOL>_ENABLED` | `true` to expose that CLI to the daemon, anything else to hide it |

3. **Start the runtime:**

   ```bash
   docker compose up -d
   docker compose logs -f runtime
   ```

4. **Verify** — open the **Runtimes** page in the Multica UI. You should see one row per enabled CLI for this daemon, all marked *online*. From here you can assign issues/tasks and they will be picked up by this container.

To stop the runtime:

```bash
docker compose down
```

## Quick start (plain Docker)

```bash
docker build -t multica-runtime:dev .

docker run -d \
  --name multica-runtime \
  -e MULTICA_APP_URL=https://app.multica.ai \
  -e MULTICA_SERVER_URL=https://api.multica.ai \
  -e MULTICA_TOKEN=mul_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  -e MULTICA_DAEMON_ID=daemon-01 \
  -e CLAUDE_ENABLED=true \
  -e CODEX_ENABLED=true \
  multica-runtime:dev
```

## Configuration reference

### Multica daemon

| Variable | Default | Description |
| --- | --- | --- |
| `MULTICA_APP_URL` | — (required) | URL of the Multica web app |
| `MULTICA_SERVER_URL` | — (required) | URL of the Multica server (API / WebSocket) |
| `MULTICA_TOKEN` | — (required) | Runtime installer token |
| `MULTICA_DAEMON_ID` | — (required) | Daemon device name, shown on the Runtimes page |
| `MULTICA_WORKSPACES_ROOT` | `/workspaces` | Where the daemon clones repositories |
| `MULTICA_DAEMON_MAX_CONCURRENT_TASKS` | `20` (Multica default) | Per-daemon concurrent task limit |

### Enabling / disabling CLIs

For each bundled CLI there is a `<TOOL>_ENABLED` flag. When the flag is **not** `true`, the entrypoint sets the matching `MULTICA_<TOOL>_PATH` to `/`, which hides the binary from the daemon's CLI auto-detection without uninstalling it.

| Flag | CLI |
| --- | --- |
| `CLAUDE_ENABLED` | Claude Code |
| `CODEX_ENABLED` | Codex |
| `COPILOT_ENABLED` | GitHub Copilot CLI |
| `GEMINI_ENABLED` | Gemini |
| `OPENCODE_ENABLED` | OpenCode |
| `PI_ENABLED` | Pi |

> Each enabled CLI shows up as its own runtime row in the Multica UI (one per *daemon × tool × workspace* combination).

### Per-CLI credentials

The Multica daemon does **not** ship the credentials each AI CLI needs (Anthropic API key, OpenAI key, Google API key, GitHub token, …). You must provide those yourself by either:

- Mounting a credentials directory into `/multica` (the in-container `$HOME`), so the per-CLI `~/.config/...` files are present, **or**
- Passing each CLI's expected env var (e.g. `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `GITHUB_TOKEN`, …) into the container.

## Image variants

> Planned — not all of these exist yet.

| Tag | Contents |
| --- | --- |
| `ghcr.io/ovhemert/multica-daemon:latest` | All bundled CLIs ("all-in-one") |
| `…:claude` | Daemon + Claude Code only |
| `…:codex` | Daemon + Codex only |
| `…:copilot` | Daemon + Copilot only |
| `…:gemini` | Daemon + Gemini only |
| `…:opencode` | Daemon + OpenCode only |
| `…:pi` | Daemon + Pi only |

All published images are **multi-arch** (`linux/amd64` + `linux/arm64`), built natively on matching GitHub-hosted runners — see [`.github/workflows/multi-build.yaml`](./.github/workflows/multi-build.yaml).

## Repository layout

```
.
├── Dockerfile                    # Builds the all-in-one runtime image
├── docker-compose.yml            # Convenience runner for local development
├── .env.example                  # Template for local secrets / config
├── src/
│   └── docker-entrypoint.sh      # PID 1: configure + login + start daemon
└── .github/workflows/
    └── multi-build.yaml          # Multi-arch GHCR build & publish
```

## Operational notes

- **Heartbeats & offline detection.** The daemon sends a heartbeat every 15s. If the Multica server misses three (45s) it marks the runtime *missing* and reclaims in-flight tasks. Don't run more than one container with the same `MULTICA_DAEMON_ID`.
- **Crash recovery.** On startup the daemon tells the server "any tasks still marked as mine are no longer running"; combined with the server-side 30s reaper this means restarts of this container are safe.
- **Workspaces.** Mount a persistent volume at `/workspaces` if you want repo clones to survive container restarts.
- **Non-root.** The container runs as `multica` (uid set by `useradd -m`). If you mount host directories, make sure they are readable by that uid.
- **Logs.** The daemon logs to stdout (so `docker logs` / `docker compose logs -f` works). For more detail, exec into the container and run `multica daemon logs -f`.

## Troubleshooting

Follow [the official three-step check](https://multica.ai/docs/daemon-runtimes#troubleshooting-agents-that-arent-working) from inside the container:

```bash
docker compose exec runtime multica daemon status
docker compose exec runtime multica daemon logs -f
```

Then confirm the runtime appears as **online** on the *Runtimes* page in the Multica UI.

## License

[MIT](./LICENSE.md) © Osmond van Hemert
