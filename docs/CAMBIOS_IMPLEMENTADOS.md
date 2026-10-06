# Cambios implementados — Grupo 7 · Sección S003

Este documento resume los cambios que realmente se realizaron durante el desarrollo del RB2. Se basa en el registro de comandos y modificaciones usado durante las pruebas.

## Estado final por archivo

### `fk.py`

Cambios realizados:

- implementación de la cinemática directa `fk(q)` con la tabla DH del JetCobot;
- límites articulares de las seis articulaciones;
- validación de cantidad/formato de articulaciones;
- `dentro_de_limites(q)`;
- `dentro_del_workspace(q)`, usando FK para rechazar posiciones inseguras;
- `paso_articular(q_actual, q_objetivo)`;
- restricciones del workspace.

El broker usa estas funciones para la admisión:

```python
ok, msg = fk.dentro_de_limites(q)
ok, msg = fk.dentro_del_workspace(q)
paso = fk.paso_articular(q_ref, q)
```

La verificación contra el robot físico produjo aproximadamente 5.4 mm de error, dentro del criterio de ≤ 10 mm.

### `politicas.py`

Durante el desarrollo se completó para soportar FIFO, prioridad y una variante conceptual con envejecimiento.

Sin embargo, la evidencia experimental final **no corresponde a aging**. Las corridas medidas fueron:

```text
FIFO
vs
Prioridad estática
```

Por eso el informe y el repositorio no deben atribuir las métricas medidas a `tau = 8 s`.

### `broker.py`

Fue el archivo con más cambios.

#### Admisión validada

El `goal_callback()` terminó evaluando:

```text
límites articulares
→ workspace mediante FK
→ paso articular máximo
→ aceptar / rechazar
```

Los rechazos registran motivo explícito y se mantienen contadores de aceptados, rechazados y completados.

#### Separación entre admisión y ejecución

`handle_accepted_callback()` pasó a **encolar**, no ejecutar inmediatamente.

El worker/despachador:

- extrae un único pedido;
- ejecuta el goal;
- espera a que termine;
- recién entonces despacha el siguiente.

Esto es la base de la exclusión mutua.

#### Cola con `heapq`

La cola final usa `heapq` y una clase `Pedido`.

Criterio observado:

- FIFO: menor tiempo de llegada/creación;
- prioridad: mayor valor de prioridad primero;
- empate: pedido más antiguo primero.

#### Política configurable

```bash
ros2 run arm_broker broker --ros-args -p politica:=fifo
ros2 run arm_broker broker --ros-args -p politica:=prioridad
```

Esas dos configuraciones generaron los bags válidos.

#### `/arm/queue_state` estructurado

El tópico pasó de `std_msgs/msg/String` a:

```text
arm_broker_interfaces/msg/QueueState
```

Incluye:

- `stamp`
- `executing_client`
- `executing_goal_id`
- `executing_elapsed_s`
- `queue_length`
- `queued_goal_ids`
- `queued_clients`
- `queued_priorities`
- `queued_wait_s`
- `total_accepted`
- `total_rejected`
- `total_completed`

#### Seguimiento del ejecutor

Se añadieron las variables de estado del cliente/goal actualmente en ejecución para que `/arm/queue_state` indique quién controla el brazo.

#### Conexión física al JetCobot

Se integró `pymycobot` con:

```python
MyCobot('/dev/ttyUSB0', 1000000)
```

y el movimiento convierte radianes a grados antes de llamar a `send_angles()`.

#### Movimiento final por goal

La interpolación que enviaba muchos `send_angles()` fue reemplazada por un único envío de la pose final al robot. El bucle posterior se mantuvo para feedback, tiempo transcurrido, cancelación y duración controlada.

## Verificaciones que quedaron demostradas

- FIFO: A → B → C incluso cuando C tenía mayor prioridad.
- Prioridad estática: A → C → B.
- `/arm/queue_state` publicado aproximadamente a 5 Hz.
- `/move_arm` visible con un único Action Server.
- movimiento físico real del JetCobot.
- FK verificada con error aproximado de 5.4 mm.
- 0 violaciones de exclusión mutua en los CSV finales.
- 4 aceptados, 0 rechazados y 4 completados en ambas corridas finales.

## Código final que debe recuperarse desde la Jetson

Antes de cerrar la entrega, las versiones que deben considerarse fuente definitiva son:

```text
/home/jetson/ros2_ws/src/kit_reto_alumno/src/arm_broker/arm_broker/broker.py
/home/jetson/ros2_ws/src/kit_reto_alumno/src/arm_broker/arm_broker/fk.py
/home/jetson/ros2_ws/src/kit_reto_alumno/src/arm_broker/arm_broker/politicas.py
```

Comprobaciones recomendadas:

```bash
grep -Rni "NotImplementedError" \
  ~/ros2_ws/src/kit_reto_alumno/src/arm_broker

grep -n "politicas" \
  ~/ros2_ws/src/kit_reto_alumno/src/arm_broker/arm_broker/broker.py
```

Las versiones originales del ZIP del curso no deben publicarse como si fueran la implementación final del grupo.
