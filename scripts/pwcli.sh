#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PROJECT_NAME="$(basename "${ROOT_DIR}")"
PROJECT_PLAYWRIGHT_DIR="${ROOT_DIR}/output/playwright"
PROJECT_BROWSER_DIR="${ROOT_DIR}/.playwright-browsers"
PROJECT_NPM_CACHE_DIR="${ROOT_DIR}/.npm-cache"

if [[ -x "${ROOT_DIR}/codex/skills/playwright/scripts/playwright_cli.sh" ]]; then
    PWCLI="${ROOT_DIR}/codex/skills/playwright/scripts/playwright_cli.sh"
else
    CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"
    PWCLI="${CODEX_HOME}/skills/playwright/scripts/playwright_cli.sh"
fi

if [[ ! -x "${PWCLI}" ]]; then
    echo "Playwright skill wrapper not found: ${PWCLI}" >&2
    echo "Run make bootstrap first." >&2
    exit 1
fi

mkdir -p "${PROJECT_PLAYWRIGHT_DIR}" "${PROJECT_BROWSER_DIR}" "${PROJECT_NPM_CACHE_DIR}"

export PLAYWRIGHT_BROWSERS_PATH="${PLAYWRIGHT_BROWSERS_PATH:-${PROJECT_BROWSER_DIR}}"
export PLAYWRIGHT_CLI_SESSION="${PLAYWRIGHT_CLI_SESSION:-${PROJECT_NAME}}"
export npm_config_cache="${npm_config_cache:-${PROJECT_NPM_CACHE_DIR}}"
export CODEX_HOME="${CODEX_HOME:-${HOME}/.codex}"

cd "${PROJECT_PLAYWRIGHT_DIR}"
exec "${PWCLI}" "$@"
