# Operations

## Runtime Behavior

- **Heartbeats and offline detection.** The daemon sends a heartbeat every 15 seconds. If the Multica server misses three heartbeats, it marks the runtime as missing and reclaims in-flight tasks. Never run more than one container with the same `MULTICA_DAEMON_ID`; see [MULTICA_DAEMON_ID uniqueness](./configuration.md#multica_daemon_id-uniqueness).
- **Crash recovery.** On startup, the daemon tells the server that any tasks still marked as mine are no longer running. Combined with the server-side 30-second reaper, restarts of this container are safe. The `restart: unless-stopped` policy in `docker-compose.yml` ensures the daemon comes back automatically after host reboots or crashes.
- **Workspaces.** The `docker-compose.yml` declares a named Docker volume (`workspaces`) mounted at `/workspaces`. Repo clones survive `docker compose down` and restart automatically, so there is no re-clone on each startup. For plain `docker run` usage, add `-v workspaces:/workspaces` to persist the directory.
- **Non-root.** The container runs as `multica`, with uid set by `useradd -m`. If you mount host directories, make sure they are readable by that uid.
- **Logs.** The daemon logs to stdout, so `docker logs` and `docker compose logs -f` work. For more detail, exec into the container and run `multica daemon logs -f`.
