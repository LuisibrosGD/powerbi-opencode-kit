# AGENTS.md — powerbi-opencode-kit

Instrucciones base para todos los agentes. OpenCode las carga vía `instructions` en `opencode.json`.

## Idioma y tono

- Responde siempre en español.
- Usa un tono corto, directo y técnico.
- Evita superlativos y validación emocional.
- Cuando cites código o archivos, usa el formato `ruta:línea` cuando sea posible.

## Proyecto

- Kit base para trabajar con Power BI mediante OpenCode: modelado, DAX, Power Query (M), informes y despliegue.
- Los proyectos Power BI del usuario se almacenan dentro de `./workspace/`.
- El workspace de trabajo por defecto es `./workspace/mi-proyecto/`.
- Nunca dependas de rutas absolutas como `C:\Users\...`.
- Usa rutas relativas al repositorio siempre que sea posible.

Estructura esperada:

- `.opencode/agents/*.md` → un archivo por agente.
- `.opencode/skills/<nombre>/SKILL.md` → una carpeta por skill.
- `.opencode/commands/*.md` → comandos invocables con `/nombre`.
- `docs/` → guías y convenciones.
- `workspace/mi-proyecto/` → proyecto Power BI y archivos del usuario.

Una estructura habitual del workspace es:

```text
workspace/mi-proyecto/
├── proyecto_pbi/
│   ├── Proyecto.pbip
│   ├── Proyecto.Report/
│   └── Proyecto.SemanticModel/
├── data/
│   ├── raw/
│   └── reference/
├── prompts/
└── output/
```

La ubicación exacta interna puede variar. No asumas que el `.pbip` está directamente en la raíz de `mi-proyecto`.

## Cómo trabajar

1. **Evidencia antes de afirmar:** lee con `read`, `glob` y `grep` antes de proponer cambios.
2. **Cambios mínimos:** prefiere editar (`edit`) sobre crear archivos (`write`). No crees `.md` de documentación salvo pedido explícito.
3. **Verificación:** siempre que implementes o corrijas algo, verifica el resultado.
4. **Git:** no hagas `commit` ni `push` salvo petición explícita. Antes de commitear revisa `git status`, `git diff` y `git log --oneline -10`.
5. **Permisos:** respeta el bloque `permission` de `opencode.json` y del frontmatter de cada agente.

# Power BI — Preflight obligatorio

Antes de usar el MCP `powerbi-modeling` para inspeccionar, modificar o construir un modelo, ejecuta siempre este preflight.

## 1. Revisar el workspace

Inspecciona recursivamente:

`./workspace/mi-proyecto/`

Usa primero herramientas locales rápidas como `glob`, `read` o `grep`.

Busca:

- archivos `.pbip`
- archivos `.pbix`
- carpetas `.Report`
- carpetas `.SemanticModel`

No invoques todavía operaciones costosas de inspección del modelo mediante MCP.

## 2. Validar existencia del PBIP

### Si existe exactamente un `.pbip`

Comprueba que tenga asociados:

- `<Proyecto>.Report/`
- `<Proyecto>.SemanticModel/`

Si existen, continúa con el workflow.

Resultado:

`POWERBI_PROJECT_STATUS: READY`

### Si NO existe `.pbip`, pero sí existe `.pbix`

Detén el workflow.

No inspecciones el modelo completo mediante MCP.

Informa al usuario que debe:

1. abrir el `.pbix` en Power BI Desktop;
2. guardarlo como proyecto Power BI `.pbip`;
3. colocarlo dentro de `./workspace/mi-proyecto/`;
4. volver a ejecutar la tarea.

Resultado:

`POWERBI_PROJECT_STATUS: PBIP_REQUIRED`

### Si no existe ni `.pbip` ni `.pbix`

Detén el workflow e informa que no se encontró ningún proyecto Power BI.

Resultado:

`POWERBI_PROJECT_STATUS: PROJECT_NOT_FOUND`

### Si existen varios `.pbip`

No selecciones uno arbitrariamente.

Muestra los proyectos encontrados y solicita al usuario cuál debe utilizarse.

Resultado:

`POWERBI_PROJECT_STATUS: PROJECT_SELECTION_REQUIRED`

## 3. Validar estructura del PBIP

La existencia del archivo `.pbip` por sí sola no es suficiente.

Comprueba también que existan sus carpetas asociadas:

```text
Proyecto.pbip
Proyecto.Report/
Proyecto.SemanticModel/
```

Si falta alguna de ellas, detén el workflow e informa qué componente falta.

Resultado:

`POWERBI_PROJECT_STATUS: INVALID_STRUCTURE`

## 4. Detectar posible PBIP desactualizado

Si existen simultáneamente:

```text
Proyecto.pbix
Proyecto.pbip
```

y el modelo del `.pbip` parece vacío o incompleto, no asumas inmediatamente que el proyecto no contiene datos.

Indicadores de posible desfase:

- 0 tablas;
- 0 particiones;
- 0 consultas;
- `.SemanticModel` prácticamente vacío;
- el usuario indica que el `.pbix` sí contiene datos.

En ese caso:

1. no realices modificaciones;
2. informa que el `.pbip` puede estar desactualizado respecto al `.pbix`;
3. solicita abrir el `.pbix` en Power BI Desktop;
4. guardarlo nuevamente como `.pbip`;
5. repetir el preflight.

Resultado:

`POWERBI_PROJECT_STATUS: PBIP_OUTDATED`

# Power BI — Regla de inspección

El preflight y la inspección del modelo son fases diferentes.

## Preflight

Durante el preflight está permitido leer directamente:

- `.pbip`
- `.pbir`
- `.tmdl`
- `.json`

únicamente para:

- localizar el proyecto;
- comprobar su estructura;
- detectar si aparentemente está vacío;
- identificar referencias entre Report y SemanticModel.

No utilices esta lectura como sustituto de una inspección solicitada mediante MCP.

## Inspección del modelo

Después de obtener:

`POWERBI_PROJECT_STATUS: READY`

usa el MCP `powerbi-modeling` como fuente principal para consultar:

- tablas;
- columnas;
- medidas;
- relaciones;
- particiones;
- consultas Power Query;
- datos;
- resultados DAX;
- metadatos del modelo.

Si el usuario solicita explícitamente:

> Usa el MCP

no respondas las preguntas del modelo leyendo TMDL, PBIR o JSON.

Si el MCP no puede obtener una información:

- indícalo explícitamente;
- no simules una consulta MCP leyendo archivos del proyecto.

## Modelo abierto en Power BI Desktop

Antes de modificar el modelo:

1. identifica mediante el MCP qué instancia/modelo de Power BI Desktop está disponible;
2. comprueba que corresponde al proyecto seleccionado;
3. evita modificar otra instancia de Power BI abierta accidentalmente.

Si no puedes determinar con seguridad qué modelo corresponde al `.pbip`, detén las modificaciones y solicita confirmación.

# Convenciones Power BI

## Modelado

- Preferir esquema estrella.
- Mantener tablas de hechos finas.
- Usar dimensiones conformadas.
- Preferir relaciones de una sola dirección salvo necesidad justificada.
- Inspeccionar el modelo existente antes de crear tablas, columnas o relaciones.

## DAX

- Preferir medidas sobre columnas calculadas cuando corresponda.
- Usar nombres claros.
- Evitar `FILTER` innecesarios.
- Preferir variables `VAR` para expresiones complejas.
- Validar medidas importantes ejecutando consultas DAX cuando sea posible.
- No considerar una medida correcta únicamente porque pudo crearse sin errores.

## Power Query M

- Usar nombres de pasos claros y consistentes.
- Evitar `Table.Buffer` salvo que exista una razón concreta.
- No hardcodear rutas pertenecientes a una computadora específica.
- Para datasets dentro del workspace, resolver la ubicación actual del archivo antes de crear o reparar una fuente.

## Reportes

El modelado y el diseño visual son responsabilidades diferentes.

Para:

- importación;
- Power Query;
- tablas;
- columnas;
- relaciones;
- medidas DAX;
- verificación de datos;

usar `powerbi-modeling`.

Para:

- páginas;
- visuales;
- layout;
- formato;
- PBIR;
- preview;
- screenshots;

usar la skill `powerbi-report-cli`.

No comenzar el diseño del reporte hasta que el modelo requerido esté preparado y validado.

# Crear un agente nuevo

1. Duplica `.opencode/agents/ejemplo-agente.md` → `.opencode/agents/<nombre>.md`.
2. Ajusta el frontmatter (`description`, `mode`, `temperature`, `permission`).
3. Escribe el prompt en el cuerpo.
4. Reinicia OpenCode para que cargue el cambio.

# Crear un skill nuevo

1. Duplica `.opencode/skills/ejemplo-skill/` → `.opencode/skills/<nombre>/`.
2. `name` del frontmatter = nombre de la carpeta.
3. `description` debe indicar qué hace, cuándo dispararlo y palabras clave.
4. Escribe instrucciones, ejemplos y referencias en el cuerpo.
5. Si está en otra ruta, regístrala en `opencode.json` → `skills.paths`.
6. Reinicia OpenCode.


## Estado inicial del modelo

Después de validar la estructura del PBIP, clasifica el estado aparente
del modelo sin sustituir la inspección MCP.

Si `.SemanticModel` no contiene tablas aparentes:

`POWERBI_MODEL_STATE: EMPTY`

Si contiene una o más tablas aparentes:

`POWERBI_MODEL_STATE: POPULATED`

Este estado es solo una comprobación local preliminar.
El MCP `powerbi-modeling` debe confirmar posteriormente el estado real
del modelo.

# Power BI — Uso del MCP configurado

El servidor MCP `powerbi-modeling` ya está configurado a nivel de proyecto
en `opencode.json`.

## Regla obligatoria

Cuando necesites utilizar Power BI Modeling MCP:

- usa directamente las herramientas MCP `powerbi-modeling` expuestas
  por OpenCode;
- no ejecutes manualmente `npx @microsoft/powerbi-modeling-mcp`;
- no levantes una segunda instancia del servidor MCP;
- no crees scripts Python, PowerShell, Node.js o Bash para descubrir,
  listar o iniciar el MCP;
- no busques configuraciones MCP globales si el servidor del proyecto
  está disponible;
- no instales nuevamente el paquete MCP durante una tarea.

La configuración del proyecto es la fuente de verdad:

`./opencode.json`

## Verificación

Para comprobar si el MCP está disponible:

1. intenta utilizar directamente una operación MCP de
   `powerbi-modeling`;
2. si las herramientas MCP no están disponibles, detén el workflow;
3. informa al usuario que debe revisar la conexión/configuración MCP.

No intentes solucionar automáticamente la ausencia del MCP
ejecutando una nueva instancia mediante `npx`.

Estado cuando no esté disponible:

`POWERBI_MCP_STATUS: NOT_AVAILABLE`

Estado cuando la conexión MCP funcione:

`POWERBI_MCP_STATUS: READY`

## Herramientas del sistema

No uses `bash`, Python, PowerShell o Node.js para replicar una operación
que ya proporciona el MCP `powerbi-modeling`.

Ejemplo:

Incorrecto:

`python mcp_list.py`
`npx @microsoft/powerbi-modeling-mcp`

Correcto:

usar directamente `connection_operations`, `model_operations`,
`table_operations`, `measure_operations`, etc. del MCP configurado.

## MCP configurado por el proyecto

El MCP `powerbi-modeling` ya está configurado en `opencode.json`.

Nunca:

- ejecutes manualmente `npx @microsoft/powerbi-modeling-mcp`;
- crees scripts Python para iniciar o descubrir MCP;
- levantes otra instancia MCP;
- busques una configuración MCP global.

Usa directamente las herramientas MCP expuestas por OpenCode.

## Capturas

Todas las capturas generadas para validación visual deben almacenarse
dentro de:

./workspace/mi-proyecto/output/screenshots/

No solicites acceso a una carpeta padre más amplia salvo que sea
estrictamente necesario.

Las carpetas temporales utilizadas durante el proceso deben limitarse
al workspace o al directorio temporal del sistema.