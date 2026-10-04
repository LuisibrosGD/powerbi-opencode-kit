---
name: ejemplo-skill
description: Plantilla de ejemplo. Usar cuando se quiera crear un skill nuevo del kit Power BI (DAX, modelado, Power Query). Copiar como .opencode/skills/<nombre>/SKILL.md.
---

# Skill de ejemplo — Power BI

> Plantilla lista para duplicar. Cada skill vive en su propia carpeta:
> `.opencode/skills/<nombre-skill>/SKILL.md`
>
> - `name` debe coincidir con el nombre de la carpeta, en minúsculas con guiones, máx. 64 caracteres.
> - `description` es obligatoria: sin ella opencode filtra el skill y nunca se activa.
> - Usa tercera persona y palabras clave literales que el usuario diría ("medida DAX", "modelo estrella", "Power Query M", "archivo .bim", etc.).

## Cuándo usar este skill

- Describe aquí los disparadores concretos.
- Ejemplo: "Usa ONLY cuando el usuario pida crear o corregir una medida DAX en un modelo tabular".

## Instrucciones

1. Lee primero los archivos del modelo implicados.
2. Aplica las convenciones del proyecto (ver `AGENTS.md`).
3. Propón el cambio mínimo que resuelva el pedido.
4. Indica cómo validarlo (Power BI Desktop, Tabular Editor, DAX Studio).

## Ejemplo

**Usuario:** "Crea la medida Ventas YoY"
**Respuesta esperada:** propuesta DAX formateada + tabla donde crearla + validación sugerida.
