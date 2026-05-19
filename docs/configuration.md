# Configuration

## Multica Daemon

| Variable | Default | Description |
| --- | --- | --- |
| `MULTICA_APP_URL` | Required | URL of the Multica web app |
| `MULTICA_SERVER_URL` | Required | URL of the Multica server, including API and WebSocket traffic |
| `MULTICA_TOKEN` | Required | Runtime installer token |
| `MULTICA_DAEMON_ID` | `$HOSTNAME` | Daemon device name, shown on the Runtimes page. Must be unique per container. |
| `MULTICA_WORKSPACES_ROOT` | `/workspaces` | Where the daemon clones repositories |
| `MULTICA_DAEMON_MAX_CONCURRENT_TASKS` | `20` | Per-daemon concurrent task limit |
| `GIT_AUTHOR_NAME` | None | Git `user.name` applied globally inside the container |
| `GIT_AUTHOR_EMAIL` | None | Git `user.email` applied globally inside the container |

## MULTICA_DAEMON_ID Uniqueness

> **Warning: never run two containers with the same `MULTICA_DAEMON_ID`.**
> They will race over heartbeats and task assignment, causing tasks to stall
> or execute twice.

When `MULTICA_DAEMON_ID` is not set, the entrypoint falls back to `$HOSTNAME`, which Docker sets to the short container ID. That is unique by default.

Set `MULTICA_DAEMON_ID` explicitly when you want a stable, human-readable name on the Runtimes page, such as `daemon-prod-01`. If you scale out with `docker compose up --scale runtime=N`, omit `MULTICA_DAEMON_ID` from your `.env` and let each replica get a distinct ID from its hostname.

## Secret Management

Do **not** put live runtime tokens in a committed `.env` file. The `.env` file is only for daemon-level settings such as `MULTICA_TOKEN`, URLs, daemon IDs, and git identity.

Configure agent CLI credentials in Multica itself. Do not add `ANTHROPIC_API_KEY`, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `GITHUB_TOKEN`, or similar agent secrets to `.env` files.

Recommended approaches for daemon-level secrets, in order of increasing security:

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

Secrets are mounted as files under `/run/secrets/` inside the container. The entrypoint would need updating to read the file; contributions welcome.

**SOPS + age (recommended for teams)**

1. Encrypt your secrets file: `sops --encrypt --age <recipient> .env > .env.enc`
2. Decrypt at deploy time: `sops --decrypt .env.enc > .env && docker compose up -d`
3. Commit only `.env.enc` to version control; never commit the plaintext `.env`.

## Per-Agent CLI Credentials

The Multica daemon image does **not** ship the credentials each AI CLI needs.

Add those credentials to the agent configuration in Multica. Multica injects the configured values into the agent process when it launches a task, so each agent can have its own credentials without exposing them to the whole runtime container.

| CLI | Credential | Where to get it | Configure in Multica as |
| --- | --- | --- | --- |
| **Claude Code** | Anthropic API key | [console.anthropic.com](https://console.anthropic.com) -> API Keys | `ANTHROPIC_API_KEY` |
| **Codex** | OpenAI API key | [platform.openai.com](https://platform.openai.com) -> API Keys | `OPENAI_API_KEY` |
| **GitHub Copilot** | GitHub token with Copilot scope | GitHub -> Settings -> Developer settings -> Personal access tokens | `GITHUB_TOKEN` |
| **Gemini** | Google AI Studio key | [aistudio.google.com](https://aistudio.google.com) -> Get API key | `GEMINI_API_KEY` |
| **OpenCode** | Provider-specific, such as OpenAI or Anthropic | Same as the underlying provider | Provider's own env var |
| **Pi** | Pi API key | Your Pi account settings | `PI_API_KEY` |

Do not pass these credentials through Docker `-e` flags, Compose `.env` files, `--env-file`, Docker secrets mounted into the container, or host credential directory mounts. Those approaches make the secret part of the runtime configuration.

Agent credentials should live with the Multica agent configuration and be scoped to the specific agent process that needs them.
