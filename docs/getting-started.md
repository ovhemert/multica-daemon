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
   | `MULTICA_DAEMON_ID` | A unique name for this daemon, shown in the Runtimes page; defaults to `$HOSTNAME` if omitted |
   | `GIT_AUTHOR_NAME` | Name used for git commits produced by agent tasks |
   | `GIT_AUTHOR_EMAIL` | Email used for git commits produced by agent tasks |

   > **Do not commit live runtime tokens to version control.** Use `--env-file`
   > with a file outside your repo, Docker secrets, or SOPS/age for
   > daemon-level secrets only. See [Secret management](./configuration.md#secret-management)
   > for details. Configure agent CLI credentials in Multica, not in `.env`.

3. **Start the runtime:**

   ```bash
   docker compose up -d
   docker compose logs -f runtime
   ```

4. **Verify** by opening the Runtimes page in the Multica UI. You should see one row per enabled CLI for this daemon, all marked online. From there, you can assign issues or tasks and they will be picked up by this container.

To stop the runtime:

```bash
docker compose down
```

## Plain Docker

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
