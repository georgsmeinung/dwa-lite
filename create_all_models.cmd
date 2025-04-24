@echo off
REM ================================================================================
REM Script: create_all_models.cmd
REM Descripción:
REM   Este script crea toda la estructura de tablas del Data Warehouse Automation (DWA)
REM   ejecutando los scripts SQL en orden lógico desde las carpetas:
REM     - models/tmp
REM     - models/dwa
REM     - models/dwm
REM     - models/dqm
REM     - models/met
REM     - models/dp
REM
REM   La base de datos SQLite se crea (si no existe) en la carpeta /db.
REM
REM Uso:
REM   Ejecutar este archivo desde la raíz del proyecto en Windows:
REM       > create_all_models.cmd
REM
REM Requisitos:
REM   - Tener instalado SQLite y accesible como `sqlite3` en el PATH del sistema.
REM   - Los scripts deben estar organizados por carpeta bajo /models.
REM ================================================================================

echo === Inicializando creación de todas las tablas del DWA por capas ===

REM Crear carpeta y base SQLite si no existen
if not exist db mkdir db
if not exist db\dwa-lite.db (
    echo [✓] Creando nueva base de datos SQLite
    type nul > db\dwa-lite.db
)

REM Ejecutar scripts por capa en orden lógico
setlocal enabledelayedexpansion

set DWA_LAYERS=models\tmp models\dwa models\dwm models\dqm models\met models\dp

for %%L in (%DWA_LAYERS%) do (
    echo.
    echo === Ejecutando scripts en %%L ===
    for %%F in (%%L\*.sql) do (
        echo    [▶] %%F
        sqlite3 db\dwa-lite.db < %%F
    )
)

echo.
echo === Todas las estructuras fueron generadas exitosamente ===
pause
