#!/usr/bin/env bash
# SessionEnd: respalda la conversación (comprimida) en OneDrive, cifra los secretos y sube memoria-claude, salvo que lo
# nuevo traiga un secreto. Los avisos quedan en ~/.claude/memoria-claude-avisos.log y los muestra la siguiente sesión.
. "$(dirname "$0")/comun.sh"
NUBE=$(u "${MEMORIA_NUBE:-${OneDrive:-$HOME/OneDrive}}")
ennube=1; [ -d "$NUBE" ] || { NUBE="$HOME"; ennube=""; }        # sin OneDrive: solo local, en ~/respaldos
NUBE="$NUBE/respaldos"
RESPALDO="${MEMORIA_RESPALDO:-$NUBE/claude-conversaciones}"
SECRETOS="${MEMORIA_SECRETOS:-$HOME/.claude/memoria-secretos.txt}"
entrada=$(cat)

# 1. conversación de esta sesión -> <OneDrive>/respaldos/claude-conversaciones/<proyecto>/*.jsonl.xz (nunca git).
#    Comprimida con xz porque la subida es lenta: ~4 veces menos (el doble que gzip); gzip si el equipo no trae xz
#    (Mac). Las carpetas de respaldos-extra.txt (una ruta por línea) se copian a la par.
t=$(campo transcript_path); [ -n "$t" ] && t=$(u "$t")
if [ -f "$t" ]; then
    d="$RESPALDO/$(basename "$(dirname "$t")")"
    if command -v xz >/dev/null 2>&1; then
        mkdir -p "$d" && xz -6 -T0 -c "$t" > "$d/$(basename "$t").xz" || avisa "no se pudo respaldar la conversación $t"
    else
        mkdir -p "$d" && gzip -c "$t" > "$d/$(basename "$t").gz" || avisa "no se pudo respaldar la conversación $t"
    fi
fi
if [ -n "$ennube" ] && [ -s "$C/respaldos-extra.txt" ]; then
    grep '^[^#[:space:]]' "$C/respaldos-extra.txt" | tr -d '\r' | while IFS= read -r x; do
        x=$(u "$x"); [ -d "$x" ] || continue
        cp -ru "$x" "$NUBE/" 2>/dev/null || rsync -a "$x" "$NUBE/" 2>/dev/null   # el cp de Mac no tiene -u
    done
fi

# 2. secretos: cada archivo de secretos/archivos.txt (ruta relativa a $HOME) se cifra con la llave pública cuando
#    cambia; la privada no hace falta aquí (vive fuera del repo y solo sirve para descifrar).
AGE=$(command -v age || ls "$HOME"/AppData/Local/Microsoft/WinGet/Packages/FiloSottile.age*/age/age.exe 2>/dev/null | head -1)   # recién instalado, el PATH del app aún no lo trae
if [ -s "$C/secretos/archivos.txt" ] && [ -x "$AGE" ]; then
    while IFS= read -r r; do
        r=${r%$'\r'}; [ -n "$r" ] || continue
        s="$HOME/$r"; n=${r//\//__}; x="$C/secretos/${n#.}.age"   # sin punto inicial: no queda oculto
        if [ -f "$s" ] && { [ ! -f "$x" ] || [ "$s" -nt "$x" ]; }; then
            "$AGE" -R "$C/secretos/destinatario.txt" -o "$x" "$s" || avisa "no se pudo cifrar $r"
        fi
    done < "$C/secretos/archivos.txt"
fi

# 3. memoria-claude: commit y push con candado de secretos
cd "$C" 2>/dev/null || exit 0
if [ -n "$(git status --porcelain)" ]; then
    for i in 1 2 3; do git add -A 2>/dev/null && break; sleep 2; done    # otra sesión puede tener el índice tomado
    secretos=$(git diff --cached --no-color -U0 | grep '^+[^+]' | grep -E -i -e \
        '(password|pwd)[[:space:]]*[=:][[:space:]]*[^*[:space:];"'"'"'<]|ghp_[A-Za-z0-9]{20}|github_pat_[A-Za-z0-9_]{20}|sk-[A-Za-z0-9]{20}|BEGIN [A-Z ]*PRIVATE KEY')
    # La opción de contraseña de sqlcmd (P mayúscula) se busca aparte, sin -i: con -i, "mkdir -p" daba falso positivo.
    secretos="$secretos$(git diff --cached --no-color -U0 | grep '^+[^+]' | grep -E -e '(^|[[:space:]])-P[[:space:]]+[^*[:space:]]')"
    # contraseñas conocidas, una por línea, en un archivo local que nunca se sube
    [ -s "$SECRETOS" ] && secretos="$secretos$(git diff --cached --no-color -U0 | grep '^+[^+]' | grep -F -i -f "$SECRETOS")"
    if [ -n "$secretos" ]; then
        git reset -q
        avisa "memoria-claude NO se subió: lo nuevo parece traer una contraseña o token. Tápalo con *** y sube a mano."
        exit 0
    fi
    git commit -q -m "memoria: cierre de sesión $(date '+%Y-%m-%d %H:%M')" || exit 0
fi
# 4. índices de codebase-memory-mcp de lo que tenga commit nuevo; al salir, para no retrasar el push
trap 'bash "$C/hooks/indices.sh" cierre' EXIT
[ -z "$(git log '@{u}..' --oneline 2>/dev/null)" ] && exit 0    # nada pendiente de subir (incluye commits de un cierre sin red)
if ! git fetch -q 2>/dev/null; then
    avisa "memoria-claude: sin red al cerrar; el commit quedó local y se sube en el siguiente cierre"
    exit 0
fi
if ! git rebase -q '@{u}' >/dev/null 2>&1; then
    git rebase --abort >/dev/null 2>&1
    avisa "memoria-claude: choque con cambios de otro equipo; el commit quedó local. Resolver con: git -C ~/.claude/memoria-claude pull --rebase"
    exit 0
fi
git push -q 2>/dev/null || avisa "memoria-claude: no se pudo subir; el commit quedó local y se reintenta en el siguiente cierre"
exit 0
