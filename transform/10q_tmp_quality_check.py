# Cancelas, Martín.
# Nicolau, Jorge.

# Script: validate_quality.py
import os
import sys
from dotenv import load_dotenv
from quality_checks import validate_table_quality

# Establecer working directory como el del script
script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)
sys.path.insert(0, script_dir)

# Cargar variables de entorno desde .env
load_dotenv()

DB_PATH = os.getenv('DB_PATH')  
print(DB_PATH) 

TABLES_TO_VALIDATE = [
    "TMP_Categories", "TMP_Customers", "TMP_EmployeeTerritories", "TMP_Employees", "TMP_OrderDetails",
    "TMP_Orders", "TMP_Products", "TMP_Regions", "TMP_Shippers", "TMP_Suppliers", "TMP_Territories", "TMP_WorldData2023"
]

for table in TABLES_TO_VALIDATE:
    validate_table_quality(DB_PATH, table)
