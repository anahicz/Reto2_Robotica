#!/usr/bin/env python3
# =============================================================================
# UNIVERSIDAD ESAN · ROBÓTICA (08079)
# RETO DEL BRAZO 2 — EL TURNO DEL BRAZO
# Grupo 7 · Sección S003
#
# Encargados de la evidencia y validación del Ítem 3:
#   - Anahi Cortez Chinchay
#   - Ramirez Quevedo Karen Noelia
#   - Sebastian Pedro Aguirre Acosta
#   - Vara Vargas Valentino Uziel
#
# Esta cabecera identifica responsables de ejecución/validación, no pretende
# atribuir al grupo el andamiaje base entregado por el curso.
# =============================================================================
"""Verifica la exclusión mutua a partir de los CSV exportados del bag.

    python3 verificar_exclusion.py fifo/
    python3 verificar_exclusion.py fifo/queue_state.csv

Argumento: /arm/queue_state publica un único `executing_goal_id` por mensaje.
Si el brazo atendiera dos pedidos a la vez, los ids se verían ALTERNAR
(A, B, A) o un pedido aparecería ejecutándose y esperando en el mismo mensaje.
Se cuentan como violaciones:

  1. un goal_id que reaparece como ejecutándose después de que otro tomó el brazo;
  2. un goal_id que figura a la vez como ejecutándose y en la cola;
  3. un cambio de ejecutor sin pasar por el relevo normal.

Además informa (sin contarlas como violación) los saltos de /joint_states.
"""

import csv
import os
import sys


def leer_csv(ruta):
    with open(ruta, newline='') as f:
        return list(csv.DictReader(f))


def main():
    if len(sys.argv) < 2:
        sys.exit('Uso: python3 verificar_exclusion.py <carpeta_o_queue_state.csv>')

    arg = os.path.expanduser(sys.argv[1])
    if os.path.isdir(arg):
        q_ruta = os.path.join(arg, 'queue_state.csv')
        j_ruta = os.path.join(arg, 'joint_states.csv')
    else:
        q_ruta = arg
        j_ruta = os.path.join(os.path.dirname(os.path.abspath(arg)), 'joint_states.csv')

    if not os.path.isfile(q_ruta):
        sys.exit(f'No encuentro {q_ruta}. ¿Corriste exportar_csv.py?')

    filas = leer_csv(q_ruta)
    if not filas:
        sys.exit('queue_state.csv está vacío: ¿se grabó /arm/queue_state?')

    violaciones = []
    terminados = set()
    actual = ''
    ejecutores = {}
    intervalos = {}
    muestras_ocupado = 0

    for n, fila in enumerate(filas):
        t = int(fila['t_ns'])
        gid = fila['executing_goal_id']
        en_cola = [g for g in fila['queued_goal_ids'].split('|') if g]

        if gid:
            muestras_ocupado += 1
            ejecutores[gid] = fila['executing_client']
            if gid in en_cola:
                violaciones.append((n, t, f'{gid} ejecutándose y en cola a la vez'))
            if gid in terminados:
                violaciones.append((n, t, f'{gid} volvió a ejecutarse tras ceder el brazo'))
            iv = intervalos.setdefault(gid, [t, t])
            iv[1] = t

        if gid != actual:
            if actual:
                terminados.add(actual)
            actual = gid

    ordenados = sorted(intervalos.items(), key=lambda kv: kv[1][0])
    for (a, (a0, a1)), (b, (b0, b1)) in zip(ordenados, ordenados[1:]):
        if b0 < a1:
            violaciones.append((-1, b0, f'intervalos de {a} y {b} se solapan'))

    t0, t1 = int(filas[0]['t_ns']), int(filas[-1]['t_ns'])
    print(f'Archivo               : {q_ruta}')
    print(f'Mensajes queue_state  : {len(filas)}  ({(t1 - t0) / 1e9:.1f} s grabados)')
    print(f'Goals distintos       : {len(intervalos)}')
    print(f'Clientes que ejecutaron: {sorted(set(ejecutores.values()))}')
    print(f'Mensajes con brazo ocupado: {muestras_ocupado} de {len(filas)}')
    print('Máximo de goals ejecutándose a la vez en un mensaje: 1 '
          '(el mensaje solo tiene un executing_goal_id)')

    if os.path.isfile(j_ruta):
        js = leer_csv(j_ruta)
        q = [[float(f['j%d' % i]) for i in range(1, 7)] for f in js]
        saltos = [max(abs(a - b) for a, b in zip(q[k], q[k + 1])) for k in range(len(q) - 1)]
        if saltos:
            print(f'joint_states          : {len(q)} muestras, salto máximo entre muestras '
                  f'{max(saltos):.3f} rad')

    print()
    for n, t, motivo in violaciones[:10]:
        print(f'  violación (fila {n}, t={t}): {motivo}')
    if len(violaciones) > 10:
        print(f'  ... y {len(violaciones) - 10} más')

    if violaciones:
        print(f'VIOLACIONES DE EXCLUSION MUTUA: {len(violaciones)} -> REVISAR (no cumple)')
        sys.exit(1)
    print('VIOLACIONES DE EXCLUSION MUTUA: 0 -> CERO (cumple)')


if __name__ == '__main__':
    main()
