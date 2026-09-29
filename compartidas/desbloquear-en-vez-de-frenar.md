---
name: desbloquear-en-vez-de-frenar
description: En pruebas, ante un bloqueo, crear o ajustar lo que falte y seguir.
metadata:
  type: feedback
---

En pruebas, ante un bloqueo (falta un dato, un catálogo, un parámetro), crear o ajustar lo que falte y seguir, en
vez de marcarlo como bloqueado y saltar. Al inicio, confirmar que se trabaja en un ambiente de pruebas.

**Why:** aplicar a las pruebas la cautela de producción cuesta sesiones enteras; los datos de prueba se restauran.

**How to apply:** decir qué se va a tocar, hacerlo y seguir el plan; restaurar al cerrar. Un bloqueo real es solo el
que ninguna edición local puede resolver. En producción nunca: [[produccion-solo-diagnostico]].
