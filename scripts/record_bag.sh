#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
  echo "Uso: bash scripts/record_bag.sh fifo|prioridad [directorio_base]"
  exit 2
fi

POLICY="$1"
BASE_DIR="${2:-$HOME/evidencias_item3}"
case "${POLICY}" in
  fifo) BAG_NAME="fifo_bag_ok" ;;
  prioridad) BAG_NAME="prioridad_bag_ok" ;;
  *) echo "[ERROR] Política válida: fifo o prioridad"; exit 3 ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/ros_env.sh"

TOPICS=(/arm/queue_state /joint_states /rosout)
AVAILABLE="$(ros2 topic list)"
for topic in "${TOPICS[@]}"; do
  if ! grep -qx "${topic}" <<<"${AVAILABLE}"; then
    echo "[ERROR] Falta ${topic}. No se iniciará rosbag para evitar una captura inválida."
    exit 4
  fi
done

OUT_DIR="${BASE_DIR}/${POLICY}"
OUT_PATH="${OUT_DIR}/${BAG_NAME}"
mkdir -p "${OUT_DIR}"

if [[ -e "${OUT_PATH}" ]]; then
  echo "[ERROR] Ya existe ${OUT_PATH}. Renómbralo o elimínalo conscientemente antes de repetir."
  exit 5
fi

echo "[OK] Se descubren los 3 tópicos requeridos."
echo "Grabando ${POLICY}. Termina la corrida con Ctrl+C."
ros2 bag record /arm/queue_state /joint_states /rosout -o "${OUT_PATH}"

echo "\n=== ROSBAG INFO ==="
ros2 bag info "${OUT_PATH}"
