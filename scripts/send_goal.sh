#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 8 ]]; then
  cat <<'USAGE'
Uso:
  bash scripts/send_goal.sh CLIENTE PRIORIDAD q1 q2 q3 q4 q5 q6

Ejemplo usado durante las pruebas:
  bash scripts/send_goal.sh Sebastian 10 0.0 -0.5 0.5 0.0 0.5 0.0

Los valores articulares se envían en radianes a /move_arm.
USAGE
  exit 2
fi

CLIENT_ID="$1"
PRIORITY="$2"
shift 2
JOINTS=("$@")

if ! [[ "${PRIORITY}" =~ ^[0-9]+$ ]] || (( PRIORITY < 0 || PRIORITY > 255 )); then
  echo "[ERROR] PRIORIDAD debe estar entre 0 y 255."
  exit 3
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/ros_env.sh"

ros2 action send_goal /move_arm arm_broker_interfaces/action/MoveArm \
  "{joint_positions: [${JOINTS[0]}, ${JOINTS[1]}, ${JOINTS[2]}, ${JOINTS[3]}, ${JOINTS[4]}, ${JOINTS[5]}], client_id: '${CLIENT_ID}', priority: ${PRIORITY}}" \
  --feedback
