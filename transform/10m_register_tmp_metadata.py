# ejecutar_sqlite_script_env.py
import os
import sqlite3
import pandas as pd
from dotenv import load_dotenv
from sqlite_utils import ejecutar_sql
from datetime import datetime

# Ruta del directorio donde está este script (no el CWD desde donde lo llamás)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Cargar .env relativo a este script también
load_dotenv(dotenv_path=os.path.join(BASE_DIR, ".env"))

# Cargar variable 
DB_PATH = os.getenv("DB_PATH", "")
TMP_DICT_PATH_CSV = os.getenv("TMP_DICT_PATH_CSV", "")
TMP_COL_DICT_PATH_CSV = os.getenv("TMP_COL_DICT_PATH_CSV", "")
# Resolver rutas relativas al script
ruta_db = os.path.join(BASE_DIR, DB_PATH)
# Resolver ruta del CSV
ruta_csv = os.path.join(BASE_DIR, TMP_DICT_PATH_CSV)
# Resolver ruta del CSV de columnas
ruta_col_csv = os.path.join(BASE_DIR, TMP_COL_DICT_PATH_CSV)
# Crear conexión a la base de datos
conn = sqlite3.connect(ruta_db)
cursor = conn.cursor()

# === Carga de MET_Tables ===
# Cargar descripciones desde el CSV
dictionary_df = pd.read_csv(ruta_csv)
description_dict = dict(zip(dictionary_df['tableName'], dictionary_df['description']))

# Borrar registros existentes en MET_Tables con layer = 'TMP'
cursor.execute("DELETE FROM MET_Tables WHERE layer = 'TMP'")

# Leer metadata de tablas TMP_ desde sqlite_master
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'TMP_%'")
tmp_tables = cursor.fetchall()

# Insertar nuevos registros en MET_Tables con descripciones desde CSV
for (table_name,) in tmp_tables:
    description = description_dict.get(table_name, f'Descripción no disponible para {table_name}')
    cursor.execute("""
        INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
        VALUES (?, 'TMP', ?, datetime('now'), 'headless', datetime('now'))
    """, (table_name, description))

# === Carga de MET_Columns ===
# Leer el archivo CSV con descripciones detalladas
detailed_df = pd.read_csv(ruta_col_csv)
detailed_descriptions = {
    (row["tableName"], row["columnName"]): row["description"]
    for _, row in detailed_df.iterrows()
}

# Leer columnas de todas las tablas TMP_ y asignar descripciones desde el CSV
columns_metadata = []
for (table_name,) in tmp_tables:
    cursor.execute(f"PRAGMA table_info({table_name})")
    table_info = cursor.fetchall()
    for col in table_info:
        col_id, col_name, data_type, not_null, default_value, is_pk = col
        description = detailed_descriptions.get((table_name, col_name), f"Columna {col_name} de {table_name}")
        columns_metadata.append({
            "tableName": table_name,
            "columnName": col_name,
            "dataType": data_type or "UNKNOWN",
            "isPrimaryKey": int(is_pk == 1),
            "isForeignKey": 0,
            "isUUID": int("uuid" in col_name.lower()),
            "description": description
        })

# Borrar los registros existentes en MET_Columns que correspondan a tablas TMP_
cursor.execute("DELETE FROM MET_Columns WHERE tableName LIKE 'TMP_%'")

# Generar las sentencias INSERT
insert_column_sqls = []
for col in columns_metadata:
    stmt = f"""INSERT INTO MET_Columns (tableName, columnName, dataType, isPrimaryKey, isForeignKey, isUUID, description)
VALUES ('{col["tableName"]}', '{col["columnName"]}', '{col["dataType"]}', {col["isPrimaryKey"]}, {col["isForeignKey"]}, {col["isUUID"]}, '{col["description"]}');"""
    insert_column_sqls.append(stmt)

# Ejecutar los INSERTs generados previamente
for stmt in insert_column_sqls:
    cursor.execute(stmt)

# Leer el ID de ejecución actual desde el archivo
with open("current_execution.txt", "r") as f:
    execution_id = f.read().strip()

# Generar registro de inicio de ejecución del pipeline
cursor.execute("""
INSERT INTO MET_Executions (processName, executedBy, startTime, endTime, status, log)
VALUES (
    ?,
    'headless',
    datetime('now', '-10 minutes'),
    datetime('now'),
    'STARTED',
    'Full Pipeline Execution'
);
""",(execution_id,))

# Guardar cambios
conn.commit()
