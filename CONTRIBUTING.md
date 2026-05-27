# Contributing

Thanks for helping improve multica-daemon!

## Conventions

### Docker Assets

- **One `RUN` layer per concern** (apt, CLIs, multica download, filesystem setup). Keep layers lean: chain commands with `&&`, clean package-manager caches in the same layer.
- **Pin package versions when the upstream install path supports it** — no `@latest`, no `latest` npm tags. Versioned CLI packages are centralized in `versions.env`; production Dockerfiles should `COPY versions.env` and source it with `. versions.env` instead of defining per-Dockerfile `ARG <CLI>_VERSION=...` / `MULTICA_VERSION=...` blocks. Update `versions.env` when bumping bundled CLI versions.
- **Dedicated variants** — each CLI has its own `docker/Dockerfile.<variant>` file. New CLI variants must get a dedicated Dockerfile and be added to the CI variant matrices.
- **Non-root user** — containers run as the `multica` user. Any filesystem path that the daemon writes to at runtime (`/multica`, `/workspaces`) must be `chown`ed to `multica:multica` before the `USER multica` instruction.
- **Multi-arch** — all images are expected to build cleanly for both `linux/amd64` and `linux/arm64`. Test the affected variant with its Dockerfile, such as `docker buildx build --platform linux/amd64,linux/arm64 -f docker/Dockerfile.claude .` locally before opening a PR.

### Entrypoint (`docker/docker-entrypoint.sh`)

- The script must end with `exec multica daemon start --foreground` (the `exec` is non-negotiable — it replaces the shell as PID 1 so `SIGTERM` reaches the daemon on `docker stop`).
- All required daemon env vars are validated implicitly by the commands that consume them. If you add a new daemon-level var, document it in `docs/configuration.md` and in `.env.example`. Agent CLI credentials belong in Multica agent configuration, not in `.env.example`.

### Versioning and releases

- The project version tracks `MULTICA_VERSION` (the bundled Multica CLI). A bump to any bundled CLI version warrants a new release and a CHANGELOG entry.
- Tags follow `vMAJOR.MINOR.PATCH`. Create a tag on `main` to trigger the CI build and publish workflow.

## Pull request checklist

- [ ] The affected `docker buildx build --platform linux/amd64,linux/arm64 -f docker/Dockerfile.<variant> .` variant completes without errors.
- [ ] New daemon env vars are documented in `docs/configuration.md` and `.env.example`; agent CLI credentials are documented as Multica agent configuration.
- [ ] CHANGELOG entry added under `[Unreleased]`.
- [ ] No secrets, API keys, or tokens committed (check with `git log -p`).

## Reporting issues

Open a GitHub issue. Include the image tag, `docker inspect <container>` output, and `multica daemon logs` output where relevant.
