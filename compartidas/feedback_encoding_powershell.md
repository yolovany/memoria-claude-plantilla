---
name: feedback_encoding_powershell
description: En Windows, no editar archivos con Set-Content/Out-File de PowerShell 5.1: añade BOM.
metadata:
  type: feedback
---

Solo en Windows. Para editar archivos de un repo no usar `Set-Content` ni `Out-File` de Windows PowerShell 5.1: la
herramienta Edit, o `sed -i` desde Bash.

**Why:** PowerShell 5.1 escribe UTF-8 con BOM (`EF BB BF`) y convierte LF a CRLF. El BOM rompe acentos y emojis en
páginas web y hace que un `@import` al inicio de un `CLAUDE.md` deje de funcionar.

**How to apply:** pocos archivos, Edit; muchos con el mismo patrón, `sed -i` en Bash (UTF-8 sin BOM, conserva LF).
Comprobar con `xxd archivo | head -1` que no empiece con `efbbbf`.
