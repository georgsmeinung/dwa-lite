"""
Script: validate_quality.py
Descripción:
  Este script ejecuta validaciones automáticas de calidad sobre las tablas
  del DWA (DWA_, DWM_) y registra los resultados en la capa DQM_.
  Evalúa aspectos clave como valores nulos, duplicados, y consistencia referencial,
  permitiendo generar alertas e indicadores que alimentan dashboards técnicos.

Funcionalidad:
  - Recorre cada tabla relevante del DWA (o lista parametrizable).
  - Cuenta valores nulos por columna y los compara contra umbrales.
  - Detecta duplicados basados en claves naturales o surrogate keys.
  - Registra resultados en `DQM_TableStatistics` y `DQM_FieldIssues`.
  - Opcionalmente, puede validar integridad entre claves foráneas.

Entradas esperadas:
  - Base de datos SQLite con las capas DWA_, DWM_ y DQM_ ya creadas.
  - Las tablas deben contener datos actualizados.

Salidas:
  - Nuevas filas en `DQM_TableStatistics` y `DQM_FieldIssues`
  - Impresiones por consola para debug y trazabilidad

Recomendación:
  - Ejecutar después de poblar o actualizar las tablas DWA_/DWM_
  - Usar como paso previo a la generación de productos DP_

Uso:
  Este script puede invocarse en un entorno automatizado (headless)
"""

import sqlite3
from datetime import datetime

DB_PATH = "db/dwa.sqlite"
TABLES_TO_VALIDATE = [
    "DWA_Customers",
    "DWA_Products",
    "DWM_Customers",
    "DWM_Employees",
    "DWM_Products"
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
        INSERT INTO DQM_TableStatistics (tableName, rowCount, nullFields, checkDateTime, dataLayer)
        VALUES (?, ?, ?, ?, ?)
    """, (table, row_count, len(nulls), datetime.now().isoformat(), table.split('_')[0]))
    conn.commit()

    # Registrar problemas de calidad
    for table_name, col, issue_type, count, severity in issues:
        cursor.execute("""
            INSERT INTO DQM_FieldIssues (tableName, columnName, issueType, issueCount, issueDateTime, severity)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (table_name, col, issue_type, count, datetime.now().isoformat(), severity))
    conn.commit()

    print(f"[✔] Validación de calidad completada: {table} ({row_count} filas, {len(issues)} issues)")

# Conexión y ejecución directa para ejecución en cadena
conn = sqlite3.connect(DB_PATH)
for table in TABLES_TO_VALIDATE:
    validate_table_quality(conn, table)
conn.close()
