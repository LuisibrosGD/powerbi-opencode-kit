# powerbi-opencode-kit

Kit portable para trabajar con proyectos Power BI (`.pbip`) desde OpenCode Build. El modelado se hace con el MCP `powerbi-modeling`; el reporte se edita y valida con la skill `powerbi-report-cli` y el CLI instalado localmente.

## Requisitos

- Windows y Power BI Desktop.
- Node.js 20 o superior, npm, Git y OpenCode v1.
- Un proyecto `.pbip` con sus carpetas `.Report` y `.SemanticModel` dentro de `workspace/mi-proyecto/`.

## Instalación

```powershell
git clone <URL-del-repositorio>
cd powerbi-opencode-kit
opencode
```

El MCP y la skill funcionan sin instalar las dependencias npm del repositorio. Antes de editar o validar un reporte con `powerbi-report-author`, ejecuta `npm ci`. Eso crea `node_modules/` solo en tu PC. También puedes ejecutar `powershell -NoProfile -ExecutionPolicy Bypass -File scripts/setup.ps1` para instalar el CLI y comprobar el entorno.

El servidor MCP se inicia desde `opencode.json` al abrir OpenCode. No hay que iniciarlo manualmente. La versión del paquete MCP está fijada en esa configuración.

## Estructura

```text
AGENTS.md                         Reglas de trabajo y preflight
opencode.json                     MCP y permisos de OpenCode v1
package.json / package-lock.json  CLI local fijado
.opencode/skills/powerbi-report-cli/
.opencode/commands/powerbi-run.md
scripts/setup.ps1
scripts/check-environment.ps1
templates/project/                Estructura vacía para proyectos nuevos
workspace/mi-proyecto/            Proyecto y datos del usuario, ignorados por Git
examples/previous-kit/            Configuración anterior como referencia
```

## Uso

1. Guarda el archivo Power BI Desktop como proyecto `.pbip` dentro de `workspace/mi-proyecto/`. Debe tener `<Nombre>.Report/` y `<Nombre>.SemanticModel/` junto al `.pbip`.
2. Verifica el entorno y el PBIP:

   ```powershell
   powershell -NoProfile -ExecutionPolicy Bypass -File scripts/check-environment.ps1 -RequireProject
   ```

3. Escribe la tarea en `workspace/mi-proyecto/prompts/tarea.txt`.
4. En OpenCode Build ejecuta `/powerbi-run ./workspace/mi-proyecto/prompts/tarea.txt`.

Para consultar la versión del CLI local:

```powershell
npm exec -- powerbi-report-author --version
```

`check-environment.ps1` comprueba la estructura y solo clasifica de forma preliminar el contenido del modelo. El MCP debe confirmar tablas, medidas y datos antes de modificar el reporte.

## Alcance de la prueba

El kit puede instalarse y comprobarse sin un PBIP. Las pruebas de MCP, importación, modelado, diseño y capturas requieren un PBIP real abierto en Power BI Desktop. Las capturas se guardan en `workspace/mi-proyecto/output/screenshots/`.
