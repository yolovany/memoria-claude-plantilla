---
name: sin-ramas-ni-worktrees
description: Trabajar siempre en la rama principal, sin ramas alternativas ni worktrees.
metadata:
  type: feedback
---

Trabajar siempre en la rama principal del repo: sin ramas alternativas ni worktrees.

**Why:** lo que queda en otra rama se pierde de vista y no se revisa; con varias sesiones a la vez complica saber qué
está dónde.

**How to apply:**
- Lo que quede sin verificar va a la rama principal en un commit marcado `wip(...)` y se dice en el relevo.
- Sin `git worktree add`, `EnterWorktree` ni `isolation: "worktree"` en agentes. Si una herramienta lo impone,
  preguntar antes.
- Con varias sesiones en el mismo repo: [[commits-solo-cambios-propios]].
