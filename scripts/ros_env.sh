#!/usr/bin/env bash
# Se debe ejecutar con: source scripts/ros_env.sh

_rb2_script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_rb2_root="$(cd "${_rb2_script_dir}/.." && pwd)"
_rb2_cfg="${RB2_NETWORK_CONFIG:-${_rb2_root}/config/network.env}"

if [[ ! -f "${_rb2_cfg}" ]]; then
  echo "[ERROR] Falta ${_rb2_cfg}" >&2
  echo "Crea el archivo con:" >&2
  echo "  cp ${_rb2_root}/config/network.env.example ${_rb2_root}/config/network.env" >&2
  return 2 2>/dev/null || exit 2
fi

# shellcheck disable=SC1090
source "${_rb2_cfg}"

if [[ ! -f "/opt/ros/${ROS_DISTRO}/setup.bash" ]]; then
  echo "[ERROR] No existe /opt/ros/${ROS_DISTRO}/setup.bash" >&2
  return 3 2>/dev/null || exit 3
fi

case "$-" in
  *u*) _rb2_had_nounset=1 ;;
  *)   _rb2_had_nounset=0 ;;
esac

set +u
# shellcheck disable=SC1090
source "/opt/ros/${ROS_DISTRO}/setup.bash"

if [[ -f "${WORKSPACE}/install/setup.bash" ]]; then
  # shellcheck disable=SC1090
  source "${WORKSPACE}/install/setup.bash"
fi

if [[ ${_rb2_had_nounset} -eq 1 ]]; then
  set -u
fi

export ROS_DOMAIN_ID ROS_LOCALHOST_ONLY RMW_IMPLEMENTATION ROS_DISCOVERY_SERVER
export FASTRTPS_DEFAULT_PROFILES_FILE

if [[ ! -f "${FASTRTPS_DEFAULT_PROFILES_FILE}" ]]; then
  echo "[AVISO] No existe FASTRTPS_DEFAULT_PROFILES_FILE=${FASTRTPS_DEFAULT_PROFILES_FILE}" >&2
fi

unset _rb2_script_dir _rb2_root _rb2_cfg _rb2_had_nounset
