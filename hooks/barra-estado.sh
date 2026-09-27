#!/usr/bin/env bash
# Barra de estado de Claude Code: indicadores de caveman y ponytail con los scripts de cada plugin.
# La carpeta del plugin cambia con cada versión: se toma la más reciente instalada.
dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
partes=()
for p in caveman ponytail; do
  script=$(ls -td "$dir"/plugins/cache/$p/$p/*/hooks/$p-statusline.sh 2>/dev/null | head -1)
  [ -n "$script" ] && s=$(bash "$script") && [ -n "$s" ] && partes+=("$s")
done
printf '%s' "${partes[*]}"
