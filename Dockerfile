FROM node:24-trixie-slim AS base
RUN apt-get update \
  && apt-get install -y --no-install-recommends ca-certificates curl git
RUN corepack enable



FROM base AS production

# Install CLI's
ARG \
  CLAUDE_VERSION=2.1.143 \
  CODEX_VERSION=0.130.0 \
  COPILOT_VERSION=1.0.48 \
  CURSOR_VERSION=1.1.0 \
  GEMINI_VERSION=0.42.0 \
  HERMES_VERSION=0.3.1 \
  KIMI_VERSION=1.0.11 \
  KIRO_VERSION=0.0.1 \
  OPENCODE_VERSION=1.15.4 \
  OPENCLAW_VERSION=2026.5.18 \
  PI_VERSION=0.75.3

RUN npm install -g @anthropic-ai/claude-code@${CLAUDE_VERSION}
RUN npm install -g @openai/codex@${CODEX_VERSION}
RUN npm install -g @github/copilot@${COPILOT_VERSION}
RUN npm install -g @nothumanwork/cursor-agent-cli@${CURSOR_VERSION}
RUN npm install -g @google/gemini-cli@${GEMINI_VERSION}
RUN npm install -g hermes-coding@${HERMES_VERSION}
RUN npm install -g kimi-code@${KIMI_VERSION}
RUN npm install -g kiro-cli@${KIRO_VERSION}
RUN npm install -g opencode-ai@${OPENCODE_VERSION}
RUN npm install -g openclaw@${OPENCLAW_VERSION}
RUN npm install -g @earendil-works/pi-coding-agent@${PI_VERSION}

# Multica (daemon)
RUN curl -fsSL https://raw.githubusercontent.com/multica-ai/multica/main/scripts/install.sh | bash

# Filesystem
RUN mkdir -p /multica /workspaces
COPY src/docker-entrypoint.sh /docker-entrypoint.sh
RUN chmod +x /docker-entrypoint.sh

# Create non-root user so claude --dangerously-skip-permissions works
RUN useradd -m -s /bin/bash multica \
  && chown -R multica:multica /multica /workspaces
USER multica

# Environment variables
ENV \
  HOME=/multica \
  MULTICA_WORKSPACES_ROOT=/workspaces \
  PATH=/usr/local/bin:/usr/bin:/bin \
  SHELL=/bin/bash

ENTRYPOINT ["/docker-entrypoint.sh"]
