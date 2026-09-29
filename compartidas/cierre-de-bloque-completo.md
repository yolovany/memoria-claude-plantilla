---
name: cierre-de-bloque-completo
description: Al cerrar un bloque grande, poner al día docs de todos los repos tocados y la memoria, sin que lo pidan.
metadata:
  type: feedback
---

Al cerrar un bloque grande (una funcionalidad, una auditoría, un cambio de proveedor), sin esperar a que el usuario
lo pida:
1. poner al día la documentación de todos los repos que se tocaron (README, guías, pendientes, bitácora);
2. ordenar la memoria: la nota del proyecto como estado vigente, sin bloques EN CURSO viejos ni datos superados;
3. confirmar los índices de búsqueda de código si se usan ([[indices-codebase-al-dia]]);
4. commit de lo propio ([[commits-solo-cambios-propios]]).

**Why:** con varios repos tocados, las notas y los documentos quedan atrasados si nadie los revisa al final.

**How to apply:** `/cerrar-tema` hace el recorrido. En repos públicos, sin nombres de clientes
([[no-mencionar-nombres-de-empresas]]); proponer memorias nuevas ([[recomendar-memorias-opcion-multiple]]); reportar
dónde quedó cada cambio ([[donde-quedo-cada-cambio]]).
