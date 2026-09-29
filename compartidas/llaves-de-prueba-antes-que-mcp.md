---
name: llaves-de-prueba-antes-que-mcp
description: Para probar integraciones con proveedores, llaves de prueba en .env, no el MCP ni la cuenta real.
metadata:
  type: feedback
---

Para probar integraciones con proveedores que manejan dinero o datos de clientes (pagos, envíos, facturación), usar
sus llaves de prueba o sandbox en `.env` (fuera de git), y no conectar el MCP del proveedor ni pedir acceso a la
cuenta real, salvo que el usuario lo pida.

**Why:** las llaves de prueba no mueven dinero, se revocan del lado del proveedor y no exponen la cuenta real.

**How to apply:** pedir las llaves por `.env`, nunca pegadas en el chat. Comprobar con una llamada inofensiva si son de
prueba o de producción; si son de producción, limitarse a lecturas o consultas que no cuesten. Ver
[[sandbox-que-falla-no-insistir]].
