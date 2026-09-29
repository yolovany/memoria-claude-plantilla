---
name: commit-por-cada-pieza-terminada
description: Todo lo terminado va con su commit, un tema por commit.
metadata:
  type: feedback
---

Todo lo que se termina va acompañado de su commit, un tema por commit, antes de empezar lo siguiente.

**Why:** los cambios de varios temas acumulados ya no se pueden separar en commits coherentes, y se enredan con el
trabajo del usuario.

**How to apply:** mensajes en el idioma del usuario con el formato Conventional Commits y un cuerpo que explique el
porqué. Si la terminal rompe las comillas del mensaje, pasarlo con `git commit -F archivo`.
