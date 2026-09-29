# Instalar, migrar o actualizar el arnés (instrucciones para Claude)

Este archivo lo sigue Claude cuando el usuario pega el prompt de instalación del README. Si eres Claude: guía al
usuario paso a paso, en español y en palabras simples. El usuario sabe de computación pero puede ser nuevo en Claude:
explica lo propio de Claude (memoria, hooks, permisos, compactar) en una o dos líneas cuando aparezca.

**Reglas mientras instalas:**
- Pregunta con opciones (AskUserQuestion), cada una con pros y contras en simple. Un paso a la vez.
- Nunca pidas contraseñas, tokens ni llaves en el chat. Los inicios de sesión (`gh auth login`, OneDrive) los hace el
  usuario en su terminal o en la app; tú le dices qué escribir y esperas.
- Antes de crear el repo en GitHub, de instalar programas o de hacer push, di qué vas a hacer y espera su sí.
- Al terminar cada paso, di en una línea qué quedó hecho.

## 0. ¿Qué toca?

Detecta el sistema (Windows, Mac o Linux) y revisa `~/.claude/memoria-claude`:

| Situación | Qué hacer |
|---|---|
| No existe | **A. Instalación nueva** |
| Existe y no tiene `VERSION` o no tiene el remoto `plantilla` (`git -C ~/.claude/memoria-claude remote -v`) | **B. Migrar una copia vieja** (creada antes con "Use this template"; no se actualizaba) |
| Existe con `VERSION` | **C. Actualizar** |

En los comandos de abajo, `python` es `python3` en Mac y Linux.

## A. Instalación nueva

1. **Programas.** Revisa `git --version`, `python --version` (3.8 o más) y `gh --version`. Instala lo que falte, con su
   permiso:
   - Windows: `winget install --id Git.Git -e`, `winget install --id Python.Python.3.12 -e`,
     `winget install --id GitHub.cli -e` (después, abrir una terminal nueva).
   - Mac: `xcode-select --install` (trae git y Python) y `brew install gh` (si no tiene Homebrew, https://brew.sh).
   - Linux: `sudo apt install git python3 gh` (o el gestor de su distribución).
2. **GitHub.** Si `gh auth status` falla, que él corra `gh auth login` en su terminal (GitHub.com, HTTPS, navegador).
   Si no tiene cuenta, que la cree en https://github.com/signup.
3. **Su repo privado de memoria.** Con su sí:
   `gh repo create memoria-claude --private --template yolovany/memoria-claude-plantilla` y
   `gh repo clone memoria-claude ~/.claude/memoria-claude`.
4. **Perfil.** Pregunta en una ronda: a qué se dedica, qué sabe (lenguajes, herramientas), qué va a hacer con Claude y
   cómo quiere que le expliques. Escríbelo en 3 a 6 líneas en la sección "Sobre mí" de su `CLAUDE.md`.
5. **Preferencias.** Muestra las preferencias de `compartidas/` (sección "Preferencias" del índice) y los plugins
   caveman (respuestas más cortas, menos tokens) y ponytail (código mínimo, sin sobreingeniería), una línea de qué hace
   cada una. Vienen todas encendidas; lo que desmarque va a `apagadas.txt` (el nombre de la nota, o `plugin:<nombre>`).
   Pregunta también el idioma y si quiere agregar algo suyo a "Preferencias de trabajo" de `CLAUDE.md`.
6. **Dónde están sus repos.** Por omisión `C:\Github` en Windows y `~/Github` en Mac y Linux. Si usa otra carpeta, se
   pasa con `--raiz`.
7. **Secretos (opcional).** Explica: contraseñas y llaves nunca van en claro en git; el arnés las sube cifradas con age
   y solo su llave privada las abre. Si quiere:
   - Instala age (Windows `winget install --id FiloSottile.age -e`, Mac `brew install age`, Linux `apt install age`).
   - `age-keygen -o <llave>`: la llave privada va en OneDrive → Almacén personal (Windows:
     `%OneDrive%\Almacén personal\memoria-claude-llave.txt`) o en `~/.config/memoria-claude/llave-age.txt` con respaldo
     en su gestor de contraseñas. Si no es la ruta de Windows, se define la variable `MEMORIA_LLAVE`.
   - `age-keygen -y <llave> > ~/.claude/memoria-claude/secretos/destinatario.txt` (la pública, esa sí va en git).
8. **Permisos.** Explica los modos de permisos del app (el selector junto al cuadro de texto): preguntar siempre,
   aceptar ediciones, plan y sin preguntar. Sin preguntar es cómodo pero Claude ejecuta todo sin detenerse: **no
   usarlo** con producción, datos de clientes ni para borrar cosas; se vuelve al modo que pregunta con el mismo
   selector. Ofrece bloquear lo muy peligroso: si acepta, agrega a `~/.claude/settings.json` en `permissions.deny`:
   `"Bash(rm -rf:*)"`, `"Bash(git push --force:*)"`, `"Bash(git reset --hard:*)"`.
9. **Instalar.** `python ~/.claude/memoria-claude/arnes.py instalar [--raiz <carpeta>]`. Enlaza la memoria de cada
   repo, agrega hooks, barra de estado y plugins a `~/.claude/settings.json` sin pisar lo suyo, instala los atajos y el
   candado de secretos.
10. **Revisar.** `python ~/.claude/memoria-claude/arnes.py doctor`: todo en ✓ (la llave solo si hizo el paso 7).
11. **Subir.** En `~/.claude/memoria-claude`: `git add -A`, `git commit -m "memoria: primera configuración"`,
    `git push`.
12. **Cierre.** Dile que reinicie Claude, que abra un chat en uno de sus repos y que lea `GUIA.md` (resúmela en 5
    líneas: cómo pedir, permisos, `/retomar`, `/cerrar-tema`, `/memorias`, "actualiza el arnés").

## B. Migrar una copia vieja

Su repo salió de la plantilla antes de que se pudiera actualizar. Se conserva todo lo suyo.

1. **Estado.** `git status` en `~/.claude/memoria-claude`: si hay cambios, commit primero. Lista lo que es suyo:
   carpetas de proyectos, notas propias en `compartidas/`, cambios en `CLAUDE.md`.
2. **Punto de regreso.** `git tag antes-de-migrar` (local; con `git reset --hard antes-de-migrar` se vuelve).
3. **Conectar con la plantilla.**
   `git remote add plantilla https://github.com/yolovany/memoria-claude-plantilla.git` y
   `git fetch plantilla --tags`. Trae el instalador nuevo: `git show <última vX.Y.Z>:arnes.py > arnes.py`.
4. **Vista previa.** `python arnes.py actualizar`: detecta de qué versión salió su copia, muestra las novedades y qué
   se agrega, actualiza o quita. Explícaselo en simple y pide su sí.
5. **Aplicar.** `python arnes.py actualizar --aplicar`. Los archivos que él editó no se tocan: para cada uno, muestra la
   diferencia con la versión nueva (`git diff --no-index <archivo> <copia de la versión nueva>`) y pregunta si conserva
   la suya o toma la nueva (`--forzar <archivo>`).
6. **Su `CLAUDE.md`.** Las reglas de la memoria ahora viven en `REGLAS.md`. Si su `CLAUDE.md` todavía tiene "Cómo se
   guarda la memoria" y "Al compactar", propón reemplazar esas secciones por `@REGLAS.md` y dejar sus preferencias;
   muestra el cambio antes de hacerlo. Si no tiene "Sobre mí", haz el paso A4.
7. **Preferencias.** Haz el paso A5 (las que apague van a `apagadas.txt`).
8. **Instalar.** `python arnes.py instalar`. Avísale antes: quita de sus repos la línea `@~/.claude/memoria-claude/...`
   que ponía la versión vieja (en `CLAUDE.local.md` se borra; en un `CLAUDE.md` versionado queda como texto, con un
   commit en ese repo). Ya no hace falta: el índice lo carga la memoria automática de Claude.
9. **Revisar y subir.** `python arnes.py doctor`, commit y push. Dile que reinicie Claude.

## C. Actualizar

Sigue el atajo `/actualizar-arnes` (`skills/actualizar-arnes/SKILL.md`).
