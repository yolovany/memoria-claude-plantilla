---
name: preguntar-antes-de-decidir
description: "Ante cualquier decisión de diseño o producto, preguntar siempre en vez de decidir por cuenta propia"
metadata: 
  type: feedback
---

Cuando aparezca algo que decidir —comportamiento, UX, modelo de datos, alcance, qué se
guarda o cómo se muestra— preguntar al usuario en vez de elegir por cuenta propia y
avisarle después. Aplica aunque haya una opción claramente mejor: se propone con la
recomendación, pero decide él.

**Why:** conoce la operación real (cuadrillas, empresas, campo) y ha corregido varias
veces suposiciones mías que parecían razonables desde el código pero no correspondían a
cómo trabajan. Decidir yo genera trabajo que luego hay que revertir.

**How to apply:** usar AskUserQuestion con las opciones y sus implicaciones concretas —
qué cambia en el código y qué cuesta— marcando la recomendada si la hay. No aplica a
decisiones puramente mecánicas de implementación (nombres de variables, cómo partir un
método, orden de los edits).

**Toda pregunta va por AskUserQuestion, sin excepción** (lo pidió explícitamente el
08/09/2026). Incluidas las que salen al final de una explicación y las que parecen de
sí o no: se convierten en opciones con sus implicaciones, en vez de dejarlas sueltas en
el texto. El análisis y la recomendación sí van en el texto; la pregunta, en el
selector.

**Pero antes de preguntar, verificar la premisa en el código.** Varias veces he abierto
rondas enteras de preguntas sobre un problema que no existía: supuse que una tabla
guardaba algo, o que un dato se depuraba, sin comprobarlo. Cuando se acumulan las
preguntas suele ser señal de que estoy resolviendo el problema equivocado — ahí toca
parar, releer lo que pidió literalmente y reanalizar, no seguir preguntando.

Desde el 2026-09-11 las preguntas van siempre con **opciones seleccionables** (AskUserQuestion), no en texto libre; el usuario responde mejor así y puede pedir «vuelve a preguntar» cuando una opción no le cuadra.
