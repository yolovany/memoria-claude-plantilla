---
name: sesiones-paralelas-avisar
description: Hallazgos que afecten a otra sesión relacionada se le mandan por SendMessage; recursos compartidos por turnos.
metadata:
  type: feedback
---

Cuando hay otra sesión en una tarea relacionada, avisarle con `SendMessage` de cada hallazgo o ajuste que afecte
sus resultados, sin esperar a que pregunte. Coordinar los recursos que no se pueden compartir (equipos de prueba,
servidores locales, bases de prueba).

**Why:** una sesión que trabaja con información vieja o que pisa un recurso ocupado pierde su trabajo.

**How to apply:**
- `ListAgents` para dar con la sesión; `SendMessage` con la primera línea autocontenida.
- Avisar al liberar un recurso y en qué estado queda, al corregir una hipótesis que se le pasó y al cambiar
  herramientas compartidas o hacer commits que la afecten.
- Con varios chats a la vez: sin workflows ni agentes múltiples (gastan muchos tokens); un chat coordinador lleva
  los turnos de los recursos.
