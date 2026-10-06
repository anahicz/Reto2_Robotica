# Evidencia — Ítem 3

## Integridad

La evidencia proviene de las corridas válidas `fifo_bag_ok` y `prioridad_bag_ok`.

| Métrica | FIFO | Prioridad con aging |
|---|---:|---:|
| Duración del bag | 40.056 s | 24.420 s |
| Mensajes totales | 622 | 384 |
| /joint_states | 396 | 237 |
| /arm/queue_state | 198 | 119 |
| /rosout | 28 | 28 |
| Goals aceptados | 4 | 4 |
| Goals rechazados | **0** | **0** |
| Goals completados | 4 | 4 |
| Espera media | 2.37 s | 3.60 s |
| P95 | 3.00 s | 5.19 s |
| Espera máxima | 3.00 s | 5.19 s |
| Jain | 1.000 | 1.000 |
| Violaciones de exclusión | **0** | **0** |

## Orden observado

FIFO:

```text
Valentino -> Sebastian -> Anahi -> Karen
```

Prioridad:

```text
Sebastian (10) -> Valentino (5) -> Karen (2) -> Anahi (1)
```

El código recuperado usa aging con `tau=8.0 s`. En esta muestra, las esperas fueron insuficientes para que el término de envejecimiento cambiara el orden determinado por las prioridades iniciales.

## Muestreo

`metricas.py` observa 3 pedidos en cola aunque el contador final registra 4 completados. La primera meta puede pasar a ejecución entre muestras de `/arm/queue_state` (~5 Hz).

## Exclusión mutua

`verificacion_exclusion_resultados.txt` registra 0 violaciones en ambas corridas.

## Predicción P95

`predecir_p95.py` está en `../codigo/analisis`. Si se ejecuta después de las mediciones debe describirse como simulación retrospectiva, no como evidencia de una predicción realizada previamente.

Los hashes de los archivos originales están en `manifest_sha256.txt`.
