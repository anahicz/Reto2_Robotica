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
"""Predice la espera por política ANTES de medir (simulación, sin ROS ni robot).

    python3 predecir_p95.py --src ~/Desktop/ros2_ws/src/arm_broker --poses 40

Usa TUS políticas reales (arm_broker/politicas.py), así que la predicción cambia
si cambias tau o la lógica de la política.

Modelo (simple, y hay que decirlo en el diseño previo):
  - 4 clientes en lazo cerrado: mandan un pedido, esperan el resultado, descansan
    `pausa` s y mandan el siguiente (igual que cliente.py).
  - El brazo atiende de a uno y cada pose dura `servicio` s fijos
    (= duracion_movimiento_s del broker).
  - No modela red, ni rechazos, ni cancelaciones.
"""

import argparse
import importlib.util
import math
import os
import statistics
import sys
import types


def cargar_politicas(src):
    ruta = os.path.join(os.path.expanduser(src), 'arm_broker', 'politicas.py')
    if not os.path.isfile(ruta):
        sys.exit(f'No encuentro {ruta}\n'
                 'Usa --src con la carpeta del paquete (la que contiene arm_broker/politicas.py).')
    spec = importlib.util.spec_from_file_location('politicas_sim', ruta)
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    return mod


def p95(xs):
    if not xs:
        return 0.0
    o = sorted(xs)
    k = max(0, min(len(o) - 1, int(round(0.95 * (len(o) - 1)))))
    return o[k]


def jain(vals):
    if not vals or sum(vals) == 0:
        return 0.0
    return sum(vals) ** 2 / (len(vals) * sum(v * v for v in vals))


def simular(mod, nombre, clientes, poses, servicio, pausa, tau):
    reloj = [0.0]
    mod.time = types.SimpleNamespace(time=lambda: reloj[0])

    clase = mod.POLITICAS[nombre]
    try:
        politica = clase(tau) if nombre == 'prioridad' else clase()
    except TypeError:
        politica = clase()

    restantes = {c: poses for c, _ in clientes}
    prio = dict(clientes)
    proximo = {c: 0.0 for c, _ in clientes}
    en_cola = set()
    pendientes = []
    esperas = []
    contador = 0
    libre_en = 0.0
    t = 0.0

    while any(restantes.values()) or pendientes:
        for c, _ in clientes:
            if restantes[c] > 0 and c not in en_cola and proximo[c] <= t:
                reloj[0] = proximo[c]
                contador += 1
                gh = types.SimpleNamespace(
                    goal_id=types.SimpleNamespace(uuid=contador.to_bytes(16, 'big')))
                ped = mod.Pedido(gh, c, prio[c], [0.0] * 6)
                ped.t_llegada = proximo[c]
                pendientes.append(ped)
                en_cola.add(c)

        if libre_en <= t and pendientes:
            reloj[0] = t
            idx = politica.siguiente(pendientes)
            ped = pendientes.pop(idx)
            ped.t_inicio_ejec = t
            esperas.append((ped.client_id, ped.priority, t - ped.t_llegada))
            libre_en = t + servicio
            politica.atendido(ped)
            restantes[ped.client_id] -= 1
            en_cola.discard(ped.client_id)
            proximo[ped.client_id] = libre_en + pausa
            t = libre_en
            continue

        candidatos = [libre_en] if libre_en > t else []
        candidatos += [proximo[c] for c, _ in clientes
                       if restantes[c] > 0 and c not in en_cola and proximo[c] > t]
        if not candidatos:
            break
        t = min(candidatos)

    return esperas


def mostrar(nombre, esperas, clientes):
    todas = [w for _, _, w in esperas]
    por_prio = {}
    for _, p, w in esperas:
        por_prio.setdefault(p, []).append(w)
    atendidos = {c: sum(1 for cc, _, _ in esperas if cc == c) for c, _ in clientes}

    print(f'\n=== {nombre.upper()}')
    print(f'  pedidos            : {len(todas)}')
    print(f'  espera media       : {statistics.mean(todas):.2f} s')
    print(f'  espera p95 global  : {p95(todas):.2f} s')
    print(f'  espera máxima      : {max(todas):.2f} s')
    print('  por prioridad (mayor número = más urgente):')
    for p in sorted(por_prio, reverse=True):
        ws = por_prio[p]
        print(f'    prioridad {p}: n={len(ws):3d}  media={statistics.mean(ws):6.2f}s  '
              f'p95={p95(ws):6.2f}s  máx={max(ws):6.2f}s')
    peor = min(por_prio)
    print(f'  índice de inanición: {max(por_prio[peor]):.2f} s  '
          f'(espera máxima de la prioridad {peor}, la menos urgente)')
    print(f'  equidad de Jain    : {jain(list(atendidos.values())):.3f}  (sobre goals por cliente)')
    return p95(todas)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--src', required=True, help='carpeta del paquete arm_broker')
    ap.add_argument('--poses', type=int, default=40, help='poses por cliente (las de la traza)')
    ap.add_argument('--servicio', type=float, default=3.0, help='segundos por pose')
    ap.add_argument('--pausa', type=float, default=0.5, help='pausa_s del cliente')
    ap.add_argument('--tau', type=float, default=8.0, help='tau_envejecimiento_s')
    ap.add_argument('--clientes', default='ana:1,beto:5,carla:3,dario:2',
                    help='nombre:prioridad separados por coma')
    args = ap.parse_args()

    clientes = []
    for par in args.clientes.split(','):
        n, p = par.split(':')
        clientes.append((n.strip(), int(p)))

    mod = cargar_politicas(args.src)
    print(f'Simulación: {len(clientes)} clientes x {args.poses} poses, servicio {args.servicio}s, '
          f'pausa {args.pausa}s, tau {args.tau}s')
    print(f'Clientes: {clientes}')

    resultados = {}
    for nombre in ('fifo', 'prioridad'):
        try:
            e = simular(mod, nombre, clientes, args.poses, args.servicio, args.pausa, args.tau)
        except NotImplementedError:
            sys.exit(f'La política "{nombre}" aún tiene NotImplementedError. '
                     'Aplica primero los bloques IMPLEMENTAR.')
        resultados[nombre] = mostrar(nombre, e, clientes)

    print('\nResumen: p95 global  FIFO = %.2f s   prioridad = %.2f s' %
          (resultados['fifo'], resultados['prioridad']))
    print('Escribe en el diseño previo qué esperas y por qué, con tus palabras.')


if __name__ == '__main__':
    main()
