---
description: Ejecuta una tarea de Power BI desde un archivo de texto, con preflight, modelado, reporte y validación.
agent: build
---

Lee el archivo de instrucciones indicado en `$ARGUMENTS`, relativo al repositorio. Si falta la ruta o el archivo, informa el error sin modificar nada.

1. Aplica `AGENTS.md`. Ejecuta el preflight de `workspace/mi-proyecto/` antes de usar el MCP. Puedes usar `scripts/check-environment.ps1 -RequireProject` como apoyo, pero inspecciona también los archivos del PBIP y sus referencias.
2. Si el preflight no da `POWERBI_PROJECT_STATUS: READY`, detén las operaciones sobre el proyecto y explica la acción necesaria.
3. Para importar, transformar, modelar, crear medidas y validar DAX, usa exclusivamente las herramientas del MCP `powerbi-modeling` ya configurado. Confirma la instancia de Power BI Desktop antes de cualquier escritura. Si el MCP no está disponible, informa `POWERBI_MCP_STATUS: NOT_AVAILABLE` y detén esa fase.
4. No empieces el reporte hasta validar el modelo. Para páginas, visuales, PBIR, preview y capturas, carga la skill `powerbi-report-cli`, su modo y las referencias pertinentes. Solo para esa fase, comprueba el CLI local; si falta, instala las dependencias con `npm ci`. Usa `npm exec -- powerbi-report-author`.
5. Guarda capturas en `workspace/mi-proyecto/output/screenshots/`, revísalas visualmente y corrige hasta tres iteraciones cuando sea necesario.
6. Al terminar, informa las fases verificadas, archivos modificados y límites concretos. No hagas commit, push ni publicación sin instrucción explícita.

Tarea del usuario:

$ARGUMENTS
