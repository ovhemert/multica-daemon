# Multica Daemon — Containerized Runtimes

Docker images that bundle the [Multica](https://multica.ai) daemon together with one or more AI coding agent CLIs (Claude Code, Codex, Copilot, Gemini, OpenCode, Pi, …). Run them anywhere Docker runs to spin up scalable, isolated [Multica runtimes](https://multica.ai/docs/daemon-runtimes) without polluting your host machine.

> A **runtime** in Multica is the combination of *daemon × one AI coding tool*. This repo packages that combination into reproducible container images so you can scale runtimes horizontally — locally with Docker Compose, on a server, or on Kubernetes — instead of installing every CLI on every developer's laptop.

## Architecture

```mermaid
graph TD
    subgraph Host["Host machine"]
        subgraph C1["Container (daemon-01)"]
            D1[Multica daemon]
            D1 --> R1[Claude Code runtime]
            D1 --> R2[Codex runtime]
            D1 --> R3[Gemini runtime]
        end
        subgraph C2["Container (daemon-02)"]
            D2[Multica daemon]
            D2 --> R4[Claude Code runtime]
            D2 --> R5[Codex runtime]
            D2 --> R6[Gemini runtime]
        end
    end

    R1 & R2 & R3 & R4 & R5 & R6 <-->|WebSocket| API[Multica server]
    API --> UI[Multica UI / issue queue]
```

One host runs **N containers** (one per `MULTICA_DAEMON_ID`). Each container runs **M runtimes** (one per installed CLI × workspace). Total runtimes on that host: **N × M**.

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

   > **Do not commit live runtime tokens to version control.** Use `--env-file`
   > with a file outside your repo, Docker secrets, or SOPS/age for
   > daemon-level secrets only — see [Secret management](#secret-management)
   > for details. Configure agent CLI credentials in Multica, not in `.env`.

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

## How runtimes scale

A single host can run any number of daemon containers simultaneously. Each container registers its own set of runtimes with the Multica server.

```
1 host
└── N containers  (one MULTICA_DAEMON_ID each, e.g. daemon-01 … daemon-N)
    └── M runtimes per container  (one per installed CLI × workspace)
        └── Total = N × M runtimes visible in the Multica UI
```

**Example:** three containers on one server, each with the all-in-one image (6 CLIs), connected to 1 workspace → **3 × 6 × 1 = 18 runtimes**.

Practical scaling guidelines:

- **Scale containers** (`N`) when you want more parallel capacity for the same set of CLIs — each container handles tasks independently.
- **Scale using variants** (`M`) when you need specific CLIs per container, e.g. run only the `claude` variant to dedicate hardware to Claude Code tasks.
- **`MULTICA_DAEMON_MAX_CONCURRENT_TASKS`** caps how many tasks one daemon runs at once (default: 20). Lower it if your host is CPU/memory constrained.
- **Do not** run two containers with the same `MULTICA_DAEMON_ID` — the server will see conflicting heartbeats and reclaim tasks unpredictably.

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

Do **not** put live runtime tokens in a committed `.env` file. The `.env`
file is only for daemon-level settings such as `MULTICA_TOKEN`, URLs, daemon
IDs, and git identity. Configure agent CLI credentials in Multica itself; do
not add `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`,
`GITHUB_TOKEN`, or similar agent secrets to `.env` files.

Recommended approaches for daemon-level secrets, in order of increasing
security:

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

### Per-agent CLI credentials

The Multica daemon image does **not** ship the credentials each AI CLI needs.
Add those credentials to the agent configuration in Multica. Multica injects
the configured values into the agent process when it launches a task, so each
agent can have its own credentials without exposing them to the whole runtime
container.

| CLI | Credential | Where to get it | Configure in Multica as |
| --- | --- | --- | --- |
| **Claude Code** | Anthropic API key | [console.anthropic.com](https://console.anthropic.com) → API Keys | `ANTHROPIC_API_KEY` |
| **Codex** | OpenAI API key | [platform.openai.com](https://platform.openai.com) → API Keys | `OPENAI_API_KEY` |
| **GitHub Copilot** | GitHub token (with Copilot scope) | GitHub → Settings → Developer settings → Personal access tokens | `GITHUB_TOKEN` |
| **Gemini** | Google AI Studio key | [aistudio.google.com](https://aistudio.google.com) → Get API key | `GEMINI_API_KEY` |
| **OpenCode** | Provider-specific (OpenAI, Anthropic, ...) | Same as the underlying provider | Provider's own env var |
| **Pi** | Pi API key | Your Pi account settings | `PI_API_KEY` |

Do not pass these credentials through Docker `-e` flags, Compose `.env`
files, `--env-file`, Docker secrets mounted into the container, or host
credential directory mounts. Those approaches make the secret part of the
runtime configuration. Agent credentials should live with the Multica agent
configuration and be scoped to the specific agent process that needs them.

## Image variants

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
├── docker-bake.hcl               # Multi-variant build definition
├── docker-compose.yml            # Convenience runner for local development
├── .env.example                  # Template for daemon runtime config
├── CHANGELOG.md                  # Version history
├── CONTRIBUTING.md               # Dockerfile and release conventions
├── SECURITY.md                   # How to report token leaks / image vulns
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

### Daemon offline

The Runtimes page shows the daemon as *offline* or *missing*.

```bash
# 1. Check the daemon process is running
docker compose exec runtime multica daemon status

# 2. Tail live logs for error messages
docker compose exec runtime multica daemon logs -f

# 3. Verify the container is healthy
docker inspect --format '{{.State.Health.Status}}' $(docker compose ps -q runtime)

# 4. If the container exited, read the last run's output
docker compose logs runtime --tail 100
```

Common causes:

- `MULTICA_TOKEN` is expired or revoked — generate a new one from Settings → Runtimes.
- `MULTICA_SERVER_URL` is wrong or unreachable — verify with `curl $MULTICA_SERVER_URL/healthz` from inside the container.
- Duplicate `MULTICA_DAEMON_ID` — rename one of the containers and restart.

### Tool not detected

A CLI is installed in the image but no runtime row appears for it in the Multica UI.

```bash
# Confirm the CLI binary exists and is executable
docker compose exec runtime which claude
docker compose exec runtime claude --version

# Check the daemon detected it on startup
docker compose exec runtime multica daemon logs | grep -i "claude\|detected\|registered"
```

Common causes:

- The image variant you pulled doesn't include that CLI (e.g. `…:claude` omits Codex).
- The CLI requires interactive auth that hasn't been completed — exec into the container and run the CLI's login flow manually, then restart.

### Auth failed

The daemon starts but tasks fail immediately with authentication errors.

```bash
# Confirm the agent credential names configured in Multica match the CLI.
# Multica injects these values into the agent process when a task launches.
docker compose exec runtime multica daemon logs -f
```

Common causes:

- The agent configuration in Multica is missing the required credential.
- The configured credential name does not match what the CLI expects.
- The key has been revoked or has insufficient scope — regenerate and redeploy.
- For Copilot: `GITHUB_TOKEN` must have the `copilot` scope enabled.

### Task stuck in queued

A task has been assigned but stays in *queued* and never starts.

```bash
# Check how many tasks are currently running on this daemon
docker compose exec runtime multica daemon status

# Check the MULTICA_DAEMON_MAX_CONCURRENT_TASKS setting
docker compose exec runtime env | grep MULTICA_DAEMON_MAX_CONCURRENT_TASKS

# Look for task acceptance/rejection in the logs
docker compose exec runtime multica daemon logs | grep -i "task\|queue\|accept\|reject"
```

Common causes:

- The daemon has reached its `MULTICA_DAEMON_MAX_CONCURRENT_TASKS` limit — wait for a running task to finish, or increase the limit and restart.
- The daemon is *offline* — see the [Daemon offline](#daemon-offline) section above.
- The workspace the task references hasn't been connected to this daemon — verify in the Multica UI under Settings → Workspaces.

## Upgrade guide

### Bumping a CLI version

Each CLI version is a build arg in `docker-bake.hcl` (e.g. `CLAUDE_VERSION`, `CODEX_VERSION`). To upgrade:

1. Update the version variable in `docker-bake.hcl` and the matching `ARG` default in `Dockerfile`.
2. Build and test locally:
   ```bash
   docker buildx bake claude --load
   docker run --rm ghcr.io/ovhemert/multica-daemon:claude claude --version
   ```
3. Open a PR, merge to `main`, and tag a new release (see below).

### Bumping the Multica daemon (`MULTICA_VERSION`)

The daemon version drives the project's release version. Bump it when:

- A new `multica-cli` release includes features or fixes you need.
- The server-side API requires a minimum client version (watch the Multica changelog).

Steps are the same as bumping a CLI version. Add a `CHANGELOG.md` entry.

### Tagging a release

```bash
git tag v<MULTICA_VERSION>    # e.g. git tag v0.3.4
git push origin v<MULTICA_VERSION>
```

The CI workflow triggers on tags matching `v*` and publishes multi-arch images to GHCR.

### Breaking-change policy

- **No breaking changes** to environment variable names or mount paths without a major version bump and a migration note in `CHANGELOG.md`.
- **Pinned versions** mean existing image digests are immutable — you opt into upgrades by pulling a new tag.
- **Deprecation window** — if a variable or behaviour is removed, it will be documented as deprecated in one release before being removed in the next.

## License

[MIT](./LICENSE.md) © Osmond van Hemert
