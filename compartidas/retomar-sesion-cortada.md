---
name: retomar-sesion-cortada
description: Cómo retomar una sesión cortada (límite de uso, otra cuenta, apagón) desde su transcripción local.
metadata:
  type: reference
---

Una sesión cortada (límite de uso, cambio de cuenta, apagón) se retoma desde su transcripción local: las
herramientas de sesiones (`list_sessions`) solo ven las de la cuenta activa, pero la transcripción está en disco, en
`~/.claude/projects/<carpeta donde arrancó>/<id>.jsonl`.

**How to apply:**
- **Automático:** al abrir un chat, el hook de inicio busca en la misma carpeta de trabajo las sesiones de las últimas
  48 horas que terminaron en el error de límite de uso y le pasa a Claude su resumen (una vez por sesión).
- **A mano:** `/retomar` (o `python ~/.claude/memoria-claude/arnes.py retomar [id]`) lista las cortadas de los últimos
  7 días o resume una por su id.
- Después: leer el bloque EN CURSO de la nota del proyecto ([[preparar-compactacion]]), revisar `git status` de los
  repos que menciona y seguir desde la última respuesta del usuario sin volver a preguntar lo que ya aprobó.
- Si no aparece, buscar el id en todas las carpetas: `~/.claude/projects/*/<id>*.jsonl`. El hook de cierre también
  guarda una copia comprimida en `OneDrive/respaldos/claude-conversaciones/`.
