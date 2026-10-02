#!/usr/bin/env bash
# UserPromptSubmit y PostToolUse: cuando el contexto llega al 80% de la ventana de compactación automática, le ordena a
# Claude poner al día el bloque EN CURSO antes de seguir (compartidas/preparar-compactacion.md). Una vez por ciclo: la
# marca se borra sola cuando el contexto vuelve a bajar del umbral (después de compactar).
# Ventana: CLAUDE_CODE_AUTO_COMPACT_WINDOW, o autoCompactWindow de ~/.claude/settings.json, o ~967K (la de Claude Code).
# Corre tras cada herramienta: sin subprocesos salvo una tubería (en Windows cada uno cuesta ~40 ms).
entrada=$(cat)
s='[[:space:]]*:[[:space:]]*'
[[ $entrada =~ \"transcript_path\"$s\"([^\"]*)\" ]] && t=${BASH_REMATCH[1]//\\\\//} || exit 0
[[ $entrada =~ \"session_id\"$s\"([^\"]*)\" ]] && sid=${BASH_REMATCH[1]} || exit 0
[[ $entrada =~ \"hook_event_name\"$s\"([^\"]*)\" ]] && evento=${BASH_REMATCH[1]} || evento=PostToolUse
[ -f "$t" ] || exit 0

ventana=$CLAUDE_CODE_AUTO_COMPACT_WINDOW
if [ -z "$ventana" ] && [ -f "$HOME/.claude/settings.json" ]; then
    conf=$(<"$HOME/.claude/settings.json")
    [[ $conf =~ \"autoCompactWindow\"$s\"?([0-9]+[kKmM]?) ]] && ventana=${BASH_REMATCH[1]}
fi
case "$ventana" in
    *[kK]) ventana=$(( ${ventana%?} * 1000 )) ;;
    *[mM]) ventana=$(( ${ventana%?} * 1000000 )) ;;
    ''|*[!0-9]*) ventana=967000 ;;
esac
umbral=$(( ventana * 8 / 10 ))

# Contexto de la última respuesta: entrada + caché leída + caché creada, del último renglón con usage.
l=$(tail -c 2000000 "$t" | grep '"cache_read_input_tokens"' | tail -1)
ctx=0
for k in input_tokens cache_read_input_tokens cache_creation_input_tokens; do
    [[ $l =~ \"$k\"$s([0-9]+) ]] && ctx=$(( ctx + BASH_REMATCH[1] ))
done

marca="${TMPDIR:-/tmp}/memoria-claude-ctx-$sid"
if [ "$ctx" -lt "$umbral" ]; then [ -f "$marca" ] && rm -f "$marca"; exit 0; fi
[ -f "$marca" ] && exit 0
: > "$marca"
. "$(dirname "$0")/comun.sh"
msg="Contexto en $(( ctx / 1000 ))K de $(( ventana / 1000 ))K: la compactación automática llega pronto. Antes de seguir con la tarea, pon al día ya el bloque EN CURSO de la nota principal del proyecto (paso actual y siguiente exacto, decisiones del usuario, commits y dónde quedó cada cambio, preguntas abiertas, chats paralelos y lo que pidió no hacer todavía). Después continúa donde ibas."
printf '{"hookSpecificOutput": {"hookEventName": "%s", "additionalContext": "%s"}}\n' "$evento" "$(esc "$msg")"
exit 0
