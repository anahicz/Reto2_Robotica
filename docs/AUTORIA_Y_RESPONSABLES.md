# Autoría y responsables — Grupo 7 · Sección S003

## Criterio de atribución

Para mantener la atribución lo más transparente posible, se distingue entre:

1. **Andamiaje base del curso:** estructura, manifiestos, interfaces, cliente e instrumentación que fueron entregados por el curso.
2. **Implementación del equipo:** código escrito o completado por el Grupo 7 dentro de los bloques evaluados.
3. **Evidencia experimental:** ejecución, captura, medición y análisis realizados durante las pruebas.

La cabecera de cada archivo evaluado debe indicar explícitamente quién estuvo a cargo de ese nivel.

## Responsables por nivel evaluado

| Nivel / componente | Archivo o bloque | Encargado |
|---|---|---|
| Cinemática directa y validación geométrica | `arm_broker/fk.py` | **Sebastian Pedro Aguirre Acosta** |
| Políticas de planificación FIFO / prioridad | `arm_broker/politicas.py` | **Anahi Cortez Chinchay** |
| Admisión de metas | `broker.py — goal_callback / admisión` | **Ramirez Quevedo Karen Noelia** |
| Worker, ejecución y exclusión mutua | `broker.py — worker / execute_callback` | **Vara Vargas Valentino Uziel** |

## Evidencia del Ítem 3

La prueba de contención se realizó de forma grupal con un cliente por integrante:

| Equipo cliente | Integrante | Prioridad |
|---|---|---:|
| rpi-20 | Anahi Cortez Chinchay | 1 |
| rpi-11 | Ramirez Quevedo Karen Noelia | 2 |
| rpi-10 | Sebastian Pedro Aguirre Acosta | 10 |
| pi-uno | Vara Vargas Valentino Uziel | 5 |

La estación principal de captura fue **rpi-20 (Anahi)**.

## Cabeceras que deben quedar en el código final

### `fk.py`

```python
# =============================================================================
# UNIVERSIDAD ESAN · ROBÓTICA (08079)
# RETO DEL BRAZO 2 — Grupo 7 · Sección S003
#
# Nivel: Cinemática directa y validación geométrica
# Encargado: Sebastian Pedro Aguirre Acosta
#
# Base: andamiaje entregado por el curso.
# Aporte del equipo: implementación/completado del nivel evaluado.
# =============================================================================
```

### `politicas.py`

```python
# =============================================================================
# UNIVERSIDAD ESAN · ROBÓTICA (08079)
# RETO DEL BRAZO 2 — Grupo 7 · Sección S003
#
# Nivel: Políticas de planificación
# Encargada: Anahi Cortez Chinchay
#
# Base: andamiaje entregado por el curso.
# Aporte del equipo: implementación de FIFO y segunda política evaluada.
# =============================================================================
```

### `broker.py`

```python
# =============================================================================
# UNIVERSIDAD ESAN · ROBÓTICA (08079)
# RETO DEL BRAZO 2 — Grupo 7 · Sección S003
#
# Nivel: Admisión de metas
# Encargada: Ramirez Quevedo Karen Noelia
#
# Nivel: Worker, ejecución y exclusión mutua
# Encargado: Vara Vargas Valentino Uziel
#
# Base: andamiaje entregado por el curso.
# Aporte del equipo: implementación de los bloques evaluados del broker.
# =============================================================================
```

## Regla de transparencia

No se debe presentar como autoría del grupo lo que ya venía resuelto en el kit del curso. Las cabeceras identifican al **encargado del nivel evaluado**, que es la atribución más clara y verificable para la sustentación.
