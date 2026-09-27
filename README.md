# memoria-claude (plantilla)

Plantilla para que Claude Code recuerde tu forma de trabajar y el estado de cada uno de tus repos, versionado en
GitHub. Si pierdes el equipo o cambias de PC, recuperas todo con dos comandos. Pensada para Windows con los repos
en `C:\Github`.

## Qué hace

- **Una carpeta de memoria por repo** en tu `memoria-claude` privado. La memoria automática de Claude escribe ahí
  (por un enlace) y el hook de cierre la sube a GitHub en cada sesión.
- **Cada repo privado tuyo** lleva un `CLAUDE.md` versionado que importa el índice de su memoria. Los públicos,
  los ajenos y los de `solo-local.txt` usan un `CLAUDE.local.md` que no se versiona.
- **Lo técnico de cada repo** (compilar, liberar, trampas del código) vive en su `docs/`, enlazado desde su
  `CLAUDE.md`. El estado y las decisiones van en la memoria.
- **Secretos cifrados** con [age](https://github.com/FiloSottile/age). La llave privada va en OneDrive (Almacén
  personal).
- **Conversaciones respaldadas** comprimidas en `OneDrive\respaldos`.
- **Repos nuevos** se conectan solos la primera vez que los abres en Claude.
- **Preferencias de partida** en `CLAUDE.md` y `compartidas/`: ajústalas o bórralas a tu gusto.

## Cómo funciona (para empezar)

**Claude no recuerda nada entre chats.** Cada chat nuevo empieza en blanco; lo único que "sabe" al arrancar es lo
que lee de ciertos archivos. Esta plantilla organiza esos archivos para que siempre lea lo importante y nunca se
pierda.

**1. `CLAUDE.md`: instrucciones que Claude lee al abrir cada chat.** Hay tres niveles:

| Archivo | Cuándo se lee | Para qué |
|---|---|---|
| `~/.claude/CLAUDE.md` (tu carpeta de usuario) | En todos los chats | Aquí solo tiene una línea que carga esta memoria |
| `C:\Github\<repo>\CLAUDE.md` | En los chats de ese repo | Reglas técnicas del repo y la línea que carga su memoria |
| `C:\Github\<repo>\CLAUDE.local.md` | Igual, pero no se sube a GitHub | Lo mismo, para repos públicos o ajenos |

Una línea que empieza con `@` (por ejemplo `@~/.claude/memoria-claude/mi-repo/MEMORY.md`) **mete el contenido de
ese otro archivo** como si estuviera escrito ahí.

**2. La memoria: notas cortas en Markdown**, una por tema, dentro de este repositorio:

```
memoria-claude/                  (tu repo privado, clonado en ~/.claude/memoria-claude)
├─ CLAUDE.md                     tus preferencias de trabajo y las reglas de la memoria  ← se lee siempre
├─ compartidas/                  lo que sirve para todos tus repos
│  ├─ MEMORY.md                  índice: una línea por nota                               ← se lee siempre
│  └─ respuestas-cortas.md …     las notas
└─ mi-repo/                      una carpeta por cada repo
   ├─ MEMORY.md                  índice de ese repo                                       ← se lee en sus chats
   ├─ estado-mi-repo.md          qué está hecho, qué falta, qué está sin probar (con fecha)
   └─ decision-x.md …            decisiones, correcciones tuyas, datos del entorno
```

En cada chat Claude lee **solo los índices** (unas líneas); abre una nota completa cuando el tema la necesita. Así
la memoria puede crecer sin llenar cada chat.

**3. La memoria automática.** Claude Code guarda por su cuenta notas en `~/.claude/projects/<repo>/memory/`. Aquí
esa carpeta es un **enlace** a `memoria-claude/<repo>/`: lo que Claude anota cae directo en este repo.

**4. Qué va en cada lugar:**
- **Estado, decisiones, correcciones y preferencias** → la memoria (este repo).
- **Lo técnico del código** (cómo compilar, cómo liberar, trampas conocidas) → `docs/` del propio repo, con una
  línea en su `CLAUDE.md`. Así viaja con el código y se corrige en el mismo commit.
- **Contraseñas y datos personales** → nunca en claro: un archivo fuera de git que se sube cifrado (`secretos/`).

**5. Los hooks** (scripts que Claude Code corre solo):
- **Al abrir un chat:** trae los cambios de la memoria hechos en otro equipo, avisa si la memoria de un repo quedó
  atrasada frente a su código y conecta los repos nuevos.
- **Al cerrar un chat:** respalda la conversación en OneDrive, cifra los secretos y sube la memoria a GitHub.

**6. Qué le puedes decir a Claude:**
- No hace falta pedir "guárdalo": guarda solo lo importante y te avisa en una línea ("Guardé en memoria: …").
- "¿Qué recuerdas de X?" o "¿qué índices de memoria ves?" para revisar lo que sabe.
- "Pon al día la memoria de este repo" cuando cambió mucho.
- Si algo guardado está mal, díselo: corrige la nota. También puedes leer y editar las notas en GitHub.

## Requisitos

- Claude Code (app de escritorio o CLI), [Git para Windows](https://git-scm.com/download/win) (trae Git Bash) y
  [GitHub CLI](https://cli.github.com/) con sesión: `gh auth login`.
- OneDrive con sesión iniciada.
- Opcional: los plugins caveman y ponytail (vienen en `config/settings-memoria.json`, en nivel "full" y con su indicador en
  la barra de estado; el nivel se cambia en `env` de ese archivo) y codebase-memory-mcp.

## Instalación (una vez por cuenta)

1. **Crea tu copia privada:** en GitHub, botón **Use this template → Create a new repository**, con el nombre
   `memoria-claude` y visibilidad **Private**. O desde consola:

   ```powershell
   gh repo create memoria-claude --private --template yolovany/memoria-claude-plantilla
   ```

2. **Clónala donde la busca Claude:**

   ```powershell
   gh repo clone memoria-claude "$HOME\.claude\memoria-claude"
   ```

3. **Crea tu llave de age.** Abre OneDrive → **Almacén personal** y desbloquéalo; luego:

   ```powershell
   winget install --id FiloSottile.age -e
   $bin = (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\Packages" -Filter age-keygen.exe -Recurse | Select-Object -First 1).DirectoryName
   $llave = Join-Path $env:OneDrive 'Almacén personal\memoria-claude-llave.txt'
   & "$bin\age-keygen.exe" -o $llave
   & "$bin\age-keygen.exe" -y $llave | Set-Content "$HOME\.claude\memoria-claude\secretos\destinatario.txt" -Encoding ascii
   ```

   Si tu OneDrive no tiene Almacén personal, guarda la llave donde quieras y define la variable de entorno
   `MEMORIA_LLAVE` con su ruta.

4. **Corre el instalador:**

   ```powershell
   powershell -ExecutionPolicy Bypass -File "$HOME\.claude\memoria-claude\enlazar.ps1"
   ```

   Agrega los hooks, variables y plugins a `~/.claude/settings.json` sin pisar lo que ya tengas, instala el
   candado de secretos y hace que `~/.claude/CLAUDE.md` cargue la memoria. Tus repos se conectan después, uno por
   uno, la primera vez que abres cada uno en Claude (paso 6). Si tus repos no están en `C:\Github`, agrega
   `-Raiz D:\ruta` y define la variable de entorno `MEMORIA_RAIZ` con esa ruta en formato Git Bash (`/d/ruta`).

5. **Súbelo:**

   ```powershell
   cd "$HOME\.claude\memoria-claude"; git add -A; git commit -m "memoria: primera configuración"; git push
   ```

6. **Reinicia Claude y abre un chat en cada repo que uses.** En ese primer chat el hook crea su carpeta de memoria,
   su conexión y lo aprueba (verás el aviso "repo nuevo … conectado"). Desde el segundo chat en ese repo, pregúntale
   "¿qué índices de memoria ves cargados?": debe mostrar el contenido de `compartidas/MEMORY.md` y el del índice de
   ese repo, no solo la línea `@...`.

## Uso diario

No hay que hacer nada: Claude guarda solo lo importante (correcciones, decisiones, datos del entorno y estado), y
los hooks traen lo de otros equipos al abrir y suben todo al cerrar.

- **Repos privados sin rastro de Claude** (sin CLAUDE.md versionado): agrega la carpeta a `solo-local.txt` antes de
  abrirlos.
- **Secretos:** guarda el archivo fuera de git y agrega su ruta (relativa a tu carpeta de usuario) a
  `secretos/archivos.txt`; el hook de cierre lo sube cifrado.
- **Clones extra del mismo repo** (una carpeta por versión, por ejemplo): agrégalos a `alias.txt` como
  `<carpeta>=<proyecto>`.
- **Carpetas locales que también quieras en OneDrive:** una ruta por línea en `respaldos-extra.txt`.

## Equipo nuevo o perdido

Instala los requisitos, inicia sesión en `gh` y OneDrive, desbloquea Almacén personal y corre:

```powershell
gh repo clone memoria-claude "$HOME\.claude\memoria-claude"
powershell -ExecutionPolicy Bypass -File "$HOME\.claude\memoria-claude\enlazar.ps1"
```

Clona tus repos (según `repos.txt`), enlaza, conecta, aprueba, configura y descifra los secretos.

## Estructura

| Ruta | Qué es |
|---|---|
| `CLAUDE.md` | Preferencias de trabajo y reglas de la memoria; se carga en todas las sesiones |
| `compartidas/` | Memorias que sirven a varios proyectos, con su índice `MEMORY.md` |
| `<repo>/` | Memoria de un repositorio: `MEMORY.md` (índice) y una nota por tema; la crea el hook al abrir el repo |
| `hooks/` | `sesion-inicio.sh`, `sesion-fin.sh`, `pre-commit.sh` (candado de secretos) y `barra-estado.sh` (nivel de caveman y ponytail en la barra de estado) |
| `enlazar.ps1` | Deja un equipo listo: clona, enlaza, conecta, aprueba, configura y descifra |
| `repos.txt` | De dónde clonar cada repo; lo mantiene `enlazar.ps1` |
| `alias.txt`, `solo-local.txt`, `respaldos-extra.txt` | Ajustes: clones extra, repos sin rastro, carpetas a respaldar |
| `config/settings-memoria.json` | Hooks, variables y plugins que se fusionan en `~/.claude/settings.json` |
| `secretos/` | Archivos cifrados con age, su lista (`archivos.txt`) y la llave pública (`destinatario.txt`) |
