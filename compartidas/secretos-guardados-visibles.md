---
name: secretos-guardados-visibles
description: En formularios, un secreto ya guardado se muestra como configurado (enmascarado), nunca vacío.
metadata:
  type: feedback
---

En instaladores, asistentes y pantallas de ajustes, cuando un secreto (token, contraseña, llave de API) ya está
guardado, el campo se muestra como configurado (enmascarado, "••••••" o "configurado") y se conserva si se deja así;
solo se reemplaza si se escribe uno nuevo. Nunca se muestra vacío ni se revela.

**Why:** un campo vacío hace creer que no hay nada configurado y lleva a pedir o pegar el secreto otra vez.

**How to apply:** estado visible (configurado / no configurado), valor nunca expuesto y reemplazo explícito. Ver
[[diseno-interfaces-coherente]].
