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

# CLI versions
ARG \
  CLAUDE_VERSION=2.1.144 \
  CODEX_VERSION=0.131.0 \
  COPILOT_VERSION=1.0.50 \
  GEMINI_VERSION=0.42.0 \
  MULTICA_VERSION=0.3.3 \
  OPENCODE_VERSION=1.15.5 \
  PI_VERSION=0.75.3

# Which CLIs to install — comma-separated list of: claude,codex,copilot,gemini,hermes,opencode,pi
# Default installs all CLIs (the "all" / "latest" image variant).
ARG ENABLED_CLIS=claude,codex,copilot,gemini,hermes,opencode,pi

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN set -e; \
  for cli in $(printf '%s' "${ENABLED_CLIS}" | tr ',' ' '); do \
    case "$cli" in \
      claude)   npm install -g "@anthropic-ai/claude-code@${CLAUDE_VERSION}" ;; \
      codex)    npm install -g "@openai/codex@${CODEX_VERSION}" ;; \
      copilot)  npm install -g "@github/copilot@${COPILOT_VERSION}" ;; \
      gemini)   npm install -g "@google/gemini-cli@${GEMINI_VERSION}" ;; \
      hermes)   curl -fsSL https://raw.githubusercontent.com/NousResearch/hermes-agent/main/scripts/install.sh | UV_DATA_DIR=/usr/local/share/uv bash ;; \
      opencode) npm install -g "opencode-ai@${OPENCODE_VERSION}" ;; \
      pi)       npm install -g "@earendil-works/pi-coding-agent@${PI_VERSION}" ;; \
    esac; \
  done

# Multica (daemon) — always installed regardless of ENABLED_CLIS
RUN ARCH="$(uname -m | sed 's/x86_64/amd64/;s/aarch64/arm64/')" \
  && curl -fsSL -o /tmp/multica.tgz "https://github.com/multica-ai/multica/releases/download/v${MULTICA_VERSION}/multica-cli-${MULTICA_VERSION}-linux-${ARCH}.tar.gz" \
  && tar -xzf /tmp/multica.tgz -C /usr/local/bin multica \
  && rm -f /tmp/multica.tgz

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
