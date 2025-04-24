@echo off
REM ================================================================================
REM Script: run_pipeline.cmd
REM Descripción:
REM   Este script ejecuta el pipeline completo de Data Warehouse Automation (DWA)
REM   en modo headless sobre Windows. Automatiza la ejecución secuencial de:
REM     - Ingesta de CSVs
REM     - Generación de dimensión de tiempo
REM     - Transformaciones a modelo dimensional
REM     - Enriquecimiento con claves temporales
REM     - Gestión de versiones históricas (SCD Tipo 2)
REM     - Validación de calidad de datos
REM     - Generación de productos analíticos
REM     - Registro de metadata y linaje
REM
REM Uso:
REM   Ejecutar este archivo desde la raíz del proyecto:
REM       > run_pipeline.cmd
REM
REM Requisitos:
REM   - Python 3.x con pandas instalado
REM   - SQLite 3.x instalado y accesible como `sqlite3`
REM   - La base `db/dwa.sqlite` debe existir (o ser creada previamente)
REM   - Scripts SQL y Python deben estar en la carpeta `transform/`
REM ================================================================================

echo === Iniciando pipeline DWA en Windows ===
DB_PATH=db\dwa-lite.db

echo [1] Cargando CSV a TMP_
python transform\10_load_csv_to_tmp.py

echo [2] Generando o extendiendo DWA_Time
sqlite3 %DB_PATH% < transform\15_generate_dwa_time.sql

echo [3] Transformando TMP_ a DWA_
sqlite3 %DB_PATH% < transform\20_transform_tmp_to_dwa.sql

echo [4] Asignando claves de fecha a hechos
sqlite3 %DB_PATH% < transform\25_assign_date_keys_to_facts.sql

echo [5] Aplicando SCD Tipo 2
python transform\30_update_dwm_from_dwa.py

echo [6] Validando calidad
python transform\40_validate_quality.py

echo [7] Generando productos analíticos
sqlite3 %DB_PATH% < transform\50_generate_data_products.sql

echo [8] Registrando metadata
sqlite3 %DB_PATH% < transform\60_register_metadata.sql

echo === Pipeline finalizado correctamente ===
pause
