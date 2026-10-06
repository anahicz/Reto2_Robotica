#!/usr/bin/env bash

# ==============================================================================
# UNIVERSIDAD ESAN - ROBÓTICA
# RETO 2 - EL TURNO DEL BRAZO
# Grupo 7 - Sección S003
#
# setup_raspberry.sh
#
# Prepara una Raspberry Pi nueva para trabajar con el sistema ROS 2 del reto:
#   - comprueba ROS 2 Humble
#   - crea la configuración de red
#   - instala el XML FastDDS SUPER_CLIENT
#   - copia arm_broker_interfaces
#   - copia arm_broker
#   - compila ambos paquetes
#   - carga el entorno ROS 2
#   - configura DDS / Discovery Server
#   - reinicia el daemon
#   - verifica interfaces, action server y tópicos
#
# Uso:
#
#   cd ~/Reto2_Robotica
#   bash scripts/setup_raspberry.sh
#
# ==============================================================================

set -eo pipefail


# ==============================================================================
# 1. RUTAS DEL PROYECTO
# ==============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

WORKSPACE="${HOME}/ros2_ws"
WS_SRC="${WORKSPACE}/src"

ITEM2="${ROOT}/ITEMS/item2/codigo"

REPO_BROKER="${ITEM2}/arm_broker"
REPO_INTERFACES="${ITEM2}/arm_broker_interfaces"

WS_BROKER="${WS_SRC}/arm_broker"
WS_INTERFACES="${WS_SRC}/arm_broker_interfaces"

NETWORK_CONFIG="${ROOT}/config/network.env"
NETWORK_EXAMPLE="${ROOT}/config/network.env.example"

XML_REPO="${ROOT}/config/super_client_configuration_file.xml"
XML_DEST="${HOME}/super_client_configuration_file.xml"


# ==============================================================================
# 2. CONFIGURACIÓN ROS 2 / RED
# ==============================================================================

ROS_DISTRO="humble"

# Configuración usada en las pruebas del Grupo 7
ROS_DOMAIN_ID_DEFAULT="112"
DISCOVERY_SERVER_DEFAULT="172.51.1.17:11811"


echo
echo "============================================================"
echo "   RB2 - CONFIGURACIÓN AUTOMÁTICA DE RASPBERRY PI"
echo "============================================================"
echo

echo "[INFO] Repositorio:"
echo "       ${ROOT}"
echo

echo "[INFO] Workspace ROS:"
echo "       ${WORKSPACE}"
echo


# ==============================================================================
# 3. COMPROBAR ROS 2
# ==============================================================================

echo "------------------------------------------------------------"
echo "[1/9] Comprobando ROS 2 ${ROS_DISTRO}"
echo "------------------------------------------------------------"

ROS_SETUP="/opt/ros/${ROS_DISTRO}/setup.bash"

if [[ ! -f "${ROS_SETUP}" ]]; then
    echo
    echo "[ERROR] No se encontró:"
    echo "        ${ROS_SETUP}"
    echo
    echo "Esta Raspberry no tiene ROS 2 ${ROS_DISTRO} correctamente instalado."
    exit 1
fi

echo "[OK] ROS 2 ${ROS_DISTRO} encontrado."


# ==============================================================================
# 4. COMPROBAR ARCHIVOS DEL REPOSITORIO
# ==============================================================================

echo
echo "------------------------------------------------------------"
echo "[2/9] Comprobando archivos del proyecto"
echo "------------------------------------------------------------"

if [[ ! -d "${REPO_INTERFACES}" ]]; then
    echo "[ERROR] No existe:"
    echo "        ${REPO_INTERFACES}"
    exit 2
fi

if [[ ! -d "${REPO_BROKER}" ]]; then
    echo "[ERROR] No existe:"
    echo "        ${REPO_BROKER}"
    exit 2
fi

if [[ ! -f "${XML_REPO}" ]]; then
    echo "[ERROR] No existe:"
    echo "        ${XML_REPO}"
    exit 2
fi

echo "[OK] arm_broker encontrado."
echo "[OK] arm_broker_interfaces encontrado."
echo "[OK] XML FastDDS encontrado."


# ==============================================================================
# 5. CREAR CONFIGURACIÓN DE RED
# ==============================================================================

echo
echo "------------------------------------------------------------"
echo "[3/9] Configurando ROS 2 y FastDDS"
echo "------------------------------------------------------------"

if [[ ! -f "${NETWORK_CONFIG}" ]]; then

    if [[ -f "${NETWORK_EXAMPLE}" ]]; then
        cp "${NETWORK_EXAMPLE}" "${NETWORK_CONFIG}"
        echo "[OK] Creado:"
        echo "     ${NETWORK_CONFIG}"

    else
        cat > "${NETWORK_CONFIG}" <<EOF
ROS_DISTRO=${ROS_DISTRO}
WORKSPACE="\$HOME/ros2_ws"

ROS_DOMAIN_ID=${ROS_DOMAIN_ID_DEFAULT}
ROS_LOCALHOST_ONLY=0
RMW_IMPLEMENTATION=rmw_fastrtps_cpp
ROS_DISCOVERY_SERVER=${DISCOVERY_SERVER_DEFAULT}
FASTRTPS_DEFAULT_PROFILES_FILE="\$HOME/super_client_configuration_file.xml"
EOF

        echo "[OK] network.env creado automáticamente."
    fi

else
    echo "[OK] Ya existe config/network.env."
fi


# Cargar configuración
# Deshabilitamos temporalmente nounset por compatibilidad.
set +u
source "${NETWORK_CONFIG}"
set -u


# ==============================================================================
# 6. COPIAR XML FASTDDS
# ==============================================================================

echo
echo "------------------------------------------------------------"
echo "[4/9] Instalando configuración FastDDS"
echo "------------------------------------------------------------"

cp -f "${XML_REPO}" "${XML_DEST}"

echo "[OK] XML instalado en:"
echo "     ${XML_DEST}"


# Verificar IP del Discovery Server dentro del XML

echo
echo "[INFO] Discovery Server configurado en el XML:"

grep -n "address\|port" "${XML_DEST}" || true


# ==============================================================================
# 7. PREPARAR WORKSPACE
# ==============================================================================

echo
echo "------------------------------------------------------------"
echo "[5/9] Preparando workspace ROS 2"
echo "------------------------------------------------------------"

mkdir -p "${WS_SRC}"

echo "[OK] Workspace:"
echo "     ${WORKSPACE}"


# ==============================================================================
# 8. COPIAR PAQUETES
# ==============================================================================

echo
echo "------------------------------------------------------------"
echo "[6/9] Instalando paquetes del reto"
echo "------------------------------------------------------------"

echo "[INFO] Copiando arm_broker_interfaces..."

rm -rf "${WS_INTERFACES}"
cp -a "${REPO_INTERFACES}" "${WS_SRC}/"

echo "[OK] arm_broker_interfaces instalado."


echo
echo "[INFO] Copiando arm_broker..."

rm -rf "${WS_BROKER}"
cp -a "${REPO_BROKER}" "${WS_SRC}/"

echo "[OK] arm_broker instalado."


# ==============================================================================
# 9. CARGAR ROS SIN ERROR DE AMENT_TRACE_SETUP_FILES
# ==============================================================================

echo
echo "------------------------------------------------------------"
echo "[7/9] Compilando paquetes"
echo "------------------------------------------------------------"

# Algunos scripts internos de ROS/ament utilizan variables no inicializadas.
# Por eso nounset se deshabilita durante los source.

set +u

source "/opt/ros/${ROS_DISTRO}/setup.bash"

set -u


cd "${WORKSPACE}"


# ==============================================================================
# 10. COMPILAR
# ==============================================================================

colcon build \
    --packages-select \
    arm_broker_interfaces \
    arm_broker


BUILD_RESULT=$?

if [[ ${BUILD_RESULT} -ne 0 ]]; then
    echo
    echo "[ERROR] colcon build falló."
    exit 3
fi


echo
echo "[OK] Compilación terminada."


# ==============================================================================
# 11. CARGAR WORKSPACE
# ==============================================================================

set +u

source "${WORKSPACE}/install/setup.bash"

set -u


# ==============================================================================
# 12. EXPORTAR VARIABLES ROS 2
# ==============================================================================

echo
echo "------------------------------------------------------------"
echo "[8/9] Configurando entorno ROS 2"
echo "------------------------------------------------------------"

export ROS_DOMAIN_ID
export ROS_LOCALHOST_ONLY
export RMW_IMPLEMENTATION
export ROS_DISCOVERY_SERVER
export FASTRTPS_DEFAULT_PROFILES_FILE


echo "ROS_DOMAIN_ID=${ROS_DOMAIN_ID}"
echo "ROS_LOCALHOST_ONLY=${ROS_LOCALHOST_ONLY}"
echo "RMW_IMPLEMENTATION=${RMW_IMPLEMENTATION}"
echo "ROS_DISCOVERY_SERVER=${ROS_DISCOVERY_SERVER}"
echo "FASTRTPS_DEFAULT_PROFILES_FILE=${FASTRTPS_DEFAULT_PROFILES_FILE}"


# ==============================================================================
# 13. REINICIAR DAEMON ROS 2
# ==============================================================================

echo
echo "[INFO] Reiniciando ROS 2 daemon..."

ros2 daemon stop >/dev/null 2>&1 || true

sleep 2

ros2 daemon start >/dev/null 2>&1 || true

sleep 4

echo "[OK] ROS 2 daemon reiniciado."


# ==============================================================================
# 14. VERIFICAR INTERFACES
# ==============================================================================

echo
echo "------------------------------------------------------------"
echo "[9/9] Verificando instalación"
echo "------------------------------------------------------------"


echo
echo "=== MoveArm.action ==="

if ros2 interface show arm_broker_interfaces/action/MoveArm; then
    echo
    echo "[OK] MoveArm.action disponible."
else
    echo
    echo "[ERROR] No se pudo cargar MoveArm.action."
    exit 4
fi


echo
echo "=== QueueState.msg ==="

if ros2 interface show arm_broker_interfaces/msg/QueueState; then
    echo
    echo "[OK] QueueState.msg disponible."
else
    echo
    echo "[ERROR] No se pudo cargar QueueState.msg."
    exit 4
fi


# ==============================================================================
# 15. COMPROBAR EJECUTABLES
# ==============================================================================

echo
echo "=== Ejecutables arm_broker ==="

ros2 pkg executables arm_broker || true


# ==============================================================================
# 16. VERIFICAR DISCOVERY
# ==============================================================================

echo
echo "=== Buscando Action Server /move_arm ==="

ACTION_INFO="$(ros2 action info /move_arm 2>/dev/null || true)"

echo "${ACTION_INFO}"


if echo "${ACTION_INFO}" | grep -q "Action servers: 1"; then

    echo
    echo "[OK] Broker /move_arm descubierto."

else

    echo
    echo "[AVISO] No se encontró un Action Server activo en /move_arm."
    echo
    echo "Esto NO significa que la Raspberry esté mal configurada."
    echo "Puede significar simplemente que el broker todavía no está"
    echo "ejecutándose en la máquina servidor."

fi


# ==============================================================================
# 17. VERIFICAR TOPICS
# ==============================================================================

echo
echo "=== Tópicos ROS 2 visibles ==="

ros2 topic list || true


if ros2 topic list 2>/dev/null | grep -qx "/arm/queue_state"; then
    echo "[OK] /arm/queue_state descubierto."
else
    echo "[AVISO] /arm/queue_state todavía no está visible."
fi


if ros2 topic list 2>/dev/null | grep -qx "/joint_states"; then
    echo "[OK] /joint_states descubierto."
else
    echo "[AVISO] /joint_states todavía no está visible."
fi


# ==============================================================================
# 18. RESULTADO FINAL
# ==============================================================================

echo
echo
echo "============================================================"
echo "             CONFIGURACIÓN TERMINADA"
echo "============================================================"
echo

echo "[OK] ROS 2 ${ROS_DISTRO}"
echo "[OK] arm_broker_interfaces"
echo "[OK] arm_broker"
echo "[OK] FastDDS SUPER_CLIENT"
echo "[OK] Discovery Server: ${ROS_DISCOVERY_SERVER}"
echo "[OK] ROS_DOMAIN_ID: ${ROS_DOMAIN_ID}"

echo
echo "La Raspberry está preparada para los Ítems 2 y 3."

echo
echo "------------------------------------------------------------"
echo "EN CADA TERMINAL NUEVA EJECUTA:"
echo "------------------------------------------------------------"
echo

echo "cd ${ROOT}"
echo "source scripts/ros_env.sh"

echo
echo "------------------------------------------------------------"
echo "PARA COMPROBAR CONEXIÓN:"
echo "------------------------------------------------------------"
echo

echo "bash scripts/check_client.sh"

echo
echo "------------------------------------------------------------"
echo "PARA EJECUTAR UN CLIENTE:"
echo "------------------------------------------------------------"
echo

echo "ros2 run arm_broker cliente --ros-args \\"
echo "  -p client_id:=Anahi \\"
echo "  -p priority:=1"

echo
echo "============================================================"
