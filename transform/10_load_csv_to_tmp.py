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
from datetime import datetime

# Configuración
DB_PATH = 'db/dwa-lite.db'
CSV_FOLDER = 'data/ingesta1'
USER = 'pipeline-headless'

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
uuid_required_tables = ['TMP_Customers', 'TMP_Employees', 'TMP_Products']

# Conexión a SQLite
conn = sqlite3.connect(DB_PATH)
cursor = conn.cursor()

for file_name, table_name in files_tables:
    path = os.path.join(CSV_FOLDER, file_name)
    print(f"Cargando {path} en {table_name}...")
    now = datetime.now().isoformat(sep=' ', timespec='seconds')

    try:
        df = pd.read_csv(path)
        df.columns = [c.strip().replace(' ', '_').replace('(', '').replace(')', '').replace('%','PCT') for c in df.columns]

        if file_name == 'world-data-2023.csv':
            if 'Density\n(P/Km2)' in df.columns:
                df.rename(columns={'Density\n(P/Km2)': 'Density_PKm2'}, inplace=True)
        
        if table_name in uuid_required_tables:
            df['uuid'] = [str(uuid.uuid4()) for _ in range(len(df))]

        df.to_sql(table_name, conn, if_exists='replace', index=False)

        # Registro en DQM_LoadResults
        cursor.execute("""
            INSERT INTO DQM_LoadResults (
                sourceFile, tableTarget, rowCountSource, rowCountLoaded,
                rejectedRows, loadStatus, loadMessage, createdAt
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            file_name, table_name, len(df), len(df), 0, 'SUCCESS', 'OK', now
        ))

        # Registro en MET_Lineage
        cursor.execute("""
            INSERT INTO MET_Lineage (
                sourceEntity, targetEntity, transformationDescription,
                transformationScript, lineageType, createdAt
            ) VALUES (?, ?, ?, ?, ?, ?)
        """, (
            file_name, table_name, 'Carga directa desde CSV', None, 'direct', now
        ))

        print(f" - OK ({len(df)} filas)")

    except Exception as e:
        cursor.execute("""
            INSERT INTO DQM_LoadResults (
                sourceFile, tableTarget, rowCountSource, rowCountLoaded,
                rejectedRows, loadStatus, loadMessage, createdAt
            ) VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
            file_name, table_name, 0, 0, 0, 'FAILURE', str(e), now
        ))

        print(f" - ERROR al cargar {file_name}: {e}")

conn.commit()
conn.close()
print("Carga completada.")
