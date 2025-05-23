# quality_checks.py
import sqlite3
from datetime import datetime
import pandas as pd
import numpy as np

def validate_table_quality(DB_PATH, table):
    # Conexión
    conn = sqlite3.connect(DB_PATH)
    print(f"Conectado a base: {DB_PATH}")
    cursor = conn.cursor()
    issues = []

    # Row count
    row_count = cursor.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]

    # Columnas
    columns_info = cursor.execute(f"PRAGMA table_info({table})").fetchall()
    columns = [col[1] for col in columns_info]

    # Cargar tabla completa como DataFrame
    df = pd.read_sql_query(f"SELECT * FROM {table}", conn)

    # Verificación de valores nulos
    nulls = df.isnull().sum()
    for col, count in nulls.items():
        if count > 0:
            issues.append((table, col, 'NULL_VALUES', int(count), 'MEDIUM'))

    # Verificación de duplicados si hay uuid
    if 'uuid' in df.columns:
        dup_count = df['uuid'].duplicated().sum()
        if dup_count > 0:
            issues.append((table, 'uuid', 'DUPLICATES', int(dup_count), 'HIGH'))

    # Verificación de outliers
    numeric_cols = df.select_dtypes(include=[np.number]).columns
    for col in numeric_cols:
        Q1 = df[col].quantile(0.25)
        Q3 = df[col].quantile(0.75)
        IQR = Q3 - Q1

        # Outliers normales (1.5 * IQR)
        outlier_mask = (df[col] < Q1 - 1.5 * IQR) | (df[col] > Q3 + 1.5 * IQR)
        outlier_count = outlier_mask.sum()
        if outlier_count > 0:
            issues.append((table, col, 'OUTLIERS', int(outlier_count), 'LOW'))

        # Outliers severos (3 * IQR)
        severe_outlier_mask = (df[col] < Q1 - 3 * IQR) | (df[col] > Q3 + 3 * IQR)
        severe_outlier_count = severe_outlier_mask.sum()
        if severe_outlier_count > 0:
            issues.append((table, col, 'SEVERE_OUTLIERS', int(severe_outlier_count), 'HIGH'))

    # Guardar estadísticas generales
    cursor.execute("""
        INSERT INTO DQM_TableStatistics (tableName, rowCount, nullCount, createdAt, dataLayer)
        VALUES (?, ?, ?, ?, ?)
    """, (table, row_count, int(nulls.sum()), datetime.now().isoformat(), table.split('_')[0]))
    conn.commit()

    # Guardar issues
    for table_name, col, issue_type, count, severity in issues:
        cursor.execute("""
            INSERT INTO DQM_FieldIssues (tableName, fieldName, issueType, issueCount, createdAt, severity)
            VALUES (?, ?, ?, ?, ?, ?)
        """, (table_name, col, issue_type, count, datetime.now().isoformat(), severity))
    conn.commit()

    print(f"[i] Validación de calidad completada: {table} ({row_count} filas, {len(issues)} issues)")

    conn.close()
