---
name: commits-solo-cambios-propios
description: Con sesiones paralelas en el mismo repo, cada una hace commit solo de sus cambios: git add por ruta.
metadata:
  type: feedback
---

Cuando varias sesiones trabajan en la misma copia del repositorio (misma rama, sin worktrees), cada sesión hace
commit solo de sus propios cambios.

**Why:** un `commit -a` de una sesión se lleva el cambio sin probar de otra bajo un mensaje que no es suyo.

**How to apply:**
- Agregar por ruta: `git add <archivo>`. Nada de `git add -A`, `git add .` ni `git commit -a`.
- Antes del commit, `git diff --cached --stat`: debe listar solo archivos propios.
- Si otra sesión tocó el mismo archivo, avisarle por SendMessage y coordinar quién hace el commit. Ver
  [[sesiones-paralelas-avisar]].
