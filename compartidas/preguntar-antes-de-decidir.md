---
name: preguntar-antes-de-decidir
description: Ante una decisión de diseño o alcance, preguntar con opciones en vez de decidir por cuenta propia.
metadata:
  type: feedback
---

Cuando haya algo que decidir (comportamiento, diseño, modelo de datos, alcance, qué se guarda o cómo se muestra),
preguntar al usuario en vez de elegir y avisar después. Aunque una opción sea claramente mejor: se recomienda, pero
decide el usuario.

**Why:** el usuario conoce la operación real; lo que parece razonable desde el código muchas veces no corresponde a
cómo se trabaja, y decidir por él genera trabajo que luego hay que revertir.

**How to apply:**
- Toda pregunta con opciones seleccionables (AskUserQuestion), incluso las de sí o no. El análisis y la
  recomendación van en el texto; la pregunta, en el selector. También las que siguen abiertas de un mensaje a
  otro: nunca como lista suelta al final del texto.
- Cada opción con pros, contras e implicaciones en palabras simples: qué gana, qué cuesta (dinero, trabajo, riesgo)
  y qué deja pendiente. Marcar la recomendada.
- Si la respuesta pide aclaración ("no entiendo", "vuelve a preguntar"), explicar mejor y volver a preguntar.
- Antes de preguntar, verificar la premisa en el código o en los datos: muchas preguntas seguidas suelen indicar que
  se está resolviendo el problema equivocado.
- No aplica a detalles mecánicos (nombres de variables, orden de las ediciones).
