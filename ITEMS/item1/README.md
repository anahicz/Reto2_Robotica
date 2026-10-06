# Ítem 1 — Cinemática directa verificada

**Encargado oficial:** Vara Vargas Valentino Uziel.

## Código

- `codigo/matlab/prediccion_fk.m`: predicción FK para las tres poses.
- `codigo/matlab/comparacion_fk.m`: comparación predicción vs. medición.
- `codigo/jetcobot/medir_fk_jetcobot.py`: envío de poses y lectura con `get_coords()`.

Los fragmentos Python se ejecutaron como celdas en JupyterLab del JetCobot. El objeto `mc` y la conexión con el robot ya estaban inicializados en la sesión; por eso estos archivos no repiten esa configuración.

Resultados documentados: errores euclidianos de 5.37 mm, 6.18 mm y 7.58 mm, todos dentro del criterio de 10 mm.
