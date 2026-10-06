# Reto 2 — El Turno del Brazo

Repositorio del RB-2 de Robótica: cinemática directa y acceso concurrente al JetCobot con ROS 2.

## Ejecución rápida en una Raspberry nueva

```bash
git clone https://github.com/anahicz/Reto2_Robotica.git
cd Reto2_Robotica
cp config/network.env.example config/network.env
nano config/network.env
```

Después de colocar `super_client_configuration_file.xml` en la ruta configurada:

```bash
bash scripts/setup_client.sh
source scripts/ros_env.sh
bash scripts/check_client.sh
```

Para mandar un goal:

```bash
bash scripts/send_goal.sh CLIENTE PRIORIDAD q1 q2 q3 q4 q5 q6
```

Para grabar las corridas del ítem 3:

```bash
bash scripts/record_bag.sh fifo
bash scripts/record_bag.sh prioridad
```

Para exportar CSV y generar la figura comparativa:

```bash
bash scripts/analyze_item3.sh
```

## Documentación

La guía completa de comandos depurados está en:

- [`docs/COMANDOS_EJECUCION.md`](docs/COMANDOS_EJECUCION.md)

Los scripts no esconden la configuración de red: todos leen `config/network.env`, que se crea a partir de `config/network.env.example`.

## Configuración usada en la corrida documentada

```text
ROS_DOMAIN_ID=112
ROS_LOCALHOST_ONLY=0
RMW_IMPLEMENTATION=rmw_fastrtps_cpp
ROS_DISCOVERY_SERVER=172.51.1.17:11811
```

Estos valores deben revisarse si cambia la Jetson, el número de equipo o la red del laboratorio.

## Evidencia del ítem 3

Las corridas válidas documentadas fueron `fifo_bag_ok` y `prioridad_bag_ok`. Las primeras capturas que contenían únicamente `/rosout` fueron descartadas. Antes de grabar, `scripts/record_bag.sh` comprueba que estén presentes `/arm/queue_state`, `/joint_states` y `/rosout`.

## Estado del repositorio

La automatización para preparar clientes ya está incluida. Para que una Raspberry quede completamente reproducible solo desde GitHub, todavía debe mantenerse versionado el paquete `src/arm_broker_interfaces` (y el resto del código fuente exigido por la entrega). Mientras tanto, `setup_client.sh --copy-from-jetson` reproduce el método de copia usado en el laboratorio.
