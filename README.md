# Reto 2 — El Turno del Brazo

Repositorio del RB-2 de Robótica (ESAN, Grupo 7 · Sección S003).

## Estructura

```text
ITEMS/
├── item1/   # Cinemática directa y verificación FK
├── item2/   # arm_broker, interfaces y evidencias de admisión
├── item3/   # Medición bajo contención, análisis y evidencia
└── item4/   # Auditoría de la IK del firmware

config/      # FastDDS y variables de red
scripts/     # Preparación, diagnóstico y ejecución
docs/        # Autoría, cambios y comandos
informe/     # Informe técnico
```

Responsables oficiales:
- Ítem 1 — Vara Vargas Valentino Uziel
- Ítem 2 — Ramirez Quevedo Karen Noelia
- Ítem 3 — Anahi Cortez Chinchay
- Ítem 4 — Sebastian Pedro Aguirre Acosta

La atribución completa está en `docs/AUTORIA_Y_RESPONSABLES.md`.

## Raspberry nueva: instalación corta

Requisitos previos: Ubuntu/ROS 2 Humble y Git.

```bash
git clone https://github.com/anahicz/Reto2_Robotica.git
cd Reto2_Robotica && bash scripts/bootstrap_raspberry.sh
```

Como el repositorio es privado, el primer `clone` puede pedir autenticación de GitHub. No guardes tokens en una máquina compartida.

El bootstrap:
1. crea `config/network.env` si no existe;
2. copia el XML FastDDS real a `$HOME/super_client_configuration_file.xml`;
3. instala `arm_broker_interfaces` en `~/ros2_ws/src`;
4. compila la interfaz;
5. reinicia el daemon;
6. verifica que `MoveArm` esté disponible.

Si el repo ya existe:

```bash
cd ~/Reto2_Robotica
bash scripts/sync_raspberry.sh
```

Cada terminal nueva:

```bash
cd ~/Reto2_Robotica
source scripts/ros_env.sh
```

Diagnóstico:

```bash
bash scripts/check_client.sh
```

## Configuración validada

```text
ROS_DOMAIN_ID=112
ROS_LOCALHOST_ONLY=0
RMW_IMPLEMENTATION=rmw_fastrtps_cpp
ROS_DISCOVERY_SERVER=172.51.1.17:11811
```

El XML usado en laboratorio está en `config/super_client_configuration_file.xml`.

## Política de prioridad

El código recuperado del workspace compilado usa:

```text
prioridad efectiva = prioridad + espera_s / tau
tau = 8.0 s
```

Por tanto, `politica:=prioridad` corresponde a **prioridad con envejecimiento (aging)**. En la muestra observada el orden coincidió con prioridad numérica descendente porque las esperas fueron cortas respecto a `tau`.

## Estado

Versionado:
- código final de `arm_broker` e interfaces;
- código de Ítems 1 y 4;
- XML FastDDS;
- rechazos del Ítem 2;
- bags, CSV, métricas, figura y exclusión mutua del Ítem 3.

Pendientes externos:
- video de 3 minutos: subir a `ITEMS/item3/evidencia/video/`;
- repetir con la traza CSV oficial solo si la rúbrica la exige y está disponible.
