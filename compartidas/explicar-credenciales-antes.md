---
name: explicar-credenciales-antes
description: Antes de pedir que se cree un token o llave: permisos mínimos, dónde se guarda, caducidad y riesgo.
metadata:
  type: feedback
---

Cuando haga falta que el usuario cree un token, una llave de API o una cuenta de servicio, explicar antes de que la
genere: qué permisos mínimos marcar (y por qué no más), dónde va a quedar guardada (`.env` fuera de git, servidor,
cifrada), qué caducidad ponerle y qué pasa al vencer, y qué riesgo hay si se filtra y cómo se revoca.

**Why:** con eso claro de entrada se evitan idas y vueltas y credenciales con más permisos de los necesarios.

**How to apply:** una tabla corta con esos cuatro puntos y el nombre sugerido para la credencial. Nunca pedir que la
pegue en el chat: va en `.env` o en el panel. Ver [[llaves-de-prueba-antes-que-mcp]].
