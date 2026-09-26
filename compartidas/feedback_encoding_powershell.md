---
name: feedback_encoding_powershell
description: No editar archivos de los repos con PowerShell Set-Content/Out-File: agrega BOM UTF-8; usar Edit o sed.
metadata:
  type: feedback
---

Para editar archivos de los repos (HTML/JS/CSS, Markdown), NO usar `Set-Content -Encoding utf8` ni `Out-File`
de Windows PowerShell 5.1. Usar la herramienta Edit o `sed -i` desde Bash.

**Why:** PowerShell 5.1 escribe UTF-8 **con BOM** (`EF BB BF`): rompe caracteres especiales en HTML y hace que
una línea `@import` de un CLAUDE.md deje de reconocerse. También convierte LF a CRLF.

**How to apply:** uno o pocos archivos, Edit; cambios en lote, `sed -i` en Bash. Verificar con
`head -c3 archivo | xxd` que no empiece con `efbbbf`.
