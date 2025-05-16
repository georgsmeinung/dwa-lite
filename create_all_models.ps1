# =================================================================================
# Script: create_all_models.ps1
# Descripción:
#   Este script crea toda la estructura de tablas del Data Warehouse Automation (DWA)
#   ejecutando los scripts SQL en orden lógico desde las carpetas:
#     - models/tmp
#     - models/dwa
#     - models/dwm
#     - models/dqm
#     - models/met
#     - models/dp
#
#   La base de datos SQLite se crea (si no existe) en la carpeta /db.
#
# Uso:
#   Ejecutar este archivo desde la raíz del proyecto en Windows:
#       > .\create_all_models.ps1
#
# Requisitos:
#   - Tener instalado SQLite y accesible como `sqlite3` en el PATH del sistema.
#   - Los scripts deben estar organizados por carpeta bajo /models.
# =================================================================================

Write-Host "=== Inicializando creación de todas las tablas del DWA por capas ==="

# Crear carpeta y base SQLite si no existen
if (-not (Test-Path "db")) {
    New-Item -ItemType Directory -Path "db" | Out-Null
}
if (-not (Test-Path "db\dwa-lite.db")) {
    Write-Host "[✓] Creando nueva base de datos SQLite"
    New-Item -ItemType File -Path "db\dwa-lite.db" | Out-Null
}

# Ejecutar scripts por capa en orden lógico
$DWA_LAYERS = @(
    "models/tmp",
    "models/dwa",
    "models/dwm",
    "models/dqm",
    "models/met",
    "models/dp"
)

foreach ($layer in $DWA_LAYERS) {
    Write-Host ""
    Write-Host "=== Ejecutando scripts en $layer ==="
    Get-ChildItem -Path "$layer" -Filter *.sql | ForEach-Object {
        Write-Host "   [▶] $($_.FullName)"
        & sqlite3 "db\dwa-lite.db" < $_.FullName
    }
}

Write-Host ""
Write-Host "=== Todas las estructuras fueron generadas exitosamente ==="
Read-Host -Prompt "Presione Enter para continuar"
