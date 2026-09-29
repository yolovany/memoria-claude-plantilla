---
name: actualizar-arnes
description: Trae la versión nueva del arnés de memoria desde la plantilla pública sin tocar lo propio. Úsala cuando el usuario diga "actualiza el arnés" o cuando el hook de inicio avise que hay versión nueva.
---

# Actualizar el arnés

1. `python ~/.claude/memoria-claude/arnes.py actualizar` (`python3` en Mac y Linux): vista previa con las novedades y
   qué se agrega, actualiza o quita. Nada cambia todavía.
2. Explica las novedades en palabras simples (qué gana él) y pide su sí.
3. `python ~/.claude/memoria-claude/arnes.py actualizar --aplicar`. Hace el commit; lo sube el hook de cierre.
4. **Editados:** los archivos del arnés que él cambió no se tocan. Para cada uno, muestra la diferencia con la versión
   nueva (`git -C ~/.claude/memoria-claude show vX.Y.Z:<archivo>` contra el suyo) y pregunta: conservar el suyo,
   tomar el nuevo (`--aplicar --forzar <archivo>`) o apagar esa nota (`apagadas.txt`).
5. `python ~/.claude/memoria-claude/arnes.py doctor` y, si cambiaron hooks o atajos, dile que reinicie Claude.
