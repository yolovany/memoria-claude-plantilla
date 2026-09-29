---
name: sandbox-que-falla-no-insistir
description: Si el sandbox de un proveedor falla dos veces por causas suyas, ofrecer alternativas en vez de insistir.
metadata:
  type: feedback
---

Si el ambiente de pruebas de un proveedor externo falla dos veces por causas suyas (registro que no pasa, acceso en
ciclo, credenciales que no sirven), no seguir probando variantes con el usuario: ofrecer de inmediato alternativas con
su costo real.

**Why:** insistir consume la sesión en un problema que no depende de nosotros.

**How to apply:** al segundo fallo, opciones: 1) texto listo para el soporte del proveedor, 2) otro proveedor con
sandbox que funcione (comparando el mismo caso), 3) validar en la primera operación real con cancelación o reembolso,
4) dejarlo para la salida si no bloquea. Ver [[automatizar-siendo-realista]] y [[desbloquear-en-vez-de-frenar]].
