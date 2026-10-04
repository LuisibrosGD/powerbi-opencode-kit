$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
Set-Location -LiteralPath $repoRoot

foreach ($name in @('node', 'npm', 'git', 'opencode')) {
    if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
        throw "Falta $name en PATH."
    }
}

if (-not (Test-Path -LiteralPath 'package-lock.json' -PathType Leaf)) {
    throw 'Falta package-lock.json; no se puede instalar de forma reproducible.'
}

npm ci
if ($LASTEXITCODE -ne 0) { throw 'npm ci falló.' }

$source = Join-Path $repoRoot 'templates/project'
$target = Join-Path $repoRoot 'workspace/mi-proyecto'
New-Item -ItemType Directory -Force -Path $target | Out-Null
Get-ChildItem -LiteralPath $source -Recurse -File | ForEach-Object {
    $relative = $_.FullName.Substring($source.Length).TrimStart('\', '/')
    $destination = Join-Path $target $relative
    $parent = Split-Path -Parent $destination
    New-Item -ItemType Directory -Force -Path $parent | Out-Null
    if (-not (Test-Path -LiteralPath $destination)) {
        Copy-Item -LiteralPath $_.FullName -Destination $destination
    }
}

& (Join-Path $PSScriptRoot 'check-environment.ps1')
if ($LASTEXITCODE -ne 0) { throw 'La verificación del entorno falló.' }
