#!/usr/bin/env bash
# SessionStart: trae lo que otra PC haya subido a memoria-claude y muestra los avisos que dejó el cierre anterior.
# Nunca bloquea la sesión: ante cualquier problema avisa y sale.
C="${MEMORIA_CLAUDE:-$HOME/.claude/memoria-claude}"
AVISOS="${MEMORIA_AVISOS:-$HOME/.claude/memoria-claude-avisos.log}"
export GIT_TERMINAL_PROMPT=0
entrada=$(cat)

msg=""
if cd "$C" 2>/dev/null; then
    if ! git fetch -q 2>/dev/null; then
        msg="memoria-claude: sin red al abrir; no se trajo lo de otras PC."
    elif ! git rebase -q --autostash '@{u}' >/dev/null 2>&1; then
        git rebase --abort >/dev/null 2>&1
        msg="memoria-claude: choque con cambios de otra PC. Resolver con: git -C ~/.claude/memoria-claude pull --rebase"
    fi
fi
if [ -s "$AVISOS" ]; then
    msg="${msg:+$msg | }$(tail -n 3 "$AVISOS" | tr '\n' ' ')"
    : > "$AVISOS"
fi

# Memoria atrasada: su repo tiene commits de más de un día después del último cambio de su memoria.
RAIZ="${MEMORIA_RAIZ:-/c/Github}"
atrasadas=""
for d in "$C"/*/; do
    p=$(basename "$d")
    case "$p" in compartidas|hooks) continue ;; esac
    [ -s "$d/MEMORY.md" ] && [ -e "$RAIZ/$p/.git" ] || continue
    repo=$(git -C "$RAIZ/$p" log -1 --format=%ct 2>/dev/null)
    mem=$(find "$d" -maxdepth 1 -name '*.md' -printf '%T@\n' 2>/dev/null | sort -n | tail -1)
    mem=${mem%.*}
    [ -n "$repo" ] && [ -n "$mem" ] && [ "$repo" -gt $((mem + 86400)) ] && atrasadas="$atrasadas $p"
done
ctx=""
[ -n "$atrasadas" ] && ctx="memoria-claude: memoria atrasada respecto a su repo (commits posteriores a su último cambio):$atrasadas. Ponerla al día (estado vigente) antes de usarla."

# Repo de C:\Github abierto sin memoria (nuevo) o sin aprobar en este equipo: enlazar.ps1 -Solo le crea la conexión
# (CLAUDE.md versionado si es privado y propio, CLAUDE.local.md si no) y aprueba su importación. Su memoria carga
# desde la siguiente sesión.
cwd=$(printf '%s' "$entrada" | sed -n 's/.*"cwd"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' | sed 's/\\\\/\//g')
top=$(git -C "$(cygpath -u "$cwd" 2>/dev/null)" rev-parse --show-toplevel 2>/dev/null); [ -n "$top" ] && top=$(cygpath -u "$top")
p=$(basename "$top")
if [ -n "$top" ] && [ "$(dirname "$top")" = "$(cygpath -u "$(cygpath -w "$RAIZ")")" ] && ! grep -q "^$p=" "$C/alias.txt" 2>/dev/null; then
    nuevo=""
    if [ ! -d "$C/$p" ]; then
        mkdir --parents "$C/$p" && printf '# Memory Index\n' > "$C/$p/MEMORY.md" && nuevo=1
    fi
    if [ -n "$nuevo" ] || ! grep -qixF "$(cygpath -w "$top")" "$HOME/.claude/memoria-claude-aprobados.txt" 2>/dev/null; then
        powershell.exe -NoProfile -ExecutionPolicy Bypass -File "$(cygpath -w "$C/enlazar.ps1")" -Raiz "$(cygpath -w "$RAIZ")" -Solo "$p" > /dev/null 2>&1
        [ -n "$nuevo" ] && ctx="${ctx:+$ctx | }memoria-claude: repo nuevo $p conectado a su memoria (carpeta $p/ creada). Su índice carga desde la siguiente sesión."
    fi
fi

esc() { printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'; }
msg="${msg:+$msg${ctx:+ | }}$ctx"
if [ -n "$ctx" ]; then
    printf '{"systemMessage": "%s", "hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "%s"}}\n' "$(esc "$msg")" "$(esc "$ctx")"
elif [ -n "$msg" ]; then
    printf '{"systemMessage": "%s"}\n' "$(esc "$msg")"
fi
exit 0
