#!/usr/bin/env bash
# Compactación sin perder el hilo (compartidas/preparar-compactacion.md).
#   antes   (PreCompact, manual o automática): copia los scripts y notas del scratchpad de la sesión al archivo del
#           proyecto (<proyecto>/archivo/<fecha>-<sesión>/, solo texto propio de menos de 1 MB, sin .env ni llaves),
#           le pone su fila en INDICE.md si no la tiene, y respalda la conversación y sube memoria-claude con
#           sesion-fin.sh (mismo candado de secretos). Nunca bloquea la compactación.
#   despues (SessionStart "compact"): le recuerda a Claude leer el bloque EN CURSO del proyecto y retomar desde ahí.
# El bloque EN CURSO no lo escribe este script: Claude lo mantiene al día al cerrar cada paso.
. "$(dirname "$0")/comun.sh"
entrada=$(cat)

# Proyecto de la sesión: la carpeta de su repo (o su alias) en memoria-claude.
cwd=$(campo cwd); [ -n "$cwd" ] && cwd=$(u "$cwd")
top=$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null); [ -n "$top" ] && top=$(u "$top")
p=$(basename "${top:-$cwd}")
a=$(grep -m1 "^$p=" "$C/alias.txt" 2>/dev/null | cut -d= -f2 | tr -d '\r'); [ -n "$a" ] && p=$a
[ -d "$C/$p" ] || p=""

if [ "$1" = despues ]; then
    rm -f "${TMPDIR:-/tmp}/memoria-claude-$(campo session_id)"   # el resumen perdió los índices de repos adicionales
    nota=""
    [ -n "$p" ] && nota=$(sed -n 's/^- \[[^]]*\](\([^)]*\.md\)).*/\1/p' "$C/$p/MEMORY.md" | grep -v '^archivo/' | head -1)
    donde=${nota:+~/.claude/memoria-claude/$p/$nota}
    ctx="Se compactó la conversación. Antes de responder: lee ${donde:-la nota principal del proyecto en ~/.claude/memoria-claude/<proyecto>/} (su bloque EN CURSO y el estado vigente), revisa git status de los repos que menciona y retoma desde sus siguientes pasos y preguntas abiertas sin volver a preguntar lo ya decidido. Si el EN CURSO no cubre lo último del resumen, complétalo en cuanto puedas."
    printf '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "%s"}}\n' "$(esc "$ctx")"
    exit 0
fi

# antes: archivar el scratchpad de esta sesión.
sid=$(campo session_id); t=$(campo transcript_path)
if [ -n "$p" ] && [ -n "$sid" ] && [ -n "$t" ]; then
    slug=$(basename "$(dirname "$t")")
    # Carpeta temporal de Claude: %LOCALAPPDATA%\Temp en Windows, $TMPDIR en Mac, /tmp en Linux.
    s=""
    for tmp in "$(u "${LOCALAPPDATA:-$HOME/AppData/Local}")/Temp" "${TMPDIR%/}" /tmp; do
        [ -d "$tmp/claude/$slug/$sid/scratchpad" ] && { s="$tmp/claude/$slug/$sid/scratchpad"; break; }
    done
    corto=${sid:0:8}
    dest=$(ls -d "$C/$p/archivo/"*-"$corto" 2>/dev/null | head -1)
    [ -n "$dest" ] || dest="$C/$p/archivo/$(date +%F)-$corto"
    if [ -n "$s" ]; then
        copiados=$(cd "$s" && find . -type f -size -1024k \
            \( -name '*.py' -o -name '*.sh' -o -name '*.ps1' -o -name '*.js' -o -name '*.mjs' -o -name '*.md' \
               -o -name '*.txt' -o -name '*.sql' -o -name '*.php' -o -name '*.json' -o -name '*.csv' \) \
            ! -path '*/node_modules/*' ! -path '*/vendor/*' ! -name '.env*' ! -iname '*secret*' ! -iname '*clave*' \
            ! -iname '*token*' ! -iname '*password*' -print | sed 's|^\./||')
        # Clones de repos dentro del scratchpad (una plantilla, un repo de pruebas) no son notas de la sesión.
        for g in $(cd "$s" && find . -mindepth 2 -name .git -prune | sed 's|/\.git$||; s|^\./||'); do
            copiados=$(printf '%s\n' "$copiados" | grep -v "^$g/")
        done
        if [ -n "$copiados" ]; then
            printf '%s\n' "$copiados" | while IFS= read -r f; do
                mkdir -p "$dest/$(dirname "$f")" && cp "$s/$f" "$dest/$f"
            done
            i="$C/$p/archivo/INDICE.md"
            if [ -f "$i" ] && ! grep -q "\[$corto\]" "$i"; then
                fila="| $(date +%F) | [$corto]($(basename "$dest")/) | (archivado al compactar: poner el tema) | $(printf '%s' "$copiados" | head -12 | tr '\n' ',' | sed 's/,$//; s/,/, /g') |"
                awk -v f="$fila" '{print} /^\|---/ && !h {print f; h=1}' "$i" > "$i.tmp" && mv "$i.tmp" "$i"
            fi
        fi
    fi
fi
# Respaldo de la conversación, secretos cifrados y subida de memoria-claude, como al cerrar la sesión.
printf '%s' "$entrada" | bash "$C/hooks/sesion-fin.sh" >/dev/null 2>&1
exit 0
