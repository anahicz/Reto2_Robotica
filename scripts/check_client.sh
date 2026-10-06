#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/ros_env.sh"

missing=0

printf '\n=== VARIABLES ===\n'
printf 'ROS_DOMAIN_ID=%s\n' "${ROS_DOMAIN_ID}"
printf 'ROS_LOCALHOST_ONLY=%s\n' "${ROS_LOCALHOST_ONLY}"
printf 'RMW_IMPLEMENTATION=%s\n' "${RMW_IMPLEMENTATION}"
printf 'ROS_DISCOVERY_SERVER=%s\n' "${ROS_DISCOVERY_SERVER}"
printf 'FASTRTPS_DEFAULT_PROFILES_FILE=%s\n' "${FASTRTPS_DEFAULT_PROFILES_FILE}"

if [[ ! -f "${FASTRTPS_DEFAULT_PROFILES_FILE}" ]]; then
  echo "[ERROR] XML de FastDDS no encontrado."
  missing=1
fi

printf '\n=== DAEMON ===\n'
ros2 daemon stop >/dev/null 2>&1 || true
sleep 2
ros2 daemon start
sleep 4

printf '\n=== INTERFAZ ===\n'
if ! ros2 interface show arm_broker_interfaces/action/MoveArm; then
  echo "[ERROR] arm_broker_interfaces no está disponible en este cliente."
  missing=1
fi

printf '\n=== ACTIONS ===\n'
ros2 action list -t || true
ros2 action info /move_arm || true

printf '\n=== TOPICS ===\n'
ros2 topic list -t || true

if ros2 topic list | grep -qx '/arm/queue_state'; then
  printf '\n=== /arm/queue_state (1 muestra, máx. 6 s) ===\n'
  timeout 6 ros2 topic echo /arm/queue_state --once || true
else
  echo "[ERROR] No se descubre /arm/queue_state."
  missing=1
fi

if ros2 topic list | grep -qx '/joint_states'; then
  echo "[OK] /joint_states descubierto."
else
  echo "[ERROR] No se descubre /joint_states."
  missing=1
fi

if [[ ${missing} -ne 0 ]]; then
  echo "\n[RESULTADO] Hay problemas de configuración/discovery. No grabes el bag todavía."
  exit 1
fi

echo "\n[RESULTADO] Cliente listo para la prueba."
