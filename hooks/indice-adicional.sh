#!/usr/bin/env bash
# PostToolUse (Read, Edit, Write, Grep, Glob…): la primera vez que Claude toca un archivo de un repo de la raíz que no
# es el de la sesión (un directorio adicional), le pasa el índice de su memoria. El del repo principal ya lo carga la
# memoria automática de Claude. Lo ya pasado se anota por sesión en la carpeta temporal (compactar.sh lo borra).
. "$(dirname "$0")/comun.sh"
entrada=$(cat)
f=$(campo file_path); [ -n "$f" ] || f=$(campo notebook_path); [ -n "$f" ] || f=$(campo path); [ -n "$f" ] || exit 0
f=$(u "$f")
case "$f" in "$RAIZ"/*) ;; *) exit 0 ;; esac
r=${f#"$RAIZ"/}; r=${r%%/*}
marca="${TMPDIR:-/tmp}/memoria-claude-$(campo session_id)"
grep -qxF "$r" "$marca" 2>/dev/null && exit 0
printf '%s\n' "$r" >> "$marca"
p=$(proyecto "$r")
top=$(git -C "$(u "$(campo cwd)")" rev-parse --show-toplevel 2>/dev/null)
[ -n "$top" ] && [ "$(proyecto "$(basename "$(u "$top")")")" = "$p" ] && exit 0   # es el repo principal
[ -s "$C/$p/MEMORY.md" ] || exit 0
ctx="Índice de memoria del repo adicional $r (~/.claude/memoria-claude/$p/MEMORY.md). Lee las notas que apliquen antes de cambiarlo:
$(cat "$C/$p/MEMORY.md")"
printf '{"hookSpecificOutput": {"hookEventName": "PostToolUse", "additionalContext": "%s"}}\n' "$(esc "$ctx")"
exit 0
