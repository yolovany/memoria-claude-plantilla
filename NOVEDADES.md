# Novedades

Lo que cambia en cada versión, en palabras simples. "Actualiza el arnés" muestra las secciones posteriores a tu
versión.

## v1.0.0 — 2026-09-29

- **Se instala y se actualiza con un prompt.** "Actualiza el arnés" trae lo nuevo sin tocar tus memorias, tu
  `CLAUDE.md` ni lo que apagaste; lo que editaste te lo pregunta. Las copias viejas se migran con el mismo prompt de
  instalación.
- **Windows, Mac y Linux.** El instalador pasó a Python (`arnes.py`) y los hooks ya no dependen de Windows.
- **Cambio de cuenta sin perder el hilo.** Si una sesión se corta por el límite de uso, el chat nuevo en la misma
  carpeta la retoma solo. A mano: `/retomar`.
- **Atajos:** `/retomar`, `/cerrar-tema`, `/memorias`, `/actualizar-arnes`, `/proponer-mejora`.
- **Doctor:** `/memorias` revisa que todo esté en su lugar, dice cómo arreglar lo que falte y cuántos tokens carga la
  memoria en cada chat.
- **Barra de estado** con modelo, % de contexto y % del límite de 5 horas.
- **Menos tokens:** el índice de un repo ya no se carga dos veces; el de un repo adicional llega solo cuando Claude toca
  sus archivos. Aviso diario si un índice pasa del presupuesto (6 KB `compartidas/`, 4 KB cada repo).
- **Compactar sin perder el hilo:** antes de compactar se archiva y se sube todo; después, Claude retoma desde el
  bloque EN CURSO.
- **36 notas generales** en tres grupos (preferencias que se apagan, prácticas y según herramienta), con reglas nuevas
  como "producción: solo diagnóstico", "retomar sesión cortada" y "explicar credenciales antes".
- Reglas de la memoria aparte, en `REGLAS.md`; tu `CLAUDE.md` queda solo con lo tuyo. Perfil ("Sobre mí") al instalar.
- Guía de primeros pasos (`GUIA.md`) y licencia MIT.

## v0.4.0 y anteriores

Primeras versiones, solo Windows y sin actualización: memoria por repo, hooks de inicio y cierre, secretos cifrados,
barra con caveman y ponytail, e índices de codebase-memory-mcp.
