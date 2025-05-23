# quality_checks.py
import sqlite3
from datetime import datetime

def validate_table_quality(DB_PATH, table):

    # Conexión y ejecución directa para ejecución en cadena
    conn = sqlite3.connect(DB_PATH)
    print(f"Conectado a base: {DB_PATH}")
    
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

    if 'uuid' in columns:
        dup_count = cursor.execute(f"""
            SELECT COUNT(*) FROM (
                SELECT uuid, COUNT(*) as cnt FROM {table}
                GROUP BY uuid HAVING cnt > 1
            ) t
        """).fetchone()[0]
        if dup_count > 0:
            issues.append((table, 'uuid', 'DUPLICATES', dup_count, 'HIGH'))

    cursor.execute("""
        INSERT INTO DQM_TableStatistics (tableName, rowCount, nullCount, createdAt, dataLayer)
        VALUES (?, ?, ?, ?, ?)
    """, (table, row_count, len(nulls), datetime.now().isoformat(), table.split('_')[0]))
    conn.commit()

    for table_name, col, issue_type, count, severity in issues:
        cursor.execute("""
            INSERT INTO DQM_FieldIssues (tableName, fieldName, issueType, issueCount, createdAt, severity)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (table_name, col, issue_type, count, datetime.now().isoformat(), severity))
    conn.commit()

    print(f"`[i]` Validación de calidad completada: {table} ({row_count} filas, {len(issues)} issues)")
    
    conn.close()

