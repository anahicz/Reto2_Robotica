# Ítem 3 — Medición bajo contención

**Encargada oficial:** Anahi Cortez Chinchay.

La prueba experimental utilizó cuatro clientes distribuidos; esto no cambia la responsabilidad oficial del ítem.

## Código

`codigo/analisis` contiene:
- `predecir_p95.py`
- `verificar_exclusion.py`

El broker medido es el del Ítem 2.

## Evidencia validada

Está en `evidencia/`:
- bags FIFO y prioridad;
- CSV de `/arm/queue_state` y `/joint_states`;
- `metricas_resultados.txt`;
- `comparacion_politicas.png`;
- `verificacion_exclusion_resultados.txt`;
- manifiesto SHA-256.

Resultados:
- FIFO: espera media 2.37 s, P95 3.00 s.
- Prioridad con aging: espera media 3.60 s, P95 5.19 s.
- 4 goals aceptados, 0 rechazados y 4 completados en ambas corridas.
- 0 violaciones de exclusión mutua en ambas corridas.
- Jain = 1.000 en ambas.

### Nota sobre la prioridad

El código recuperado demuestra que `politica:=prioridad` usa envejecimiento con `tau=8.0 s`. El orden observado fue Sebastian (10) → Valentino (5) → Karen (2) → Anahi (1). Como las esperas fueron cortas respecto a `tau`, el aging no llegó a invertir ese orden, pero formaba parte de la política activa.

### Alcance

Las corridas documentadas se dispararon con goals preparados manualmente. Si la rúbrica exige literalmente la traza CSV oficial, esa repetición sigue siendo una mejora pendiente.
