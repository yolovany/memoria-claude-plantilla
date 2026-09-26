---
name: guardar-memoria-sin-pedirlo
description: Guardar en memoria lo importante sin esperar a que el usuario lo pida: correcciones, decisiones, datos del entorno y estado; en el momento, avisando en una línea.
metadata:
  type: feedback
---

El usuario no tiene que decir "guárdalo en memoria". Claude detecta lo importante por sus afirmaciones y
confirmaciones y lo guarda solo (decidido el 2026-09-26).

**Qué se guarda:**
- **Correcciones:** "no hagas eso", "así no" o un cambio de enfoque. Se guarda la regla y el porqué.
- **Decisiones y confirmaciones:** lo que elige en las preguntas con opciones, y cuando confirma un enfoque que no
  era obvio ("sí, así", "perfecto").
- **Datos del entorno:** servidores, rutas, quién hace qué, configuraciones de clientes. Lo sensible va cifrado
  (regla "Lo sensible" en `CLAUDE.md`).
- **Estado al cerrar un tema:** qué quedó hecho, qué falta y qué está sin probar, en la nota de estado del proyecto.

**Why:** una decisión que queda solo en la conversación se pierde cuando la sesión se corta o se compacta, y el
usuario no quiere volver a explicar.

**How to apply:**
- **Cuándo:** en el momento en que se detecta, no al final.
- **Dónde:** lo decide Claude. Si es de un repo, va en su carpeta; si es técnico, en su `docs/`; si sirve a varios
  proyectos, en `compartidas/`. Si el lugar es dudoso, preguntar.
- **Aviso:** una línea al final de la respuesta ("Guardé en memoria: …") para que pueda corregirlo.
- **Qué no:** lo que el repo o git ya registran, ni lo que solo sirve para la conversación en curso.
- Antes de crear una nota, actualizar la que ya cubra el tema.
