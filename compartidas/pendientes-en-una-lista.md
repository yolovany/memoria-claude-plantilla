---
name: pendientes-en-una-lista
description: Los pendientes de un proyecto van en una sola lista corta, por responsable, en el repo.
metadata:
  type: feedback
---

Los pendientes de un proyecto van en una sola lista, en el repo (por ejemplo `docs/pendientes.md`), agrupada por
responsable (el usuario, el cliente, el día de salida), un renglón por punto y sin explicaciones: el detalle vive en la
bitácora o la guía y se enlaza. Los demás documentos y la memoria remiten a esa lista en vez de repetirla.

**Why:** los pendientes repetidos en varios lugares se desincronizan y algunos quedan solo en uno.

**How to apply:** al cerrar cada tema, actualizar la lista en el mismo commit; al reportar pendientes en el chat, usar
el mismo formato.
