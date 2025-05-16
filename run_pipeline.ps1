# =================================================================================
# Script: run_pipeline.ps1
# Descripción:
#   Ejecuta el pipeline completo de Data Warehouse Automation (DWA) en modo headless
#   sobre Windows. Automatiza:
#     - Ingesta de CSVs
#     - Generación de dimensión de tiempo
#     - Transformaciones a modelo dimensional
#     - Enriquecimiento con claves temporales
#     - Gestión de versiones históricas (SCD Tipo 2)
#     - Validación de calidad de datos
#     - Generación de productos analíticos
#     - Registro de metadata y linaje
#
# Uso:
#   Ejecutar este archivo desde la raíz del proyecto:
#       > .\run_pipeline.ps1
#
# Requisitos:
#   - Python 3.x con pandas instalado
#   - SQLite 3.x instalado y accesible como `sqlite3`
#   - La base `db/dwa-lite.db` debe existir (o ser creada previamente)
#   - Scripts SQL y Python deben estar en la carpeta `transform/`
# =================================================================================

Write-Host "=== Iniciando pipeline DWA en Windows ==="
$DB_PATH = "db\dwa-lite.db"

Write-Host "[1] Cargando CSV a TMP_"
python transform\10_load_csv_to_tmp.py

Write-Host "[2] Generando o extendiendo DWA_Time"
sqlite3 $DB_PATH < transform\15_generate_dwa_time.sql

Write-Host "[3] Transformando TMP_ a DWA_"
sqlite3 $DB_PATH < transform\20_transform_tmp_to_dwa.sql

Write-Host "[4] Asignando claves de fecha a hechos"
sqlite3 $DB_PATH < transform\25_assign_date_keys_to_facts.sql

Write-Host "[5] Aplicando SCD Tipo 2"
python transform\30_update_dwm_from_dwa.py

Write-Host "[6] Validando calidad"
python transform\40_validate_quality.py

Write-Host "[7] Generando productos analíticos"
sqlite3 $DB_PATH < transform\50_generate_data_products.sql

Write-Host "[8] Registrando metadata"
sqlite3 $DB_PATH < transform\60_register_metadata.sql

Write-Host "=== Pipeline finalizado correctamente ==="
Read-Host -Prompt "Presione Enter para salir"
