#!/usr/bin/env bash

set -eou pipefail

HERMES_HOME="${HERMES_HOME:-/opt/data}"
HERMES_INSTALL_DIR="${HERMES_INSTALL_DIR:-/opt/hermes}"

if [ "$(id -u)" = "0" ]; then
  if [ -n "${HERMES_UID:-}" ] && [ "${HERMES_UID}" != "$(id -u hermes)" ]; then
    usermod -u "${HERMES_UID}" hermes
  fi

  if [ -n "${HERMES_GID:-}" ] && [ "${HERMES_GID}" != "$(id -g hermes)" ]; then
    groupmod -o -g "${HERMES_GID}" hermes 2>/dev/null || true
  fi

  chown -R hermes:hermes "${HERMES_HOME}" /workspaces 2>/dev/null || true
  chown -R hermes:hermes "${HERMES_INSTALL_DIR}/.venv" 2>/dev/null || true

  exec gosu hermes "$0" "$@"
fi

export HERMES_HOME
export HOME="${HOME:-${HERMES_HOME}}"
export VIRTUAL_ENV="${VIRTUAL_ENV:-${HERMES_INSTALL_DIR}/.venv}"
export PATH="${VIRTUAL_ENV}/bin:${HERMES_HOME}/.local/bin:${PATH}"

mkdir -p "${HERMES_HOME}"/{cron,sessions,logs,hooks,memories,skills,skins,plans,workspace,home}

if [ ! -f "${HERMES_HOME}/.env" ] && [ -f "${HERMES_INSTALL_DIR}/.env.example" ]; then
  # cp "${HERMES_INSTALL_DIR}/.env.example" "${HERMES_HOME}/.env"
  printenv > "${HERMES_HOME}/.env"
fi

if [ ! -f "${HERMES_HOME}/config.yaml" ] && [ -f "${HERMES_INSTALL_DIR}/cli-config.yaml.example" ]; then
  cp "${HERMES_INSTALL_DIR}/cli-config.yaml.example" "${HERMES_HOME}/config.yaml"
fi

if [ ! -f "${HERMES_HOME}/SOUL.md" ] && [ -f "${HERMES_INSTALL_DIR}/docker/SOUL.md" ]; then
  cp "${HERMES_INSTALL_DIR}/docker/SOUL.md" "${HERMES_HOME}/SOUL.md"
fi

if [ ! -f "${HERMES_HOME}/auth.json" ] && [ -n "${HERMES_AUTH_JSON_BOOTSTRAP:-}" ]; then
  printf '%s' "${HERMES_AUTH_JSON_BOOTSTRAP}" > "${HERMES_HOME}/auth.json"
  chmod 600 "${HERMES_HOME}/auth.json"
fi

if [ -d "${HERMES_INSTALL_DIR}/skills" ] && [ -f "${HERMES_INSTALL_DIR}/tools/skills_sync.py" ]; then
  python3 "${HERMES_INSTALL_DIR}/tools/skills_sync.py"
fi

exec /docker-entrypoint.sh "$@"
