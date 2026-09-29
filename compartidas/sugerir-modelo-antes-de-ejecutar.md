---
name: sugerir-modelo-antes-de-ejecutar
description: Antes de una tanda de trabajo, sugerir el modelo adecuado (más rápido o más capaz).
metadata:
  type: feedback
---

Antes de ejecutar una tanda de trabajo, evaluar si el modelo activo es el adecuado y sugerir el cambio antes de
empezar, no a media faena.

**Why:** el gasto de tokens importa. Lo mecánico y verificable (correr comandos, leer registros, comparar salidas) no
gana nada con el modelo más caro, porque un error se delata solo. El diagnóstico de causa raíz, las decisiones de
diseño y lo que toque despliegues, seguridad o credenciales sí lo ameritan.

**How to apply:** regla: modelo rápido mientras sea "corre esto y dime qué salió"; el más capaz en cuanto sea "por qué
salió así". Decirlo en una línea y esperar. Cambiar el modelo desde el selector no borra la conversación.
