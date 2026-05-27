#!/usr/bin/env bash

set -eou pipefail

if [[ "$(id -u)" == "0" ]]; then
  chown -R multica:multica /opt/data
  exec /usr/sbin/gosu multica "$0" "$@"
fi

if [[ -n "${GITHUB_TOKEN:-}" ]]; then
  /opt/hermes/.venv/bin/python - <<'PY'
from pathlib import Path

import yaml

config_path = Path("/opt/data/config.yaml")
config_path.parent.mkdir(parents=True, exist_ok=True)

if config_path.exists():
    with config_path.open(encoding="utf-8") as handle:
        config = yaml.safe_load(handle) or {}
else:
    config = {}

terminal = config.setdefault("terminal", {})
passthrough = terminal.setdefault("env_passthrough", [])

for name in ("GITHUB_TOKEN", "GH_TOKEN"):
    if name not in passthrough:
        passthrough.append(name)

with config_path.open("w", encoding="utf-8") as handle:
    yaml.safe_dump(config, handle, sort_keys=False)
PY
fi

exec /docker-entrypoint.sh "$@"
