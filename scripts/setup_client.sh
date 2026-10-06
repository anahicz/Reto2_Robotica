#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CFG="${RB2_NETWORK_CONFIG:-${ROOT}/config/network.env}"
COPY_FROM_JETSON=0

if [[ "${1:-}" == "--copy-from-jetson" ]]; then
  COPY_FROM_JETSON=1
fi

if [[ ! -f "${CFG}" ]]; then
  cp "${ROOT}/config/network.env.example" "${CFG}"
  echo "[ATENCIÓN] Se creó ${CFG}. Revísalo y vuelve a ejecutar este script."
  exit 2
fi

# shellcheck disable=SC1090
source "${CFG}"

if [[ ! -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
  echo "[ERROR] ROS 2 ${ROS_DISTRO} no está disponible en /opt/ros/${ROS_DISTRO}."
  exit 3
fi

# shellcheck disable=SC1090
source "/opt/ros/${ROS_DISTRO}/setup.bash"
mkdir -p "${WORKSPACE}/src"

REPO_IFACE="${ROOT}/src/arm_broker_interfaces"
WS_IFACE="${WORKSPACE}/src/arm_broker_interfaces"

if [[ -d "${REPO_IFACE}" ]]; then
  echo "[INFO] Instalando arm_broker_interfaces desde el repositorio..."
  rm -rf "${WS_IFACE}"
  cp -a "${REPO_IFACE}" "${WS_IFACE}"
elif [[ ! -d "${WS_IFACE}" && ${COPY_FROM_JETSON} -eq 1 ]]; then
  echo "[INFO] Copiando arm_broker_interfaces desde ${JETSON_USER}@${JETSON_HOST}..."
  scp -r "${JETSON_USER}@${JETSON_HOST}:${JETSON_WORKSPACE}/src/kit_reto_alumno/src/arm_broker_interfaces" "${WORKSPACE}/src/"
elif [[ ! -d "${WS_IFACE}" ]]; then
  cat >&2 <<MSG
[ERROR] arm_broker_interfaces no está en ${WS_IFACE} ni en el repositorio.
Opciones:
  1) Añadir src/arm_broker_interfaces al repositorio; o
  2) Ejecutar: bash scripts/setup_client.sh --copy-from-jetson
MSG
  exit 4
fi

if [[ ! -f "${FASTRTPS_DEFAULT_PROFILES_FILE}" ]]; then
  echo "[ERROR] Falta ${FASTRTPS_DEFAULT_PROFILES_FILE}."
  echo "Copia el super_client_configuration_file.xml correcto y vuelve a ejecutar."
  exit 5
fi

cd "${WORKSPACE}"
colcon build --packages-select arm_broker_interfaces

# shellcheck disable=SC1090
source "${WORKSPACE}/install/setup.bash"
export ROS_DOMAIN_ID ROS_LOCALHOST_ONLY RMW_IMPLEMENTATION ROS_DISCOVERY_SERVER
export FASTRTPS_DEFAULT_PROFILES_FILE

ros2 daemon stop >/dev/null 2>&1 || true
sleep 2
ros2 daemon start
sleep 4

echo "=============================="
echo "INTERFAZ MOVEARM"
ros2 interface show arm_broker_interfaces/action/MoveArm

echo "=============================="
echo "ACTION SERVER"
ros2 action info /move_arm || true

echo "=============================="
echo "Cliente preparado. En una terminal nueva ejecuta:"
echo "  source ${ROOT}/scripts/ros_env.sh"
