# Borrador del post de LinkedIn

Hay dos versiones: una larga (la recomendada) y una corta. Adjunta como imágenes el diagrama de arquitectura del README y 2 o 3 capturas de las apps (de `~/Downloads/Capturas apps/`).

---

## Versión larga

Tenía un portátil viejo en un cajón. Hoy es el servidor de producción de 6 aplicaciones que usan mi familia, mis amigos y un entrenador personal con sus clientes. 🖥️

Lo que corre en él:
• Una lista de la compra familiar en tiempo real que funciona sin cobertura en el súper
• Una app de fitness con APK propio (nutrición, running con Garmin y Strava, fuerza)
• Un SaaS para entrenadores personales, con pagos con Stripe Connect y demo pública
• Un bot de Telegram y un panel para gestionar un pequeño negocio de placas NFC
• Un concurso para un cumpleaños: TV, presentador y un móvil por equipo
• Nextcloud como nube personal

Cómo está montado:
🔒 Cero puertos web abiertos en el router: todo entra por un túnel de Cloudflare que se abre desde casa hacia fuera
🐳 17 contenedores en Docker rootless, sin capacidades del kernel, con sistema de archivos de solo lectura y límites de memoria y CPU
🗄️ Bases de datos en redes internas sin salida a internet; la demo pública ni siquiera ve la red de producción
💾 Copias diarias que se restauran solas en una base de datos aparte para comprobar que sirven, y el resultado me llega por Telegram
🚀 Despliegue con un comando: compila en el Mac, copia los datos antes de actualizar y vuelve sola a la versión anterior si la nueva no responde

Y la parte que más me interesa contar: la metodología.
Lo he construido dirigiendo agentes de IA como si fueran mi equipo de desarrollo. Lo que me ha funcionado:
1️⃣ Primero un plan escrito y aprobado; después, código
2️⃣ Fases pequeñas que acaban en producción, no en una rama
3️⃣ Nada está hecho sin tests en verde: unitarios, e2e con Playwright y accesibilidad WCAG AA
4️⃣ Un AGENTS.md por repo con las convenciones y las trampas ya resueltas, y un ESTADO.md para que cada sesión empiece donde acabó la anterior
5️⃣ Decisiones registradas en ADR, y la seguridad y el diseño vigilados por tests
6️⃣ Los secretos nunca pasan por el chat con la IA

Lo más valioso no salió de los tests, sino de probarlo de verdad: un permiso de Android que nunca se declaraba, una caché de Cloudflare que servía APKs viejos sin dejar rastro, un límite de peticiones que bloqueaba la propia web… Todo está documentado.

He publicado la configuración del servidor (sin secretos) y el código de las apps, con diagramas de arquitectura, requisitos y flujos:
👉 github.com/jlgarciavalverde/homelab

Si te interesa el self-hosting, la seguridad en contenedores o trabajar con agentes de IA en proyectos reales, estaré encantado de hablarlo. 👇

#SelfHosting #Docker #DevOps #Cloudflare #IA #DesarrolloDeSoftware #Backend #Homelab

---

## Versión corta

Un portátil viejo → servidor de producción con 6 apps propias y 17 contenedores. 🖥️

🔒 0 puertos web abiertos (Cloudflare Tunnel)
🐳 Docker rootless, solo lectura y sin capacidades
💾 Copias que se restauran solas cada día para comprobar que sirven
🚀 Despliegue con un comando y vuelta atrás automática
🤖 Construido dirigiendo agentes de IA: plan aprobado → fases pequeñas → tests en verde → producción

Configuración, metodología y lecciones aprendidas, todo publicado 👉 github.com/jlgarciavalverde/homelab

#SelfHosting #Docker #DevOps #IA #Homelab
