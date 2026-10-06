#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

git -C "${ROOT}" pull --ff-only origin main
exec bash "${ROOT}/scripts/bootstrap_raspberry.sh" "${@}"
