---
name: preparar-compactacion
description: El bloque EN CURSO del proyecto se mantiene al día; los hooks de compactación archivan, suben y hacen retomar.
metadata:
  type: feedback
---

La compactación (manual o automática) resume la conversación y pierde detalle. Para retomar sin perder dirección, el
estado vive fuera de la conversación.

**Why:** una sesión larga con varios repos, chats paralelos y pruebas a medias pierde en el resumen qué faltaba, qué
se decidió y qué chat lleva qué.

**How to apply:**
- **EN CURSO siempre al día:** en la nota principal del proyecto, un bloque EN CURSO arriba del estado vigente: chat y
  su id, qué se hace, resultados con números de commit, qué falta exactamente, siguientes pasos en orden, decisiones
  recientes del usuario y chats paralelos. Se actualiza al cerrar cada paso, no al pedir compactar. Se integra o se
  borra al cerrar el tema.
- **Hooks:** antes de compactar (`hooks/compactar.sh antes`) se archiva el scratchpad de la sesión y se sube la
  memoria; después (`compactar.sh despues`) Claude recibe la orden de leer el EN CURSO y retomar desde ahí sin volver
  a preguntar lo decidido. Las instrucciones del resumen están en `REGLAS.md` ("Al compactar").
- **Aviso:** cuando el contexto va lleno (la barra de estado muestra el %), sugerir compactar en una línea, con el EN
  CURSO ya al día.
- Relacionadas: [[retomar-sesion-cortada]], [[sesiones-paralelas-avisar]].
