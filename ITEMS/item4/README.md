# Ítem 4 — Puerta a la cinemática inversa

**Encargado oficial:** Sebastian Pedro Aguirre Acosta.

## Código

- `codigo/jetcobot/prueba_ik_firmware.py`: envía la meta cartesiana con `send_coords()` y lee `get_angles()`.
- `codigo/matlab/auditoria_ik_fk.m`: aplica la FK propia al vector articular ejecutado y calcula el error.

El fragmento Python se ejecutó como celda en JupyterLab del JetCobot, donde `mc` ya estaba inicializado.

Resultado documentado: error cartesiano de 10.40 mm respecto a la meta solicitada.
