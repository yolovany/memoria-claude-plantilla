---
name: commit-por-cada-pieza-terminada
description: Cada trabajo terminado se commitea en el momento; no dejar cambios acumulándose en el árbol.
metadata: 
  type: feedback
---

Instrucción del usuario el 2026-08-09: "todo lo que completes debe estar
acompañado de su commit". Surgió tras dejar tres temas distintos mezclados sin
confirmar en el árbol de trabajo.

**Why:** cambios acumulados de varios temas ya no se pueden separar en commits
coherentes, y su propio trabajo sin confirmar queda enredado con el mío.

**How to apply:** al terminar una pieza, commitearla antes de empezar la
siguiente, un tema por commit. Mensajes en español, Conventional Commits, con
cuerpo que explique el porqué (así es su historial). Pasar el mensaje con
`git commit -F archivo`: los here-strings de PowerShell se rompen con comillas
dentro. Ver también [[peticiones-al-final-del-mensaje]].
