---
name: rtk-hook-powershell
description: Si usas RTK (compresor de salidas de comandos): que el hook cubra PowerShell, telemetría a elección, y cómo agregar filtros propios.
metadata:
  type: reference
---

Solo si usas RTK (`rtk hook claude` en el PreToolUse de `~/.claude/settings.json`), que comprime la salida de los
comandos antes de que entre al contexto.

**How to apply:**
- **Cobertura:** el matcher que instala RTK es `Bash`. En Windows, donde casi todo corre en la herramienta PowerShell,
  ampliarlo a `Bash|PowerShell`. Las herramientas Read y Grep de Claude no pasan por RTK.
- **Telemetría:** revisar `rtk telemetry status`; si los repos son de clientes, `rtk telemetry disable`.
- **Qué cubre:** `rtk rewrite "<comando>"` dice si un comando se filtra (vacío = no). El hook solo ve el comando de
  arriba: lo que corre dentro de un script no se filtra.
- **Filtros propios:** en el `filters.toml` global de RTK (`%APPDATA%\rtk\` en Windows). Regex en comillas simples de
  TOML y `match_command` empezando con `^`. RTK no carga el archivo hasta `rtk trust --yes`, y hay que repetirlo cada vez
  que se edita. `rtk verify` no corre las pruebas de filtros de usuario: probar con un ejecutable falso en el PATH.
- **Límites:** grep se corta en 200 resultados y 25 por archivo, y un `diff` se comprime casi entero. Si falta detalle:
  `rtk proxy <comando>`.
