---
name: temas-aparte-como-sugerencia
description: Un tema lateral se lanza como sugerencia (spawn_task) y los dos chats quedan comunicados.
metadata:
  type: feedback
---

Si en una conversación surge un tema que conviene llevar por separado (fuera del alcance, otro repo, un hallazgo
lateral), no se mezcla ni se frena el trabajo: se lanza como sugerencia con `spawn_task`. Si el usuario abre ese chat,
los dos quedan comunicados.

**Why:** cada tema avanza en su chat sin perder la coordinación con el que lo originó.

**How to apply:**
- El prompt de `spawn_task` lleva el id y el título de la sesión que lo dispara
  (`mcp__ccd_session_mgmt__get_session` con `"self"`) y estas instrucciones: al empezar, avisar a esa sesión; mandarle
  cada hallazgo o decisión que le afecte; al terminar, un resumen (hecho, abierto, commits).
- La sesión que lo disparó hace lo mismo en sentido contrario.
- Cuando el usuario abre el chat sugerido, copiarle modelo, esfuerzo, modo de permisos y estilo del chat que lo sugirió
  (`get_session` "self" y los `set_session_*` al id `local_…` nuevo): con otro modo de permisos los mensajes entre chats
  quedan retenidos.
- Recursos compartidos: [[sesiones-paralelas-avisar]].
