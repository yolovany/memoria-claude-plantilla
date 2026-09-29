#!/usr/bin/env bash
# Prueba de humo del arnés en una carpeta de usuario temporal: instalar, enlazar un repo nuevo, hooks, retomar,
# candado de secretos y actualizar (con un archivo editado y una nota apagada). La corre GitHub Actions en Windows, Mac
# y Linux; en local: bash .github/prueba.sh
set -euo pipefail
R=$(cd "$(dirname "$0")/.." && pwd)
T=$(cd "$(mktemp -d)" && pwd -P)   # ruta física (en Mac /var es un enlace a /private/var)
nat() { if command -v cygpath >/dev/null 2>&1; then cygpath -w "$1"; else printf '%s' "$1"; fi; }
for c in python3 python py; do "$c" -c 'import sys; sys.exit(sys.version_info < (3, 8))' 2>/dev/null && { PY=$c; break; }; done
export HOME="$T/home" USERPROFILE="$(nat "$T/home")" MEMORIA_LLAVE="$(nat "$T/sin-llave")" GIT_TERMINAL_PROMPT=0
export MEMORIA_RAIZ="$(nat "$T/Github")" MEMORIA_NUBE="$(nat "$T/nube")" PYTHONIOENCODING=utf-8
unset OneDrive || true
C="$HOME/.claude/memoria-claude"
mkdir -p "$HOME/.claude" "$T/Github" "$T/nube"
git config --global user.email prueba@example.com; git config --global user.name prueba
git config --global init.defaultBranch main; git config --global core.autocrlf false
falla() { echo "FALLA: $*" >&2; exit 1; }
ok() { echo "ok: $*"; }
json() { "$PY" -c 'import json,sys; json.load(sys.stdin)'; }

# Memoria: copia de este repo con un proyecto "demo", remoto origin local.
git init -q --bare "$T/origen.git"
mkdir -p "$C" && (cd "$R" && git ls-files -co --exclude-standard | tar cf - -T -) | (cd "$C" && tar xf -)
mkdir -p "$C/demo" && printf '# Memory Index\n- [Estado](estado.md) — prueba\n' > "$C/demo/MEMORY.md"
git -C "$C" init -q && git -C "$C" add -A && git -C "$C" commit -qm base && git -C "$C" remote add origin "$T/origen.git"
git -C "$C" push -qu origin main
for r in demo nuevo; do git init -q "$T/Github/$r" && git -C "$T/Github/$r" commit -q --allow-empty -m init; done

# 1. instalar
"$PY" "$C/arnes.py" instalar > "$T/instalar.txt"
[ -f "$HOME/.claude/settings.json" ] && json < "$HOME/.claude/settings.json" || falla "settings.json"
grep -q '@~/.claude/memoria-claude/CLAUDE.md' "$HOME/.claude/CLAUDE.md" || falla "import en ~/.claude/CLAUDE.md"
[ -f "$C/.git/hooks/pre-commit" ] || falla "candado de secretos"
[ -f "$HOME/.claude/skills/retomar/SKILL.md" ] || falla "atajos"
slug=$(nat "$T/Github/demo" | sed 's/[^a-zA-Z0-9]/-/g')
[ -f "$HOME/.claude/projects/$slug/memory/MEMORY.md" ] || falla "enlace de la memoria de demo"
ok "instalar"
[ -z "$("$PY" "$C/arnes.py" instalar | grep -v '^aviso' || true)" ] || falla "instalar no es idempotente"
ok "instalar dos veces no cambia nada"

# 2. hook de inicio en un repo nuevo: crea su carpeta y lo enlaza
printf '{"session_id":"s1","cwd":"%s"}' "$(nat "$T/Github/nuevo" | sed 's/\\/\\\\/g')" | bash "$C/hooks/sesion-inicio.sh" > "$T/inicio.json"
json < "$T/inicio.json" || falla "salida del hook de inicio"
[ -f "$C/nuevo/MEMORY.md" ] || falla "carpeta del repo nuevo"
ok "hook de inicio (repo nuevo)"

# 3. índice de un repo adicional: una vez, y nunca el del repo principal
e='{"session_id":"s2","cwd":"%s","tool_input":{"file_path":"%s"}}'
d=$(nat "$T/Github/demo" | sed 's/\\/\\\\/g'); n=$(nat "$T/Github/nuevo/x.txt" | sed 's/\\/\\\\/g')
printf "$e" "$d" "$n" | bash "$C/hooks/indice-adicional.sh" | json || falla "índice adicional"
[ -z "$(printf "$e" "$d" "$n" | bash "$C/hooks/indice-adicional.sh")" ] || falla "índice adicional repetido"
[ -z "$(printf "$e" "$d" "$d/y.txt" | bash "$C/hooks/indice-adicional.sh")" ] || falla "índice del repo principal"
ok "índice de repo adicional"

# 4. barra de estado y compactar
b=$(printf '%s' '{"model":{"display_name":"Opus"},"context_window":{"used_percentage":34,"current_usage":{"input_tokens":1}},"rate_limits":{"five_hour":{"used_percentage":62.5}}}' | bash "$C/hooks/barra-estado.sh")
case "$b" in "Opus ctx 34% 5h 62%"*) ok "barra: $b" ;; *) falla "barra: $b" ;; esac
printf '{"session_id":"s2","cwd":"%s"}' "$d" | bash "$C/hooks/compactar.sh" despues | json || falla "compactar despues"
ok "compactar"

# 5. retomar: sesión cortada por límite de uso en la misma carpeta
p="$HOME/.claude/projects/$slug"
printf '%s\n' '{"type":"user","message":{"content":"arregla X"}}' \
  '{"type":"assistant","message":{"content":[{"type":"text","text":"You have hit your limit"}]},"isApiErrorMessage":true,"error":"rate_limit"}' > "$p/cortada1.jsonl"
"$PY" "$C/arnes.py" revisar --cwd "$(nat "$T/Github/demo")" --sesion s3 | grep -q '^Retomar' || falla "retomar automático"
[ -z "$("$PY" "$C/arnes.py" revisar --cwd "$(nat "$T/Github/demo")" --sesion s4 | grep '^Retomar' || true)" ] || falla "retomar repetido"
ok "retomar"

# 6. hook de cierre: respalda la conversación y sube la memoria; el candado frena una contraseña
echo "- nota" >> "$C/demo/MEMORY.md"
printf '{"session_id":"cortada1","transcript_path":"%s"}' "$(nat "$p/cortada1.jsonl" | sed 's/\\/\\\\/g')" | bash "$C/hooks/sesion-fin.sh"
ls "$T/nube/respaldos/claude-conversaciones/$slug/" | grep -q cortada1 || falla "respaldo de la conversación"
git -C "$T/origen.git" log --oneline -1 | grep -q 'cierre de sesión' || falla "push de la memoria"
echo 'password = secreto123' > "$C/demo/fuga.md" && git -C "$C" add demo/fuga.md
git -C "$C" commit -qm fuga 2>/dev/null && falla "el candado dejó pasar una contraseña"
git -C "$C" reset -q && rm "$C/demo/fuga.md"
ok "cierre y candado de secretos"

# 7. doctor
"$PY" "$C/arnes.py" doctor > "$T/doctor.txt" || falla "doctor"
ok "doctor"

# 8. actualizar: versión nueva con una nota cambiada; el usuario editó otra y apagó una tercera
P2="$T/plantilla" && git clone -q "$R" "$P2"
v=$(cat "$C/VERSION"); git -C "$P2" tag -f "v$v" >/dev/null
echo "Línea nueva." >> "$P2/compartidas/respuestas-cortas.md"
echo "Cambio de la plantilla." >> "$P2/compartidas/preguntar-antes-de-decidir.md"
git -C "$P2" commit -qam "versión nueva" && git -C "$P2" tag v9.9.9
echo "Mi cambio." >> "$C/compartidas/preguntar-antes-de-decidir.md"
echo "trabajo-desatendido" >> "$C/apagadas.txt"
printf -- '---\nname: mia\n---\nmía\n' > "$C/compartidas/mia.md" && echo '- [Mía](mia.md)' >> "$C/compartidas/MEMORY.md"
git -C "$C" add -A && git -C "$C" commit -qm "cambios del usuario"
MEMORIA_PLANTILLA="$P2" "$PY" "$C/arnes.py" actualizar --aplicar > "$T/actualizar.txt"
grep -q 'Línea nueva.' "$C/compartidas/respuestas-cortas.md" || falla "no actualizó una nota sin editar"
grep -q 'Mi cambio.' "$C/compartidas/preguntar-antes-de-decidir.md" || falla "pisó una nota editada"
grep -q 'editado: .*preguntar-antes-de-decidir' "$T/actualizar.txt" || falla "no avisó de la nota editada"
[ ! -f "$C/compartidas/trabajo-desatendido.md" ] && ! grep -q 'trabajo-desatendido' "$C/compartidas/MEMORY.md" || falla "trajo una nota apagada"
grep -q '(mia.md)' "$C/compartidas/MEMORY.md" || falla "perdió una nota propia del índice"
[ "$(cat "$C/VERSION")" = 9.9.9 ] || falla "VERSION"
ok "actualizar"

rm -rf "$T"
echo "TODO BIEN"
