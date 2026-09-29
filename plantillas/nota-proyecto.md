---
name: estado-tienda-ejemplo
description: Estado vigente de la tienda de ejemplo — qué está hecho, qué falta y qué está sin probar (EJEMPLO de nota principal de proyecto).
metadata:
  type: project
---

<!-- Ejemplo de la nota principal de un proyecto. Cópiala a ~/.claude/memoria-claude/<repo>/estado-<repo>.md y
     agrégale su línea al MEMORY.md del repo. Se reescribe como estado vigente: no se le agregan bloques por fecha. -->

# Tienda de ejemplo — estado al 2026-09-29

## EN CURSO

- Chat "Pagos con tarjeta" (`local_…`): conectar la pasarela de pagos en el ambiente de pruebas.
- Hecho: llaves de prueba en `.env`, cobro de prueba aprobado (commit `a1b2c3d`).
- Falta: probar el reembolso y el webhook de pago rechazado.
- Siguientes pasos: 1) reembolso en pruebas, 2) webhook, 3) guion de salida.
- Decisiones recientes: D12 pagos solo con tarjeta al inicio; D13 sin guardar tarjetas.
- Chats paralelos: "Envíos" (`local_…`) lleva la cotización de paquetería; no toca pagos.

## Estado vigente

| Área | Estado | Dónde |
|---|---|---|
| Catálogo | Hecho y en producción | producción |
| Pagos | En pruebas | pruebas (clon) |
| Envíos | Cotización lista, sin guías | pruebas |
| Facturación | Pendiente del cliente | — |

## Decisiones (vigentes)

- D12 (2026-09-20): pagos solo con tarjeta al inicio; transferencias después.
- D13 (2026-09-22): no se guardan tarjetas; el cliente las captura en cada compra.

## Pendientes

Lista única en el repo: `docs/pendientes.md` (por responsable).

## Entorno

- Pruebas: clon local en `http://tienda.test`; producción: el hosting del cliente (solo lectura sin orden explícita).
- Credenciales: en `.env` del repo (fuera de git); nunca aquí.
