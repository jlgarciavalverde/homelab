# Lecciones aprendidas

[← Volver al README](../README.md)

Problemas reales que aparecieron montando y manteniendo el servidor, cómo se diagnosticaron y cómo se arreglaron.

## Infraestructura

| Síntoma | Causa | Arreglo |
|---|---|---|
| `cloudflared` respondía `Unauthorized: Tunnel not found` | El túnel se había creado de tipo Mesh/WARP Connector, que no usa ese token | Crear el túnel de tipo **Cloudflared**. Y no instalar WARP en el servidor: desvía todo el tráfico saliente y corta el SSH. |
| Errores 502 intermitentes | Un `docker run --token` copiado del panel había creado un segundo conector en la red `bridge`, que no ve los contenedores | Un solo `cloudflared`, el de Compose, en la red `proxy`. |
| CPU a 88–93 °C en reposo | El instalador de Ubuntu había instalado snaps destacados (microk8s, nextcloud…) | Purgarlos. Y compilar las imágenes en el Mac, nunca en el servidor. |
| SSH seguía aceptando contraseña | `50-cloud-init.conf` la activa y sshd usa el primer valor que lee | Endurecer en `00-hardening.conf`. |
| `Permission denied` al escribir en `./data` | Con Docker rootless, el uid 1000 del contenedor no es el usuario del host | `user: "0:0"` (el root del contenedor es el usuario normal del host) más `cap_drop: [ALL]` y solo lectura. |
| Una descarga del APK traía una versión vieja sin dejar rastro en los logs | Cloudflare cachea por extensión aunque el origen diga `no-cache` | `Cache-Control: no-store` (eso sí lo respeta) y `?v=<versión>` en la URL. |
| `/health` informaba de la versión antigua tras desplegar | `env_file: .env` pisaba la variable horneada en la imagen | El despliegue actualiza `APP_VERSION` en el `.env`. |
| Un subdominio nuevo «no existía» en el Mac | La caché DNS local recordaba el NXDOMAIN | Comprobar con `dig @1.1.1.1` o `curl --resolve`. |

## Aplicaciones

| Síntoma | Causa | Arreglo |
|---|---|---|
| Al cargar la web, el navegador recibía 429 | El límite global de peticiones contaba también los JS estáticos | Contar solo `/api/*`. |
| El permiso de Health Connect se cerraba solo, sin conceder nada | El plugin de Expo no declaraba los permisos `android.permission.health.*` en el manifiesto | Declararlos en `app.json` y comprobar el manifiesto tras cada `prebuild`. Se descubrió con `adb logcat` y `dumpsys package` en un móvil real. |
| La APK se cerraba al abrir la vista 3D (en la web funcionaba) | El build CommonJS de three llama a `process.emitWarning`, que no existe en React Native | Forzar `three.module.js` en `metro.config.js`. |
| La visión con IA daba un 503 idéntico al de «falta la clave» | Google retiró el modelo gratuito por defecto y el `catch` ocultaba el error real | Modelos configurables por variable de entorno y el error real en el log. |
| El servidor se apagaba solo de vez en cuando | Desconocida (portátil reciclado) | Vigilante desde el Mac que avisa si el servidor no responde. |

## Lo que se ha quedado como costumbre

- Medir antes de suponer: `adb logcat`, `dumpsys`, `curl` directo al contenedor frente al público y los mapas de R8 del build ya compilado.
- Cada trampa resuelta va al `AGENTS.md` del proyecto, para que no vuelva a costar otra tarde.
- Los e2e prueban lo que de verdad se rompe: offline, permisos, aislamiento, desbordes a 360 dp y accesibilidad.
