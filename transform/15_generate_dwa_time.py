# ejecutar_sqlite_script_env.py
import os
from dotenv import load_dotenv
from sqlite_utils import ejecutar_sql

# Ruta del directorio donde está este script (no el CWD desde donde lo llamás)
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

# Cargar .env relativo a este script también
load_dotenv(dotenv_path=os.path.join(BASE_DIR, ".env"))

# Cargar variable 
DB_PATH = os.getenv("DB_PATH", "")
SCRIPT_FILE_PATH = os.getenv("15_SQL_FILE_PATH", "")
# Resolver rutas relativas al script
ruta_db = os.path.join(BASE_DIR, DB_PATH)
archivo_sql = os.path.join(BASE_DIR, SCRIPT_FILE_PATH)

print("-> Ejecutando SQL:")
print("   SQL:", SCRIPT_FILE_PATH)
print("   DB :", DB_PATH)

ejecutar_sql(archivo_sql, ruta_db)