#!/usr/bin/env bash
# Compatibilidad con la guía anterior.
# La preparación actual está centralizada en bootstrap_raspberry.sh.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec bash "${SCRIPT_DIR}/bootstrap_raspberry.sh" "${@}"
