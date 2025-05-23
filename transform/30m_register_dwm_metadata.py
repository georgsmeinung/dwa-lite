# Cancelas, Martín.
# Nicolau, Jorge.A

import os
from dotenv import load_dotenv
import sqlite3
import pandas as pd

# Ruta del directorio donde está este script
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Cargar .env relativo a este script también
load_dotenv(dotenv_path=os.path.join(BASE_DIR, ".env"))

# Cargar variables específicas para DWM
DB_PATH = os.getenv("DB_PATH", "")
DWM_DICT_PATH_CSV = os.getenv("DWM_DICT_PATH_CSV", "")
DWM_COL_DICT_PATH_CSV = os.getenv("DWM_COL_DICT_PATH_CSV", "")

# Resolver rutas relativas al script
ruta_db = os.path.join(BASE_DIR, DB_PATH)
ruta_csv = os.path.join(BASE_DIR, DWM_DICT_PATH_CSV)
ruta_col_csv = os.path.join(BASE_DIR, DWM_COL_DICT_PATH_CSV)

# Crear conexión a la base de datos
conn = sqlite3.connect(ruta_db)
cursor = conn.cursor()

# === Carga de MET_Tables ===
dictionary_df = pd.read_csv(ruta_csv)
description_dict = dict(zip(dictionary_df['tableName'], dictionary_df['description']))

cursor.execute("DELETE FROM MET_Tables WHERE layer = 'DWM'")
cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name LIKE 'DWM_%'")
dwm_tables = cursor.fetchall()

for (table_name,) in dwm_tables:
    description = description_dict.get(table_name, f'Descripción no disponible para {table_name}')
    cursor.execute(
        """INSERT INTO MET_Tables (tableName, layer, description, createdAt, createdBy, lastModified)
        VALUES (?, 'DWM', ?, datetime('now'), 'headless', datetime('now'))""",
        (table_name, description)
    )

# === Carga de MET_Columns ===
detailed_df = pd.read_csv(ruta_col_csv)
detailed_descriptions = {
    (row["tableName"], row["columnName"]): row["description"]
    for _, row in detailed_df.iterrows()
}

columns_metadata = []
for (table_name,) in dwm_tables:
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

cursor.execute("DELETE FROM MET_Columns WHERE tableName LIKE 'DWM_%'")

for col in columns_metadata:
    cursor.execute(
        """INSERT INTO MET_Columns (tableName, columnName, dataType, isPrimaryKey, isForeignKey, isUUID, description)
        VALUES (?, ?, ?, ?, ?, ?, ?)""",
        (
            col["tableName"],
            col["columnName"],
            col["dataType"],
            col["isPrimaryKey"],
            col["isForeignKey"],
            col["isUUID"],
            col["description"]
        )
    )

conn.commit()
