# sqlite_utils.py
import sqlite3
import os

def ejecutar_sql(archivo_sql, ruta_db):
    if not os.path.isfile(archivo_sql):
        print(f"[x] Error: El archivo SQL '{archivo_sql}' no existe.")
        return

    if not os.path.isfile(ruta_db):
        print(f"[x] Error: La base de datos SQLite '{ruta_db}' no existe.")
        return

    try:
        with open(archivo_sql, 'r', encoding='utf-8') as f:
            sql_script = f.read()

        conn = sqlite3.connect(ruta_db)
        cursor = conn.cursor()
        cursor.executescript(sql_script)
        conn.commit()
        print(f"[i] Script ejecutado correctamente.")
    except sqlite3.Error as e:
        print(f"[x] Error de SQLite: {e}")
    finally:
        if conn:
            conn.close()
