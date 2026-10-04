# powerbi-opencode-kit

Kit base (vacío, listo para usar) para trabajar con Power BI usando opencode.

Queda configurado para que después puedas agregar agentes y skills sin pelear con el esquema.

## Estructura

```text
.
├── opencode.json                  # config del proyecto ($schema + instructions + skills.paths + permission)
├── AGENTS.md                      # instrucciones globales que opencode carga automáticamente
├── .opencode/
│   ├── agents/
│   │   └── ejemplo-agente.md      # plantilla → duplica para crear agentes reales
│   ├── skills/
│   │   └── ejemplo-skill/
│   │       └── SKILL.md           # plantilla → duplica para crear skills reales
│   └── commands/
│       └── listar-kit.md          # comando /listar-kit de ejemplo
└── docs/
    └── agentes-y-skills.md        # guía de instalación y uso
```

## Entorno verificado

Versiones con las que se configuró y probó este kit (2026-10-03).
Si tu modelo de IA revisa el proyecto, toma estas versiones como referencia del entorno esperado:

```powershell
opencode --version
node --version
npm --version
git --version
```

Salida esperada:

```text
1.15.10
v22.19.0
10.9.3
git version 2.49.0.windows.1
```

## Regla obligatoria: trabajar con PBIP, no con PBIX

No trabajes directamente sobre `.pbix`. Usa siempre Proyecto de Power BI (`.pbip`).

PBIP descompone el proyecto en archivos de texto: modelo semántico e informe quedan en carpetas independientes. PBIR guarda páginas y visuales en JSON, mientras TMDL representa el modelo semántico. Eso permite que un agente modifique el proyecto y que Git muestre exactamente qué cambió.

Estructura esperada del proyecto del usuario:

```text
MiDashboard/
├── MiDashboard.pbip
├── MiDashboard.Report/
│   ├── definition.pbir
│   └── definition/
│       └── pages/
└── MiDashboard.SemanticModel/
    ├── definition.pbism
    └── definition/
```

Antes de ejecutar el agente:

> Archivo → Guardar como → Proyecto de Power BI (.pbip)

## Uso

1. Abre este proyecto con opencode.
2. Ejecuta `/listar-kit` para ver agentes y skills detectados.
3. Para un agente nuevo: duplica `.opencode/agents/ejemplo-agente.md`.
4. Para un skill nuevo: duplica la carpeta `.opencode/skills/ejemplo-skill/`.
5. Reinicia opencode tras cada cambio de config (no hay hot-reload).

Detalles en `docs/agentes-y-skills.md`.
