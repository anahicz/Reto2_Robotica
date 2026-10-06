#!/usr/bin/env bash
set -euo pipefail

BASE_DIR="${1:-$HOME/evidencias_item3}"
FIFO_BAG="${BASE_DIR}/fifo/fifo_bag_ok"
PRIO_BAG="${BASE_DIR}/prioridad/prioridad_bag_ok"
FIFO_CSV="${BASE_DIR}/fifo/fifo_csv"
PRIO_CSV="${BASE_DIR}/prioridad/prioridad_csv"
FIGURE="${BASE_DIR}/comparacion_politicas.png"
RESULTS="${BASE_DIR}/metricas_resultados.txt"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck disable=SC1091
source "${SCRIPT_DIR}/ros_env.sh"

EXPORTER="${ANALYSIS_DIR}/exportar_csv.py"
METRICS="${ANALYSIS_DIR}/metricas.py"

for f in "${EXPORTER}" "${METRICS}"; do
  if [[ ! -f "${f}" ]]; then
    echo "[ERROR] No existe ${f}"
    echo "Ajusta ANALYSIS_DIR en config/network.env o ejecuta el análisis en la Jetson."
    exit 2
  fi
done

for bag in "${FIFO_BAG}" "${PRIO_BAG}"; do
  if [[ ! -d "${bag}" ]]; then
    echo "[ERROR] No existe el bag ${bag}"
    exit 3
  fi
done

mkdir -p "${FIFO_CSV}" "${PRIO_CSV}"

python3 "${EXPORTER}" "${FIFO_BAG}" --salida "${FIFO_CSV}"
python3 "${EXPORTER}" "${PRIO_BAG}" --salida "${PRIO_CSV}"

python3 "${METRICS}" \
  "${FIFO_CSV}/queue_state.csv" \
  "${PRIO_CSV}/queue_state.csv" \
  --salida "${FIGURE}" 2>&1 | tee "${RESULTS}"

echo "\nResultados: ${RESULTS}"
echo "Figura:     ${FIGURE}"
