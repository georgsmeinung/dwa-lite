# Cancelas, Martín.
# Nicolau, Jorge.A

# 13m_register_stg_metadata.py
import os
from dotenv import load_dotenv
from sqlite_utils import ejecutar_sql
import sqlite3
import pandas as pd

# Ruta del directorio donde está este script (no el CWD desde donde lo llamás)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Cargar .env relativo a este script también
load_dotenv(dotenv_path=os.path.join(BASE_DIR, ".env"))

# Cargar variable 
DB_PATH = os.getenv("DB_PATH", "")
TMP_DICT_PATH_CSV = os.getenv("STG_DICT_PATH_CSV", "")
TMP_COL_DICT_PATH_CSV = os.getenv("STG_COL_DICT_PATH_CSV", "")
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

# Borrar registros existentes en MET_Tables con layer = 'STG'
cursor.execute("DELETE FROM MET_Tables WHERE layer = 'STG'")

# Leer metadata de tablas STG_ desde sqlite_master
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'STG_%'")
tmp_tables = cursor.fetchall()

# Insertar nuevos registros en MET_Tables con descripciones desde CSV
for (table_name,) in tmp_tables:
    description = description_dict.get(table_name, f'Descripción no disponible para {table_name}')
    cursor.execute("""
        INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
        VALUES (?, 'STG', ?, datetime('now'), 'headless', datetime('now'))
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

# Borrar los registros existentes en MET_Columns que correspondan a tablas STG_
cursor.execute("DELETE FROM MET_Columns WHERE tableName LIKE 'STG_%'")

# Generar las sentencias INSERT
insert_column_sqls = []
for col in columns_metadata:
    stmt = f"""INSERT INTO MET_Columns (tableName, columnName, dataType, isPrimaryKey, isForeignKey, isUUID, description)
VALUES ('{col["tableName"]}', '{col["columnName"]}', '{col["dataType"]}', {col["isPrimaryKey"]}, {col["isForeignKey"]}, {col["isUUID"]}, '{col["description"]}');"""
    insert_column_sqls.append(stmt)

# Ejecutar los INSERTs generados previamente
for stmt in insert_column_sqls:
    cursor.execute(stmt)

# Obtener tablas STG_
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'STG_%'")
stg_tables = [row[0] for row in cursor.fetchall()]

# Agregar columna uuid a STG_ solo si no existe, y luego poblarla
for table in stg_tables:
    # Obtener nombres de columnas actuales
    cursor.execute(f"PRAGMA table_info({table})")
    columns = [col[1] for col in cursor.fetchall()]

    if "uuid" not in columns:
        # Agregar columna uuid
        cursor.execute(f"ALTER TABLE {table} ADD COLUMN uuid TEXT")
        # Poblarla con valores aleatorios únicos
        cursor.execute(f"UPDATE {table} SET uuid = lower(hex(randomblob(16)))")

# Guardar cambios
conn.commit()
