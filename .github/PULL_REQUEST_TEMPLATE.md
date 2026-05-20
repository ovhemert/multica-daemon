## Summary

<!-- What does this PR do and why? Link the related issue if applicable. -->

## Changes

<!-- List the key changes. Focus on the "what" and "why", not the "how" (the diff covers that). -->

- 

## Checklist

- [ ] `docker buildx bake` (or `docker build`) completes without errors.
- [ ] New daemon env vars are documented in `docs/configuration.md` and `.env.example`; agent CLI credentials are documented as Multica agent configuration.
- [ ] CHANGELOG entry added under `[Unreleased]`.
- [ ] No secrets, API keys, or tokens committed (check with `git log -p`).
- [ ] Multi-arch build tested for `linux/amd64` and `linux/arm64` (or N/A for docs-only changes).
