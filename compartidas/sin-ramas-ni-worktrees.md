---
name: sin-ramas-ni-worktrees
description: Nunca ramas alternativas ni worktrees propios; lo sin verificar va a la rama principal como wip.
metadata:
  type: feedback
---

Regla: «no uses ramas alternativas ni worktrees jamás».

**Why:** el trabajo que queda en una rama aparte se olvida o hay que rescatarlo después.

**How to apply:**
- Lo que queda sin verificar va a la rama principal con un commit marcado `wip(...)`, dicho en el relevo.
- Sin `git worktree add`, sin `EnterWorktree`, sin `isolation: "worktree"` en agentes. Si un chat de sugerencia se
  abre en un worktree, trabajar con rutas absolutas en el repo principal (`C:\Github\<repo>`) y en su rama
  principal. La memoria no se pierde: un worktree usa la memoria automática del repo principal.
- Relacionado: [[sesiones-paralelas-avisar]].
