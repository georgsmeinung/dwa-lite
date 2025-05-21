"""
Script: update_csv_to_tmp.py
Descripción:
  Este script carga los archivos de novedades desde `data/ingesta2/` a las
  tablas temporales `TMP_`, aplicando la lógica de actualización incremental
  sin destruir los datos existentes. Maneja nombres de archivo distintos
  (ej. "orders - novedades.csv") mapeándolos a sus tablas destino correctas.

Uso:
  Ejecutar desde la raíz del proyecto:
      > python transform/update_csv_to_tmp.py

Requisitos:
  - La base de datos SQLite debe existir (`db/dwa.sqlite`)
  - Las tablas TMP_ deben estar ya creadas
  - Se espera que los archivos estén en la carpeta `data/ingesta2/`
"""

import os
import sqlite3
import pandas as pd
import uuid
from datetime import datetime

DATA_DIR = "data/ingesta2"
DB_PATH = "db/dwa-lite.db"

# Mapeo explícito de nombres de archivo → tabla destino
FILENAME_TO_TABLE = {
    "customers - novedades.csv": "TMP_Customers",
    "orders - novedades.csv": "TMP_Orders",
    "order_details - novedades.csv": "TMP_OrderDetails"
}

TABLES_WITH_UUID = ["TMP_Customers"]  # Agregar uuid solo si es necesario

# Conexión a SQLite
conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

def append_to_tmp_table(filename, tablename):
    path = os.path.join(DATA_DIR, filename)
    df = pd.read_csv(path)

    if tablename in TABLES_WITH_UUID:
        df["uuid"] = [str(uuid.uuid4()) for _ in range(len(df))]

    # Inserta sin borrar lo existente
    df.to_sql(tablename, conn, if_exists="append", index=False)

    print(f"[✓] {filename} -> {tablename} ({len(df)} filas insertadas)")

# Apagado de Keys
cursor.execute("""
            PRAGMA foreign_keys = OFF;
        """)
current = cursor.fetchone()
        
# Procesamiento de archivos
for file in os.listdir(DATA_DIR):
    if file in FILENAME_TO_TABLE:
        try:
            append_to_tmp_table(file, FILENAME_TO_TABLE[file])
        except Exception as e:
            print(f"[✘] Error al cargar {file}: {e}")
    else:
        print(f"[!] Archivo ignorado (sin mapeo definido): {file}")

cursor.execute("""
            PRAGMA foreign_keys = ON;
        """)
current = cursor.fetchone()

conn.close()
