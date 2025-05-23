# Cancelas, Martín.
# Nicolau, Jorge.A

"""
Script: update_csv_to_tmp.py
Descripción:
  Este script carga los archivos de novedades desde `data/ingesta2/` a las
  tablas temporales `TMP_`, aplicando la lógica de actualización incremental
  sin destruir los datos existentes. Maneja nombres de archivo distintos
  (ej. "orders - novedades.csv") mapeándolos a sus tablas destino correctas.

Uso:
  Ejecutar desde la raíz del proyecto:
      > 10b_load_update_csv_to_tmp.py
      

Requisitos:
  - La base de datos SQLite debe existir (`db/dwa.sqlite`)
  - Las tablas TMP_ deben estar ya creadas
  - Se espera que los archivos estén en la carpeta `data/ingesta2/`
"""

import sqlite3
import pandas as pd
import os
import uuid
import re
import get_execution_id as pid
from dotenv import load_dotenv
from datetime import datetime

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

execution_id = pid.get_or_create_execution_id()

# Cargar .env
load_dotenv(dotenv_path=os.path.join(BASE_DIR, ".env"))

DB_PATH = os.getenv("DB_PATH", "")
CSV_FOLDER = os.getenv("10B_CSV_FOLDER", "")
USER = os.getenv("10B_USER", "")

# Mapas explícitos: archivo → tabla TMP_ (para novedades)
files_tables = [
    ('customers - novedades.csv', 'TMP_Customers'),
    ('orders - novedades.csv', 'TMP_Orders'),
    ('order_details - novedades.csv', 'TMP_OrderDetails')
]

# Tablas que requieren UUID
uuid_required_tables = ['TMP_Customers', 'TMP_Orders', 'TMP_OrderDetails']

# Claves primarias por tabla TMP_
business_keys = {
    'TMP_Customers': 'customerID',
    'TMP_Orders': 'orderID',
    'TMP_OrderDetails': 'orderID'  # asumiendo simplificación
}

# Conexión
conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

# Limpieza de columnas
def clean_column(col):
    col = re.sub(r'[\s\/:\-]+', '_', col)
    col = re.sub(r'\(_?%?\)', '_PCT', col)
    col = col.replace('\n', '_')
    col = re.sub(r'__+', '_', col)
    return col.strip('_')

for file_name, table_name in files_tables:
    path = os.path.join(CSV_FOLDER, file_name)
    print(f"Actualizando {path} -> {table_name}")
    now = datetime.now().isoformat(sep=' ', timespec='seconds')

    try:
        df = pd.read_csv(path)
        df.columns = [c.strip().replace(' ', '_').replace('(', '').replace(')', '').replace('%','PCT') for c in df.columns]
        if file_name == 'world-data-2023.csv':
            df.columns = [clean_column(col) for col in df.columns]

        # Agregar UUID si es necesario
        if table_name in uuid_required_tables:
            if 'uuid' not in df.columns:
                df['uuid'] = None
            df['uuid'] = df['uuid'].apply(lambda x: str(uuid.uuid4()) if pd.isnull(x) or x == '' else x)

        # Reemplazo seguro por clave de negocio
        key = business_keys.get(table_name)
        if key and key in df.columns:
            for _, row in df.iterrows():
                placeholders = ', '.join(['?'] * len(df.columns))
                columns = ', '.join(df.columns)
                sql = f"INSERT OR REPLACE INTO {table_name} ({columns}) VALUES ({placeholders})"
                cursor.execute(sql, tuple(row))

        else:
            # fallback si no hay clave definida
            df.to_sql(table_name, conn, if_exists='append', index=False)

        print(f" - OK ({len(df)} filas)")

    except Exception as e:
        print(f" - ERROR al procesar {file_name}: {e}")

conn.commit()
conn.close()
print("Actualización de novedades completada.")

