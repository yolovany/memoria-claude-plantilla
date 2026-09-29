---
name: estandar-de-la-industria
description: No heredar decisiones por inercia: compararlas con lo que usa la industria y proponer lo más robusto.
metadata:
  type: feedback
---

Al retomar un proyecto con decisiones de otra persona (librerías, plugins, proveedores, arquitectura), no
conservarlas por inercia: compararlas con lo que usa la industria para ese tipo de proyecto y proponer lo más robusto o
más sencillo de mantener, explicando qué se gana al cambiar.

**Why:** lo heredado muchas veces no es la mejor opción, y cambiar a tiempo cuesta menos que después.

**How to apply:** inventariar lo existente, decir qué usa la industria (con fuentes) y proponer con pros y contras:
conservar, sustituir o combinar ([[preguntar-antes-de-decidir]]). Al comparar proveedores, probar el mismo caso con sus
APIs reales cuando se pueda. Lo que se sustituye queda apagado y reversible hasta que el reemplazo se pruebe en real.
