# Ítem 2 — Broker con cola de prioridades

**Encargada oficial:** Ramirez Quevedo Karen Noelia.

## Código final recuperado

`codigo/arm_broker` y `codigo/arm_broker_interfaces` provienen del workspace que fue compilado e instalado en el laboratorio.

Archivos principales:
- `arm_broker/arm_broker/broker.py`
- `arm_broker/arm_broker/fk.py`
- `arm_broker/arm_broker/politicas.py`
- `arm_broker/arm_broker/cliente.py`
- `arm_broker_interfaces/action/MoveArm.action`
- `arm_broker_interfaces/msg/QueueState.msg`

Los SHA-256 comprobados entre `src`, `build` e `install` fueron idénticos para:
- broker.py: `d89000755c3968b5368136e4c60969c63d89d5b776a17c5d9d24a2409db93f90`
- fk.py: `4f93f28bb9382c538d1efd678dd8b0efa11d34d56c135d3520fa65d478a05e1f`
- politicas.py: `10b2d3e07166e3e31f0e83e056782a96b533bf70d57e41cf8b2b684ee666ac9c`
- cliente.py: `95ff93e53d4ce091f3d75d0c6890b7c62556367c7269e4c470fae6b615d128d3`

## Política implementada

`broker.py` importa `POLITICAS` y `Pedido` desde `politicas.py`. Para `politica:=prioridad`, instancia `SegundaPolitica` con `tau_envejecimiento_s`.

`SegundaPolitica` usa:

```text
puntaje = priority + espera_s / tau
tau = 8.0 s
```

Por tanto, la política implementada es **prioridad con envejecimiento**.

## Evidencia

`evidencia/rechazos` contiene los rechazos por:
- límite articular;
- fuera del workspace;
- paso articular excesivo.
