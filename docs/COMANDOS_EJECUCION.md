# RB2 — Ejecución reproducible

## Raspberry nueva

Requisitos previos: Git y ROS 2 Humble instalados.

```bash
git clone https://github.com/anahicz/Reto2_Robotica.git
cd Reto2_Robotica && bash scripts/bootstrap_raspberry.sh
```

El script copia el XML FastDDS real, instala `arm_broker_interfaces` en `~/ros2_ws/src`, compila y reinicia el daemon.

Si el repositorio ya existe:

```bash
cd ~/Reto2_Robotica
bash scripts/sync_raspberry.sh
```

Para copiar además `arm_broker` al workspace:

```bash
bash scripts/bootstrap_raspberry.sh --full
```

## Cada terminal nueva

```bash
cd ~/Reto2_Robotica
source scripts/ros_env.sh
```

## Diagnóstico

```bash
bash scripts/check_client.sh
```

Antes de iniciar una prueba deben estar visibles:
- `arm_broker_interfaces/action/MoveArm`
- `/move_arm`
- `/arm/queue_state`
- `/joint_states`

## Configuración documentada

```text
ROS_DOMAIN_ID=112
ROS_LOCALHOST_ONLY=0
RMW_IMPLEMENTATION=rmw_fastrtps_cpp
ROS_DISCOVERY_SERVER=172.51.1.17:11811
FASTRTPS_DEFAULT_PROFILES_FILE=$HOME/super_client_configuration_file.xml
```

El XML está en `config/super_client_configuration_file.xml` y el bootstrap lo copia automáticamente.

## Ejecutar el broker

FIFO:

```bash
ros2 run arm_broker broker --ros-args -p politica:=fifo
```

Prioridad con envejecimiento:

```bash
ros2 run arm_broker broker --ros-args   -p politica:=prioridad   -p tau_envejecimiento_s:=8.0
```

El código recuperado confirma que `politica:=prioridad` instancia `SegundaPolitica` y utiliza `priority + espera_s/tau`.

## Enviar un goal

```bash
bash scripts/send_goal.sh CLIENTE PRIORIDAD q1 q2 q3 q4 q5 q6
```

## Grabar bags

```bash
bash scripts/record_bag.sh fifo
bash scripts/record_bag.sh prioridad
```

## Evidencia adicional

```bash
ros2 topic info /joint_states -v
ros2 action info /move_arm
ros2 topic hz /arm/queue_state
```

## Estructura de código

- Ítem 1: `ITEMS/item1/codigo`
- Ítem 2: `ITEMS/item2/codigo`
- Ítem 3: `ITEMS/item3/codigo`
- Ítem 4: `ITEMS/item4/codigo`
