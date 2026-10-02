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
- **Aviso al 80%** (`hooks/aviso-contexto.sh`, con cada mensaje y tras cada herramienta): cuando el contexto llega al
  80% de la ventana de compactación automática (`autoCompactWindow`, 500K por omisión del arnés), Claude recibe la
  orden de poner al día el EN CURSO antes de seguir. Una vez por ciclo. Si llega, se atiende primero.
- **Ventana de compactación:** compactar antes ahorra tokens (cada respuesta relee todo el contexto), pero cada
  compactación pierde detalle. Ajustarla a lo que uno suele usar con `/autocompact` (por ejemplo `/autocompact 500k`).
- Relacionadas: [[retomar-sesion-cortada]], [[sesiones-paralelas-avisar]].
