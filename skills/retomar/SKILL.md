---
name: retomar
description: Retoma una sesión que se cortó (límite de uso, cambio de cuenta, apagón) o la última de este proyecto. Úsala cuando el usuario diga "retoma", "en qué íbamos" o "qué hacía la otra cuenta".
---

# Retomar una sesión cortada

1. Corre `python ~/.claude/memoria-claude/arnes.py retomar $ARGUMENTS` (`python3` en Mac y Linux). Sin argumento
   lista las sesiones cortadas por límite de uso de los últimos 7 días; con un id, resume esa sesión.
2. Si hay más de una, pregunta cuál sigue (opción múltiple, con su fecha y su último mensaje).
3. Lee el bloque **EN CURSO** de la nota principal del proyecto de esa sesión (`~/.claude/memoria-claude/<proyecto>/`)
   y revisa `git status` de los repos que menciona: puede haber cambios sin commit de la sesión cortada.
4. Si el resumen no alcanza, lee el final de su transcripción (la ruta viene en el resumen) con Read, desde el final.
5. Retoma desde el paso siguiente sin volver a preguntar lo que el usuario ya decidió. Di en una línea desde dónde
   sigues y actualiza el EN CURSO si estaba atrasado.
