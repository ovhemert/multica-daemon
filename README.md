# Multica Daemon - Containerized Runtimes

This repository builds Docker images that bundle the [Multica](https://multica.ai) daemon with dedicated AI coding agent CLIs, including Claude Code, Codex, Copilot, Gemini, Hermes, OpenCode, and Pi.

Its main purpose is to make [Multica runtimes](https://multica.ai/docs/daemon-runtimes) reproducible, isolated, and horizontally scalable. Instead of installing every AI coding CLI on every developer machine, you can run these images anywhere Docker runs: locally with Docker Compose, on a server, or on Kubernetes.

In Multica, a runtime is the combination of one daemon and one AI coding tool. This repo packages that combination into per-agent container images so each daemon container registers the runtime for its installed CLI with the Multica server.

## Documentation

- [Architecture](./docs/architecture.md) - runtime model, scaling behavior, and what is included in the images
- [Getting started](./docs/getting-started.md) - Docker Compose and plain Docker quick starts
- [Configuration](./docs/configuration.md) - environment variables, daemon IDs, and secret handling
- [Images](./docs/images.md) - published image variants and repository layout
- [Operations](./docs/operations.md) - runtime behavior, persistence, logging, and recovery notes
- [Troubleshooting](./docs/troubleshooting.md) - common daemon, tool detection, auth, and queue issues
- [Upgrade guide](./docs/upgrades.md) - bumping CLI or daemon versions and tagging releases

## Related Files

- [Contributing](./CONTRIBUTING.md)
- [Changelog](./CHANGELOG.md)
- [Security policy](./SECURITY.md)
- [License](./LICENSE.md)

## License

[MIT](./LICENSE.md) (c) Osmond van Hemert
