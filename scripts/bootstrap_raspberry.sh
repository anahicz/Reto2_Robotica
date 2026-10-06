#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
CFG="${RB2_NETWORK_CONFIG:-${ROOT}/config/network.env}"
FULL=0

if [[ "${1:-}" == "--full" ]]; then
  FULL=1
fi

if [[ ! -f "${CFG}" ]]; then
  cp "${ROOT}/config/network.env.example" "${CFG}"
  echo "[INFO] Se creó ${CFG} con la configuración validada. Edítalo si cambió la red."
fi

# shellcheck disable=SC1090
source "${CFG}"

if [[ ! -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
  echo "[ERROR] ROS 2 ${ROS_DISTRO} no está instalado en /opt/ros/${ROS_DISTRO}."
  exit 2
fi

cp -f "${ROOT}/config/super_client_configuration_file.xml"       "${FASTRTPS_DEFAULT_PROFILES_FILE}"

# Los setup.bash de ROS/ament pueden leer variables aún no definidas.
# Desactivamos nounset solo durante el source y lo reactivamos después.
set +u
# shellcheck disable=SC1090
source "/opt/ros/${ROS_DISTRO}/setup.bash"
set -u

mkdir -p "${WORKSPACE}/src"

REPO_ITEM2="${ROOT}/ITEMS/item2/codigo"
rm -rf "${WORKSPACE}/src/arm_broker_interfaces"
cp -a "${REPO_ITEM2}/arm_broker_interfaces" "${WORKSPACE}/src/"

PACKAGES=(arm_broker_interfaces)

if [[ ${FULL} -eq 1 ]]; then
  rm -rf "${WORKSPACE}/src/arm_broker"
  cp -a "${REPO_ITEM2}/arm_broker" "${WORKSPACE}/src/"
  PACKAGES+=(arm_broker)
fi

cd "${WORKSPACE}"
colcon build --packages-select "${PACKAGES[@]}"

set +u
# shellcheck disable=SC1090
source "${WORKSPACE}/install/setup.bash"
set -u

export ROS_DOMAIN_ID ROS_LOCALHOST_ONLY RMW_IMPLEMENTATION ROS_DISCOVERY_SERVER
export FASTRTPS_DEFAULT_PROFILES_FILE

ros2 daemon stop >/dev/null 2>&1 || true
sleep 2
ros2 daemon start
sleep 3

echo
echo "=== INTERFAZ ==="
ros2 interface show arm_broker_interfaces/action/MoveArm

echo
echo "[OK] Raspberry preparada."
echo "En cada terminal nueva:"
echo "  cd ${ROOT} && source scripts/ros_env.sh"
echo
echo "Diagnóstico:"
echo "  cd ${ROOT} && bash scripts/check_client.sh"
