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
  1. Configures the daemon (`server_url`, `app_url`, `device_name`)
  2. Logs in with `MULTICA_TOKEN`
  3. Starts `multica daemon start --foreground` as PID 1

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
   | `MULTICA_DAEMON_ID` | A unique name for this daemon (shown in the Runtimes page); defaults to `$HOSTNAME` if omitted |
   | `GIT_AUTHOR_NAME` | Name used for git commits produced by agent tasks |
   | `GIT_AUTHOR_EMAIL` | Email used for git commits produced by agent tasks |

   > **Do not commit live tokens to version control.** Use `--env-file` with a
   > file outside your repo, Docker secrets, or SOPS/age — see
   > [Secret management](#secret-management) for details.

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
  multica-runtime:dev
```

## Configuration reference

### Multica daemon

| Variable | Default | Description |
| --- | --- | --- |
| `MULTICA_APP_URL` | — (required) | URL of the Multica web app |
| `MULTICA_SERVER_URL` | — (required) | URL of the Multica server (API / WebSocket) |
| `MULTICA_TOKEN` | — (required) | Runtime installer token |
| `MULTICA_DAEMON_ID` | `$HOSTNAME` | Daemon device name, shown on the Runtimes page — **must be unique per container** (see below) |
| `MULTICA_WORKSPACES_ROOT` | `/workspaces` | Where the daemon clones repositories |
| `MULTICA_DAEMON_MAX_CONCURRENT_TASKS` | `20` (Multica default) | Per-daemon concurrent task limit |
| `GIT_AUTHOR_NAME` | — | Git `user.name` applied globally inside the container |
| `GIT_AUTHOR_EMAIL` | — | Git `user.email` applied globally inside the container |

### MULTICA_DAEMON_ID uniqueness

> **Warning: never run two containers with the same `MULTICA_DAEMON_ID`.**
> They will race over heartbeats and task assignment, causing tasks to stall
> or execute twice.

When `MULTICA_DAEMON_ID` is not set the entrypoint falls back to
`$HOSTNAME`, which Docker sets to the short container ID — unique by default.
Set it explicitly when you want a stable, human-readable name on the Runtimes
page (e.g. `daemon-prod-01`). If you scale out with `docker compose up
--scale runtime=N`, **omit `MULTICA_DAEMON_ID`** from your `.env` and let
each replica get a distinct ID from its hostname.

### Secret management

Do **not** put live tokens in a committed `.env` file. Recommended approaches
in order of increasing security:

**`--env-file` (simplest, local only)**
```bash
docker compose --env-file /path/to/secrets.env up -d
```
Keep the secrets file outside the repo and out of version control.

**Docker secrets (Swarm / Compose v2)**
```yaml
services:
  runtime:
    secrets:
      - multica_token
secrets:
  multica_token:
    file: ./secrets/multica_token.txt
```
Secrets are mounted as files under `/run/secrets/` inside the container. The
entrypoint would need updating to read the file; contributions welcome.

**SOPS + age (recommended for teams)**
1. Encrypt your secrets file: `sops --encrypt --age <recipient> .env > .env.enc`
2. Decrypt at deploy time: `sops --decrypt .env.enc > .env && docker compose up -d`
3. Commit only `.env.enc` to version control; never commit the plaintext `.env`.

### Per-CLI credentials

The Multica daemon does **not** ship the credentials each AI CLI needs (Anthropic API key, OpenAI key, Google API key, GitHub token, …). You must provide those yourself by either:

- Passing each CLI's expected env var into the container via `.env` / `--env-file` / Docker secrets:

  | CLI | Environment variable(s) |
  | --- | --- |
  | Claude Code | `ANTHROPIC_API_KEY` |
  | Codex | `OPENAI_API_KEY` |
  | Copilot | `GITHUB_TOKEN` |
  | Gemini | `GEMINI_API_KEY` or `GOOGLE_API_KEY` |
  | OpenCode | `OPENAI_API_KEY` (or provider-specific key) |
  | Pi | `PI_API_KEY` |

- Mounting a pre-configured credentials directory into `/multica` (the in-container `$HOME`), so the per-CLI `~/.config/...` files are present.

In the Multica UI you can inject these as **agent configuration variables** under Settings → Runtimes → *Configure*. Variables set there are passed as environment variables to every task run on that runtime.

### Git identity

Agent tasks produce commits. Set `GIT_AUTHOR_NAME` and `GIT_AUTHOR_EMAIL` so
those commits are attributed correctly:

```bash
# .env
GIT_AUTHOR_NAME=Multica Daemon
GIT_AUTHOR_EMAIL=daemon@multica.ai
```

The entrypoint runs `git config --global user.name / user.email` from these
values before starting the daemon. If neither variable is set, git will fall
back to its own defaults (or fail on repositories that require an identity).

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

- **Heartbeats & offline detection.** The daemon sends a heartbeat every 15s. If the Multica server misses three (45s) it marks the runtime *missing* and reclaims in-flight tasks. Never run more than one container with the same `MULTICA_DAEMON_ID` — see [MULTICA_DAEMON_ID uniqueness](#multica_daemon_id-uniqueness).
- **Crash recovery.** On startup the daemon tells the server "any tasks still marked as mine are no longer running"; combined with the server-side 30s reaper this means restarts of this container are safe. The `restart: unless-stopped` policy in `docker-compose.yml` ensures the daemon comes back automatically after host reboots or crashes.
- **Workspaces.** The `docker-compose.yml` declares a named Docker volume (`workspaces`) mounted at `/workspaces`. Repo clones survive `docker compose down` and restart automatically — no re-clone on each startup. For plain `docker run` usage, add `-v workspaces:/workspaces` to persist the directory.
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
