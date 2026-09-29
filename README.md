# memoria-claude (plantilla)

Un arnés para que Claude Code recuerde tu forma de trabajar y el estado de cada uno de tus repos, en un repo privado
tuyo en GitHub. Si cambias de equipo o de cuenta, retomas donde ibas. Funciona en Windows, Mac y Linux y se actualiza
sin tocar lo tuyo.

## Instalar (un prompt)

Necesitas Claude Code (app de escritorio o terminal) y una cuenta de GitHub. Abre un chat en cualquier carpeta y pega:

```text
Instala el arnés de memoria de Claude: descarga con curl https://raw.githubusercontent.com/yolovany/memoria-claude-plantilla/main/INSTALAR.md, léelo completo y síguelo conmigo paso a paso.
```

Claude revisa lo que falta (git, Python, GitHub CLI), crea tu repo privado desde esta plantilla, te pregunta quién eres
y qué preferencias quieres, y deja todo conectado. El mismo prompt sirve si ya tenías una copia de la plantilla que
no se actualizaba: la migra conservando tus memorias.

## Actualizar

Cuando hay versión nueva, Claude te avisa al abrir un chat. Di **"actualiza el arnés"**: te muestra las novedades,
aplica lo que no editaste y te pregunta por lo que sí. Tus memorias, tu `CLAUDE.md` y lo que apagaste no se tocan.

## Qué hace

- **Memoria por repo** en tu repo privado: lo que Claude aprende de cada proyecto (estado, decisiones, correcciones)
  se guarda solo y se sube a GitHub al cerrar cada chat.
- **Preferencias y prácticas** probadas en `compartidas/`: preguntar con opciones, respuestas cortas, commits
  ordenados, cuidado con producción… Las preferencias se apagan una por una.
- **Retomar sin perder el hilo:** si se acaba el límite de uso o cambias de cuenta, el chat nuevo retoma la sesión
  cortada. Antes de compactar, se archiva y se sube todo.
- **Barra de estado** con modelo, % de contexto y % del límite de 5 horas.
- **Atajos:** `/retomar`, `/cerrar-tema`, `/memorias`, `/actualizar-arnes`, `/proponer-mejora`.
- **Secretos cifrados** con [age](https://github.com/FiloSottile/age) y un candado que frena commits con contraseñas.
- **Pocos tokens:** solo se cargan índices cortos; las notas se leen cuando hacen falta. `/memorias` dice cuánto carga
  cada chat.

## Cómo funciona

| Capa | Dónde | ¿Se actualiza? |
|---|---|---|
| Arnés (hooks, `arnes.py`, reglas, atajos, documentación) | la lista de `arnes.txt` | Sí |
| Prácticas generales | `compartidas/` (sección "Prácticas") | Sí; se pueden apagar |
| Preferencias | `compartidas/` (sección "Preferencias") | Sí; se apagan en `apagadas.txt` |
| Según herramienta | `compartidas/` (sección "Según herramienta") | Sí; solo aplican si usas esa herramienta |
| Lo tuyo: `CLAUDE.md`, tus proyectos, tus notas | todo lo demás | Nunca |

Más detalle en [docs/como-funciona.md](docs/como-funciona.md). Para empezar con Claude: [GUIA.md](GUIA.md).

## Proponer mejoras

Si algo te sirvió y le serviría a todos, di **"propón esto a la plantilla"**: Claude redacta la versión general, sin
datos tuyos, y abre un issue aquí cuando lo apruebes.

## Licencia

MIT: úsala y modifícala libremente, sin garantía. Ver [LICENSE](LICENSE).
