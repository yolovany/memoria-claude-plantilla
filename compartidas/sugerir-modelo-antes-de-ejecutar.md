---
name: sugerir-modelo-antes-de-ejecutar
description: Ahorrar tokens es prioridad; sugerir cambio de modelo (Opus↔Sonnet) antes de empezar trabajo cuyo costo no lo amerita.
metadata: 
  type: feedback
---

Antes de ejecutar cualquier tanda de trabajo, evaluar si el modelo activo es el adecuado y sugerir el cambio (Opus→Sonnet o Sonnet→Opus) antes de continuar, no a media faena.

**Why:** el gasto de tokens importa. Trabajo mecánico y verificable —correr comandos, leer logs, comparar salidas contra lo esperado— no compra nada con Opus, porque un error se delata solo. El diagnóstico de causa raíz, las decisiones de diseño y lo que toque despliegue, seguridad o credenciales sí lo ameritan.

**How to apply:** decidir con la regla "Sonnet mientras sea *corre esto, dime qué salió*; Opus en cuanto sea *por qué salió así*". Decirlo en una línea al inicio de la respuesta, junto con las [[peticiones-al-final-del-mensaje]], y esperar antes de quemar tokens en el modelo caro. El cambio se hace desde el selector de la app; no borra el contexto de la conversación.
