# RB2 — Guía de ejecución y comandos depurados

Esta guía reorganiza los comandos usados durante el desarrollo de los ítems 2 y 3. El objetivo es que una Raspberry Pi nueva pueda integrarse a la prueba sin depender de variables exportadas, paquetes compilados o configuraciones guardadas de sesiones anteriores.

> **Importante:** aquí se conservan los comandos finales que sí forman parte del procedimiento. Los bloques de parcheo temporal de `broker.py`, los intentos fallidos y las repeticiones de depuración no deben volver a ejecutarse si el código fuente final ya contiene esos cambios.

## 1. Configuración validada en la corrida documentada

La corrida final documentada usó:

```bash
ROS_DOMAIN_ID=112
ROS_LOCALHOST_ONLY=0
RMW_IMPLEMENTATION=rmw_fastrtps_cpp
ROS_DISCOVERY_SERVER=172.51.1.17:11811
FASTRTPS_DEFAULT_PROFILES_FILE=$HOME/super_client_configuration_file.xml
```

La consigna general indica que el dominio debe ser el asignado al equipo (`42 + número de equipo`). Por eso los valores no están fijados dentro de los scripts: se editan en `config/network.env`.

## 2. Preparar una Raspberry Pi nueva

### 2.1 Clonar el repositorio

```bash
git clone https://github.com/anahicz/Reto2_Robotica.git
cd Reto2_Robotica
```

### 2.2 Crear la configuración local

```bash
cp config/network.env.example config/network.env
nano config/network.env
```

Revisar al menos:

```bash
ROS_DOMAIN_ID=...
ROS_DISCOVERY_SERVER=IP_JETSON:11811
FASTRTPS_DEFAULT_PROFILES_FILE="$HOME/super_client_configuration_file.xml"
```

El archivo `config/network.env` debe ser específico del laboratorio. No conviene versionar configuraciones accidentales de otra sesión.

### 2.3 Copiar el perfil FastDDS

El desarrollo utilizó `super_client_configuration_file.xml`. Antes de continuar, debe existir en la ruta indicada por `FASTRTPS_DEFAULT_PROFILES_FILE`.

Si el XML está disponible en otra máquina:

```bash
scp usuario@MAQUINA_ORIGEN:/ruta/super_client_configuration_file.xml \
  $HOME/super_client_configuration_file.xml
```

Comprobar que el XML no siga apuntando a `127.0.0.1` o a una IP antigua:

```bash
grep -n "address\|port" "$HOME/super_client_configuration_file.xml"
```

### 2.4 Instalar/compilar `arm_broker_interfaces`

La Raspberry cliente necesita conocer `arm_broker_interfaces/action/MoveArm` y `arm_broker_interfaces/msg/QueueState`.

Cuando el paquete esté dentro de este repositorio en `src/arm_broker_interfaces`, basta con:

```bash
bash scripts/setup_client.sh
```

Mientras el paquete todavía no esté versionado aquí, se puede copiar desde la Jetson usada en el laboratorio:

```bash
bash scripts/setup_client.sh --copy-from-jetson
```

Ese script reproduce el procedimiento que funcionó durante la depuración: crea `~/ros2_ws/src`, coloca `arm_broker_interfaces`, compila solo ese paquete, carga el workspace, reinicia el daemon y comprueba la interfaz y `/move_arm`.

## 3. Qué ejecutar en cada terminal nueva

Cada shell nueva parte limpia. No asumir que las variables siguen cargadas.

```bash
cd ~/Reto2_Robotica
source scripts/ros_env.sh
```

Verificar:

```bash
echo "$ROS_DOMAIN_ID"
echo "$ROS_DISCOVERY_SERVER"
echo "$FASTRTPS_DEFAULT_PROFILES_FILE"
```

## 4. Diagnóstico antes de mover el robot o grabar bags

Ejecutar:

```bash
bash scripts/check_client.sh
```

La prueba no debe comenzar hasta que se cumpla lo siguiente:

```text
arm_broker_interfaces/action/MoveArm existe
/move_arm tiene 1 Action Server
/arm/queue_state está visible
/joint_states está visible
```

Comandos manuales equivalentes:

```bash
ros2 daemon stop
sleep 2
ros2 daemon start
sleep 4

ros2 interface show arm_broker_interfaces/action/MoveArm
ros2 action list -t
ros2 action info /move_arm
ros2 topic list -t
ros2 topic echo /arm/queue_state --once
```

### Error conocido: Action Server = 0

Si aparece `Action servers: 0`, revisar, en este orden:

1. que la Jetson esté ejecutando `/arm_broker`;
2. que `ROS_DOMAIN_ID` sea el mismo en todos los equipos;
3. que `ROS_DISCOVERY_SERVER` tenga la IP actual de la Jetson;
4. que el XML FastDDS no apunte a loopback/IP antigua;
5. que `arm_broker_interfaces` esté compilado y el workspace esté sourced;
6. reiniciar el daemon después de corregir la configuración.

## 5. Comprobaciones en la Jetson

```bash
source /opt/ros/humble/setup.bash
source ~/ros2_ws/install/setup.bash

ros2 node list
ros2 topic list -t
ros2 action info /move_arm
```

La ejecución documentada mostró:

```text
/arm_broker
/arm/queue_state [arm_broker_interfaces/msg/QueueState]
/joint_states [sensor_msgs/msg/JointState]
```

### Puerto del JetCobot

```bash
ls -l /dev/ttyUSB* /dev/ttyACM* 2>/dev/null
```

El desarrollo utilizó `/dev/ttyUSB0` a `1000000 baud`.

### Verificación FK sin ordenar un movimiento nuevo

```bash
cd ~/ros2_ws/src/kit_reto_alumno/herramientas
python3 verificar_fk.py --solo-leer
```

En la prueba documentada se obtuvo un error de 5.4 mm, dentro del criterio de 10 mm.

## 6. Enviar un goal desde un cliente

```bash
bash scripts/send_goal.sh CLIENTE PRIORIDAD q1 q2 q3 q4 q5 q6
```

Ejemplo utilizado durante el desarrollo:

```bash
bash scripts/send_goal.sh Sebastian 10 0.0 -0.5 0.5 0.0 0.5 0.0
```

Distribución usada en la corrida final:

| Raspberry | Cliente | Prioridad |
|---|---|---:|
| rpi-20 | Anahi | 1 |
| rpi-11 | Karen | 2 |
| rpi-10 | Sebastian | 10 |
| pi-uno | Valentino | 5 |

## 7. Grabar la corrida FIFO

```bash
bash scripts/check_client.sh
bash scripts/record_bag.sh fifo
```

El script exige que estén visibles `/arm/queue_state`, `/joint_states` y `/rosout`. Esto evita repetir el error de las primeras capturas, donde el bag contenía únicamente `/rosout`.

La corrida FIFO válida del desarrollo fue:

```text
fifo_bag_ok
Duración: 40.056 s
Mensajes: 622
/joint_states: 396
/arm/queue_state: 198
/rosout: 28
```

## 8. Grabar la corrida de prioridad

```bash
bash scripts/check_client.sh
bash scripts/record_bag.sh prioridad
```

La corrida válida documentada fue:

```text
prioridad_bag_ok
Duración: 24.420 s
Mensajes: 384
/joint_states: 237
/arm/queue_state: 119
/rosout: 28
```

> Las corridas medidas en el informe comparan **FIFO frente a prioridad estática**. El diseño con aging (`τ = 8 s`) fue planteado, pero no corresponde atribuirle las métricas de estas corridas.

## 9. Exportar CSV y generar la comparación

```bash
bash scripts/analyze_item3.sh
```

Resultados documentados:

```text
FIFO:      espera media 2.37 s, P95 3.00 s
Prioridad: espera media 3.60 s, P95 5.19 s
Jain:      1.000 en ambas
```

## 10. Comandos que NO deben repetirse mañana

Durante el desarrollo se ejecutaron bloques Python que modificaban `broker.py` para:

- convertir `/arm/queue_state` desde `std_msgs/String` a `QueueState`;
- registrar `executing_client`, `executing_goal_id` y tiempos;
- conectar `mover()` con `pymycobot`;
- cambiar la ejecución física a un solo `send_angles()` por goal.

Esos bloques eran **parches de desarrollo**. Si el repositorio contiene la versión final del broker, volver a ejecutarlos puede duplicar código o dejar el archivo en un estado incorrecto.

Tampoco es necesario hacer siempre:

```bash
rm -rf build install log
```

Para una Raspberry cliente basta normalmente con:

```bash
colcon build --packages-select arm_broker_interfaces
```

## 11. Checklist de mañana

1. Clonar/actualizar el repositorio.
2. Crear y revisar `config/network.env`.
3. Colocar `super_client_configuration_file.xml` correcto.
4. Compilar `arm_broker_interfaces` en cada Raspberry nueva.
5. `source scripts/ros_env.sh` en cada terminal.
6. Ejecutar `bash scripts/check_client.sh` y exigir 1 Action Server.
7. Confirmar `/arm/queue_state` y `/joint_states` antes de iniciar rosbag.
8. Grabar FIFO y prioridad por separado.
9. Ejecutar `ros2 bag info` y comprobar que ambos tópicos tengan mensajes.
10. Exportar CSV, ejecutar métricas y guardar `metricas_resultados.txt` + `comparacion_politicas.png`.

## 12. Comandos confirmados del desarrollo real

### Corregir FastDDS si el XML todavía apunta a localhost

```bash
cp /home/alumno01/super_client_configuration_file.xml \
   /home/alumno01/super_client_configuration_file.xml.bak

sed -i 's/127\.0\.0\.1/172.51.1.17/g' \
  /home/alumno01/super_client_configuration_file.xml

grep -n "address\|port" ~/super_client_configuration_file.xml
ping -c 3 172.51.1.17
```

### Ejecutar el broker con la política correcta

FIFO:

```bash
ros2 run arm_broker broker --ros-args -p politica:=fifo
```

Prioridad estática:

```bash
ros2 run arm_broker broker --ros-args -p politica:=prioridad
```

### Verificar QueueState

```bash
ros2 topic type /arm/queue_state
ros2 topic echo /arm/queue_state --once
ros2 topic hz /arm/queue_state
```

El tipo final esperado es:

```text
arm_broker_interfaces/msg/QueueState
```

y la frecuencia observada durante el desarrollo fue cercana a 5 Hz.

### Verificar publicadores de joint_states

```bash
ros2 topic info /joint_states -v
```

Conservar esta salida como evidencia del publicador/controlador efectivo.

### Recuperar el código final desde la Jetson

Antes de cerrar GitHub, copiar **las versiones reales usadas en las pruebas**, no las originales del ZIP:

```bash
mkdir -p ~/Reto2_Robotica/src

cp -r ~/ros2_ws/src/kit_reto_alumno/src/arm_broker \
      ~/Reto2_Robotica/src/

cp -r ~/ros2_ws/src/kit_reto_alumno/src/arm_broker_interfaces \
      ~/Reto2_Robotica/src/
```

Y verificar:

```bash
grep -Rni "NotImplementedError" \
  ~/Reto2_Robotica/src/arm_broker

grep -n "politicas" \
  ~/Reto2_Robotica/src/arm_broker/arm_broker/broker.py
```

## 13. Qué representa realmente cada política medida

Las corridas finales registradas con `fifo_bag_ok` y `prioridad_bag_ok` corresponden a:

```text
FIFO vs prioridad estática
```

Aunque durante el desarrollo se trabajó una idea de prioridad con envejecimiento y `tau = 8.0 s`, **esas métricas no se deben presentar como mediciones de aging**.
