@echo off
REM ================================================================================
REM Script: run_incremental_pipeline.cmd
REM Descripción:
REM   Ejecuta el pipeline incremental del DWA procesando archivos de novedades
REM   ubicados en `data/ingesta2/`. Utiliza SCD Tipo 2 para mantener historial
REM   y actualiza todas las capas sin sobrescribir datos existentes.
REM
REM   Este pipeline se activa con archivos CSV que pueden tener nombres distintos
REM   a los de `ingesta1`, y se mapean explícitamente en el script Python
REM   `update_csv_to_tmp.py`.
REM
REM Uso:
REM   > run_incremental_pipeline.cmd
REM
REM Requisitos:
REM   - SQLite y Python instalados
REM   - Base de datos poblada previamente con `ingesta1`
REM   - Archivos en `data/ingesta2/` con sufijo " - novedades.csv"
REM ================================================================================

echo === Iniciando pipeline INCREMENTAL con novedades de Ingesta2 ===

echo [1] Cargando novedades CSV a TMP_
python transform\11_update_csv_to_tmp.py

echo [2] Generando nuevas fechas en DWA_Time si es necesario
sqlite3 db\dwa.sqlite < transform\15_generate_dwa_time.sql

echo [3] Transformando nuevos datos TMP_ a DWA_
sqlite3 db\dwa.sqlite < transform\20_transform_tmp_to_dwa.sql

echo [4] Asignando claves de fecha a hechos
sqlite3 db\dwa.sqlite < transform\25_assign_date_keys_to_facts.sql

echo [5] Actualizando memoria histórica con SCD Tipo 2
python transform\30_update_dwm_from_dwa.py

echo [6] Validando calidad de datos actualizados
python transform\40_validate_quality.py

echo [7] Recalculando productos analíticos (parcial o completo)
sqlite3 db\dwa.sqlite < transform\50_generate_data_products.sql

echo [8] Registrando nueva ejecución y linaje
sqlite3 db\dwa.sqlite < transform\60_register_metadata.sql

echo === Actualización incremental finalizada correctamente ===
pause
