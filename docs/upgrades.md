# Upgrade Guide

## Bumping A CLI Version

Each versioned CLI package has a build arg in `docker-bake.hcl`, such as `CLAUDE_VERSION` or `CODEX_VERSION`. Hermes is installed from the upstream `NousResearch/hermes-agent` install script and does not currently have a pinned version arg.

To upgrade:

1. Update the version variable in `docker-bake.hcl` and the matching `ARG` default in `Dockerfile`.
2. Build and test locally:

   ```bash
   docker buildx bake claude --load
   docker run --rm ghcr.io/ovhemert/multica-daemon:claude claude --version
   ```

3. Open a PR, merge to `main`, and tag a new release.

## Bumping The Multica Daemon

The daemon version is controlled by `MULTICA_VERSION` and drives the project's release version.

Bump it when:

- A new `multica-cli` release includes features or fixes you need.
- The server-side API requires a minimum client version. Watch the Multica changelog for this.

Steps are the same as bumping a CLI version. Add a `CHANGELOG.md` entry.

## Tagging A Release

```bash
git tag v<MULTICA_VERSION>    # e.g. git tag v0.3.4
git push origin v<MULTICA_VERSION>
```

The CI workflow triggers on tags matching `v*` and publishes multi-arch images to GHCR.

## Breaking-Change Policy

- **No breaking changes** to environment variable names or mount paths without a major version bump and a migration note in `CHANGELOG.md`.
- **Pinned versions** and immutable image digests mean existing releases do not change. You opt into upgrades by pulling a new tag.
- **Deprecation window** means if a variable or behavior is removed, it will be documented as deprecated in one release before being removed in the next.
