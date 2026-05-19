#!/usr/bin/env bash

set -eou pipefail

# Set daemon configuration
export MULTICA_DAEMON_DEVICE_NAME=${MULTICA_DAEMON_ID}
multica config set server_url ${MULTICA_SERVER_URL}
multica config set app_url ${MULTICA_APP_URL}

# Login
multica login --token ${MULTICA_TOKEN}

# Start daemon (exec replaces bash as PID 1 so SIGTERM reaches the daemon)
exec multica daemon start --foreground
