# Evidencia — Ítem 3

Este directorio resume la evidencia validada contenida en `ITEM3.zip`.

## Contenido del archivo entregado

El ZIP contiene:

- `fifo_bag_ok/`
  - `fifo_bag_ok_0.db3`
  - `metadata.yaml`
- `fifo_csv/`
  - `queue_state.csv`
  - `joint_states.csv`
- `prioridad_bag_ok/`
  - `prioridad_bag_ok_0.db3`
  - `metadata.yaml`
- `prioridad_csv/`
  - `queue_state.csv`
  - `joint_states.csv`
- `comparacion_politicas.png`
- `metricas_resultados.txt`

## Validación de las corridas

| Métrica | FIFO | Prioridad estática |
|---|---:|---:|
| Duración del bag | 40.056 s | 24.420 s |
| Mensajes totales | 622 | 384 |
| /joint_states | 396 | 237 |
| /arm/queue_state | 198 | 119 |
| /rosout | 28 | 28 |
| Frecuencia observada /arm/queue_state | 4.94 Hz | 4.87 Hz |
| Goals aceptados | 4 | 4 |
| Goals rechazados | **0** | **0** |
| Goals completados | 4 | 4 |
| Espera media | 2.37 s | 3.60 s |
| P95 de espera | 3.00 s | 5.19 s |
| Espera máxima / índice de inanición | 3.00 s | 5.19 s |
| Equidad de Jain | 1.000 | 1.000 |
| Máximo de elementos observados en cola | 2 | 3 |

## Orden de ejecución observado

A partir de `executing_client` en `queue_state.csv`:

**FIFO**

```text
Valentino -> Sebastian -> Anahi -> Karen
```

**Prioridad estática**

```text
Sebastian (10) -> Valentino (5) -> Karen (2) -> Anahi (1)
```

La segunda corrida evidencia el reordenamiento esperado por prioridad numérica descendente.

## Observación sobre metricas.py

`metricas.py` reporta 3 pedidos observados en cola aunque el contador final registra 4 completados. Esto es coherente con una telemetría periódica cercana a 5 Hz: la primera meta puede pasar directamente a ejecución entre dos muestras y no quedar observada como `queued`.

Los cuatro clientes sí aparecen como `executing_client` en ambas corridas y el contador final de cada bag es:

```text
total_accepted = 4
total_rejected = 0
total_completed = 4
```

## Qué queda fuera de este ZIP

Este archivo no contiene una salida independiente de `verificar_exclusion.py` ni una salida fechada de `predecir_p95.py`. Por tanto, esas evidencias no deben declararse como adjuntadas solo a partir de este ZIP.

Los SHA-256 del ZIP y de sus archivos están en `manifest_sha256.txt`.
