FROM node:24-trixie-slim AS base
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl git \
  && rm -rf /var/lib/apt/lists/*



FROM base AS production

# OCI image labels
ARG VERSION=latest
LABEL org.opencontainers.image.title="multica-daemon" \
      org.opencontainers.image.description="Multica daemon runtime with multiple AI coding agent CLIs" \
      org.opencontainers.image.source="https://github.com/ovhemert/multica-daemon" \
      org.opencontainers.image.licenses="MIT" \
      org.opencontainers.image.version="${VERSION}"

# Install CLI's
ARG \
  CLAUDE_VERSION=2.1.143 \
  CODEX_VERSION=0.130.0 \
  COPILOT_VERSION=1.0.48 \
  GEMINI_VERSION=0.42.0 \
  MULTICA_VERSION=0.3.2 \
  OPENCODE_VERSION=1.15.4 \
  PI_VERSION=0.75.3

RUN npm install -g \
  @anthropic-ai/claude-code@${CLAUDE_VERSION} \
  @openai/codex@${CODEX_VERSION} \
  @github/copilot@${COPILOT_VERSION} \
  @google/gemini-cli@${GEMINI_VERSION} \
  opencode-ai@${OPENCODE_VERSION} \
  @earendil-works/pi-coding-agent@${PI_VERSION}

# Multica (daemon)
RUN ARCH="$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')" \
  && curl -fsSL "https://github.com/multica-ai/multica/releases/download/v${MULTICA_VERSION}/multica-cli-${MULTICA_VERSION}-linux-${ARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin multica

# Filesystem
RUN mkdir -p /multica /workspaces
COPY src/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Create non-root user so claude --dangerously-skip-permissions works
# Global npm packages remain root-owned at /usr/local/lib/node_modules — intentional and safe for execution
RUN useradd -m -s /bin/bash multica \
  && chown -R multica:multica /multica /workspaces
USER multica

# Environment variables
ENV \
  HOME=/multica \
  MULTICA_WORKSPACES_ROOT=/workspaces \
  PATH=/usr/local/bin:/usr/bin:/bin \
  SHELL=/bin/bash

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD multica daemon status

ENTRYPOINT ["/docker-entrypoint.sh"]
