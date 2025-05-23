# Cancelas, Martín.
# Nicolau, Jorge.A

"""
Script: load_csv_to_tmp.py
Descripción:
  Carga automáticamente los archivos CSV de la carpeta `data/ingesta1/` a
  las tablas `TMP_` en SQLite. Para cada archivo:
    - Se crea un DataFrame con pandas.
    - Se agrega un campo `uuid` si la tabla lo requiere (Customers, Employees, Products).
    - Se carga en la tabla `TMP_` correspondiente.
    - Se registra la carga en `DQM_LoadResults` con cantidad de filas y estado.
    - Se deja traza en `MET_Lineage` para trazabilidad de origen.

Uso:
  Ejecutar desde la raíz del proyecto con:
    $ python scripts/load_csv_to_tmp.py

Dependencias:
  - pandas
  - sqlite3
  - uuid
"""

import sqlite3
import pandas as pd
import os
import uuid
import re
import get_execution_id as pid
from dotenv import load_dotenv
from datetime import datetime

# Ruta del directorio donde está este script (no el CWD desde donde lo llamás)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

execution_id = pid.get_or_create_execution_id()

# Cargar .env relativo a este script también
load_dotenv(dotenv_path=os.path.join(BASE_DIR, ".env"))

# Cargar variable 
DB_PATH = os.getenv("DB_PATH", "")
CSV_FOLDER = os.getenv("10A_CSV_FOLDER", "")
USER = os.getenv("10A_USER", "")


# Lista de archivos y tablas destino
files_tables = [
    ('categories.csv', 'TMP_Categories'),
    ('customers.csv', 'TMP_Customers'),
    ('employee_territories.csv', 'TMP_EmployeeTerritories'),
    ('employees.csv', 'TMP_Employees'),
    ('order_details.csv', 'TMP_OrderDetails'),
    ('orders.csv', 'TMP_Orders'),
    ('products.csv', 'TMP_Products'),
    ('regions.csv', 'TMP_Regions'),
    ('shippers.csv', 'TMP_Shippers'),
    ('suppliers.csv', 'TMP_Suppliers'),
    ('territories.csv', 'TMP_Territories'),
    ('world-data-2023.csv', 'TMP_WorldData2023')
]

# Tablas donde se requiere UUID para trazabilidad
uuid_required_tables = ['TMP_Categories','TMP_Customers', 'TMP_Employees','TMP_EmployeeTerritories', 'TMP_Employees','TMP_OrderDetails', 'TMP_Orders','TMP_Products','TMP_Regions','TMP_Shippers','TMP_Suppliers','TMP_Territories','TMP_WorldData2023']

# Conexión a SQLite
conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

# Clean column names
def clean_column(col):
    col = re.sub(r'[\s\-/\\:]+', '_', col)        # Replace colon with underscore
    col = re.sub(r'[\s\-/\\]+', '_', col)         # Replace spaces, dashes, slashes with underscores
    col = re.sub(r'\(_?%?\)', '_PCT', col)        # Replace variations of "(%)" or "( %)" with "_PCT"
    col = col.replace('\n', '_')                  # Replace line breaks with underscore
    col = re.sub(r'__+', '_', col)                # Collapse multiple underscores
    return col.strip('_')

for file_name, table_name in files_tables:
    path = os.path.join(CSV_FOLDER, file_name)
    print(f"Cargando {path} en {table_name}...")
    now = datetime.now().isoformat(sep=' ', timespec='seconds')

    try:
        df = pd.read_csv(path)
        df.columns = [c.strip().replace(' ', '_').replace('(', '').replace(')', '').replace('%','PCT') for c in df.columns]
        
        if file_name == 'world-data-2023.csv': df.columns = [clean_column(col) for col in df.columns]
                        
        if table_name in uuid_required_tables:
            generated = set()
            
            def generate_unique_uuid():
                new_id = str(uuid.uuid4())
                while new_id in generated:
                    new_id = str(uuid.uuid4())
                generated.add(new_id)
                return new_id

            df['uuid'] = [generate_unique_uuid() for _ in range(len(df))]


        df.to_sql(table_name, conn, if_exists='append', index=False)

        # Registro en DQM_LoadResults
        cursor.execute("""
            INSERT INTO DQM_LoadResults (
                sourceFile, tableTarget, rowCountSource, rowCountLoaded,
                rejectedRows, loadStatus, loadMessage, createdAt
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            file_name, table_name, len(df), len(df), 0, 'SUCCESS', execution_id , now
        ))

        # Registro en MET_Lineage
        cursor.execute("""
            INSERT INTO MET_Lineage (
                sourceEntity, targetEntity, transformationDescription,
                transformationScript, lineageType, createdAt
            ) VALUES (?, ?, ?, ?, ?, ?)
        """, (
            file_name, table_name, 'Carga directa desde CSV', execution_id, 'direct', now
        ))

        print(f" - OK ({len(df)} filas)")

    except Exception as e:
        cursor.execute("""
            INSERT INTO DQM_LoadResults (
                sourceFile, tableTarget, rowCountSource, rowCountLoaded,
                rejectedRows, loadStatus, loadMessage, createdAt
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            file_name, table_name, 0, 0, 0, 'FAILURE', execution_id + str(e), now
        ))

        print(f" - ERROR al cargar {file_name}: {e}")

conn.commit()
conn.close()
print("Carga completada.")
