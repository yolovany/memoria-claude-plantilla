#!/usr/bin/env bash
# Lo común de los hooks, para que corran igual en Windows (Git Bash), Mac y Linux. Se carga con: . "$(dirname "$0")/comun.sh"
C="${MEMORIA_CLAUDE:-$HOME/.claude/memoria-claude}"
AVISOS="${MEMORIA_AVISOS:-$HOME/.claude/memoria-claude-avisos.log}"
export GIT_TERMINAL_PROMPT=0

# u: ruta del sistema -> ruta de bash (C:\Github -> /c/Github en Git Bash; en Mac y Linux, igual). w: al revés.
u() { if command -v cygpath >/dev/null 2>&1; then cygpath -u "$1"; else printf '%s' "$1"; fi; }
w() { if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi; }

# Carpeta de los repos: MEMORIA_RAIZ (la pone arnes.py si no es la de siempre), o C:\Github en Windows y ~/Github.
if [ -n "$MEMORIA_RAIZ" ]; then RAIZ=$(u "$MEMORIA_RAIZ")
elif command -v cygpath >/dev/null 2>&1; then RAIZ=/c/Github
else RAIZ="$HOME/Github"; fi

# campo NOMBRE: valor de texto de un campo del JSON que Claude Code le pasa al hook (en $entrada), con \\ -> /. Toma
# la primera aparición: las que siguen pueden venir del contenido de un archivo leído o escrito.
campo() { printf '%s' "$entrada" | grep -o "\"$1\"[[:space:]]*:[[:space:]]*\"[^\"]*\"" | head -1 | sed 's/^[^:]*:[[:space:]]*"//; s/"$//; s/\\\\/\//g'; }

# py: Python 3. En Windows "python3" puede ser el atajo de la tienda, que no corre nada: se prueba cada nombre.
py() {
    if [ -z "$PY" ]; then
        for c in python3 python py; do
            "$c" -c 'import sys; sys.exit(sys.version_info < (3, 8))' >/dev/null 2>&1 && { PY=$c; break; }
        done
    fi
    [ -n "$PY" ] && "$PY" "$@"
}

avisa() { printf '%s %s\n' "$(date '+%Y-%m-%d %H:%M')" "$1" >> "$AVISOS"; }
# esc: texto (aun de varias líneas) -> contenido de una cadena JSON.
esc() { printf '%s' "$1" | tr -d '\r' | tr '\t' ' ' | sed 's/\\/\\\\/g; s/"/\\"/g' | awk 'NR > 1 { printf "\\n" } { printf "%s", $0 }'; }

# carpeta_claude RUTA: carpeta de ~/.claude/projects de un repo (lo que no es letra o número pasa a '-').
carpeta_claude() { printf '%s/.claude/projects/%s' "$HOME" "$(w "$1" | sed 's/[^a-zA-Z0-9]/-/g')"; }

# proyecto CARPETA: carpeta de memoria de un repo (la misma, o la de alias.txt).
proyecto() { a=$(grep -m1 "^$1=" "$C/alias.txt" 2>/dev/null | cut -d= -f2 | tr -d '\r'); printf '%s' "${a:-$1}"; }
