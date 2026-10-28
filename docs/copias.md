# Copias de seguridad

[← Volver al README](../README.md)

Regla: **una copia solo cuenta si se ha restaurado**. Por eso las de Postgres se restauran automáticamente en una base de datos aparte cada día.

## Qué se copia

| Servicio | Cómo | Cada cuánto | Retención | Comprobación | Copia fuera del servidor |
|---|---|---|---|---|---|
| nfc (Postgres) | Contenedor `nfc-backup`: `pg_dump` | Diario, 4:00 | 30 días | Restauración en `nfc_simulacro`, recuento de tablas, migraciones y filas. El resultado llega al bot de Telegram. | `pull-backups.sh` al Mac (el launchd está preparado, pero sin instalar) |
| coach (Postgres + fotos) | Contenedor `coach-backup`: `pg_dump` + `tar` de las fotos | Diario | 14 días | Simulacro real de restauración en el Mac | `pull-backups.sh` al Mac cada día (launchd) + vigilante |
| compra (SQLite) | La propia app: `VACUUM INTO` | Cada 6 h | 14 días | `PRAGMA integrity_check` al traerla | `pull-backups.sh` al Mac (a mano: el launchd no está instalado) |
| cheluisfit (SQLite) | La propia app: `VACUUM INTO` + copia antes de cada despliegue | Cada 6 h | 14 días | — | `backup-offsite.mjs` al Mac tras cada despliegue |
| Nextcloud | [`scripts/backup.sh`](../scripts/backup.sh): `mariadb-dump` + volumen en modo mantenimiento | Manual (ver pendiente) | 8 copias | — | Pendiente |
| Código | GitHub + `git bundle` de CheluisFIT en el servidor | En cada push o despliegue | — | — | Sí |

## Simulacro diario (nfc)

```mermaid
flowchart TD
  a["4:00 · pg_dump nfc"] --> b{¿Volcado OK?}
  b -- no --> f["Aviso a los admins por Telegram"]
  b -- sí --> c["Crear la BD nfc_simulacro<br/>y restaurar el volcado"]
  c --> d{"¿Restaura y tiene<br/>≥ 15 tablas?"}
  d -- no --> f
  d -- sí --> e["OK: tablas, migraciones,<br/>ventas, comercios y movimientos"]
  e --> g["Borrar nfc_simulacro<br/>y guardar el resultado en simulacro.txt"]
  f --> g
  g --> h["Resumen de los lunes en el grupo"]
```

Las escrituras van a un archivo `.tmp` que luego se renombra: una copia a medias nunca sustituye a una buena.

## Pendiente

- **Programar `scripts/backup.sh`** (Nextcloud y compra): el script existe pero no tiene cron, y la última copia es del 20 de septiembre de 2026. Basta con una línea en el `crontab` del usuario, por ejemplo `0 3 * * 0 ~/servicios/backup.sh >> ~/backups/backup.log 2>&1`.
- **Copia externa de Nextcloud**: hoy solo está en el mismo disco, lo que protege contra borrados pero no contra la rotura del disco.
- **Instalar los launchd de compra y nfc en el Mac**, para que sus copias externas se hagan solas como las de coach.
