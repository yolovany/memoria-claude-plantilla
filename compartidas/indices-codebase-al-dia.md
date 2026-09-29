---
name: indices-codebase-al-dia
description: Con codebase-memory-mcp: todo repo en uso indexado y al día; un índice por carpeta.
metadata:
  type: feedback
---

Solo si usas codebase-memory-mcp. Todo repo que se use en una sesión, incluido `memoria-claude`, debe estar indexado
y al día: la búsqueda de código parte de esos índices y uno viejo da respuestas equivocadas.

**How to apply:**
- Con `auto_index` activado, la herramienta indexa el repo de la sesión y su vigilante lo sigue. No sigue
  `memoria-claude` ni los directorios adicionales: los cubre `hooks/indices.sh`, que reindexa todo proyecto cuyo commit
  cambió desde su último índice (tras cada `git commit` y al cerrar la sesión).
- Un repo nuevo se indexa a mano la primera vez (`index_repository` con `repo_path`).
- Un solo índice por carpeta, con el nombre que da la herramienta; si aparece otro para la misma carpeta, borrar el
  duplicado.
