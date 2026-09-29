#!/usr/bin/env bash
# Barra de estado de Claude Code: modelo, % de contexto usado, % del límite de uso de 5 horas de la cuenta, y los
# indicadores de caveman y ponytail con los scripts de cada plugin (la carpeta del plugin cambia con cada versión: se
# toma la más reciente instalada).
entrada=$(cat | tr -d '\n')
modelo=$(printf '%s' "$entrada" | sed -n 's/.*"display_name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')
# Sin el objeto anidado current_usage, cada bloque queda sin llaves internas y basta [^}]*.
plano=$(printf '%s' "$entrada" | sed 's/"current_usage"[[:space:]]*:[[:space:]]*{[^}]*}//')
pct() { printf '%s' "$plano" | sed -n "s/.*\"$1\"[[:space:]]*:[[:space:]]*{[^}]*\"used_percentage\"[[:space:]]*:[[:space:]]*\([0-9]*\).*/\1/p"; }
ctx=$(pct context_window); lim=$(pct five_hour)
partes=()
[ -n "$modelo" ] && partes+=("$modelo")
[ -n "$ctx" ] && partes+=("ctx $ctx%")
[ -n "$lim" ] && partes+=("5h $lim%")
dir="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
for p in caveman ponytail; do
  script=$(ls -td "$dir"/plugins/cache/$p/$p/*/hooks/$p-statusline.sh 2>/dev/null | head -1)
  [ -n "$script" ] && s=$(bash "$script" < /dev/null) && [ -n "$s" ] && partes+=("$s")
done
printf '%s' "${partes[*]}"
