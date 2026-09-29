---
name: guardar-memoria-sin-pedirlo
description: Claude guarda solo lo importante (correcciones, decisiones, entorno, estado) sin que se lo pidan.
metadata:
  type: feedback
---

El usuario no tiene que decir "guárdalo en memoria": Claude detecta lo importante por sus afirmaciones y
confirmaciones y lo guarda solo.

**Qué se guarda:**
- **Correcciones:** "no hagas eso", "así no" o un cambio de enfoque. Se guarda la regla y el porqué.
- **Decisiones y confirmaciones:** lo que elige en las preguntas con opciones, y cuando confirma un enfoque que no era
  obvio.
- **Datos del entorno:** servidores, rutas, quién hace qué, configuraciones. Lo sensible va cifrado ("Lo sensible" en
  `REGLAS.md`).
- **Estado al cerrar un tema:** qué quedó hecho, qué falta y qué está sin probar, en la nota del proyecto.

**Why:** una decisión que queda solo en la conversación se pierde cuando la sesión se corta o se compacta, y el
usuario no quiere volver a explicar.

**How to apply:**
- En el momento en que se detecta, no al final.
- Lugar: de un repo, en su carpeta; técnico, en el `docs/` del repo; para varios proyectos, en `compartidas/`. Si es
  dudoso, preguntar.
- Aviso: una línea al final de la respuesta ("Guardé en memoria: …") para que el usuario pueda corregirlo.
- No se guarda lo que el repo o git ya registran ni lo que solo sirve a la conversación en curso.
- Antes de crear una nota, actualizar la que ya cubra el tema.
