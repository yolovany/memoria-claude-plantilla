---
name: verificar-tras-edicion-detenida
description: Tras una interrupción o una llamada rechazada, revisar git status antes de afirmar que nada cambió.
metadata:
  type: feedback
---

Cuando el usuario interrumpe o rechaza una llamada (un comando de varios pasos, una edición), no dar por hecho que
no se aplicó: antes de continuar o de decir "no se escribió nada", revisar `git status` y `git diff` de los archivos
que tocaba.

**Why:** un comando de varios pasos puede haber escrito archivos antes de detenerse, aunque el aviso diga lo
contrario.

**How to apply:** `git status -s` en los repos involucrados; si hay cambios, decir cuáles son y preguntar si se
conservan o se descartan. Nunca descartarlos sin preguntar.
