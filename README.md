# Reto 2 — El Turno del Brazo

Repositorio del RB-2 de Robótica: cinemática directa y acceso concurrente al JetCobot con ROS 2.

## Autoría y responsables — Grupo 7 · Sección S003

El repositorio distingue explícitamente entre el **andamiaje base entregado por el curso** y los bloques implementados por el equipo.

Responsables oficiales por ítem:

- **Ítem 1 — Encargado:** Vara Vargas Valentino Uziel (Valentino)
- **Ítem 2 — Encargada:** Ramirez Quevedo Karen Noelia (Karen)
- **Ítem 3 — Encargada:** Anahi Cortez Chinchay (Anahi)
- **Ítem 4 — Encargado:** Sebastian Pedro Aguirre Acosta (Sebastián)

La matriz completa de atribución y las cabeceras que deben conservarse en el código final están en [`docs/AUTORIA_Y_RESPONSABLES.md`](docs/AUTORIA_Y_RESPONSABLES.md).

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

La evidencia validada extraída de `ITEM3.zip` está documentada en:

- [`evidencia/item3/README.md`](evidencia/item3/README.md)
- [`evidencia/item3/metricas_resultados.txt`](evidencia/item3/metricas_resultados.txt)
- [`evidencia/item3/resumen_validacion.csv`](evidencia/item3/resumen_validacion.csv)
- [`evidencia/item3/manifest_sha256.txt`](evidencia/item3/manifest_sha256.txt)

Las corridas válidas fueron `fifo_bag_ok` y `prioridad_bag_ok`. Las primeras capturas que contenían únicamente `/rosout` fueron descartadas. Antes de grabar, `scripts/record_bag.sh` comprueba que estén presentes `/arm/queue_state`, `/joint_states` y `/rosout`.

Los resultados validados muestran 4 goals aceptados, **0 rechazados y 4 completados** en ambas políticas. FIFO obtuvo 2.37 s de espera media y P95 de 3.00 s; prioridad estática obtuvo 3.60 s y P95 de 5.19 s.

## Estado del repositorio

La automatización para preparar clientes ya está incluida. Para que una Raspberry quede completamente reproducible solo desde GitHub, todavía debe mantenerse versionado el paquete `src/arm_broker_interfaces` (y el resto del código fuente exigido por la entrega). Mientras tanto, `setup_client.sh --copy-from-jetson` reproduce el método de copia usado en el laboratorio.
