#!/usr/bin/env bash
# Busca datos personales en la plantilla: correos (salvo noreply y ejemplos), IPs, rutas de carpetas de usuario y
# autores de commits con correo real. Lo corre GitHub Actions en cada cambio; quien publica revisa además su lista
# privada de nombres (clientes, empresas) antes de subir.
set -u
cd "$(dirname "$0")/.."
hallado=0
revisa() {
    local r
    r=$(git ls-files -co --exclude-standard | grep -v '^LICENSE$' | tr '\n' '\0' | xargs -0 grep -nIE "$1" 2>/dev/null | grep -vE "$2")
    if [ -n "$r" ]; then echo "$3:"; echo "$r"; hallado=1; fi
}
revisa '[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}' 'noreply|example\.(com|org)|privacidad\.sh' 'correos'
revisa '(^|[^0-9.])([0-9]{1,3}\.){3}[0-9]{1,3}([^0-9.]|$)' '127\.0\.0\.1|0\.0\.0\.0|privacidad\.sh' 'IPs'
revisa '([A-Za-z]:\\+Users\\+|/Users/|/home/)[A-Za-z]' '<usuario>|/home/usuario|/Users/usuario|privacidad\.sh' 'rutas de usuario'
autores=$(git log --format='%ae %ce' 2>/dev/null | tr ' ' '\n' | sort -u | grep -v 'noreply' || true)
if [ -n "$autores" ]; then echo "commits con correo real: $autores"; hallado=1; fi
[ "$hallado" = 0 ] && echo "sin datos personales"
exit "$hallado"
