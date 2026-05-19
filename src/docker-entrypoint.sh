#!/usr/bin/env bash

set -eou pipefail

# Disable tools when not used (by changing search path)
if [ "${CLAUDE_ENABLED:-false}" != "true" ]; then export MULTICA_CLAUDE_PATH=/; fi
if [ "${CODEX_ENABLED:-false}" != "true" ]; then export MULTICA_CODEX_PATH=/; fi
if [ "${COPILOT_ENABLED:-false}" != "true" ]; then export MULTICA_COPILOT_PATH=/; fi
if [ "${GEMINI_ENABLED:-false}" != "true" ]; then export MULTICA_GEMINI_PATH=/; fi
if [ "${OPENCODE_ENABLED:-false}" != "true" ]; then export MULTICA_OPENCODE_PATH=/; fi
if [ "${PI_ENABLED:-false}" != "true" ]; then export MULTICA_PI_PATH=/; fi

# Set daemon configuration
export MULTICA_DAEMON_DEVICE_NAME=${MULTICA_DAEMON_ID}
multica config set server_url ${MULTICA_SERVER_URL}
multica config set app_url ${MULTICA_APP_URL}

# Login
multica login --token ${MULTICA_TOKEN}

# Start daemon
multica daemon start --foreground
