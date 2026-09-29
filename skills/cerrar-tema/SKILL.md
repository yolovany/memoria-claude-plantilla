---
name: cerrar-tema
description: Cierra el tema en curso dejando todo en orden (memoria al día, commits, archivo de la sesión, publicar si aplica). Úsala cuando el usuario diga "cerramos", "cierra el tema" o al terminar un bloque de trabajo.
---

# Cerrar un tema

Hazlo en este orden y reporta al final en pocas líneas:

1. **Memoria del proyecto:** reescribe la nota principal como estado vigente con la fecha de hoy; integra o borra el
   bloque EN CURSO. Actualiza también las notas de otros repos que cambiaron y sus líneas en cada `MEMORY.md`
   (una línea corta por nota).
2. **Commits:** en cada repo tocado, `git add` por ruta (nunca `-A` ni `.`) solo de lo tuyo, revisa `git diff --cached`
   y haz commit. Push solo si el usuario ya lo autorizó para ese repo.
3. **Archivo de la sesión:** copia los scripts y notas útiles del scratchpad a
   `~/.claude/memoria-claude/<proyecto>/archivo/<fecha>-<sesión>/` (texto propio, menos de 1 MB, contraseñas tapadas
   con `***`) y agrega su fila arriba en `archivo/INDICE.md` con un tema que diga de qué trató.
4. **Memorias nuevas:** propón en opción múltiple las correcciones, decisiones o datos del entorno que valga la pena
   guardar (en el proyecto o en `compartidas/`).
5. **Plantilla:** si existe `~/.claude/memoria-claude/plantilla.txt` (eres el dueño de la plantilla) y el tema tocó
   hooks, `arnes.py`, `REGLAS.md`, `config/`, `skills/` o una nota general de `compartidas/`, propón publicar a la
   plantilla (`python ~/.claude/memoria-claude/publicar.py`, ver "Plantilla pública" en el README de memoria-claude).
6. **Reporte:** qué quedó hecho, dónde quedó cada cambio (pruebas, producción, solo docs, pendiente de salida), qué
   queda abierto y de quién depende. El commit y el push de memoria-claude los hace el hook de cierre.
