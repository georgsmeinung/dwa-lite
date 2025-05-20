"""
Script: validate_quality.py
Descripción:
  Ejecuta validaciones automáticas de calidad sobre las tablas del DWA y DWM 
  y registra los resultados en DQM_TableStatistics y DQM_FieldIssues.

Mejoras:
  - Carga configuración dinámica desde un archivo .env
  - Evita hardcodear el path a la base de datos.

Uso:
  1. Definir el archivo .env en la raíz del proyecto con:
     DB_PATH=db/dwa-lite.db
  2. Ejecutar el script normalmente:
     $ python transform/validate_quality.py
"""

import sqlite3
import os
from dotenv import load_dotenv
from datetime import datetime

# Cargar variables de entorno desde .env
load_dotenv()

DB_PATH = os.getenv('DB_PATH', 'db/dwa-lite.db')  # Default de seguridad

TABLES_TO_VALIDATE = [
    "DWA_Customers",
    "DWA_Employees"
    "DWA_Products",
    "DWA_Time",
    "DWA_WorldData2023",
    "DWA_SalesFact",
    "DWA_DeliveriesFact",
    "DWM_Customers",
    "DWM_Employees",
    "DWM_Products",
    "DWM_WorldData2023",
    "DWM_SalesFact",
    "DWM_DeliveriesFact"
]

def validate_table_quality(conn, table):
    cursor = conn.cursor()
    issues = []
    row_count = cursor.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]
    columns = [col[1] for col in cursor.execute(f"PRAGMA table_info({table})")]

    nulls = {}
    for col in columns:
        count = cursor.execute(f"SELECT COUNT(*) FROM {table} WHERE {col} IS NULL").fetchone()[0]
        if count > 0:
            nulls[col] = count
            issues.append((table, col, 'NULL_VALUES', count, 'MEDIUM'))

    # Detectar duplicados por uuid si existe
    if 'uuid' in columns:
        dup_count = cursor.execute(f"""
            SELECT COUNT(*) FROM (
                SELECT uuid, COUNT(*) as cnt FROM {table}
                GROUP BY uuid HAVING cnt > 1
            ) t
        """).fetchone()[0]
        if dup_count > 0:
            issues.append((table, 'uuid', 'DUPLICATES', dup_count, 'HIGH'))

    # Registrar estadísticas generales
    cursor.execute("""
        INSERT INTO DQM_TableStatistics (tableName, rowCount, nullCount, createdAt, dataLayer)
        VALUES (?, ?, ?, ?, ?)
    """, (table, row_count, len(nulls), datetime.now().isoformat(), table.split('_')[0]))
    conn.commit()

    # Registrar problemas de calidad
    for table_name, col, issue_type, count, severity in issues:
        cursor.execute("""
            INSERT INTO DQM_FieldIssues (tableName, fieldName, issueType, issueCount, createdAt, severity)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (table_name, col, issue_type, count, datetime.now().isoformat(), severity))
    conn.commit()

    print(f"[✔] Validación de calidad completada: {table} ({row_count} filas, {len(issues)} issues)")

# Conexión y ejecución directa para ejecución en cadena
conn = sqlite3.connect(DB_PATH)
print(f"Conectado a base: {DB_PATH}")

for table in TABLES_TO_VALIDATE:
    validate_table_quality(conn, table)

conn.close()
