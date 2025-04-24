@echo off
echo === Iniciando pipeline DWA en Windows ===

echo [1] Cargando CSV a TMP_
python transform\load_csv_to_tmp.py

echo [2] Generando o extendiendo DWA_Time
sqlite3 db\dwa.sqlite < transform\generate_dwa_time.sql

echo [3] Transformando TMP_ a DWA_
sqlite3 db\dwa.sqlite < transform\transform_tmp_to_dwa.sql

echo [4] Asignando claves de fecha a hechos
sqlite3 db\dwa.sqlite < transform\assign_date_keys_to_facts.sql

echo [5] Aplicando SCD Tipo 2
python transform\update_dwm_from_dwa.py

echo [6] Validando calidad
python transform\validate_quality.py

echo [7] Generando productos analíticos
sqlite3 db\dwa.sqlite < transform\generate_data_products.sql

echo [8] Registrando metadata
sqlite3 db\dwa.sqlite < transform\register_metadata.sql

echo === Pipeline finalizado correctamente ===
pause
