# Reglas de la memoria

Cómo se guarda y se carga la memoria de este repositorio (`~/.claude/memoria-claude`). Son del arnés: iguales para
todos los que lo usan y se actualizan con él. Las preferencias de cada quien van en su `CLAUDE.md`.

## Cómo se guarda la memoria

- **De un proyecto:** en su carpeta de este repositorio (`<repo>/`). La carpeta de memoria de Claude de cada proyecto
  (`~/.claude/projects/<ruta-del-repo>/memory`) es un enlace a ella, así que la memoria automática ya escribe aquí.
  También los repos públicos tienen su carpeta aquí.
- **Lo técnico de un repo privado propio** (compilar, liberar, arneses y scripts, trampas del código, patrones de UI)
  viaja con su código: el detalle en `docs/` del repo y una línea con el enlace en su `CLAUDE.md`, en el mismo commit
  que el cambio. El estado, las decisiones y las preferencias se quedan aquí. En públicos, repos ajenos y los que no
  deben llevar rastro de Claude, todo se queda aquí.
- **Carga:** el índice (`MEMORY.md`) del repo en que se abre el chat lo carga la memoria automática de Claude por el
  enlace (también en los clones de `alias.txt`). Si Claude toca un archivo de otro repo de la raíz (un directorio
  adicional), el hook `indice-adicional.sh` le pasa su índice la primera vez. El arnés no escribe nada dentro de los
  repos. Solo índices: las notas se leen antes de tocar el repo; sus reglas valen igual. Si dos memorias se
  contradicen, manda la más reciente y se corrige la vieja.
- **Al día:** al cerrar cada tema (el mismo momento del commit) se actualiza la memoria del proyecto que cambió. Si
  al abrir aparece "memoria atrasada", se pone al día antes de usarla.
- **Formato:** la nota principal de un proyecto es su estado vigente, con la fecha al inicio: se reescribe, no se le
  agregan bloques por fecha al final. La historia vive en la bitácora del repo y en git.
- **Preferencias y memorias que sirven a varios proyectos:** en `compartidas/`, con su línea en
  `compartidas/MEMORY.md`. Una sola copia: no duplicarlas en carpetas de proyecto.
- **Lo sensible** (credenciales, datos personales) nunca va en claro: va en un archivo fuera de git (listado en
  `.gitignore` si está dentro del repo) y se agrega su ruta a `secretos/archivos.txt`; el hook de cierre lo sube
  cifrado con age. La llave privada nunca va en el repo (dónde vive: `README.md`).
- **Archivo de sesiones:** `<Proyecto>/archivo/INDICE.md` lista las sesiones anteriores (fecha, tema, archivos) y
  `<Proyecto>/archivo/<fecha>-<sesión>/` guarda sus scripts y notas. No se carga solo: consultarlo cuando un tema ya
  se trabajó antes, antes de rehacer un script. Las sesiones sobre la memoria misma van en `compartidas/archivo/`.
- **Al cerrar cada sesión:**
  1. Copiar los scripts y notas útiles de la carpeta de trabajo (scratchpad) a `<Proyecto>/archivo/<fecha>-<sesión>/`
     (solo texto propio: sin archivos de más de 1 MB ni código de terceros como wordpress, node_modules o vendor;
     contraseñas tapadas con `***`) y agregar su fila, arriba, en el `INDICE.md` del proyecto, con un tema que diga de
     qué trató la sesión.
  2. El commit y el push los hace solo el hook de cierre (`hooks/sesion-fin.sh`); el pull, el de inicio. Si al abrir
     aparece un aviso de memoria-claude (secreto detectado, sin red, choque con otro equipo), atenderlo primero.
- **Proyecto nuevo:** se conecta solo al abrirlo en Claude (hook de inicio): crea su carpeta y su conexión. Su
  memoria carga desde la segunda sesión.
- **Otro equipo:** ver `README.md`.

## Al compactar (instrucciones para el resumen)

Al resumir la conversación para compactarla, conservar siempre: la ruta de la nota principal del proyecto y que su
bloque **EN CURSO** manda; el paso en que íbamos y el siguiente, exacto; las preguntas abiertas (de Claude y del
usuario) y lo que el usuario decidió en esta sesión, con su número de decisión; los commits y dónde quedó cada cambio
(clon/pruebas, producción, solo docs, día de salida); lo que espera de terceros; los chats paralelos con su id
`local_…` y lo que llevan; y lo que el usuario pidió no hacer todavía (publicar, desplegar). Lo demás puede ir
resumido.
