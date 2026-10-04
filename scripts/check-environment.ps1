param([switch]$RequireProject, [switch]$RequireReportCli)

$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$projectRoot = Join-Path $repoRoot 'workspace/mi-proyecto'
$environmentOk = $true

foreach ($name in @('node', 'npm', 'git', 'opencode')) {
    $command = Get-Command $name -ErrorAction SilentlyContinue
    if ($command) {
        Write-Output "$name`: $($command.Source)"
    } else {
        Write-Output "$name`: NO DISPONIBLE"
        $environmentOk = $false
    }
}

if (Get-Command node -ErrorAction SilentlyContinue) {
    $nodeVersion = (& node --version).TrimStart('v')
    if ([version]$nodeVersion -lt [version]'20.0.0') {
        Write-Output "Node.js $nodeVersion es insuficiente; se requiere >=20."
        $environmentOk = $false
    }
}

$cli = Join-Path $repoRoot 'node_modules/.bin/powerbi-report-author.cmd'
if (Test-Path -LiteralPath $cli -PathType Leaf) {
    $version = & $cli --version
    if ($LASTEXITCODE -eq 0) {
        Write-Output "powerbi-report-author: $version"
    } else {
        Write-Output 'powerbi-report-author: ERROR'
        if ($RequireReportCli) { $environmentOk = $false }
    }
} else {
    Write-Output 'powerbi-report-author: NO INSTALADO (solo se requiere para reportes)'
    if ($RequireReportCli) { $environmentOk = $false }
}

if (-not (Test-Path -LiteralPath $projectRoot -PathType Container)) {
    Write-Output 'POWERBI_PROJECT_STATUS: PROJECT_NOT_FOUND'
    if ($RequireProject -or -not $environmentOk) { exit 1 }
    exit 0
}

$pbips = @(Get-ChildItem -LiteralPath $projectRoot -Recurse -File -Filter '*.pbip')
$pbixes = @(Get-ChildItem -LiteralPath $projectRoot -Recurse -File -Filter '*.pbix')

if ($pbips.Count -gt 1) {
    $pbips | ForEach-Object { Write-Output "Proyecto: $($_.FullName.Substring($repoRoot.Length + 1))" }
    Write-Output 'POWERBI_PROJECT_STATUS: PROJECT_SELECTION_REQUIRED'
    exit 1
}
if ($pbips.Count -eq 0) {
    if ($pbixes.Count -gt 0) {
        Write-Output 'POWERBI_PROJECT_STATUS: PBIP_REQUIRED'
    } else {
        Write-Output 'POWERBI_PROJECT_STATUS: PROJECT_NOT_FOUND'
    }
    if ($RequireProject -or -not $environmentOk) { exit 1 }
    exit 0
}

$pbip = $pbips[0]
$base = [System.IO.Path]::GetFileNameWithoutExtension($pbip.Name)
$report = Join-Path $pbip.DirectoryName ($base + '.Report')
$model = Join-Path $pbip.DirectoryName ($base + '.SemanticModel')
$missing = @()
if (-not (Test-Path -LiteralPath $report -PathType Container)) { $missing += ($base + '.Report/') }
if (-not (Test-Path -LiteralPath $model -PathType Container)) { $missing += ($base + '.SemanticModel/') }
if ($missing.Count -gt 0) {
    Write-Output "Componentes faltantes: $($missing -join ', ')"
    Write-Output 'POWERBI_PROJECT_STATUS: INVALID_STRUCTURE'
    exit 1
}

$tableFiles = @(Get-ChildItem -LiteralPath $model -Recurse -File -Filter '*.tmdl' | Where-Object {
    Select-String -LiteralPath $_.FullName -Pattern '^\s*table\s+' -Quiet
})
if ($tableFiles.Count -eq 0) {
    $pairedPbix = Join-Path $pbip.DirectoryName ($base + '.pbix')
    if (Test-Path -LiteralPath $pairedPbix -PathType Leaf) {
        Write-Output 'POWERBI_PROJECT_STATUS: PBIP_OUTDATED'
        exit 1
    }
    Write-Output 'POWERBI_MODEL_STATE: EMPTY'
} else {
    Write-Output 'POWERBI_MODEL_STATE: POPULATED'
}

Write-Output "Proyecto: $($pbip.FullName.Substring($repoRoot.Length + 1))"
Write-Output 'POWERBI_PROJECT_STATUS: READY'
if (-not $environmentOk) { exit 1 }
