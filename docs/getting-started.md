# Getting Started

## Docker Compose

1. **Get a runtime installer token** from the Multica UI: Settings -> Runtimes -> Install a runtime. It looks like `mul_...`.

2. **Create your `.env`** by copying the example and filling in the token:

   ```bash
   cp .env.example .env
   $EDITOR .env
   ```

   Minimum required variables:

   | Variable | Description |
   | --- | --- |
   | `MULTICA_APP_URL` | URL of the Multica web app, such as `https://app.multica.ai` |
   | `MULTICA_SERVER_URL` | URL of the Multica API/WebSocket server |
   | `MULTICA_TOKEN` | Runtime installer token (`mul_...`) |

   > **Do not commit live runtime tokens to version control.** Use `--env-file`
   > with a file outside your repo, Docker secrets, or SOPS/age for
   > daemon-level secrets only. See [Secret management](./configuration.md#secret-management)
   > for details. Configure agent CLI credentials in Multica, not in `.env`.

3. **Start the runtimes:**

   ```bash
   docker compose --profile all up -d
   docker compose logs -f
   ```

   Use a single profile, such as `--profile claude`, when you only want one agent container.

4. **Verify** by opening the Runtimes page in the Multica UI. You should see one row per started daemon container, all marked online. From there, you can assign issues or tasks and they will be picked up by the matching runtime.

To stop the runtime:

```bash
docker compose down
```

## Plain Docker

```bash
docker build -f docker/Dockerfile.claude -t multica-daemon:dev-claude .

docker run -d \
  --name multica-daemon-claude \
  -e MULTICA_APP_URL=https://app.multica.ai \
  -e MULTICA_SERVER_URL=https://api.multica.ai \
  -e MULTICA_TOKEN=mul_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx \
  -e MULTICA_DAEMON_ID=daemon-claude-01 \
  -v workspaces:/workspaces \
  multica-daemon:dev-claude
```
