# Cambios implementados — Grupo 7 · Sección S003

## Fuente definitiva

Los paquetes finales fueron recuperados de:

```text
/home/alumno01/ros2_ws/src/arm_broker
/home/alumno01/ros2_ws/src/arm_broker_interfaces
```

Se verificó que `src`, `build` e `install` tuvieran el mismo SHA-256 para `broker.py`, `fk.py`, `politicas.py` y `cliente.py`.

## fk.py

Incluye:
- tabla DH;
- límites articulares;
- FK;
- validación de workspace;
- cálculo del paso articular.

## broker.py

Incluye:
- admisión por límites, workspace y paso máximo;
- cola de pedidos;
- worker único;
- exclusión mutua;
- `QueueState` estructurado;
- contadores de aceptados, rechazados y completados;
- publicación de `/joint_states`.

## politicas.py

La política `fifo` selecciona el pedido de menor `t_llegada`.

La política `prioridad` es **prioridad con envejecimiento**:

```text
puntaje = prioridad + espera_s / tau
tau = 8.0 s
```

El broker importa `POLITICAS` y, para `politica:=prioridad`, construye `SegundaPolitica` con el parámetro `tau_envejecimiento_s`.

El historial del laboratorio contiene ejecuciones explícitas con:

```bash
ros2 run arm_broker broker --ros-args   -p politica:=prioridad   -p tau_envejecimiento_s:=8.0
```

Por tanto, la documentación anterior que llamaba a la corrida “prioridad estática” debe interpretarse como una descripción del **orden observado**, no de la implementación activa.

## interfaces

`MoveArm.action` y `QueueState.msg` están versionados junto al broker en el Ítem 2.

## Evidencia

Ítem 2:
- tres rechazos con motivo legible.

Ítem 3:
- bags válidos FIFO/prioridad;
- CSV;
- métricas;
- figura;
- 0 violaciones de exclusión mutua;
- 4 aceptados, 0 rechazados y 4 completados en ambas corridas.
