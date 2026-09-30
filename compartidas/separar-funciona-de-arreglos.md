---
name: separar-funciona-de-arreglos
description: Al reportar una prueba, separar lo que funciona de los arreglos y decir por qué arreglar algo que ya funciona.
metadata:
  type: feedback
---

Al reportar el resultado de una prueba, separar en dos bloques lo que **funciona** y los **arreglos** que se proponen,
y decir en una línea por qué hace falta arreglar algo que ya funciona: el problema aparece después o en otro caso, o
Claude lo esquivó improvisando y otra persona (u otro Claude) podría no hacerlo.

**Why:** "la prueba pasó" seguido de una lista de arreglos confunde: el usuario no sabe si algo falla o no, ni por qué
debería gastar en cambiar lo que ya sirve.

**How to apply:** en el reporte y en la pregunta de opciones, primero "funciona: …", luego "arreglos: …" con su porqué.
Relacionado: [[respuestas-cortas]], [[preguntar-antes-de-decidir]].
