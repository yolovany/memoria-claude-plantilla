# Memoria de Claude

Repositorio privado `memoria-claude` del dueño de esta cuenta de GitHub, clonado en `~/.claude/memoria-claude`. Lo
carga `~/.claude/CLAUDE.md` en todas las sesiones de este equipo.

## Preferencias de trabajo

(Punto de partida: ajustarlas a tu gusto.)

- Respuestas cortas y precisas, en español. Explicar solo si lo pido.
- No decidir por cuenta propia: ante cualquier decisión de diseño o alcance, preguntar con opciones; si mi
  respuesta pide aclaración, explicar mejor y volver a preguntar.
- Cerrar un paso antes del siguiente: no proponer lo que sigue mientras haya preguntas tuyas sin responder.
- En pruebas, desbloquear en vez de frenar: crear lo que falte y seguir (confirmar que es ambiente de pruebas).
- Al cerrar cada paso de pruebas, decir el porcentaje de avance hacia la liberación.
- Sesiones paralelas: hallazgos o ajustes que afecten a otra sesión relacionada se le mandan por SendMessage;
  coordinar los recursos compartidos.
- Nombres de empresas o clientes: nunca en material público; sí en documentación interna.
- Memoria sin pedirla: correcciones, decisiones, datos del entorno y estado se guardan en el momento, sin esperar
  a que lo pida, avisando en una línea al final (`compartidas/guardar-memoria-sin-pedirlo.md`).

## Cómo se guarda la memoria

- **De un proyecto:** en su carpeta de este repositorio (`<repo>/`). La carpeta de memoria de Claude de cada
  proyecto (`~/.claude/projects/C--Github-<repo>/memory`) es un enlace a ella, así que la memoria automática ya
  escribe aquí. También los repos públicos tienen su carpeta aquí.
- **Lo técnico de un repo privado propio** (compilar, liberar, arneses y scripts, trampas del código, patrones de UI)
  viaja con su código: el detalle en `docs/` del repo y una línea con el enlace en su `CLAUDE.md`, en el mismo commit
  que el cambio. El estado, las decisiones y las preferencias se quedan aquí. En públicos, repos ajenos y los de
  `solo-local.txt`, todo se queda aquí.
- **Carga:** cada repo importa el `MEMORY.md` de su carpeta: los privados propios desde su `CLAUDE.md` versionado;
  públicos, ajenos, los de `solo-local.txt` y alias (`alias.txt`) desde su `CLAUDE.local.md`, que nunca se
  versiona. Lo pone `enlazar.ps1`; con `CLAUDE_CODE_ADDITIONAL_DIRECTORIES_CLAUDE_MD=1` en `settings.json` también
  carga en los repos adicionales de la sesión. Solo índices: las notas se leen antes de tocar el repo; sus reglas
  valen igual. Si dos memorias se contradicen, manda la más reciente y se corrige la vieja.
- **Al día:** al cerrar cada tema (el mismo momento del commit) se actualiza la memoria del proyecto que cambió. Si
  al abrir aparece "memoria atrasada", se pone al día antes de usarla.
- **Formato:** la nota principal de un proyecto es su estado vigente, con la fecha al inicio: se reescribe, no se le
  agregan bloques por fecha al final. La historia vive en la bitácora del repo y en git.
- **Preferencias y memorias que sirven a varios proyectos:** en `compartidas/`, con su línea en
  `compartidas/MEMORY.md`. Una sola copia: no duplicarlas en carpetas de proyecto.
- **Lo sensible** (credenciales, datos personales) nunca va en claro: va en un archivo fuera de git (listado en
  `.gitignore` si está dentro del repo) y se agrega su ruta a `secretos/archivos.txt`; el hook de cierre lo sube
  cifrado con age. La llave privada vive en `OneDrive\Almacén personal`.
- **Archivo de sesiones:** `<Proyecto>/archivo/INDICE.md` lista las sesiones anteriores (fecha, tema, archivos) y
  `<Proyecto>/archivo/<fecha>-<sesión>/` guarda sus scripts y notas. No se carga solo: consultarlo cuando un tema ya
  se trabajó antes, antes de rehacer un script. Las sesiones sobre la memoria misma van en `compartidas/archivo/`.
- **Al cerrar cada sesión:**
  1. Copiar los scripts y notas útiles de la carpeta de trabajo (scratchpad) a `<Proyecto>/archivo/<fecha>-<sesión>/`
     (solo texto propio: sin archivos de más de 1 MB ni código de terceros; contraseñas tapadas con `***`) y agregar
     su fila, arriba, en el `INDICE.md` del proyecto, con un tema que diga de qué trató la sesión.
  2. El commit y el push los hace solo el hook de cierre (`hooks/sesion-fin.sh`); el pull, el de inicio. Si al abrir
     aparece un aviso de memoria-claude (secreto detectado, sin red, choque con otro equipo), atenderlo primero.
- **Proyecto nuevo:** se conecta solo al abrirlo en Claude (hook de inicio): crea su carpeta y su conexión. Su
  memoria carga desde la segunda sesión.
- **Otro equipo:** ver `README.md`.

## Memorias compartidas

@compartidas/MEMORY.md
