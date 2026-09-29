---
name: sesiones-paralelas-avisar
description: Con chats paralelos: avisar hallazgos por SendMessage y coordinar los recursos compartidos.
metadata:
  type: feedback
---

Cuando hay otra sesión en una tarea relacionada, avisarle con `SendMessage` de cada hallazgo o ajuste que afecte sus
resultados, sin esperar a que pregunte, y coordinar los recursos que no se pueden compartir (un equipo de pruebas, un
servidor local, una base de pruebas).

**Why:** dos sesiones que no se hablan trabajan sobre supuestos viejos o se pisan un recurso.

**How to apply:**
- `ListAgents` para dar con la sesión y `SendMessage` con una primera línea que se entienda sola. Avisar al liberar
  un recurso, al corregir algo que se le pasó y al cambiar herramientas o commits que la afecten.
- Sin orquestar muchos agentes en esos chats: gastan demasiados tokens. Cada chat trabaja directo.
- Recursos por turnos: un chat coordinador lleva quién tiene cada uno; se pide turno, se espera el visto bueno y se
  avisa al liberar.
- Si `SendMessage` por nombre falla (dos sesiones con el mismo título o una detenida), usar el id `local_…` con
  `mcp__ccd_session_mgmt__send_message`, que además la reanuda.
- Una sola sesión (la principal) edita la nota del proyecto y su bloque EN CURSO; las demás le mandan los cambios.
