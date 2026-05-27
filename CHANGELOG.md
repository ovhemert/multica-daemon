# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project uses calendar-based version tags (`MULTICA_VERSION` of the bundled daemon CLI, e.g. `v0.3.0`).

## [Unreleased]

### Added
- `GITHUB_TOKEN` / `GIT_ASKPASS` workflow for authenticated private repository clones, with supporting documentation and compose/env examples.

### Changed
- Hermes image builds from the Node.js 24 variant base, installs `hermes-agent`, then installs the Multica daemon like the other agent variants.

### Removed
- Default `GIT_AUTHOR_NAME` / `GIT_AUTHOR_EMAIL` environment values from compose; set them explicitly when needed.

## [v0.3.8] — 2026-05-26

### Added
- GHCR cleanup workflow for untagged image versions and orphaned referrer artifacts.

### Changed
- Multica daemon CLI updated to `0.3.8`.

## [v0.3.6] — 2026-05-25

### Changed
- Multica daemon CLI updated to `0.3.6`.
- CLI pins updated: Copilot `1.0.54` and Pi `0.75.5`.
- Hermes base image updated to `nousresearch/hermes-agent:main` (Hermes Agent `v0.14.0` at release time).

## [v0.3.5] — 2026-05-23

### Changed
- Claude now builds from a dedicated `docker/Dockerfile.claude` image variant.
- Codex, Copilot, Gemini, OpenCode, and Pi now build from dedicated `docker/Dockerfile.<variant>` image variants.
- Hermes now builds from the upstream `nousresearch/hermes-agent` base image in a dedicated `docker/Dockerfile.hermes` image variant.
- CI now builds and publishes only dedicated per-agent image variants.
- Multica daemon CLI updated to `0.3.5`.
- CLI pins updated: Claude `2.1.150`, Codex `0.133.0`, Copilot `1.0.51`, Gemini `0.43.0`, OpenCode `1.15.10`, and Pi `0.75.4`.

### Removed
- Docker Buildx Bake configuration; CI now remains the source of truth for variant builds.
- Bundled `all` / unqualified image builds; use the per-agent tags instead.

## [v0.3.4] — 2026-05-21

### Added
- Hermes agent image variant and bundled all-in-one runtime support.

## [v0.3.3] — 2026-05-19

### Fixed
- CI: trigger image builds only on version tags, not on every push.
- CI: switch Docker build layer cache backend to the GHCR OCI registry cache.

## [v0.3.2] — 2026-05-19

### Added
- Image variants: per-CLI tags (`claude`, `codex`, `copilot`, `gemini`, `opencode`, `pi`) in addition to the bundled `all` / `latest` image.
- Shared variant build definitions so all image variants inherit common build args.
- Multi-arch native builds (`linux/amd64` + `linux/arm64`) via GitHub-hosted runners.
- `ENABLED_CLIS` build arg to control which CLIs are installed at build time.

### Changed
- `docker/Dockerfile` refactored for a smaller, more reproducible image (tighter `apt` layer, exec-form entrypoint for correct PID 1 signal handling).
- `MULTICA_VERSION` is now a pinned build arg; every CLI version is pinned the same way.
- `MULTICA_DAEMON_DEVICE_NAME` is derived from `MULTICA_DAEMON_ID` in the entrypoint instead of being a separate variable.

### Fixed
- `exec multica daemon` replaces the entrypoint shell as PID 1 so `SIGTERM` is delivered correctly on `docker stop`.
- Prevented pipe-masked failures in the `multica` tarball download.

## [v0.3.0] — initial release

### Added
- Initial `docker/Dockerfile` bundling the Multica daemon with Claude Code, Codex, GitHub Copilot, Gemini, OpenCode, and Pi.
- `docker-compose.yml` for local one-command startup.
- `docker/docker-entrypoint.sh`: configures server URLs, logs in with `MULTICA_TOKEN`, then starts the daemon as PID 1.
- Non-root `multica` user; `HOME=/multica`, workspace root at `/workspaces`.
- `HEALTHCHECK` using `multica daemon status`.
- MIT license.

[Unreleased]: https://github.com/ovhemert/multica-daemon/compare/v0.3.8...HEAD
[v0.3.8]: https://github.com/ovhemert/multica-daemon/compare/v0.3.6...v0.3.8
[v0.3.6]: https://github.com/ovhemert/multica-daemon/compare/v0.3.5...v0.3.6
[v0.3.5]: https://github.com/ovhemert/multica-daemon/compare/v0.3.4...v0.3.5
[v0.3.4]: https://github.com/ovhemert/multica-daemon/compare/v0.3.3...v0.3.4
[v0.3.3]: https://github.com/ovhemert/multica-daemon/compare/v0.3.2...v0.3.3
[v0.3.2]: https://github.com/ovhemert/multica-daemon/compare/v0.3.0...v0.3.2
[v0.3.0]: https://github.com/ovhemert/multica-daemon/releases/tag/v0.3.0
