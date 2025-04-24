# load_csv_to_tmp.py
# Script para cargar archivos CSV de Ingesta1 en tablas TMP_ en SQLite, con trazabilidad UUID

import sqlite3
import pandas as pd
import os
import uuid
from datetime import datetime

# Configuración
DB_PATH = 'dwa.sqlite'
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
