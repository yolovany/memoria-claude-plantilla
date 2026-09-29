---
name: memorias
description: Muestra qué recuerda Claude en esta sesión y de dónde (índices cargados, notas, tokens) y revisa el arnés. Úsala cuando el usuario pregunte "qué recuerdas", "qué memorias tienes" o pida revisar el arnés.
---

# Qué recuerdo y de dónde

1. Resume en pocas líneas lo que tienes cargado: preferencias (`~/.claude/memoria-claude/CLAUDE.md`), reglas
   (`REGLAS.md`), el índice de `compartidas/` y el del proyecto de esta sesión (memoria automática). Si `$ARGUMENTS`
   nombra un tema o repo, busca en esos índices y en las notas qué hay de eso.
2. Corre `python ~/.claude/memoria-claude/arnes.py doctor` (`python3` en Mac y Linux) y muestra lo que salga mal
   con su arreglo, y los tokens que se cargan al abrir cada chat.
3. Ofrece en opción múltiple: abrir una nota, corregir o borrar una memoria que esté mal, o compactar un índice que
   pase del presupuesto (una línea corta por nota, el detalle en la nota).
