# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project uses calendar-based version tags (`MULTICA_VERSION` of the bundled daemon CLI, e.g. `v0.3.3`).

## [Unreleased]

## [v0.3.3] — 2026-05-19

### Fixed
- CI: trigger image builds only on version tags, not on every push.
- CI: switch Docker build layer cache backend to the GHCR OCI registry cache.

## [v0.3.2] — 2026-05-19

### Added
- Image variants: per-CLI tags (`claude`, `codex`, `copilot`, `gemini`, `opencode`, `pi`) in addition to the bundled `all` / `latest` image.
- `docker-bake.hcl` with a shared `_common` target; all variants inherit build args from it.
- Multi-arch native builds (`linux/amd64` + `linux/arm64`) via GitHub-hosted runners.
- `ENABLED_CLIS` build arg to control which CLIs are installed at build time.

### Changed
- Dockerfile refactored for a smaller, more reproducible image (tighter `apt` layer, exec-form entrypoint for correct PID 1 signal handling).
- `MULTICA_VERSION` is now a pinned build arg; every CLI version is pinned the same way.
- `MULTICA_DAEMON_DEVICE_NAME` is derived from `MULTICA_DAEMON_ID` in the entrypoint instead of being a separate variable.

### Fixed
- `exec multica daemon` replaces the entrypoint shell as PID 1 so `SIGTERM` is delivered correctly on `docker stop`.
- Prevented pipe-masked failures in the `multica` tarball download.

## [v0.3.0] — initial release

### Added
- Initial `Dockerfile` bundling the Multica daemon with Claude Code, Codex, GitHub Copilot, Gemini, OpenCode, and Pi.
- `docker-compose.yml` for local one-command startup.
- `src/docker-entrypoint.sh`: configures server URLs, logs in with `MULTICA_TOKEN`, then starts the daemon as PID 1.
- Non-root `multica` user; `HOME=/multica`, workspace root at `/workspaces`.
- `HEALTHCHECK` using `multica daemon status`.
- MIT license.

[Unreleased]: https://github.com/ovhemert/multica-daemon/compare/v0.3.3...HEAD
[v0.3.3]: https://github.com/ovhemert/multica-daemon/compare/v0.3.2...v0.3.3
[v0.3.2]: https://github.com/ovhemert/multica-daemon/compare/v0.3.0...v0.3.2
[v0.3.0]: https://github.com/ovhemert/multica-daemon/releases/tag/v0.3.0
