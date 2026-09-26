---
name: desbloquear-en-vez-de-frenar
description: En pruebas, crear o ajustar lo que falte y seguir, en vez de marcar el caso como bloqueado; preguntar al inicio si es ambiente de pruebas.
metadata:
  type: feedback
---

Ante un bloqueo durante las pruebas (falta un catálogo, un parámetro vacío, un dato que no existe), **crear o
ajustar lo que falte y seguir**, en vez de anotarlo como bloqueado y saltar al siguiente. Confirmar qué se va a
tocar, hacerlo y continuar en el orden del plan.

Preguntar al inicio de la sesión **si se trabaja sobre ambiente de pruebas**. Si lo es, no frenarse por datos
que se borran o quedan inconsistentes: se restauran al cerrar.

**Why:** la cautela de producción aplicada a pruebas cuesta sesiones enteras; el bloqueo real es solo el que
ninguna edición local puede resolver.

**How to apply:** vale copiar filas de catálogo, rellenar parámetros vacíos y editar banderas directo en la base
de pruebas. Restaurar al cerrar la corrida.
