# Contributing

Thanks for helping improve multica-daemon!

## Conventions

### Dockerfile

- **One `RUN` layer per concern** (apt, CLIs, multica download, filesystem setup). Keep layers lean: chain commands with `&&`, clean package-manager caches in the same layer.
- **Pin package versions when the upstream install path supports it** — no `@latest`, no `latest` npm tags. Versioned CLI packages live in `ARG` declarations at the top of the `production` stage and are mirrored in `docker-bake.hcl` as top-level `variable` blocks so CI can override them at build time. CLIs installed from upstream scripts, such as Hermes, must be documented as unpinned.
- **`ENABLED_CLIS` build arg** — new CLIs must be wired into the `for cli in …; do case … esac; done` loop in the Dockerfile *and* added as a dedicated `target` in `docker-bake.hcl`.
- **Non-root user** — the container runs as the `multica` user. Any filesystem path that the daemon writes to at runtime (`/multica`, `/workspaces`) must be `chown`ed to `multica:multica` before the `USER multica` instruction.
- **Multi-arch** — all images are expected to build cleanly for both `linux/amd64` and `linux/arm64`. Test with `docker buildx bake --set *.platform=linux/amd64,linux/arm64` locally before opening a PR.

### Entrypoint (`src/docker-entrypoint.sh`)

- The script must end with `exec multica daemon start --foreground` (the `exec` is non-negotiable — it replaces the shell as PID 1 so `SIGTERM` reaches the daemon on `docker stop`).
- All required daemon env vars are validated implicitly by the commands that consume them. If you add a new daemon-level var, document it in `docs/configuration.md` and in `.env.example`. Agent CLI credentials belong in Multica agent configuration, not in `.env.example`.

### Versioning and releases

- The project version tracks `MULTICA_VERSION` (the bundled Multica CLI). A bump to any bundled CLI version warrants a new release and a CHANGELOG entry.
- Tags follow `vMAJOR.MINOR.PATCH`. Create a tag on `main` to trigger the CI build and publish workflow.

## Pull request checklist

- [ ] `docker buildx bake` (or `docker build`) completes without errors.
- [ ] New daemon env vars are documented in `docs/configuration.md` and `.env.example`; agent CLI credentials are documented as Multica agent configuration.
- [ ] CHANGELOG entry added under `[Unreleased]`.
- [ ] No secrets, API keys, or tokens committed (check with `git log -p`).

## Reporting issues

Open a GitHub issue. Include the image tag, `docker inspect <container>` output, and `multica daemon logs` output where relevant.
