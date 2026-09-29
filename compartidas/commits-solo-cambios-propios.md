---
name: commits-solo-cambios-propios
description: Con varias sesiones en el mismo repo, cada una hace commit solo de sus cambios.
metadata:
  type: feedback
---

Cuando varias sesiones trabajan en la misma copia del repo, cada sesión hace commit solo de sus propios cambios.

**Why:** un `git commit -a` de una sesión se lleva los cambios sin probar de otra, bajo un mensaje que no les
corresponde.

**How to apply:**
- Agregar por ruta: `git add <archivo>`. Nada de `git add -A`, `git add .` ni `git commit -a`.
- Antes del commit, `git diff --cached --stat`: debe listar solo archivos propios.
- Si otra sesión también tocó el archivo, avisarle ([[sesiones-paralelas-avisar]]) y acordar quién hace el commit.
- Al dejar cambios propios sin commit, avisar a las sesiones paralelas qué archivos son.
