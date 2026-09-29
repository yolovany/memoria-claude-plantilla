---
name: auditar-contra-produccion
description: Antes de liberar, leer en solo lectura la configuración real de producción y compararla con pruebas.
metadata:
  type: feedback
---

Antes de liberar o de dar algo por listo, leer en solo lectura la configuración real de producción y compararla con
lo que dan por hecho los scripts de despliegue y el ambiente de pruebas. Que la prueba pase en el clon no basta.

**Why:** los fallos graves suelen estar en las diferencias entre pruebas y producción, no en el código probado: una
opción apagada con un valor que el script conserva, un caché o servicio que solo existe en producción, un campo
obligatorio allá y opcional en pruebas.

**How to apply:**
- Por cada paso que toque producción, preguntarse qué hay allá hoy (opciones, valores en 0, servicios que el clon no
  tiene: caché, CDN, tareas programadas) y leerlo.
- Lo que el clon no puede reproducir se anota como verificación explícita en el guion de salida, con su comando.
- Cada diferencia encontrada deja una prueba que la reproduce.
- Siempre en solo lectura: [[produccion-solo-diagnostico]].
