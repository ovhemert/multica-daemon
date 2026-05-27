#!/usr/bin/env bash

set -eou pipefail

# MULTICA_DAEMON_ID must be unique across all running containers.
# Two containers sharing the same ID will fight over heartbeats and task
# assignment, causing tasks to stall or be duplicated.
# Fall back to $HOSTNAME (the container ID) when the variable is not set,
# which is unique per container by default.
MULTICA_DAEMON_ID="${MULTICA_DAEMON_ID:-${HOSTNAME}}"

# Set daemon configuration
export MULTICA_DAEMON_DEVICE_NAME="${MULTICA_DAEMON_ID}"
multica config set server_url "${MULTICA_SERVER_URL}"
multica config set app_url "${MULTICA_APP_URL}"

# Login
multica login --token "${MULTICA_TOKEN}"

# Start daemon (exec replaces bash as PID 1 so SIGTERM reaches the daemon)
exec multica daemon start --foreground
