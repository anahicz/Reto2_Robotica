# Reto 2 — El Turno del Brazo

Repositorio del RB-2 de Robótica (ESAN, Grupo 7 · Sección S003).

## Estructura

```text
ITEMS/
├── item1/   # Cinemática directa y verificación FK
├── item2/   # arm_broker, interfaces y evidencias de admisión
├── item3/   # Medición bajo contención, análisis y evidencia
└── item4/   # Auditoría de la IK del firmware

config/      # FastDDS y variables de red
scripts/     # Preparación, diagnóstico y ejecución
docs/        # Autoría, cambios y comandos
informe/     # Informe técnico
```

Responsables oficiales:
- Ítem 1 — Vara Vargas Valentino Uziel
- Ítem 2 — Ramirez Quevedo Karen Noelia
- Ítem 3 — Anahi Cortez Chinchay
- Ítem 4 — Sebastian Pedro Aguirre Acosta

La atribución completa está en `docs/AUTORIA_Y_RESPONSABLES.md`.

## Preparar una Raspberry nueva

La Raspberry debe tener Ubuntu/ROS 2 Humble y Git. El proyecto se prepara con dos pasos:

```bash
git clone https://github.com/anahicz/Reto2_Robotica.git
cd Reto2_Robotica && bash scripts/bootstrap_raspberry.sh
```

El script:
1. crea `config/network.env` si no existe;
2. copia el XML FastDDS real a `$HOME/super_client_configuration_file.xml`;
3. instala `arm_broker_interfaces` en `~/ros2_ws/src`;
4. compila la interfaz;
5. reinicia el daemon de ROS 2;
6. comprueba que la interfaz esté disponible.

Si el repositorio ya está clonado:

```bash
cd ~/Reto2_Robotica
bash scripts/sync_raspberry.sh
```

Para cargar el entorno en una terminal:

```bash
source scripts/ros_env.sh
```

Para verificar discovery:

```bash
bash scripts/check_client.sh
```

## Configuración validada

La corrida documentada usó:

```text
ROS_DOMAIN_ID=112
ROS_LOCALHOST_ONLY=0
RMW_IMPLEMENTATION=rmw_fastrtps_cpp
ROS_DISCOVERY_SERVER=172.51.1.17:11811
```

El XML usado realmente está versionado en `config/super_client_configuration_file.xml`.

## Política de prioridad

El código recuperado del workspace compilado usa:

```text
prioridad efectiva = prioridad + espera_s / tau
tau = 8.0 s
```

Por tanto, la política `prioridad` implementada es **prioridad con envejecimiento (aging)**. En la corrida observada las esperas fueron cortas respecto a `tau`, por lo que el orden coincidió con prioridad numérica descendente, pero la implementación activa sí incluía aging.

## Estado

Ya están versionados:
- código final de `arm_broker`;
- `arm_broker_interfaces`;
- código de Ítems 1 y 4 extraído del informe;
- XML FastDDS real;
- evidencias de rechazos del Ítem 2;
- bags, CSV, métricas, figura y verificación de exclusión del Ítem 3.

Pendientes de entrega externa: video de 3 minutos y, si el docente la exige, repetición con la traza CSV oficial.
