# Cómo funciona el arnés

## Qué se carga en cada chat

| Archivo | Cuándo | Para qué |
|---|---|---|
| `~/.claude/CLAUDE.md` | Siempre | Una línea que importa `~/.claude/memoria-claude/CLAUDE.md` |
| `CLAUDE.md` (tuyo) | Siempre | Sobre ti y tus preferencias; importa `REGLAS.md` y el índice de `compartidas/` |
| `REGLAS.md` | Siempre | Cómo se guarda y se carga la memoria, y qué conservar al compactar |
| `compartidas/MEMORY.md` | Siempre | Índice de preferencias, prácticas y tus notas generales |
| `<repo>/MEMORY.md` | En los chats de ese repo | Índice de la memoria del repo; lo carga la memoria automática de Claude |
| Índice de un repo adicional | Al tocar su primer archivo | Lo pasa `hooks/indice-adicional.sh` |

Solo se cargan índices (una línea por nota). Claude abre una nota cuando el tema la necesita. Presupuesto: 4 KB por
índice; el hook de inicio avisa una vez al día si alguno se pasa, y `/memorias` dice cuántos tokens carga cada chat.

## Memoria automática y enlaces

Claude Code guarda lo que aprende de un repo en `~/.claude/projects/<ruta del repo>/memory/`. `arnes.py` convierte esa
carpeta en un enlace a `~/.claude/memoria-claude/<repo>/` (junction en Windows, symlink en Mac y Linux): lo que Claude
anota cae en tu repo privado y el hook de cierre lo sube. Un repo nuevo se enlaza solo la primera vez que abres un chat
en él; su memoria carga desde el segundo chat.

## Hooks

| Hook | Cuándo | Qué hace |
|---|---|---|
| `sesion-inicio.sh` | Al abrir un chat | Trae lo de otros equipos, avisa de memorias atrasadas, enlaza repos nuevos, pasa las sesiones cortadas por límite de uso y, una vez al día, índices grandes y versión nueva |
| `sesion-fin.sh` | Al cerrar un chat | Respalda la conversación comprimida (OneDrive si hay), cifra secretos, hace commit y push con candado de secretos |
| `compactar.sh` | Antes y después de compactar | Archiva el scratchpad y sube; después, recuerda retomar desde EN CURSO |
| `indice-adicional.sh` | Al leer o editar un archivo | Pasa el índice de un repo adicional la primera vez |
| `indices.sh` | Tras `git commit` y al cerrar | Reindexa codebase-memory-mcp (solo si lo usas) |
| `barra-estado.sh` | Siempre | Modelo, % de contexto, % del límite de 5 horas, caveman y ponytail |
| `pre-commit.sh` | En cada commit de la memoria | Rechaza commits con contraseñas o tokens |

## Capas y actualización

`arnes.txt` es la lista de lo que pertenece al arnés. `python arnes.py actualizar`:

1. Trae la plantilla (remoto `plantilla`) y su última versión (`vX.Y.Z`).
2. Compara cada archivo del arnés con la versión de la que salió tu copia (`VERSION`; en copias viejas, la que más
   archivos comparte):
   - si no lo editaste, lo reemplaza;
   - si lo editaste, no lo toca y lo lista para que decidas (`--forzar <archivo>` toma el nuevo);
   - si lo borraste, no lo vuelve a traer;
   - lo que salió del arnés se quita si no lo editaste.
3. `apagadas.txt` manda: esas notas y plugins no llegan.
4. Rehace el índice de `compartidas/`: las líneas del arnés de la versión nueva y después las tuyas (sección
   "Propias").
5. Fusiona `config/settings-memoria.json` en `~/.claude/settings.json` sin pisar lo tuyo, enlaza atajos nuevos,
   escribe `VERSION` y hace el commit.

Sin `--aplicar` solo muestra las novedades y el plan.

## Tus archivos

`CLAUDE.md`, `apagadas.txt`, `alias.txt` (clones extra que usan la memoria de otro repo), `respaldos-extra.txt`
(carpetas a copiar a OneDrive al cerrar), `repos.txt` (de dónde clonar tus repos en un equipo nuevo; lo mantiene
`arnes.py`), `secretos/archivos.txt` y `secretos/destinatario.txt`, tus carpetas de proyectos y tus notas.

## Equipo nuevo

`gh repo clone memoria-claude ~/.claude/memoria-claude` y `python ~/.claude/memoria-claude/arnes.py instalar`: clona
tus repos, enlaza, configura y descifra los secretos (con tu llave privada en su lugar).

## Para quien mantiene la plantilla

La plantilla se publica desde el repo de memoria del dueño con una lista blanca: el código del arnés se copia tal cual y
las notas generales se redactan de nuevo, sin datos personales ni de clientes. Cada versión lleva etiqueta `vX.Y.Z` y
su entrada en `NOVEDADES.md`; GitHub Actions prueba los scripts en Windows, Mac y Linux y busca datos personales antes
de aceptar cambios.
