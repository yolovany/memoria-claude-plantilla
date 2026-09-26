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

## Requisitos

- Claude Code (app de escritorio o CLI), [Git para Windows](https://git-scm.com/download/win) (trae Git Bash) y
  [GitHub CLI](https://cli.github.com/) con sesión: `gh auth login`.
- OneDrive con sesión iniciada.
- Opcional: los plugins caveman y ponytail (vienen en `config/settings-memoria.json`) y codebase-memory-mcp.

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
| `hooks/` | `sesion-inicio.sh`, `sesion-fin.sh` y `pre-commit.sh` (candado de secretos) |
| `enlazar.ps1` | Deja un equipo listo: clona, enlaza, conecta, aprueba, configura y descifra |
| `repos.txt` | De dónde clonar cada repo; lo mantiene `enlazar.ps1` |
| `alias.txt`, `solo-local.txt`, `respaldos-extra.txt` | Ajustes: clones extra, repos sin rastro, carpetas a respaldar |
| `config/settings-memoria.json` | Hooks, variables y plugins que se fusionan en `~/.claude/settings.json` |
| `secretos/` | Archivos cifrados con age, su lista (`archivos.txt`) y la llave pública (`destinatario.txt`) |
