---
name: indices-codebase-al-dia
description: Todo repo en uso (incluido memoria-claude) indexado en codebase-memory-mcp, con auto_watch y auto_index; un índice por carpeta.
metadata:
  type: feedback
---

Todo repo que se use en una sesión, incluido `memoria-claude`, debe estar indexado en codebase-memory-mcp, y los
índices al día siempre.

**Why:** la búsqueda de código parte de esos índices; uno viejo o faltante da respuestas equivocadas.

**How to apply:**
- Configuración (`codebase-memory-mcp config list`): `auto_watch=true` reindexa los proyectos indexados mientras
  hay sesión; `auto_index=true` indexa el repo de la sesión si no lo estaba. Los directorios adicionales no se
  indexan solos: al empezar a usar uno, revisar `list_projects` e indexarlo.
- Un solo índice por carpeta, con el nombre que da la herramienta; si aparece otro nombre para la misma raíz,
  borrar el duplicado.
