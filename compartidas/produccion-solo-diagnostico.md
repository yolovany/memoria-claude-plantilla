---
name: produccion-solo-diagnostico
description: Contra producción, solo diagnóstico de lectura hasta que el usuario ordene explícitamente un cambio.
metadata:
  type: feedback
---

Contra producción (servidores, bases de datos, sitios en vivo, cuentas reales de proveedores) solo se hace
diagnóstico de lectura, hasta que el usuario ordene explícitamente un cambio o un despliegue.

**Why:** un error en producción afecta a usuarios reales y puede no tener marcha atrás. Con el modo que no pide
permiso, esta regla es la barrera.

**How to apply:**
- Lecturas sí: consultas de solo lectura (SELECT), APIs de consulta, registros.
- Todo lo que escriba (despliegues, scripts, migraciones, cambios de configuración) se propone con su plan de reversa
  y se espera la orden.
- La orden vale para ese cambio, no para los siguientes.
- Relacionada: [[auditar-contra-produccion]].
