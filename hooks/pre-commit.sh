#!/usr/bin/env bash
# pre-commit de memoria-claude (lo instala arnes.py): rechaza cualquier commit, manual o del hook de cierre, cuyas
# líneas nuevas traigan una contraseña o token. Las contraseñas conocidas van en ~/.claude/memoria-secretos.txt.
SECRETOS="${MEMORIA_SECRETOS:-$HOME/.claude/memoria-secretos.txt}"
nuevas=$(git diff --cached --no-color -U0 | grep '^+[^+]')
hallado=$(printf '%s\n' "$nuevas" | grep -E -i -e \
    '(password|pwd)[[:space:]]*[=:][[:space:]]*[^*[:space:];"'"'"'<]|ghp_[A-Za-z0-9]{20}|github_pat_[A-Za-z0-9_]{20}|sk-[A-Za-z0-9]{20}|BEGIN [A-Z ]*PRIVATE KEY')
# La opción de contraseña de sqlcmd (P mayúscula) se busca aparte, sin -i: con -i, "mkdir -p" daba falso positivo.
hallado="$hallado$(printf '%s\n' "$nuevas" | grep -E -e '(^|[[:space:]])-P[[:space:]]+[^*[:space:]]')"
[ -s "$SECRETOS" ] && hallado="$hallado$(printf '%s\n' "$nuevas" | grep -F -i -f "$SECRETOS")"
if [ -n "$hallado" ]; then
    echo "memoria-claude: commit rechazado, lo nuevo parece traer una contraseña o token. Tápalo con *** y reintenta." >&2
    exit 1
fi
exit 0
