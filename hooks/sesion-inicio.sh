#!/usr/bin/env bash
# SessionStart: trae lo que otro equipo haya subido a memoria-claude, muestra los avisos que dejó el cierre anterior,
# conecta el repo si es nuevo y le pasa a Claude lo que debe retomar (sesiones cortadas por límite de uso) y los avisos
# del día (índices grandes, versión nueva del arnés). Nunca bloquea la sesión: ante cualquier problema avisa y sale.
. "$(dirname "$0")/comun.sh"
entrada=$(cat)

msg=""
if cd "$C" 2>/dev/null; then
    if ! git fetch -q 2>/dev/null; then
        msg="memoria-claude: sin red al abrir; no se trajo lo de otros equipos."
    elif ! git rebase -q --autostash '@{u}' >/dev/null 2>&1; then
        git rebase --abort >/dev/null 2>&1
        msg="memoria-claude: choque con cambios de otro equipo. Resolver con: git -C ~/.claude/memoria-claude pull --rebase"
    fi
fi
if [ -s "$AVISOS" ]; then
    msg="${msg:+$msg | }$(tail -n 3 "$AVISOS" | tr '\n' ' ')"
    : > "$AVISOS"
fi

# Memoria atrasada: su repo tiene commits de más de un día después del último commit de su memoria.
atrasadas=""
for d in "$C"/*/; do
    p=$(basename "$d")
    case "$p" in compartidas|hooks|config|secretos|docs|plantillas|skills) continue ;; esac
    [ -s "$d/MEMORY.md" ] && [ -e "$RAIZ/$p/.git" ] || continue
    repo=$(git -C "$RAIZ/$p" log -1 --format=%ct 2>/dev/null)
    mem=$(git -C "$C" log -1 --format=%ct -- "$p/" 2>/dev/null)
    [ -n "$repo" ] && [ -n "$mem" ] && [ "$repo" -gt $((mem + 86400)) ] && atrasadas="$atrasadas $p"
done
ctx=""
[ -n "$atrasadas" ] && ctx="memoria-claude: memoria atrasada respecto a su repo (commits posteriores a su último cambio):$atrasadas. Ponerla al día (estado vigente) antes de usarla."

# Repo de la raíz sin carpeta de memoria (nuevo) o sin enlazar en este equipo: arnes.py conectar enlaza la carpeta de
# memoria automática de Claude con la suya en memoria-claude. Su índice carga desde la siguiente sesión.
cwd=$(campo cwd)
top=$(git -C "$(u "$cwd")" rev-parse --show-toplevel 2>/dev/null); [ -n "$top" ] && top=$(u "$top")
p=$(basename "$top")
if [ -n "$top" ] && [ "$(dirname "$top")" = "$RAIZ" ] && ! grep -q "^$p=" "$C/alias.txt" 2>/dev/null; then
    nuevo=""
    if [ ! -d "$C/$p" ]; then
        mkdir -p "$C/$p" && printf '# Memory Index\n' > "$C/$p/MEMORY.md" && nuevo=1
    fi
    if [ -n "$nuevo" ] || [ ! -e "$(carpeta_claude "$top")/memory/MEMORY.md" ]; then
        py "$(w "$C/arnes.py")" conectar "$p" --raiz "$(w "$RAIZ")" > /dev/null 2>&1
        [ -n "$nuevo" ] && ctx="${ctx:+$ctx | }memoria-claude: repo nuevo $p conectado a su memoria (carpeta $p/ creada). Su índice carga desde la siguiente sesión."
    fi
fi

# Sesiones cortadas por límite de uso en esta carpeta, índices grandes y versión nueva (arnes.py revisar).
extra=$(py "$(w "$C/arnes.py")" revisar --cwd "$cwd" --sesion "$(campo session_id)" 2>/dev/null)

msg="${msg:+$msg${ctx:+ | }}$ctx"   # el usuario ve los avisos cortos; el resumen de lo que se retoma es solo para Claude
case "$extra" in Retomar:*) msg="${msg:+$msg | }memoria-claude: hay una sesión cortada por límite de uso; Claude la retoma." ;; esac
case "$extra" in *"versión nueva del arnés"*) msg="${msg:+$msg | }memoria-claude: hay versión nueva del arnés; di \"actualiza el arnés\"." ;; esac
[ -n "$extra" ] && ctx="${ctx:+$ctx | }$extra"
if [ -n "$ctx" ]; then
    printf '{"systemMessage": "%s", "hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "%s"}}\n' "$(esc "$msg")" "$(esc "$ctx")"
elif [ -n "$msg" ]; then
    printf '{"systemMessage": "%s"}\n' "$(esc "$msg")"
fi
exit 0
