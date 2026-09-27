#!/usr/bin/env bash
# Reindexa en codebase-memory-mcp cada proyecto cuyo commit cambió desde su último índice. El vigilante de la herramienta
# solo sigue el repo principal de la sesión; esto cubre memoria-claude y los directorios adicionales al cerrar cambios:
#   - hook PostToolUse (Bash|PowerShell): solo si el comando hizo "git commit"; corre en segundo plano.
#   - sesion-fin.sh, tras el commit automático de la memoria: `indices.sh cierre` (en primer plano).
# El CLI no informa el commit de cada índice: el último indexado se anota en ~/.claude/indices-commits.txt.
CBM=$(command -v codebase-memory-mcp || ls "$HOME"/AppData/Local/Programs/codebase-memory-mcp/codebase-memory-mcp.exe 2>/dev/null | head -1)
[ -x "$CBM" ] || exit 0
ESTADO="$HOME/.claude/indices-commits.txt"

reindexar() {
    touch "$ESTADO"
    "$CBM" cli list_projects 2>/dev/null | grep -o '"root_path":"[^"]*"' | cut -d'"' -f4 | while read -r raiz; do
        sha=$(git -C "$raiz" rev-parse HEAD 2>/dev/null) || continue
        grep -qxF "$raiz $sha" "$ESTADO" && continue
        "$CBM" cli index_repository "{\"repo_path\":\"$raiz\"}" >/dev/null 2>&1 || continue
        # ponytail: sin candado; dos corridas a la vez solo repiten trabajo
        { grep -vF "$raiz " "$ESTADO"; echo "$raiz $sha"; } > "$ESTADO.tmp" && mv "$ESTADO.tmp" "$ESTADO"
    done
}

if [ "$1" = cierre ]; then
    reindexar
else
    grep -q 'git[^"]*commit' || exit 0
    (reindexar) >/dev/null 2>&1 &
fi
exit 0
