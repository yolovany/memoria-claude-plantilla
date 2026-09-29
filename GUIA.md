# Primeros pasos con Claude

Para quien ya sabe de computación y empieza con Claude Code. Lo básico para sacarle provecho sin sustos ni gastar de
más.

## Cómo pedir

- **Contexto, objetivo y cuándo está terminado:** "En el repo X, la página de pagos tarda 8 s. Quiero que cargue en
  menos de 2 s sin cambiar el diseño. Terminado = medido en mi equipo".
- **Una cosa a la vez.** Si el tema cambia, chat nuevo o `/clear`.
- **Tareas grandes: primero el plan.** Pide "hazme un plan y no cambies nada todavía", o usa el modo plan. Corriges el
  plan antes de que escriba código.
- **Claude pregunta con opciones.** Si ninguna te convence, dilo ("ninguna, explica más") y vuelve a preguntar.

## Permisos

El selector junto al cuadro de texto define cuánto hace Claude sin preguntarte:

| Modo | Qué hace | Cuándo |
|---|---|---|
| Preguntar | Pide permiso para cada comando y edición | Al empezar, y con cualquier cosa delicada |
| Aceptar ediciones | Edita archivos solo; pregunta los comandos | Trabajo normal en un repo con git |
| Plan | Solo lee y propone | Antes de un cambio grande |
| Sin preguntar | Hace todo sin detenerse | Solo en pruebas, con git limpio y sin producción |

**Precaución con "sin preguntar":** Claude puede borrar, instalar o subir cosas sin avisar. Nunca lo uses con
servidores de producción, datos de clientes o para limpiar archivos. Si algo se ve raro, cambia el selector a
"preguntar" y dile "detente". El arnés trae la regla de que en producción solo lee sin tu orden, pero una regla no es
un candado: el modo sí.

## Memoria

- Claude no recuerda nada entre chats: lo que "sabe" al abrir está en esta memoria (`~/.claude/memoria-claude`).
- Guarda solo lo importante (correcciones, decisiones, datos del entorno) y te avisa en una línea. Si guardó algo mal,
  díselo y lo corrige.
- `/memorias`: qué recuerda y de dónde, y una revisión del arnés.
- Todo es texto en tu repo privado: lo puedes leer y editar en GitHub.

## Contexto, compactar y cortes

- La barra de abajo muestra el modelo, el **% de contexto** usado y el **% del límite de 5 horas** de tu cuenta.
- Con el contexto arriba de ~70 %, conviene compactar (`/compact`) en una pausa natural. Claude lleva un bloque
  **EN CURSO** en la nota del proyecto para retomar sin perder el hilo.
- Si se acaba el límite o cambias de cuenta, abre un chat en la misma carpeta: Claude detecta la sesión cortada y la
  retoma. A mano: `/retomar`.

## Modelos y costo

- El modelo más capaz para diseño, diagnóstico y lo delicado; el más rápido para lo mecánico (correr, comparar,
  resumir). Claude te sugiere el cambio antes de empezar; cambiarlo no borra la conversación.
- Lo que más gasta: conversaciones largas, leer archivos grandes completos y pedir "revisa todo". Pide cosas concretas.
- `/context` muestra qué ocupa el contexto; `/memorias` dice cuántos tokens carga la memoria en cada chat.

## Deshacer

- Tu red de seguridad es git: Claude hace un commit por cada pieza terminada. `git log` para ver, `git revert` para
  deshacer un commit.
- Dentro del chat, Esc dos veces permite volver a un punto anterior de la conversación y de los archivos.

## Seguridad

- Nunca pegues contraseñas ni llaves en el chat. Van en un `.env` fuera de git o en `secretos/` (cifrado).
- El candado de secretos frena un commit de la memoria si ve una contraseña o un token.
- Para probar pagos, envíos y demás, usa las llaves de prueba del proveedor.

## Atajos y frases útiles

| Escribe | Qué pasa |
|---|---|
| `/retomar` | Retoma una sesión cortada o de otra cuenta |
| `/cerrar-tema` | Memoria al día, commits, archivo de la sesión y memorias nuevas |
| `/memorias` | Qué recuerda Claude, revisión del arnés y tokens |
| "actualiza el arnés" | Trae la versión nueva de la plantilla sin tocar lo tuyo |
| "propón esto a la plantilla" | Manda una mejora general al dueño de la plantilla |
