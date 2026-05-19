# Troubleshooting

## Daemon Offline

The Runtimes page shows the daemon as offline or missing.

```bash
# 1. Check the daemon process is running
docker compose exec daemon multica daemon status

# 2. Tail live logs for error messages
docker compose exec daemon multica daemon logs -f

# 3. Verify the container is healthy
docker inspect --format '{{.State.Health.Status}}' $(docker compose ps -q daemon)

# 4. If the container exited, read the last run's output
docker compose logs daemon --tail 100
```

Common causes:

- `MULTICA_TOKEN` is expired or revoked. Generate a new one from Settings -> Runtimes.
- `MULTICA_SERVER_URL` is wrong or unreachable. Verify with `curl $MULTICA_SERVER_URL/healthz` from inside the container.
- `MULTICA_DAEMON_ID` is duplicated. Rename one of the containers and restart.

## Tool Not Detected

A CLI is installed in the image but no runtime row appears for it in the Multica UI.

```bash
# Confirm the CLI binary exists and is executable
docker compose exec daemon which claude
docker compose exec daemon claude --version

# Check the daemon detected it on startup
docker compose exec daemon multica daemon logs | grep -i "claude\|detected\|registered"
```

Common causes:

- The image variant you pulled does not include that CLI, such as the `claude` variant omitting Codex.
- The CLI requires interactive auth that has not been completed. Exec into the container and run the CLI's login flow manually, then restart.

## Auth Failed

The daemon starts but tasks fail immediately with authentication errors.

```bash
# Confirm the agent credential names configured in Multica match the CLI.
# Multica injects these values into the agent process when a task launches.
docker compose exec daemon multica daemon logs -f
```

Common causes:

- The agent configuration in Multica is missing the required credential.
- The configured credential name does not match what the CLI expects.
- The key has been revoked or has insufficient scope. Regenerate and redeploy.
- For Copilot, `GITHUB_TOKEN` must have the `copilot` scope enabled.

## Task Stuck In Queued

A task has been assigned but stays in queued and never starts.

```bash
# Check how many tasks are currently running on this daemon
docker compose exec daemon multica daemon status

# Check the MULTICA_DAEMON_MAX_CONCURRENT_TASKS setting
docker compose exec daemon env | grep MULTICA_DAEMON_MAX_CONCURRENT_TASKS

# Look for task acceptance/rejection in the logs
docker compose exec daemon multica daemon logs | grep -i "task\|queue\|accept\|reject"
```

Common causes:

- The daemon has reached its `MULTICA_DAEMON_MAX_CONCURRENT_TASKS` limit. Wait for a running task to finish, or increase the limit and restart.
- The daemon is offline. See [Daemon offline](#daemon-offline).
- The workspace the task references has not been connected to this daemon. Verify in the Multica UI under Settings -> Workspaces.
